# Standard Operating Procedure (SOP)
## OCI Instance Details Exporter

---

**Document Version:** 1.0  
**Last Updated:** December 2024  
**Prepared For:** Cloud Operations Team  
**Purpose:** Export comprehensive instance details from Oracle Cloud Infrastructure (OCI) to CSV format

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Initial Setup (One-Time)](#initial-setup)
4. [Execution Procedure](#execution-procedure)
5. [Verification](#verification)
6. [Troubleshooting Guide](#troubleshooting-guide)
7. [Maintenance](#maintenance)
8. [Appendix](#appendix)

---

## Overview

### Purpose
This document provides step-by-step instructions for setting up and executing the OCI Instance Details Exporter script. The script automatically collects comprehensive information about all compute instances across your OCI tenancy and exports the data to CSV format.

### Scope
- Applies to all OCI tenancies
- Covers all regions subscribed to your tenancy
- Works on Windows, Linux, and macOS

### Expected Output
A CSV file containing the following information for each instance:
- Instance identification (name, OCID, state)
- Location details (region, compartment, availability domain)
- Compute specifications (shape, OCPUs, memory)
- Network configuration (IPs, VCNs, subnets)
- Storage details (boot volumes, block volumes)
- Metadata (tags, creation time, platform config)

### Estimated Time
- **Initial Setup:** 30-45 minutes (one-time)
- **Subsequent Executions:** 5-30 minutes (depending on environment size)

---

## Prerequisites

### Technical Requirements

| Requirement | Minimum Version | How to Check |
|-------------|-----------------|--------------|
| Python | 3.6 or higher | `python --version` |
| OCI Python SDK | Latest | `pip show oci` |
| Internet Access | Required | Test connectivity to oci.oraclecloud.com |
| Disk Space | 100 MB free | `df -h` (Linux/Mac) or check drive properties (Windows) |

### Access Requirements

✅ Active OCI Account  
✅ OCI User credentials (username and password)  
✅ Ability to generate API keys  
✅ IAM permissions (see Section 3.4)

### Skills Required

- Basic command line/terminal usage
- Ability to edit text files
- Basic understanding of OCI console navigation

---

## Initial Setup (One-Time)

### Step 1: Install Python

#### For Windows:

1. Download Python from [https://www.python.org/downloads/](https://www.python.org/downloads/)
2. Run the installer
3. **IMPORTANT:** Check "Add Python to PATH" during installation
4. Click "Install Now"
5. Verify installation:
   ```cmd
   python --version
   ```
   Expected output: `Python 3.x.x`

#### For macOS:

1. Open Terminal (Applications → Utilities → Terminal)
2. Install using Homebrew:
   ```bash
   brew install python3
   ```
   Or download from [python.org](https://www.python.org/downloads/)
3. Verify:
   ```bash
   python3 --version
   ```

#### For Linux:

1. Open Terminal
2. Install Python:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install python3 python3-pip
   
   # RedHat/CentOS
   sudo yum install python3 python3-pip
   ```
3. Verify:
   ```bash
   python3 --version
   ```

**✓ Checkpoint:** Python version displayed successfully

---

### Step 2: Install OCI Python SDK

1. Open Command Prompt (Windows) or Terminal (Mac/Linux)

2. Install the SDK:
   ```bash
   pip install oci
   ```
   
   **Note:** On some systems, use `pip3` instead:
   ```bash
   pip3 install oci
   ```

3. Wait for installation to complete (may take 2-3 minutes)

4. Verify installation:
   ```bash
   python -c "import oci; print('OCI SDK installed successfully! Version:', oci.__version__)"
   ```
   
   Expected output: `OCI SDK installed successfully! Version: x.x.x`

**✓ Checkpoint:** OCI SDK installed and version displayed

---

### Step 3: Generate OCI API Keys

#### 3.1 Create Key Directory

**Windows:**
```cmd
mkdir %USERPROFILE%\.oci
cd %USERPROFILE%\.oci
```

**Mac/Linux:**
```bash
mkdir -p ~/.oci
cd ~/.oci
```

#### 3.2 Generate Key Pair

Run these commands one by one:

```bash
openssl genrsa -out oci_api_key.pem 2048
```
*(Generates private key)*

```bash
openssl rsa -pubout -in oci_api_key.pem -out oci_api_key_public.pem
```
*(Generates public key)*

**Note for Windows users:** If `openssl` is not found:
- Download Git for Windows from [git-scm.com](https://git-scm.com/)
- Use Git Bash to run the commands above

**✓ Checkpoint:** Two files created:
- `oci_api_key.pem` (private key)
- `oci_api_key_public.pem` (public key)

#### 3.3 Set File Permissions (Mac/Linux only)

```bash
chmod 600 ~/.oci/oci_api_key.pem
chmod 644 ~/.oci/oci_api_key_public.pem
```

---

### Step 4: Upload Public Key to OCI Console

1. **Log in to OCI Console:**
   - Go to [https://cloud.oracle.com/](https://cloud.oracle.com/)
   - Enter your Cloud Account Name
   - Click "Next"
   - Enter your username and password
   - Click "Sign In"

2. **Navigate to API Keys:**
   - Click your **Profile Icon** (top-right corner)
   - Select **"User Settings"** from dropdown

3. **Add API Key:**
   - Scroll down to **Resources** section (left sidebar)
   - Click **"API Keys"**
   - Click **"Add API Key"** button

4. **Upload Public Key:**
   - Select **"Paste Public Keys"** radio button
   - Open the public key file:
     - **Windows:** Open `%USERPROFILE%\.oci\oci_api_key_public.pem` in Notepad
     - **Mac/Linux:** Run `cat ~/.oci/oci_api_key_public.pem`
   - Copy the **entire content** (including BEGIN and END lines)
   - Paste into the text box
   - Click **"Add"**

5. **Save Configuration:**
   - A dialog box will appear showing "Configuration File Preview"
   - **IMPORTANT:** Click **"Copy"** to copy the entire configuration
   - Save this somewhere temporarily (Notepad, TextEdit, etc.)
   - Click **"Close"**

**✓ Checkpoint:** API Key shows as "Active" in the API Keys list

---

### Step 5: Create OCI Configuration File

#### 5.1 Create Config File

**Windows:**
```cmd
notepad %USERPROFILE%\.oci\config
```
*(Click "Yes" if asked to create new file)*

**Mac:**
```bash
nano ~/.oci/config
```

**Linux:**
```bash
vi ~/.oci/config
# or
nano ~/.oci/config
```

#### 5.2 Paste Configuration

Paste the configuration you copied in Step 4.5. It should look like this:

```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaaa...
fingerprint=12:34:56:78:9a:bc:de:f0:12:34:56:78:9a:bc:de:f0
tenancy=ocid1.tenancy.oc1..aaaaaaaaa...
region=us-ashburn-1
key_file=~/.oci/oci_api_key.pem
```

**For Windows users:** Change the `key_file` line to:
```ini
key_file=C:\Users\YourUsername\.oci\oci_api_key.pem
```
*(Replace `YourUsername` with your actual Windows username)*

#### 5.3 Save the File

**Windows (Notepad):**
- Click File → Save
- Close Notepad

**Mac/Linux (nano):**
- Press `Ctrl + X`
- Press `Y` to confirm
- Press `Enter` to save

**Linux (vi):**
- Press `Esc`
- Type `:wq`
- Press `Enter`

#### 5.4 Set Permissions (Mac/Linux only)

```bash
chmod 600 ~/.oci/config
```

**✓ Checkpoint:** Configuration file created at `~/.oci/config`

---

### Step 6: Verify OCI Setup

Test your configuration:

```bash
python -c "import oci; config = oci.config.from_file(); identity = oci.identity.IdentityClient(config); user = identity.get_user(config['user']).data; print('✓ SUCCESS! Connected as:', user.name)"
```

**Expected Output:**
```
✓ SUCCESS! Connected as: your.email@company.com
```

**If you see an error:** Refer to [Troubleshooting Guide](#troubleshooting-guide)

**✓ Checkpoint:** Successfully connected to OCI

---

### Step 7: Configure IAM Permissions

**⚠️ IMPORTANT:** You need proper permissions to run the script.

#### 7.1 Required Permissions

Your user must have these permissions:
- `inspect instances`
- `inspect compartments`
- `inspect vnics`
- `inspect subnets`
- `inspect vcns`
- `inspect boot-volumes`
- `inspect volumes`
- `inspect volume-attachments`
- `inspect boot-volume-attachments`
- `inspect images`

#### 7.2 Request Permissions from Administrator

**If you are NOT an administrator:**

1. Identify your user group:
   - OCI Console → Identity → Users
   - Click your username
   - Note the "Groups" listed

2. Send this email to your OCI Administrator:

---

**EMAIL TEMPLATE:**

```
Subject: Request for OCI Read Permissions

Hi [Administrator Name],

I need read-only permissions to run an instance inventory script.

User: [Your Username/Email]
Group: [Your Group Name from step 1]

Please add the following policy to my group:

Allow group [GroupName] to read all-resources in tenancy

Alternatively, you can use these granular permissions:

Allow group [GroupName] to inspect instances in tenancy
Allow group [GroupName] to inspect compartments in tenancy
Allow group [GroupName] to inspect vnics in tenancy
Allow group [GroupName] to inspect subnets in tenancy
Allow group [GroupName] to inspect vcns in tenancy
Allow group [GroupName] to inspect boot-volumes in tenancy
Allow group [GroupName] to inspect volumes in tenancy
Allow group [GroupName] to inspect volume-attachments in tenancy
Allow group [GroupName] to inspect boot-volume-attachments in tenancy
Allow group [GroupName] to inspect images in tenancy

Thank you!
```

---

#### 7.3 For Administrators: Create Policy

1. OCI Console → Identity & Security → Policies
2. Select your root compartment
3. Click "Create Policy"
4. Enter:
   - **Name:** `instance-exporter-read-policy`
   - **Description:** `Read permissions for instance inventory script`
   - **Policy Statements:** Click "Show manual editor" and paste:
   ```
   Allow group [YourGroupName] to read all-resources in tenancy
   ```
   *(Replace [YourGroupName] with actual group name)*
5. Click "Create"

**✓ Checkpoint:** Permissions configured

---

### Step 8: Download and Save the Script

#### 8.1 Create Working Directory

**Windows:**
```cmd
mkdir C:\Scripts\OCI
cd C:\Scripts\OCI
```

**Mac/Linux:**
```bash
mkdir -p ~/scripts/oci
cd ~/scripts/oci
```

#### 8.2 Create Script File

**Windows:**
```cmd
notepad oci_instance_exporter.py
```

**Mac/Linux:**
```bash
nano oci_instance_exporter.py
```

#### 8.3 Copy Script Content

Copy the entire Python script from the code artifact provided earlier and paste it into the file.

#### 8.4 Save the File

- Windows: File → Save, then close Notepad
- Mac/Linux: Press `Ctrl + X`, then `Y`, then `Enter`

#### 8.5 Make Executable (Mac/Linux only)

```bash
chmod +x oci_instance_exporter.py
```

**✓ Checkpoint:** Script file created and saved

---

## Execution Procedure

### Pre-Execution Checklist

Before running the script, verify:

- [ ] Python is installed and accessible
- [ ] OCI SDK is installed
- [ ] OCI configuration file exists at `~/.oci/config`
- [ ] API keys are uploaded and active in OCI Console
- [ ] You have required IAM permissions
- [ ] You have stable internet connection
- [ ] You have at least 100 MB free disk space

---

### Standard Execution Steps

#### Step 1: Open Terminal/Command Prompt

**Windows:**
- Press `Win + R`
- Type `cmd`
- Press `Enter`

**Mac:**
- Press `Cmd + Space`
- Type `Terminal`
- Press `Enter`

**Linux:**
- Press `Ctrl + Alt + T`

#### Step 2: Navigate to Script Directory

**Windows:**
```cmd
cd C:\Scripts\OCI
```

**Mac/Linux:**
```bash
cd ~/scripts/oci
```

#### Step 3: Execute the Script

**Windows:**
```cmd
python oci_instance_exporter.py
```

**Mac/Linux:**
```bash
python3 oci_instance_exporter.py
```

#### Step 4: Monitor Execution

You will see output like:

```
============================================================
OCI Instance Details Exporter
============================================================
Fetching instance details from all regions...

Processing region: us-ashburn-1
  Processing instance: web-server-prod-01
  Processing instance: db-server-prod-01
  Processing instance: app-server-prod-01

Processing region: us-phoenix-1
  Processing instance: backup-server-01

Processing region: eu-frankfurt-1
  Processing instance: web-server-eu-01

✓ Successfully exported 5 instances to oci_instances_20241215_143022.csv

============================================================
Total instances found: 5
============================================================
```

**Execution Time:**
- Small environments (< 10 instances): 2-5 minutes
- Medium environments (10-100 instances): 5-15 minutes
- Large environments (> 100 instances): 15-30 minutes

**⏱️ Note:** Do NOT close the terminal during execution!

#### Step 5: Execution Complete

When you see "Total instances found: X", the script has completed successfully.

**✓ Checkpoint:** Script executed without errors

---

## Verification

### Step 1: Locate Output File

The CSV file will be in the same directory where you ran the script:

**Windows:**
```cmd
dir oci_instances_*.csv
```

**Mac/Linux:**
```bash
ls -lh oci_instances_*.csv
```

### Step 2: Verify File Size

The file should be > 0 bytes. Check the size:

**Windows:** Right-click file → Properties  
**Mac/Linux:** `ls -lh oci_instances_*.csv`

### Step 3: Preview Content

**Windows:**
```cmd
type oci_instances_20241215_143022.csv | more
```

**Mac/Linux:**
```bash
head -20 oci_instances_20241215_143022.csv
```

### Step 4: Open in Spreadsheet Application

1. Open Microsoft Excel, Google Sheets, or LibreOffice Calc
2. File → Open
3. Select the CSV file
4. Verify:
   - All columns are present (25 columns expected)
   - Data looks correct
   - Number of rows matches "Total instances found"

### Expected Columns

| Column Name | Example Value |
|-------------|---------------|
| instance_name | web-server-prod-01 |
| instance_ocid | ocid1.instance.oc1.iad.anuwcl... |
| lifecycle_state | RUNNING |
| region | us-ashburn-1 |
| compartment_name | Production |
| availability_domain | US-ASHBURN-AD-1 |
| shape | VM.Standard.E4.Flex |
| shape_ocpus | 2 |
| shape_memory_gb | 16 |
| private_ips | 10.0.1.25 |
| public_ips | 129.213.45.67 |

**✓ Checkpoint:** CSV file opened and data verified

---

## Troubleshooting Guide

### Issue 1: "Python is not recognized"

**Symptoms:**
```
'python' is not recognized as an internal or external command
```

**Solution:**
1. Find Python installation path:
   - Windows: Usually `C:\Python39\` or `C:\Users\YourName\AppData\Local\Programs\Python\Python39\`
2. Add to PATH:
   - Windows: System Properties → Environment Variables → Edit PATH → Add Python directory
3. Restart Command Prompt
4. Try `python3` instead of `python`

---

### Issue 2: "ConfigFileNotFound"

**Symptoms:**
```
oci.exceptions.ConfigFileNotFound: Config file not found at: ~/.oci/config
```

**Solution:**
1. Verify file exists:
   - Windows: Check `C:\Users\YourName\.oci\config`
   - Mac/Linux: Run `ls -la ~/.oci/config`
2. If missing, repeat [Step 5](#step-5-create-oci-configuration-file)
3. Check file permissions (Mac/Linux):
   ```bash
   chmod 600 ~/.oci/config
   ```

---

### Issue 3: "InvalidPrivateKey"

**Symptoms:**
```
oci.exceptions.InvalidPrivateKey: The provided key is not a valid PEM format private key
```

**Solution:**
1. Regenerate keys (repeat [Step 3](#step-3-generate-oci-api-keys))
2. Upload new public key to OCI Console
3. Update config file with new fingerprint
4. Ensure no extra spaces/characters in key file

---

### Issue 4: "NotAuthenticated"

**Symptoms:**
```
oci.exceptions.ServiceError: {
    "code": "NotAuthenticated",
    "message": "The required information to complete authentication was not provided"
}
```

**Solution:**
1. Verify fingerprint matches:
   - OCI Console → User Settings → API Keys
   - Compare with fingerprint in `~/.oci/config`
2. Ensure API key is "Active" (not "Inactive")
3. Check private key path in config file is correct
4. Verify `key_file` path:
   - Windows: Use full path like `C:\Users\YourName\.oci\oci_api_key.pem`
   - Mac/Linux: Use `~/.oci/oci_api_key.pem`

---

### Issue 5: "NotAuthorizedOrNotFound"

**Symptoms:**
```
oci.exceptions.ServiceError: {
    "code": "NotAuthorizedOrNotFound",
    "message": "Authorization failed or requested resource not found"
}
```

**Solution:**
1. Check IAM permissions (refer to [Step 7](#step-7-configure-iam-permissions))
2. Wait 5-10 minutes for policy changes to propagate
3. Verify you're in correct tenancy
4. Try logging into OCI Console to confirm access

---

### Issue 6: Script Runs But No Output

**Symptoms:**
- Script completes with "Total instances found: 0"
- CSV file is empty or only has headers

**Solution:**
1. Verify you have compute instances in your tenancy:
   - Log in to OCI Console
   - Navigate to Compute → Instances
   - Check if any instances exist
2. Check if instances are in different compartments:
   - Script scans all compartments
   - Verify compartment access permissions
3. Verify region subscriptions:
   - Governance → Tenancy Management → Regions
   - Ensure regions are subscribed

---

### Issue 7: "TooManyRequests" Error

**Symptoms:**
```
oci.exceptions.ServiceError: {
    "code": "TooManyRequests",
    "message": "Too many requests"
}
```

**Solution:**
1. This is an OCI API rate limit
2. Wait 5-10 minutes and try again
3. For large environments, consider running script during off-peak hours
4. Contact me if you need a version with rate-limiting delays

---

### Issue 8: Script Hangs/Freezes

**Symptoms:**
- Script stops responding
- No output for > 10 minutes

**Solution:**
1. Press `Ctrl + C` to stop script
2. Check internet connectivity
3. Run script again
4. If persistent, check specific region/compartment causing issue
5. Review OCI service health dashboard

---

### Issue 9: Import Error

**Symptoms:**
```
ModuleNotFoundError: No module named 'oci'
```

**Solution:**
1. Reinstall OCI SDK:
   ```bash
   pip install --upgrade oci
   ```
2. Verify installation:
   ```bash
   pip show oci
   ```
3. Check if using correct Python version:
   ```bash
   python --version
   pip --version
   ```
4. If using virtual environment, ensure it's activated

---

### Issue 10: Permission Denied (Linux/Mac)

**Symptoms:**
```
Permission denied: './oci_instance_exporter.py'
```

**Solution:**
```bash
chmod +x oci_instance_exporter.py
python3 oci_instance_exporter.py
```

---

### Getting Help

If issues persist:

1. **Collect Information:**
   - Python version: `python --version`
   - OCI SDK version: `pip show oci`
   - Operating system
   - Full error message (screenshot or copy)

2. **Check Logs:**
   - Script output
   - OCI Audit logs (Console → Governance → Audit)

3. **Contact Support:**
   - OCI Support: [https://support.oracle.com](https://support.oracle.com)
   - Internal IT support team
   - Script developer/maintainer

---

## Maintenance

### Regular Tasks

#### Weekly
- [ ] Execute script to capture latest instance inventory
- [ ] Archive old CSV files

#### Monthly
- [ ] Review and clean up archived CSV files
- [ ] Verify API keys are active
- [ ] Update OCI SDK if new version available

#### Quarterly
- [ ] Review IAM permissions
- [ ] Update this SOP if process changes
- [ ] Test script execution on backup system

---

### Updating the Script

When a new version is released:

1. **Backup Current Version:**
   ```bash
   cp oci_instance_exporter.py oci_instance_exporter.py.backup
   ```

2. **Download New Version:**
   - Save new version as `oci_instance_exporter.py`

3. **Test Execution:**
   ```bash
   python3 oci_instance_exporter.py
   ```

4. **Verify Output:**
   - Compare new CSV with previous version
   - Ensure all expected columns are present

5. **Update Documentation:**
   - Update this SOP if procedures changed

---

### Updating OCI SDK

Check for updates monthly:

```bash
pip install --upgrade oci
```

Verify new version:
```bash
pip show oci
```

---

### Key Rotation

Rotate API keys every 90 days:

1. Generate new key pair (repeat [Step 3](#step-3-generate-oci-api-keys))
2. Add new public key to OCI Console (keep old one active)
3. Update config file with new fingerprint and key path
4. Test script with new keys
5. Delete old API key from OCI Console
6. Delete old private key file

---

## Appendix

### A. File Locations Reference

| Item | Windows | Mac/Linux |
|------|---------|-----------|
| Config File | `C:\Users\[User]\.oci\config` | `~/.oci/config` |
| Private Key | `C:\Users\[User]\.oci\oci_api_key.pem` | `~/.oci/oci_api_key.pem` |
| Public Key | `C:\Users\[User]\.oci\oci_api_key_public.pem` | `~/.oci/oci_api_key_public.pem` |
| Script | `C:\Scripts\OCI\oci_instance_exporter.py` | `~/scripts/oci/oci_instance_exporter.py` |
| Output CSV | Same as script location | Same as script location |

---

### B. Common OCI Regions

| Region Name | Region Identifier |
|-------------|-------------------|
| US East (Ashburn) | us-ashburn-1 |
| US West (Phoenix) | us-phoenix-1 |
| US West (San Jose) | us-sanjose-1 |
| Europe (Frankfurt) | eu-frankfurt-1 |
| Europe (London) | uk-london-1 |
| Asia Pacific (Mumbai) | ap-mumbai-1 |
| Asia Pacific (Tokyo) | ap-tokyo-1 |
| Asia Pacific (Singapore) | ap-singapore-1 |
| Asia Pacific (Sydney) | ap-sydney-1 |

---

### C. CSV Column Descriptions

| Column | Description | Example |
|--------|-------------|---------|
| instance_name | Display name of instance | web-server-01 |
| instance_ocid | Unique identifier | ocid1.instance.oc1... |
| lifecycle_state | Current state | RUNNING, STOPPED |
| region | OCI region | us-ashburn-1 |
| compartment_name | Compartment display name | Production |
| compartment_id | Compartment OCID | ocid1.compartment... |
| availability_domain | Availability domain | AD-1, AD-2, AD-3 |
| fault_domain | Fault domain | FAULT-DOMAIN-1 |
| shape | Compute shape | VM.Standard.E4.Flex |
| shape_ocpus | Number of OCPUs | 2 |
| shape_memory_gb | Memory in GB | 16 |
| image_id | OS image OCID | ocid1.image.oc1... |
| image_name | OS image name | Oracle-Linux-8.7 |
| os_family | Operating system | Oracle Linux |
| time_created | Creation timestamp | 2024-01-15 10:30:00 |
| freeform_tags | User-defined tags | {"Environment":"Prod"} |
| defined_tags | Namespace tags | {"Operations":{"CostCenter":"1234"}} |
| private_ips | Private IP addresses | 10.0.1.25; 10.0.2.30 |
| public_ips | Public IP addresses | 129.213.45.67 |
| vcns | VCN names | prod-vcn; backup-vcn |
| subnets | Subnet names | public-subnet; private-subnet |
| boot_volume_name | Boot volume name | boot-volume-01 |
| boot_volume_size_gb | Boot volume size | 50 |
| block_volumes | Attached block volumes | data-vol-01:100GB; logs-vol-02:50GB |
| platform_config | Platform configuration | INTEL_VM |

---

### D. Quick Reference Commands

#### Check Python Version
```bash
python --version
```

#### Check OCI SDK Version
```bash
pip show oci
```

#### Test OCI Connection
```bash
python -c "import oci; config = oci.config.from_file(); print('Connected successfully!')"
```

#### List API Keys
```bash
oci iam user api-key list --user-id <your-user-ocid>
```

#### View Config File
**Windows:**
```cmd
type %USERPROFILE%\.oci\config
```
**Mac/Linux:**
```bash
cat ~/.oci/config
```

#### Find Script Location
**Windows:**
```cmd
where oci_instance_exporter.py
```
**Mac/Linux:**
```bash
find ~ -name "oci_instance_exporter.py"
```

---

### E. Sample Output Analysis

**Example CSV Output:**

```csv
instance_name,instance_ocid,lifecycle_state,region,shape,shape_ocpus,private_ips
web-server-01,ocid1.instance.oc1.iad.xxx,RUNNING,us-ashburn-1,VM.Standard.E4.Flex,2,10.0.1.25
db-server-01,ocid1.instance.oc1.iad.yyy,RUNNING,us-ashburn-1,VM.Standard.E4.Flex,4,10.0.2.30
app-server-01,ocid1.instance.oc1.phx.zzz,STOPPED,us-phoenix-1,VM.Standard2.1,1,10.1.1.15
```

**Useful Analysis:**
- Total instances: Count rows
- Running instances: Filter by lifecycle_state = "RUNNING"
- Total OCPUs: Sum shape_ocpus column
- Instances by region: Group by region column
- Cost estimation: Calculate based on shape and hours

---

### F. Security Best Practices

✅ **DO:**
- Protect your private key file (`oci_api_key.pem`)
- Use read-only permissions when possible
- Rotate API keys every 90 days
- Keep OCI SDK updated
- Store CSV files securely
- Use encrypted storage for sensitive data
- Review IAM policies regularly

❌ **DON'T:**
- Share your private key
- Commit keys to version control
- Give unnecessary permissions
- Store keys in public locations
- Email unencrypted CSV files
- Use root user for automation

---

### G. Scheduling Automated Execution

#### Windows Task Scheduler

1. Open Task Scheduler
2. Create Basic Task
3. Name: "OCI Instance Export"
4. Trigger: Daily at 2:00 AM
5. Action: Start a program
   - Program: `C:\Python39\python.exe`
   - Arguments: `C:\Scripts\OCI\oci_instance_exporter.py`
6. Finish

#### Linux/Mac Cron Job

Edit crontab:
```bash
crontab -e
```

Add line (runs daily at 2 AM):
```
0 2 * * * /usr/bin/python3 /home/username/scripts/oci/oci_instance_exporter.py
```

Save and exit.

---

### H. Contact Information

| Role | Contact |
|------|---------|
| Script Issues | [Your IT Support Email] |
| OCI Access/Permissions | [OCI Admin Email] |
| OCI Support | support.oracle.com |
| Emergency Contact | [24/7 Support Number] |

---

### I. Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2024-12-15 | Cloud Ops Team | Initial SOP creation |

---

### J. Approval Signatures

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Author | | | |
| Reviewer | | | |
| Approver | | | |

---

## Document End

**Last Updated:** December 15, 2024   
**Document Owner:** Cloud Operations Team

---

*This SOP is a living document and should be updated as processes evolve.*
