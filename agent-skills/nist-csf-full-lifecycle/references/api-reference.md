# NIST CSF 2.0 Sandbox API — Quick Reference

## Base URL

```
https://sandbox.nist-csf.example.com/api/v1
```

Local Microcks mock:

```
http://localhost:8080/rest/NIST+Cybersecurity+Framework+%28CSF%29+2.0+%E2%80%94+Sandbox+API/1.0.0
```

## Authentication

All requests require a bearer token:

```
Authorization: Bearer sandbox-token-acme-001
```

## CSF 2.0 Functions

| Code | Name     | Purpose                                              |
|------|----------|------------------------------------------------------|
| GV   | Govern   | Cybersecurity risk management strategy and policy    |
| ID   | Identify | Understand current cybersecurity risk posture        |
| PR   | Protect  | Safeguards to manage cybersecurity risks             |
| DE   | Detect   | Find and analyze attacks and compromises             |
| RS   | Respond  | Take action on detected incidents                    |
| RC   | Recover  | Restore affected assets and operations               |

## Implementation Tiers

| Tier | Name          | Description                                        |
|------|---------------|----------------------------------------------------|
| 1    | Partial       | Ad-hoc, reactive practices                         |
| 2    | Risk Informed | Risk-aware but not formalized                      |
| 3    | Repeatable    | Formally approved, regularly reviewed policies     |
| 4    | Adaptive      | Continuously improving based on lessons learned    |

## Implementation States

- `not_implemented` — No controls in place
- `partially_implemented` — Some controls exist but gaps remain
- `implemented` — Controls fully operational
- `advanced` — Controls exceed requirements, continuously optimized

## Scoring Scale (Assessments)

| Score | Meaning            |
|-------|--------------------|
| 0     | Not Assessed       |
| 1     | Not Implemented    |
| 2     | Partially Implemented |
| 3     | Fully Implemented  |
| 4     | Advanced / Optimized |

## Endpoints Summary

### CSF Taxonomy (read-only)
- `GET /csf/functions` — List all 6 CSF functions
- `GET /csf/functions/{functionId}/categories` — Categories for a function
- `GET /csf/categories/{categoryId}/subcategories` — Subcategories for a category

### Organizations
- `GET /organizations` — List organizations
- `POST /organizations` — Register new organization
- `GET /organizations/{orgId}` — Get organization detail

### Profiles
- `GET /organizations/{orgId}/profiles` — List profiles (filter: `?type=current` or `?type=target`)
- `POST /organizations/{orgId}/profiles` — Create profile
- `GET /organizations/{orgId}/profiles/{profileId}` — Get profile detail
- `PUT /organizations/{orgId}/profiles/{profileId}` — Update profile

### Assessments
- `GET /organizations/{orgId}/assessments` — List assessments
- `POST /organizations/{orgId}/assessments` — Create assessment
- `GET /organizations/{orgId}/assessments/{assessmentId}` — Get assessment detail
- `PATCH /organizations/{orgId}/assessments/{assessmentId}` — Update assessment status

### Gap Analysis
- `POST /organizations/{orgId}/gap-analysis` — Run gap analysis
- `GET /organizations/{orgId}/gap-analysis/{gapId}` — Retrieve gap analysis

## Profile Types

- `current` — Snapshot of the organization's present cybersecurity posture
- `target` — Desired future-state cybersecurity posture

## Profile Statuses

`draft` → `in_review` → `approved` → `archived`

## Assessment Statuses

`in_progress` → `in_review` → `completed` | `cancelled`

## Gap Analysis Priority Levels

`low` → `medium` → `high` → `critical`

## Recommendation Effort Levels

`low` | `medium` | `high`
