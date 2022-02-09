


### Generating Contract Visuals

We use [surya](https://github.com/ConsenSys/surya) to create contract diagrams.

Run `yarn visualize` to generate an amalgamated contract visualization in the `out/` directory. Or use the below commands for each respective contract.

##### YobotArtBlocksBroker.sol

Run `surya graph -s src/YobotArtBlocksBroker.sol | dot -Tpng > out/YobotArtBlocksBroker.png`

##### YobotERC721LimitOrder.sol

Run `surya graph -s src/YobotERC721LimitOrder.sol | dot -Tpng > out/YobotERC721LimitOrder.png`
