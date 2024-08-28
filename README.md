# Merkle Airdrop 

- [Merkle Airdrop](#merkle-airdrop)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Pre-deploy and Pre-tests: Generate merkle proofs](#pre-deploy-and-pre-tests-generate-merkle-proofs)
- [Deploy](#deploy)
  - [Interacting - Local anvil network](#interacting---local-anvil-network)
    - [Setup anvil and deploy contracts](#setup-anvil-and-deploy-contracts)
    - [Sign your airdrop claim](#sign-your-airdrop-claim)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Estimate gas](#estimate-gas)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)` 


## Quickstart

```bash
git clone https://github.com/maikelordaz/merkle-airdrop
cd merkle-airdrop
make all
```

# Usage

## Pre-deploy and Pre-tests: Generate merkle proofs

If working with default addresses skip this section

To ork with different addresses:
1. Update the whitelist in `GenerateInput.s.sol`. This will To generate the input file and then the merkle root and proofs
2. Run:

```bash
make merkle
```

3. In the `script/target/output.json` take the `root` (there more than 1, but all be the same)
4. Paste it in the `DeployMerkleAirdrop.s.sol` 

# Deploy 

## Interacting - Local anvil network

### Setup anvil and deploy contracts

>[!NOTE]
> This scripts only work in wsl

```bash
make anvil
# in another terminal
make deploy
# Copy the ArepaToken address & Airdrop contract address
```
Copy the Arepa Token and Aidrop contract addresses and paste them into the `AIRDROP_ADDRESS` and `TOKEN_ADDRESS` variables in the `MakeFile`

The following steps allow the second default anvil address (`0x70997970C51812dc3A010C7d01b50e0d17dc79C8`) to call claim and pay for the gas on behalf of the first default anvil address (`0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`) which will recieve the airdrop. 

### Sign your airdrop claim  

```bash
# in another terminal
make sign
```

1. Retrieve the signature bytes outputted to the terminal and add them to `Interact.s.sol` *making sure to remove the `0x` prefix*.
2. If you have modified the claiming addresses in the merkle tree, you will need to update the proofs in this file too (which you can get from `output.json`)
3. Run the following command to check the balance before the claim   
   
```bash
make balance
```

4. Run the following command to claim the airdrop

```bash
make claim
```

5. Check the claiming address balance has increased by running

```bash
make balance
```

NOTE: `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` is the default anvil address which has recieved the airdropped tokens.


## Testing

```bash
forge test
```

### Test Coverage

```bash
forge coverage
```

## Estimate gas

You can estimate how much gas things cost by running:

```bash
forge snapshot
```

And you'll see an output file called `.gas-snapshot`