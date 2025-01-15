// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Roulette.sol";

contract RouletteTest is Test {
    Roulette roulette;

    function setUp() public {
        roulette = new Roulette();
    }

    function testDepositFunds() public {
        vm.startPrank(roulette.admin());
        roulette.depositFunds{value: 1 ether}();
        assertEq(address(roulette).balance, 1 ether);
        vm.stopPrank();
    }

    function testPlayerDeposit() public {
        roulette.playerDeposit{value: 0.5 ether}();
        assertEq(roulette.playerBalances(address(this)), 0.5 ether);
    }
}
