# Database Health Check Script

This script focuses specifically on checking the health of the database layer for the Movie Analyst application.

## Features

The database health check script performs the following checks:

1. **Cloud SQL Proxy status** - Ensures the Cloud SQL Proxy is running on the backend VM
2. **Database connectivity** - Verifies the backend can connect to the database
3. **Database schema verification** - Checks if database tables exist and are populated with data
4. **Schema initialization validation** - Confirms database contains expected initial data from seeds.js
5. **Database functionality test** - Runs a sample query to verify the database is fully functional

## Prerequisites

Before running this script, ensure you have:

- Google Cloud SDK installed and configured with appropriate permissions
- Proper authentication to access the GCP project (project ID: `epamgcpdeployment2`)
- Proper network access to connect to the VMs via IAP tunneling
- MySQL client installed on the system running the script

## Usage

```bash
# Run the database health check
./scripts/database_check.sh
```

## Output

The script will output the status of each check:
- `✓` indicates the check passed
- `✗` indicates the check failed
- Additional troubleshooting tips are provided when checks fail

If any check fails, the script will exit with status code 1 and provide details about what went wrong.

## Troubleshooting

This focused database check is particularly helpful for identifying database-related issues that appear as 500 errors in the full health check. 

If the database connectivity check fails, common causes include:
- Database initialization workflow not run (2.8.5-database-initialization.yml)
- Incorrect database credentials in the .env file
- Issues with the Cloud SQL Proxy configuration
- Database user permissions not properly set

## Integration with Database Initialization

If the database schema is missing, run the database initialization workflow:
- GitHub Actions workflow: `2.8.5-database-initialization.yml`
- This workflow executes the `seeds.js` script to create tables and populate initial data