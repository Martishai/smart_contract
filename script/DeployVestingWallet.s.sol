// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/VestingWallet.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1_000_000 ether); // donne 1 million de tokens au deployer
    }
}

contract DeployVestingWallet is Script {
    function run() external {
        vm.startBroadcast();

        // Déploiement du token factice
        MockERC20 token = new MockERC20("Mock Token", "MCK");

        // Déploiement du VestingWallet en lui passant l'adresse du token
        VestingWallet vesting = new VestingWallet(address(token));

        vm.stopBroadcast();
    }
}

