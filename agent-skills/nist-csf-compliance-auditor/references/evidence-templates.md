# Evidence Templates by CSF Function

Use these templates when documenting evidence for subcategory findings.
Replace placeholders with actual observations.

## GV — Govern

```
GV.OC-01: Reviewed [document name] dated [date]. Cybersecurity mission
statement is [aligned/not aligned] with organizational mission.
Board sign-off [present/absent] as of [date].

GV.RM-01: Risk management strategy document [exists/does not exist].
Last reviewed [date]. Risk appetite statement [approved/pending]
by [governance body].

GV.RR-01: CISO role [established/vacant]. Reporting line: [direct to
CEO / via CIO / other]. RACI matrix [complete/in progress/absent].
```

## ID — Identify

```
ID.AM-01: Hardware asset inventory maintained in [CMDB tool name].
Coverage: [X]% of known assets. Last updated [date].
Shadow IT discovery [performed/not performed].

ID.AM-02: Software inventory covers [X]% of systems. SaaS discovery
tool [deployed/not deployed]. License compliance [tracked/untracked].

ID.RA-01: Risk assessment last performed [date] using [methodology].
Covers [scope]. Next scheduled: [date].
```

## PR — Protect

```
PR.AA-01: Identity provider: [tool name]. MFA enforced for
[all users / privileged only / not enforced]. SSO coverage: [X]%.

PR.DS-01: Data classification policy [exists/absent]. DLP controls
[deployed/not deployed] on [endpoints/network/cloud]. Encryption
at rest: [yes/no]. In transit: [yes/no].

PR.PS-01: Patch management SLA: [X days critical / Y days high].
Current compliance rate: [X]%. Exceptions: [count].
```

## DE — Detect

```
DE.CM-01: Network monitoring covers [X]% of segments. Tool: [SIEM name].
OT coverage: [yes/no]. Cloud workloads: [monitored/unmonitored].

DE.AE-01: Anomaly detection [rule-based/ML-based/absent]. False positive
rate: [X]%. Mean time to detect (MTTD): [hours/days].
```

## RS — Respond

```
RS.MA-01: Incident response plan [exists/absent]. Last tested: [date/never].
Format: [tabletop/simulation/live]. Participants: [roles].

RS.CO-01: Communication plan [exists/absent]. Stakeholder notification
SLA: [X hours]. Regulatory reporting process: [defined/undefined].
```

## RC — Recover

```
RC.RP-01: Recovery plan [exists/absent] for [X] critical systems.
RTO target: [hours]. RPO target: [hours]. Last DR test: [date/never].

RC.CO-01: Post-incident review process [formal/informal/absent].
Lessons learned documented for last [X] incidents.
```
