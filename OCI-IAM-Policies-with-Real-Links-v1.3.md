
# OCI Service-Level Admin IAM Policies (Expanded Coverage)

**Owner:** Ganesh Shinde – Senior Domain Manager, Data Center  
**Version:** 1.3  
**Last Updated:** 21-Jan-2026  

This edition removes internal citations and adds clickable Oracle docs links for every new or nuanced service family. It also cross‑checks your requested services and adds any missing IAM policy entries or guidance. Use families where possible to auto‑include newly added resource types.

---
## 0) Quick Additions at a Glance
- Web Application Acceleration (WAA) — see Docs below
- Multicloud Hub — see Docs below
- IP Address Insights — see Docs below
- Zero Trust Packet Routing (ZPR) — see Docs below
- Exadata Fleet Update — see Docs below
- Data Safe (DB security features) — see Docs below
- API Access Control (Privileged API) — see Docs below
- Delegate Access Control — see Docs below
- Operator Access Control — see Docs below
- Billing: Invoices/Subscriptions/Rate cards (read) + Scheduled Reports service policy — see Docs below

**Docs:**
- Core policy syntax and service policy reference:  
  - https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policysyntax.htm  
  - https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policyreference.htm

---
## 1) Compute Administration
**Group:** `BFL-OCI-COMPUTE-ADMIN`

```hcl
# Core compute & management
Allow group BFL-OCI-COMPUTE-ADMIN to manage instance-family in compartment <COMP>
Allow group BFL-OCI-COMPUTE-ADMIN to manage compute-management-family in compartment <COMP>

# Dedicated hosts & custom images
Allow group BFL-OCI-COMPUTE-ADMIN to manage dedicated-vm-hosts in compartment <COMP>
Allow group BFL-OCI-COMPUTE-ADMIN to read instance-images in compartment <COMP>

# Dependencies
Allow group BFL-OCI-COMPUTE-ADMIN to use virtual-network-family in compartment HOME:BFL-OCI-NETWORK
Allow group BFL-OCI-COMPUTE-ADMIN to use volume-family in compartment HOME:BFL-OCI-STORAGE
```

**Secure Desktops (guidance)**  
Secure Desktops relies on compute, storage, and networking permissions and a dynamic group for desktop pools (e.g., `resource.type='desktoppool'`). Use the above compute/network/volume policies plus the service setup guidance.  
**Docs:**  
- https://docs.oracle.com/en/solutions/oci-tenancy-secure-desktop-pool/index.html  
- https://docs.public.oneportal.content.oci.oraclecloud.com/iaas/secure-desktops/policies.htm

---
## 2) Storage Administration
**Group:** `BFL-OCI-STORAGE-ADMIN`

```hcl
Allow group BFL-OCI-STORAGE-ADMIN to manage volume-family in compartment <COMP>
Allow group BFL-OCI-STORAGE-ADMIN to manage file-family in compartment <COMP>
Allow group BFL-OCI-STORAGE-ADMIN to manage object-family in compartment <COMP>
```

**Docs:**
- Object Storage/Archive policy reference: https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/objectstoragepolicyreference.htm

---
## 3) Network Administration
**Group:** `BFL-OCI-NETWORK-ADMIN`

```hcl
# VCN stack & LBs
Allow group BFL-OCI-NETWORK-ADMIN to manage virtual-network-family in compartment <COMP>
Allow group BFL-OCI-NETWORK-ADMIN to manage load-balancers in compartment <COMP>
Allow group BFL-OCI-NETWORK-ADMIN to manage network-load-balancers in compartment <COMP>

# DNS (public/private zones, views, resolvers, TSIG, redirects)
Allow group BFL-OCI-NETWORK-ADMIN to manage dns in compartment <COMP>

# Web Application Acceleration
Allow group BFL-OCI-NETWORK-ADMIN to manage waa-family in compartment <COMP>

# IP Address Insights (read-only recommended)
Allow group BFL-OCI-NETWORK-ADMIN to read ipam in tenancy
```

