import FungibleToken from 0x05
import KlausToken from 0x05

pub fun main(account: Address) {

    // Attempt to borrow PublicVault capability
    let publicVault: &KlausToken.Vault{FungibleToken.Balance, 
    FungibleToken.Receiver, KlausToken.VaultInterface}? =
        getAccount(account).getCapability(/public/Vault)
            .borrow<&KlausToken.Vault{FungibleToken.Balance, 
            FungibleToken.Receiver, KlausToken.VaultInterface}>()

    if (publicVault == nil) {
        // Create and link an empty vault if capability is not present
        let newVault <- KlausToken.createEmptyVault()
        getAuthAccount(account).save(<-newVault, to: /storage/VaultStorage)
        getAuthAccount(account).link<&KlausToken.Vault{FungibleToken.Balance, 
        FungibleToken.Receiver, KlausToken.VaultInterface}>(
            /public/Vault,
            target: /storage/VaultStorage
        )
        log("Empty vault created and linked")
        
        // Borrow the vault capability again to display its balance
        let retrievedVault: &KlausToken.Vault{FungibleToken.Balance}? =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&KlausToken.Vault{FungibleToken.Balance}>()
        log("Balance of the new vault: ")
        log(retrievedVault?.balance)
    } else {
        log("Vault already exists and is properly linked")
        
        // Borrow the vault capability for further checks
        let checkVault: &KlausToken.Vault{FungibleToken.Balance, 
        FungibleToken.Receiver, KlausToken.VaultInterface} =
            getAccount(account).getCapability(/public/Vault)
                .borrow<&KlausToken.Vault{FungibleToken.Balance, 
                FungibleToken.Receiver, KlausToken.VaultInterface}>()
                ?? panic("Vault capability not found")
        
        // Check if the vault's UUID is in the list of vaults
        if KlausToken.vaults.contains(checkVault.uuid) {     
            log("Balance of the existing vault:")       
            log(publicVault?.balance)
            log("This is a KlausToken vault")
        } else {
            log("This is not a KlausToken vault")
        }
    }
}
