#!/bin/bash

# Script to check if required tools are installed for the EPAM Cloud Project
echo "Checking required tools for EPAM Cloud Project..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for pyenv
echo -n "Checking for pyenv... "
if command_exists pyenv; then
    echo "[OK] Installed (Version: $(pyenv --version))"
else
    echo "[MISSING] Not installed"
fi

# Check for tfenv
echo -n "Checking for tfenv... "
if command_exists tfenv; then
    echo "[OK] Installed (Version: $(tfenv --version))"
else
    echo "[MISSING] Not installed"
fi

# Check for Terraform (should be managed by tfenv)
echo -n "Checking for Terraform... "
if command_exists terraform; then
    TERRAFORM_PATH=$(which terraform)
    if [[ "$TERRAFORM_PATH" == *".tfenv"* ]]; then
        # Try to get the version, handling the case where no version is set
        TERRAFORM_VERSION=$(terraform version 2>&1 | head -n1)
        if [[ "$TERRAFORM_VERSION" == *"Version could not be resolved"* ]]; then
            echo "[WARNING] Installed but no version set (managed by tfenv)"
        else
            echo "[OK] Installed (Managed by tfenv: $TERRAFORM_VERSION)"
        fi
    else
        echo "[WARNING] Installed but not managed by tfenv (direct installation)"
    fi
else
    echo "[MISSING] Not installed"
fi

# Check for Ansible
echo -n "Checking for Ansible... "
if command_exists ansible; then
    ANSIBLE_PATH=$(which ansible)
    if [[ "$ANSIBLE_PATH" == *".pyenv/shims"* ]] || [[ "$ANSIBLE_PATH" == *".venv"* ]] || [[ "$ANSIBLE_PATH" == *"/ansible-env/"* ]]; then
        echo "[OK] Installed in a virtual environment"
    else
        echo "[WARNING] Installed but not in a virtual environment"
    fi
else
    echo "[MISSING] Not installed"
fi

# Check for AWS CLI
echo -n "Checking for AWS CLI... "
if command_exists aws; then
    AWS_VERSION=$(aws --version 2>&1 | head -n1)
    echo "[OK] Installed ($AWS_VERSION)"
else
    echo "[MISSING] Not installed"
fi

# Check for Azure CLI
echo -n "Checking for Azure CLI... "
if command_exists az; then
    AZ_VERSION=$(az version --short 2>/dev/null | head -n1 | cut -d' ' -f3)
    echo "[OK] Installed ($AZ_VERSION)"
else
    echo "[MISSING] Not installed"
fi

# Check for Google Cloud CLI
echo -n "Checking for Google Cloud CLI... "
if command_exists gcloud; then
    GCLOUD_VERSION=$(gcloud version --short 2>/dev/null | head -n1)
    echo "[OK] Installed ($GCLOUD_VERSION)"
else
    echo "[MISSING] Not installed"
fi

echo ""
echo "Checking Python and pip..."

# Check for Python
echo -n "Checking for Python... "
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo "[OK] Installed ($PYTHON_VERSION)"
else
    echo "[MISSING] Not installed"
fi

# Check for pip
echo -n "Checking for pip... "
if command_exists pip; then
    PIP_VERSION=$(pip --version 2>&1 | head -n1)
    echo "[OK] Installed ($PIP_VERSION)"
elif command_exists pip3; then
    PIP_VERSION=$(pip3 --version 2>&1 | head -n1)
    echo "[OK] Installed ($PIP_VERSION)"
else
    echo "[MISSING] Not installed"
fi

echo ""
echo "Summary of missing tools:"
MISSING_TOOLS=()

if ! command_exists pyenv; then MISSING_TOOLS+=("pyenv"); fi
if ! command_exists tfenv; then MISSING_TOOLS+=("tfenv"); fi
if ! command_exists terraform; then MISSING_TOOLS+=("terraform"); fi
if ! command_exists ansible; then MISSING_TOOLS+=("ansible"); fi
if ! command_exists aws; then MISSING_TOOLS+=("AWS CLI"); fi
if ! command_exists az; then MISSING_TOOLS+=("Azure CLI"); fi
if ! command_exists gcloud; then MISSING_TOOLS+=("Google Cloud CLI"); fi

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo "[OK] All required tools are installed!"
else
    echo "[WARNING] The following tools are missing:"
    for tool in "${MISSING_TOOLS[@]}"; do
        echo "  - $tool"
    done
    echo ""
fi

echo ""
echo "Recommendations:"
echo "- Install pyenv to manage Python versions: https://github.com/pyenv/pyenv#installation"
echo "- Install tfenv to manage Terraform versions: https://github.com/tfutils/tfenv#installation"
echo "- Install Ansible in a virtual environment for the project"
echo "- Choose a cloud provider (AWS, Azure, or GCP) and install the corresponding CLI tool"
echo "- Install Terraform using tfenv once tfenv is installed"

echo ""
echo "Installation commands (for Ubuntu/Debian):"
echo ""
echo "# Install pyenv dependencies and pyenv:"
echo "sudo apt update"
echo "sudo apt install -y make build-essential libssl-dev zlib1g-dev \\"
echo "    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \\"
echo "    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \\"
echo "    libffi-dev liblzma-dev"
echo "curl https://pyenv.run | bash"
echo ""
echo "# Install tfenv:"
echo "git clone https://github.com/tfutils/tfenv.git ~/.tfenv"
echo "sudo ln -s ~/.tfenv/bin/* /usr/local/bin"
echo ""
echo "# Install Python and set up Ansible environment:"
echo "pyenv install 3.11.5"
echo "pyenv virtualenv ansible-env-epam"
echo "pyenv activate ansible-env-epam  # or 'pyenv local ansible-env-epam'"
echo "pip install ansible"
echo ""
echo "# Install Terraform with tfenv:"
echo "tfenv install 1.9.5"
echo "tfenv use 1.9.5"
echo ""
echo "# Install cloud CLIs (choose one or all):"
echo "# For AWS:"
echo "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'"
echo "unzip awscliv2.zip"
echo "sudo ./awscliv2/install"
echo ""
echo "# For Azure:"
echo "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
echo ""
echo "# For Google Cloud:"
echo "sudo apt install apt-transport-https ca-certificates gnupg"
echo "echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main' | \\"
echo "    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list"
echo "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -"
echo "sudo apt update && sudo apt install google-cloud-cli"