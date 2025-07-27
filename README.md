# VM Provisioning System

A comprehensive web-based Virtual Machine provisioning and management system built with Flask. This application provides an intuitive interface for creating, managing, and monitoring virtual machines across different environments.

## 🚀 Features

### Core Functionality
- **VM Creation**: Automated VM provisioning from templates
- **Real-time Monitoring**: Live progress tracking and status updates
- **Web Dashboard**: Modern, responsive web interface
- **Template Management**: Pre-configured VM templates for quick deployment
- **Template Pre-Check**: Comprehensive template validation and preparation
- **Progress Tracking**: Detailed progress logs and status indicators
- **Error Handling**: Comprehensive error reporting and recovery

### Technical Features
- **Flask Web Framework**: Lightweight and flexible Python web framework
- **Docker Support**: Containerized deployment with Docker
- **RESTful API**: Clean API endpoints for integration
- **Real-time Updates**: Server-Sent Events (SSE) for live updates
- **Responsive Design**: Mobile-friendly web interface

## 📋 Prerequisites

Before running this application, ensure you have:

- **Python 3.8+** installed
- **Git** for version control
- **Docker** (optional, for containerized deployment)
- **Virtual Environment** (recommended)

### 🎯 Template Preparation (IMPORTANT)

**Before using the VM Provisioning System, you MUST prepare your RedHat Linux templates:**

1. **Download the pre-check script**:
   ```bash
   wget https://raw.githubusercontent.com/goasutlor/vmprovisioning_from_template/main/template_precheck.sh
   chmod +x template_precheck.sh
   ```

2. **Run the template validation**:
   ```bash
   sudo ./template_precheck.sh
   ```

3. **Follow the script recommendations** to ensure your template is ready for bulk VM provisioning.

**📖 For detailed information about template preparation, see [Template Pre-Check Documentation](TEMPLATE_PRECHECK_README.md)**

## 🛠️ Installation

### Method 1: Direct Python Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/goasutlor/vmprovisioning_from_template.git
   cd vmprovisioning_from_template
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**:
   ```bash
   python app.py
   ```

### Method 2: Docker Deployment

1. **Pull the Docker image**:
   ```bash
   docker pull ghcr.io/goasutlor/vmprovisioning_from_template:latest
   ```

2. **Run the container**:
   ```bash
   docker run -p 9999:9999 ghcr.io/goasutlor/vmprovisioning_from_template:latest
   ```

## 🌐 Usage

### Accessing the Application

Once running, access the application at:
```
http://localhost:9999
```

### Main Features

1. **Dashboard**: Overview of all VMs and their status
2. **VM Creation**: Create new VMs from templates
3. **Template Pre-Check**: Validate and prepare templates
4. **Progress Monitoring**: Real-time progress tracking
5. **Logs**: Detailed operation logs
6. **Settings**: Configuration management

### 🎯 Template Preparation for Clone Feature

**⚠️ IMPORTANT: Before using the Clone Feature, you MUST prepare your templates:**

The Clone Feature creates VMs by cloning existing templates. To ensure successful cloning, follow these steps:

#### **Step 1: Template Pre-Check (REQUIRED)**
```bash
# Download the pre-check script
wget https://raw.githubusercontent.com/goasutlor/vmprovisioning_from_template/main/template_precheck.sh
chmod +x template_precheck.sh

# Run the script on your template VM
sudo ./template_precheck.sh
```

#### **Step 2: Verify Template Readiness**
The script will check and fix:
- ✅ **Network Configuration** - Ensures proper network setup
- ✅ **Security Settings** - Validates firewall and SELinux
- ✅ **Package Management** - Checks YUM/DNF functionality
- ✅ **Service Status** - Verifies essential services
- ✅ **Storage Configuration** - Validates disk and filesystem
- ✅ **System Compatibility** - Ensures RHEL 7-9 compatibility

#### **Step 3: Template Best Practices**
- **Clean State**: Start with a fresh, minimal template
- **Updated Packages**: Ensure all packages are up-to-date
- **Proper Shutdown**: Always shut down templates properly
- **Consistent Configuration**: Use standardized settings
- **Documentation**: Keep records of template configurations

#### **Step 4: Clone Feature Usage**
After template preparation:
1. **Select Template**: Choose your validated template
2. **Configure VM Settings**: Set hostname, IP, and other parameters
3. **Start Cloning**: The system will clone from the prepared template
4. **Monitor Progress**: Track real-time cloning progress
5. **Verify Results**: Check that cloned VMs are working correctly

**📖 For detailed template preparation guide, see [Template Pre-Check Documentation](TEMPLATE_PRECHECK_README.md)**

