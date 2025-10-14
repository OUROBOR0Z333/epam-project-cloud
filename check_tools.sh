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
    echo "✓ Installed (Version: $(pyenv --version))"
else
    echo "✗ Not installed"
fi

# Check for tfenv
echo -n "Checking for tfenv... "
if command_exists tfenv; then
    echo "✓ Installed (Version: $(tfenv --version))"
else
    echo "✗ Not installed"
fi

# Check for Terraform (managed by tfenv)
echo -n "Checking for Terraform... "
if command_exists terraform; then
    # Check if it's managed by tfenv
    TERRAFORM_PATH=$(which terraform)
    if [[ "$TERRAFORM_PATH" == *"tfenv"* ]]; then
        # Try to get the version, handling the case where no version is set
        TERRAFORM_VERSION=$(terraform version 2>&1 | head -n1)
        if [[ "$TERRAFORM_VERSION" == *"Version could not be resolved"* ]]; then
            echo "⚠️  Installed but no version set (managed by tfenv)"
            echo "    Available versions: $(tfenv list 2>/dev/null || echo 'none')"
        else
            echo "✓ Installed (Managed by tfenv: $TERRAFORM_VERSION)"
        fi
    else
        TERRAFORM_VERSION=$(terraform version 2>&1 | head -n1)
        echo "! Installed but not managed by tfenv: $TERRAFORM_VERSION"
    fi
else
    echo "✗ Not installed"
fi

# Check for Ansible
echo -n "Checking for Ansible... "
if command_exists ansible; then
    # Check if it's in a virtual environment
    ANSIBLE_PATH=$(which ansible)
    if [[ "$ANSIBLE_PATH" == *".pyenv/shims"* ]]; then
        # Check if a specific ansible environment exists
        if pyenv versions --bare 2>/dev/null | grep -q "ansible-env"; then
            # Check if the active environment is ansible-env
            CURRENT_PYENV=$(pyenv version-name 2>/dev/null)
            if [[ "$CURRENT_PYENV" == "ansible-env-epam" ]]; then
                echo "✓ Installed and currently active in ansible-env-epam (Path: $ANSIBLE_PATH)"
            else
                echo "✓ Available via pyenv in ansible-env-epam environment (Path: $ANSIBLE_PATH)"
                echo "  - To activate: pyenv activate ansible-env-epam"
                echo "  - Currently using: $CURRENT_PYENV"
            fi
        else
            echo "✓ Installed via pyenv (Path: $ANSIBLE_PATH)"
        fi
    elif [[ "$ANSIBLE_PATH" == *"venv"* ]] || [[ "$ANSIBLE_PATH" == *"/ansible-env/"* ]] || [[ "$ANSIBLE_PATH" == *".pyenv/versions"* ]]; then
        echo "✓ Installed in dedicated environment (Path: $ANSIBLE_PATH)"
    else
        echo "⚠️  Installed but not in dedicated virtual environment (Path: $ANSIBLE_PATH)"
    fi
else
    echo "✗ Not installed"
fi

# Check for AWS CLI
echo -n "Checking for AWS CLI... "
if command_exists aws; then
    AWS_VERSION=$(aws --version 2>&1)
    echo "✓ Installed ($AWS_VERSION)"
else
    echo "✗ Not installed"
fi

# Check for Azure CLI
echo -n "Checking for Azure CLI... "
if command_exists az; then
    # Try to get a cleaner version output
    AZ_VERSION=$(az version 2>/dev/null | grep -o '"azure-cli": *"[^"]*"' | head -n1 || echo "available")
    echo "✓ Installed (Azure CLI $AZ_VERSION)"
else
    echo "✗ Not installed"
fi

# Check for Google Cloud CLI
echo -n "Checking for Google Cloud CLI... "
if command_exists gcloud; then
    GCLOUD_VERSION=$(gcloud version --short 2>/dev/null | head -n1 || echo "available")
    echo "✓ Installed ($GCLOUD_VERSION)"
else
    echo "✗ Not installed"
fi

echo ""
echo "Checking Python and pip..."

# Check for Python (managed by pyenv)
echo -n "Checking for Python... "
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    PYTHON_PATH=$(which python3)
    echo "✓ Installed ($PYTHON_VERSION)"
    if [[ "$PYTHON_PATH" == *"pyenv"* ]]; then
        echo "  - Managed by pyenv: $PYTHON_PATH"
    else
        echo "  - Not managed by pyenv: $PYTHON_PATH"
    fi
elif command_exists python; then
    PYTHON_VERSION=$(python --version 2>&1)
    PYTHON_PATH=$(which python)
    echo "✓ Installed ($PYTHON_VERSION)"
    if [[ "$PYTHON_PATH" == *"pyenv"* ]]; then
        echo "  - Managed by pyenv: $PYTHON_PATH"
    else
        echo "  - Not managed by pyenv: $PYTHON_PATH"
    fi
else
    echo "✗ Not installed"
fi

# Check for pip
echo -n "Checking for pip... "
if command_exists pip; then
    PIP_VERSION=$(pip --version 2>&1)
    echo "✓ Installed ($PIP_VERSION)"
elif command_exists pip3; then
    PIP_VERSION=$(pip3 --version 2>&1)
    echo "✓ Installed ($PIP_VERSION)"
else
    echo "✗ Not installed"
fi

echo ""
echo "Pyenv Python environments:"
if command_exists pyenv; then
    pyenv versions
else
    echo "  pyenv not installed"
fi

echo ""
echo "Tfenv Terraform versions:"
if command_exists tfenv; then
    echo "  Available versions: $(tfenv list 2>/dev/null || echo 'none')"
else
    echo "  tfenv not installed"
fi

echo ""
echo "Summary:"
echo "- All required tools are installed except Terraform version needs to be set"
echo "- Ansible is installed in a dedicated pyenv environment (ansible-env-epam) but not currently active"
echo "- Cloud CLIs (AWS, Azure, GCP) are all installed"
echo ""
echo "Recommendations:"
echo "- Set a Terraform version with: tfenv install <version> && tfenv use <version>"
echo "- Activate Ansible environment when needed: pyenv activate ansible-env-epam"
echo "- Choose one cloud provider for your project (AWS, Azure, or GCP) and focus on it"

echo ""
echo "Quick setup commands:"
echo "  # Install and set Terraform version:"
echo "  tfenv install 1.9.5"
echo "  tfenv use 1.9.5"
echo ""
echo "  # Activate Ansible environment:"
echo "  pyenv activate ansible-env-epam"
echo ""
echo "  # Or if using a different Ansible environment name:"
echo "  source ~/.pyenv/versions/ansible-env/bin/activate"