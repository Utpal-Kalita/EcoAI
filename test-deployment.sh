#!/bin/bash

# EcoAI Deployment Test Script
# Tests all services and their endpoints

set -e

echo "🧪 EcoAI Deployment Test Suite"
echo "==============================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_endpoint() {
    SERVICE=$1
    URL=$2
    EXPECTED_STATUS=${3:-200}
    
    echo -n "Testing $SERVICE... "
    
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" 2>/dev/null || echo "000")
    
    if [ "$RESPONSE" = "$EXPECTED_STATUS" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $RESPONSE)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $RESPONSE, expected $EXPECTED_STATUS)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_json_response() {
    SERVICE=$1
    URL=$2
    EXPECTED_KEY=$3
    
    echo -n "Testing $SERVICE JSON response... "
    
    RESPONSE=$(curl -s "$URL" 2>/dev/null || echo "{}")
    
    if echo "$RESPONSE" | grep -q "$EXPECTED_KEY"; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo "  Response: $RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

test_post_endpoint() {
    SERVICE=$1
    URL=$2
    DATA=$3
    EXPECTED_KEY=$4
    
    echo -n "Testing $SERVICE POST... "
    
    RESPONSE=$(curl -s -X POST "$URL" \
        -H "Content-Type: application/json" \
        -d "$DATA" 2>/dev/null || echo "{}")
    
    if echo "$RESPONSE" | grep -q "$EXPECTED_KEY"; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo "  Response: $RESPONSE"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 5

# Test Backend
echo ""
echo "🔧 Testing Backend Service"
echo "-------------------------"
test_endpoint "Backend Health Check" "http://localhost:3001/health" 200
test_json_response "Backend Health Status" "http://localhost:3001/health" "status"

# Test Backend API with sample data
TEST_DATA='{"energy_kwh": 100, "miles_driven": 50, "meat_consumption": 5}'
test_post_endpoint "Backend Analyze Endpoint" "http://localhost:3001/analyze" "$TEST_DATA" "totalFootprint"

# Test AI Service
echo ""
echo "🤖 Testing AI Service"
echo "--------------------"
test_endpoint "AI Service Health Check" "http://localhost:8000/health" 200
test_json_response "AI Service Status" "http://localhost:8000/health" "status"
test_endpoint "AI Service Root" "http://localhost:8000/" 200

# Test Frontend
echo ""
echo "🎨 Testing Frontend"
echo "------------------"
test_endpoint "Frontend Homepage" "http://localhost:3000" 200

# Test Redis (if accessible)
echo ""
echo "💾 Testing Redis"
echo "---------------"
if command -v redis-cli &> /dev/null; then
    if redis-cli -h localhost -p 6379 ping > /dev/null 2>&1; then
        echo -e "Testing Redis... ${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "Testing Redis... ${YELLOW}⚠ SKIP${NC} (not accessible)"
    fi
else
    echo -e "Testing Redis... ${YELLOW}⚠ SKIP${NC} (redis-cli not installed)"
fi

# Summary
echo ""
echo "==============================="
echo "📊 Test Summary"
echo "==============================="
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo "Your EcoAI deployment is working correctly! 🎉"
    echo "Access the application at: http://localhost:3000"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo ""
    echo "Check the logs for more details:"
    echo "  docker-compose logs"
    exit 1
fi
