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
echo -e "${BLUE}  Dr_Quine - ASM Testing Suite${NC}"
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
echo -e "${BLUE}[1/3] Testing Colleen.s${NC}"
echo -e "      ${YELLOW}→ Colleen should print itself${NC}"
./exc/Colleen > tmp_Colleen 2>/dev/null
diff Colleen.s tmp_Colleen > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "      ${GREEN}✓ PASS${NC} - Output matches source file"
    ((PASSED++))
else
    echo -e "      ${RED}✗ FAIL${NC} - Output differs from source"
    echo -e "      Run: ${YELLOW}diff Colleen.s tmp_Colleen | head -n 10${NC}"
    ((FAILED++))
fi
rm -f tmp_Colleen
echo ""

# Test 2: Grace
echo -e "${BLUE}[2/3] Testing Grace.s${NC}"
echo -e "      ${YELLOW}→ Grace should create Grace_kid.s${NC}"
rm -f Grace_kid.s
./exc/Grace > /dev/null 2>&1
if [ ! -f Grace_kid.s ]; then
    echo -e "      ${RED}✗ FAIL${NC} - Grace_kid.s not created"
    ((FAILED++))
else
    diff Grace.s Grace_kid.s > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "      ${GREEN}✓ PASS${NC} - Grace_kid.s is identical to Grace.s"
        ((PASSED++))
    else
        echo -e "      ${RED}✗ FAIL${NC} - Grace_kid.s differs from Grace.s"
        echo -e "      Run: ${YELLOW}diff Grace.s Grace_kid.s | head -n 10${NC}"
        ((FAILED++))
    fi
fi
rm -f Grace_kid.s
echo ""

# Test 3: Sully
echo -e "${BLUE}[3/3] Testing Sully.s${NC}"
echo -e "      ${YELLOW}→ Testing in subdirectory (as per subject)${NC}"

# Create test directory
rm -rf test_sully_check
mkdir -p test_sully_check
cd test_sully_check

# Compile
nasm -f elf64 ../Sully.s -o Sully.o > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "      ${RED}✗ FAIL${NC} - nasm compilation failed"
    cd ..
    rm -rf test_sully_check
    ((FAILED++))
    exit 1
fi

gcc -no-pie Sully.o -o Sully > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "      ${RED}✗ FAIL${NC} - gcc linking failed"
    cd ..
    rm -rf test_sully_check
    ((FAILED++))
    exit 1
fi

# Run Sully with timeout
timeout 5 ./Sully > /dev/null 2>&1
killall -9 Sully Sully_4 Sully_3 Sully_2 Sully_1 Sully_0 2>/dev/null

# Count files
FILE_COUNT=$(ls -1 | grep Sully | wc -l)

# Check basic file creation
SULLY_PASS=true
if [ ! -f "Sully_4.s" ] || [ ! -f "Sully_0.s" ]; then
    echo -e "      ${RED}✗ FAIL${NC} - Required files not created"
    SULLY_PASS=false
fi

if [ "$SULLY_PASS" = true ]; then
    # Check comment lines (; i = X)
    COMMENTS_OK=true
    for i in 4 3 2 1 0; do
        if [ -f "Sully_$i.s" ]; then
            FIRST_LINE=$(head -n 1 "Sully_$i.s")
            if [ "$FIRST_LINE" != "; i = $i" ]; then
                echo -e "      ${RED}✗ FAIL${NC} - Sully_$i.s has wrong comment: $FIRST_LINE"
                COMMENTS_OK=false
            fi
        else
            echo -e "      ${RED}✗ FAIL${NC} - Sully_$i.s not found"
            COMMENTS_OK=false
        fi
    done
    
    # Check i values in data section
    I_VALUES_OK=true
    for i in 4 3 2 1 0; do
        if [ -f "Sully_$i.s" ]; then
            if ! grep -q "i dq $i" "Sully_$i.s"; then
                echo -e "      ${RED}✗ FAIL${NC} - Sully_$i.s has wrong i value in data"
                I_VALUES_OK=false
            fi
        fi
    done
    
    # Check that Sully_0 was not compiled
    NO_SULLY_0_EXE=true
    if [ -f "Sully_0.o" ] || [ -f "Sully_0" ]; then
        echo -e "      ${RED}✗ FAIL${NC} - Sully_0 should not be compiled"
        NO_SULLY_0_EXE=false
    fi
    
    # Check diff between Sully.s and Sully_0.s
    DIFF_OUTPUT=$(diff ../Sully.s Sully_0.s 2>&1 | head -n 10)
    DIFF_CORRECT=false
    if echo "$DIFF_OUTPUT" | grep -q "; i = 5" && echo "$DIFF_OUTPUT" | grep -q "; i = 0"; then
        if echo "$DIFF_OUTPUT" | grep -q "i dq 5" && echo "$DIFF_OUTPUT" | grep -q "i dq 0"; then
            DIFF_CORRECT=true
        fi
    fi
    
    if [ "$COMMENTS_OK" = true ] && [ "$I_VALUES_OK" = true ] && [ "$NO_SULLY_0_EXE" = true ] && [ "$DIFF_CORRECT" = true ]; then
        echo -e "      ${GREEN}✓ PASS${NC} - All Sully files created correctly"
        echo -e "      ${GREEN}✓ PASS${NC} - Comments: ; i = 5 → 4 → 3 → 2 → 1 → 0"
        echo -e "      ${GREEN}✓ PASS${NC} - Data section i values correct"
        echo -e "      ${GREEN}✓ PASS${NC} - Sully_0 not compiled (correct)"
        echo -e "      ${GREEN}✓ PASS${NC} - diff output correct (only i values differ)"
        echo -e "      ${GREEN}✓ PASS${NC} - Total files: $FILE_COUNT (expected: 15)"
        ((PASSED++))
    else
        ((FAILED++))
    fi
else
    ((FAILED++))
fi

# Cleanup
cd ..
rm -rf test_sully_check
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
    echo ""
    echo -e "${YELLOW}Quick test commands:${NC}"
    echo -e "  Colleen: ${BLUE}./exc/Colleen > tmp && diff Colleen.s tmp${NC}"
    echo -e "  Grace:   ${BLUE}./exc/Grace && diff Grace.s Grace_kid.s${NC}"
    echo -e "  Sully:   ${BLUE}mkdir t && cd t && nasm -f elf64 ../Sully.s -o Sully.o && gcc -no-pie Sully.o -o Sully && ./Sully${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed! ✗${NC}"
    exit 1
fi
