#!/usr/bin/env bash
#
# deploy-new-firebase.sh - Deploy MultiFi Hub to a new Firebase project
#
# Usage:
#   ./scripts/deploy-new-firebase.sh [OPTIONS]
#
# Options:
#   --firebase-project PROJECT_ID   Firebase project ID (required)
#   --nexus-url URL                 Nexus server URL (default: https://nexus-server.multifi.ai)
#   --build-only                    Only build, don't deploy
#   --help                          Show this help message

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Default values
FIREBASE_PROJECT=""
NEXUS_URL="https://nexus-server.multifi.ai"
BUILD_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --firebase-project)
            FIREBASE_PROJECT="$2"
            shift 2
            ;;
        --nexus-url)
            NEXUS_URL="$2"
            shift 2
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --help|-h)
            grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate
if [[ -z "$FIREBASE_PROJECT" && "$BUILD_ONLY" == false ]]; then
    echo -e "${RED}Error: --firebase-project is required for deployment${NC}"
    echo ""
    echo "Usage:"
    echo "  ./scripts/deploy-new-firebase.sh --firebase-project YOUR_PROJECT_ID"
    echo ""
    echo "To find your project ID:"
    echo "  1. Go to https://console.firebase.google.com/"
    echo "  2. Select your project"
    echo "  3. Project ID is shown in project settings"
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploy MultiFi Hub to Firebase${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Configuration:"
echo "  Nexus Server URL: $NEXUS_URL"
if [[ -n "$FIREBASE_PROJECT" ]]; then
    echo "  Firebase Project: $FIREBASE_PROJECT"
fi
echo ""

# Check if Firebase is logged in
if ! firebase projects:list &>/dev/null; then
    echo -e "${YELLOW}Firebase not authenticated. Please run:${NC}"
    echo "  firebase login"
    exit 1
fi

# Update .firebaserc if deploying
if [[ "$BUILD_ONLY" == false && -n "$FIREBASE_PROJECT" ]]; then
    echo -e "${BLUE}Configuring Firebase project...${NC}"
    
    # Create or update .firebaserc
    if [[ -f .firebaserc ]]; then
        # Update existing file
        cat > .firebaserc <<EOF
{
  "projects": {
    "default": "$FIREBASE_PROJECT"
  }
}
EOF
    else
        # Create new file
        cat > .firebaserc <<EOF
{
  "projects": {
    "default": "$FIREBASE_PROJECT"
  }
}
EOF
    fi
    echo -e "${GREEN}✓ Firebase project configured${NC}"
fi

# Build with environment variables
echo -e "${BLUE}Building frontend with Nexus URL: $NEXUS_URL${NC}"
export VITE_NEXUS_API_URL="$NEXUS_URL"
export VITE_NEXUS_SERVER_URL="$NEXUS_URL"
export VITE_API_URL="$NEXUS_URL"

npm run build

if [[ $? -ne 0 ]]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build successful${NC}"

# Deploy to Firebase
if [[ "$BUILD_ONLY" == false ]]; then
    echo -e "${BLUE}Deploying to Firebase...${NC}"
    firebase deploy --only hosting --project "$FIREBASE_PROJECT"

    if [[ $? -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Deployment Complete!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo "Frontend URL: https://${FIREBASE_PROJECT}.web.app"
        echo "Nexus Server: $NEXUS_URL"
        echo ""
        echo "To set up custom domain (nexus.multifi.ai):"
        echo "  1. Go to Firebase Console → Hosting"
        echo "  2. Click 'Add custom domain'"
        echo "  3. Enter: nexus.multifi.ai"
        echo "  4. Update DNS CNAME to point to ${FIREBASE_PROJECT}.web.app"
        echo ""
    else
        echo -e "${RED}✗ Deployment failed${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${GREEN}Build complete!${NC}"
    echo "Build output: dist/"
    echo "To deploy manually:"
    echo "  firebase deploy --only hosting --project $FIREBASE_PROJECT"
    echo ""
fi
