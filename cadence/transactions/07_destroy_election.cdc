/**
    This transaction uses an authorized reference to load and destroy an Election with the id provided as input argument.

    @param electionId (Uint64) The election identifier for the election to be destroyed
**/
import "VoteBooth"
import "ElectionStandard"
import "Burner"

transaction(electionId: UInt64) {
    let electionIndexRef: &{VoteBooth.ElectionIndexPublic}
    let electionStoragePath: StoragePath
    let electionPublicPath: PublicPath
    let electionToDestroy: @ElectionStandard.Election

    prepare(signer: auth(LoadValue, UnpublishCapability) &Account) {
        self.electionIndexRef = signer.capabilities.borrow<&{VoteBooth.ElectionIndexPublic}>(VoteBooth.electionIndexPublicPath) ??
        panic(
            "Unable to retrieve a valid &{VoteBooth.ElectionIndexPublic} at "
            .concat(VoteBooth.electionIndexPublicPath.toString())
            .concat(" from account ")
            .concat(signer.address.toString())
        )

        self.electionStoragePath = self.electionIndexRef.getElectionStoragePath(electionId: electionId) ??
        panic(
            "Unable to retrieve a valid StoragePath for election "
            .concat(electionId.toString())
            .concat(" for the ElectionIndexPublic retrieved from account ")
            .concat(signer.address.toString())
        )

        self.electionPublicPath = self.electionIndexRef.getElectionPublicPath(electionId: electionId) ??
        panic(
            "Unable to retrieve a valid PublicPath for election "
            .concat(electionId.toString())
            .concat(" for the ElectionIndexPublic retrieved from account ")
            .concat(signer.address.toString())
        )

        self.electionToDestroy <- signer.storage.load<@ElectionStandard.Election>(from: self.electionStoragePath) ??
        panic(
            "Unable to retrieve a valid @ElectionStandard.Election at "
            .concat(self.electionStoragePath.toString())
            .concat(" from account ")
            .concat(signer.address.toString())
        )

        // Unpublish all election capabilities
        let oldCapability: Capability? = signer.capabilities.unpublish(self.electionPublicPath)
    }


    execute {
        // Finish with destroying the Election loaded with the Burner contract to trigger the Election's burnCallback
        Burner.burn(<- self.electionToDestroy)
    }
}