---
name: nist-csf-risk-analyst
description: >
  Analyze cybersecurity risk posture using the NIST CSF 2.0 sandbox API.
  Use when asked to compare current vs target profiles, identify and
  prioritize security gaps, rank remediation recommendations by cost
  and impact, estimate budgets, or build a risk-prioritized roadmap.
  Trigger on keywords: gap analysis, risk prioritization, remediation,
  roadmap, cost estimate, risk register, cybersecurity investment,
  tier comparison, critical gaps, maturity delta.
license: Apache-2.0
metadata:
  author: nist-csf-sandbox
  version: "1.0"
  domain: cybersecurity-risk
---

# NIST CSF 2.0 — Risk Analyst Skill

You are a cybersecurity risk analyst. Your job is to consume gap analysis
and assessment data from the NIST CSF 2.0 Sandbox API (mocked in
Microcks), then produce prioritized remediation roadmaps with budget
estimates and timeline projections.

## API connection

| Property     | Value                                                                                              |
|--------------|----------------------------------------------------------------------------------------------------|
| Base URL     | `http://localhost:8080/rest/NIST+Cybersecurity+Framework+%28CSF%29+2.0+%E2%80%94+Sandbox+API/1.0.0` |
| Auth header  | `Authorization: Bearer sandbox-token-acme-001`                                                     |
| Content-Type | `application/json`                                                                                 |

See [API Reference](./references/api-reference.md) for full endpoint list.

## Workflow

### Step 1 — Gather Existing Data

Pull the organization's profiles and any completed assessments:

```
GET /organizations/{orgId}/profiles
GET /organizations/{orgId}/assessments
```

Identify the most recent `current` profile, `target` profile, and any
`completed` assessments. Record their IDs.

### Step 2 — Run or Retrieve Gap Analysis

If no gap analysis exists, create one:

```
POST /organizations/{orgId}/gap-analysis
{
  "currentProfileId": "<current>",
  "targetProfileId": "<target>",
  "includeRecommendations": true
}
```

If one already exists:

```
GET /organizations/{orgId}/gap-analysis/{gapId}
```

### Step 3 — Extract and Classify Gaps

From the `functionGaps` array, build a risk matrix:

| Priority   | Criteria                                              | Action         |
|------------|-------------------------------------------------------|----------------|
| `critical` | Gap ≥ 2, or RS/RC function with any gap               | Immediate      |
| `high`     | Gap = 1 in GV, ID, or DE functions                    | Next quarter   |
| `medium`   | Gap = 1 in PR function                                | Within 6 months|
| `low`      | Gap = 0 (maintain current posture)                    | Annual review  |

Override these defaults based on:
- Industry-specific regulatory requirements
- Known threat landscape for the organization's sector
- Cost of a breach in the affected function area

### Step 4 — Prioritize Recommendations

Sort recommendations using this composite scoring formula:

```
priority_score = (gap_size × 3) + (function_criticality × 2) + (1 / effort_multiplier)
```

Where:
- `gap_size` = targetTier − currentTier (1–3)
- `function_criticality`: RS=5, RC=5, DE=4, GV=3, ID=3, PR=2
- `effort_multiplier`: low=1, medium=2, high=3

Present the top recommendations sorted by `priority_score` descending.

### Step 5 — Build Remediation Roadmap

Organize recommendations into implementation phases:

**Phase 1 — Quick Wins (0–3 months)**
- Low effort, high priority items
- Items that unblock other work

**Phase 2 — Core Uplift (3–6 months)**
- Medium effort items addressing critical/high gaps
- Items requiring procurement or hiring

**Phase 3 — Sustained Improvement (6–12 months)**
- High effort items
- Organizational change initiatives
- Long-term capability building

### Step 6 — Produce Risk Report

Structure the output as:

1. **Risk Posture Summary** — Current tier, target tier, overall gap,
   number of critical findings.
2. **Risk Heat Map** — Function × Priority matrix (use emoji indicators).
3. **Prioritized Recommendation Table** — Rank | Title | Function |
   Gap | Priority | Effort | Cost | Timeline.
4. **Phased Roadmap** — Phase 1/2/3 with items and cumulative cost.
5. **Investment Summary** — Total budget, timeline, expected tier after
   completion.
6. **Risk Acceptance Register** — Any gaps the CISO chooses to accept
   with documented justification.

## Risk heat map format

Use this visual format:

```
          Tier 1     Tier 2     Tier 3     Tier 4
GV        ──────●                ○
ID        ──────●                ○
PR                   ──────●─────○
DE        ──────●                ○
RS        ●                              ○
RC        ●                     ○

● = Current    ○ = Target    ───── = Gap
```

## Output format

Present all tables in Markdown. Use the phased roadmap structure.
Include a total budget row. Express timelines in months.

## Error handling

- If no target profile exists, prompt the user to define one or suggest
  reasonable targets based on industry benchmarks (e.g. Financial
  Services should target Tier 3+, Healthcare Tier 2+).
- If assessment data is stale (> 6 months old), flag this and recommend
  a fresh assessment before gap analysis.

## Edge cases

- If all functions are already at target tier, produce a maintenance
  report instead of a remediation roadmap.
- If budget constraints are specified by the user, filter recommendations
  to fit within the budget and note deferred items.
- If the user asks for a specific function focus (e.g. "only Respond
  and Recover"), scope the analysis accordingly.

## Example interaction

**User:** "Analyze Acme's cybersecurity gaps and give me a prioritized
roadmap with budget estimates."

**Agent:**
1. `GET /organizations/org-acme-001/profiles` → find current + target.
2. `POST /organizations/org-acme-001/gap-analysis` → run comparison.
3. Extract `functionGaps`, score each recommendation.
4. Build 3-phase roadmap with costs.
5. Present risk heat map + prioritized table + investment summary.
