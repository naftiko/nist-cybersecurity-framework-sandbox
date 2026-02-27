# Industry Benchmark Targets — NIST CSF 2.0

Recommended minimum target tiers by industry sector. Use these when the
organization has not defined explicit targets, or to validate that
targets are reasonable for the industry.

## Financial Services

| Function | Minimum Target | Rationale                                     |
|----------|----------------|-----------------------------------------------|
| GV       | 3              | Regulatory requirement (FFIEC, OCC, NYDFS)    |
| ID       | 3              | PCI-DSS, SOX asset inventory mandates         |
| PR       | 3              | Zero-trust expected by regulators             |
| DE       | 3              | Real-time fraud detection required             |
| RS       | 3              | FFIEC requires tested IR plans                 |
| RC       | 3              | Business continuity mandated                   |

## Healthcare

| Function | Minimum Target | Rationale                                     |
|----------|----------------|-----------------------------------------------|
| GV       | 2              | HIPAA Security Rule governance                |
| ID       | 3              | PHI asset tracking required                    |
| PR       | 3              | HIPAA access controls and encryption          |
| DE       | 2              | Breach detection within 60 days (HHS)         |
| RS       | 2              | Breach notification rule (60 days)            |
| RC       | 2              | Clinical system availability critical         |

## Manufacturing / Industrial

| Function | Minimum Target | Rationale                                     |
|----------|----------------|-----------------------------------------------|
| GV       | 2              | NIST SP 800-82 OT governance                  |
| ID       | 2              | OT asset discovery challenges                  |
| PR       | 3              | IT/OT segmentation critical                    |
| DE       | 2              | OT monitoring still maturing                   |
| RS       | 2              | Safety-critical response requirements          |
| RC       | 2              | Production continuity essential                |

## Technology / SaaS

| Function | Minimum Target | Rationale                                     |
|----------|----------------|-----------------------------------------------|
| GV       | 3              | SOC 2, ISO 27001 governance                   |
| ID       | 3              | Cloud asset sprawl management                  |
| PR       | 4              | Customer data protection, DevSecOps           |
| DE       | 3              | APT detection for IP protection               |
| RS       | 3              | SLA-driven incident response                   |
| RC       | 3              | High availability requirements                 |

## Government / Public Sector

| Function | Minimum Target | Rationale                                     |
|----------|----------------|-----------------------------------------------|
| GV       | 3              | FISMA, FedRAMP governance                      |
| ID       | 3              | CDM program asset management                   |
| PR       | 3              | NIST 800-53 control families                   |
| DE       | 3              | CISA requirements                              |
| RS       | 3              | US-CERT reporting timelines                    |
| RC       | 2              | COOP/COG requirements                          |

## Retail / E-Commerce

| Function | Minimum Target | Rationale                                     |
|----------|----------------|-----------------------------------------------|
| GV       | 2              | PCI-DSS governance                             |
| ID       | 2              | Cardholder data environment scoping           |
| PR       | 3              | PCI-DSS controls, tokenization                |
| DE       | 2              | Fraud and skimming detection                   |
| RS       | 2              | PCI breach notification                        |
| RC       | 2              | E-commerce availability                        |

## Using Benchmarks

1. Look up the organization's primary industry.
2. Compare their current profile tiers to the minimum targets.
3. If current tier < minimum target, flag as a regulatory risk.
4. Set target profile tiers to at least the minimum target values.
5. For highly regulated sub-sectors, add +1 to the minimum target.
