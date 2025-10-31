/**
    Main contract that takes all the Interfaces defined thus far and sets up the whole resource based process.
    
    This contract establishes all the resources from the interfaces imported but it also has to deal with an interesting limitation of Cadence. Well, it is not a proper technical limitation, but more of a "avoid this if possible" condition, which is having a Collection of Elections, while Elections are also Collections already by themselves. Though there's nothing in Cadence that prevents that, the documentation advises developers to avoid this if possible. And I wanted to because it is going to mess with idea of delegating ElectionPublic capabilities through Ballots. As such, I'm going to use this contract to come up with an automatic way to create and manage Elections without using a Collection.

    @author: Ricardo Lopes Almeida - https://github.com/rdlalmeida
**/
import "Burner"
import "BallotStandard"
import "ElectionStandard"
import "VoteBoxStandard"

access(all) contract VoteBooth {
    // CUSTOM PATHS
    access(all) let voteBoothPrinterAdminStoragePath: StoragePath
    access(all) let electionIndexStoragePath: StoragePath
    access(all) let electionIndexPublicPath: PublicPath

    // CUSTOM ENTITLEMENTS
    access(all) entitlement VoteBoothAdmin

    // CUSTOM EVENTS
    access(all) event ElectionIndexCreated(_accountAddress: Address)
    // Event for when the ElectionIndex is destroyed. The activeElections parameter is the number of elections in the main index still active/existing.
    access(all) event ElectionIndexDestroyed(_accountAddress: Address)
    access(all) event VoteBoothPrinterAdminCreated(_accountAddress: Address)
    access(all) event VoteBoothPrinterAdminDestroyed(_accountAddress: Address)

    // Use this parameter to validate the process structure by ensuring that all contracts in the project were deployed by the same address, i.e., to the same account.
    access(all) let deployerAddress: Address

    // I'm using this variable to determine the verbosity of some of the functions in this project which log stuff to the blockchain's message stack. 
    // This makes sense for local tests where there's little traffic in the local blockchain emulator, but it is pointless to do in a test or mainnet setting
    // Adjust this accordingly
    access(all) var verbose: Bool

    /**
        Internal function to validate contract consistency up to this point. In other words, this function ensures that all dependencies and this contract has the same deployerAddress.

        @returns (Bool) If this contract and all dependencies have the same deployerAddress, this function returns true. Otherwise a false is returned instead.
    **/
    access(self) view fun validateContract(): Bool {
        if (
            (BallotStandard.deployerAddress == ElectionStandard.deployerAddress) && 
            (ElectionStandard.deployerAddress == VoteBoxStandard.deployerAddress) && 
            (VoteBoxStandard.deployerAddress == self.deployerAddress) 
            ) {
                return true
            }
            else {
                return false
            }
    }

    /**
        This function abstracts the logic of retrieving a &{ElectionStandard.ElectionPublic}. To avoid storing collections inside other collections, I had to come up with a slightly convoluted process that requires retrieving a bunch of references from all over the place. This function simplifies this process by receiving just the electionId and returning the public reference, if the Election exists, or nil if not.

        @param electionId (UInt64) The election identifier for the Election whose reference are to be retrieved from.

        @returns &{ElectionStandard.ElectionPublic}? If an Election for the electionId provided exists, this function returns it. Otherwise a nil is returned instead.
    **/
    access(all) view fun getElectionPublicReference(electionId: UInt64): &{ElectionStandard.ElectionPublic}? {
        // Start by getting the unauthorized account reference to the account where the ElectionIndex is stored in
        let deployerAccount: &Account = getAccount(VoteBooth.deployerAddress)

        let electionIndexRef: &{VoteBooth.ElectionIndexPublic} = deployerAccount.capabilities.borrow<&{VoteBooth.ElectionIndexPublic}>(VoteBooth.electionIndexPublicPath) ??
        panic(
            "Unable to retrieve a valid &{VoteBooth.ElectionIndexPublic} at "
            .concat(VoteBooth.electionIndexPublicPath.toString())
            .concat(" from account ")
            .concat(deployerAccount.address.toString())
        )

        // At this point, check if the electionId is among the active ones. Continue only if so, return a nil if not
        if (!electionIndexRef.electionExists(electionId: electionId)) {
            return nil
        }

        // The election exists. Get the public path for the election in question from the election index reference
        let electionPublicPath: PublicPath = electionIndexRef.getElectionPublicPath(electionId: electionId) ??
        panic(
            "Unable to retrieve a valid PublicPath for election "
            .concat(electionId.toString())
            .concat(" for the Election Index from account ")
            .concat(deployerAccount.address.toString())
        )

        // Get the public reference to the election from here
        let electionPublicRef: &{ElectionStandard.ElectionPublic} = deployerAccount.capabilities.borrow<&{ElectionStandard.ElectionPublic}>(electionPublicPath) ??
        panic(
            "Unable to retrieve a &{ElectionStandard.ElectionPublic} at "
            .concat(electionPublicPath.toString())
            .concat(" from account ")
            .concat(deployerAccount.address.toString())
        )

        return electionPublicRef
    }

    // ---------------------------------------------------------------- BALLOT BEGIN ---------------------------------------------------------------------------
    // ---------------------------------------------------------------- BALLOT END -----------------------------------------------------------------------------

    // ---------------------------------------------------------------- ELECTION BEGIN -------------------------------------------------------------------------
    // This one is a simple public interface to apply to the ElectionIndex, just to expose the electionExists function
    access(all) resource interface ElectionIndexPublic {
        access(all) view fun electionExists(electionId: UInt64): Bool
        access(all) view fun getElectionStoragePath(electionId: UInt64): StoragePath?
        access(all) view fun getElectionPublicPath(electionId: UInt64): PublicPath?
        access(all) view fun getActiveElectionIds(): [UInt64]
        access(all) fun listActiveElections(): {UInt64: String}
        access(all) view fun getPublicElectionReference(_electionId: UInt64): &{ElectionStandard.ElectionPublic}?
    }

    /**
        I need a way to keep track of all Election resources created and saved in this account. The obvious strategy would be to create another collection-type resource, but this goes against Cadence good programming practices, which strongly discourages collections of collections, since Elections are Ballot-type collections themselves already. I also want to ensure that only the contract deployer can play around with this data, so the most secure approach is to encode all this into a new, admin-type resource.
    **/
    access(all) resource ElectionIndex: ElectionIndexPublic, Burner.Burnable {
        // Use this dictionary to keep track of any issued Elections. This dictionary uses the format {electionId: {ElectionStoragePath: ElectionPublicPath}}
        access(self) var electionIndex: {UInt64: {StoragePath: PublicPath}}

        // Simple getter to determine if a given Election exists and it is still active
        access(all) view fun electionExists(electionId: UInt64): Bool {
            return self.electionIndex.containsKey(electionId)
        }

        /**
            Function to add a new record to the ElectionIndex resource.

            @param electionId (UInt64) The electionId of the resource in question.
            @param electionStoragePath (StoragePath) The path to the private storage area where the Election resource was stored.
            @param electionPublicPath (PublicPath) The path to the public storage area where a public reference to this Election can be retrieved from.
        **/
        access(account) fun addElectionToIndex(electionId: UInt64, electionStoragePath: StoragePath, electionPublicPath: PublicPath): Void {
            // Done
            self.electionIndex[electionId] = {electionStoragePath: electionPublicPath}
        }
        
        /**
            Function to remove a record identified by the electionId provided from this ElectionIndex resource.

            @param electionId (UInt64) The electionId of the resource in question.
        **/
        access(account) fun removeElectionFromIndex(electionId: UInt64): {StoragePath: PublicPath}? {
            return self.electionIndex.remove(key: electionId)
        }

        /**
            Simple function to retrieve a {StoragePath: PublicPath} record from an existing ElectionIndex, for the electionId provided. If no Election exists in the current ElectionIndex, a nil is returned instead.

            @param electionId (UInt64) The electionId of the Election resource in question.

            @return {StoragePath: PublicPath}? If an Election with the provided electionId exists, the function returns the corresponding entry. If the Election does not exists, a nil is returned instead.
        **/
        access(account) view fun getElectionIndexEntry(electionId: UInt64): {StoragePath: PublicPath}? {
            if (!self.electionExists(electionId: electionId)) {
                return nil
            }
            else {
                let electionEntry: {StoragePath: PublicPath} = self.electionIndex[electionId] ??
                panic(
                    "Unable to retrieve a valid {StoragePath: PublicPath} record for electionId "
                    .concat(electionId.toString())
                    .concat(" for account ")
                    .concat(self.owner!.address.toString())
                )
            
            return electionEntry
            }
        }

        /**
            This function receives an electionId and returns the private storage path where the Election in question is currently stored, if one exists. Otherwise, returns nil.

            @param electionId (UInt64) The electionId of the Election resource in question.

            @return StoragePath? If an Election with the provided electionId exists, the function returns the corresponding StoragePath. If the Election does not exists, a nil is returned instead.
        **/
        access(all) view fun getElectionStoragePath(electionId: UInt64): StoragePath? {    
            let electionEntry: {StoragePath: PublicPath}? = self.getElectionIndexEntry(electionId: electionId)
            
            if (electionEntry == nil) {
                return nil
            }
            else {
                // Return only the single key
                return electionEntry!.keys[0]
            }
        }

        /**
            This function receives an electionId and returns the public storage path where the Election in question has its public capability stored to, if one exists.

            @param electionId (UInt64) The electionId of the Election resource in question.

            @return PublicPath? If an Election with the provided electionId exists, the function returns the corresponding PublicPath. If the Election does not exists, a nil is returned instead
        **/
        access(all) view fun getElectionPublicPath(electionId: UInt64): PublicPath? {
            let electionEntry: {StoragePath: PublicPath}? = self.getElectionIndexEntry(electionId: electionId)

            if (electionEntry == nil) {
                return nil
            }
            else {
                // Return the one value
                return electionEntry!.values[0]
            }
        }

        /**
            Simple function to return the array of keys used in the ElectionIndex dictionary, which essentially returns the array of keys for the electionIndex internal structure.

            @returns ([UInt64]) If successful, this function returns the array of active electionIds from the electionIndex internal dictionary.
        **/
        access(all) view fun getActiveElectionIds(): [UInt64] {
            return self.electionIndex.keys
        }

        /**
            This function returns a dictionary in the format {electionId: electionName} to provide a more intuitive pairing between the id of the Election resource and its name.

            @returns {UInt64: String} A dictionary in the format {UInt64: electionName}
        **/
        access(all) fun listActiveElections(): {UInt64: String} {
            // Grab a list of all active electionIds
            let activeElectionIds: [UInt64] = self.getActiveElectionIds()

            // I need a reference to the VoteBooth deployer account. Does not need to be an authorized one
            let deployerAccount: &Account = getAccount(VoteBooth.deployerAddress)
            // Use it to get a public reference to the ElectionIndex
            let electionIndexRef: &{VoteBooth.ElectionIndexPublic} = deployerAccount.capabilities.borrow<&{VoteBooth.ElectionIndexPublic}>(VoteBooth.electionIndexPublicPath) ??
            panic(
                "Unable to retrieve a valid &{VoteBooth.ElectionIndexPublic} at "
                .concat(VoteBooth.electionIndexPublicPath.toString())
                .concat(" from account ")
                .concat(deployerAccount.address.toString())
            )

            var electionInfo: {UInt64: String} = {}

            // Compose the return dictionary in a loop
            for activeElectionId in activeElectionIds {
                let electionPublicPath: PublicPath = electionIndexRef.getElectionPublicPath(electionId: activeElectionId) ??
                panic(
                    "Unable to get a valid PublicPath from the ElectionIndex for electionId "
                    .concat(activeElectionId.toString())
                    .concat(" in account ")
                    .concat(deployerAccount.address.toString())
                )

                let electionRef: &{ElectionStandard.ElectionPublic} = deployerAccount.capabilities.borrow<&{ElectionStandard.ElectionPublic}>(electionPublicPath) ??
                panic(
                    "Unable to get a valid &{ElectionStandard.ElectionPublic} at "
                    .concat(electionPublicPath.toString())
                    .concat(" for account ")
                    .concat(deployerAccount.address.toString())
                )

                let electionName: String = electionRef.getElectionName()

                electionInfo[activeElectionId] = electionName
            }

            return electionInfo
        }
        
        /**
            This function abstracts a lot of the logic required to retrieve a public reference to a given Election resource in store. Because of the convoluted way in which I have to store Elections in this project, I need to do a lot to get a public reference to one, hence why I abstracted the whole process with a simple function.

            @param _electionId (UInt64) The election identifier for the Election whose reference is to be returned.

            @returns (&{ElectionStandard.ElectionPublic}) If an Election exists in store in the VoteBooth contract deployer account, this function returns the public reference to it. If anything happens that makes this reference retrieval impossible, the relevant panic is thrown instead.
        **/
        access(all) view fun getPublicElectionReference(_electionId: UInt64): &{ElectionStandard.ElectionPublic} {
            // Set up the account where all the Election are stored in
            let deployerAccount: &Account = getAccount(VoteBooth.deployerAddress)

            // Start by making sure that the Election does exist
            if (!self.electionExists(electionId: _electionId)) {
                panic(
                    "ERROR: There are no Elections in storage with id "
                    .concat(_electionId.toString())
                    .concat(" for account ")
                    .concat(deployerAccount.address.toString())
                )
            }
            

            // The Election exists. Retrieve the PublicPath where its public reference should have been published to
            let electionPublicPath: PublicPath = self.getElectionPublicPath(electionId: _electionId) ??
            panic(
                "Unable to retrieve a valid PublicPath from the ElectionIndex in account "
                .concat(deployerAccount.address.toString())
            )


            let electionRef: &{ElectionStandard.ElectionPublic} = deployerAccount.capabilities.borrow<&{ElectionStandard.ElectionPublic}>(electionPublicPath) ??
            panic(
                "Unable to retrieve a valid &{ElectionStandard.ElectionPublic} at "
                .concat(electionPublicPath.toString())
                .concat(" from account ")
                .concat(deployerAccount.address.toString())
            )

            return electionRef
        }

        /**
            Typical burnCallback function to be automatically executed when this resource gets destroyed with the Burner contract. This allows me to ensure that all Election resources are also properly destroyed before destroying this ElectionIndex resource permanently. But since I need to load each individual Election in order to destroy it, I cannot use the usual Burner contract and the burnCallback function. The burnCallback function does not accepts any arguments but I need to provide it with an authorized reference to the account where the Elections are currently stored in.

            @param deployed (auth(Storage) &Account) An authorized reference to the account that stores all Elections.
        **/
        access(account) fun cleanElectionStorage(deployer: auth(Storage) &Account): Void {
            // Use the internal electionIndex to load, unpublish and destroy all Elections in storage
            let electionListRef: &VoteBooth.ElectionIndex? = deployer.storage.borrow<&VoteBooth.ElectionIndex>(from: VoteBooth.electionIndexStoragePath)

            // Proceed only of this reference is not nil. Otherwise it is pointless to go on
            if (electionListRef != nil) {
                let electionKeys: &[UInt64] = electionListRef!.electionIndex.keys

                // Do the rest in a loop
                for electionKey in electionKeys {
                    // Process each record individually
                    let currentRecord: &{StoragePath: PublicPath}? = electionListRef!.electionIndex[electionKey]

                    if (currentRecord != nil) {
                        let currentKey: StoragePath = currentRecord!.keys[0]

                        let currentElection: @ElectionStandard.Election? <- deployer.storage.load<@ElectionStandard.Election>(from: currentKey)
                        
                        // Use the Burner contract to destroy the individual Elections and trigger their burnCallback functions
                        Burner.burn(<- currentElection)
                    }
                }
            }
        }

        /**
            burnCallback function, as requested from the Burner.Burnable interface.
        **/
        access(contract) fun burnCallback(): Void {
            // Not a lot to do but to emit the ElectionIndexDestroyed event
            emit ElectionIndexDestroyed(_accountAddress: VoteBooth.deployerAddress)
        }

        init() {
            self.electionIndex = {}

            // Emit the ElectionIndexCreated event
            emit ElectionIndexCreated(_accountAddress: VoteBooth.deployerAddress)
        }
    }
    // ---------------------------------------------------------------- ELECTION END ---------------------------------------------------------------------------

    // ---------------------------------------------------------------- VOTEBOX BEGIN --------------------------------------------------------------------------
    // ---------------------------------------------------------------- VOTEBOX END ----------------------------------------------------------------------------

    // ---------------------------------------------------------------- BALLOT PRINTER ADMIN BEGIN -------------------------------------------------------------
    access(all) resource VoteBoothPrinterAdmin: Burner.Burnable {
        /**
            This function is the only process to create new Ballots in this context. I've made the BallotStandard contract such that anyone can import it and use the resource in their own version of this election platform. But for this instance in particular, the only entry point to create a new Ballot is through one of these BallotPrinterAdmin resources.

            @param newLinkedElectionId (UInt64) The electionId to the Election resource that this Ballot can be submitted to.
            @param newElectionCapability (Capability<&{ElectionStandard.ElectionPublic}>) A Capability to retrieve the public reference to the Election associated to this Ballot.
            @param deployer (auth(VoteBoxStandard.VoteBoxAdmin, ElectionStandard.ElectionAdmin)) An authorized reference to an account with VoteBoxAdmin and ElectionAdmin privileges so that I can use it to retrieve authorized references to those resources.

            @returns (UInt64?) If successful, this function stores the minted Ballot directly into the voterAddress's account and returns the ballotId of the new Ballot created. Otherwise a nil is returned instead.
        **/
        access(all) fun createBallot(newLinkedElectionId: UInt64, voterAddress: Address, deployer: auth(BorrowValue, VoteBoxStandard.VoteBoxAdmin, ElectionStandard.ElectionAdmin) &Account): UInt64?
        {
            // New Ballots can only be created if an ElectionIndex exists, an Election with the provided newLinkedElectionId provided exists also, 
            // and the account retrieved from the voterAddress provided has a valid @VoteBoxStandard.VoteBox. Validate these points an create the 
            // Ballot if everything is OK

            // 1. Validate and get a reference to the ElectionIndex resource
            let electionIndexRef: &{VoteBooth.ElectionIndexPublic} = deployer.capabilities.borrow<&{VoteBooth.ElectionIndexPublic}>(VoteBooth.electionIndexPublicPath) ??
            panic(
                "Unable to retrieve a valid &{VoteBooth.ElectionIndexPublic} at "
                .concat(VoteBooth.electionIndexPublicPath.toString())
                .concat(" from account ")
                .concat(deployer.address.toString())
            )

            // Use the index to get the storage path to the election in question. I need to grab an authorized reference from it
            let electionStoragePath: StoragePath = electionIndexRef.getElectionStoragePath(electionId: newLinkedElectionId) ??
            panic(
                "Unable to retrieve a valid election Storage Path for electionId "
                .concat(newLinkedElectionId.toString())
            )

            // 2. Validate and get a reference to the Election with an electionId matching the provided newLinkedElectionId
            // Grab an authorized version to the Election resource
            let electionRef: auth(ElectionStandard.ElectionAdmin) &ElectionStandard.Election = deployer.storage.borrow<auth(ElectionStandard.ElectionAdmin) &ElectionStandard.Election>(from: electionStoragePath) ??
            panic(
                "Unable to retrieve a valid auth(ElectionStandard.ElectionAdmin) &ElectionStandard.Election at "
                .concat(electionStoragePath.toString())
                .concat(" from account ")
                .concat(deployer.address.toString())
            )

            // Before moving any further, check if the Election in question is already finished. If so, panic. I don't want new Ballots submitted into an
            // already tallied Election
            if (electionRef.isElectionFinished()) {
                panic(
                    "ERROR: Election "
                    .concat(newLinkedElectionId.toString())
                    .concat(" was tallied already! Unable to print new Ballots to a closed Election!")
                )
            }

            // 3. Validate and get a reference to a valid VoteBox in the account identified by the voterAddress parameter provided.
            let voterAccount: &Account = getAccount(voterAddress)

            let voteBoxRef: &{VoteBoxStandard.VoteBoxPublic} = voterAccount.capabilities.borrow<&{VoteBoxStandard.VoteBoxPublic}>(VoteBoxStandard.voteBoxPublicPath) ??
            panic(
                "Unable to retrieve a valid &{VoteBoxStandard.VoteBoxPublic} at "
                .concat(VoteBoxStandard.voteBoxPublicPath.toString())
                .concat(" for account ")
                .concat(voterAddress.toString())
            )

            // 4. Use the reference to the Election to get its public capability. Force cast it if needed
            let electionPublicCap: Capability<&{ElectionStandard.ElectionPublic}> = electionRef.getElectionCapability() as! Capability<&{ElectionStandard.ElectionPublic}>

            // 5. Create the Ballot resource and set this capability to it
            let newBallot: @BallotStandard.Ballot <- BallotStandard.createBallot(
                newLinkedElectionId: newLinkedElectionId, 
                newElectionCapability: electionPublicCap, 
                newVoterAddress: voterAddress
            )

            // 6. Add this Ballot's electionId to the Election's totalBallotsMinted and the mintedBallots array
            let newBallotId: UInt64 = newBallot.ballotId

            electionRef.increaseBallotsMinted(ballots: 1)
            electionRef.addMintedBallot(ballotId: newBallotId)

            // 7. Save the ballot onto the voter's VoteBox
            voteBoxRef.depositBallot(ballot: <- newBallot)

            // 8. Finish by returning the ballotId
            return newBallotId
        }

        /**
            Function to add a new entry to the ElectionIndex resource, from within the VoteBoothPrinterAdmin resource.

            @param deployer (auth(Storage) &Account) Authorized reference to the account currently storing the ElectionIndex resource.
            @param electionId (UInt64) The election identifier to the Election resource to process.
            @param electionStoragePath (StoragePath) The storage path to be used as key in the new record.
            @param electionPublicPath (PublicPath) The path to the public storage area to retrieve the public reference to the Election resource.
        **/
        access(all) fun addElectionIndexEntry(deployer: auth(Storage) &Account, electionId: UInt64, electionStoragePath: StoragePath, electionPublicPath: PublicPath): Void {
            let electionIndexRef: &VoteBooth.ElectionIndex = deployer.storage.borrow<&VoteBooth.ElectionIndex>(from: VoteBooth.electionIndexStoragePath) ?? 
            panic(
                "Unable to retrieve a valid &VoteBooth.ElectionIndex at "
                .concat(VoteBooth.electionIndexStoragePath.toString())
                .concat(" from account at ")
                .concat(self.owner!.address.toString())
            )

            electionIndexRef.addElectionToIndex(electionId: electionId, electionStoragePath: electionStoragePath, electionPublicPath: electionPublicPath)
        }

        /**
            Function to remove the entry defined by the electionId provided, from within the VoteBoothPrinterAdmin resource.

            @param deployer (auth(Storage) &Account) Authorized reference to the account currently storing the ElectionIndex resource.
            @param electionId (UInt64) The election identifier to the Election resource to process.

            @return ({StoragePath: PublicPath})? If successful, this function returns back the entry removed from the ElectionIndex. If the entry does not exist, return a nil instead.

        **/
        access(all) fun removeElectionIndexEntry(deployer: auth(Storage) &Account, electionId: UInt64): {StoragePath: PublicPath}? {
            let electionIndexRef: auth(Storage) &VoteBooth.ElectionIndex = deployer.storage.borrow<auth(Storage) &VoteBooth.ElectionIndex>(from: VoteBooth.electionIndexStoragePath) ?? 
            panic(
                "Unable to retrieve a valid auth(Storage) &VoteBooth.ElectionIndex at "
                .concat(VoteBooth.electionIndexStoragePath.toString())
                .concat(" from account ")
                .concat(deployer.address.toString())
            )

            return electionIndexRef.removeElectionFromIndex(electionId: electionId)
        }

        /**
            Function to retrieve the storage path associated to an ElectionIndex record corresponding to the electionId provided.

            @param deployer (auth(Storage) &Account) Authorized reference to the account currently storing the ElectionIndex resource.

            @return StoragePath If there's a valid ElectionIndex in storage and it contains a record matching the electionId provided, this function returns the StoragePath associated. Otherwise a nil is returned instead.
        **/
        access(all) fun getElectionStoragePath(deployer: auth(BorrowValue) &Account, electionId: UInt64): StoragePath? {
            let electionIndexRef: &VoteBooth.ElectionIndex = deployer.storage.borrow<&VoteBooth.ElectionIndex>(from: VoteBooth.electionIndexStoragePath) ??
            panic(
                "Unable to retrieve a valid &VoteBooth.ElectionIndex at "
                .concat(VoteBooth.electionIndexStoragePath.toString())
                .concat(" from account at ")
                .concat(self.owner!.address.toString())
            )

            let electionStoragePath: StoragePath? = electionIndexRef.getElectionStoragePath(electionId: electionId)

            return electionStoragePath
        }

        /**
            This function accesses the ElectionIndex resource and returns a list of electionIds for active Elections.

            @returns [UInt64] If successful, this function returns an array of UInt64 with the electionIds for all active Elections.
        **/
        access(all) view fun getAllActiveElections(deployer: auth(BorrowValue) &Account): [UInt64] {
            let electionIndexRef: &VoteBooth.ElectionIndex = deployer.storage.borrow<&VoteBooth.ElectionIndex>(from: VoteBooth.electionIndexStoragePath) ??
            panic(
                "Unable to retrieve a valid &VoteBooth.ElectionIndex at "
                .concat(VoteBooth.electionIndexStoragePath.toString())
                .concat(" from account at ")
                .concat(self.owner!.address.toString())
            )

            return electionIndexRef.getActiveElectionIds()
        }

        /**
            Function to create new Election resources by tapping the respective contract. This function is a simple wrapper for the ElectionStandard contract function.

            @param newElectionName (String) The name for the Election resource.
            @param newElectionBallot (String) The question that this Election wants to answer.
            @param newElectionOptions ({UInt8: String}) The set of options that the voter must chose from.
            @param newPublicKey ([UInt8]) A [UInt8] representing the public encryption key that is to be used to encrypt the Ballot option from the frontend side.
            @param newElectionStoragePath (StoragePath) A StoragePath-type item to where this Election resource is going to be stored into the voter's own account.
            @param newElectionPublicPath (PublicPath) A PublicPath-type item where the public reference to this Election can be retrieved from.
            @param deployerAccount (auth(Storage) &Account) An authorized reference, with Storage entitlement, to the account where these Elections are to be stored to.

            @return UInt64 If successful, this function returns the electionId of the Election created with the provided parameters.  
        **/
        access(all) fun createElection(
            newElectionName: String,
            newElectionBallot: String,
            newElectionOptions: {UInt8: String},
            newPublicKey: [UInt8],
            newElectionStoragePath: StoragePath,
            newElectionPublicPath: PublicPath,
            deployerAccount: auth(Storage, Capabilities, ElectionStandard.ElectionAdmin) &Account
        ): UInt64 {
            // Start by creating the Election resource

            let newElection: @ElectionStandard.Election <- ElectionStandard.createElection(
                newElectionName: newElectionName,
                newElectionBallot: newElectionBallot,
                newElectionOptions: newElectionOptions,
                newPublicKey: newPublicKey,
                newElectionStoragePath: newElectionStoragePath,
                newElectionPublicPath: newElectionPublicPath
            )

            let newElectionId: UInt64 = newElection.getElectionId()

            // Add this election details to the internal electionIndex dictionary
            self.addElectionIndexEntry(
                deployer: deployerAccount,
                electionId: newElection.getElectionId(),
                electionStoragePath: newElectionStoragePath,
                electionPublicPath: newElectionPublicPath
            )

            // Cleanup the storage slot and save this Election to the StoragePath provided
            let oldResource: @ElectionStandard.Election? <- deployerAccount.storage.load<@ElectionStandard.Election>(from: newElectionStoragePath)
            // Burn the old resource, if it exists, with the Burner contract to trigger any lingering burnCallback functions
            Burner.burn(<- oldResource)

            // Save the new Election resource to the provided StoragePath
            deployerAccount.storage.save(<- newElection, to: newElectionStoragePath)

            // Unpublish and old public capabilities for the PublicPath provided and re-create these as well.
            let oldCapability: Capability? = deployerAccount.capabilities.unpublish(newElectionPublicPath)

            // Capabilities are simple values in Cadence, so I don't need to destroy this oldCapability. Create a fresh one and continue
            let newElectionCapability: Capability<&{ElectionStandard.ElectionPublic}> = deployerAccount.capabilities.storage.issue<&{ElectionStandard.ElectionPublic}>(newElectionStoragePath)

            // Publish this capability to the PublicPath provided
            deployerAccount.capabilities.publish(newElectionCapability, at: newElectionPublicPath)

            // Grab an authorized reference to the Election just stored and set the created capability in it
            let authElectionRef: auth(ElectionStandard.ElectionAdmin) &ElectionStandard.Election = deployerAccount.storage.borrow<auth(ElectionStandard.ElectionAdmin) &ElectionStandard.Election>(from: newElectionStoragePath) ??
            panic(
                "Unable to retrieve a valid &ElectionStandard.Election at "
                .concat(newElectionStoragePath.toString())
                .concat(" from account ")
                .concat(deployerAccount.address.toString())
            )

            authElectionRef.setElectionCapability(capability: newElectionCapability)

            // All done. Return the electionId from the new resource at the end of this
            return newElectionId
        }

        access(contract) fun burnCallback() {
            // All I can do from here is to emit the respective event and move on
            emit VoteBoothPrinterAdminDestroyed(_accountAddress: VoteBooth.deployerAddress)
        }

        // VoteBoothBallotPrinterAdmin constructor
        init() {
            // Nothing more to do but to emit the VoteBoothBallotPrinterAdminCreated event
            emit VoteBoothPrinterAdminCreated(_accountAddress: VoteBooth.deployerAddress)
        }
    }
    // ---------------------------------------------------------------- BALLOT PRINTER ADMIN END ---------------------------------------------------------------

    // ---------------------------------------------------------------- VOTEBOOTH BEGIN ------------------------------------------------------------------------
    // VoteBooth Contract constructor
    init(_verbose: Bool) {
        // Set the debug flag to true for now
        self.verbose = _verbose
        
        self.voteBoothPrinterAdminStoragePath = /storage/VoteBoothPrinterAdmin
        self.electionIndexStoragePath = /storage/ElectionIndex
        self.electionIndexPublicPath = /public/ElectionIndex

        self.deployerAddress = self.account.address

        // Clean up the usual storage slot and re-create the BallotPrinterAdmin
        let oldPrinter: @AnyResource? <- self.account.storage.load<@VoteBoothPrinterAdmin>(from: self.voteBoothPrinterAdminStoragePath)
        destroy oldPrinter
        
        let newPrinterAdmin: @VoteBoothPrinterAdmin <- create VoteBoothPrinterAdmin()
        self.account.storage.save(<- newPrinterAdmin, to: self.voteBoothPrinterAdminStoragePath)

        // Repeat the process for the ElectionIndex resource
        let oldIndex:@VoteBooth.ElectionIndex? <- self.account.storage.load<@ElectionIndex>(from: self.electionIndexStoragePath)

        // Check if the oldIndex resource returned is not nil and of the expected type
        if (oldIndex != nil && (oldIndex.getType() == Type<@VoteBooth.ElectionIndex?>())) {
            // If there's a valid ElectionIndex, use the clean up function to clear all the Elections in storage first
            let electionIndexRef: &VoteBooth.ElectionIndex? = &oldIndex

            // As it is the rule so far, Cadence is super picky with everything. Turns out that invoking the cleanElectionStorage function from the 
            // ElectionIndex resource is a big no no and creates all sorts of issues. The "correct" way to process this is to get a reference to the 
            // resource itself.
            electionIndexRef!.cleanElectionStorage(deployer: self.account)
        }
 
        Burner.burn(<- oldIndex)

        // Unpublish any old capabilities
        let oldCapability: Capability? = self.account.capabilities.unpublish(VoteBooth.electionIndexPublicPath)

        // Re-create the whole thing
        let newElectionIndex: @ElectionIndex <- create ElectionIndex()
        self.account.storage.save(<- newElectionIndex, to: self.electionIndexStoragePath)

        let newElectionIndexCap: Capability<&{VoteBooth.ElectionIndexPublic}> = self.account.capabilities.storage.issue<&{VoteBooth.ElectionIndexPublic}>(VoteBooth.electionIndexStoragePath)
        self.account.capabilities.publish(newElectionIndexCap, at: VoteBooth.electionIndexPublicPath)
    }
    // ---------------------------------------------------------------- VOTEBOOTH END --------------------------------------------------------------------------
}