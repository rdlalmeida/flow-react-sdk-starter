/**
    Transaction to create a new Election resource and save it into a storage path provided as argument, as well as publishing a capability to the public path provided as well.

    @param _electionName (String) The name of the Election resource.
    @param _electionBallot (String) The question that this Election wants to answer.
    @param _electionOptions ({UInt8: String}) The set of Ballot voting options that the voter must chose from. For easier processing, these should be arranged in a UInt8: <OptionText> format for frontend consumption.
    @param _publicKey ([UInt8]) A UInt8 array representing the integer encoding of a hex-based public key String. This key is to be used by the frontend to encrypt any options for Ballots submitted to this Election.
    @param _electionStoragePath (StoragePath) A storage path-type element indicating where, in the contract deployer's account, the Election resource should be storage into.
    @param _electionPublicPath (PublicPath) A public path-type element indicating where, in the contract deployer's account, the public interface of the Election resource should be published into.
**/

import "VoteBooth"
import "ElectionStandard"

transaction(
    _electionName: String, 
    _electionBallot: String, 
    _electionOptions: {UInt8: String},
    _publicKey: [UInt8],
    _electionStoragePath: StoragePath,
    _electionPublicPath: PublicPath
    ) {
    let voteBoothPrinterAdminRef: &VoteBooth.VoteBoothPrinterAdmin
    let newElectionId: UInt64

    prepare(signer: auth(Storage, Capabilities, ElectionStandard.ElectionAdmin) &Account) {
        // Get the authorized reference for the VoteBoothPrinterAdmin resource with all the entitlements specified in the transaction signature
        self.voteBoothPrinterAdminRef 
            = signer.storage.borrow<auth(Storage, Capabilities, ElectionStandard.ElectionAdmin) &VoteBooth.VoteBoothPrinterAdmin>(from: VoteBooth.voteBoothPrinterAdminStoragePath) ??
            panic(
                "Unable to retrieve a valid auth(Storage, Capabilities, ElectionStandard.ElectionAdmin) &VoteBooth.VoteBoothPrinterAdmin at "
                .concat(VoteBooth.voteBoothPrinterAdminStoragePath.toString())
                .concat(" from account at ")
                .concat(signer.address.toString())
            )
        
        // Create the Election in this prepare phase because I need access to the signer variable.
        self.newElectionId = self.voteBoothPrinterAdminRef.createElection(
            newElectionName: _electionName,
            newElectionBallot: _electionBallot,
            newElectionOptions: _electionOptions,
            newPublicKey: _publicKey,
            newElectionStoragePath: _electionStoragePath,
            newElectionPublicPath: _electionPublicPath,
            deployerAccount: signer
        )

        if (VoteBooth.verbose) {
            log("Created a new Election with electionId ".concat(self.newElectionId.toString()).concat(" => ").concat(_electionName))
        }
    }

    execute {}
}