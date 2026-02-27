---
name: nist-csf-full-lifecycle
description: >
  End-to-end NIST CSF 2.0 lifecycle management against the sandbox API.
  Combines CISO onboarding, compliance assessment, and risk analysis into
  a single orchestrated workflow. Use when asked to perform a complete
  cybersecurity posture evaluation from scratch, run the full NIST CSF
  pipeline, or produce a comprehensive governance package. Trigger on
  keywords: full assessment, end-to-end, complete evaluation, NIST
  lifecycle, comprehensive posture, cybersecurity program setup,
  governance package, maturity assessment.
license: Apache-2.0
metadata:
  author: nist-csf-sandbox
  version: "1.0"
  domain: cybersecurity-lifecycle
---

# NIST CSF 2.0 — Full Lifecycle Skill

You are a cybersecurity program manager orchestrating a complete NIST
CSF 2.0 evaluation lifecycle. This skill chains together organization
onboarding, profile creation, compliance assessment, gap analysis, and
risk-prioritized remediation planning into a single end-to-end workflow.

## API connection

| Property     | Value                                                                                              |
|--------------|----------------------------------------------------------------------------------------------------|
| Base URL     | `http://localhost:8080/rest/NIST+Cybersecurity+Framework+%28CSF%29+2.0+%E2%80%94+Sandbox+API/1.0.0` |
| Auth header  | `Authorization: Bearer sandbox-token-acme-001`                                                     |
| Content-Type | `application/json`                                                                                 |

See [API Reference](./references/api-reference.md) for full endpoint list.

## Complete Workflow — 8 Phases

Execute these phases sequentially. Each phase builds on the outputs of
the previous one. Track all resource IDs in a running state table.

### State Tracking

Maintain this table throughout the workflow:

```
| Resource          | ID                    | Status      |
|-------------------|-----------------------|-------------|
| Organization      | <pending>             |             |
| Current Profile   | <pending>             |             |
| Target Profile    | <pending>             |             |
| Assessment        | <pending>             |             |
| Gap Analysis      | <pending>             |             |
```

Update after each phase completes.

---

### Phase 1 — Organization Setup

**Goal:** Register the enterprise in the sandbox.

```
POST /organizations
```

**Inputs needed from user:**
- Organization name
- Industry sector
- Size (small / medium / large / enterprise)
- Optional: description, contact email

**Validation:** Confirm 201 response with a valid `id`.

---

### Phase 2 — Framework Discovery

**Goal:** Pull the full CSF 2.0 taxonomy to inform profile design.

```
GET /csf/functions
```

For each of the 6 functions, retrieve categories:

```
GET /csf/functions/GV/categories
GET /csf/functions/ID/categories
GET /csf/functions/PR/categories
GET /csf/functions/DE/categories
GET /csf/functions/RS/categories
GET /csf/functions/RC/categories
```

For priority categories (user-specified or default to GV.OC, ID.AM,
PR.AA, DE.CM, RS.MA, RC.RP), pull subcategories:

```
GET /csf/categories/{categoryId}/subcategories
```

Present a summary table of the framework structure to the user.

---

### Phase 3 — Current Profile Creation

**Goal:** Establish the organization's current cybersecurity posture.

```
POST /organizations/{orgId}/profiles
```

Build the profile body with:
- `type: "current"`
- Per-function tier assessments (from user input or industry defaults)
- Category-level outcomes where known

If the user provides only an overall tier, distribute it across functions
using this heuristic:
- PR = overall tier (protection is usually strongest)
- GV, ID, DE = overall tier
- RS = overall tier − 1 (response is often weakest)
- RC = overall tier − 1 (recovery is often weakest)
- Minimum tier is always 1.

**Validation:** Confirm `profileId` returned. Update state table.

---

### Phase 4 — Target Profile Creation

**Goal:** Define the desired future-state posture.

```
POST /organizations/{orgId}/profiles
```

- `type: "target"`
- If the user specifies a target tier, apply it uniformly or use
  industry benchmarks from [Industry Benchmarks](./references/industry-benchmarks.md).
- If no target specified, default to current + 1 for each function,
  capped at tier 4.

Approve the target profile:

```
PUT /organizations/{orgId}/profiles/{targetProfileId}
{ "status": "approved" }
```

---

### Phase 5 — Compliance Assessment

**Goal:** Evaluate the organization against the current profile with
subcategory-level findings.

```
POST /organizations/{orgId}/assessments
```

Build `functionScores` for all 6 functions. For each function, include
at least 2–3 subcategory findings with:
- `subcategoryId`
- `score` (0–4)
- `implementationState`
- `evidence` (specific, verifiable statement)

