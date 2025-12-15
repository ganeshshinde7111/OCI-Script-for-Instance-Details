#!/bin/bash

# Script to get comprehensive instance details across OCI tenancy
# Output: CSV file with all instance information

OUTPUT_FILE="oci_instances_full_$(date +%Y%m%d_%H%M%S).csv"

echo "Starting OCI Instance Details Collection..."
echo "==========================================="

# Print CSV header
echo "instance_name,instance_ocid,lifecycle_state,region,compartment_name,compartment_id,availability_domain,fault_domain,shape,shape_ocpus,shape_memory_gb,image_id,image_name,os_family,time_created,freeform_tags,defined_tags,private_ips,public_ips,vcns,subnets,boot_volume_name,boot_volume_size_gb,block_volumes,platform_config" > "$OUTPUT_FILE"

# Function to safely extract JSON values
safe_jq() {
    local json="$1"
    local query="$2"
    local default="${3:-N/A}"
    echo "$json" | jq -r "$query // \"$default\"" 2>/dev/null || echo "$default"
}

# Function to escape CSV fields
escape_csv() {
    local field="$1"
    # Replace double quotes with two double quotes and wrap in quotes if contains comma/newline
    if [[ "$field" == *","* ]] || [[ "$field" == *$'\n'* ]] || [[ "$field" == *"\""* ]]; then
        field="${field//\"/\"\"}"
        echo "\"$field\""
    else
        echo "\"$field\""
    fi
}

