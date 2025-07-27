#!/bin/bash

# =============================================================================
# RedHat Linux Template Pre-Check Script (Audit/Fixed Mode)
# สำหรับ Bulk VM Provisioning Program
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/template_precheck_$(date +%Y%m%d_%H%M%S).log"
ERROR_COUNT=0
WARNING_COUNT=0
MODE="audit" # default

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS") echo -e "${GREEN}[PASS]${NC} $message" ;;
        "FAIL") echo -e "${RED}[FAIL]${NC} $message" ; ((ERROR_COUNT++)) ;;
        "WARN") echo -e "${YELLOW}[WARN]${NC} $message" ; ((WARNING_COUNT++)) ;;
        "INFO") echo -e "${BLUE}[INFO]${NC} $message" ;;
    esac
}

log_output() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Mode selection
select_mode() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}RedHat Template Pre-Check Script${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "\nเลือกโหมดการทำงาน:"
    echo "1) Audit Mode (ตรวจสอบอย่างเดียว)"
    echo "2) Fixed Mode (ตรวจสอบ + แก้ไขอัตโนมัติ)"
    read -p "กรุณาเลือก [1-2, default=1]: " mode_choice
    case $mode_choice in
        2) MODE="fixed" ;;
        *) MODE="audit" ;;
    esac
    echo -e "\n${YELLOW}โหมดที่เลือก: $MODE${NC}\n"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_status "PASS" "Running as root"
    else
        print_status "FAIL" "This script must be run as root"
        exit 1
    fi
}

check_redhat_version() {
    log_output "Checking RedHat version..."
    if [[ -f /etc/redhat-release ]]; then
        REDHAT_VERSION=$(cat /etc/redhat-release)
        print_status "INFO" "RedHat version: $REDHAT_VERSION"
        if grep -q "Red Hat Enterprise Linux" /etc/redhat-release; then
            VERSION_NUM=$(grep -o '[0-9]\+' /etc/redhat-release | head -1)
            if [[ $VERSION_NUM -ge 7 && $VERSION_NUM -le 9 ]]; then
                print_status "PASS" "Supported RedHat version: RHEL $VERSION_NUM"
            else
                print_status "WARN" "RedHat version $VERSION_NUM may not be fully supported"
            fi
        else
            print_status "FAIL" "Not a RedHat Enterprise Linux system"
        fi
    else
        print_status "FAIL" "RedHat release file not found"
    fi
}

