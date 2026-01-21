
# OCI Service-Level Admin IAM Policies (Expanded Coverage)

**Owner:** Ganesh Shinde – Senior Domain Manager, Data Center  
**Version:** 1.2  
**Last Updated:** 21-Jan-2026  

This update cross‑checks your requested services and adds any missing IAM policy entries or guidance. It keeps the standard OCI policy syntax and resource families, with tenancy/compartment scope set according to Oracle references.citeturn1search19turn1search25

> **How to read**: Replace `<COMP>` with the effective compartment path. Use families where possible (auto‑includes new resource types later).citeturn1search11

---
## 0) Quick Additions at a Glance
- **Web Application Acceleration**: added `waa-family`.citeturn2search79  
- **Multicloud Hub**: added `multicloud-family`.citeturn2search52  
- **IP Address Insights**: added `read ipam`.citeturn2search64  
- **Zero Trust Packet Routing (ZPR)**: added ZPR policy/admin resource types.citeturn2search103  
- **Exadata Fleet Update**: added `fleet-software-update-family`.citeturn2search108  
- **Data Safe**: added `data-safe-family` (covers assessments, audit, discovery, masking, SQL Firewall).citeturn2search72  
- **API Access Control (Privileged API)**: added `privileged-api-family`.citeturn2search141  
- **Delegate Access Control**: added `delegation-management-family`.citeturn2search143  
- **Operator Access Control**: added `operator-control-family`.citeturn2search137  
- **Billing**: added **Invoices/Subscriptions** resource types & scheduled reports service policy.citeturn2search123turn2search127

---
## 1) Compute Administration
**Group:** `BFL-OCI-COMPUTE-ADMIN`

```hcl
# Core compute
Allow group BFL-OCI-COMPUTE-ADMIN to manage instance-family in compartment <COMP>
Allow group BFL-OCI-COMPUTE-ADMIN to manage compute-management-family in compartment <COMP>

# Dedicated hosts & custom images
Allow group BFL-OCI-COMPUTE-ADMIN to manage dedicated-vm-hosts in compartment <COMP>
Allow group BFL-OCI-COMPUTE-ADMIN to read instance-images in compartment <COMP>

# Dependencies
Allow group BFL-OCI-COMPUTE-ADMIN to use virtual-network-family in compartment HOME:BFL-OCI-NETWORK
Allow group BFL-OCI-COMPUTE-ADMIN to use volume-family in compartment HOME:BFL-OCI-STORAGE
```

> `instance-family` + `compute-management-family` cover instances, autoscaling, configs, and pools.citeturn1search11

**Secure Desktops (guidance)**  
Secure Desktops relies on **compute, storage, and networking** permissions and dynamic groups for the **desktop pools**; there isn’t a separate published aggregate family. Use the service’s setup guidance and dynamic-group rules (e.g., `resource.type='desktoppool'`) plus the compute/network/volume policies above.citeturn2search81turn2search84

---
## 2) Storage Administration
**Group:** `BFL-OCI-STORAGE-ADMIN`

```hcl
# Block, File, Object (incl. archive)
Allow group BFL-OCI-STORAGE-ADMIN to manage volume-family in compartment <COMP>
Allow group BFL-OCI-STORAGE-ADMIN to manage file-family in compartment <COMP>
Allow group BFL-OCI-STORAGE-ADMIN to manage object-family in compartment <COMP>
```

> Volume groups/replicas and backups are included under Block Volume family; buckets/objects are under Object Storage family.citeturn2search124turn2search58

---
## 3) Network Administration
**Group:** `BFL-OCI-NETWORK-ADMIN`

```hcl
# Full VCN stack & load balancers
Allow group BFL-OCI-NETWORK-ADMIN to manage virtual-network-family in compartment <COMP>
Allow group BFL-OCI-NETWORK-ADMIN to manage load-balancers in compartment <COMP>
Allow group BFL-OCI-NETWORK-ADMIN to manage network-load-balancers in compartment <COMP>

# DNS
Allow group BFL-OCI-NETWORK-ADMIN to manage dns in compartment <COMP>

# Web Application Acceleration
Allow group BFL-OCI-NETWORK-ADMIN to manage waa-family in compartment <COMP>

# IP Management (insights)
Allow group BFL-OCI-NETWORK-ADMIN to read ipam in tenancy

# Optional troubleshooting visibility
Allow group BFL-OCI-NETWORK-ADMIN to read all-resources in compartment <COMP>
```

