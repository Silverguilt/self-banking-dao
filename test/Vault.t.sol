// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault vault;
    address user = address(0x123);

    function setUp() public {
        vault = new Vault();
    }

    function testDeposit() public {
        uint256 depositAmount = 1 ether;

        vm.deal(user, depositAmount);
        vm.startPrank(user);
        vault.deposit{value: depositAmount}();

        Vault.Deposit memory userDeposit = vault.getDeposit(user);
        assertEq(userDeposit.amount, depositAmount, "Deposit amount mismatch");
        assertEq(userDeposit.timestamp, block.timestamp, "Timestamp mismatch");

        assertEq(
            address(vault).balance,
            depositAmount,
            "Vault balance mismatch"
        );
        vm.stopPrank();
    }

    function testAllocateGovernance() public {
        uint256 depositAmount = 1 ether;

        vm.deal(user, depositAmount);
        vm.startPrank(user);
        vault.deposit{value: depositAmount}();
        vm.stopPrank();

        // Test allocateGovernance
        vm.startPrank(address(this)); // Deployer acts as the admin
        vault.allocateGovernance(user); // Pass the correct argument
        uint256 governanceTokens = vault.getGovernanceTokens(user);
        assertEq(
            governanceTokens,
            depositAmount / 1 ether,
            "Governance tokens mismatch"
        );
        vm.stopPrank();
    }

    function testWithdraw() public {
        uint256 depositAmount = 1 ether;

        vm.deal(user, depositAmount);
        vm.startPrank(user);
        vault.deposit{value: depositAmount}();
        vm.stopPrank();

        vm.warp(block.timestamp + 7 days);
        vm.startPrank(user);
        vault.withdraw(depositAmount); // Pass the correct argument
        Vault.Deposit memory userDeposit = vault.getDeposit(user);
        assertEq(userDeposit.amount, 0, "Deposit should be withdrawn");
        assertEq(address(vault).balance, 0, "Vault balance mismatch");
        vm.stopPrank();
    }

    function testWithdrawFailsBeforeLockPeriod() public {
        uint256 depositAmount = 1 ether;

        vm.deal(user, depositAmount);
        vm.startPrank(user);
        vault.deposit{value: depositAmount}();

        vm.expectRevert("Funds are locked for 1 week");
        vault.withdraw(depositAmount);
        vm.stopPrank();
    }

    function testFallbackFunction() public {
        uint256 depositAmount = 1 ether;

        vm.deal(user, depositAmount);
        vm.startPrank(user);

        (bool success, ) = address(vault).call{value: depositAmount}("");
        assertTrue(success, "Fallback function failed");
        assertEq(
            address(vault).balance,
            depositAmount,
            "Vault balance mismatch"
        );
        vm.stopPrank();
    }

    function testCreditScoreIntegration() public {
        uint256 depositAmount = 1 ether;
        uint256 mockCreditScore = 750;

        vm.deal(user, depositAmount);
        vm.startPrank(user);
        vault.deposit{value: depositAmount}();
        vm.stopPrank();

        // Integrate credit score
        vm.startPrank(address(this)); // Deployer acts as the admin
        vault.integrateCreditScore(user, mockCreditScore);

        // Credit score integration doesn't affect balances but emits an event
        Vault.Deposit memory userDeposit = vault.getDeposit(user);
        assertEq(
            userDeposit.amount,
            depositAmount,
            "Deposit amount should remain unchanged"
        );
        vm.stopPrank();
    }
}
