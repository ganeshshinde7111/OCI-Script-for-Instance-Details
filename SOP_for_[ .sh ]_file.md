# Standard Operating Procedure (SOP)
## OCI Instance Details Collection Script

### Document Information
- **Purpose**: Collect comprehensive instance details across entire OCI tenancy
- **Audience**: System Administrators, Cloud Engineers, DevOps Teams
- **Last Updated**: December 2024
- **Version**: 1.0

---

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Setup Instructions](#setup-instructions)
4. [Execution Steps](#execution-steps)
5. [Understanding the Output](#understanding-the-output)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Overview

### What does this script do?
This script collects detailed information about **all compute instances** across your entire OCI (Oracle Cloud Infrastructure) tenancy and exports the data to a CSV file.

### What information is collected?
The script gathers 25 different data points for each instance:
- Basic info (name, OCID, state, region)
- Compute resources (OCPUs, memory)
- Network details (IPs, VCNs, subnets)
- Storage details (boot volume, block volumes)
- Configuration (shape, OS, platform config)
- Metadata (tags, creation time)

### Why use this script?
- **Inventory Management**: Get a complete inventory of all instances
- **Capacity Planning**: Understand resource utilization
- **Cost Optimization**: Identify unused or oversized instances
- **Compliance Auditing**: Document your infrastructure
- **Migration Planning**: Export data for analysis

---

## Prerequisites

### 1. Access Requirements
✅ **You need:**
- Access to OCI Cloud Shell OR a Linux/Mac terminal with OCI CLI installed
- OCI user account with **Read permissions** on:
  - Compute Instances
  - Networking (VCNs, Subnets, VNICs)
  - Block Storage (Boot Volumes, Block Volumes)
  - IAM (Compartments)

✅ **Recommended Access Level:**
- Read access across all compartments (or specific compartments you want to audit)

### 2. Software Requirements
The script requires the following tools (already available in OCI Cloud Shell):
- **OCI CLI** (Oracle Cloud Infrastructure Command Line Interface)
- **jq** (JSON processor)
- **bash** (Shell environment)

### 3. Time Estimate
- Small tenancy (< 50 instances): 2-5 minutes
- Medium tenancy (50-200 instances): 5-15 minutes
- Large tenancy (200+ instances): 15-30+ minutes

---

## Setup Instructions

### Option 1: Using OCI Cloud Shell (Recommended for Beginners)

#### Step 1: Access OCI Cloud Shell
1. Log in to [OCI Console](https://cloud.oracle.com/)
2. Click the **Cloud Shell icon** (>_) in the top-right corner of the console
3. Wait for Cloud Shell to initialize (15-30 seconds)

#### Step 2: Create a Working Directory
```bash
# Create a directory for scripts
mkdir -p ~/Scripts
cd ~/Scripts
```

#### Step 3: Create the Script File
```bash
# Create the script file
nano oci_instance_details.sh
```

#### Step 4: Copy the Script
1. Copy the entire script content from the artifact
2. Paste it into the nano editor (Right-click → Paste, or Ctrl+Shift+V)
3. Save and exit:
   - Press `Ctrl + X`
   - Press `Y` to confirm
   - Press `Enter` to save

#### Step 5: Make the Script Executable
```bash
chmod +x oci_instance_details.sh
```

#### Step 6: Verify the Script
```bash
# Check if the file was created
ls -lh oci_instance_details.sh

# You should see something like:
# -rwxr-xr-x 1 ganesh_shi oci 9.8K Dec 15 10:30 oci_instance_details.sh
```

### Option 2: Using Local Terminal (Advanced Users)

If you're using your local machine instead of Cloud Shell:

#### Prerequisites Check
```bash
# Check if OCI CLI is installed
oci --version

# Check if jq is installed
jq --version

# If not installed, install them:
# For Mac: brew install oci-cli jq
# For Linux: Follow OCI CLI installation guide
```

#### Configuration Check
```bash
# Verify OCI CLI is configured
oci iam region list

# If not configured, run:
oci setup config
```

---

## Execution Steps

### Step 1: Navigate to Script Directory
```bash
cd ~/Scripts
```

### Step 2: Run the Script
```bash
./oci_instance_details.sh
```

### Step 3: Monitor Progress
You'll see output like this:
```
Starting OCI Instance Details Collection...
===========================================
Fetching all compartments...
Found root compartment: YourTenancyName

Processing compartment: YourTenancyName (root)
  No instances found in this compartment

Found 19 additional compartments to process

Processing compartment: Production
  Processing instance: ocid1.instance.oc1.ap-mumbai-1.xxxxx
  ✓ Instance processed successfully
  Processing instance: ocid1.instance.oc1.ap-mumbai-1.yyyyy
  ✓ Instance processed successfully

Processing compartment: Development
  Processing instance: ocid1.instance.oc1.ap-mumbai-1.zzzzz
  ✓ Instance processed successfully
...
```

### Step 4: Wait for Completion
The script will display a completion message:
```
===========================================
✓ Collection complete!
✓ Output file: oci_instances_full_20241215_103045.csv
===========================================

Total instances found: 42
```

### Step 5: Locate the Output File
```bash
# List the generated CSV files
ls -lh oci_instances_full_*.csv

# The filename includes a timestamp:
# oci_instances_full_YYYYMMDD_HHMMSS.csv
```

---

## Understanding the Output

### Downloading the CSV File

#### From Cloud Shell:
1. Click the **Cloud Shell menu** (three dots) in the top-right
2. Select **Download**
3. Enter the full path: `/home/your_username/Scripts/oci_instances_full_20241215_103045.csv`
4. Click **Download**

#### Alternative Method:
```bash
# View the file in Cloud Shell
cat oci_instances_full_20241215_103045.csv

# Or copy to Object Storage for download
oci os object put --bucket-name your-bucket --file oci_instances_full_20241215_103045.csv
```

### CSV Column Descriptions

| Column Name | Description | Example |
|-------------|-------------|---------|
| **instance_name** | Display name of the instance | `prod-web-server-01` |
| **instance_ocid** | Unique Oracle Cloud ID | `ocid1.instance.oc1...` |
| **lifecycle_state** | Current state | `RUNNING`, `STOPPED` |
| **region** | OCI region location | `ap-mumbai-1` |
| **compartment_name** | Compartment display name | `Production` |
| **compartment_id** | Compartment OCID | `ocid1.compartment...` |
| **availability_domain** | Availability Domain | `hKPE:AP-MUMBAI-1-AD-1` |
| **fault_domain** | Fault Domain | `FAULT-DOMAIN-1` |
| **shape** | Instance shape/size | `VM.Standard.E4.Flex` |
| **shape_ocpus** | Number of CPU cores | `2` |
| **shape_memory_gb** | RAM in gigabytes | `16` |
| **image_id** | OS image OCID | `ocid1.image.oc1...` |
| **image_name** | Operating system name | `Oracle-Linux-8.8-2023.10.24-0` |
| **os_family** | OS type | `Oracle Linux` |
| **time_created** | Instance creation date/time | `2023-11-15T08:30:45.123Z` |
| **freeform_tags** | User-defined tags | `Environment=Prod; Owner=TeamA` |
| **defined_tags** | Namespace-qualified tags | `Operations.CostCenter=12345` |
| **private_ips** | Private IP addresses | `10.0.1.15; 10.0.2.20` |
| **public_ips** | Public IP addresses | `203.0.113.42` |
| **vcns** | Virtual Cloud Network names | `prod-vcn` |
| **subnets** | Subnet names | `public-subnet-01` |
| **boot_volume_name** | Boot disk name | `boot-volume-prod-web-01` |
| **boot_volume_size_gb** | Boot disk size | `50` |
| **block_volumes** | Additional attached volumes | `data-vol-01(100GB); logs-vol(50GB)` |
| **platform_config** | Platform-specific settings | `type=AMD_VM; secure-boot=true` |

### Opening in Excel/Google Sheets
1. Open Microsoft Excel or Google Sheets
2. Click **File → Open** or **File → Import**
3. Select your CSV file
4. The data will automatically populate in columns
5. Use filters and pivot tables for analysis

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: "Permission denied" when running script
**Symptom:**
```
-bash: ./oci_instance_details.sh: Permission denied
```
**Solution:**
```bash
chmod +x oci_instance_details.sh
```

---

#### Issue 2: "jq: command not found"
**Symptom:**
```
./oci_instance_details.sh: line 25: jq: command not found
```
**Solution:**
```bash
# In Cloud Shell, jq should be pre-installed
# If not, install it:
sudo yum install jq -y    # For Oracle Linux
# OR
sudo apt-get install jq   # For Ubuntu/Debian
```

---

#### Issue 3: "Unable to fetch compartments"
**Symptom:**
```
Error: Unable to fetch compartments. Check your OCI CLI configuration.
```
**Solution:**
```bash
# Test OCI CLI connectivity
oci iam region list

# If this fails, reconfigure OCI CLI:
oci setup config
```

---

#### Issue 4: "Only headers in CSV, no data"
**Symptom:**
CSV file only contains the header row, no instance data.

**Solution:**
```bash
# Check if you have instances
oci compute instance list --all --query 'data[].id'

# If empty, you may not have instances or permissions
# Check your IAM policies
```

---

#### Issue 5: Script takes too long / times out
**Symptom:**
Script runs for 30+ minutes or appears stuck.

**Solution:**
- This is normal for large tenancies (200+ instances)
- The script processes each instance sequentially
- You can monitor progress in real-time
- Consider running during off-hours

**To run in background:**
```bash
nohup ./oci_instance_details.sh > script_output.log 2>&1 &

# Check progress:
tail -f script_output.log
```

---

#### Issue 6: "ERROR: Could not fetch instance details"
**Symptom:**
```
Processing instance: ocid1.instance...
ERROR: Could not fetch instance details
```

**Possible Causes:**
1. Instance was deleted/terminated during script execution
2. Insufficient permissions
3. Network connectivity issue

**Solution:**
- Ignore if only a few instances fail
- If many fail, check IAM permissions
- Re-run the script if needed

---

## Best Practices

### 1. Schedule Regular Exports
Run the script monthly or quarterly to track infrastructure changes:
```bash
# Add to crontab for monthly execution
# Run on 1st of each month at 2 AM
0 2 1 * * /home/your_user/Scripts/oci_instance_details.sh
```

### 2. Archive Historical Data
Keep CSV files for trend analysis:
```bash
# Create archive directory
mkdir -p ~/oci_reports/archive

# Move old reports
mv oci_instances_full_*.csv ~/oci_reports/archive/
```

### 3. Use Filters in Excel
After opening the CSV:
1. Select all data (Ctrl+A)
2. Click **Data → Filter**
3. Use dropdown arrows to filter by:
   - Compartment
   - Region
   - Lifecycle State
   - Shape

### 4. Create Summary Reports
Use Excel Pivot Tables to analyze:
- Instances per compartment
- Total OCPUs and memory by region
- Instances by lifecycle state
- Storage utilization summary

### 5. Security Considerations
- The CSV contains OCIDs but no sensitive data
- Do not share publicly as it reveals your infrastructure
- Store securely with appropriate access controls
- Consider encrypting archived reports

### 6. Performance Tips
For very large tenancies (500+ instances):
- Run during off-peak hours
- Use background execution with `nohup`
- Consider filtering by specific compartments if you don't need all data

---

## Appendix

### Quick Reference Commands

```bash
# Navigate to scripts directory
cd ~/Scripts

# Run the script
./oci_instance_details.sh

# List generated files
ls -lh oci_instances_full_*.csv

# View CSV content
cat oci_instances_full_20241215_103045.csv

# Count total instances in CSV
wc -l oci_instances_full_20241215_103045.csv

# Search for specific instance
grep "instance-name" oci_instances_full_20241215_103045.csv

# Run in background
nohup ./oci_instance_details.sh > output.log 2>&1 &

# Check background job
tail -f output.log
```

### Getting Help

If you encounter issues not covered in this SOP:
1. Check OCI CLI documentation: https://docs.oracle.com/iaas/tools/oci-cli/
2. Review IAM policies for required permissions
3. Contact your OCI administrator
4. Check Oracle Cloud support resources

---

## Revision History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | Dec 2024 | Initial document creation | Ganesh Shinde |

---

**End of Document**
