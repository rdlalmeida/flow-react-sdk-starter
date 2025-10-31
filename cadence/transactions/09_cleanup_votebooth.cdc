/**
    This transaction deletes every resource from this voting process that it is currently stored in the transaction signer's storage account. This includes all Elections, active and otherwise, BallotPrinterAdmin, ElectionIndex, etc...
**/
import "VoteBooth"
import "ElectionStandard"
import "Burner"

transaction() {
    let electionIndex: @VoteBooth.ElectionIndex
    let voteBoothPrinterAdmin: @VoteBooth.VoteBoothPrinterAdmin

    prepare(signer: auth(LoadValue, UnpublishCapability) &Account) {
        // Load the ElectionIndex and VoteBoothPrinterAdmin resource to the transaction variables from the elevated access account
        self.electionIndex <- signer.storage.load<@VoteBooth.ElectionIndex>(from: VoteBooth.electionIndexStoragePath) ??
        panic(
            "Unable to retrieve a valid @VoteBooth.ElectionIndex at "
            .concat(VoteBooth.electionIndexStoragePath.toString())
            .concat(" from account ")
            .concat(signer.address.toString())
        )

        // Unpublish the ElectionIndexPublic capability as well
        let oldCapability: Capability? = signer.capabilities.unpublish(VoteBooth.electionIndexPublicPath)

        self.voteBoothPrinterAdmin <- signer.storage.load<@VoteBooth.VoteBoothPrinterAdmin>(from: VoteBooth.voteBoothPrinterAdminStoragePath) ??
        panic(
            "Unable to retrieve a valid @VoteBooth.VoteBoothPrinterAdmin at "
            .concat(VoteBooth.voteBoothPrinterAdminStoragePath.toString())
            .concat(" from account ")
            .concat(signer.address.toString())
        )

        // Loop through all the elections in the ElectionIndex, load them, if they exist, and destroy them one by one
        let existingElections: [UInt64] = self.electionIndex.getActiveElectionIds()

        for electionId in existingElections {
            // Grab the StoragePath
            let electionStoragePath: StoragePath = self.electionIndex.getElectionStoragePath(electionId: electionId) ??
            panic(
                "Unable to get a StoragePath for Election "
                .concat(electionId.toString())
                .concat(" for the ElectionIndex from account ")
                .concat(signer.address.toString())
            )

            // And the PublicPath for each Election
            let electionPublicPath: PublicPath = self.electionIndex.getElectionPublicPath(electionId: electionId) ??
            panic(
                "Unable to get a PublicPath for Election "
                .concat(electionId.toString())
                .concat(" for the ElectionIndex from account ")
                .concat(signer.address.toString())
            )

            // Use the PublicPath to unpublish the ElectionPublic capability
            let oldElectionCapability: Capability? = signer.capabilities.unpublish(electionPublicPath)

            // And use the StoragePath to load the Election resource
            let electionToDestroy: @ElectionStandard.Election <- signer.storage.load<@ElectionStandard.Election>(from: electionStoragePath) ??
            panic(
                "Unable to get a valid @ElectionStandard.Election at "
                .concat(electionStoragePath.toString())
                .concat(" from account ")
                .concat(signer.address.toString())
            )

            // Done. There's not a lot more to do. The burnCallback from the Election resource already takes care of the rest
            Burner.burn(<- electionToDestroy)
        }
        
    }

    execute {
        // All done. Get rid of the ElectionIndex as well
        Burner.burn(<- self.electionIndex)

        // Same for the VoteBoothPrinterAdmin resource
        Burner.burn(<- self.voteBoothPrinterAdmin)
    }
}