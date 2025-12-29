# LAMP Stack - Quick Start Guide

This guide will help you deploy the LAMP stack in under 5 minutes!

## 🎯 Prerequisites Checklist

- [ ] Ansible installed on your control machine
- [ ] Target server running RHEL/CentOS 7/8/9
- [ ] SSH access to target server (root or sudo user)
- [ ] Target server IP address

## 🚀 5-Minute Deployment

### Step 1: Configure Target Server (1 minute)

Edit `inventory.ini`:

```bash
nano inventory.ini
```

Replace `YOUR_SERVER_IP` with your actual server IP:

```ini
[webservers]
lamp-server ansible_host=192.168.1.100 ansible_user=root
```

Save and exit (Ctrl+X, then Y, then Enter)

### Step 2: Update Passwords (1 minute)

Edit `group_vars/all.yml`:

```bash
nano group_vars/all.yml
```

Update these passwords (IMPORTANT for security):

```yaml
mysql_root_password: "YourStrongRootPassword123!"
mysql_user_password: "YourStrongUserPassword123!"
```

Save and exit (Ctrl+X, then Y, then Enter)

### Step 3: Test Connection (30 seconds)

```bash
ansible webservers -m ping
```

Expected output:
```
lamp-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 4: Deploy LAMP Stack (2-3 minutes)

```bash
ansible-playbook site.yml
```

Watch the deployment progress. It will:
- ✓ Update system packages
- ✓ Configure SELinux
- ✓ Install and configure Apache
- ✓ Install and configure MariaDB
- ✓ Install and configure PHP
- ✓ Configure firewall rules
- ✓ Deploy test pages

### Step 5: Verify Deployment (30 seconds)

Open your web browser and visit:

1. **Home Page**: `http://YOUR_SERVER_IP/`
2. **PHP Info**: `http://YOUR_SERVER_IP/info.php`
3. **Database Test**: `http://YOUR_SERVER_IP/db_test.php`

## ✅ Success Indicators

You should see:
- ✓ A welcome page with server information
- ✓ PHP configuration details on info.php
- ✓ Successful database connection on db_test.php
- ✓ All services running (Apache, MariaDB)
- ✓ SELinux in enforcing mode

## 🔧 Common Issues & Quick Fixes

### Issue 1: Cannot connect to server

```bash
# Check SSH access
ssh root@YOUR_SERVER_IP

# If using SSH key
ssh -i ~/.ssh/your_key root@YOUR_SERVER_IP
```

### Issue 2: Permission denied

Update inventory.ini to use sudo:

```ini
[webservers:vars]
ansible_become=yes
ansible_become_method=sudo
```

### Issue 3: Python not found

Install Python 3 on target server:

```bash
ssh root@YOUR_SERVER_IP
yum install python3 -y
```

### Issue 4: Firewall blocking access

Manually open firewall:

```bash
ansible webservers -m shell -a "firewall-cmd --permanent --add-service=http && firewall-cmd --reload"
```

## 📊 Post-Deployment Checks

### Check all services are running:

```bash
ansible webservers -m shell -a "systemctl status httpd mariadb"
```

### Check SELinux status:

```bash
ansible webservers -m shell -a "sestatus"
```

### Check firewall rules:

```bash
ansible webservers -m shell -a "firewall-cmd --list-all"
```

### Test database connection:

```bash
ansible webservers -m shell -a "mysql -u root -p'YOUR_ROOT_PASSWORD' -e 'SHOW DATABASES;'"
```

## 🎓 Next Steps

1. **Remove test pages** (for production):
   ```bash
   ansible webservers -m file -a "path=/var/www/html/info.php state=absent"
   ansible webservers -m file -a "path=/var/www/html/db_test.php state=absent"
   ```

2. **Deploy your application**:
   - Upload your PHP files to `/var/www/html/`
   - Import your database schema
   - Configure your application

3. **Enable HTTPS**:
   - Obtain SSL certificate (Let's Encrypt recommended)
   - Configure Apache SSL virtual host
   - Update firewall for HTTPS

4. **Set up backups**:
   - Database backups
   - Web files backups
   - Configuration backups

## 🔒 Security Reminders

- ✓ Change all default passwords
- ✓ Remove test pages in production
- ✓ Keep SELinux in enforcing mode
- ✓ Enable HTTPS for production
- ✓ Regular security updates
- ✓ Use SSH keys instead of passwords
- ✓ Implement database backups

## 📞 Need Help?

Check the main README.md for:
- Detailed documentation
- Troubleshooting guide
- Advanced configuration
- Security best practices

## 🎉 Congratulations!

Your LAMP stack is now deployed and ready to use!

---

**Deployment Time**: ~5 minutes  
**Components**: Apache + MariaDB + PHP + SELinux  
**Status**: Production Ready ✓
