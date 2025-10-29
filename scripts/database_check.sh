#!/bin/bash

# Database-specific Health Check Script
# This script focuses only on database connectivity and schema validation

set -e  # Exit on any error

echo "==========================================="
echo "Database Health Check for Movie Analyst Application"
echo "==========================================="

# Define constants
PROJECT_ID="${PROJECT_ID:-epamgcpdeployment2}"
BACKEND_VM_NAME="backend-qa"
ZONE="us-central1-a"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if required commands exist
if ! command_exists gcloud; then
    log "ERROR: gcloud command not found. Please install Google Cloud SDK."
    exit 1
fi

# Note: MySQL client is required on the target backend instance, not necessarily on the local machine
# The actual database connectivity check will be performed via SSH on the backend instance

# 1. Check if Cloud SQL Proxy on backend is running
log "1. Checking if Cloud SQL Proxy is running on backend..."
if gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo systemctl is-active cloud-sql-proxy" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null | grep -q "active"; then
    log "✓ Cloud SQL Proxy is running on backend"
else
    log "✗ Cloud SQL Proxy is NOT running on backend"
    exit 1
fi

# 2. Check database connectivity from backend
log "2. Testing database connectivity from backend..."
# Extract the password from the env file using more robust method to handle special characters
DB_PASSWORD=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo grep DB_PASSWORD /opt/movie-analyst/movie-analyst-api/movie-analyst-api/.env | cut -d '=' -f 2-" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null | tr -d '\r\n')
DB_TEST=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u app_user -p'$DB_PASSWORD' -e 'USE movie_db; SELECT COUNT(*) FROM movies LIMIT 1;'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "error")
if echo "$DB_TEST" | grep -q "SELECT COUNT(*) FROM movies LIMIT 1" && ! echo "$DB_TEST" | grep -q "error"; then
    log "✓ Backend can connect to database"
else
    log "✗ Backend cannot connect to database"
    log "  Troubleshooting tips:"
    log "  - Check if the database initialization workflow (2.8.5-database-initialization.yml) has been run"
    log "  - Verify the database password in /opt/movie-analyst/movie-analyst-api/movie-analyst-api/.env"
    log "  - Confirm the Cloud SQL Proxy is properly configured and running"
    log "  - Check app_user permissions on the database"
    exit 1
fi

# 3. Check if database tables exist and are populated
log "3. Checking if database tables exist and are populated..."
TABLES_EXIST=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u app_user -p'$DB_PASSWORD' -e 'USE movie_db; SHOW TABLES;'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "error")

if echo "$TABLES_EXIST" | grep -q "Tables_in_movie_db" && echo "$TABLES_EXIST" | grep -q -E "(movies|publications|reviewers)"; then
    log "✓ Required database tables exist"
    
    # Check if tables are populated with data
    MOVIES_COUNT=$(echo "$TABLES_EXIST" | grep -q "movies" && gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u app_user -p'$DB_PASSWORD' -e 'USE movie_db; SELECT COUNT(*) FROM movies;'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "0")
    
    if [ "$MOVIES_COUNT" -gt 0 ]; then
        log "✓ Database tables are populated with data (movies count: $MOVIES_COUNT)"
    else
        log "! Database tables exist but might be empty"
    fi
else
    log "✗ Required database tables are missing"
    log "  This indicates the database initialization workflow (2.8.5-database-initialization.yml) has not been run yet"
    log "  Run this workflow to execute seeds.js and create the required tables and data"
    exit 1
fi

# 4. Check if the schema initialization has been run by checking for expected data
log "4. Checking if database schema initialization has been completed properly..."
EXPECTED_DATA_CHECK=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u app_user -p'$DB_PASSWORD' -e 'USE movie_db; SELECT COUNT(*) AS total_movies FROM movies; SELECT COUNT(*) AS total_publications FROM publications; SELECT COUNT(*) AS total_reviewers FROM reviewers;'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "error")

if echo "$EXPECTED_DATA_CHECK" | grep -q -E -i "(total_movies|total_publications|total_reviewers|total)" && ! echo "$EXPECTED_DATA_CHECK" | grep -q -i "ERROR"; then
    MOVIES_COUNT=$(echo "$EXPECTED_DATA_CHECK" | grep -E "^[0-9]+$" | head -n 1)
    PUBLICATIONS_COUNT=$(echo "$EXPECTED_DATA_CHECK" | grep -E "^[0-9]+$" | sed -n '2p')
    REVIEWERS_COUNT=$(echo "$EXPECTED_DATA_CHECK" | grep -E "^[0-9]+$" | sed -n '3p')
    
    log "✓ Schema initialization validated (Movies: $MOVIES_COUNT, Publications: $PUBLICATIONS_COUNT, Reviewers: $REVIEWERS_COUNT)"
    
    # Check if the data looks like it was properly initialized by seeds.js
    if [ "$MOVIES_COUNT" -gt 0 ] && [ "$PUBLICATIONS_COUNT" -gt 0 ] && [ "$REVIEWERS_COUNT" -gt 0 ]; then
        log "✓ Database contains expected initial data from schema initialization"
    else
        log "! Database tables exist but expected initial data is missing"
    fi
else
    log "✗ Database schema initialization validation failed"
    exit 1
fi

# 5. Run a test query to verify the database is fully functional
log "5. Testing database functionality with sample query..."
SAMPLE_QUERY=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u app_user -p'$DB_PASSWORD' -e 'USE movie_db; SELECT title, score FROM movies LIMIT 1;'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "error")

if echo "$SAMPLE_QUERY" | grep -q "title\|score" && ! echo "$SAMPLE_QUERY" | grep -q -i "error"; then
    log "✓ Database is fully functional and accessible"
else
    log "✗ Database test query failed"
    exit 1
fi

echo ""
log "==========================================="
log "DATABASE CHECKS PASSED! Database is healthy."
log "==========================================="
log "The database is properly configured and ready for the application."
log "==========================================="

exit 0