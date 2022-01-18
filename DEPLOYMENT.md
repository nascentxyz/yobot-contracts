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

InfiniteMint deployed with:
```bash
forge create --rpc-url https://eth-goerli.alchemyapi.io/v2/<your_api_key> --chain 'goerli' --interactive InfiniteMint --constructor-args 'TEST' 'TEST'
```

InfiniteMint deployed on Goerli at [0xc47eff74c2e949fee8a249586e083f573a7e56fa](https://goerli.etherscan.io/address/0xc47eff74c2e949fee8a249586e083f573a7e56fa).

The `--interactive` flag allows you to enter your deployer wallet private key in the terminal without exposing it in plain text.

Verification requires the following environment variables to be set:
```bash
export ETH_RPC_URL=xxxx
export ETHERSCAN_API_KEY=xxxx
```

// TODO: wait for file flattening https://github.com/gakonst/ethers-rs/pull/774

Verify InfiniteMint contract with:
```bash
forge verify-contract src/InfiniteMint.sol:InfiniteMint 0xc47eff74c2e949fee8a249586e083f573a7e56fa 'TEST' 'TEST'
```
  
StrictMint deployed with:
```bash
forge create --rpc-url https://eth-goerli.alchemyapi.io/v2/<your_api_key> --chain 'goerli' --interactive StrictMint --constructor-args <os_registry_address>
```

StrictMint deployed to Goerli at [0x908b07973b4cedb0cad205a9766496e602b7a974](https://goerli.etherscan.io/address/0x908b07973b4cedb0cad205a9766496e602b7a974)