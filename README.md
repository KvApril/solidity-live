# Senior Solidity Live Coding — Quick Rounds (5-10 min each)

## Fork and clone this repo then complete each of the challenges in the following order

Eight independent problems, one short contract file each. Every file
compiles as-is with a real bug baked in and a short TASK comment at the
top. Solidity `^0.8.24`, zero imports — drops straight into Remix,
Foundry, or Hardhat. Candidates fix the starter file directly.

| File | Bug class | Target |
|---|---|---|
| `01_ReadOnlyReentrancy_Vault.sol` | Reentrancy + read-only reentrancy on the oracle view | ~5-10 min |
| `02_SignatureReplay_Claimable.sol` | Signature replay (nonce / chain id / contract binding) | ~5-10 min |
| `03_ProxyStorageCollision.sol` | Delegatecall storage collision (EIP-1967 slots) | ~10 min |
| `04_InflationAttack_TokenVault.sol` | First-depositor inflation attack, rounding direction | ~10 min |
| `05_TxOriginAuth_Wallet.sol` | `tx.origin` authorization / phishing | ~5 min |
| `06_UncheckedTransfer_Escrow.sol` | Unchecked ERC20 return value | ~5-10 min |
| `07_UnprotectedInitializer_Vault.sol` | Unprotected / re-callable initializer | ~5 min |
| `08_PushPaymentDoS_Airdrop.sol` | Push-payment DoS + unbounded loop | ~5-10 min |

## Evaluating

- Can they **name the bug class** before fixing it, quickly?
- Is the fix minimal and correct, respecting stated constraints
  (unchanged signatures etc.)?
- Senior signal: edge cases and follow-ups raised unprompted
  (read-only reentrancy in 01, non-bool tokens in 06, locking the
  implementation contract in 07, CEI in the new claim path in 08).
