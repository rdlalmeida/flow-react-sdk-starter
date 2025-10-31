/**
    ## The Ballot Token standard

    Interface to regulate the access to the base resource for this project, namely, the Ballot.

    @author: Ricardo Lopes Almeida - https://github.com/rdlalmeida
**/

import "Burner"
import "Crypto"

access(all) contract BallotStandard {
// CUSTOM ENTITLEMENTS
    access(all) entitlement BallotAdmin

    // CUSTOM EVENTS
    access(all) event BallotCreated(_ballotId: UInt64, _linkedElectionId: UInt64)
    access(all) event BallotBurned(_ballotId: UInt64, _linkedElectionId:UInt64)

    // I'm setting up a deployerAddress parameter in each of this project's contracts to allow voters to check that all contracts are deployed under the same,
    // ElectionAdministrator account, to ensure they are not getting Ballots and Elections from someone else.
    access(all) let deployerAddress: Address

    // The public interface applied to the BallotStandard.Ballot resource. These parameter and functions is what a voter has access when he/she grabs a public
    // reference to an Election resource through the Ballot-based election capability. 
    access(all) resource interface BallotPublic {
        access(all) let ballotId: UInt64
        access(all) let linkedElectionId: UInt64
        access(all) view fun getElectionCapability(): Capability
        access(all) view fun getOption(): String
        access(all) view fun getVoterAddress(): Address?
    }

    // The Ballot resource standard definition.
    access(all) resource Ballot: Burner.Burnable, BallotPublic {
        access(all) let ballotId: UInt64
        access(all) let linkedElectionId: UInt64
        /**
            This capability is going to be used to access the "submitBallot" function from the Election resource that points to it. The idea is to keep Election resources somewhat hidden in the VoteBooth deployer account and delegate access to it on a per-voter basis, using the Ballot resources to that effect.
        */
        access(BallotAdmin) let electionCapability: Capability
        /**
            This is the field where the choice in the ballot gets reflected. The idea is to have an encrypted value here, hence why I set it as a String.
            What gets encrypted is still open to debate, My idea was to simplify this and just put a number in this field to make counting easier, but once I add an encryption layer, this strategy limits my cipher space quite a lot. But if I concatenate it with a very large random integer tough... Anyway, this needs some thinking, but the idea is to have the frontend setting this field so that the encryption process happens off-chain.
        **/
        access(self) var option: String

        /**
            I need a pair of parameter to prevent an adversary from taking advantage of this system. I need a "voterAddress" as well as a "ballotIndex" parameter that is derived from the initial one. The idea is to use this to ensure that this Ballot is either inside of an account that matches the "voterAddress" parameter, be it by itself or while in a VoteBox, or inside an Election resource. To restrict the Ballot to these two states only, I need to be creative with this aspect.
            For now, I'm setting the ballotIndex as H(voterAddress) = ballotIndex, i.e., the ballotIndex is the hash digest for the address of the voter.
            Also, to preserve the privacy of the voter, the voter address can be set to nil during the submission of the Ballot
        **/
        access(BallotStandard.BallotAdmin) var voterAddress: Address?
        access(all) let ballotIndex: String


        /**
            Simple getter function to retrieve the option parameter from this Ballot. This parameter can only exist either in its default state or set to an encrypted string encoding the voter's decision. Even so, there's some privacy measures that need to be in place, hence why I protected this function with a BallotStandard.BallotAdmin, i.e., only the owner of this Ballot can invoke this function through an authorized reference to this Ballot resource.

            @returns (String) The option currently set in this Ballot resource.
        **/
        access(all) view fun getOption(): String {
            return self.option
        }

        /**
            Function to set the "option" field in this BallotStandard.Ballot resource. The function is protected with access(BallotStandard.BallotAdmin) to ensure that only the owner of this resource can call this function through an authorized reference to this Ballot resource.

            @param newOption (String) The new option to set in this Ballot. The assumption is that this String comes already encrypted from the frontend or whatever process is happening off-chain.
        **/
        access(BallotStandard.BallotAdmin) fun vote(newOption: String): Void {
            // There's not a lot more that I need to do. The blinding and encrypting logic needs to necessarily occur outside of this contract.
            self.option = newOption
        }

        /**
            Simple access(all) getter for the electionCapability parameter. I need this to be accessible for anyone.

            @returns (Capability) This function returns the Capability value set in this Ballot resource. This capability can be force cast into a Capability<&{ElectionStandard.ElectionPublic}> if needed
        **/
        access(all) view fun getElectionCapability(): Capability {
            return self.electionCapability
        }

        /**
            Simple getter for the voterAddress parameter set in the Ballot

            @returns (Address?) Returns whatever is set currently in the voterAddress parameter, which can be an address or a nil
        **/
        access(all) view fun getVoterAddress(): Address? {
            return self.voterAddress
        }

        /**
            This function abstracts the operation to set this Ballot to be anonymous by setting the current voterAddress parameter to a nil.
        **/
        access(BallotStandard.BallotAdmin) fun anonymizeBallot(): Void {
            self.voterAddress = nil
        }

        /**
            Standard "burnCallback" function as defined by the Burner contract. This function is automatically invoked when a Ballot resource is burned using the "Burner.burn()" function.
        **/
        access(contract) fun burnCallback(): Void {
            // From the Ballot's point of view, all I need to do is to emit the proper Event
            emit BallotBurned(_ballotId: self.ballotId, _linkedElectionId: self.linkedElectionId)
        }
        
        /**
            BallotStandard.Ballot resource constructor. This is the standard resource constructor to build new Ballot resources.

            @param _linkedElectionId (UInt64) The election identifier to the Election resource this Ballot is associated to, i.e., where it can be submitted to.
            @param _electionCapability (Capability) A capability value to the public interface of the Election resource associated to this Ballot. At this level, to avoid the circular referencing that happens if I import the ElectionStandard into this one, I'm setting this parameter as just a broader Capability value, but the idea is to set this with a specific Capability<&{ElectionStandard.ElectionPublic}> to retrieve an ElectionPublic reference from this Ballot directly.
            @param voterAddress (Address) The account address of the voter that is going to receive this Ballot in its VoteBox resource. This Ballot sets this value internally through the resource constructor to ensure that only the voter identified by this address can mutate and submit it.

            @returns (@BallotStandard.Ballot) If successful, this function returns a fresh @BallotStandard.Ballot back to the caller.
        **/
        init(
            _linkedElectionId: UInt64,
            _electionCapability: Capability,
            _voterAddress: Address
        ) {
            self.ballotId = self.uuid
            self.linkedElectionId = _linkedElectionId
            self.electionCapability = _electionCapability

            // The voterAddress is achieved directly
            self.voterAddress = _voterAddress

            /**
                The original idea was to simply hash the voterAddress and use this as key to store this Ballot in an Election. But... by some weird reason, the String -> [UInt8] -> String circuit in Cadence is a bit weird and needs fixing to be usable.
                The main problem is that, in Cadence, a UInt8 is a number between 0 and 255 (The 'U' means unsigned, which implies that all 8 of the bits are used for the representation, i.e., the range is 0 - (2⁸ - 1) = 0 - 255). But the String.fromUTF8, by some stupid reason, does not recognizes any encoding 7 bits and above, i.e., any array element 2⁷ - 1 = 127 and higher. Also, not all characters in that 0-127 range are printable or usable on a String. But the hashing algorithm produces a [UInt8] result in which each element can go from 0 to 255. This means that reverting the hashed output back to a String creates all sorts of problems as soon as a value >= 128 is found.
                Fortunately, I don't really care about how the digest looks like, as long as it is produced deterministically from an input. As such, I'm going to use this function to address this limitation: any values found in the original digest that are 128 or above get subtracted and added to bring them back to the decodable range, which is going to be the set of printable UTF8 characters in the 65-90; 97-126 range, and thus producing a fairly deterministic encoding algorithm.

                NOTE: This is a one way process, therefore I only need to ensure determinism in one direction. I'm hashing a piece of information to start this, so it is impossible for me to reverse this operation at a future point.

            **/            
            // Grab the voterAddress into a encodable format
            let voterAddressToEncode: [UInt8] = self.voterAddress!.toString().utf8


            // Use the [UInt8] input to get the hash digest of the address String
            let hashedVoterAddress: [UInt8] = Crypto.hash(voterAddressToEncode, algorithm: HashAlgorithm.SHA3_256)
            var normalisedHashedVoterAddress: [UInt8] = []
            var elementToNormalise: UInt8 = 0

            // Go though each element of the hash output and subtract 122 out of every element >= 122
            for index, hashElement in hashedVoterAddress {
                // Set the element to normalise
                elementToNormalise = hashElement

                // Repeat this while the element is outside of the allowed ranges
                while ((elementToNormalise < 65 || elementToNormalise > 90) && (elementToNormalise < 97 || elementToNormalise > 122)) {
                    if (elementToNormalise < 65) {
                        // Bring the hash element to within the uppercase letter range of [65-90]. The range is 26 positions long, so the easiest approach is
                        // to add 26 until the element gets in that range. I'm doing this inside a while loop, therefore it is OK if the first increment
                        // does not bring the elementToNormalise to within the desired range. The next loop or the one after that will do it.
                        elementToNormalise = elementToNormalise + 26

                    }
                    // In this case I just want the element out of this 6 slot range. As such, I'm adding or subtracting 6 to the element depending on where in
                    // the range it sits.
                    else if (elementToNormalise > 90 && elementToNormalise < 97) {
                        if (elementToNormalise <= 93) {
                            // Push it towards the uppercase letter range
                            elementToNormalise = elementToNormalise - 6
                        }
                        else{
                            // And this one into the lowercase letter range
                            elementToNormalise = elementToNormalise + 6
                        }
                    }
                    else{
                        // And anything above the upper limit, simply subtract half of the upper range limit each time until it falls into one of the valid ranges
                        elementToNormalise = elementToNormalise - 122
                    }
                }

                // Once an element gets out of this while loop, it is within the desired range. Add it to the final array to encode back to a String
                normalisedHashedVoterAddress.append(elementToNormalise)
            }

            // All done. It should be possible to covert this array back to a String
            let hashDigest: String? = String.fromUTF8(normalisedHashedVoterAddress)

            if (hashDigest == nil) {
                panic(
                    "ERROR: Unable to decode hashed address "
                    .concat(self.voterAddress!.toString())
                    .concat(" back to a String...")
                )
            }
            else {
                self.ballotIndex = hashDigest!
            }

            self.option = "default"

            // All done. Finish by emitting the BallotCreated event
            emit BallotStandard.BallotCreated(_ballotId: self.ballotId, _linkedElectionId: _linkedElectionId)
        }
    }

    /**
        Entry point function to create new Ballot resources. New Ballots can only be created from their issuing contract, therefore I need a function at this level to be able to create new Ballots.

        @param newLinkedElectionId (UInt64) The electionId connecting to the Election where this Ballot can be deposited to.
        @param newElectionCapability (Capability<&{ElectionStandard.ElectionPublic}>) A capability value to retrieve the public reference to the Election where this Ballot can be submitted to.
        @param newVoterAddress (Address) The account address for the voter that is to receive this Ballot, for consistency checks.

        @return @BallotStandard.Ballot If successful, this function returns a newly minted Ballot resource.
    **/
    access(all) fun createBallot(newLinkedElectionId: UInt64, newElectionCapability: Capability, newVoterAddress: Address): @BallotStandard.Ballot {
        return <- create Ballot(_linkedElectionId: newLinkedElectionId, _electionCapability: newElectionCapability, _voterAddress: newVoterAddress)
    }

    /**
        BallotStandard contract constructor. I'm not setting anything relevant at the contract level, hence the empty constructor.
    **/
    init() {
        // Set the address of the contract deployer as an internal parameter for future comparison.
        self.deployerAddress = self.account.address
    }
}