#!/usr/bin/env bash
# full-lifecycle.sh — Run the complete NIST CSF 2.0 lifecycle
# Usage: ./full-lifecycle.sh <base-url> <token> <org-name> <industry> <size> <current-tier> <target-tier>
#
# Example:
#   ./full-lifecycle.sh http://localhost:8080/rest/... sandbox-token-acme-001 \
#     "Globex Financial Services" "Financial Services" enterprise 2 3

set -euo pipefail

BASE="${1:?Usage: $0 <base-url> <token> <org-name> <industry> <size> <current-tier> <target-tier>}"
TOKEN="${2:?}"
ORG_NAME="${3:?}"
INDUSTRY="${4:?}"
SIZE="${5:?}"
CTIER="${6:?}"
TTIER="${7:?}"

H_AUTH="Authorization: Bearer ${TOKEN}"
H_CT="Content-Type: application/json"

call() {
  local method=$1 path=$2 body="${3:-}"
  local url="${BASE}${path}"
  if [[ -n "${body}" ]]; then
    curl -s -X "${method}" "${url}" -H "${H_AUTH}" -H "${H_CT}" -d "${body}"
  else
    curl -s -X "${method}" "${url}" -H "${H_AUTH}" -H "${H_CT}"
  fi
}

jval() { python3 -c "import sys,json; print(json.load(sys.stdin)['$1'])" 2>/dev/null; }

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  NIST CSF 2.0 — Full Lifecycle Orchestration            ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Org     : ${ORG_NAME}"
echo "║  Industry: ${INDUSTRY}"
echo "║  Size    : ${SIZE}"
echo "║  Current : Tier ${CTIER}  →  Target : Tier ${TTIER}"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ── Phase 1: Organization ──
echo "━━━ Phase 1/8: Organization Setup ━━━"
ORG_ID=$(call POST /organizations "{
  \"name\":\"${ORG_NAME}\",
  \"industry\":\"${INDUSTRY}\",
  \"size\":\"${SIZE}\",
  \"description\":\"Full lifecycle evaluation via agent skill.\"
}" | jval id)
echo "  ✓ Organization: ${ORG_ID}"

# ── Phase 2: Taxonomy ──
echo ""
echo "━━━ Phase 2/8: Framework Discovery ━━━"
FUNCTIONS=$(call GET /csf/functions "")
echo "  ✓ Retrieved CSF 2.0 functions"
FUNC_COUNT=$(echo "${FUNCTIONS}" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))")
echo "  ✓ ${FUNC_COUNT} functions loaded"

# ── Phase 3: Current Profile ──
echo ""
echo "━━━ Phase 3/8: Current Profile ━━━"

# RS and RC get tier-1 to simulate weaker response/recovery
RS_TIER=$(( CTIER > 1 ? CTIER - 1 : 1 ))
RC_TIER=$(( CTIER > 1 ? CTIER - 1 : 1 ))

