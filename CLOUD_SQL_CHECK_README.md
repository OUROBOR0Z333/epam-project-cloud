# Cloud SQL Health Check Script

This script specifically checks the Cloud SQL instance and validates that everything is properly configured in the Movie Analyst application infrastructure.

## Features

The Cloud SQL health check script performs the following checks:

1. **Cloud SQL Instance Status** - Verifies the Cloud SQL instance exists and is running
2. **Instance Configuration** - Checks region, tier, IP configuration
3. **Cloud SQL Proxy Status** - Ensures the proxy is running on the backend VM
4. **Database User Verification** - Confirms the application database user exists
5. **Application Database** - Verifies the application database exists
6. **Required Tables** - Checks that all required tables exist (movies, publications, reviewers)
7. **Table Data** - Verifies tables contain data
8. **User Access** - Tests that the app_user can access the database
9. **Backup Configuration** - Checks if automated backups are enabled

## Prerequisites

Before running this script, ensure you have:

- Google Cloud SDK installed and configured with appropriate permissions
- Proper authentication to access the GCP project (project ID: `epamgcpdeployment2`)
- Proper network access to connect to the VMs via IAP tunneling
- MySQL client installed on the target backend instance (not necessarily on the local machine)

## Usage

```bash
# Run the Cloud SQL health check
./scripts/cloud_sql_check.sh
```

## Output

The script will output the status of each check:
- `✓` indicates the check passed
- `⚠` indicates a warning (non-critical issue)
- `✗` indicates the check failed
- Additional information is provided for each check

If any critical check fails, the script will exit with status code 1.

## Integration with Infrastructure

This script is designed to work with the existing infrastructure:
- Checks the `movie-db-qa` Cloud SQL instance
- Connects through the backend VM (`backend-qa`)
- Uses the Cloud SQL Proxy configuration
- Validates the schema created by the database initialization workflow