# Function to process instances in a compartment
process_compartment() {
    local COMPARTMENT_ID="$1"
    local COMPARTMENT_NAME="$2"
    
    echo "Processing compartment: $COMPARTMENT_NAME"
    
    # Get instances list as JSON and extract IDs properly
    INSTANCES_JSON=$(oci compute instance list --compartment-id "$COMPARTMENT_ID" --all 2>/dev/null)
    
    if [ -z "$INSTANCES_JSON" ]; then
        echo "  No instances found in this compartment"
        return
    fi
    
    # Extract instance IDs using jq
    INSTANCES=$(echo "$INSTANCES_JSON" | jq -r '.data[]?.id // empty' 2>/dev/null)
    
    if [ -z "$INSTANCES" ]; then
        echo "  No instances found in this compartment"
        return
    fi
    
    for INSTANCE_ID in $INSTANCES; do
        # Skip if INSTANCE_ID is empty or invalid
        if [ -z "$INSTANCE_ID" ] || [ "$INSTANCE_ID" == "null" ]; then
            continue
        fi
        echo "  Processing instance: $INSTANCE_ID"
        
        # Get instance details
        INSTANCE_JSON=$(oci compute instance get --instance-id "$INSTANCE_ID" 2>/dev/null)
        
        if [ -z "$INSTANCE_JSON" ]; then
            echo "  ERROR: Could not fetch instance details"
            continue
        fi
        
        # Basic instance info
        INSTANCE_NAME=$(safe_jq "$INSTANCE_JSON" '.data."display-name"')
        LIFECYCLE_STATE=$(safe_jq "$INSTANCE_JSON" '.data."lifecycle-state"')
        REGION=$(safe_jq "$INSTANCE_JSON" '.data.region')
        AD=$(safe_jq "$INSTANCE_JSON" '.data."availability-domain"')
        FAULT_DOMAIN=$(safe_jq "$INSTANCE_JSON" '.data."fault-domain"')
        SHAPE=$(safe_jq "$INSTANCE_JSON" '.data.shape')
        TIME_CREATED=$(safe_jq "$INSTANCE_JSON" '.data."time-created"')
        
        # Shape configuration
        SHAPE_OCPUS=$(safe_jq "$INSTANCE_JSON" '.data."shape-config".ocpus')
        SHAPE_MEMORY=$(safe_jq "$INSTANCE_JSON" '.data."shape-config"."memory-in-gbs"')
        
        # Image details
        IMAGE_ID=$(safe_jq "$INSTANCE_JSON" '.data."source-details"."image-id"')
        if [ "$IMAGE_ID" != "N/A" ] && [ "$IMAGE_ID" != "null" ]; then
            IMAGE_INFO=$(oci compute image get --image-id "$IMAGE_ID" 2>/dev/null)
            IMAGE_NAME=$(safe_jq "$IMAGE_INFO" '.data."display-name"')
            OS_FAMILY=$(safe_jq "$IMAGE_INFO" '.data."operating-system"')
        else
            IMAGE_NAME="N/A"
            OS_FAMILY="N/A"
        fi
        
        # Tags
        FREEFORM_TAGS=$(echo "$INSTANCE_JSON" | jq -r '.data."freeform-tags" // {} | to_entries | map("\(.key)=\(.value)") | join("; ")' 2>/dev/null)
        [ -z "$FREEFORM_TAGS" ] && FREEFORM_TAGS="N/A"
        
        DEFINED_TAGS=$(echo "$INSTANCE_JSON" | jq -r '.data."defined-tags" // {} | to_entries | map("\(.key).\(.value | to_entries | map("\(.key)=\(.value)") | join(","))") | join("; ")' 2>/dev/null)
        [ -z "$DEFINED_TAGS" ] && DEFINED_TAGS="N/A"
        
        # Platform configuration
        PLATFORM_CONFIG=$(echo "$INSTANCE_JSON" | jq -r '.data."platform-config" // {} | to_entries | map("\(.key)=\(.value)") | join("; ")' 2>/dev/null)
        [ -z "$PLATFORM_CONFIG" ] && PLATFORM_CONFIG="N/A"
        
        # Get VNIC attachments for network info
        VNIC_ATTACHMENTS=$(oci compute vnic-attachment list --compartment-id "$COMPARTMENT_ID" --instance-id "$INSTANCE_ID" --all 2>/dev/null)
        
        PRIVATE_IPS=""
        PUBLIC_IPS=""
        VCNS=""
        SUBNETS=""
        
        if [ -n "$VNIC_ATTACHMENTS" ]; then
            VNIC_IDS=$(echo "$VNIC_ATTACHMENTS" | jq -r '.data[]."vnic-id"' 2>/dev/null)
            
            for VNIC_ID in $VNIC_IDS; do
                VNIC_INFO=$(oci network vnic get --vnic-id "$VNIC_ID" 2>/dev/null)
                
                if [ -n "$VNIC_INFO" ]; then
                    PRIV_IP=$(safe_jq "$VNIC_INFO" '.data."private-ip"')
                    PUB_IP=$(safe_jq "$VNIC_INFO" '.data."public-ip"')
                    SUBNET_ID=$(safe_jq "$VNIC_INFO" '.data."subnet-id"')
                    
                    [ "$PRIV_IP" != "N/A" ] && PRIVATE_IPS="${PRIVATE_IPS}${PRIV_IP}; "
                    [ "$PUB_IP" != "N/A" ] && PUBLIC_IPS="${PUBLIC_IPS}${PUB_IP}; "
                    
                    if [ "$SUBNET_ID" != "N/A" ]; then
                        SUBNET_INFO=$(oci network subnet get --subnet-id "$SUBNET_ID" 2>/dev/null)
                        SUBNET_NAME=$(safe_jq "$SUBNET_INFO" '.data."display-name"')
                        VCN_ID=$(safe_jq "$SUBNET_INFO" '.data."vcn-id"')
                        
                        SUBNETS="${SUBNETS}${SUBNET_NAME}; "
                        
                        if [ "$VCN_ID" != "N/A" ]; then
                            VCN_INFO=$(oci network vcn get --vcn-id "$VCN_ID" 2>/dev/null)
                            VCN_NAME=$(safe_jq "$VCN_INFO" '.data."display-name"')
                            VCNS="${VCNS}${VCN_NAME}; "
                        fi
                    fi
                fi
            done
        fi
        
        # Clean up trailing semicolons and spaces
        PRIVATE_IPS=$(echo "$PRIVATE_IPS" | sed 's/; $//' | sed 's/^$/N\/A/')
        PUBLIC_IPS=$(echo "$PUBLIC_IPS" | sed 's/; $//' | sed 's/^$/N\/A/')
        VCNS=$(echo "$VCNS" | sed 's/; $//' | sed 's/^$/N\/A/')
        SUBNETS=$(echo "$SUBNETS" | sed 's/; $//' | sed 's/^$/N\/A/')
        
        # Get boot volume details
        BOOT_VOL_ATTACHMENTS=$(oci compute boot-volume-attachment list --availability-domain "$AD" --compartment-id "$COMPARTMENT_ID" --instance-id "$INSTANCE_ID" 2>/dev/null)
        
        BOOT_VOL_NAME="N/A"
        BOOT_VOL_SIZE="N/A"
        
        if [ -n "$BOOT_VOL_ATTACHMENTS" ]; then
            BOOT_VOL_ID=$(echo "$BOOT_VOL_ATTACHMENTS" | jq -r '.data[0]."boot-volume-id"' 2>/dev/null)
            
            if [ "$BOOT_VOL_ID" != "null" ] && [ -n "$BOOT_VOL_ID" ]; then
                BOOT_VOL_JSON=$(oci bv boot-volume get --boot-volume-id "$BOOT_VOL_ID" 2>/dev/null)
                BOOT_VOL_NAME=$(safe_jq "$BOOT_VOL_JSON" '.data."display-name"')
                BOOT_VOL_SIZE=$(safe_jq "$BOOT_VOL_JSON" '.data."size-in-gbs"')
            fi
        fi
        
        # Get block volumes
        BLOCK_VOL_ATTACHMENTS=$(oci compute volume-attachment list --compartment-id "$COMPARTMENT_ID" --instance-id "$INSTANCE_ID" --all 2>/dev/null)
        
        BLOCK_VOLUMES=""
        if [ -n "$BLOCK_VOL_ATTACHMENTS" ]; then
            BLOCK_VOL_IDS=$(echo "$BLOCK_VOL_ATTACHMENTS" | jq -r '.data[]."volume-id"' 2>/dev/null)
            
            for BV_ID in $BLOCK_VOL_IDS; do
                BV_INFO=$(oci bv volume get --volume-id "$BV_ID" 2>/dev/null)
                if [ -n "$BV_INFO" ]; then
                    BV_NAME=$(safe_jq "$BV_INFO" '.data."display-name"')
                    BV_SIZE=$(safe_jq "$BV_INFO" '.data."size-in-gbs"')
                    BLOCK_VOLUMES="${BLOCK_VOLUMES}${BV_NAME}(${BV_SIZE}GB); "
                fi
            done
        fi
        
        BLOCK_VOLUMES=$(echo "$BLOCK_VOLUMES" | sed 's/; $//' | sed 's/^$/N\/A/')
        
        # Write to CSV - escape all fields
        echo "$(escape_csv "$INSTANCE_NAME"),$(escape_csv "$INSTANCE_ID"),$(escape_csv "$LIFECYCLE_STATE"),$(escape_csv "$REGION"),$(escape_csv "$COMPARTMENT_NAME"),$(escape_csv "$COMPARTMENT_ID"),$(escape_csv "$AD"),$(escape_csv "$FAULT_DOMAIN"),$(escape_csv "$SHAPE"),$(escape_csv "$SHAPE_OCPUS"),$(escape_csv "$SHAPE_MEMORY"),$(escape_csv "$IMAGE_ID"),$(escape_csv "$IMAGE_NAME"),$(escape_csv "$OS_FAMILY"),$(escape_csv "$TIME_CREATED"),$(escape_csv "$FREEFORM_TAGS"),$(escape_csv "$DEFINED_TAGS"),$(escape_csv "$PRIVATE_IPS"),$(escape_csv "$PUBLIC_IPS"),$(escape_csv "$VCNS"),$(escape_csv "$SUBNETS"),$(escape_csv "$BOOT_VOL_NAME"),$(escape_csv "$BOOT_VOL_SIZE"),$(escape_csv "$BLOCK_VOLUMES"),$(escape_csv "$PLATFORM_CONFIG")" >> "$OUTPUT_FILE"
        
        echo "  ✓ Instance processed successfully"
    done
}

