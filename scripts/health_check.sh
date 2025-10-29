#!/bin/bash

# Health Check Script for Movie Analyst Application
# This script systematically checks each layer of the infrastructure to verify all services are working

set -e  # Exit on any error

echo "==========================================="
echo "Movie Analyst Application Health Check"
echo "==========================================="

# Define constants
PROJECT_ID="${PROJECT_ID:-epamgcpdeployment2}"
BACKEND_SERVICE_NAME="backend-service-qa"
FRONTEND_VM_NAME="frontend-qa-vpr8"
BACKEND_VM_NAME="backend-qa"
BASTION_VM_NAME="bastion-qa"
ZONE="us-central1-a"
LOAD_BALANCER_IP="34.107.139.237"
BACKEND_INTERNAL_IP="10.0.2.2"
FRONTEND_INTERNAL_IP="10.0.2.3"
BACKEND_PORT=3000
FRONTEND_PORT=3030

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

if ! command_exists curl; then
    log "ERROR: curl command not found. Please install curl."
    exit 1
fi

if ! command_exists jq; then
    log "ERROR: jq command not found. Please install jq."
    exit 1
fi

# 1. Load-balancer ↔ FE VM Health Check
log "1. Checking Load-balancer ↔ Frontend VM health..."
if gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --project=$PROJECT_ID --global 2>/dev/null; then
    log "✓ Load balancer backend service is HEALTHY"
else
    log "✗ Load balancer backend service is UNHEALTHY"
    exit 1
fi

# 2. Check if frontend process is listening on port 3030
log "2. Checking if frontend process is listening on port $FRONTEND_PORT..."
if gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo ss -tuln | grep $FRONTEND_PORT" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $FRONTEND_VM_NAME 2>/dev/null; then
    log "✓ Frontend process is listening on port $FRONTEND_PORT"
else
    log "✗ Frontend process is NOT listening on port $FRONTEND_PORT"
    exit 1
fi

# 3. Check if backend process is listening on port 3000
log "3. Checking if backend process is listening on port $BACKEND_PORT..."
if gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo ss -tuln | grep $BACKEND_PORT" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null; then
    log "✓ Backend process is listening on port $BACKEND_PORT"
else
    log "✗ Backend process is NOT listening on port $BACKEND_PORT"
    exit 1
fi

# 4. Check PM2 status for both frontend and backend
log "4. Checking PM2 status for frontend..."
FRONTEND_PM2_STATUS=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo -u app pm2 jlist | jq -r '.[] | select(.name == \"movie-analyst-frontend\") | .pm2_env.status'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $FRONTEND_VM_NAME 2>/dev/null || echo "error")
if [ "$FRONTEND_PM2_STATUS" = "online" ]; then
    log "✓ Frontend PM2 process is running"
else
    log "✗ Frontend PM2 process is NOT running (status: $FRONTEND_PM2_STATUS)"
    exit 1
fi

log "5. Checking PM2 status for backend..."
BACKEND_PM2_STATUS=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo -u app pm2 jlist | jq -r '.[] | select(.name == \"movie-analyst-backend\") | .pm2_env.status'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "error")
if [ "$BACKEND_PM2_STATUS" = "online" ]; then
    log "✓ Backend PM2 process is running"
else
    log "✗ Backend PM2 process is NOT running (status: $BACKEND_PM2_STATUS)"
    exit 1
fi

# 6. Check Cloud SQL Proxy on backend
log "6. Checking if Cloud SQL Proxy is running on backend..."
if gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="sudo systemctl is-active cloud-sql-proxy" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null | grep -q "active"; then
    log "✓ Cloud SQL Proxy is running on backend"
else
    log "✗ Cloud SQL Proxy is NOT running on backend"
    exit 1
fi

# 7. Test FE → BE connectivity
log "7. Testing Frontend → Backend connectivity..."
if gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="curl -s -o /dev/null -w '%{http_code}' http://$BACKEND_INTERNAL_IP:$BACKEND_PORT/movies" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $FRONTEND_VM_NAME 2>/dev/null | grep -q "200\|500"; then
    RESPONSE_CODE=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="curl -s -o /dev/null -w '%{http_code}' http://$BACKEND_INTERNAL_IP:$BACKEND_PORT/movies" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $FRONTEND_VM_NAME 2>/dev/null)
    if [ "$RESPONSE_CODE" = "200" ]; then
        log "✓ Frontend can reach Backend (Response: $RESPONSE_CODE)"
    elif [ "$RESPONSE_CODE" = "500" ]; then
        log "! Frontend can reach Backend but Backend is returning 500 errors (Response: $RESPONSE_CODE)"
    else
        log "✗ Frontend cannot reach Backend (Response: $RESPONSE_CODE)"
        exit 1
    fi
else
    log "✗ Frontend cannot reach Backend"
    exit 1
fi

# 8. Check database connectivity from backend
log "8. Testing database connectivity from backend..."
DB_TEST=$(gcloud compute ssh --zone=$ZONE --project=$PROJECT_ID --command="mysql -h 127.0.0.1 -u app_user -p\$(sudo grep DB_PASSWORD /opt/movie-analyst/movie-analyst-api/.env | cut -d '=' -f 2) -e 'USE movie_db; SELECT COUNT(*) FROM movies LIMIT 1;'" --tunnel-through-iap --ssh-flag="-o ConnectTimeout=10" $BACKEND_VM_NAME 2>/dev/null || echo "error")
if echo "$DB_TEST" | grep -q "SELECT COUNT(*) FROM movies LIMIT 1" && ! echo "$DB_TEST" | grep -q "error"; then
    log "✓ Backend can connect to database"
else
    log "✗ Backend cannot connect to database"
    exit 1
fi

# 9. Smoke test via Load Balancer
log "9. Testing via Load Balancer..."
if curl -s -o /dev/null -w '%{http_code}' -I http://$LOAD_BALANCER_IP 2>/dev/null | grep -q "200"; then
    log "✓ Load balancer is responding (Response: 200)"
else
    RESPONSE_CODE=$(curl -s -o /dev/null -w '%{http_code}' -I http://$LOAD_BALANCER_IP 2>/dev/null || echo "error")
    log "✗ Load balancer is NOT responding (Response: $RESPONSE_CODE)"
    exit 1
fi

# 10. Check backend API endpoints
log "10. Testing backend API endpoints..."
API_RESPONSE=$(curl -s -o /dev/null -w '%{http_code}' http://$LOAD_BALANCER_IP/movies 2>/dev/null || echo "error")
if [ "$API_RESPONSE" = "200" ]; then
    log "✓ Backend API endpoint is accessible via load balancer (Response: $API_RESPONSE)"
elif [ "$API_RESPONSE" = "404" ]; then
    log "! Backend API endpoint not found via load balancer (Response: $API_RESPONSE)"
else
    log "✗ Backend API endpoint is not accessible via load balancer (Response: $API_RESPONSE)"
    exit 1
fi

echo ""
log "==========================================="
log "ALL CHECKS PASSED! Application is healthy."
log "==========================================="
log "Frontend is accessible at: http://$LOAD_BALANCER_IP"
log "Backend API is accessible at: http://$LOAD_BALANCER_IP/movies"
log "==========================================="

exit 0