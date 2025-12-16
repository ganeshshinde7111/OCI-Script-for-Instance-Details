Statements

Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage instance-family in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage file-family in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage object-family in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage boot-volume in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to use cloud-shell in tenancy
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to read all-resources in tenancy
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage stack-monitoring-family in tenancy
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to use virtual-network-family in tenancy
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage alarms in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to read metrics in tenancy
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage ons-topics in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage ons-subscriptions in tenancy
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage volume-family in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage block-volume in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage load-balancers in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to use keys in compartment HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to use vaults in compartment HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage volumes in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage backup-policies in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage volume-backups in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage tag-namespaces in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage tag-defaults in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage management-agents in tenancy where request.permission!='*_DELETE'
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to use management-agent-plugins in tenancy



The issue is that the user has **insufficient permissions to use customer-managed encryption keys** for block volumes and boot volumes. Here's the problem and solution:

## Root Cause

The user has these permissions:
- `use keys` in compartment `HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC`
- `use vaults` in compartment `HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC`

However, to assign customer-managed keys to volumes, the user needs **`manage`** permissions, not just **`use`** permissions for keys.

## Required Permissions for Customer-Managed Key Assignment

To assign customer-managed encryption keys to block volumes and boot volumes, the user needs:

### 1. **Key Management Permissions** (MISSING)
```
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage keys in compartment HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC
```

### 2. **Additional Required Permission** (if not already granted)
The user also needs permission to manage key-delegates:
```
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to use key-delegate in compartment HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC
```

## Solution

Add these two policy statements to the existing IAM policies:

```
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to manage keys in compartment HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC
Allow group BFL-OCI-IDT/SG-BFL-OCI-PRD-SRV-ADMIN to use key-delegate in compartment HOME:BFL-OCI-SHARED:BFL-OCI-SHARED-SEC
```

## Why This Happens

- **`use keys`** allows reading key metadata but not using the key for encryption operations
- **`manage keys`** allows full key operations including encrypting/decrypting data
- **`use key-delegate`** allows the Block Volume service to use the key on behalf of the user

## Verification Steps

After adding the permissions:
1. Wait 1-2 minutes for IAM policy propagation
2. Have the user log out and log back in
3. Try assigning the customer-managed key to a block volume or boot volume again

The unauthorized access error should be resolved.
