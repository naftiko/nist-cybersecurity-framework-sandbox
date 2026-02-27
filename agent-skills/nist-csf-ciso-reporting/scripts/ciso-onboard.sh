#!/usr/bin/env bash
# ciso-onboard.sh — Onboard an organization and create current + target profiles
# Usage: ./ciso-onboard.sh <base-url> <token> <org-name> <industry> <size> <current-tier> <target-tier>
#
# Example:
#   ./ciso-onboard.sh http://localhost:8080/rest/... sandbox-token-acme-001 \
#     "Acme Corporation" Manufacturing large 2 3

set -euo pipefail

BASE_URL="${1:?Usage: $0 <base-url> <token> <org-name> <industry> <size> <current-tier> <target-tier>}"
TOKEN="${2:?}"
ORG_NAME="${3:?}"
INDUSTRY="${4:?}"
SIZE="${5:?}"
CURRENT_TIER="${6:?}"
TARGET_TIER="${7:?}"

AUTH="Authorization: Bearer ${TOKEN}"
CT="Content-Type: application/json"

echo "═══════════════════════════════════════════"
echo "  NIST CSF 2.0 — CISO Onboarding Script"
echo "═══════════════════════════════════════════"

# ── Step 1: Create Organization ──
echo ""
echo "▶ Step 1: Registering organization '${ORG_NAME}'..."
ORG_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/organizations" \
  -H "${AUTH}" -H "${CT}" \
  -d "{
    \"name\": \"${ORG_NAME}\",
    \"industry\": \"${INDUSTRY}\",
    \"size\": \"${SIZE}\",
    \"description\": \"Onboarded via CISO reporting skill.\"
  }")

HTTP_CODE=$(echo "${ORG_RESPONSE}" | tail -1)
ORG_BODY=$(echo "${ORG_RESPONSE}" | sed '$d')

if [[ "${HTTP_CODE}" -ge 400 ]]; then
  echo "✗ Failed (HTTP ${HTTP_CODE}): ${ORG_BODY}"
  exit 1
fi

ORG_ID=$(echo "${ORG_BODY}" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "unknown")
echo "✓ Organization created: ${ORG_ID}"

# ── Step 2: Build function tiers JSON ──
build_function_tiers() {
  local tier=$1
  local label=$2
  python3 -c "
import json
functions = [
    ('GV', 'Govern'),
    ('ID', 'Identify'),
    ('PR', 'Protect'),
    ('DE', 'Detect'),
    ('RS', 'Respond'),
    ('RC', 'Recover'),
]
tiers = [{'functionId': fid, 'tier': ${tier}, 'notes': '${label} tier for ${ORG_NAME}'} for fid, _ in functions]
print(json.dumps(tiers))
"
}

CURRENT_FT=$(build_function_tiers "${CURRENT_TIER}" "Current")
TARGET_FT=$(build_function_tiers "${TARGET_TIER}" "Target")

# ── Step 3: Create Current Profile ──
echo ""
echo "▶ Step 2: Creating current profile (Tier ${CURRENT_TIER})..."
CUR_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/organizations/${ORG_ID}/profiles" \
  -H "${AUTH}" -H "${CT}" \
  -d "{
    \"name\": \"${ORG_NAME} Current Profile\",
    \"type\": \"current\",
    \"overallTier\": ${CURRENT_TIER},
    \"description\": \"Baseline cybersecurity posture.\",
    \"functionTiers\": ${CURRENT_FT},
    \"categoryOutcomes\": []
  }")

CUR_CODE=$(echo "${CUR_RESPONSE}" | tail -1)
CUR_BODY=$(echo "${CUR_RESPONSE}" | sed '$d')
CUR_ID=$(echo "${CUR_BODY}" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "unknown")
echo "✓ Current profile created: ${CUR_ID}"

# ── Step 4: Create Target Profile ──
echo ""
echo "▶ Step 3: Creating target profile (Tier ${TARGET_TIER})..."
TGT_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/organizations/${ORG_ID}/profiles" \
  -H "${AUTH}" -H "${CT}" \
  -d "{
    \"name\": \"${ORG_NAME} Target Profile\",
    \"type\": \"target\",
    \"overallTier\": ${TARGET_TIER},
    \"description\": \"Target cybersecurity posture.\",
    \"functionTiers\": ${TARGET_FT},
    \"categoryOutcomes\": []
  }")

TGT_CODE=$(echo "${TGT_RESPONSE}" | tail -1)
TGT_BODY=$(echo "${TGT_RESPONSE}" | sed '$d')
TGT_ID=$(echo "${TGT_BODY}" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "unknown")
echo "✓ Target profile created: ${TGT_ID}"

# ── Step 5: Run Gap Analysis ──
echo ""
echo "▶ Step 4: Running gap analysis..."
GAP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/organizations/${ORG_ID}/gap-analysis" \
  -H "${AUTH}" -H "${CT}" \
  -d "{
    \"currentProfileId\": \"${CUR_ID}\",
    \"targetProfileId\": \"${TGT_ID}\",
    \"includeRecommendations\": true
  }")

GAP_CODE=$(echo "${GAP_RESPONSE}" | tail -1)
GAP_BODY=$(echo "${GAP_RESPONSE}" | sed '$d')
GAP_ID=$(echo "${GAP_BODY}" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "unknown")
echo "✓ Gap analysis generated: ${GAP_ID}"

# ── Summary ──
echo ""
echo "═══════════════════════════════════════════"
echo "  Onboarding Complete"
echo "═══════════════════════════════════════════"
echo "  Organization ID : ${ORG_ID}"
echo "  Current Profile : ${CUR_ID}"
echo "  Target Profile  : ${TGT_ID}"
echo "  Gap Analysis    : ${GAP_ID}"
echo "═══════════════════════════════════════════"
