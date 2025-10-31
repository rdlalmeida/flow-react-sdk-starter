/**
    Simple script to return the flag regarding the state of the Election identified by the input provided.

    @param electionId (UInt64) The election identifier for the Election resource whose status is to be retrieved.

    @returns (Bool) The running status of the Election.
**/
import "ElectionStandard"
import "VoteBooth"

access(all) fun main(electionId: UInt64): Bool {
    let electionPublicRef: &{ElectionStandard.ElectionPublic} = VoteBooth.getElectionPublicReference(electionId: electionId) ??
    panic(
        "Unable to get a valid &{ElectionStandard.ElectionPublic} from the VoteBooth contract for election ".concat(electionId.toString())
    )

    return electionPublicRef.isElectionFinished()
}