CUR_ID=$(call POST "/organizations/${ORG_ID}/profiles" "{
  \"name\":\"${ORG_NAME} Current Profile\",
  \"type\":\"current\",
  \"overallTier\":${CTIER},
  \"description\":\"Baseline posture — automated lifecycle.\",
  \"functionTiers\":[
    {\"functionId\":\"GV\",\"tier\":${CTIER},\"notes\":\"Governance at baseline.\"},
    {\"functionId\":\"ID\",\"tier\":${CTIER},\"notes\":\"Identification at baseline.\"},
    {\"functionId\":\"PR\",\"tier\":${CTIER},\"notes\":\"Protection at baseline.\"},
    {\"functionId\":\"DE\",\"tier\":${CTIER},\"notes\":\"Detection at baseline.\"},
    {\"functionId\":\"RS\",\"tier\":${RS_TIER},\"notes\":\"Response below baseline.\"},
    {\"functionId\":\"RC\",\"tier\":${RC_TIER},\"notes\":\"Recovery below baseline.\"}
  ],
  \"categoryOutcomes\":[]
}" | jval id)
echo "  ✓ Current Profile: ${CUR_ID}"

# ── Phase 4: Target Profile ──
echo ""
echo "━━━ Phase 4/8: Target Profile ━━━"
TGT_ID=$(call POST "/organizations/${ORG_ID}/profiles" "{
  \"name\":\"${ORG_NAME} Target Profile\",
  \"type\":\"target\",
  \"overallTier\":${TTIER},
  \"description\":\"Target posture — automated lifecycle.\",
  \"functionTiers\":[
    {\"functionId\":\"GV\",\"tier\":${TTIER},\"notes\":\"Target governance.\"},
    {\"functionId\":\"ID\",\"tier\":${TTIER},\"notes\":\"Target identification.\"},
    {\"functionId\":\"PR\",\"tier\":${TTIER},\"notes\":\"Target protection.\"},
    {\"functionId\":\"DE\",\"tier\":${TTIER},\"notes\":\"Target detection.\"},
    {\"functionId\":\"RS\",\"tier\":${TTIER},\"notes\":\"Target response.\"},
    {\"functionId\":\"RC\",\"tier\":$(( TTIER > 1 ? TTIER - 1 : 1 )),\"notes\":\"Target recovery.\"}
  ],
  \"categoryOutcomes\":[]
}" | jval id)
echo "  ✓ Target Profile: ${TGT_ID}"

# ── Phase 5: Assessment ──
echo ""
echo "━━━ Phase 5/8: Compliance Assessment ━━━"
ASSESS_ID=$(call POST "/organizations/${ORG_ID}/assessments" "{
  \"profileId\":\"${CUR_ID}\",
  \"title\":\"${ORG_NAME} Full Lifecycle Assessment\",
  \"assessor\":\"Automated Agent Auditor\",
  \"scope\":\"All business units — full lifecycle evaluation.\",
  \"methodology\":\"Automated sandbox assessment via agent skill.\",
  \"functionScores\":[
    {\"functionId\":\"GV\",\"score\":2.3,\"tier\":${CTIER},\"findings\":[
      {\"subcategoryId\":\"GV.OC-01\",\"score\":3,\"implementationState\":\"implemented\",\"evidence\":\"Mission-aligned strategy document reviewed.\"},
      {\"subcategoryId\":\"GV.OC-02\",\"score\":2,\"implementationState\":\"partially_implemented\",\"evidence\":\"Stakeholder register stale.\"}
    ]},
    {\"functionId\":\"ID\",\"score\":2.5,\"tier\":${CTIER},\"findings\":[
      {\"subcategoryId\":\"ID.AM-01\",\"score\":3,\"implementationState\":\"implemented\",\"evidence\":\"CMDB covers 95% hardware.\"},
      {\"subcategoryId\":\"ID.AM-02\",\"score\":2,\"implementationState\":\"partially_implemented\",\"evidence\":\"Shadow IT untracked.\"}
    ]},
    {\"functionId\":\"PR\",\"score\":2.8,\"tier\":${CTIER},\"findings\":[
      {\"subcategoryId\":\"PR.AA-01\",\"score\":3,\"implementationState\":\"implemented\",\"evidence\":\"MFA enforced for privileged accounts.\"}
    ]},
    {\"functionId\":\"DE\",\"score\":2.0,\"tier\":${CTIER},\"findings\":[
      {\"subcategoryId\":\"DE.CM-01\",\"score\":2,\"implementationState\":\"partially_implemented\",\"evidence\":\"OT monitoring gaps.\"}
    ]},
    {\"functionId\":\"RS\",\"score\":1.5,\"tier\":${RS_TIER},\"findings\":[
      {\"subcategoryId\":\"RS.MA-01\",\"score\":1,\"implementationState\":\"not_implemented\",\"evidence\":\"IR plan untested.\"}
    ]},
    {\"functionId\":\"RC\",\"score\":1.2,\"tier\":${RC_TIER},\"findings\":[
      {\"subcategoryId\":\"RC.RP-01\",\"score\":1,\"implementationState\":\"not_implemented\",\"evidence\":\"No recovery plan.\"}
    ]}
  ]
}" | jval id)
echo "  ✓ Assessment: ${ASSESS_ID}"

# Complete assessment
call PATCH "/organizations/${ORG_ID}/assessments/${ASSESS_ID}" '{"status":"completed"}' > /dev/null
echo "  ✓ Assessment marked completed"

# ── Phase 6: Gap Analysis ──
echo ""
echo "━━━ Phase 6/8: Gap Analysis ━━━"
GAP_RESPONSE=$(call POST "/organizations/${ORG_ID}/gap-analysis" "{
  \"currentProfileId\":\"${CUR_ID}\",
  \"targetProfileId\":\"${TGT_ID}\",
  \"includeRecommendations\":true
}")
GAP_ID=$(echo "${GAP_RESPONSE}" | jval id)
echo "  ✓ Gap Analysis: ${GAP_ID}"

# ── Phase 7: Prioritization ──
echo ""
echo "━━━ Phase 7/8: Risk Prioritization ━━━"
TOTAL_COST=$(echo "${GAP_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('totalEstimatedCostUsd','N/A'))")
TIMELINE=$(echo "${GAP_RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('estimatedTimelineMonths','N/A'))")
echo "  ✓ Total estimated cost: \$${TOTAL_COST}"
echo "  ✓ Estimated timeline: ${TIMELINE} months"

# ── Phase 8: Summary ──
echo ""
echo "━━━ Phase 8/8: Executive Summary ━━━"
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  LIFECYCLE COMPLETE                                     ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Resource          │ ID                                 ║"
echo "╠════════════════════╪════════════════════════════════════╣"
printf "║  %-18s │ %-36s║\n" "Organization" "${ORG_ID}"
printf "║  %-18s │ %-36s║\n" "Current Profile" "${CUR_ID}"
printf "║  %-18s │ %-36s║\n" "Target Profile" "${TGT_ID}"
printf "║  %-18s │ %-36s║\n" "Assessment" "${ASSESS_ID}"
printf "║  %-18s │ %-36s║\n" "Gap Analysis" "${GAP_ID}"
echo "╠══════════════════════════════════════════════════════════╣"
printf "║  %-18s │ \$%-35s║\n" "Total Investment" "${TOTAL_COST}"
printf "║  %-18s │ %-35s ║\n" "Timeline" "${TIMELINE} months"
echo "╚══════════════════════════════════════════════════════════╝"
