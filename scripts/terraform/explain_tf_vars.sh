#!/bin/bash

# explain_tf_vars.sh - Explain Terraform variable precedence

echo "Terraform Variable Precedence (highest to lowest):"
echo "=================================================="
echo "1. Command-line variables (-var and -var-file)"
echo "2. Environment variables (TF_VAR_name)"
echo "3. terraform.tfvars file"
echo "4. *.auto.tfvars files"
echo "5. Variable defaults in variables.tf"

echo ""
echo "In this project:"
echo "==============="
echo "- variables.tf defines the variable 'project_id' with a default value of 'epamgcpdeployment2'"
echo "- terraform.tfvars no longer specifies project_id, so Terraform uses the default"
echo "- This reduces the chance of mismatches between configurations"