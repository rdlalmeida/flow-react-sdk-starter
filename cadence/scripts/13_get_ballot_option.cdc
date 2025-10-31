/**
    This script returns the option parameter associated to a Ballot stored in a VoteBox under the provided electionId.

    @param electionId (UInt64) The electionId for the Election associated to the Ballot whose option is to be returned.
    @param voteboxAddress (Address) The Address of the account from where the reference to the VoteBox reference is to be retrieved from.

    @return (String?) If a Ballot exists for the electionId provided, this script returns the Ballot option associated.
**/

import "VoteBoxStandard"

access(all) fun main(electionId: UInt64, voteboxAddress: Address): String? {
    let voteboxRef: &{VoteBoxStandard.VoteBoxPublic} = getAccount(voteboxAddress).capabilities.borrow<&{VoteBoxStandard.VoteBoxPublic}>(VoteBoxStandard.voteBoxPublicPath) ?? 
    panic(
        "Unable to retrieve a valid &{VoteBoxStandard.VoteBoxPublic} at "
        .concat(VoteBoxStandard.voteBoxPublicPath.toString())
        .concat(" from account ")
        .concat(voteboxAddress.toString())
    )

    let someArray: [Int] = [1, 2, 3, 5]
    let anotherArray: [Int] = someArray.slice(from: 0, upTo: 2)

    return voteboxRef.getVote(electionId: electionId)
}