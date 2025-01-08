import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import styled from 'styled-components';
import abi from '../src/abi.json';

// Contract address from environment variables
const CONTRACT_ADDRESS = process.env.REACT_APP_CONTRACT_ADDRESS;

// Styled Components
const Container = styled.div`
  font-family: 'Arial', sans-serif;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
`;

const Card = styled.div`
  background: #ffffff;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  width: 400px;
  max-width: 100%;
  text-align: center;
`;

const Title = styled.h1`
  font-size: 24px;
  color: #333;
  margin-bottom: 20px;
`;

const Info = styled.p`
  margin: 10px 0;
  color: #555;
  font-size: 16px;
`;

const Input = styled.input`
  padding: 10px;
  margin: 10px 0;
  width: calc(100% - 22px);
  border: 1px solid #ddd;
  border-radius: 5px;
`;

const Button = styled.button`
  padding: 10px 15px;
  margin: 10px 5px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 14px;
  background-color: #4caf50;
  color: white;
  transition: background-color 0.2s;

  &:hover {
    background-color: #45a049;
  }

  &:disabled {
    background-color: #ccc;
    cursor: not-allowed;
  }
`;

const ErrorText = styled.p`
  color: red;
  font-size: 14px;
  margin-top: 10px;
`;

// React Component
function App() {
  const [account, setAccount] = useState('');
  const [balance, setBalance] = useState('0');
  const [depositAmount, setDepositAmount] = useState('');
  const [contract, setContract] = useState(null);
  const [governanceTokens, setGovernanceTokens] = useState('0');
  const [depositTimestamp, setDepositTimestamp] = useState('');
  const [unlockDate, setUnlockDate] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    connectWallet();
  }, []);

  // Connect Wallet
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

        await fetchDepositInfo();
      } catch (err) {
        console.error('Wallet connection failed:', err);
        setError('Wallet connection failed. Check console for details.');
      }
    } else {
      alert('MetaMask not installed!');
    }
  };

  // Fetch Deposit Info
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
        setError('Failed to fetch deposit info.');
      }
    }
  };

  // Deposit Funds
  const deposit = async () => {
    if (contract) {
      try {
        setError('');
        const tx = await contract.deposit({
          value: ethers.utils.parseEther(depositAmount),
        });
        await tx.wait();
        alert('Deposit successful!');
        await fetchDepositInfo(); // Refresh data
      } catch (err) {
        console.error('Deposit failed:', err);
        setError('Deposit failed. Check console for details.');
      }
    }
  };

  // Withdraw Funds
  const withdraw = async () => {
    if (contract) {
      try {
        setError('');
        const tx = await contract.withdraw(
          ethers.utils.parseEther(depositAmount)
        );
        await tx.wait();
        alert('Withdrawal successful!');
        await fetchDepositInfo(); // Refresh data
      } catch (err) {
        console.error('Withdrawal failed:', err);
        setError('Withdrawal failed. Check console for details.');
      }
    }
  };

  return (
    <Container>
      <Card>
        <Title>Vault Contract</Title>
        <Info>Connected Account: {account || 'Not Connected'}</Info>
        <Info>ETH Balance: {balance} ETH</Info>
        <Info>Governance Tokens: {governanceTokens}</Info>
        <Info>Deposit Timestamp: {depositTimestamp}</Info>
        <Info>Unlock Date: {unlockDate}</Info>

        <Input
          type="text"
          placeholder="Amount (ETH)"
          value={depositAmount}
          onChange={(e) => setDepositAmount(e.target.value)}
        />
        <Button onClick={deposit}>Deposit</Button>
        <Button onClick={withdraw}>Withdraw</Button>

        {error && <ErrorText>{error}</ErrorText>}
      </Card>
    </Container>
  );
}

export default App;
