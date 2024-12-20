// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Vault is AccessControl, ReentrancyGuard {
    bytes32 public constant LENDER_ROLE = keccak256("LENDER_ROLE");

    struct Loan {
        uint256 amount;
        uint256 interestRate;
        uint256 duration;
        uint256 startTime;
        address borrower;
        bool repaid;
    }

    mapping(uint256 => Loan) public loans;
    uint256 public loanCounter;

    event LoanCreated(
        uint256 loanId,
        address indexed borrower,
        uint256 amount,
        uint256 interestRate,
        uint256 duration
    );
    event LoanRepaid(uint256 loanId, address indexed borrower);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createLoan(
        uint256 amount,
        uint256 interestRate,
        uint256 duration
    ) external nonReentrant {
        loanCounter++;
        loans[loanCounter] = Loan(
            amount,
            interestRate,
            duration,
            block.timestamp,
            msg.sender,
            false
        );
        emit LoanCreated(
            loanCounter,
            msg.sender,
            amount,
            interestRate,
            duration
        );
    }

    function repayLoan(uint256 loanId) external payable nonReentrant {
        Loan storage loan = loans[loanId];
        require(msg.sender == loan.borrower, "Not your loan");
        require(!loan.repaid, "Loan already repaid");
        uint256 totalAmount = loan.amount +
            ((loan.amount * loan.interestRate) / 100);
        require(msg.value == totalAmount, "Incorrect repayment amount");

        loan.repaid = true;
        emit LoanRepaid(loanId, msg.sender);
    }

    function getLoan(uint256 loanId) external view returns (Loan memory) {
        return loans[loanId];
    }
}