> WAA uses the `waa-family` aggregate; IP Address Insights uses the `ipam` resource. Network Command Center tools (Path Analyzer, Visualizer, VTAP/Flow logs) are covered by the underlying networking/logging permissions.citeturn2search79turn2search64turn2search90

---
## 4) Database Administration
**Group:** `BFL-OCI-DATABASE-ADMIN`

```hcl
# Base DB service & Autonomous DB
Allow group BFL-OCI-DATABASE-ADMIN to manage database-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage autonomous-database-family in compartment <COMP>

# Exadata Fleet Update
Allow group BFL-OCI-DATABASE-ADMIN to manage fleet-software-update-family in compartment <COMP>

# Engines & data services
Allow group BFL-OCI-DATABASE-ADMIN to manage mysql-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage postgres-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage nosql-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage opensearch-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage redis-family in compartment <COMP>

# Dependencies (networks & secrets)
Allow group BFL-OCI-DATABASE-ADMIN to use virtual-network-family in compartment HOME:BFL-OCI-NETWORK
Allow group BFL-OCI-DATABASE-ADMIN to use secret-family in compartment HOME:BFL-OCI-SHARED:SEC
Allow group BFL-OCI-DATABASE-ADMIN to use vaults in compartment HOME:BFL-OCI-SHARED:SEC
Allow group BFL-OCI-DATABASE-ADMIN to use keys in compartment HOME:BFL-OCI-SHARED:SEC
```

> `database-family` and `autonomous-database-family` cover the DB services (including globally distributed flavors); Exadata Fleet Update uses `fleet-software-update-family`.citeturn1search23turn1search24turn2search108

### Data Safe (DB Security)
```hcl
Allow group BFL-OCI-DATABASE-ADMIN to manage data-safe-family in compartment <COMP>
```
> Covers Security Assessment, User Assessment, Data Discovery, Masking, Activity Auditing, SQL Firewall features.citeturn2search72

---
## 5) Security Administration
**Group:** `BFL-OCI-SECURITY-ADMIN`

```hcl
# Vault & Secrets
Allow group BFL-OCI-SECURITY-ADMIN to manage vaults in compartment <COMP>
Allow group BFL-OCI-SECURITY-ADMIN to manage keys in compartment <COMP>
Allow group BFL-OCI-SECURITY-ADMIN to manage secret-family in compartment <COMP>

# Certificates
Allow group BFL-OCI-SECURITY-ADMIN to manage certificate-authority-family in compartment <COMP>
Allow group BFL-OCI-SECURITY-ADMIN to manage leaf-certificate-family in compartment <COMP>

# Cloud Guard & Security Zones (tenancy)
Allow group BFL-OCI-SECURITY-ADMIN to manage cloud-guard-family in tenancy
Allow group BFL-OCI-SECURITY-ADMIN to manage security-zone in tenancy
Allow group BFL-OCI-SECURITY-ADMIN to manage security-recipe in tenancy

# WAF & Network Firewall
Allow group BFL-OCI-SECURITY-ADMIN to manage waf-family in compartment <COMP>
Allow group BFL-OCI-SECURITY-ADMIN to manage network-firewall-family in compartment <COMP>

# Scanning (VSS)
Allow group BFL-OCI-SECURITY-ADMIN to manage vss-family in compartment <COMP>

# Bastion & Threat Intelligence
Allow group BFL-OCI-SECURITY-ADMIN to manage bastion-family in compartment <COMP>
Allow group BFL-OCI-SECURITY-ADMIN to manage threat-intelligence-family in tenancy

# API Access Control (Privileged API)
Allow group BFL-OCI-SECURITY-ADMIN to manage privileged-api-family in tenancy

# Delegate & Operator Access Control
Allow group BFL-OCI-SECURITY-ADMIN to manage delegation-management-family in tenancy
Allow group BFL-OCI-SECURITY-ADMIN to manage operator-control-family in tenancy

# Zero Trust Packet Routing (ZPR)
Allow group BFL-OCI-SECURITY-ADMIN to manage zpr-policy in tenancy
Allow group BFL-OCI-SECURITY-ADMIN to manage security-attribute-namespace in tenancy

# Managed Access (Lockbox)
Allow group BFL-OCI-SECURITY-ADMIN to manage lockbox-family in tenancy
```

> Tenancy scope is required for Cloud Guard & Security Zones admin. API Access Control, Delegate Access Control, and Operator Access Control have their own aggregates; ZPR introduces `zpr-policy`/`security-attribute-namespace` resource types; Lockbox uses the `lockbox-family`.citeturn1search30turn1search3turn2search141turn2search143turn2search137turn2search103turn2search99
> Bastion and Threat Intelligence policies are available in the detailed service policy reference.citeturn2search131

