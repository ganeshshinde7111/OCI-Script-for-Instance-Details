#!/usr/bin/env python3
"""
OCI Instance Details Exporter
Fetches comprehensive instance details from Oracle Cloud Infrastructure and exports to CSV
"""

import oci
import csv
from datetime import datetime
import json

def get_compartment_name(identity_client, compartment_id):
    """Get compartment name from compartment ID"""
    try:
        compartment = identity_client.get_compartment(compartment_id).data
        return compartment.name
    except:
        return compartment_id

def get_image_details(compute_client, image_id):
    """Get image name and OS family"""
    try:
        image = compute_client.get_image(image_id).data
        return image.display_name, image.operating_system
    except:
        return image_id, "Unknown"

def get_vnic_details(virtual_network_client, vnic_id):
    """Get VNIC details including IPs, subnet, and VCN"""
    try:
        vnic = virtual_network_client.get_vnic(vnic_id).data
        subnet = virtual_network_client.get_subnet(vnic.subnet_id).data
        vcn = virtual_network_client.get_vcn(subnet.vcn_id).data
        
        return {
            'private_ip': vnic.private_ip,
            'public_ip': vnic.public_ip if vnic.public_ip else '',
            'subnet_id': vnic.subnet_id,
            'subnet_name': subnet.display_name,
            'vcn_id': subnet.vcn_id,
            'vcn_name': vcn.display_name
        }
    except:
        return None

def get_boot_volume_details(compute_client, block_storage_client, availability_domain, compartment_id, instance_id):
    """Get boot volume details"""
    try:
        boot_volume_attachments = oci.pagination.list_call_get_all_results(
            compute_client.list_boot_volume_attachments,
            availability_domain=availability_domain,
            compartment_id=compartment_id,
            instance_id=instance_id
        ).data
        
        if boot_volume_attachments:
            boot_volume_id = boot_volume_attachments[0].boot_volume_id
            boot_volume = block_storage_client.get_boot_volume(boot_volume_id).data
            return boot_volume.display_name, boot_volume.size_in_gbs
    except:
        pass
    return '', ''

def get_block_volumes(compute_client, block_storage_client, compartment_id, instance_id):
    """Get attached block volumes"""
    try:
        volume_attachments = oci.pagination.list_call_get_all_results(
            compute_client.list_volume_attachments,
            compartment_id=compartment_id,
            instance_id=instance_id
        ).data
        
        volumes = []
        for attachment in volume_attachments:
            try:
                volume = block_storage_client.get_volume(attachment.volume_id).data
                volumes.append(f"{volume.display_name}:{volume.size_in_gbs}GB")
            except:
                continue
        
        return '; '.join(volumes) if volumes else ''
    except:
        return ''

def get_all_vnics(compute_client, virtual_network_client, compartment_id, instance_id):
    """Get all VNICs attached to an instance"""
    try:
        vnic_attachments = oci.pagination.list_call_get_all_results(
            compute_client.list_vnic_attachments,
            compartment_id=compartment_id,
            instance_id=instance_id
        ).data
        
        private_ips = []
        public_ips = []
        vcns = []
        subnets = []
        
        for attachment in vnic_attachments:
            if attachment.lifecycle_state == "ATTACHED":
                vnic_details = get_vnic_details(virtual_network_client, attachment.vnic_id)
                if vnic_details:
                    if vnic_details['private_ip']:
                        private_ips.append(vnic_details['private_ip'])
                    if vnic_details['public_ip']:
                        public_ips.append(vnic_details['public_ip'])
                    if vnic_details['vcn_name'] not in vcns:
                        vcns.append(vnic_details['vcn_name'])
                    if vnic_details['subnet_name'] not in subnets:
                        subnets.append(vnic_details['subnet_name'])
        
        return {
            'private_ips': '; '.join(private_ips),
            'public_ips': '; '.join(public_ips),
            'vcns': '; '.join(vcns),
            'subnets': '; '.join(subnets)
        }
    except Exception as e:
        print(f"Error getting VNICs: {str(e)}")
        return {'private_ips': '', 'public_ips': '', 'vcns': '', 'subnets': ''}

def get_platform_config(instance):
    """Get platform configuration details"""
    try:
        if hasattr(instance, 'platform_config') and instance.platform_config:
            config_type = instance.platform_config.type if hasattr(instance.platform_config, 'type') else 'Unknown'
            return config_type
    except:
        pass
    return ''

def list_all_compartments(identity_client, tenancy_id):
    """List all compartments in the tenancy including root"""
    compartments = [tenancy_id]
    try:
        all_compartments = oci.pagination.list_call_get_all_results(
            identity_client.list_compartments,
            tenancy_id,
            compartment_id_in_subtree=True
        ).data
        
        for compartment in all_compartments:
            if compartment.lifecycle_state == "ACTIVE":
                compartments.append(compartment.id)
    except Exception as e:
        print(f"Error listing compartments: {str(e)}")
    
    return compartments

