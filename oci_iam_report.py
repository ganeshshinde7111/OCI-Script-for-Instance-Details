import oci
import pandas as pd
import re

# Load OCI config
config = oci.config.from_file("~/.oci/config")
identity_client = oci.identity.IdentityClient(config)
tenancy_id = config["tenancy"]

rows = []

# Fetch all groups
groups = identity_client.list_groups(compartment_id=tenancy_id).data

# Fetch all IdPs (Federated Identity Providers)
idps = identity_client.list_identity_providers(compartment_id=tenancy_id, protocol="SAML2").data
idp_mappings = {}
for idp in idps:
    mappings = identity_client.list_idp_group_mappings(identity_provider_id=idp.id).data
    for mapping in mappings:
        idp_mappings[mapping.group_name] = mapping.idp_group_name  # OCI group → IdP group

# Fetch all policies
policies = identity_client.list_policies(compartment_id=tenancy_id).data

# Fetch user-group memberships for local users
memberships = identity_client.list_user_group_memberships(compartment_id=tenancy_id).data

for group in groups:
    # Get local users in the group
    user_ids = [m.user_id for m in memberships if m.group_id == group.id]
    user_names = []
    for uid in user_ids:
        user = identity_client.get_user(uid).data
        user_names.append(user.name)

    # Get IdP mapping if exists
    idp_group_name = idp_mappings.get(group.name, None)

    # Find policies referencing this group
    for policy in policies:
        for stmt in policy.statements:
            if f"group {group.name}" in stmt:
                # Extract permissions and resource types
                perm_match = re.search(r"\b(manage|read|inspect|use)\b", stmt)
                resource_match = re.search(r"\b(all-resources|instance|volume|network)\b", stmt)
                permission = perm_match.group(1) if perm_match else None
                resource_type = resource_match.group(1) if resource_match else None

                rows.append({
                    "oci_group_name": group.name,
                    "oci_group_id": group.id,
                    "users": ", ".join(user_names) if user_names else "Federated Only",
                    "idp_group_name": idp_group_name,
                    "policy_name": policy.name,
                    "policy_id": policy.id,
                    "statement": stmt,
                    "permission": permission,
                    "resource_type": resource_type
                })

# Convert to DataFrame
df = pd.DataFrame(rows)
df.to_csv("oci_iam_report.csv", index=False)

print("✅ Consolidated report saved as oci_iam_report.csv")
