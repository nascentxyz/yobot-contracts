# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: update solc build dappbuild

# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_11

# deps
update:; forge update

# Build & test
build  :; forge build --optimize --optimize-runs 1000000
dappbuild :; dapp build
test   :; forge test --optimize --optimize-runs 1000000 -v # --ffi # enable if you need the `ffi` cheat code on HEVM

# Gas
gas-test :; forge test --gas-snapshot
snapshot :; forge snapshot --optimize --optimize-runs 1000000

# Flattening
flatten :; forge flatten ./src/YobotERC721LimitOrder.sol

# Fork Mainnet With Hardhat
mainnet-fork :; npx hardhat node --fork ${ETH_MAINNET_RPC_URL}