echo ""
echo "Fetching all compartments..."
COMPARTMENTS_JSON=$(oci iam compartment list --all --compartment-id-in-subtree true --query 'data[?("lifecycle-state"==`ACTIVE`)].{id:id,name:name}' 2>/dev/null)

if [ -z "$COMPARTMENTS_JSON" ]; then
    echo "Error: Unable to fetch compartments. Check your OCI CLI configuration."
    exit 1
fi

# Get root compartment - try multiple methods
ROOT_COMPARTMENT=$(oci iam compartment list --all --query 'data[0]."compartment-id"' --raw-output 2>/dev/null)

if [ -z "$ROOT_COMPARTMENT" ] || [ "$ROOT_COMPARTMENT" == "null" ]; then
    # Alternative method: get from first compartment's parent
    ROOT_COMPARTMENT=$(oci iam availability-domain list --query 'data[0]."compartment-id"' --raw-output 2>/dev/null)
fi

if [ -z "$ROOT_COMPARTMENT" ] || [ "$ROOT_COMPARTMENT" == "null" ]; then
    echo "Error: Unable to fetch root compartment. Check your OCI CLI configuration."
    echo "Trying to list compartments directly..."
    oci iam compartment list --limit 1
    exit 1
fi

# Get root compartment name
ROOT_NAME=$(oci iam tenancy get --tenancy-id "$ROOT_COMPARTMENT" --query 'data.name' --raw-output 2>/dev/null || echo "root")

