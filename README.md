# yobot • [![tests](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml) [![lints](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml) ![GitHub](https://img.shields.io/github/license/nascentxyz/yobot-contracts) ![GitHub package.json version](https://img.shields.io/github/package-json/v/nascentxyz/yobot-contracts)


**Experimental**, **heavily-documented** contracts for [yobot](https://yobot.com).

## Blueprint

```ml
src
├─ external
│  ├─ ERC165 — "A minimal ERC165 Implementation"
│  ├─ ERC721Enumerable — "An extension of ERC721 that supports enumeration"
│  └─ ERC721Metadata — "An Enumerable ERC721 with Metadata"
├─ interfaces
│  ├─ IArtBlocksFactory — "ArtBlocksFactory Contract Interface"
│  ├─ IERC165 — "ERC165 Interface"
│  ├─ IERC721 — "ERC721 Interface"
│  └─ IERC721Enumerable — "An Enumerable ERC721 Interface"
├─ tests
│  ├─ utils
│  │  └─ DSTestPlus — "Custom, extended DSTest Suite"
│  ├─ Coordinator.t — "Coordinator Tests"
│  ├─ YobotArtBlocksBroker.t — "YobotArtBlocksBroker Tests"
│  └─ YobotERC721LimitOrder.t — "YobotERC721LimitOrder Tests"
├─ Coordinator — "Coordinator for Fee Parameters and Reception"
├─ GenArt721Core — "..."
├─ InfiniteMint — "An ERC721 allowing infinite mints for testnet"
├─ Randomizer — "A random generation"
├─ YobotArtBlocksBroker — "Permissionless Broker for ArtBlocks Minting using Flashbot Searchers"
├─ YobotBroker — "Abstracted Broker Functionality for Yobot"
├─ YobotDeadline — "Abstracted Deadline Logic"
└─ YobotERC721LimitOrder — "Permissionless Broker for Generalized ERC721 Minting using Flashbot Searchers"
```

## Development

### First time with Forge/Foundry?

Don't have [rust](https://www.rust-lang.org/tools/install) installed?
Run
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Then, install [foundry](https://github.com/gakonst/foundry) with:
```bash
cargo install --git https://github.com/gakonst/foundry --bin forge --locked
```

### Dependencies

```bash
yarn setup
```

### Run Tests

```bash
yarn test
```

### Deploying


Then, we must source our environment variables to deploy to the Goerli network:

```bash
export ETH_FROM=xxxx
export ETH_RPC_URL=xxxx
export ETH_GAS=xxxx
export ETHERSCAN_API_KEY=xxxx
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

## License

[AGPL-3.0-only](https://github.com/nascentxyz/yobot/blob/master/LICENSE)

# Acknowledgements

- [foundry](https://github.com/gakonst/foundry)
- [solmate](https://github.com/Rari-Capital/solmate)
- [Artbotter](https://artbotter.io) for their tremendous initial lift and inspiration!
- [Georgios Konstantopoulos](https://github.com/gakonst) for [forge-template](https://github.com/gakonst/forge-template) resource.

## Noted Issues

On initial library import, `zeppelin-solidity` root contract directory will need to be changed from "contracts" to "src". Use the commands:

```
ln -s contracts lib/zeppelin-solidity/src
echo /src >>.git/modules/lib/zeppelin-solidity/info/exclude
```

## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. Nascent is not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
