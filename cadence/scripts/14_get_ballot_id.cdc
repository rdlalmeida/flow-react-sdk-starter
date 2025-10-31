/**
    This apparently simple script is actually needed due to the convoluted way in which I'm saving Ballots in this system. This script returns the ballotId for a Ballot stored under the VoteBox stored under the address provided as input, under the electionId key also provided as input.

    @param voteboxAddress (Address) The address of the account where the VoteBox reference should be retrieved from.
    @param electionId (UInt64) The election identifier where the Ballot should be stored under.

    @returns UInt64? If a Ballot exists for the VoteBox and electionId provided, this script returns its ballotId. Otherwise it returns nil.
**/
import "VoteBoxStandard"

access(all) fun main(voteboxAddress: Address, electionId: UInt64): UInt64? {
    let voteboxRef: &{VoteBoxStandard.VoteBoxPublic} = getAccount(voteboxAddress).capabilities.borrow<&{VoteBoxStandard.VoteBoxPublic}>(VoteBoxStandard.voteBoxPublicPath) ??
    panic(
        "Unable to get a valid &{VoteBoxStandard.VoteBoxPublic} at "
        .concat(VoteBoxStandard.voteBoxPublicPath.toString())
        .concat(" from account ")
        .concat(voteboxAddress.toString())
    )

    return voteboxRef.getBallotId(electionId: electionId)
}