## 🏗️ Project Structure

```
vm_provisioning/
├── app.py                           # Main Flask application
├── vm_provision.py                  # Core VM provisioning logic
├── progress_table_ref.py            # Progress tracking system
├── config.py                       # Configuration management
├── requirements.txt                # Python dependencies
├── Dockerfile                     # Docker configuration
├── template_precheck.sh           # Template validation script
├── TEMPLATE_PRECHECK_README.md    # Template preparation guide
├── templates/                     # HTML templates
│   ├── dashboard.html             # Main dashboard
│   ├── login.html                 # Authentication page
│   └── progress.html              # Progress tracking
├── static/                       # Static assets
│   ├── css/                      # Stylesheets
│   ├── js/                       # JavaScript files
│   └── images/                   # Image assets
└── __init__.py                   # Package initialization
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the project root:

```env
FLASK_ENV=development
FLASK_DEBUG=True
PORT=9999
HOST=127.0.0.1
```

### Application Settings

Key configuration options in `config.py`:

- **Port**: Default application port (9999)
- **Host**: Binding address (127.0.0.1)
- **Debug**: Debug mode for development
- **Logging**: Log level and output configuration

## 📊 API Endpoints

### Core Endpoints

- `GET /` - Main dashboard
- `GET /api/vms` - List all VMs
- `POST /api/vms` - Create new VM
- `GET /api/vms/<id>` - Get VM details
- `PUT /api/vms/<id>` - Update VM
- `DELETE /api/vms/<id>` - Delete VM

### Progress Tracking

- `GET /api/progress` - Get progress updates
- `GET /api/logs` - Get operation logs
- `POST /api/progress` - Update progress

## 🐳 Docker Support

### Building the Image

```bash
docker build -t vm-provisioning .
```

### Running with Docker Compose

```yaml
version: '3.8'
services:
  vm-provisioning:
    image: ghcr.io/goasutlor/vmprovisioning_from_template:latest
    ports:
      - "9999:9999"
    environment:
      - FLASK_ENV=production
    volumes:
      - ./logs:/app/logs
```

## 🧪 Development

### Setting Up Development Environment

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Run tests** (if available)
5. **Submit a pull request**

### Code Style

- Follow PEP 8 Python style guidelines
- Use meaningful variable and function names
- Add docstrings to functions and classes
- Include type hints where appropriate

## 📝 Logging

The application uses structured logging with different levels:

- **INFO**: General application information
- **WARNING**: Non-critical issues
- **ERROR**: Application errors
- **DEBUG**: Detailed debugging information

Logs are written to both console and file (if configured).

## 🔒 Security Considerations

- **Input Validation**: All user inputs are validated
- **Error Handling**: Comprehensive error handling prevents information leakage
- **Authentication**: User authentication system (if implemented)
- **HTTPS**: Use HTTPS in production environments

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Add tests** (if applicable)
5. **Update documentation**
6. **Submit a pull request**

### Contribution Guidelines

- Follow the existing code style
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help

- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions

### Common Issues

1. **Port already in use**: Change the port in `config.py`
2. **Dependencies missing**: Run `pip install -r requirements.txt`
3. **Permission errors**: Check file permissions and Docker settings

### Clone Feature Issues

4. **Template clone failures**: 
   - Run template pre-check script first
   - Ensure template is properly shut down
   - Verify template has sufficient disk space
   - Check template network configuration

5. **Cloned VM network issues**:
   - Verify template network settings
   - Check DHCP/DNS configuration
   - Ensure proper IP address assignment

6. **Template compatibility problems**:
   - Use only RHEL 7-9 templates
   - Run template pre-check in fixed mode
   - Update template packages before cloning

## 📈 Roadmap

### Planned Features

- [ ] Multi-cloud support (AWS, Azure, GCP)
- [ ] Advanced VM templates
- [ ] User management system
- [ ] API rate limiting
- [ ] Enhanced monitoring dashboard
- [ ] Backup and restore functionality
- [ ] Automated template validation
- [ ] Template lifecycle management
- [ ] Clone feature enhancements

### Version History

- **v1.0.0**: Initial release with basic VM provisioning
- **v1.1.0**: Added progress tracking and real-time updates
- **v1.2.0**: Docker support and improved UI
- **v1.3.0**: Added template pre-check validation and Clone Feature enhancements

## 🙏 Acknowledgments

- Flask community for the excellent web framework
- Docker team for containerization support
- All contributors and users of this project

---

**Last Updated**: 2025-07-27  
**Version**: 1.2.0  
**Maintainer**: [Your Name/Organization] 