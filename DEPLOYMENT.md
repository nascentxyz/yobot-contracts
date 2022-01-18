## Setting up the deployment environment

Set the environment variables from the example `.env.example` file in a `.env` file.
Alternatively, export then to the current shell.

```sh
## Etherscan API Key ##
## Used for verification of contracts on deployement ##
ETHERSCAN_API_KEY=

## Alchemy API Key ##
## For deployment ##
ALCHEMY_API_KEY=

## Alchmey API Key URL ##
ETH_RPC_URL=

## EOA Contract Deployer ##
ETH_FROM=

## Block gas limit (max: 15M ie 15000000) ##
ETH_GAS=15000000
```

## Deploying Contracts

#### Prerequisites

Install DappTools using their [installation guide](https://github.com/dapphub/dapptools#installation).

Don't have [Rust](https://www.rust-lang.org/tools/install) installed?
Run
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Then, install [Foundry](https://github.com/gakonst/foundry) with:
```bash
cargo install --git https://github.com/gakonst/foundry --bin forge --locked
```

First run the following to build using both forge (deploying) and dapp (verifying):
```bash
make
```

#### InfiniteMint


#### StrictMint

OpenSea Registry Proxy (Mainnet): [0xa5409ec958c83c3f309868babaca7c86dcb077c1](https://etherscan.io/address/0xa5409ec958c83c3f309868babaca7c86dcb077c1)

OpenSea Registry Proxy (Goerli): [???]


`StrictMint` deployed with:
```bash
forge create --rpc-url https://eth-goerli.alchemyapi.io/v2/<your_api_key> --chain 'goerli' --interactive ./src/mocks/StrictMint.sol:StrictMint
```

StrictMint deployed on Goerli at [0xed198777a685a7152ecf165b4a4dee010fe6f933](https://goerli.etherscan.io/address/0xed198777a685a7152ecf165b4a4dee010fe6f933).

The `--interactive` flag allows you to enter your deployer wallet private key in the terminal without exposing it in plain text.

Verify the contract with dapptools.

Verify StrictMint contract with:
```bash
ETH_FROM=<ETH_FROM> ETH_RPC_URL=https://eth-goerli.alchemyapi.io/v2/<your_api_key> ETHERSCAN_API_KEY=<api_key> ETH_GAS=15000000 dapp verify-contract src/mocks/StrictMint.sol:StrictMint 0xed198777a685a7152ecf165b4a4dee010fe6f933
```

#### YobotERC721LimitOrder


`YobotERC721LimitOrder` deployed with:
```bash
forge create --rpc-url https://eth-goerli.alchemyapi.io/v2/<your_api_key> --chain 'goerli' --interactive ./src/YobotERC721LimitOrder.sol:YobotERC721LimitOrder
```

YobotERC721LimitOrder deployed on Goerli at [0x20340e29ba445553f6a5c1b8d30f405b3447664d](https://goerli.etherscan.io/address/0x20340e29ba445553f6a5c1b8d30f405b3447664d).

The `--interactive` flag allows you to enter your deployer wallet private key in the terminal without exposing it in plain text.

Verify YobotERC721LimitOrder contract with:
```bash
ETH_FROM=<ETH_FROM> ETH_RPC_URL=https://eth-goerli.alchemyapi.io/v2/<your_api_key> ETHERSCAN_API_KEY=<api_key> ETH_GAS=15000000 dapp verify-contract src/YobotERC721LimitOrder.sol:YobotERC721LimitOrder 0x20340e29ba445553f6a5c1b8d30f405b3447664d 0xf25e32C0f2928F198912A4F21008aF146Af8A05a 500
```