**Docs:**
- WAA policy reference: https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/waapolicyreference.htm  
- WAA overview: https://docs.oracle.com/en-us/iaas/Content/web-app-acceleration/overview.htm  
- IP Address Insights: https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/ip_inventory.htm  
- DNS policy reference: https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/dnspolicyreference.htm  
- Network Command Center overview: https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/net_command_center.htm

---
## 4) Database Administration
**Group:** `BFL-OCI-DATABASE-ADMIN`

```hcl
# Base DB service & Autonomous DB (incl. globally distributed/exascale variants)
Allow group BFL-OCI-DATABASE-ADMIN to manage database-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage autonomous-database-family in compartment <COMP>

# Exadata Fleet Update (FSU)
Allow group BFL-OCI-DATABASE-ADMIN to manage fleet-software-update-family in compartment <COMP>

# Engines & data services
Allow group BFL-OCI-DATABASE-ADMIN to manage mysql-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage postgres-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage nosql-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage opensearch-family in compartment <COMP>
Allow group BFL-OCI-DATABASE-ADMIN to manage redis-family in compartment <COMP>

# Dependencies
Allow group BFL-OCI-DATABASE-ADMIN to use virtual-network-family in compartment HOME:BFL-OCI-NETWORK
Allow group BFL-OCI-DATABASE-ADMIN to use secret-family in compartment HOME:BFL-OCI-SHARED:SEC
Allow group BFL-OCI-DATABASE-ADMIN to use vaults in compartment HOME:BFL-OCI-SHARED:SEC
Allow group BFL-OCI-DATABASE-ADMIN to use keys in compartment HOME:BFL-OCI-SHARED:SEC
```

### Data Safe (DB Security)
```hcl
Allow group BFL-OCI-DATABASE-ADMIN to manage data-safe-family in compartment <COMP>
```

**Docs:**  
- Exadata Fleet Update policies: https://docs.oracle.com/en-us/iaas/exadata-fleet-update/doc/policy-details-for-exadata-fleet-update.html  
- Data Safe IAM and features: https://docs.oracle.com/en/cloud/paas/data-safe/dsiad/datasafe_iam.html

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

# Cloud Guard & Security Zones (tenancy scope)
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

**Docs:**
- Cloud Guard policies: https://docs.oracle.com/en-us/iaas/Content/cloud_guard/policies.htm  
- Security Zones: https://docs.oracle.com/en-us/iaas/Content/SecurityZones/Concepts/securityzonestopics.htm  
- API Access Control: https://docs.oracle.com/en-us/iaas/oracle-api-access-control/doc/create-iam-policies-of-oracle-api-access-control.html  
- Delegate Access Control: https://docs.oracle.com/en-us/iaas/delegate-access-control/doc/create-policies-to-control-operator-access.html  
- Operator Access Control: https://docs.oracle.com/en-us/iaas/operator-access-control/doc/policy-details.html  
- ZPR policy reference: https://docs.oracle.com/en-us/iaas/Content/zero-trust-packet-routing/policy-reference.htm  
- Managed Access (Lockbox): https://docs.oracle.com/en-us/iaas/Content/managed-access/iam-policies.htm

---
## 6) Analytics & AI Administration
**Group:** `BFL-OCI-ANALYTICS-ADMIN`

```hcl
Allow group BFL-OCI-ANALYTICS-ADMIN to manage analytics-family in compartment <COMP>
Allow group BFL-OCI-ANALYTICS-ADMIN to manage data-science-family in compartment <COMP>
Allow group BFL-OCI-ANALYTICS-ADMIN to manage dataflow-family in compartment <COMP>
Allow group BFL-OCI-ANALYTICS-ADMIN to manage stream-family in compartment <COMP>
```

**Docs:**  
- Policy syntax/reference:  
  - https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policysyntax.htm  
  - https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policyreference.htm

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

**Docs:**
- DevOps policies: https://docs.oracle.com/en-us/iaas/Content/devops/using/devops_policies.htm

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

