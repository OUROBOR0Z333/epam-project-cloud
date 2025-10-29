# Health Check Script for Movie Analyst Application

This script systematically checks each layer of the Movie Analyst application infrastructure to verify that all services are working correctly.

## Features

The health check script performs the following checks:

1. **Load balancer ↔ Frontend VM health** - Verifies the load balancer can reach the frontend VM
2. **Frontend process listening** - Checks if the frontend process is listening on port 3030
3. **Backend process listening** - Checks if the backend process is listening on port 3000
4. **PM2 status** - Verifies that both frontend and backend services are running under PM2
5. **Application code verification** - Checks if application code is properly copied to instances
6. **Dependencies verification** - Ensures Node.js dependencies are installed for both apps
7. **Cloud SQL Proxy status** - Ensures the Cloud SQL Proxy is running on the backend VM
8. **Frontend ↔ Backend connectivity** - Tests if the frontend can reach the backend API
9. **Database connectivity** - Verifies the backend can connect to the database
10. **Load balancer accessibility** - Checks if the load balancer is responding
11. **Backend API endpoints** - Tests if backend API endpoints are accessible through the load balancer

## Prerequisites

Before running this script, ensure you have:

- Google Cloud SDK installed and configured with appropriate permissions
- Proper authentication to access the GCP project (project ID: `epamgcpdeployment2`)
- Proper network access to connect to the VMs via IAP tunneling

## Usage

```bash
# Run the health check
./scripts/health_check.sh
```

## Output

The script will output the status of each check:
- `✓` indicates the check passed
- `!` indicates a warning (service is up but may have issues)
- `✗` indicates the check failed

If any check fails, the script will exit with status code 1 and provide details about what went wrong.

## Troubleshooting

If the health check fails at any point, refer to the systematic checklist in the original documentation to identify and resolve specific issues. The script will indicate exactly where the failure occurred.