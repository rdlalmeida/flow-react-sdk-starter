/**
    Transaction to create a new Ballot into a VoteBox resource into a voter account passed as input argument.

    @param _linkedElectionId (UInt64) The electionId that the Ballot to create is associated to.
    @param _voterAddress (Address) The account address of the voter account where this Ballot is to be stored into.
**/

import "VoteBooth"
import "ElectionStandard"
import "VoteBoxStandard"

transaction(_linkedElectionId: UInt64, _voterAddress: Address) {
    let voteBoothPrinterAdminRef: &VoteBooth.VoteBoothPrinterAdmin

    prepare(signer: auth(BorrowValue, VoteBoxStandard.VoteBoxAdmin, ElectionStandard.ElectionAdmin) &Account) {
        // Grab an authorized reference to the VoteBoothPrinterAdmin resource using the signer account
        self.voteBoothPrinterAdminRef = signer.storage.borrow<&VoteBooth.VoteBoothPrinterAdmin>(from: VoteBooth.voteBoothPrinterAdminStoragePath) ??
        panic(
            "Unable to retrieve a valid &VoteBooth.VoteBoothPrinterAdmin at "
            .concat(VoteBooth.voteBoothPrinterAdminStoragePath.toString())
            .concat(" for account ")
            .concat(signer.address.toString())
        )

        let newBallotId: UInt64 = self.voteBoothPrinterAdminRef.createBallot(newLinkedElectionId: _linkedElectionId, voterAddress: _voterAddress, deployer: signer) ??
        panic(
                    "Unable to create a Ballot for Election "
                    .concat(_linkedElectionId.toString())
                    .concat(" and deposit it to voter account at ")
                    .concat(_voterAddress.toString())
                    .concat(" using the VoteBoothPrinterAdmin at ")
                    .concat(VoteBooth.voteBoothPrinterAdminStoragePath.toString())
                    .concat(" from account ")
                    .concat(signer.address.toString())
                )

        if (VoteBooth.verbose) {
            log(
                "Successfully created Ballot with id "
                .concat(newBallotId.toString())
                .concat(" and deposited to the VoteBox in account ")
                .concat(_voterAddress.toString())
                )
        }
    }

    execute {
    }
}