# Java Management Service, WebLogic Management Service, OS Management/OSMH
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage jms-family in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage wlm-family in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage osms-family in compartment <COMP>
Allow group BFL-OCI-OBSERVABILITY-ADMIN to manage osmh-family in compartment <COMP>
```

**Docs:**
- Logging policies: https://docs.oracle.com/en-us/iaas/Content/Logging/Reference/policies.htm  
- Monitoring overview (metrics/alarms): https://docs.oracle.com/en-us/iaas/Content/Monitoring/Concepts/monitoringoverview.htm  
- OS Management Hub policies: https://docs.oracle.com/en-us/iaas/osmh/doc/policies.htm

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

**Docs:**
- Policy syntax/reference:  
  - https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policysyntax.htm  
  - https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policyreference.htm

---
## 10) Migration & DR Administration
**Group:** `BFL-OCI-MIGRATION-ADMIN`

```hcl
Allow group BFL-OCI-MIGRATION-ADMIN to manage cloud-migrations-family in compartment <COMP>
Allow group BFL-OCI-MIGRATION-ADMIN to manage data-transfer-family in compartment <COMP>
Allow group BFL-OCI-MIGRATION-ADMIN to manage disaster-recovery-family in compartment <COMP>
```

**Docs:**  
- Service policy reference (master): https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policyreference.htm

---
## 11) Hybrid & Multicloud Administration
**Group:** `BFL-OCI-HYBRID-ADMIN`

```hcl
Allow group BFL-OCI-HYBRID-ADMIN to manage vmware-family in compartment <COMP>
Allow group BFL-OCI-HYBRID-ADMIN to manage multicloud-family in compartment <COMP>
Allow group BFL-OCI-HYBRID-ADMIN to manage rover-family in compartment <COMP>
```

**Docs:**
- Multicloud Hub policy reference: https://docs.oracle.com/en-us/iaas/Content/multicloud-hub/policy-reference.htm  
- Multicloud Hub overview: https://docs.oracle.com/en-us/iaas/Content/multicloud-hub/overview.htm

---
## 12) Governance & Administration
**Group:** `BFL-OCI-GOVERNANCE-ADMIN`

```hcl
Allow group BFL-OCI-GOVERNANCE-ADMIN to manage cloud-advisor-family in tenancy
Allow group BFL-OCI-GOVERNANCE-ADMIN to read limits in tenancy
Allow group BFL-OCI-GOVERNANCE-ADMIN to read audit-events in tenancy
```

**Docs:**
- Policy templates/common patterns: https://docs.oracle.com/en-us/iaas/Content/Identity/policiescommon/commonpolicies.htm

---
## 13) Billing & Cost Management (Tenancy)
**Group:** `BFL-OCI-BILLING-ADMIN`

```hcl
# Budgets
Allow group BFL-OCI-BILLING-ADMIN to manage budgets in tenancy

# Invoices / Subscriptions / Rate cards (read-only)
Allow group BFL-OCI-BILLING-ADMIN to read invoices in tenancy
Allow group BFL-OCI-BILLING-ADMIN to read subscription in tenancy
Allow group BFL-OCI-BILLING-ADMIN to read rate-cards in tenancy

# Cost Analysis Scheduled Reports (Object Storage write by service principal)
Allow service metering_overlay to manage objects in compartment <COMP> where all {
  target.bucket.name = '<BUCKET-NAME>',
  any {request.permission='OBJECT_CREATE', request.permission='OBJECT_DELETE', request.permission='OBJECT_READ'}
}
```

**Docs:**  
- Subscriptions/Invoices/Payments policy reference: https://docs.oracle.com/en-us/iaas/Content/Identity/policyreference/subsinvoicepaymenthistoryreference.htm  
- Scheduled Reports: https://docs.oracle.com/en-us/iaas/Content/Billing/Concepts/scheduledreportoverview.htm  
- Oracle Support Rewards overview: https://docs.oracle.com/en-us/iaas/Content/Billing/Concepts/supportrewardsoverview.htm

---
## Appendix A – Coverage Notes
- **Customer connectivity** (DRG, FastConnect, IPSec, CPE) is included in `virtual-network-family`.
- **Network Command Center** tools (Visualizer, Path Analyzer, VTAP/Flow Logs, Inter‑region latency) use your Networking and Logging permissions.
- **Secure Desktops** uses compute/network/volume permissions + dynamic group; no separate IAM family.