---
## 6) Analytics & AI Administration
**Group:** `BFL-OCI-ANALYTICS-ADMIN`

```hcl
Allow group BFL-OCI-ANALYTICS-ADMIN to manage analytics-family in compartment <COMP>
Allow group BFL-OCI-ANALYTICS-ADMIN to manage data-science-family in compartment <COMP>
Allow group BFL-OCI-ANALYTICS-ADMIN to manage dataflow-family in compartment <COMP>
Allow group BFL-OCI-ANALYTICS-ADMIN to manage stream-family in compartment <COMP>
```

> Data Lake services (Data Catalog, Data Integration, Data Flow) and ML are covered by the respective families.citeturn1search21

---
## 7) Developer Services Administration
**Group:** `BFL-OCI-DEVSERVICES-ADMIN`

```hcl
Allow group BFL-OCI-DEVSERVICES-ADMIN to manage cluster-family in compartment <COMP>
Allow group BFL-OCI-DEVSERVICES-ADMIN to manage devops-family in compartment <COMP>
Allow group BFL-OCI-DEVSERVICES-ADMIN to manage api-gateway-family in compartment <COMP>
Allow group BFL-OCI-DEVSERVICES-ADMIN to manage artifact-family in compartment <COMP>
Allow group BFL-OCI-DEVSERVICES-ADMIN to manage container-family in compartment <COMP>
Allow group BFL-OCI-DEVSERVICES-ADMIN to manage orm-family in compartment <COMP>
```

> DevOps aggregate covers projects/repos/pipelines; Resource Manager covers stacks/jobs/providers and private endpoints/templates.citeturn1search40

---
## 8) Observability & Management Administration
**Group:** `BFL-OCI-OBSERVABILITY-ADMIN`

```hcl
# Logging
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage log-groups in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to use log-content in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage unified-configuration in compartment <COMP>

# Monitoring & Alarms
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage metric-family in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage alarms in compartment <COMP>

# Events & Service Connector Hub
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage cloudevents-rules in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage service-connector-family in compartment <COMP>

# Log Analytics & Dashboards
Allow group BFL-OCI-OBSERVABILITY-ADMIN to use loganalytics-features-family in tenancy
Allow group BFL-OCI-OBSERVABILITY-ADMIN to use loganalytics-resources-family in compartment <COMP>

Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage management-dashboard-family in compartment <COMP>

# Java Management Service & WebLogic Management Service
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage jms-family in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage wlm-family in compartment <COMP>

# OS Management (Autonomous Linux & OS Management Hub)
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage osms-family in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage osmh-family in compartment <COMP>

```

> Logging uses `log-groups`/`log-content`/`unified-configuration`; Log Analytics requires feature access at tenancy.citeturn1search37turn1search35
> JMS, WLM, and OS Management Hub/Service families are managed here as documented in the detailed policy references.citeturn2search131turn2search57

---
## 9) Identity Administration (Tenancy)
**Group:** `BFL-OCI-IDENTITY-ADMIN`

```hcl
Allow group BFL-OCI-IDENTITY-ADMIN to manage users in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage groups in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage dynamic-groups in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage policies in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage compartments in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage authentication-policies in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage network-sources in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage tag-namespaces in tenancy
Allow group BFL-OCI-IDENTITY-ADMIN to manage tag-defaults in tenancy
```

> Identity objects live at tenancy/root; manage at tenancy scope.citeturn1search8

---
## 10) Migration & DR Administration
**Group:** `BFL-OCI-MIGRATION-ADMIN`

```hcl
Allow group BFL-OCI-MIGRATION-ADMIN to manage cloud-migrations-family in compartment <COMP>
Allow group BFL-OCI-MIGRATION-ADMIN to manage data-transfer-family in compartment <COMP>
Allow group BFL-OCI-MIGRATION-ADMIN to manage disaster-recovery-family in compartment <COMP>
```

> Full Stack Disaster Recovery and Data Transfer are covered by their aggregates.citeturn1search21

---
## 11) Hybrid & Multicloud Administration
**Group:** `BFL-OCI-HYBRID-ADMIN`

```hcl
Allow group BFL-OCI-HYBRID-ADMIN to manage vmware-family in compartment <COMP>
Allow group BFL-OCI-HYBRID-ADMIN to manage multicloud-family in compartment <COMP>
Allow group BFL-OCI-HYBRID-ADMIN to manage rover-family in compartment <COMP>
```

