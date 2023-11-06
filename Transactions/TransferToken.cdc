import FungibleToken from 0x05
import KlausToken from 0x05

transaction(receiverAccount: Address, amount: UFix64) {

    // Define references
    let signerVault: &KlausToken.Vault
    let receiverVault: &KlausToken.Vault{FungibleToken.Receiver}

    prepare(acct: AuthAccount) {
        // Borrow references and handle errors
        self.signerVault = acct.borrow<&KlausToken.Vault>(from: /storage/VaultStorage)
            ?? panic("Sender's vault not found")

        self.receiverVault = getAccount(receiverAccount)
            .getCapability(/public/Vault)
            .borrow<&KlausToken.Vault{FungibleToken.Receiver}>()
            ?? panic("Receiver's vault not found")
    }

    execute {
        // Withdraw tokens from signer's vault and deposit into receiver's vault
        self.receiverVault.deposit(from: <-self.signerVault.withdraw(amount: amount))
        log("Tokens successfully transferred from sender to receiver")
    }
}
