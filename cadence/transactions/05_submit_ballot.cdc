/**
    This transactions submits a Ballot in storage for the electionId provided to the Election resource in question. This action relinquishes the ownership of the Ballot resource to the owner of the Election.

    @param _electionId (UInt64) The id of the Election to vote. Ballots are internally stored inside VoteBoxes using the associated electionId as key.
**/
import "BallotStandard"
import "VoteBoxStandard"

transaction(_electionId: UInt64) {
    let voteBoxRef: auth(BallotStandard.BallotAdmin) &VoteBoxStandard.VoteBox

    prepare(signer: auth(BallotStandard.BallotAdmin, BorrowValue) &Account) {
        self.voteBoxRef = signer.storage.borrow<auth(BallotStandard.BallotAdmin) &VoteBoxStandard.VoteBox>(from: VoteBoxStandard.voteBoxStoragePath) ??
        panic(
            "Unable to retrieve a valid auth(BallotStandard.BallotAdmin) &VoteBoxStandard at "
            .concat(VoteBoxStandard.voteBoxPublicPath.toString())
            .concat(" from account ")
            .concat(signer.address.toString())
        )
    }

    execute {
        let returnedElectionId: UInt64 = self.voteBoxRef.castBallot(electionId: _electionId)

        if (returnedElectionId != _electionId) {
            panic(
                "ERROR: The Ballot was cast for Election "
                .concat(_electionId.toString())
                .concat(" but the transaction returned Election ")
                .concat(returnedElectionId.toString())
            )
        }
    }
}