/**
    Since I can invoke this function either directly from an &ElectionStandard.ElectionPublic reference or from a &VoteBoxStandard.VoteBoxPublic one as well, I want this one script to be able to do both. Retrieving this data from the ElectionStandard.ElectionPublic only requires a valid electionId, but the one from the &VoteBoxStandard.VoteBoxPublic needs the address to the user account provided as well. As such, each of the following scripts accept two inputs, the second one is set as an optional (the voter address). If both inputs are provided, this script runs the &VoteBoxStandard.VoteBoxPublic version. If the voter address is a nil instead, then the &ElectionStandard.ElectionPublic one is invoked instead.
    NOTE: When the &VoteBoxStandard.VoteBoxPublic version only works if the VoteBox has a Ballot in store for the electionId provided. If not, the function returns nil

    @param electionId (UInt64) The election identifier for the Election resource whose parameter is to be returned to.
    @param voteboxAddress (Address?) The account address to use to retrieve the public version of the VoteBox resource. This input can be set to a nil to retrieve the parameter in question directly from the Election resource reference.

    @returns (Capability<&{ElectionStandard.ElectionPublic}>) Returns the capability associated to the Election, if it exists. Otherwise, the process panics at the offending step.
**/
import "VoteBooth"
import "ElectionStandard"
import "VoteBoxStandard"

access(all) fun main(electionId: UInt64, voteboxAddress: Address?): Capability<&{ElectionStandard.ElectionPublic}>? {
    if (voteboxAddress == nil) {
        let deployerAccount: &Account = getAccount(VoteBooth.deployerAddress)

        let electionIndexRef: &{VoteBooth.ElectionIndexPublic} = deployerAccount.capabilities.borrow<&{VoteBooth.ElectionIndexPublic}>(VoteBooth.electionIndexPublicPath) ??
        panic(
            "Unable to get a valid &{VoteBooth.ElectionIndexPublic} at "
            .concat(VoteBooth.electionIndexPublicPath.toString())
            .concat(" from account ")
            .concat(deployerAccount.address.toString())
        )

        let electionRef: &{ElectionStandard.ElectionPublic} = electionIndexRef.getPublicElectionReference(_electionId: electionId)!

        return electionRef.getElectionCapability() as! Capability<&{ElectionStandard.ElectionPublic}>
    }
    else {
        let voteboxAccount: &Account = getAccount(voteboxAddress!)
        let voteboxRef: &{VoteBoxStandard.VoteBoxPublic} = voteboxAccount.capabilities.borrow<&{VoteBoxStandard.VoteBoxPublic}>(VoteBoxStandard.voteBoxPublicPath) ??
        panic(
            "Unable to retrieve a valid &{VoteBoxStandard.VoteBoxPublic} at "
            .concat(VoteBoxStandard.voteBoxPublicPath.toString())
            .concat(" from account ")
            .concat(voteboxAddress!.toString())
        )

        return voteboxRef.getElectionCapability(electionId: electionId) as! Capability<&{ElectionStandard.ElectionPublic}>
    }
}