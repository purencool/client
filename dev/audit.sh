#!/bin/bash
# [GOVERNANCE] CLIENT - ARCHITECTURAL AUDITOR (v2.0)
# Purpose: Detect "Moat Bypasses" and ensure 100% Structural Integrity.

echo "============================================================"
echo "Client: Clinical Saturday Audit [INITIALIZED]"
echo "Timestamp: $(date)"
echo "============================================================"

# --- Configuration ---
TARGET_DIR="../lib/apps"
FORBIDDEN_IMPORTS=("dart:io" "package:http/http.dart" "package:dio/dio.dart")
MANDATORY_BASE_CLASS="SovereignNetworkClient"
LICENSE_IDENTIFIER="license.md"

TOTAL_FILES=0
FAILED_FILES=0

# --- Phase 1: License & Header Verification ---
echo "[1/3] Auditing Legal Traceability..."
find lib -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" | while read -r FILE; do
    ((TOTAL_FILES++))
    if ! grep -q "$LICENSE_IDENTIFIER" "$FILE"; then
        echo " [LEGAL_FAIL]: $FILE (Missing License Header)"
        ((FAILED_FILES++))
    fi
done

# --- Phase 2: Architectural Bypass Detection ---
echo "[2/3] Auditing Structural Integrity (Looking for Bypasses)..."
# We check the 'features' directory to ensure they aren't talking directly to the web/disk.
for IMPORT in "${FORBIDDEN_IMPORTS[@]}"; do
    FOUND=$(grep -rl "$IMPORT" "$TARGET_DIR")
    if [ -n "$FOUND" ]; then
        echo "[BYPASS_DETECTED]: Feature files using forbidden import: $IMPORT"
        echo "$FOUND" | sed 's/^/     - /'
        ((FAILED_FILES++))
    fi
done

# --- Phase 3: Fail-Safe Implementation Check ---
echo "[3/3] Auditing Fail-Safe Compliance..."
# Ensure all network-related files in features are inheriting from the base
find "$TARGET_DIR" -name "*_repository.dart" | while read -r REPO; do
    if ! grep -q "$MANDATORY_BASE_CLASS" "$REPO"; then
        echo "[INTEGRITY_WARNING]: $REPO does not appear to use $MANDATORY_BASE_CLASS"
        # We don't increment FAILED_FILES here yet, just a warning for Day 10.
    fi
done

# --- Final Calculation ---
SUCCESSFUL_FILES=$((TOTAL_FILES - FAILED_FILES))
# Calculating ASR using bc for floating point math
ASR=$(echo "scale=2; ($SUCCESSFUL_FILES / $TOTAL_FILES) * 100" | bc)

echo "============================================================"
echo "AUDIT SUMMARY"
echo "============================================================"
echo "Total Source Files: $TOTAL_FILES"
echo "Compliant Files:    $SUCCESSFUL_FILES"
echo "Security Failures:  $FAILED_FILES"
echo "------------------------------------------------------------"
echo "AUDIT SUCCESS RATE (ASR): $ASR%"
echo "============================================================"

if (( $(echo "$ASR < 100.0" | bc -l) )); then
    echo "[RESULT]: CLINICAL FAIL. Correct bypasses before Alpha Tagging."
    exit 1
else
    echo "[RESULT]: CLINICAL PASS. Core Rebuild integrity verified."
    exit 0
fi