# yobot • [![tests](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml) [![lints](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml) ![GitHub](https://img.shields.io/github/license/nascentxyz/yobot-contracts) ![GitHub package.json version](https://img.shields.io/github/package-json/v/nascentxyz/yobot-contracts)


**Experimental**, **heavily-documented** contracts for [yobot](https://yobot.com).

## Blueprint

```ml
src
├─ artblocks
│  ├─ GenArt721Core — "..."
│  └─ YobotArtBlocksBroker — "Permissionless Broker for ArtBlocks Minting using Flashbot Searchers"
├─ external
│  ├─ ERC165 — "A minimal ERC165 Implementation"
│  ├─ ERC721Enumerable — "An extension of ERC721 that supports enumeration"
│  └─ ERC721Metadata — "An Enumerable ERC721 with Metadata"
├─ interfaces
│  ├─ IArtBlocksFactory — "ArtBlocksFactory Contract Interface"
│  ├─ IERC165 — "ERC165 Interface"
│  ├─ IERC721 — "ERC721 Interface"
│  └─ IERC721Enumerable — "An Enumerable ERC721 Interface"
├─ mocks
│  ├─ InfiniteMint — "An ERC721 allowing infinite mints for testnet"
│  └─ StrictMint — "An ERC721 with strict minting"
├─ tests
│  ├─ utils
│  │  └─ DSTestPlus — "Custom, extended DSTest Suite"
│  ├─ Coordinator.t — "Coordinator Tests"
│  ├─ YobotArtBlocksBroker.t — "YobotArtBlocksBroker Tests"
│  └─ YobotERC721LimitOrder.t — "YobotERC721LimitOrder Tests"
├─ utils
│  ├─ Randomizer — "A random generation"
│  └─ YobotDeadline — "Abstracted Deadline Logic"
├─ Coordinator — "Coordinator for Fee Parameters and Reception"
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

View [DEPLOYING.md](./DEPLOYING.md).

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
