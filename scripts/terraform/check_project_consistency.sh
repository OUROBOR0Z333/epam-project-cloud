#!/bin/bash

# check_project_consistency.sh - Check if Terraform project configuration matches gcloud configuration

echo "Checking project configuration consistency..."

# Get the project ID from gcloud configuration
GCLOUD_PROJECT=$(gcloud config get-value project 2>/dev/null)

if [ -z "$GCLOUD_PROJECT" ]; then
    echo "❌ No project configured in gcloud"
    exit 1
fi

echo "✅ gcloud project: $GCLOUD_PROJECT"

# Check if we're in a directory with Terraform files
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ No terraform.tfvars file found in current directory"
    exit 1
fi

# Extract project_id from terraform.tfvars
TF_PROJECT=$(grep -E '^project_id\s*=' terraform.tfvars | sed -E 's/project_id\s*=\s*"([^"]+)".*/\1/')

if [ -z "$TF_PROJECT" ]; then
    echo "❌ No project_id found in terraform.tfvars"
    exit 1
fi

echo "✅ Terraform project: $TF_PROJECT"

# Compare the project IDs
if [ "$GCLOUD_PROJECT" != "$TF_PROJECT" ]; then
    echo "❌ MISMATCH: gcloud project ($GCLOUD_PROJECT) does not match Terraform project ($TF_PROJECT)"
    echo "   Please update terraform.tfvars to use the correct project ID."
    exit 1
else
    echo "✅ Project IDs match"
fi

# Check billing status
BILLING_STATUS=$(gcloud alpha billing projects describe $GCLOUD_PROJECT --format="value(billingEnabled)" 2>/dev/null)

if [ "$BILLING_STATUS" != "True" ]; then
    echo "❌ Billing is not enabled for project $GCLOUD_PROJECT"
    exit 1
else
    echo "✅ Billing is enabled for project $GCLOUD_PROJECT"
fi

echo "✅ All checks passed. Project configuration is consistent."