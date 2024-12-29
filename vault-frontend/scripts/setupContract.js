const fs = require('fs');
const path = require('path');

// Load contract address and ABI
const addressPath = path.join(__dirname, '../src/contract-address.json');
const abiPath = path.join(__dirname, '../src/abi.json');

// Verify contract address exists
if (!fs.existsSync(addressPath)) {
  console.error('Contract address file missing! Please deploy the contract first.');
  process.exit(1);
}

// Verify ABI file exists
if (!fs.existsSync(abiPath)) {
  console.error('Contract ABI file missing! Please deploy the contract first.');
  process.exit(1);
}

// Load and log files to verify
const address = JSON.parse(fs.readFileSync(addressPath, 'utf-8')).address;
const abi = JSON.parse(fs.readFileSync(abiPath, 'utf-8'));

console.log('Contract Address:', address);
console.log('ABI:', JSON.stringify(abi, null, 2));
console.log('Setup complete!');
