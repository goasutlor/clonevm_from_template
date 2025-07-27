# Template Pre-Check Script

## 📋 Overview

The `template_precheck.sh` script is a comprehensive system validation and preparation tool designed specifically for RedHat Linux templates used in the VM Provisioning System. This script ensures that your template is ready for bulk VM provisioning by performing thorough system checks and automatic fixes.

## 🎯 Purpose

Before using the VM Provisioning Program, it's **essential** to run this pre-check script on your RedHat Linux template to ensure:

- ✅ System compatibility and readiness
- ✅ Network configuration validation
- ✅ Security settings verification
- ✅ Package dependencies check
- ✅ Service status validation
- ✅ Storage and disk space verification

## 🚀 Quick Start

### Prerequisites

- **RedHat Enterprise Linux 7-9** template
- **Root access** (script must run as root)
- **Bash shell** environment
- **Network connectivity** for package updates

### Running the Script

1. **Download the script**:
   ```bash
   wget https://raw.githubusercontent.com/goasutlor/vmprovisioning_from_template/main/template_precheck.sh
   ```

2. **Make it executable**:
   ```bash
   chmod +x template_precheck.sh
   ```

3. **Run as root**:
   ```bash
   sudo ./template_precheck.sh
   ```

## 🔧 Script Modes

### 1. Audit Mode (Default)
- **Purpose**: Comprehensive system inspection only
- **Action**: Reports issues without making changes
- **Use Case**: Initial assessment and validation

### 2. Fixed Mode
- **Purpose**: Inspection + automatic fixes
- **Action**: Attempts to resolve common issues automatically
- **Use Case**: Template preparation for production

## 📊 What the Script Checks

### System Validation
- ✅ **RedHat Version**: Verifies RHEL 7-9 compatibility
- ✅ **Root Access**: Ensures proper privileges
- ✅ **System Architecture**: Validates x86_64 support
- ✅ **Kernel Version**: Checks kernel compatibility

### Network Configuration
- ✅ **Network Interfaces**: Validates all network adapters
- ✅ **IP Configuration**: Checks IP address assignment
- ✅ **DNS Resolution**: Verifies name resolution
- ✅ **Gateway Connectivity**: Tests default route
- ✅ **Network Services**: Ensures network services are running

### Security Settings
- ✅ **SELinux Status**: Checks SELinux configuration
- ✅ **Firewall Rules**: Validates firewall settings
- ✅ **SSH Configuration**: Verifies SSH service
- ✅ **User Accounts**: Checks user and group setup
- ✅ **Password Policies**: Validates password requirements

### Package Management
- ✅ **YUM/DNF**: Verifies package manager functionality
- ✅ **Repository Access**: Tests repository connectivity
- ✅ **Package Updates**: Checks for available updates
- ✅ **Essential Packages**: Validates required packages

### Service Management
- ✅ **Systemd**: Verifies systemd functionality
- ✅ **Core Services**: Checks essential service status
- ✅ **Service Dependencies**: Validates service relationships
- ✅ **Auto-start Services**: Ensures proper service configuration

### Storage and Disk
- ✅ **Disk Space**: Checks available storage
- ✅ **File Systems**: Validates filesystem integrity
- ✅ **Mount Points**: Verifies mount configuration
- ✅ **Swap Space**: Checks swap configuration

## 📝 Output and Logging

### Console Output
The script provides real-time feedback with color-coded status:

- 🟢 **GREEN [PASS]**: Check passed successfully
- 🔴 **RED [FAIL]**: Critical issue found
- 🟡 **YELLOW [WARN]**: Warning or recommendation
- 🔵 **BLUE [INFO]**: Informational message

### Log Files
- **Location**: `/tmp/template_precheck_YYYYMMDD_HHMMSS.log`
- **Content**: Detailed execution log with timestamps
- **Retention**: Logs are preserved for troubleshooting

### Summary Report
At the end of execution, the script provides:
- Total checks performed
- Number of passes/fails/warnings
- Overall system readiness score
- Recommendations for next steps

## 🔧 Common Fixes Applied

### Network Issues
- ✅ Enable disabled network interfaces
- ✅ Configure missing IP addresses
- ✅ Restart network services
- ✅ Update network configuration

### Package Issues
- ✅ Update package manager cache
- ✅ Install missing essential packages
- ✅ Enable required repositories
- ✅ Resolve package conflicts

### Service Issues
- ✅ Start stopped essential services
- ✅ Enable auto-start for required services
- ✅ Fix service dependencies
- ✅ Update service configurations

### Security Issues
- ✅ Configure SELinux policies
- ✅ Update firewall rules
- ✅ Secure SSH configuration
- ✅ Set proper file permissions

## ⚠️ Important Notes

### Before Running
1. **Backup your template** before running in fixed mode
2. **Test in audit mode first** to understand issues
3. **Ensure network connectivity** for package updates
4. **Have root access** ready

### After Running
1. **Review the log file** for detailed information
2. **Address any remaining FAIL items** manually
3. **Test the template** in a safe environment
4. **Document any custom configurations** made

## 🚨 Troubleshooting

### Common Issues

#### Script Permission Denied
```bash
chmod +x template_precheck.sh
```

#### Root Access Required
```bash
sudo ./template_precheck.sh
```

#### Network Connectivity Issues
```bash
# Check network status
systemctl status network
# Restart network service
systemctl restart network
```

#### Package Manager Issues
```bash
# Clear package cache
yum clean all
# Update package list
yum update
```

### Getting Help

If you encounter issues:

1. **Check the log file** for detailed error messages
2. **Run in audit mode** to identify specific problems
3. **Review system requirements** and prerequisites
4. **Contact support** with log file attached

## 📋 Integration with VM Provisioning

### Pre-Deployment Checklist
- [ ] Run template_precheck.sh in audit mode
- [ ] Address all FAIL items
- [ ] Run template_precheck.sh in fixed mode
- [ ] Verify all checks pass
- [ ] Test template functionality
- [ ] Proceed with VM provisioning

### Automated Integration
The VM Provisioning System can automatically:
- ✅ Run pre-check validation
- ✅ Apply template fixes
- ✅ Verify template readiness
- ✅ Generate compliance reports

## 📈 Best Practices

### Template Preparation
1. **Start with a clean base image**
2. **Run pre-check in audit mode first**
3. **Address critical issues manually**
4. **Use fixed mode for final preparation**
5. **Test the template thoroughly**
6. **Document any custom configurations**

### Maintenance
1. **Run pre-check regularly** on templates
2. **Update templates** with security patches
3. **Monitor template performance**
4. **Keep logs for troubleshooting**

## 🔗 Related Documentation

- [VM Provisioning System README](README.md)
- [Docker Deployment Guide](DOCKER_README.md)
- [API Documentation](API_README.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

---

**Script Version**: 1.0.0  
**Last Updated**: 2025-07-27  
**Compatibility**: RedHat Enterprise Linux 7-9  
**Maintainer**: [Your Organization] 