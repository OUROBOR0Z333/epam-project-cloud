#!/bin/bash

# Script to verify service accounts and OS Login configuration for application deployment

set -e  # Exit on any error

echo "Verifying service accounts and OS Login configuration..."

# Check if required environment variables are set
if [ -z "$GCP_PROJECT_ID" ] || [ -z "$GCP_ZONE" ]; then
    echo "Error: GCP_PROJECT_ID and GCP_ZONE must be set as environment variables"
    exit 1
fi

echo "Project ID: $GCP_PROJECT_ID"
echo "Zone: $GCP_ZONE"

# Check if gcloud is available
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not available"
    exit 1
fi

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    echo "Error: terraform CLI is not available"
    exit 1
fi

# Verify service accounts exist
echo ""
echo "Checking for service accounts..."

# Check for app service account
APP_SA_NAME="app-sa-qa@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
APP_SA_EXISTS=$(gcloud iam service-accounts describe "$APP_SA_NAME" --project="$GCP_PROJECT_ID" >/dev/null 2>&1 && echo "exists" || echo "not found")

if [ "$APP_SA_EXISTS" = "not found" ]; then
    echo "App service account not found: $APP_SA_NAME"
    # Try to find with terraform output
    cd terraform
    terraform init
    terraform workspace select qa 2>/dev/null || terraform workspace new qa
    APP_SA_OUTPUT=$(terraform output -raw app_service_account 2>/dev/null || echo "")
    cd ..
    if [ -n "$APP_SA_OUTPUT" ]; then
        APP_SA_NAME="$APP_SA_OUTPUT"
        echo "Found app service account from terraform output: $APP_SA_NAME"
    else
        echo "No app service account found in terraform outputs"
        exit 1
    fi
else
    echo "App service account found: $APP_SA_NAME"
fi

# Check for bastion service account
BASTION_SA_NAME="bastion-sa-qa@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
BASTION_SA_EXISTS=$(gcloud iam service-accounts describe "$BASTION_SA_NAME" --project="$GCP_PROJECT_ID" >/dev/null 2>&1 && echo "exists" || echo "not found")

if [ "$BASTION_SA_EXISTS" = "not found" ]; then
    echo "Bastion service account not found: $BASTION_SA_NAME"
    # Try to find with terraform output
    cd terraform
    BASTION_SA_OUTPUT=$(terraform output -raw bastion_service_account 2>/dev/null || echo "")
    cd ..
    if [ -n "$BASTION_SA_OUTPUT" ]; then
        BASTION_SA_NAME="$BASTION_SA_OUTPUT"
        echo "Found bastion service account from terraform output: $BASTION_SA_NAME"
    else
        echo "No bastion service account found in terraform outputs"
        exit 1
    fi
else
    echo "Bastion service account found: $BASTION_SA_NAME"
fi

# Check if OS Login is enabled
echo ""
echo "Checking if OS Login is enabled for the project..."
OS_LOGIN_ENABLED=$(gcloud compute project-info describe --project="$GCP_PROJECT_ID" --format="value(commonInstanceMetadata.items.enable-oslogin)" 2>/dev/null)
if [ "$OS_LOGIN_ENABLED" = "TRUE" ] || [ "$OS_LOGIN_ENABLED" = "true" ]; then
    echo "OS Login is enabled for the project"
else
    echo "Warning: OS Login may not be enabled for the project"
    echo "This could prevent SSH access to instances using service accounts"
fi

# Check instances and their service accounts
echo ""
echo "Checking instances and their assigned service accounts..."

# Check bastion instance
BASTION_INSTANCE_NAME="bastion-qa"
BASTION_EXISTS=$(gcloud compute instances describe "$BASTION_INSTANCE_NAME" --zone="$GCP_ZONE" --project="$GCP_PROJECT_ID" >/dev/null 2>&1 && echo "exists" || echo "not found")

if [ "$BASTION_EXISTS" = "exists" ]; then
    BASTION_SA_FROM_INSTANCE=$(gcloud compute instances describe "$BASTION_INSTANCE_NAME" --zone="$GCP_ZONE" --project="$GCP_PROJECT_ID" --format="value(serviceAccounts[0].email)")
    echo "Bastion instance ($BASTION_INSTANCE_NAME) is assigned service account: $BASTION_SA_FROM_INSTANCE"
    if [ "$BASTION_SA_FROM_INSTANCE" = "$BASTION_SA_NAME" ]; then
        echo "✓ Service account assignment is correct"
    else
        echo "⚠ Service account assignment mismatch"
    fi
else
    echo "Bastion instance not found: $BASTION_INSTANCE_NAME"
fi

# Check backend instance
BACKEND_INSTANCE_NAME="backend-qa"
BACKEND_EXISTS=$(gcloud compute instances describe "$BACKEND_INSTANCE_NAME" --zone="$GCP_ZONE" --project="$GCP_PROJECT_ID" >/dev/null 2>&1 && echo "exists" || echo "not found")

if [ "$BACKEND_EXISTS" = "exists" ]; then
    BACKEND_SA_FROM_INSTANCE=$(gcloud compute instances describe "$BACKEND_INSTANCE_NAME" --zone="$GCP_ZONE" --project="$GCP_PROJECT_ID" --format="value(serviceAccounts[0].email)")
    echo "Backend instance ($BACKEND_INSTANCE_NAME) is assigned service account: $BACKEND_SA_FROM_INSTANCE"
    if [ "$BACKEND_SA_FROM_INSTANCE" = "$APP_SA_NAME" ]; then
        echo "✓ Service account assignment is correct"
    else
        echo "⚠ Service account assignment mismatch"
    fi
else
    echo "Backend instance not found: $BACKEND_INSTANCE_NAME"
fi

# Check if compute instances API is enabled
echo ""
echo "Checking if required APIs are enabled..."
REQUIRED_APIS=("compute.googleapis.com" "iam.googleapis.com" "oslogin.googleapis.com")
for api in "${REQUIRED_APIS[@]}"; do
    if gcloud services list --project="$GCP_PROJECT_ID" --filter="$api" | grep -q "$api"; then
        echo "✓ $api is enabled"
    else
        echo "⚠ $api is not enabled"
    fi
done

echo ""
echo "Service account verification complete."
echo "If all checks passed, your infrastructure is properly configured for application deployment."