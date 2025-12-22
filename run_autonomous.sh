#!/bin/bash

# Simple autonomous trading launcher
# Just ensures bot is running and shows the prompt to paste

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Prophet Autonomous Trading${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check/start trading bot
if lsof -Pi :4534 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Trading bot running on port 4534${NC}"
else
    echo -e "${YELLOW}Starting Go trading bot...${NC}"
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
    ALPACA_API_KEY=${ALPACA_API_KEY:-$ALPACA_PUBLIC_KEY} \
    ALPACA_SECRET_KEY=${ALPACA_SECRET_KEY} \
    nohup ./prophet_bot > trading_bot.log 2>&1 &
    echo $! > trading_bot.pid
    sleep 5
    echo -e "${GREEN}✓ Trading bot started${NC}"
fi

echo ""
echo -e "${GREEN}System Ready!${NC}"
echo ""
echo "Cash: $(curl -s http://localhost:4534/api/v1/account | grep -o '"Cash":[0-9.]*' | cut -d: -f2)"
echo "Buying Power: $(curl -s http://localhost:4534/api/v1/account | grep -o '"BuyingPower":[0-9.]*' | cut -d: -f2)"
echo ""
echo -e "${YELLOW}To run autonomous trading, paste this prompt in Claude:${NC}"
echo ""
cat autonomous_trading_prompt.txt