check_network_interfaces() {
    log_output "Checking network interfaces..."
    INTERFACES=($(ip link show | grep -E "^[0-9]+:" | awk -F: '{print $2}' | tr -d ' '))
    if [[ ${#INTERFACES[@]} -eq 0 ]]; then
        print_status "FAIL" "No network interfaces found"
        return
    fi
    print_status "INFO" "Found ${#INTERFACES[@]} network interface(s): ${INTERFACES[*]}"
    for interface in "${INTERFACES[@]}"; do
        if [[ "$interface" == "lo" ]]; then continue; fi
        if ip link show "$interface" | grep -q "UP"; then
            print_status "PASS" "Interface $interface is UP"
        else
            print_status "WARN" "Interface $interface is DOWN"
            if [[ "$MODE" == "fixed" ]]; then
                ip link set "$interface" up && print_status "PASS" "Brought up $interface (auto-fix)" || print_status "FAIL" "Failed to bring up $interface (auto-fix)"
            fi
        fi
        if ip addr show "$interface" | grep -q "inet "; then
            IP_ADDR=$(ip addr show "$interface" | grep "inet " | awk '{print $2}')
            print_status "INFO" "Interface $interface has IP: $IP_ADDR"
        else
            print_status "WARN" "Interface $interface has no IP address"
        fi
    done
}

check_vmware_tools() {
    log_output "Checking VMware Tools..."
    if command -v vmware-toolbox-cmd >/dev/null 2>&1; then
        print_status "PASS" "VMware Tools is installed"
        VMWARE_VERSION=$(vmware-toolbox-cmd -v 2>/dev/null | head -1)
        [[ -n "$VMWARE_VERSION" ]] && print_status "INFO" "VMware Tools version: $VMWARE_VERSION"
        if systemctl is-active --quiet vmtoolsd; then
            print_status "PASS" "VMware Tools service is running"
        else
            print_status "FAIL" "VMware Tools service is not running"
            if [[ "$MODE" == "fixed" ]]; then
                systemctl enable vmtoolsd && systemctl start vmtoolsd && print_status "PASS" "Started vmtoolsd (auto-fix)" || print_status "FAIL" "Failed to start vmtoolsd (auto-fix)"
            fi
        fi
    else
        print_status "FAIL" "VMware Tools is not installed"
        if [[ "$MODE" == "fixed" ]]; then
            yum install -y open-vm-tools && print_status "PASS" "Installed open-vm-tools (auto-fix)" || print_status "FAIL" "Failed to install open-vm-tools (auto-fix)"
            systemctl enable vmtoolsd && systemctl start vmtoolsd && print_status "PASS" "Started vmtoolsd (auto-fix)" || print_status "FAIL" "Failed to start vmtoolsd (auto-fix)"
        fi
    fi
}

check_cloud_init() {
    log_output "Checking cloud-init..."
    if command -v cloud-init >/dev/null 2>&1; then
        print_status "PASS" "cloud-init is installed"
        CLOUD_INIT_VERSION=$(cloud-init --version 2>/dev/null | head -1)
        [[ -n "$CLOUD_INIT_VERSION" ]] && print_status "INFO" "cloud-init version: $CLOUD_INIT_VERSION"
        if cloud-init status 2>/dev/null | grep -q "done"; then
            print_status "PASS" "cloud-init has completed successfully"
        else
            print_status "WARN" "cloud-init may not have completed properly"
        fi
    else
        print_status "WARN" "cloud-init is not installed (optional for vCenter customization)"
    fi
}

check_system_services() {
    log_output "Checking essential system services..."
    ESSENTIAL_SERVICES=("network" "sshd" "vmtoolsd")
    for service in "${ESSENTIAL_SERVICES[@]}"; do
        if systemctl is-enabled --quiet "$service" 2>/dev/null; then
            print_status "PASS" "Service $service is enabled"
        else
            print_status "WARN" "Service $service is not enabled"
            if [[ "$MODE" == "fixed" ]]; then
                systemctl enable "$service" && print_status "PASS" "Enabled $service (auto-fix)" || print_status "FAIL" "Failed to enable $service (auto-fix)"
            fi
        fi
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            print_status "PASS" "Service $service is running"
        else
            print_status "WARN" "Service $service is not running"
            if [[ "$MODE" == "fixed" ]]; then
                systemctl start "$service" && print_status "PASS" "Started $service (auto-fix)" || print_status "FAIL" "Failed to start $service (auto-fix)"
            fi
        fi
    done
}

check_disk_space() {
    log_output "Checking disk space..."
    ROOT_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $ROOT_USAGE -lt 80 ]]; then
        print_status "PASS" "Root filesystem usage: ${ROOT_USAGE}%"
    else
        print_status "WARN" "Root filesystem usage is high: ${ROOT_USAGE}%"
    fi
    AVAILABLE_GB=$(df / | tail -1 | awk '{print $4/1024/1024}')
    print_status "INFO" "Available space: ${AVAILABLE_GB%.2f} GB"
}

check_memory() {
    log_output "Checking memory..."
    TOTAL_MEM=$(free -g | grep Mem | awk '{print $2}')
    AVAILABLE_MEM=$(free -g | grep Mem | awk '{print $7}')
    print_status "INFO" "Total memory: ${TOTAL_MEM} GB"
    print_status "INFO" "Available memory: ${AVAILABLE_MEM} GB"
    if [[ $AVAILABLE_MEM -gt 0 ]]; then
        print_status "PASS" "Sufficient memory available"
    else
        print_status "WARN" "Low memory available"
    fi
}

check_security_settings() {
    log_output "Checking security settings..."
    if command -v getenforce >/dev/null 2>&1; then
        SELINUX_STATUS=$(getenforce)
        print_status "INFO" "SELinux status: $SELINUX_STATUS"
        if [[ "$SELINUX_STATUS" == "Disabled" ]]; then
            print_status "WARN" "SELinux is disabled (may be required for some environments)"
            if [[ "$MODE" == "fixed" ]]; then
                setenforce 1 && print_status "PASS" "Set SELinux to enforcing (auto-fix)" || print_status "FAIL" "Failed to set SELinux enforcing (auto-fix)"
            fi
        fi
    fi
    if command -v firewall-cmd >/dev/null 2>&1; then
        if firewall-cmd --state >/dev/null 2>&1; then
            print_status "INFO" "Firewall is active"
        else
            print_status "WARN" "Firewall is not active"
            if [[ "$MODE" == "fixed" ]]; then
                systemctl start firewalld && print_status "PASS" "Started firewalld (auto-fix)" || print_status "FAIL" "Failed to start firewalld (auto-fix)"
            fi
        fi
    fi
}

check_cleanup() {
    log_output "Checking for files that should be cleaned up..."
    LOG_FILES=("/var/log/messages" "/var/log/secure" "/var/log/audit/audit.log")
    for log_file in "${LOG_FILES[@]}"; do
        if [[ -f "$log_file" ]]; then
            LOG_SIZE=$(du -h "$log_file" | cut -f1)
            print_status "INFO" "Log file $log_file size: $LOG_SIZE"
            if [[ "$MODE" == "fixed" ]]; then
                truncate -s 0 "$log_file" && print_status "PASS" "Truncated $log_file (auto-fix)" || print_status "FAIL" "Failed to truncate $log_file (auto-fix)"
            fi
        fi
    done
    TEMP_COUNT=$(find /tmp -type f -mtime +7 2>/dev/null | wc -l)
    if [[ $TEMP_COUNT -gt 0 ]]; then
        print_status "WARN" "Found $TEMP_COUNT old temporary files (>7 days)"
        if [[ "$MODE" == "fixed" ]]; then
            find /tmp -type f -mtime +7 -delete && print_status "PASS" "Deleted old temp files (auto-fix)" || print_status "FAIL" "Failed to delete old temp files (auto-fix)"
        fi
    else
        print_status "PASS" "No old temporary files found"
    fi
    if command -v dnf >/dev/null 2>&1; then
        DNF_CACHE_SIZE=$(du -sh /var/cache/dnf 2>/dev/null | cut -f1)
        print_status "INFO" "DNF cache size: $DNF_CACHE_SIZE"
        if [[ "$MODE" == "fixed" ]]; then
            dnf clean all && print_status "PASS" "Cleaned DNF cache (auto-fix)" || print_status "FAIL" "Failed to clean DNF cache (auto-fix)"
        fi
    fi
}

check_network_config() {
    log_output "Checking network configuration..."
    if command -v nmcli >/dev/null 2>&1; then
        print_status "PASS" "NetworkManager is available"
        NM_DEVICES=$(nmcli device status | grep -v "lo" | wc -l)
        print_status "INFO" "NetworkManager managing $NM_DEVICES device(s)"
    fi
    STATIC_CONFIGS=$(find /etc/sysconfig/network-scripts/ -name "ifcfg-*" -type f 2>/dev/null | wc -l)
    if [[ $STATIC_CONFIGS -gt 0 ]]; then
        print_status "INFO" "Found $STATIC_CONFIGS network configuration file(s)"
    fi
}

check_running_processes() {
    log_output "Checking running processes..."
    UNNECESSARY_SERVICES=("tuned" "chronyd" "rsyslog" "auditd")
    for service in "${UNNECESSARY_SERVICES[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            print_status "INFO" "Service $service is running (consider if needed for template)"
            if [[ "$MODE" == "fixed" ]]; then
                systemctl stop "$service" && print_status "PASS" "Stopped $service (auto-fix)" || print_status "WARN" "Failed to stop $service (auto-fix)"
            fi
        fi
    done
    USER_PROCESSES=$(ps aux | grep -v root | grep -v "\[" | wc -l)
    if [[ $USER_PROCESSES -gt 5 ]]; then
        print_status "WARN" "Found $USER_PROCESSES user processes (consider cleaning up)"
    else
        print_status "PASS" "Minimal user processes running"
    fi
}

generate_recommendations() {
    log_output "Generating recommendations..."
    echo -e "\n${BLUE}=== RECOMMENDATIONS ===${NC}"
    if [[ $ERROR_COUNT -gt 0 ]]; then
        echo -e "${RED}CRITICAL ISSUES FOUND: $ERROR_COUNT${NC}"
        echo "Please fix these issues before converting to template:"
        echo "1. Install VMware Tools if missing"
        echo "2. Ensure network interfaces are properly configured"
        echo "3. Fix any failed service checks"
    fi
    if [[ $WARNING_COUNT -gt 0 ]]; then
        echo -e "${YELLOW}WARNINGS FOUND: $WARNING_COUNT${NC}"
        echo "Consider addressing these warnings:"
        echo "1. Clean up old log files and temporary files"
        echo "2. Review running services and disable unnecessary ones"
        echo "3. Check SELinux and firewall settings"
    fi
    echo -e "\n${GREEN}RECOMMENDED ACTIONS BEFORE TEMPLATE CONVERSION:${NC}"
    echo "1. Shutdown the VM properly (not suspend)"
    echo "2. Remove any snapshots"
    echo "3. Ensure VMware Tools is running"
    echo "4. Test network connectivity"
    echo "5. Verify cloud-init configuration (if using)"
    echo -e "\n${BLUE}LOG FILE: $LOG_FILE${NC}"
}

main() {
    select_mode
    echo "Log file: $LOG_FILE"
    echo ""
    touch "$LOG_FILE"
    check_root
    check_redhat_version
    check_network_interfaces
    check_vmware_tools
    check_cloud_init
    check_system_services
    check_disk_space
    check_memory
    check_security_settings
    check_cleanup
    check_network_config
    check_running_processes
    echo -e "\n${BLUE}=== SUMMARY ===${NC}"
    print_status "INFO" "Total errors: $ERROR_COUNT"
    print_status "INFO" "Total warnings: $WARNING_COUNT"
    if [[ $ERROR_COUNT -eq 0 ]]; then
        print_status "PASS" "Template is ready for conversion!"
    else
        print_status "FAIL" "Template needs fixes before conversion"
    fi
    generate_recommendations
    if [[ $ERROR_COUNT -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
}

main "$@" 