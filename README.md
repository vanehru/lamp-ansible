# LAMP Stack Ansible Playbook

A comprehensive, modular Ansible playbook for deploying a complete LAMP (Linux, Apache, MySQL, PHP) stack with SELinux enabled on RHEL/CentOS systems.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)

## ✨ Features

- **Modular Role-Based Structure**: Easy to maintain and extend
- **SELinux Enabled**: Properly configured for web services
- **Idempotent**: Safe to run multiple times
- **Firewall Configuration**: Automatic HTTP/HTTPS rules
- **Secure MySQL Setup**: Automated secure installation
- **Test Pages**: Includes PHP info and database connection test pages
- **Customizable Variables**: Easy configuration through group_vars
- **Production Ready**: Best practices and security hardening

## 📦 Components

- **Apache HTTP Server**: Web server with SSL support
- **MariaDB**: MySQL-compatible database server
- **PHP**: Latest PHP with common modules
- **SELinux**: Security-Enhanced Linux properly configured
- **Firewalld**: Firewall with web service rules

## 🔧 Prerequisites

### Control Node (Where you run Ansible)
- Ansible 2.9 or higher
- Python 3.6 or higher
- SSH access to target servers

### Target Servers
- RHEL/CentOS 7, 8, or 9 (or compatible distributions)
- Root or sudo access
- Python 3 installed
- SSH server running

### Install Ansible on Control Node

**On RHEL/CentOS:**
```bash
sudo yum install epel-release -y
sudo yum install ansible -y
```

**On Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ansible -y
```

**Verify Installation:**
```bash
ansible --version
```

## 📁 Project Structure

```
lamp-ansible/
├── ansible.cfg                 # Ansible configuration
├── inventory.ini              # Inventory file for target hosts
├── site.yml                   # Main playbook
├── group_vars/
│   └── all.yml               # Global variables
└── roles/
    ├── common/               # Common system setup
    │   └── tasks/
    │       └── main.yml
    ├── selinux/              # SELinux configuration
    │   ├── tasks/
    │   │   └── main.yml
    │   └── handlers/
    │       └── main.yml
    ├── apache/               # Apache web server
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── handlers/
    │   │   └── main.yml
    │   └── templates/
    │       └── index.html.j2
    ├── mysql/                # MySQL/MariaDB
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── handlers/
    │   │   └── main.yml
    │   └── templates/
    │       └── my.cnf.j2
    └── php/                  # PHP installation
        ├── tasks/
        │   └── main.yml
        └── templates/
            ├── info.php.j2
            └── db_test.php.j2
```

## 🚀 Quick Start

### 1. Clone or Download the Project

```bash
cd /home/azureuser/Desktop
# The lamp-ansible directory is already created
cd lamp-ansible
```

### 2. Configure Inventory

Edit `inventory.ini` and replace `YOUR_SERVER_IP` with your actual server IP:

```ini
[webservers]
lamp-server ansible_host=192.168.1.100 ansible_user=root
```

### 3. Configure Variables (Optional)

Edit `group_vars/all.yml` to customize:
- MySQL passwords
- Apache settings
- PHP configuration
- SELinux settings

### 4. Test Connection

```bash
ansible webservers -m ping
```

### 5. Run the Playbook

**Full deployment:**
```bash
ansible-playbook site.yml
```

**With verbose output:**
```bash
ansible-playbook site.yml -v
```

**Dry run (check mode):**
```bash
ansible-playbook site.yml --check
```

## ⚙️ Configuration

### Inventory Configuration

Edit `inventory.ini`:

```ini
[webservers]
server1 ansible_host=192.168.1.10 ansible_user=root
server2 ansible_host=192.168.1.11 ansible_user=root

