#!/bin/bash

# Set variables
RESOURCE_GROUP="Ajay"  # Your existing resource group
LOCATION="canadacentral"  # Canada Central
VM_NAME="github-runner-vm"
VM_IMAGE="Canonical:0001-com-ubuntu-server-focal:20_04-lts-gen2:latest"  # Ubuntu 20.04 LTS
VM_SIZE="Standard_B1s"  # Free tier size

# Create the VM
echo "Creating Azure VM in Canada Central..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $VM_IMAGE \
  --size $VM_SIZE \
  --admin-username azureuser \
  --generate-ssh-keys \
  --location $LOCATION \
  --output json

# Open SSH port
echo "Opening SSH port..."
az vm open-port --port 22 --resource-group $RESOURCE_GROUP --name $VM_NAME

# Get VM's public IP
VM_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)

echo "VM created with IP: $VM_IP"

# SSH into the VM and set up the runner
echo "Setting up GitHub Actions runner..."
ssh -o StrictHostKeyChecking=no azureuser@$VM_IP << EOF
  sudo apt-get update && sudo apt-get upgrade -y
  sudo apt-get install -y docker.io
  sudo systemctl start docker
  sudo systemctl enable docker
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  sudo apt-get install -y gh
  mkdir actions-runner && cd actions-runner
  curl -o actions-runner-linux-x64-2.317.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz
  echo "9e883d210df8c6028aff475475a457d380353f9d01877d51cc01a17b2a91161d  actions-runner-linux-x64-2.317.0.tar.gz" | shasum -a 256 -c
  tar xzf ./actions-runner-linux-x64-2.317.0.tar.gz
  ./config.sh --url https://github.com/ajaya03/DevOps-Projects --token BGZ2VCXUKZXHC3TW3BRDKWTGU4ARA
  ./run.sh
EOF

echo "Setup complete!"
