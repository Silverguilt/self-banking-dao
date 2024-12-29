import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import abi from '../src/abi.json';

const CONTRACT_ADDRESS = process.env.REACT_APP_CONTRACT_ADDRESS;

function App() {
  const [account, setAccount] = useState('');
  const [balance, setBalance] = useState('0');
  const [depositAmount, setDepositAmount] = useState('');
  const [contract, setContract] = useState(null);
  const [governanceTokens, setGovernanceTokens] = useState('0');
  const [depositTimestamp, setDepositTimestamp] = useState('');
  const [unlockDate, setUnlockDate] = useState('');

  useEffect(() => {
    connectWallet();
  }, []);

  // Connect MetaMask Wallet
  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();

        const contractInstance = new ethers.Contract(
          CONTRACT_ADDRESS,
          abi,
          signer
        );

        const accounts = await provider.send('eth_requestAccounts', []);
        setAccount(accounts[0]);
        setContract(contractInstance);

        const balance = await provider.getBalance(accounts[0]);
        setBalance(ethers.utils.formatEther(balance));

        const governanceTokens = await contractInstance.getGovernanceTokens(
          accounts[0]
        );
        setGovernanceTokens(governanceTokens.toString());

        // Fetch deposit info
        await fetchDepositInfo();
      } catch (err) {
        console.error('Wallet connection failed:', err);
      }
    } else {
      alert('MetaMask not installed!');
    }
  };

  // Fetch deposit timestamp and unlock date
  const fetchDepositInfo = async () => {
    if (contract) {
      try {
        const depositInfo = await contract.getDeposit(account);
        const timestamp = parseInt(depositInfo.timestamp.toString());

        if (timestamp > 0) {
          const unlockTimestamp = timestamp + 604800; // 1 week lock (604800 seconds)
          const unlockDate = new Date(unlockTimestamp * 1000); // Convert to milliseconds

          setDepositTimestamp(new Date(timestamp * 1000).toLocaleString());
          setUnlockDate(unlockDate.toLocaleString());
        } else {
          setDepositTimestamp('No deposit found');
          setUnlockDate('N/A');
        }
      } catch (err) {
        console.error('Failed to fetch deposit info:', err);
      }
    }
  };

  // Deposit Funds
  const deposit = async () => {
    if (contract) {
      try {
        const tx = await contract.deposit({
          value: ethers.utils.parseEther(depositAmount),
        });
        await tx.wait();
        alert('Deposit successful!');
        await fetchDepositInfo(); // Update timestamps after deposit
      } catch (err) {
        console.error('Deposit failed:', err);
      }
    }
  };

  // Withdraw Funds
  const withdraw = async () => {
    if (contract) {
      try {
        const tx = await contract.withdraw(
          ethers.utils.parseEther(depositAmount)
        );
        await tx.wait();
        alert('Withdrawal successful!');
      } catch (err) {
        console.error('Withdrawal failed:', err);
      }
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Vault Contract</h1>
      <p>Connected Account: {account}</p>
      <p>ETH Balance: {balance} ETH</p>
      <p>Governance Tokens: {governanceTokens}</p>
      <p>Deposit Timestamp: {depositTimestamp}</p>
      <p>Unlock Date: {unlockDate}</p>

      <input
        type="text"
        placeholder="Amount (ETH)"
        value={depositAmount}
        onChange={(e) => setDepositAmount(e.target.value)}
      />
      <button
        onClick={deposit}
        style={{ marginRight: '10px' }}
      >
        Deposit
      </button>
      <button onClick={withdraw}>Withdraw</button>
    </div>
  );
}

export default App;
