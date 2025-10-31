/*
    Use this transaction to fund the following emulator test accounts:

    account01: 0x179b6b1cb6755e31
    account02: 0xf3fcd2c1a78f5eee
    account03: 0xe03daebed8ca0615
*/

import "FlowToken"
import "FungibleToken"

transaction() {
    let vaultReference: auth(FungibleToken.Withdraw) &FlowToken.Vault
    let receiverRef: [&{FungibleToken.Receiver}]
    let from: Address
    let to: [Address]
    let amount: UFix64

    prepare(signer: auth(BorrowValue) &Account) {
        self.from = signer.address

        self.vaultReference = signer.storage.borrow<auth(FungibleToken.Withdraw) &FlowToken.Vault>(from: /storage/flowTokenVault) ??
        panic(
            "Unable to get a reference to the vault for account ".concat(signer.address.toString())
        )

        self.amount = 10.0
        self.receiverRef = []
        self.to = [0x179b6b1cb6755e31, 0xf3fcd2c1a78f5eee, 0xe03daebed8ca0615]

        for receiverAddress in self.to {
            let recipientAccount: &Account = getAccount(receiverAddress)

            self.receiverRef.append(recipientAccount.capabilities.borrow<&{FungibleToken.Receiver}>(/public/flowTokenReceiver) ?? panic(
                "Unable to retrieve a &{FungibleToken.Receiver} from ".concat(receiverAddress.toString())
            ))
        }
    }

    execute {
        for index, receiver in self.receiverRef {
            let tempVault: @{FungibleToken.Vault} <- self.vaultReference.withdraw(amount: self.amount)

            receiver.deposit(from: <- tempVault)

            log(
                "Transferred "
                .concat(self.amount.toString())
                .concat(" FLOW from account ")
                .concat(self.from.toString())
                .concat(" to ")
                .concat(self.to[index].toString())
            )
        }
    }
}