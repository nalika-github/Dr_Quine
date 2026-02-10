#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Dr_Quine - C Testing Suite${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Build all programs
echo -e "${YELLOW}Building all programs...${NC}"
make fclean > /dev/null 2>&1
make > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Build successful${NC}"
echo ""

# Test 1: Colleen
echo -e "${BLUE}[1/3] Testing Colleen.c${NC}"
echo -e "      ${YELLOW}→ Colleen should print itself${NC}"
./exc/Colleen > tmp_Colleen 2>/dev/null
diff src/Colleen.c tmp_Colleen > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "      ${GREEN}✓ PASS${NC} - Output matches source file"
    ((PASSED++))
else
    echo -e "      ${RED}✗ FAIL${NC} - Output differs from source"
    echo -e "      Run: ${YELLOW}diff src/Colleen.c tmp_Colleen${NC}"
    ((FAILED++))
fi
rm -f tmp_Colleen
echo ""

# Test 2: Grace
echo -e "${BLUE}[2/3] Testing Grace.c${NC}"
echo -e "      ${YELLOW}→ Grace should create Grace_kid.c${NC}"
rm -f Grace_kid.c
./exc/Grace > /dev/null 2>&1
if [ ! -f Grace_kid.c ]; then
    echo -e "      ${RED}✗ FAIL${NC} - Grace_kid.c not created"
    ((FAILED++))
else
    diff src/Grace.c Grace_kid.c > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "      ${GREEN}✓ PASS${NC} - Grace_kid.c is identical to Grace.c"
        ((PASSED++))
    else
        echo -e "      ${RED}✗ FAIL${NC} - Grace_kid.c differs from Grace.c"
        echo -e "      Run: ${YELLOW}diff src/Grace.c Grace_kid.c${NC}"
        ((FAILED++))
    fi
fi
rm -f Grace_kid.c
echo ""

# Test 3: Sully
echo -e "${BLUE}[3/3] Testing Sully.c${NC}"
echo -e "      ${YELLOW}→ Sully should create Sully_4.c to Sully_0.c${NC}"
rm -f Sully_*.c Sully_[0-9]
./exc/Sully > /dev/null 2>&1

# Wait for all processes to complete
sleep 1
killall -9 Sully_4 Sully_3 Sully_2 Sully_1 Sully_0 2>/dev/null

# Check if required files exist
SULLY_PASS=true
for i in 4 3 2 1 0; do
    if [ ! -f "Sully_$i.c" ]; then
        echo -e "      ${RED}✗ FAIL${NC} - Sully_$i.c not found"
        SULLY_PASS=false
    fi
done

if [ "$SULLY_PASS" = true ]; then
    # Check i values
    I_VALUES_OK=true
    for i in 4 3 2 1 0; do
        if ! grep -q "int i = $i" "Sully_$i.c"; then
            echo -e "      ${RED}✗ FAIL${NC} - Sully_$i.c has wrong i value"
            I_VALUES_OK=false
        fi
    done
    
    # Check that Sully_0 was not compiled
    if [ -f "Sully_0" ]; then
        echo -e "      ${RED}✗ FAIL${NC} - Sully_0 should not be compiled"
        I_VALUES_OK=false
    fi
    
    if [ "$I_VALUES_OK" = true ]; then
        echo -e "      ${GREEN}✓ PASS${NC} - All Sully files created correctly"
        echo -e "      ${GREEN}✓ PASS${NC} - i values: 4 → 3 → 2 → 1 → 0"
        echo -e "      ${GREEN}✓ PASS${NC} - Sully_0 not compiled (correct)"
        ((PASSED++))
    else
        ((FAILED++))
    fi
else
    ((FAILED++))
fi

# Cleanup
rm -f Sully_*.c Sully_[0-9]
echo ""

# Summary
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "Passed: ${GREEN}$PASSED${NC}/3"
echo -e "Failed: ${RED}$FAILED${NC}/3"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${NC}"
    exit 1
fi
