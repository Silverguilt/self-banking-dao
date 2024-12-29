#!/bin/bash

# Exit immediately if a command fails
set -e

# Load environment variables
source .env

echo "Starting deployment..."

# Deploy the contract using Foundry
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast

# Export the ABI to the frontend
echo "Exporting ABI..."
forge inspect Vault abi > vault-frontend/src/abi.json

# Prompt for the contract address
read -p "Enter deployed contract address: " CONTRACT_ADDRESS

# Write the contract address to a JSON file in the frontend
echo "Saving contract address..."
echo "{\"address\":\"$CONTRACT_ADDRESS\"}" > vault-frontend/src/contract-address.json

# Verify the files
echo "Verifying files..."
cat vault-frontend/src/abi.json
cat vault-frontend/src/contract-address.json

# Navigate to frontend and run setup
echo "Setting up frontend..."
cd vault-frontend
yarn setup
yarn start

echo "Deployment and frontend setup complete!"
