/**
    This script accesses the process's ElectionIndex resource to get a list of active elections in a {UInt64:String} dictionary format, with the electionIds as keys, and the Elections names as values.

    @returns {UInt64:String} The script returns a dictionary in the {<electionId: UInt64>: <electionName>: String} format
**/

import "VoteBooth"
import "ElectionStandard"

access(all) fun main(): {UInt64: String} {
    let deployerAccount: &Account = getAccount(VoteBooth.deployerAddress)

    let electionIndexRef: &{VoteBooth.ElectionIndexPublic} = deployerAccount.capabilities.borrow<&{VoteBooth.ElectionIndexPublic}>(VoteBooth.electionIndexPublicPath) ??
    panic(
        "ERROR: transactions/12_get_elections_list.cdc -> &{VoteBooth.ElectionIndexPublic}@"
        .concat(VoteBooth.deployerAddress.toString())
    )

    let electionInfo: {UInt64: String} = electionIndexRef.listActiveElections()
    if (VoteBooth.verbose) {
        log(
            "Election Info list returned from listActiveElections: "
        )
        log(
            electionInfo
        )
    }

    return electionInfo
}