#!/usr/bin/env python3
"""
prioritize-recommendations.py — Score and rank gap analysis recommendations.

Usage:
    python3 prioritize-recommendations.py < gap-analysis.json

Input: The full gap analysis response JSON from the API.
Output: Prioritized recommendation table and phased roadmap.
"""

import json
import sys

FUNCTION_CRITICALITY = {
    "GV": 3,
    "ID": 3,
    "PR": 2,
    "DE": 4,
    "RS": 5,
    "RC": 5,
}

EFFORT_MULTIPLIER = {"low": 1, "medium": 2, "high": 3}

PHASE_RULES = {
    # (effort, priority) → phase
    ("low", "critical"): 1,
    ("low", "high"): 1,
    ("low", "medium"): 1,
    ("medium", "critical"): 2,
    ("medium", "high"): 2,
    ("medium", "medium"): 2,
    ("high", "critical"): 2,
    ("high", "high"): 3,
    ("high", "medium"): 3,
    ("low", "low"): 3,
    ("medium", "low"): 3,
    ("high", "low"): 3,
}


def compute_priority_score(gap_size: int, function_id: str, effort: str) -> float:
    """Compute composite priority score."""
    fc = FUNCTION_CRITICALITY.get(function_id, 3)
    em = EFFORT_MULTIPLIER.get(effort, 2)
    return (gap_size * 3) + (fc * 2) + (1 / em)


def assign_phase(effort: str, priority: str) -> int:
    """Assign implementation phase based on effort and priority."""
    return PHASE_RULES.get((effort, priority), 3)


def main():
    gap = json.load(sys.stdin)

    all_recs = []

    for fg in gap.get("functionGaps", []):
        func_id = fg["functionId"]
        func_name = fg["functionName"]
        gap_size = fg["gap"]

        for rec in fg.get("recommendations", []):
            score = compute_priority_score(gap_size, func_id, rec["effort"])
            phase = assign_phase(rec["effort"], rec["priority"])
            all_recs.append({
                "rank": 0,
                "id": rec["id"],
                "title": rec["title"],
                "function": f"{func_id} ({func_name})",
                "gap": gap_size,
                "priority": rec["priority"],
                "effort": rec["effort"],
                "cost": rec.get("estimatedCostUsd", 0),
                "timeline": rec.get("timelineMonths", 0),
                "score": round(score, 2),
                "phase": phase,
            })

    # Sort by score descending
    all_recs.sort(key=lambda r: r["score"], reverse=True)
    for i, rec in enumerate(all_recs, 1):
        rec["rank"] = i

    # Print prioritized table
    print("=" * 90)
    print("  PRIORITIZED RECOMMENDATIONS")
    print("=" * 90)
    print(f"{'Rank':>4}  {'Title':<45} {'Function':<14} {'Gap':>3} {'Priority':<9} {'Effort':<7} {'Cost':>10} {'Mo':>3}  {'Score':>5}")
    print(f"{'─'*4}  {'─'*45} {'─'*14} {'─'*3} {'─'*9} {'─'*7} {'─'*10} {'─'*3}  {'─'*5}")

    for rec in all_recs:
        title = rec["title"][:45]
        print(f"{rec['rank']:>4}  {title:<45} {rec['function']:<14} {rec['gap']:>3} {rec['priority']:<9} {rec['effort']:<7} ${rec['cost']:>9,} {rec['timeline']:>3}  {rec['score']:>5}")

    # Phased roadmap
    phases = {1: [], 2: [], 3: []}
    for rec in all_recs:
        phases[rec["phase"]].append(rec)

    phase_names = {
        1: "Quick Wins (0–3 months)",
        2: "Core Uplift (3–6 months)",
        3: "Sustained Improvement (6–12 months)",
    }

    cumulative = 0
    print(f"\n{'=' * 90}")
    print("  PHASED ROADMAP")
    print(f"{'=' * 90}")

    for phase_num in [1, 2, 3]:
        items = phases[phase_num]
        phase_cost = sum(r["cost"] for r in items)
        cumulative += phase_cost
        print(f"\n── Phase {phase_num}: {phase_names[phase_num]} ──")
        if items:
            for rec in items:
                print(f"   [{rec['priority'].upper():>8}] {rec['title']} — ${rec['cost']:,} / {rec['timeline']}mo")
            print(f"   Phase Cost: ${phase_cost:,}  |  Cumulative: ${cumulative:,}")
        else:
            print("   No items in this phase.")

    print(f"\n{'=' * 90}")
    print(f"  TOTAL INVESTMENT: ${cumulative:,}")
    print(f"  ESTIMATED TIMELINE: {gap.get('estimatedTimelineMonths', 'N/A')} months")
    print(f"{'=' * 90}")

    # JSON output
    output = {
        "prioritizedRecommendations": all_recs,
        "phases": {
            f"phase{p}": {
                "name": phase_names[p],
                "items": [r["id"] for r in phases[p]],
                "cost": sum(r["cost"] for r in phases[p]),
            }
            for p in [1, 2, 3]
        },
        "totalCost": cumulative,
    }
    print(f"\nJSON Output:\n{json.dumps(output, indent=2)}")


if __name__ == "__main__":
    main()
