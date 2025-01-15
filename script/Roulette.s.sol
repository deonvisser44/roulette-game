// scripts/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "src/Roulette.sol";

contract RouletteScript is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy the Roulette contract
        Roulette roulette = new Roulette();

        console.log("Roulette contract deployed to:", address(roulette));

        vm.stopBroadcast();
    }
}
