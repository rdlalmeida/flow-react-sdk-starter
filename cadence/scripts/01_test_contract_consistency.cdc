/**
    Script to test the contract consistency of all contracts in this project, namely:
    1. BallotStandard.cdc
    2. ElectionStandard.cdc
    3. VoteBoxStandard.cdc
    4. VoteBooth

    The logic is to check that each contract in that list apart from #1 was deployed into the same account.
**/
import "BallotStandard"
import "ElectionStandard"
import "VoteBoxStandard"
import "VoteBooth"

access(all) fun main(): Bool {
    let ballotDeployer: Address = BallotStandard.deployerAddress
    let electionDeployer: Address = ElectionStandard.deployerAddress
    let voteBoxDeployer: Address = VoteBoxStandard.deployerAddress
    let voteboothDeployer: Address = VoteBooth.deployerAddress

    if (electionDeployer == ballotDeployer) {
        if (VoteBooth.verbose) {
            log(
                "Election standard is consistent."
            )
        }
    }
    else {
        if (VoteBooth.verbose) {
            log(
                "WARNING: BallotStandard("
                .concat(ballotDeployer.toString())
                .concat(") and ElectionStandard(")
                .concat(electionDeployer.toString())
                .concat(") are deployed into different accounts!")
            )
        }

        return false
    }

    if (voteBoxDeployer == electionDeployer) {
        if (VoteBooth.verbose) {
            log(
                "VoteBox standard is consistent."
            )
        }
    }
    else {
        if (VoteBooth.verbose) {
            log(
                "WARNING: VoteBoxStandard("
                .concat(voteBoxDeployer.toString())
                .concat(") and ElectionStandard(")
                .concat(electionDeployer.toString())
                .concat(") are deployed into different accounts!")
            )
        }

        return false
    }

    if (voteboothDeployer == voteBoxDeployer) {
        if (VoteBooth.verbose) {
            log(
                "VoteBooth and the remaining standards are consistently deployed at ".concat(voteboothDeployer.toString())
            )
        }
    }
    else {
        if (VoteBooth.verbose) {
            log(
                "WARNING: VoteBooth("
                .concat(voteboothDeployer.toString())
                .concat(") and VoteBoxStandard(")
                .concat(voteBoxDeployer.toString())
                .concat(") are deployed into different accounts!")
            )
        }

        return false
    }

    return true
}