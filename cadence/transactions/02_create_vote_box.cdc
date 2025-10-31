/**
    Transaction to create a new VoteBox resource and save it into the standard storage path defined at the contract level.

    @param recipientAddress (Address) The address of the voter account where this VoteBox should be stored into.
**/

import "VoteBoxStandard"
import "Burner"
import "VoteBooth"

transaction() {
    prepare(signer: auth(SaveValue, LoadValue, Capabilities) &Account) {
        let newVoteBox: @VoteBoxStandard.VoteBox <- VoteBoxStandard.createVoteBox(newVoteBoxOwner: signer.address)

        // Clean up the voter's storage slot and save the new resource into it
        let oldVoteBox: @VoteBoxStandard.VoteBox? <- signer.storage.load<@VoteBoxStandard.VoteBox>(from: VoteBoxStandard.voteBoxStoragePath)
        
        // Burn the old VoteBox using the Burner contract to trigger the burnCallback function, if this is truly a VoteBox-type resource
        Burner.burn(<- oldVoteBox)

        signer.storage.save(<- newVoteBox, to: VoteBoxStandard.voteBoxStoragePath)
        if (VoteBooth.verbose) {
            log(
                "Created a new @VoteVoxStandard.VoteBox at "
                .concat(VoteBoxStandard.voteBoxStoragePath.toString())
                .concat(" for account ")
                .concat(signer.address.toString())
            )
        }

        // Repeat the process for the capabilities
        let oldCapability: Capability? = signer.capabilities.unpublish(VoteBoxStandard.voteBoxPublicPath)
        
        let newCapability: Capability<&{VoteBoxStandard.VoteBoxPublic}> = signer.capabilities.storage.issue<&{VoteBoxStandard.VoteBoxPublic}>(VoteBoxStandard.voteBoxStoragePath)

        signer.capabilities.publish(newCapability, at: VoteBoxStandard.voteBoxPublicPath)

        if (VoteBooth.verbose) {
            log(
                "Published a new Capability<&{VoteBoxStandard.VoteBoxPublic}> at "
                .concat(VoteBoxStandard.voteBoxPublicPath.toString())
                .concat(" for account ")
                .concat(signer.address.toString())
            )
        }
    }

    execute {

    }
}