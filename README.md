# Hyperlane CCIPHook

This project contains a Hyperlane CCIPHook and CCIPISM. And is intended to send Hyperlane messages via Chainlink's CCIP.

## Table of Contents

- [Hyperlane CCIPHook](#hyperlane-cciphook)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [CCIPMessageHook.sol](#ccipmessagehooksol)
  - [CCIPISM.sol](#ccipismsol)
  - [Installation](#installation)
  - [Deployment](#deployment)
  - [Post Deployment](#post-deployment)
  - [License](#license)

## Overview

The CCIP Hook contract inherits Hyperlane's IPostDispatch, and Chainlink's Client and IRouterClient contracts. The CCIP ISM contract inherits Hyperlane's IInterchainSecurityModule and AbstractMessageIdAuthorizedIsm contracts, and Chainlink's CCIPReceiver, IRouterClient and Client contracts.

## CCIPMessageHook.sol

The `CCIPMessageHook.sol` contract has a `postDispatch()` function that is intended to be called by a Hyperlane Mailbox contract, passing it a "message" as bytesdata. This function creates a `Client.EVM2AnyMessage` using the message data and sends it to the CCIPISM contract on another chain via CCIP.

[Sepolia deployment](https://sepolia.etherscan.io/address/0xCB65494C1d041bED2920Cb32E7DCE957755B04C5#code)

## CCIPISM.sol

The `CCIPISM.sol` contract has a `_ccipReceive()` function for receiving messages sent by the Hook contract on the other chain via CCIP.

[Fuji deployment](https://testnet.snowtrace.io/address/0xa3EA3A0c8C48E76e7Cb4CA601Afb4A30dE5C02C5#code)

## Installation

To install the necessary dependencies, first ensure that you have [Foundry](https://book.getfoundry.sh/getting-started/installation) installed by running the following command:

```
curl -L https://foundry.paradigm.xyz | bash
```

Then run the following commands in the project's root directory:

```
foundryup
```

```
forge install
```

## Deployment

You will need to have a `.env` file in each directory with your `$PRIVATE_KEY`.

Replace `$PRIVATE_KEY`, `$SEPOLIA_RPC_URL` and `$FUJI_RPC_URL` in the `.env` with your respective private key and rpc url.

Deploy the `CCIPMessageHook.sol` and `CCIPISM.sol` contracts to their chains by running the following commands:

```
source .env
```

```
forge script script/DeployCCIPMessageHook.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

```
forge script script/DeployCCIPISM.s.sol --rpc-url $FUJI_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## Post Deployment

The `setISM()` will have to be called on the Hook contract with the ISM address.

## License

This project is licensed under the [MIT License](https://opensource.org/license/mit/).
