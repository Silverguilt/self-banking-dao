// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Vault.sol";

contract DeployVault is Script {
    function run() external {
        // Load private key from environment variables
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        // Start the broadcast (transaction execution)
        vm.startBroadcast(privateKey);

        // Deploy the Vault contract
        Vault vault = new Vault();

        // Stop broadcasting
        vm.stopBroadcast();

        console.log("Vault deployed at:", address(vault));
    }
}
