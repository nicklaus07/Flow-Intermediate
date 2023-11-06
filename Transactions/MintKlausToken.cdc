import FungibleToken from 0x05
import KlausToken from 0x05

transaction(receiver: Address, amount: UFix64) {

    prepare(signer: AuthAccount) {
        // Borrow the KlausToken Minter reference
        let minter = signer.borrow<&KlausToken.Minter>(from: /storage/MinterStorage)
            ?? panic("You are not the KlausToken minter")
        
        // Borrow the receiver's KlausToken Vault capability
        let receiverVault = getAccount(receiver)
            .getCapability<&KlausToken.Vault{FungibleToken.Receiver}>(/public/Vault)
            .borrow()
            ?? panic("Error: Check your KlausToken Vault status")
        
        // Minted tokens reference
        let mintedTokens <- minter.mintToken(amount: amount)

        // Deposit minted tokens into the receiver's KlausToken Vault
        receiverVault.deposit(from: <-mintedTokens)
    }

    execute {
        log("KlausToken minted and deposited successfully")
        log("Tokens minted and deposited: ".concat(amount.toString()))
    }
}