> Multicloud Hub uses `multicloud-family`; VMware Solution uses `vmware-family`; Roving Edge uses `rover-family`.citeturn2search52turn1search26

---
## 12) Governance & Administration
**Group:** `BFL-OCI-GOVERNANCE-ADMIN`

```hcl
Allow group BFL-OCI-GOVERNANCE-ADMIN to manage cloud-advisor-family in tenancy
Allow group BFL-OCI-GOVERNANCE-ADMIN to read limits in tenancy
Allow group BFL-OCI-GOVERNANCE-ADMIN to read audit-events in tenancy
```

> Common governance patterns per Oracle templates.citeturn1search14

---
## 13) Billing & Cost Management (Tenancy)
**Group:** `BFL-OCI-BILLING-ADMIN`

```hcl
# Budgets
Allow group BFL-OCI-BILLING-ADMIN to manage budgets in tenancy

# Invoices / Subscriptions / Rates (read-only)
Allow group BFL-OCI-BILLING-ADMIN to read invoices in tenancy
Allow group BFL-OCI-BILLING-ADMIN to read subscription in tenancy
Allow group BFL-OCI-BILLING-ADMIN to read rate-cards in tenancy

# Cost Reports (Oracle-owned bucket grant)
define tenancy usage-report as ocid1.tenancy.oc1..aaaaaaaaned4fkpkisbwjlr56u7cj63lf3wffbilvqknstgtvzub7vhqkggq
endorse group BFL-OCI-BILLING-ADMIN to read objects in tenancy usage-report
```

> Resource types for invoices/subscriptions/rate cards are documented. Cost/FOCUS reports require `define/endorse` to the Oracle tenancy that hosts the bucket.citeturn2search123turn1search45

**Scheduled Reports – service policy (Object Storage write)**
```hcl
# Create in the bucket’s compartment so Cost Analysis scheduled reports can write
Allow service metering_overlay to manage objects in compartment <COMP> where all {target.bucket.name = '<BUCKET-NAME>', any {request.permission='OBJECT_CREATE', request.permission='OBJECT_DELETE', request.permission='OBJECT_READ'}}
```
> Allows the Cost service to write scheduled report objects to your bucket.citeturn2search127

---
## Appendix A – Coverage Notes for Your List
- **DNS management** (public/private zones, views, resolvers, TSIG, redirects): covered by `manage dns` at compartment scope.citeturn1search9  
- **Customer connectivity** (IPSec, CPE, DRG, VC): included in `virtual-network-family`.citeturn2search124  
- **Network Command Center** (Visualizer, Path Analyzer, VTAP/Flow Logs, Inter‑region latency): surfaced through Networking + Logging permissions; no separate IAM family.citeturn2search90  
- **IP Address Insights**: uses `ipam` with `inspect/read` (we grant **read** at tenancy).citeturn2search64  
- **Globally Distributed AI/Exascale DB variants**: managed via `autonomous-database-family` / `database-family`.citeturn1search21  
- **Data Safe features** (Security assessment, User assessment, Data discovery, Masking, Activity auditing, SQL Firewall): included under `data-safe-family`.citeturn2search72  
- **API Access Control** (API controls/access requests): `privileged-api-family`.citeturn2search141  
- **Delegate Access Control** (delegations/access requests): `delegation-management-family`.citeturn2search143  
- **Operator Access Control**: `operator-control-family`.citeturn2search137  
- **Web Application Acceleration**: `waa-family`.citeturn2search79  
- **Multicloud Hub** (subscriptions/resources anchors, network anchors): `multicloud-family`.citeturn2search52  
- **Oracle Support Rewards** (**Programs & Rewards**) are visible under Billing; access follows billing/subscription permissions; redemption happens in Billing Center.citeturn2search129turn2search132

---
## Appendix B – References
- Policy verbs/syntax and resource families.citeturn1search25turn1search19turn1search11  
- Logging policy reference.citeturn1search37  
- DevOps policy reference.citeturn1search40  
- Cloud Guard & Security Zones.citeturn1search30turn1search3  
- ZPR overview & policy reference.citeturn2search102turn2search103  
- Exadata Fleet Update policies.citeturn2search108  
- Multicloud Hub policies.citeturn2search52  
- IP Address Insights.citeturn2search64  
- Billing invoices/subscriptions policies & scheduled reports.citeturn2search123turn2search127  
- Secure Desktops setup/policies.citeturn2search81turn2search84  
