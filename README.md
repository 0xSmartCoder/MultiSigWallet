# 🔐 MultiSig Wallet + SimpleVault Task

This project demonstrates a basic **MultiSig Wallet** contract interacting with a **SimpleVault** contract via low-level calls (`call`). It's a hands-on test of Solidity concepts like function encoding, permissions, and contract-to-contract interaction.

---

## 📆 Contracts Overview

### ✅ 1. `MultiSigWallet.sol`

A minimal multisignature wallet that allows:

* Multiple owners
* Proposing transactions
* Confirming transactions
* Executing only after enough confirmations

#### Features:

* ETH transfer or function call support
* `submitTransaction()` accepts destination, amount, and `data` payload
* `executeTransaction()` sends ETH and/or calls function

---

### ✅ 2. `SimpleVault.sol`

A basic contract that:

* Accepts ETH
* Only lets the `owner` withdraw funds to a target address
* Has a `release(address)` function used by the MultiSig wallet

**⚠️ Note:** For interaction to succeed, `owner` of `SimpleVault` **must be the `MultiSigWallet` address**.

---

## 🥪 Testing Steps (in Remix)

### Step 1: Deploy `MultiSigWallet`

* Owners: `["0xABC...", "0xDEF...", "0x123..."]`
* Votes Required: `2`

### Step 2: Deploy `SimpleVault`

* Pass the deployed `MultiSigWallet` address as constructor argument

### Step 3: Send ETH to `SimpleVault`

From Remix:

```solidity
SimpleVault.deposit({ value: 1 ether })
```

### Step 4: Prepare the encoded function call

Call this from Remix or make a helper in Solidity:

```solidity
abi.encodeWithSignature("release(address)", YOUR_WALLET_ADDRESS)
```

### Step 5: Submit transaction via `MultiSigWallet`

Call:

```solidity
submitTransaction(
  to: SimpleVault address,
  amount: 0,
  data: encoded release(...) bytes
)
```

### Step 6: Confirm transaction from 2 different owner accounts

```solidity
confirmTransaction(txId)
```

### Step 7: Execute transaction

```solidity
executeTransaction(txId)
```

If all steps are correct, the funds from `SimpleVault` will be released to the target address 🎉

---

## 💡 Learning Goals

* Understand how `call(data)` works
* Learn how `msg.sender` affects contract calls
* Practice encoding function signatures
* Build & test MultiSig confirmation logic

---

## 📁 Files

* `contracts/MultiSigWallet.sol`
* `contracts/SimpleVault.sol`

---

## 🔗 Author

Made with 💻 by Solizy