echo "Found root compartment: $ROOT_NAME"
echo ""

# Process root compartment
process_compartment "$ROOT_COMPARTMENT" "$ROOT_NAME (root)"

# Save compartments to temp file and process from there
TEMP_COMP_FILE="/tmp/oci_compartments_$$.json"
echo "$COMPARTMENTS_JSON" > "$TEMP_COMP_FILE"

# Process all other compartments using process substitution
COMP_COUNT=$(jq -r '. | length' "$TEMP_COMP_FILE" 2>/dev/null)
echo ""
echo "Found $COMP_COUNT additional compartments to process"
echo ""

jq -r '.[] | @json' "$TEMP_COMP_FILE" 2>/dev/null | while IFS= read -r comp; do
    COMPARTMENT_ID=$(echo "$comp" | jq -r '.id')
    COMPARTMENT_NAME=$(echo "$comp" | jq -r '.name')
    process_compartment "$COMPARTMENT_ID" "$COMPARTMENT_NAME"
done

# Clean up temp file
rm -f "$TEMP_COMP_FILE"

echo ""
echo "==========================================="
echo "✓ Collection complete!"
echo "✓ Output file: $OUTPUT_FILE"
echo "==========================================="
echo ""

# Count instances (excluding header)
INSTANCE_COUNT=$(($(wc -l < "$OUTPUT_FILE") - 1))
echo "Total instances found: $INSTANCE_COUNT"
echo ""

if [ $INSTANCE_COUNT -eq 0 ]; then
    echo "WARNING: No instances were found. This could mean:"
    echo "  1. There are no instances in your tenancy"
    echo "  2. OCI CLI is not properly configured"
    echo "  3. You don't have sufficient permissions"
    echo ""
    echo "Please verify by running: oci compute instance list --all"
fi
