/**
    This transaction casts a Ballot present in a given VoteBox by setting its option to the provided input argument.

    @param _electionId (UInt64) The id of the Election to vote. Ballots are internally stored inside VoteBoxes using the associated electionId as key.
    @param _newOption (String) The encrypted option to set the Ballot to
**/

import "BallotStandard"
import "VoteBoxStandard"

transaction(_electionId: UInt64, _newOption: String) {
    let voteBoxRef: auth(BallotStandard.BallotAdmin) &VoteBoxStandard.VoteBox

    prepare(signer: auth(BorrowValue, BallotStandard.BallotAdmin) &Account) {
        self.voteBoxRef = signer.storage.borrow<auth(BallotStandard.BallotAdmin) &VoteBoxStandard.VoteBox>(from: VoteBoxStandard.voteBoxStoragePath) ??
        panic(
            "Unable to retrieve a valid auth(BallotStandard.BallotAdmin) &VoteBoxStandard at "
            .concat(VoteBoxStandard.voteBoxStoragePath.toString())
            .concat(" from account ")
            .concat(signer.address.toString())
        )
    }

    execute {
        // Set the current Ballot option to the provided option
        self.voteBoxRef.setOption(electionId: _electionId, newOption: _newOption)
    }
}