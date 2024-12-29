# Vault Smart Contract Project

This project implements a **Vault Smart Contract** deployed on the **Sepolia Testnet**. It includes:

- **Solidity Smart Contract**: Vault with deposit, withdraw, and governance token features.
- **React Frontend**: Simple UI to interact with the contract.
- **Deployment Scripts**: Automated deployment and integration with the frontend.

## **Table of Contents**

- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Environment Variables](#environment-variables)
- [Scripts](#scripts)
- [Testing and Usage](#testing-and-usage)
- [Governance Tokens](#governance-tokens)
- [Future Enhancements](#future-enhancements)

---

## **Prerequisites**

Make sure you have the following installed:

- **Node.js** (v18 or later)
- **Yarn** (v1.22 or later)
- **Foundry** (latest version) - Smart contract framework
- **MetaMask** - For interacting with the deployed contract

---

## **Setup**

1. **Clone the Repository:**

```bash
git clone https://github.com/your-repository/vault-project.git
cd vault-project
```

2. **Backend Setup (Foundry):**

```bash
cd backend
forge install
forge build
```

3. **Frontend Setup (React):**

```bash
cd ../frontend
yarn install
```

---

## **Environment Variables**

### Create a `.env` file in both backend and frontend folders:

**Backend (.env):**

```
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
PRIVATE_KEY=0xYOUR_WALLET_PRIVATE_KEY
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY
```

**Frontend (.env):**

```
REACT_APP_CONTRACT_ADDRESS=0xYourDeployedContractAddress
```

---

## **Scripts**

### **Backend Scripts**

**Deploy Contract:**

```bash
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

**Export ABI and Address (Manual):**

```bash
forge inspect Vault abi > ../frontend/src/abi.json
```

### **Frontend Scripts**

**Setup Frontend:**

```bash
yarn setup
```

**Start Frontend Development Server:**

```bash
yarn start
```

---

## **Testing and Usage**

1. **Connect MetaMask** to the Sepolia Test Network.
2. **Deposit Funds:** Enter the amount in ETH and click **Deposit**.
3. **Check Unlock Date:** Displays the deposit timestamp and unlock date for withdrawals.
4. **Withdraw Funds:** Withdraw funds after the **1-week lock period**.
5. **Governance Tokens:** Tokens are manually allocated (see below).

---

## **Governance Tokens**

### **Manual Allocation**

Open the browser console and use:

```javascript
await window.contract.allocateGovernance('0xYourAccountAddress');
```

### **Check Token Balance**

```javascript
const tokens = await window.contract.getGovernanceTokens(
  '0xYourAccountAddress'
);
console.log('Tokens:', tokens.toString());
```

---

## **Future Enhancements**

- **Automatic Governance Allocation:** Tokens are assigned automatically on deposit.
- **Voting System Integration:** Allow governance tokens to be used for voting.
- **Token Transfers:** Enable transfer of governance tokens between users.
- **Better UX:** More responsive design and enhanced error handling.

---

## **Contributing**

Feel free to fork this repository and submit pull requests with improvements or feature additions.

---

## **License**

This project is licensed under the [MIT License](LICENSE).
