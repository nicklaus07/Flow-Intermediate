import FungibleToken from 0x05
import KlausToken from 0x05

// Create Klaus Token Vault
transaction () {

    // Define references
    let userVault: &KlausToken.Vault{FungibleToken.Balance, 
    FungibleToken.Provider, 
    FungibleToken.Receiver, 
    KlausToken.VaultInterface}?
    let account: AuthAccount

    prepare(acct: AuthAccount) {

        // Borrow vault capability and set account reference
        self.userVault = acct.getCapability(/public/Vault)
            .borrow<&KlausToken.Vault{FungibleToken.Balance, FungibleToken.Provider, FungibleToken.Receiver, KlausToken.VaultInterface}>()
            ?? panic("Could not borrow KlausToken Vault from signer")

        self.account = acct
    }

    execute {
        if self.userVault == nil {
            // Create and link an empty vault if none exists
            let emptyVault <- KlausToken.createEmptyVault()
            self.account.save(<-emptyVault, to: /storage/VaultStorage)
            self.account.link<&KlausToken.Vault{FungibleToken.Balance, 
            FungibleToken.Provider, 
            FungibleToken.Receiver, 
            KlausToken.VaultInterface}>(/public/Vault, target: /storage/VaultStorage)
            log("Empty vault created and linked")
        } else {
            log("Vault already exists and is properly linked")
        }
    }
}
