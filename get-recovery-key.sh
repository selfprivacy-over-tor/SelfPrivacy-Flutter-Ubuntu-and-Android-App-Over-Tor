#!/bin/bash
# Get .onion address and recovery key for SelfPrivacy Tor backend
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SECRETS_FILE="$SCRIPT_DIR/../Manager-Ubuntu-SelfPrivacy-Over-Alternative-Nets/backend/secrets.json"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no -o PreferredAuthentications=password"
SSH_PORT=2222

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get API token from secrets file or use default
if [ -f "$SECRETS_FILE" ]; then
    API_TOKEN=$(jq -r '.api.token // empty' "$SECRETS_FILE" 2>/dev/null)
fi
if [ -z "$API_TOKEN" ]; then
    API_TOKEN="test-token-for-tor-development"
fi

# Get .onion address from VM
echo -e "${CYAN}Getting .onion address from VM...${NC}"
ONION=$(sshpass -p '' ssh $SSH_OPTS -p $SSH_PORT root@localhost cat /var/lib/tor/hidden_service/hostname 2>/dev/null) || {
    echo -e "${RED}Error: Could not connect to VM. Is it running?${NC}"
    echo "Start the backend with: cd ../Manager-Ubuntu-SelfPrivacy-Over-Alternative-Nets/backend && ./build-and-run.sh"
    exit 1
}

# Validate .onion address
if [[ ! "$ONION" =~ ^[a-z2-7]{56}\.onion$ ]]; then
    echo -e "${RED}Error: Invalid .onion address: $ONION${NC}"
    exit 1
fi

echo -e "${GREEN}✓ .onion address: ${CYAN}$ONION${NC}"

# Generate recovery key via GraphQL API over Tor
echo -e "${CYAN}Generating recovery key via Tor...${NC}"
RESPONSE=$(curl -s --socks5-hostname 127.0.0.1:9050 \
    -X POST "http://$ONION/graphql" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_TOKEN" \
    -d '{"query": "mutation { api { getNewRecoveryApiKey { success message key } } }"}' \
    --max-time 120 2>/dev/null) || {
    echo -e "${RED}Error: Could not connect to backend via Tor${NC}"
    echo "Make sure Tor is running: ss -tlnp | grep 9050"
    exit 1
}

# Extract recovery key
RECOVERY_KEY=$(echo "$RESPONSE" | jq -r '.data.api.getNewRecoveryApiKey.key // empty' 2>/dev/null)

if [ -z "$RECOVERY_KEY" ]; then
    ERROR=$(echo "$RESPONSE" | jq -r '.errors[0].message // .data.api.getNewRecoveryApiKey.message // "Unknown error"' 2>/dev/null)
    echo -e "${RED}Error: Failed to generate recovery key: $ERROR${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Recovery key generated${NC}"
echo ""
echo -e "=========================================="
echo -e "${GREEN}Use these in the SelfPrivacy app:${NC}"
echo -e "=========================================="
echo ""
echo -e "Onion address:"
echo -e "  ${CYAN}$ONION${NC}"
echo ""
echo -e "Recovery key:"
echo -e "  ${CYAN}$RECOVERY_KEY${NC}"
echo ""
