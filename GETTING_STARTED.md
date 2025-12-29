# 🚀 Getting Started with LAMP Stack Ansible

Welcome! This guide will help you deploy your LAMP stack in minutes.

## 📋 What You'll Get

After running this playbook, you'll have:

- ✅ **Apache** web server (with SSL support)
- ✅ **MariaDB** database server (MySQL-compatible)
- ✅ **PHP** with common modules
- ✅ **SELinux** properly configured
- ✅ **Firewall** rules for HTTP/HTTPS
- ✅ **Test pages** to verify everything works

## 🎯 Prerequisites

### On Your Control Machine (where you run Ansible):
- Ansible 2.9 or higher installed
- SSH access to target server(s)

### On Target Server(s):
- RHEL/CentOS 7, 8, or 9 (or compatible)
- Root or sudo access
- Internet connection

## ⚡ Quick Start (3 Steps)

### Step 1: Configure Your Server IP

Edit `inventory.ini`:
```bash
nano inventory.ini
```

Change this line:
```ini
lamp-server ansible_host=YOUR_SERVER_IP ansible_user=root
```

To (example):
```ini
lamp-server ansible_host=192.168.1.100 ansible_user=root
```

Save and exit (Ctrl+X, Y, Enter)

### Step 2: Update Passwords (IMPORTANT!)

Edit `group_vars/all.yml`:
```bash
nano group_vars/all.yml
```

Change these passwords:
```yaml
mysql_root_password: "YourStrongRootPassword123!"
mysql_user_password: "YourStrongUserPassword123!"
```

Save and exit (Ctrl+X, Y, Enter)

### Step 3: Deploy!

**Option A - Interactive (Recommended for first time):**
```bash
./deploy.sh
```

**Option B - Direct deployment:**
```bash
ansible-playbook site.yml
```

That's it! ☕ Grab a coffee while it deploys (takes 2-3 minutes).

## 🎉 After Deployment

### Access Your Server

Open your web browser and visit:

1. **Home Page**: `http://YOUR_SERVER_IP/`
   - Shows server information and confirms Apache is working

2. **PHP Info**: `http://YOUR_SERVER_IP/info.php`
   - Displays PHP configuration and loaded modules

3. **Database Test**: `http://YOUR_SERVER_IP/db_test.php`
   - Tests MySQL/MariaDB connection

### Verify Everything Works

Run the verification script:
```bash
./verify.sh
```

This checks:
- ✓ All services are running
- ✓ SELinux is configured
- ✓ Firewall rules are set
- ✓ PHP is working
- ✓ Database is accessible

## 📚 What's Next?

### For Development/Testing:
You're all set! Start developing your PHP application.

### For Production:

1. **Remove test pages** (security):
   ```bash
   ansible webservers -m file -a "path=/var/www/html/info.php state=absent"
   ansible webservers -m file -a "path=/var/www/html/db_test.php state=absent"
   ```

2. **Enable HTTPS**:
   - Get SSL certificate (Let's Encrypt recommended)
   - Configure Apache SSL virtual host
   - Force HTTPS redirect

3. **Secure MySQL**:
   - Change passwords in `group_vars/all.yml`
   - Use Ansible Vault for sensitive data:
     ```bash
     ansible-vault encrypt group_vars/all.yml
     ```

4. **Deploy your application**:
   - Upload files to `/var/www/html/`
   - Import database schema
   - Configure application settings

## 🔧 Common Commands

### Deployment Commands:
```bash
# Full deployment
ansible-playbook site.yml

# Deploy with verbose output
ansible-playbook site.yml -v

# Dry run (no changes)
ansible-playbook site.yml --check

# Deploy only Apache
ansible-playbook site.yml --tags apache

# Deploy only MySQL
ansible-playbook site.yml --tags mysql
```

### Management Commands:
```bash
# Test connection
ansible webservers -m ping

# Check service status
ansible webservers -m shell -a "systemctl status httpd mariadb"

# Restart Apache
ansible webservers -m systemd -a "name=httpd state=restarted"

# Check SELinux status
ansible webservers -m shell -a "sestatus"

# View firewall rules
ansible webservers -m shell -a "firewall-cmd --list-all"
```

## 🆘 Troubleshooting

### Can't connect to server?
```bash
# Test SSH manually
ssh root@YOUR_SERVER_IP

# Check with verbose output
ansible webservers -m ping -vvv
```

### Services not starting?
```bash
# Check service status
ansible webservers -m shell -a "systemctl status httpd mariadb"

# View logs
ansible webservers -m shell -a "journalctl -u httpd -n 50"
```

### Can't access web page?
```bash
# Check firewall
ansible webservers -m shell -a "firewall-cmd --list-all"

# Temporarily disable firewall (testing only!)
ansible webservers -m shell -a "systemctl stop firewalld"
```

### SELinux blocking access?
```bash
# Check SELinux denials
ansible webservers -m shell -a "ausearch -m avc -ts recent"

# Temporarily set permissive (testing only!)
ansible webservers -m shell -a "setenforce 0"
```

## 📖 Documentation

- **README.md** - Complete documentation
- **QUICKSTART.md** - 5-minute deployment guide
- **PROJECT_STRUCTURE.txt** - Project layout and details
- **This file** - Getting started guide

## 🔐 Security Reminders

Before going to production:

- [ ] Change all default passwords
- [ ] Remove test pages (info.php, db_test.php)
- [ ] Enable HTTPS with valid SSL certificate
- [ ] Use Ansible Vault for sensitive data
- [ ] Keep SELinux in enforcing mode
- [ ] Set up automated backups
- [ ] Configure log rotation
- [ ] Enable automatic security updates

## 💡 Tips

1. **Use tags** to deploy specific components:
   ```bash
   ansible-playbook site.yml --tags "apache,php"
   ```

2. **Run in check mode** first to see what will change:
   ```bash
   ansible-playbook site.yml --check
   ```

3. **Use the interactive script** for easier deployment:
   ```bash
   ./deploy.sh
   ```

4. **Verify after deployment**:
   ```bash
   ./verify.sh
   ```

5. **Keep your playbook in version control** (Git):
   ```bash
   git init
   git add .
   git commit -m "Initial LAMP stack playbook"
   ```

## 🎓 Learning Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Apache HTTP Server](https://httpd.apache.org/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [PHP Manual](https://www.php.net/manual/en/)
- [SELinux User Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/using_selinux/)

## 🤝 Need Help?

1. Check the troubleshooting section above
2. Review the README.md for detailed information
3. Check Ansible logs: `./ansible.log`
4. Review service logs on target server

## ✨ Features

This playbook includes:

- **Modular design** - Easy to customize and extend
- **Idempotent** - Safe to run multiple times
- **Production-ready** - Security best practices included
- **Well-documented** - Comprehensive guides and comments
- **Tested** - Works on RHEL/CentOS 7, 8, and 9
- **Automated** - One command deployment
- **Verifiable** - Built-in verification script

## 🎊 Success!

If you can access the web pages and see the welcome screen, congratulations! 🎉

Your LAMP stack is now deployed and ready to use.

---

**Happy coding!** 💻

For questions or issues, refer to the documentation files or check the troubleshooting sections.
