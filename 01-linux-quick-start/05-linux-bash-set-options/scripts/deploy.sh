#!/bin/bash
ENVIRONMENT=${1:-staging}
echo "🚀 Deploying to $ENVIRONMENT..."
sleep 2
echo "🌐 Updating load balancer..."
sleep 1
echo "✅ Deployment to $ENVIRONMENT completed!"
exit 0