Use [Evidence Templates](./references/evidence-templates.md) for
guidance on writing evidence strings.

**Score calculation:**
- Function score = mean of subcategory scores
- Overall score = mean of function scores
- Tier mapping: 0–1.49 = Tier 1, 1.5–2.49 = Tier 2, 2.5–3.49 = Tier 3, 3.5–4.0 = Tier 4

Use [Score Calculator](./scripts/score-calculator.py) to verify calculations:

```bash
echo '<findings-json>' | python3 scripts/score-calculator.py
```

Complete the assessment:

```
PATCH /organizations/{orgId}/assessments/{assessmentId}
{ "status": "completed" }
```

---

### Phase 6 — Gap Analysis

**Goal:** Compare current vs target profiles to identify gaps.

```
POST /organizations/{orgId}/gap-analysis
{
  "currentProfileId": "<current>",
  "targetProfileId": "<target>",
  "includeRecommendations": true
}
```

Extract from the response:
- Per-function gaps (currentTier vs targetTier)
- Priority classification (critical / high / medium / low)
- Recommendations with cost and timeline estimates

---

### Phase 7 — Risk Prioritization

**Goal:** Rank recommendations and build a phased remediation roadmap.

Use [Prioritize Recommendations](./scripts/prioritize-recommendations.py):

```bash
echo '<gap-analysis-json>' | python3 scripts/prioritize-recommendations.py
```

Or manually apply the priority scoring formula:

```
priority_score = (gap × 3) + (function_criticality × 2) + (1 / effort_multiplier)

function_criticality: RS=5, RC=5, DE=4, GV=3, ID=3, PR=2
effort_multiplier: low=1, medium=2, high=3
```

Organize into three phases:
1. **Quick Wins (0–3 months)** — Low effort, high/critical priority
2. **Core Uplift (3–6 months)** — Medium effort, critical/high gaps
3. **Sustained Improvement (6–12 months)** — High effort, organizational change

---

### Phase 8 — Executive Deliverable

**Goal:** Produce a comprehensive governance package.

Compile all outputs into a single report with these sections:

#### 8.1 — Executive Summary
- 3-sentence posture overview
- Overall current tier → target tier
- Total investment required and timeline

#### 8.2 — Organization Profile
- Name, industry, size
- Registration date and contact

#### 8.3 — Framework Alignment
- Which CSF functions and categories are in scope
- Any exclusions and justification

#### 8.4 — Current Posture Scorecard
Table: Function | Current Tier | Score | Key Findings

#### 8.5 — Target Posture
Table: Function | Target Tier | Gap | Priority

#### 8.6 — Risk Heat Map
Visual representation of current vs target by function.

#### 8.7 — Assessment Findings Detail
Grouped by function, each subcategory with score, state, and evidence.
Use status indicators: ✅ ⚠️ ❌

#### 8.8 — Prioritized Recommendations
Ranked table: # | Title | Function | Gap | Priority | Effort | Cost | Timeline

#### 8.9 — Phased Roadmap
Phase 1 / 2 / 3 with items, costs, and cumulative investment

#### 8.10 — Investment Summary
| Metric               | Value          |
|----------------------|----------------|
| Total Budget         | $XXX,XXX       |
| Timeline             | XX months      |
| Current Overall Tier | X              |
| Target Overall Tier  | X              |
| Critical Gaps        | X              |
| Recommendations      | X              |

## Error handling

- If any API call fails, log the error, present it to the user, and
  offer to retry or skip the phase.
- If the Microcks mock returns fixed data, note this and proceed.
- If a dependency is missing (e.g. no current profile for assessment),
  automatically execute the required prerequisite phase.

## Edge cases

- If the user wants to skip phases (e.g. "just do the gap analysis"),
  check if prerequisites exist and either fetch them or create them.
- If the user provides a budget constraint, filter Phase 7 recommendations
  to fit and note deferred items.
- If the organization already exists, skip Phase 1 and use the existing ID.

## Example interaction

**User:** "Run a complete NIST CSF 2.0 evaluation for Globex Financial
Services. They're a large financial services firm currently at about
tier 2, aiming for tier 3."

**Agent executes all 8 phases sequentially:**
1. Registers Globex Financial Services.
2. Pulls CSF taxonomy.
3. Creates current profile at tier 2 with RS/RC at tier 1.
4. Creates target profile at tier 3 using financial services benchmarks.
5. Runs a full assessment with subcategory findings.
6. Runs gap analysis.
7. Prioritizes and phases recommendations.
8. Delivers the complete executive governance package.
