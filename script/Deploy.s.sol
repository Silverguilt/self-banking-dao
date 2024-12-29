// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Vault.sol";

contract DeployVault is Script {
    function run() external {
        // Load private key
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcast
        vm.startBroadcast(privateKey);

        // Deploy the contract
        Vault vault = new Vault();
        console.log("Vault deployed at:", address(vault));

        // Stop broadcast
        vm.stopBroadcast();
    }
}
