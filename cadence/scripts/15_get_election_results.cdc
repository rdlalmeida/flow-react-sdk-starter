/**
    Simple script to return the tally results for a given election. If the Election is not yet finished, this array is empty and that's what this script is going to return.

    @param electionId (UInt64) The election identifier from which the election results are to be returned.
**/

import "ElectionStandard"
import "VoteBooth"

access(all) fun main(electionId: UInt64): {String: Int} {

    let electionPublicRef: &{ElectionStandard.ElectionPublic} = VoteBooth.getElectionPublicReference(electionId: electionId) ??
    panic(
        "Unable to get a valid &{ElectionStandard.ElectionPublic} from the VoteBooth contract for election ".concat(electionId.toString())
    )

    return electionPublicRef.getElectionTally()
}