[webservers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Variables Configuration

Edit `group_vars/all.yml`:

```yaml
# Apache Configuration
apache_listen_port: 80
apache_document_root: /var/www/html

# MySQL Configuration
mysql_root_password: "YourStrongPassword123!"
mysql_database: "myapp_db"
mysql_user: "myapp_user"
mysql_user_password: "UserPassword123!"

# PHP Configuration
php_memory_limit: "256M"
php_max_execution_time: "300"

# SELinux Configuration
selinux_state: enforcing  # Options: enforcing, permissive, disabled
```

## 📖 Usage

### Run Specific Roles

**Only install Apache:**
```bash
ansible-playbook site.yml --tags apache
```

**Only configure SELinux:**
```bash
ansible-playbook site.yml --tags selinux
```

**Install Apache and PHP:**
```bash
ansible-playbook site.yml --tags "apache,php"
```

### Available Tags

- `common` - System setup and updates
- `selinux` - SELinux configuration
- `apache` - Apache installation and configuration
- `mysql` - MySQL/MariaDB installation
- `php` - PHP installation and configuration
- `packages` - Package installation tasks
- `config` - Configuration tasks
- `security` - Security-related tasks

### Skip Specific Roles

```bash
ansible-playbook site.yml --skip-tags mysql
```

## 🧪 Testing

After deployment, verify the installation:

### 1. Check Services Status

```bash
ansible webservers -m shell -a "systemctl status httpd mariadb"
```

### 2. Access Web Pages

- **Home Page**: `http://YOUR_SERVER_IP/`
- **PHP Info**: `http://YOUR_SERVER_IP/info.php`
- **Database Test**: `http://YOUR_SERVER_IP/db_test.php`

### 3. Verify SELinux

```bash
ansible webservers -m shell -a "sestatus"
```

### 4. Check Firewall Rules

```bash
ansible webservers -m shell -a "firewall-cmd --list-all"
```

## 🔍 Troubleshooting

### Connection Issues

**Problem**: Cannot connect to target server
```bash
# Test SSH connection
ssh root@YOUR_SERVER_IP

# Check Ansible connectivity
ansible webservers -m ping -vvv
```

### SELinux Issues

**Problem**: Web pages not accessible due to SELinux
```bash
# Check SELinux denials
ansible webservers -m shell -a "ausearch -m avc -ts recent"

# Temporarily set to permissive for testing
ansible webservers -m shell -a "setenforce 0"
```

### Apache Issues

**Problem**: Apache not starting
```bash
# Check Apache status and logs
ansible webservers -m shell -a "systemctl status httpd"
ansible webservers -m shell -a "tail -50 /var/log/httpd/error_log"
```

### MySQL Issues

**Problem**: Cannot connect to database
```bash
# Check MariaDB status
ansible webservers -m shell -a "systemctl status mariadb"

# Test MySQL connection
ansible webservers -m shell -a "mysql -u root -p'YOUR_PASSWORD' -e 'SHOW DATABASES;'"
```

### Firewall Issues

**Problem**: Cannot access web server from outside
```bash
# Check firewall status
ansible webservers -m shell -a "firewall-cmd --list-all"

# Manually add HTTP rule
ansible webservers -m shell -a "firewall-cmd --permanent --add-service=http && firewall-cmd --reload"
```

## 🔒 Security Considerations

### Production Deployment

1. **Change Default Passwords**: Update all passwords in `group_vars/all.yml`
2. **Remove Test Pages**: Delete `info.php` and `db_test.php` after testing
3. **Enable HTTPS**: Configure SSL certificates for Apache
4. **Restrict Database Access**: Ensure MySQL only listens on localhost
5. **Keep SELinux Enforcing**: Never disable SELinux in production
6. **Regular Updates**: Keep all packages updated
7. **Use SSH Keys**: Avoid password authentication
8. **Limit Sudo Access**: Use least privilege principle

### Secure Password Management

Use Ansible Vault for sensitive data:

```bash
# Create encrypted variables file
ansible-vault create group_vars/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/vault.yml

# Run playbook with vault
ansible-playbook site.yml --ask-vault-pass
```

### SSL/TLS Configuration

To enable HTTPS:

1. Obtain SSL certificates (Let's Encrypt recommended)
2. Configure Apache SSL virtual host
3. Update firewall rules for HTTPS
4. Redirect HTTP to HTTPS

## 📝 Customization

### Adding Custom PHP Modules

Edit `roles/php/tasks/main.yml` and add to the package list:

```yaml
- php-ldap
- php-soap
- php-xmlrpc
```

### Custom Apache Virtual Hosts

Create a new template in `roles/apache/templates/` and add a task to deploy it.

### Additional Databases

Modify `roles/mysql/tasks/main.yml` to create additional databases and users.

## 🤝 Contributing

Feel free to customize and extend this playbook for your needs. Some ideas:

- Add Redis/Memcached support
- Implement automated backups
- Add monitoring (Prometheus, Grafana)
- Include log rotation configuration
- Add support for multiple PHP versions

## 📄 License

This playbook is provided as-is for educational and production use.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Ansible logs: `./ansible.log`
3. Check service logs on target servers
4. Verify SELinux audit logs: `/var/log/audit/audit.log`

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Apache Documentation](https://httpd.apache.org/docs/)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [PHP Documentation](https://www.php.net/docs.php)
- [SELinux User's Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/)

---

**Created with ❤️ for automated LAMP stack deployments**
