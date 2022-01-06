# yobot • [![tests](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/tests.yml) [![lints](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml/badge.svg)](https://github.com/nascentxyz/yobot-contracts/actions/workflows/lints.yml) ![GitHub](https://img.shields.io/github/license/nascentxyz/yobot-contracts) ![GitHub package.json version](https://img.shields.io/github/package-json/v/nascentxyz/yobot-contracts)


**Experimental**, **heavily-documented** contracts for [yobot](https://yobot.com).

## Blueprint

```ml
src
├─ Coordinator - ""
├─ tests
|  ├─ Coordinator — ""
|  ├─ YobotArtBlocksBroker — ""
|  └─ YobotERC721LimitOrder - ""
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
