# yobot • [![tests](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml) [![lints](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml) ![GitHub](https://img.shields.io/github/license/nascentxyz/yobot-contracts) ![GitHub package.json version](https://img.shields.io/github/package-json/v/nascentxyz/yobot-contracts)


**Experimental**, **heavily-documented** contracts for [yobot](https://yobot.com).

## Blueprint

```ml
src
├─ external
|  ├─ ERC165 — "A minimal ERC165 Implementation"
|  ├─ ERC721Enumerable — "An extension of ERC721 that supports enumeration"
|  └─ ERC721Metadata — "An Enumerable ERC721 with Metadata"
├─ interfaces
|  ├─ IArtBlocksFactory — "ArtBlocksFactory Contract Interface"
|  ├─ IERC165 — "ERC165 Interface"
|  ├─ IERC721 — "ERC721 Interface"
|  └─ IERC721Enumerable — "An Enumerable ERC721 Interface"
├─ tests
|  ├─ utils
|  |  └─ DSTestPlus — "Custom, extended DSTest Suite"
|  ├─ Coordinator.t — "Coordinator Tests"
|  ├─ YobotArtBlocksBroker.t — "YobotArtBlocksBroker Tests"
|  └─ YobotERC721LimitOrder.t — "YobotERC721LimitOrder Tests"
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

First, if `seth` is not configured, we should run an `ethsign import --keystore <desired_keystore_file_location>`.
Then follow the steps to import your wallet private key and set a signing passphrase.

Then, we must source our environment variables to deploy to the Goerli network:

```
ETH_FROM=xxxx
ETH_RPC_URL=xxxx
ETH_GAS=xxxx
```

The ArtBlocks Factory is deployed on mainnet at [0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270](https://etherscan.io/address/0xa7d8d9ef8D8Ce8992Df33D8b8CF4Aebabd5bD270#code), but we need to have it deployed on goerli.

To deploy `GenArt721Core` as was deployed to `` on [Goerli](), run the following command in the [base directory](./):

```
dapp create GenArt721Core --verify
```

**YobotERC721LimitOrder** deployed and verified on goerli at [0x0d29790c2412f42248905f879260f1a6f409a11a](https://goerli.etherscan.io/address/0x0d29790c2412f42248905f879260f1a6f409a11a#code)

Command used to deploy:

```
ETH_GAS=15000000 dapp create src/YobotERC721LimitOrder.sol:YobotERC721LimitOrder --verify 0xf25e32C0f2928F198912A4F21008aF146Af8A05a 5
```

Command used to verify:

```
ETH_GAS=15000000 dapp verify-contract src/YobotERC721LimitOrder.sol:YobotERC721LimitOrder 0x0d29790c2412f42248905f879260f1a6f409a11a 0xf25e32C0f2928F198912A4F21008aF146Af8A05a 5
```

**YobotArtBlocksBroker** Deployed and verified on goerli at: [0x041761ca2d7730ae3788f732c1a43db002feff2f](https://goerli.etherscan.io/address/0x041761ca2d7730ae3788f732c1a43db002feff2f#code)

Command used to deploy:

```
ETH_GAS=15000000 dapp create src/YobotArtBlocksBroker.sol:YobotArtBlocksBroker 0xf25e32C0f2928F198912A4F21008aF146Af8A05a 5
```

Command to verify:

```
ETH_GAS=15000000 dapp verify-contract src/YobotArtBlocksBroker.sol:YobotArtBlocksBroker 0x041761ca2d7730ae3788f732c1a43db002feff2f 0xf25e32C0f2928F198912A4F21008aF146Af8A05a 5
```

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
