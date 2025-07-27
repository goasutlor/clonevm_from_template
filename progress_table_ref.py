# Reference Implementation for Progress Table and VM Status Management
# This file shows the correct way to handle progress table updates

def create_vm_status_data(vm_configs):
    """
    Create proper VM status data structure for the progress table
    """
    vm_status_data = {}
    
    for vm_config in vm_configs:
        vm_name = vm_config.get('name', 'unknown')
        
        # Initialize status data
        vm_status_data[vm_name] = {
            'name': vm_name,
            'hostname': vm_config.get('hostname', f"{vm_name}.local"),
            'ips': vm_config.get('ips', {}),
            'status': 'pending',
            'progress': 0
        }
        
        # Format IPs properly
        if vm_status_data[vm_name]['ips']:
            if isinstance(vm_status_data[vm_name]['ips'], dict):
                # Convert dict to string for display
                ip_values = [ip for ip in vm_status_data[vm_name]['ips'].values() if ip]
                vm_status_data[vm_name]['ips_display'] = ', '.join(ip_values) if ip_values else 'DHCP'
            elif isinstance(vm_status_data[vm_name]['ips'], str):
                vm_status_data[vm_name]['ips_display'] = vm_status_data[vm_name]['ips']
            else:
                vm_status_data[vm_name]['ips_display'] = 'DHCP'
        else:
            vm_status_data[vm_name]['ips_display'] = 'DHCP'
    
    return vm_status_data


def update_vm_status(vm_name, status, progress=None, message=None, vm_status_data=None):
    """
    Update VM status in the progress table
    """
    if not vm_status_data:
        return
    
    if vm_name not in vm_status_data:
        # Add new VM if not exists
        vm_status_data[vm_name] = {
            'name': vm_name,
            'hostname': f"{vm_name}.local",
            'ips': {},
            'ips_display': 'DHCP',
            'status': 'pending',
            'progress': 0
        }
    
    # Update status
    vm_status_data[vm_name]['status'] = status
    
    # Update progress if provided
    if progress is not None:
        vm_status_data[vm_name]['progress'] = progress
    
    # Log the update
    print(f"🔄 Updated VM {vm_name}: status={status}, progress={progress}%")


def create_status_table_html(vm_status_data):
    """
    Generate HTML for the status table
    """
    html = """
    <div class="status-table-container" id="statusTableContainer">
        <div class="card-header">
            <h3>🖥️ VM Provisioning Status</h3>
        </div>
        <table class="status-table" id="statusTable">
            <thead>
                <tr>
                    <th>VM Name</th>
                    <th>Hostname</th>
                    <th>Network IPs</th>
                    <th>Status</th>
                    <th>Progress</th>
                </tr>
            </thead>
            <tbody id="statusTableBody">
    """
    
    for vm_name, vm_data in vm_status_data.items():
        status_class = vm_data['status']
        status_text = vm_data['status'].title()
        progress_width = vm_data['progress']
        progress_text = 'Complete!' if progress_width == 100 else f'{progress_width}%'
        
        html += f"""
                <tr id="status-row-{vm_name}">
                    <td class="node-name">{vm_name}</td>
                    <td class="hostname">{vm_data['hostname']}</td>
                    <td>{vm_data['ips_display']}</td>
                    <td>
                        <div class="vm-status {status_class}" id="status-{vm_name}">
                            {status_text}
                        </div>
                    </td>
                    <td>
                        <div class="progress-bar">
                            <div class="progress-fill" id="progress-{vm_name}" style="width: {progress_width}%"></div>
                        </div>
                        <small id="progress-text-{vm_name}">{progress_text}</small>
                    </td>
                </tr>
        """
    
    html += """
            </tbody>
        </table>
    </div>
    """
    
    return html


def parse_log_message_for_vm_updates(message):
    """
    Parse log messages to extract VM status updates
    Returns: (vm_name, status, progress) or (None, None, None)
    """
    import re
    
    # Patterns to match VM status updates
    patterns = [
        # VM started
        r"🚀 Starting VM (\d+)/(\d+): ([^\s]+)",
        # VM cloned successfully
        r"✅ VM ([^\s]+) cloned successfully",
        # VM powered on
        r"🟢 VM ([^\s]+) powered on successfully",
        # VM ready
        r"✅ Guest OS boot completed - VM ([^\s]+) ready",
        # VM failed
        r"❌ ([^\s]+) clone failed",
        # Progress updates
        r"📈 Clone progress: (\d+)% - VM ([^\s]+)",
    ]
    
    for pattern in patterns:
        match = re.search(pattern, message)
        if match:
            if "progress" in pattern:
                progress = int(match.group(1))
                vm_name = match.group(2)
                return vm_name, 'provisioning', progress
            elif "failed" in pattern:
                vm_name = match.group(1)
                return vm_name, 'failed', None
            elif "ready" in pattern or "successfully" in pattern:
                vm_name = match.group(1)
                return vm_name, 'success', 100
            elif "Starting VM" in pattern:
                vm_name = match.group(3)
                return vm_name, 'provisioning', 0
    
    return None, None, None


def demo_provision_with_progress_table():
    """
    Demo function showing how to properly handle progress table updates
    """
    # Example VM configs
    vm_configs = [
        {'name': 'test01', 'hostname': 'test01.local', 'ips': {'net1': '192.168.1.101', 'net2': '192.168.2.101'}},
        {'name': 'test02', 'hostname': 'test02.local', 'ips': {'net1': '192.168.1.102', 'net2': '192.168.2.102'}},
        {'name': 'test03', 'hostname': 'test03.local', 'ips': {'net1': '192.168.1.103', 'net2': '192.168.2.103'}},
    ]
    
    # Create status data
    vm_status_data = create_vm_status_data(vm_configs)
    
    # Simulate provisioning process
    import time
    
    for vm_name in vm_status_data.keys():
        print(f"🚀 Starting VM: {vm_name}")
        update_vm_status(vm_name, 'provisioning', 0, vm_status_data=vm_status_data)
        time.sleep(0.5)
        
        print(f"📈 Progress 25% - VM {vm_name}")
        update_vm_status(vm_name, 'provisioning', 25, vm_status_data=vm_status_data)
        time.sleep(0.5)
        
        print(f"📈 Progress 50% - VM {vm_name}")
        update_vm_status(vm_name, 'provisioning', 50, vm_status_data=vm_status_data)
        time.sleep(0.5)
        
        print(f"📈 Progress 75% - VM {vm_name}")
        update_vm_status(vm_name, 'provisioning', 75, vm_status_data=vm_status_data)
        time.sleep(0.5)
        
        print(f"✅ VM {vm_name} completed")
        update_vm_status(vm_name, 'success', 100, vm_status_data=vm_status_data)
        time.sleep(0.5)
    
    # Generate final HTML
    html = create_status_table_html(vm_status_data)
    print("Generated HTML for status table:")
    print(html)
    
    return vm_status_data


if __name__ == "__main__":
    # Run demo
    result = demo_provision_with_progress_table()
    print(f"\nFinal VM status data: {result}") 