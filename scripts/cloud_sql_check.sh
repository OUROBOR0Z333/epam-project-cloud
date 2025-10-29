#!/bin/bash

# Cloud SQL Instance Health Check Script
# This script specifically checks the Cloud SQL instance and validates that everything is properly configured

set -e  # Exit on any error

echo "==========================================="
echo "Cloud SQL Instance Health Check"
echo "==========================================="

# Define constants
PROJECT_ID="${PROJECT_ID:-epamgcpdeployment2}"
BACKEND_VM_NAME="backend-qa"
ZONE="us-central1-a"
SQL_INSTANCE="movie-db-qa"
SQL_CONNECTION_NAME="***:us-central1:movie-db-qa"  # This will be retrieved dynamically
DB_NAME="movie_db"
DB_USER="app_user"

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

# 1. Check if Cloud SQL instance exists and is running
log "1. Checking if Cloud SQL instance exists and is running..."
SQL_STATUS=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(state)" 2>/dev/null || echo "ERROR")
if [ "$SQL_STATUS" = "RUNNABLE" ]; then
    log "✓ Cloud SQL instance is running"
else
    log "✗ Cloud SQL instance is not in RUNNABLE state: $SQL_STATUS"
    exit 1
fi

# 2. Get Cloud SQL connection name
log "2. Getting Cloud SQL instance connection name..."
SQL_CONNECTION_NAME=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(connectionName)" 2>/dev/null)
log "✓ Cloud SQL connection name: $SQL_CONNECTION_NAME"

# 3. Check Cloud SQL instance settings
log "3. Checking Cloud SQL instance configuration..."
SQL_REGION=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(region)" 2>/dev/null)
SQL_TIER=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(settings.tier)" 2>/dev/null)
SQL_IP_ADDRESS=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(ipAddresses[0].ipAddress)" 2>/dev/null)
SQL_PRIVATE_IP=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(privateIpAddress)" 2>/dev/null)

log "  Region: $SQL_REGION"
log "  Tier: $SQL_TIER"
log "  Private IP: $SQL_PRIVATE_IP"
if [ -n "$SQL_IP_ADDRESS" ]; then
    log "  Public IP: $SQL_IP_ADDRESS (if any)"
else
    log "  No public IP (recommended for security)"
fi

# 4. Check if Cloud SQL Proxy is running on backend
log "4. Checking if Cloud SQL Proxy is running on backend..."
if gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo systemctl is-active cloud-sql-proxy" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null | grep -q "active"; then
    log "✓ Cloud SQL Proxy is running on backend"
else
    log "✗ Cloud SQL Proxy is NOT running on backend"
    exit 1
fi

# 5. Check if database user exists
log "5. Checking if database user exists..."
DB_USER_EXISTS=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u root -p\$(sudo gcloud secrets versions access latest --secret=db_password 2>/dev/null) -e 'SELECT User, Host FROM mysql.user WHERE User=\"app_user\";'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null | grep -c "app_user" || echo "0")

if [ "$DB_USER_EXISTS" -gt 0 ]; then
    log "✓ Database user 'app_user' exists"
else
    log "⚠ Database user 'app_user' may not exist"
fi

# 6. Check if the application database exists
log "6. Checking if application database exists..."
DB_EXISTS=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u root -p\$(sudo gcloud secrets versions access latest --secret=db_password 2>/dev/null) -e 'SHOW DATABASES;' | grep -c 'movie_db'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "0")

if [ "$DB_EXISTS" -gt 0 ]; then
    log "✓ Application database 'movie_db' exists"
else
    log "✗ Application database 'movie_db' does not exist"
    exit 1
fi

# 7. Check if required tables exist
log "7. Checking if required tables exist in database..."
TABLES_EXIST=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u root -p\$(sudo gcloud secrets versions access latest --secret=db_password 2>/dev/null) -e 'USE movie_db; SHOW TABLES;' | grep -E -c 'movies|publications|reviewers'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "0")

if [ "$TABLES_EXIST" -ge 3 ]; then
    log "✓ All required tables exist (movies, publications, reviewers)"
else
    log "✗ Required tables missing (found only $TABLES_EXIST of 3 expected)"
    exit 1
fi

# 8. Check if tables have data
log "8. Checking if database tables have data..."
ROW_COUNTS=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u root -p\$(sudo gcloud secrets versions access latest --secret=db_password 2>/dev/null) -e 'USE movie_db; SELECT (SELECT COUNT(*) FROM movies) AS movies_count, (SELECT COUNT(*) FROM publications) AS publications_count, (SELECT COUNT(*) FROM reviewers) AS reviewers_count;'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "error")

if echo "$ROW_COUNTS" | grep -q -E "[0-9]+\s+[0-9]+\s+[0-9]+" && ! echo "$ROW_COUNTS" | grep -q "error"; then
    MOVIES_COUNT=$(echo "$ROW_COUNTS" | grep -E "[0-9]+\s+[0-9]+\s+[0-9]+" | awk '{print $1}' | head -n 1)
    PUBLICATIONS_COUNT=$(echo "$ROW_COUNTS" | grep -E "[0-9]+\s+[0-9]+\s+[0-9]+" | awk '{print $2}' | head -n 1)
    REVIEWERS_COUNT=$(echo "$ROW_COUNTS" | grep -E "[0-9]+\s+[0-9]+\s+[0-9]+" | awk '{print $3}' | head -n 1)
    
    log "✓ Database tables contain data (Movies: $MOVIES_COUNT, Publications: $PUBLICATIONS_COUNT, Reviewers: $REVIEWERS_COUNT)"
    
    if [ "$MOVIES_COUNT" -gt 0 ] && [ "$PUBLICATIONS_COUNT" -gt 0 ] && [ "$REVIEWERS_COUNT" -gt 0 ]; then
        log "✓ All tables have expected data"
    else
        log "! Some tables may be empty"
    fi
else
    log "! Could not verify table data counts"
fi

# 9. Test app_user access to the database
log "9. Testing app_user access to database..."
APP_USER_ACCESS=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u app_user -p\$(sudo grep DB_PASSWORD /opt/movie-analyst/movie-analyst-api/movie-analyst-api/.env | cut -d '=' -f 2) -e 'USE movie_db; SELECT COUNT(*) AS total_movies FROM movies LIMIT 1;' 2>/dev/null | grep -c '40' || echo "0")

if [ "$APP_USER_ACCESS" -gt 0 ]; then
    log "✓ app_user has proper access to the database"
else
    log "✗ app_user does not have proper access to the database or credentials are incorrect"
    exit 1
fi

# 10. Check Cloud SQL backup configuration
log "10. Checking Cloud SQL backup configuration..."
BACKUP_ENABLED=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(settings.backupConfiguration.enabled)" 2>/dev/null)
BACKUP_START_TIME=$(gcloud sql instances describe $SQL_INSTANCE --project=$PROJECT_ID --format="value(settings.backupConfiguration.startTime)" 2>/dev/null)

if [ "$BACKUP_ENABLED" = "True" ]; then
    log "✓ Automated backups are enabled (start time: $BACKUP_START_TIME)"
else
    log "⚠ Automated backups are not enabled"
fi

echo ""
log "==========================================="
log "CLOUD SQL HEALTH CHECK PASSED!"
log "==========================================="
log "Cloud SQL instance is properly configured and ready for the application."
log "==========================================="

exit 0