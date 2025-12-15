# This script collects comprehensive details of all OCI instances across a tenancy and outputs the information in a CSV format. It includes instance metadata, network details, and associated resources. 
# Like below Fields Included:

instance_name - Display name of the instance\
instance_ocid - Instance OCID\
lifecycle_state - Current state (RUNNING, STOPPED, etc.)
region - Region where instance is located
compartment_name - Name of the compartment
compartment_id - Compartment OCID
availability_domain - AD where instance is running
fault_domain - Fault domain
shape - Instance shape (VM.Standard.E4.Flex, etc.)
shape_ocpus - Number of OCPUs
shape_memory_gb - Memory in GB
image_id - Image OCID
image_name - OS image display name
os_family - Operating system family
time_created - Instance creation timestamp
freeform_tags - All freeform tags (key=value pairs)
defined_tags - All defined tags
private_ips - All private IP addresses
public_ips - All public IP addresses
vcns - VCN names
subnets - Subnet names
boot_volume_name - Boot volume display name
boot_volume_size_gb - Boot volume size
block_volumes - All attached block volumes with sizes
platform_config - Platform configuration details
