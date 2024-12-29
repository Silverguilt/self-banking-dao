// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Vault is AccessControl, ReentrancyGuard {
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Deposit) public deposits;
    mapping(address => uint256) public governanceTokens;

    uint256 public totalDeposits;

    event Deposited(address indexed user, uint256 amount);
    event GovernanceAllocated(address indexed user, uint256 governanceTokens);
    event Withdrawn(address indexed user, uint256 amount);
    event CreditScoreChecked(address indexed user, uint256 score);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GOVERNANCE_ROLE, msg.sender);
    }

    // Fallback to accept direct Ether transfers
    receive() external payable {
        deposits[msg.sender].amount += msg.value;
        deposits[msg.sender].timestamp = block.timestamp;
        totalDeposits += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    // Deposit funds into the vault
    function deposit() external payable nonReentrant {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        deposits[msg.sender].amount += msg.value;
        deposits[msg.sender].timestamp = block.timestamp;
        totalDeposits += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    function getDeposit(address user) external view returns (Deposit memory) {
        return deposits[user];
    }

    // Allocate governance rights based on deposit amount
    function allocateGovernance(
        address user
    ) external onlyRole(GOVERNANCE_ROLE) {
        uint256 depositAmount = deposits[user].amount;
        require(depositAmount > 0, "User has no deposits");

        uint256 governanceAmount = depositAmount / 1 ether; // Example: 1 governance token per 1 ether deposited
        governanceTokens[user] += governanceAmount;

        emit GovernanceAllocated(user, governanceAmount);
    }

    // Withdraw funds with DAO-defined rules
    function withdraw(uint256 amount) external nonReentrant {
        Deposit storage userDeposit = deposits[msg.sender];
        require(userDeposit.amount >= amount, "Insufficient balance");
        require(
            block.timestamp >= userDeposit.timestamp + 1 weeks,
            "Funds are locked for 1 week"
        ); // Example rule

        userDeposit.amount -= amount;
        totalDeposits -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    // Integrate credit score (optional)
    function integrateCreditScore(
        address user,
        uint256 creditScore
    ) external onlyRole(GOVERNANCE_ROLE) {
        // Example: Emit an event or make decisions based on credit score
        emit CreditScoreChecked(user, creditScore);
    }

    // View governance token balance
    function getGovernanceTokens(address user) external view returns (uint256) {
        return governanceTokens[user];
    }
}