def fetch_instance_details():
    """Main function to fetch all instance details"""
    
    # Initialize OCI config and clients
    # This uses default config file at ~/.oci/config
    config = oci.config.from_file()
    
    identity_client = oci.identity.IdentityClient(config)
    compute_client = oci.core.ComputeClient(config)
    virtual_network_client = oci.core.VirtualNetworkClient(config)
    block_storage_client = oci.core.BlockstorageClient(config)
    
    # Get tenancy ID
    tenancy_id = config["tenancy"]
    
    # Get all regions
    regions = identity_client.list_region_subscriptions(tenancy_id).data
    
    all_instances = []
    
    print("Fetching instance details from all regions...")
    
    for region in regions:
        print(f"\nProcessing region: {region.region_name}")
        
        # Update config for current region
        config["region"] = region.region_name
        
        # Re-initialize clients for new region
        compute_client = oci.core.ComputeClient(config)
        virtual_network_client = oci.core.VirtualNetworkClient(config)
        block_storage_client = oci.core.BlockstorageClient(config)
        
        # Get all compartments
        compartments = list_all_compartments(identity_client, tenancy_id)
        
        for compartment_id in compartments:
            try:
                # List instances in compartment
                instances = oci.pagination.list_call_get_all_results(
                    compute_client.list_instances,
                    compartment_id=compartment_id
                ).data
                
                for instance in instances:
                    print(f"  Processing instance: {instance.display_name}")
                    
                    # Get compartment name
                    compartment_name = get_compartment_name(identity_client, compartment_id)
                    
                    # Get image details
                    image_name, os_family = get_image_details(compute_client, instance.image_id) if instance.image_id else ('', '')
                    
                    # Get shape details
                    shape_ocpus = ''
                    shape_memory_gb = ''
                    if hasattr(instance, 'shape_config') and instance.shape_config:
                        shape_ocpus = instance.shape_config.ocpus if hasattr(instance.shape_config, 'ocpus') else ''
                        shape_memory_gb = instance.shape_config.memory_in_gbs if hasattr(instance.shape_config, 'memory_in_gbs') else ''
                    
                    # Get VNIC details
                    vnic_info = get_all_vnics(compute_client, virtual_network_client, compartment_id, instance.id)
                    
                    # Get boot volume details
                    boot_volume_name, boot_volume_size = get_boot_volume_details(
                        compute_client, block_storage_client,
                        instance.availability_domain, compartment_id, instance.id
                    )
                    
                    # Get block volumes
                    block_volumes = get_block_volumes(compute_client, block_storage_client, compartment_id, instance.id)
                    
                    # Get platform config
                    platform_config = get_platform_config(instance)
                    
                    # Prepare instance details
                    instance_details = {
                        'instance_name': instance.display_name,
                        'instance_ocid': instance.id,
                        'lifecycle_state': instance.lifecycle_state,
                        'region': region.region_name,
                        'compartment_name': compartment_name,
                        'compartment_id': compartment_id,
                        'availability_domain': instance.availability_domain,
                        'fault_domain': instance.fault_domain if instance.fault_domain else '',
                        'shape': instance.shape,
                        'shape_ocpus': shape_ocpus,
                        'shape_memory_gb': shape_memory_gb,
                        'image_id': instance.image_id if instance.image_id else '',
                        'image_name': image_name,
                        'os_family': os_family,
                        'time_created': instance.time_created.strftime('%Y-%m-%d %H:%M:%S') if instance.time_created else '',
                        'freeform_tags': json.dumps(instance.freeform_tags) if instance.freeform_tags else '{}',
                        'defined_tags': json.dumps(instance.defined_tags) if instance.defined_tags else '{}',
                        'private_ips': vnic_info['private_ips'],
                        'public_ips': vnic_info['public_ips'],
                        'vcns': vnic_info['vcns'],
                        'subnets': vnic_info['subnets'],
                        'boot_volume_name': boot_volume_name,
                        'boot_volume_size_gb': boot_volume_size,
                        'block_volumes': block_volumes,
                        'platform_config': platform_config
                    }
                    
                    all_instances.append(instance_details)
                    
            except Exception as e:
                print(f"  Error processing compartment {compartment_id}: {str(e)}")
                continue
    
    return all_instances

def export_to_csv(instances, filename='oci_instances.csv'):
    """Export instance details to CSV"""
    
    if not instances:
        print("No instances found to export.")
        return
    
    # Define CSV headers
    headers = [
        'instance_name', 'instance_ocid', 'lifecycle_state', 'region',
        'compartment_name', 'compartment_id', 'availability_domain', 'fault_domain',
        'shape', 'shape_ocpus', 'shape_memory_gb', 'image_id', 'image_name',
        'os_family', 'time_created', 'freeform_tags', 'defined_tags',
        'private_ips', 'public_ips', 'vcns', 'subnets',
        'boot_volume_name', 'boot_volume_size_gb', 'block_volumes', 'platform_config'
    ]
    
    # Write to CSV
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        writer.writerows(instances)
    
    print(f"\n✓ Successfully exported {len(instances)} instances to {filename}")

if __name__ == "__main__":
    print("=" * 60)
    print("OCI Instance Details Exporter")
    print("=" * 60)
    
    try:
        # Fetch all instance details
        instances = fetch_instance_details()
        
        # Generate filename with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'oci_instances_{timestamp}.csv'
        
        # Export to CSV
        export_to_csv(instances, filename)
        
        print("\n" + "=" * 60)
        print(f"Total instances found: {len(instances)}")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n✗ Error: {str(e)}")
        import traceback
        traceback.print_exc()
