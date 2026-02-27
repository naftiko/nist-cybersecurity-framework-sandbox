#!/usr/bin/env python3
"""
score-calculator.py — Calculate function scores and tiers from subcategory findings.

Usage:
    python3 score-calculator.py < findings.json

Input: JSON array of findings, each with { subcategoryId, score, implementationState, evidence }
Output: Calculated function score, tier, and summary statistics.

Example input (stdin):
[
  { "subcategoryId": "GV.OC-01", "score": 3, "implementationState": "implemented", "evidence": "..." },
  { "subcategoryId": "GV.OC-02", "score": 2, "implementationState": "partially_implemented", "evidence": "..." },
  { "subcategoryId": "GV.OC-03", "score": 1, "implementationState": "not_implemented", "evidence": "..." }
]
"""

import json
import sys
from collections import defaultdict


def score_to_tier(mean_score: float) -> int:
    """Map a mean score to an implementation tier."""
    if mean_score < 1.5:
        return 1
    elif mean_score < 2.5:
        return 2
    elif mean_score < 3.5:
        return 3
    else:
        return 4


TIER_LABELS = {1: "Partial", 2: "Risk Informed", 3: "Repeatable", 4: "Adaptive"}
STATE_ICONS = {
    "not_implemented": "❌",
    "partially_implemented": "⚠️",
    "implemented": "✅",
    "advanced": "🌟",
}


def main():
    findings = json.load(sys.stdin)

    if not findings:
        print("No findings provided.", file=sys.stderr)
        sys.exit(1)

    # Group findings by function prefix (first 2 chars of subcategoryId)
    by_function = defaultdict(list)
    for f in findings:
        func_id = f["subcategoryId"].split(".")[0]
        by_function[func_id].append(f)

    print("=" * 60)
    print("  NIST CSF 2.0 — Subcategory Score Analysis")
    print("=" * 60)

    overall_scores = []

    for func_id in sorted(by_function.keys()):
        func_findings = by_function[func_id]
        scores = [f["score"] for f in func_findings if f["score"] > 0]
        assessed = len(scores)
        not_assessed = len(func_findings) - assessed

        if assessed == 0:
            mean = 0.0
        else:
            mean = sum(scores) / assessed

        tier = score_to_tier(mean)
        overall_scores.append(mean)

        print(f"\n── Function: {func_id} ──")
        print(f"   Mean Score : {mean:.2f}")
        print(f"   Tier       : {tier} ({TIER_LABELS[tier]})")
        print(f"   Assessed   : {assessed} / {len(func_findings)}")

        if not_assessed:
            print(f"   ⚠️  {not_assessed} subcategories not assessed (score=0)")

        print(f"\n   {'Subcategory':<14} {'Score':>5}  {'State':<26} Icon")
        print(f"   {'-'*14} {'-'*5}  {'-'*26} {'-'*4}")
        for f in sorted(func_findings, key=lambda x: x["subcategoryId"]):
            icon = STATE_ICONS.get(f["implementationState"], "?")
            print(f"   {f['subcategoryId']:<14} {f['score']:>5}  {f['implementationState']:<26} {icon}")

    # Overall
    if overall_scores:
        overall_mean = sum(overall_scores) / len(overall_scores)
        overall_tier = score_to_tier(overall_mean)
    else:
        overall_mean = 0.0
        overall_tier = 1

    print(f"\n{'=' * 60}")
    print(f"  Overall Score : {overall_mean:.2f}")
    print(f"  Overall Tier  : {overall_tier} ({TIER_LABELS[overall_tier]})")
    print(f"{'=' * 60}")

    # Output JSON summary to stdout for piping
    summary = {
        "overallScore": round(overall_mean, 2),
        "overallTier": overall_tier,
        "functions": {
            func_id: {
                "score": round(sum(f["score"] for f in fs if f["score"] > 0) / max(len([f for f in fs if f["score"] > 0]), 1), 2),
                "tier": score_to_tier(sum(f["score"] for f in fs if f["score"] > 0) / max(len([f for f in fs if f["score"] > 0]), 1)),
                "findingsCount": len(fs),
            }
            for func_id, fs in sorted(by_function.items())
        },
    }

    print(f"\nJSON Summary:\n{json.dumps(summary, indent=2)}")


if __name__ == "__main__":
    main()
