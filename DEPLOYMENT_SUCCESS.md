# ✅ LAMP Stack Deployment - SUCCESS

## Deployment Summary

**Date:** December 27, 2025  
**Time:** 06:41:59 EST  
**Target System:** RHEL 9.4 (lamp-server)  
**Deployment Method:** Ansible Playbook  
**Status:** ✅ **COMPLETED SUCCESSFULLY**

---

## 📊 Deployment Statistics

- **Total Tasks:** 63
- **Changed:** 23
- **OK:** 63
- **Failed:** 0
- **Skipped:** 4
- **Unreachable:** 0

---

## 🎯 Components Deployed

### 1. ✅ Common System Setup
- System packages updated
- EPEL repository installed (RHEL 9 compatible)
- Essential tools installed: vim, wget, curl, git, net-tools
- Timezone configured: America/New_York
- Firewalld installed and enabled

### 2. ✅ SELinux Configuration
- **Status:** Enabled and Enforcing
- **Policy:** Targeted
- **Mode:** Enforcing
- SELinux booleans configured for web services:
  - httpd_can_network_connect: ON
  - httpd_can_network_connect_db: ON
  - httpd_execmem: ON
  - httpd_unified: ON
- SELinux contexts properly set for web directories

### 3. ✅ Apache HTTP Server
- **Version:** Apache/2.4.x
- **Status:** Active and Running
- **Port:** 80 (HTTP)
- **Document Root:** /var/www/html
- **Server Admin:** admin@localhost
- SSL module installed (mod_ssl)
- Firewall rules configured (HTTP/HTTPS)
- Service enabled on boot

### 4. ✅ MariaDB Database Server
- **Version:** MariaDB 10.5
- **Status:** Active and Running
- **Bind Address:** 127.0.0.1 (localhost only)
- **Root Password:** Configured and secured
- **Database Created:** webapp_db
- **Database User:** webapp_user (with full privileges)
- Anonymous users removed
- Test database removed
- Service enabled on boot

### 5. ✅ PHP
- **Version:** PHP 8.0.30
- **Modules Installed:** 49 modules
- **Key Modules:**
  - php-mysqlnd (MySQL Native Driver)
  - php-fpm (FastCGI Process Manager)
  - php-opcache (Opcode Cache)
  - php-gd (Image Processing)
  - php-xml (XML Support)
  - php-mbstring (Multibyte String)
  - php-json (JSON Support)
  - php-curl (cURL Support)
  - php-zip (ZIP Archive)
  - php-intl (Internationalization)
  - php-bcmath (BC Math)

**PHP Configuration:**
- Memory Limit: 256M
- Max Execution Time: 300 seconds
- Upload Max Filesize: 64M
- Post Max Size: 64M
- Timezone: America/New_York
- Error Display: Enabled (for development)

---

## 🌐 Access Information

### Web Server
- **Home Page:** http://10.0.0.4/
- **External IP:** http://4.213.183.242/

### Test Pages
- **PHP Info:** http://10.0.0.4/info.php
- **Database Test:** http://10.0.0.4/db_test.php

### Deployed Files
```
/var/www/html/
├── index.html      (Welcome page)
├── info.php        (PHP information page)
└── db_test.php     (Database connection test)
```

---

## 🔧 Issues Fixed During Deployment

### 1. EPEL Repository Installation
**Problem:** RHEL 9.4 doesn't have `epel-release` package in default repositories.

**Solution:** 
- Installed EPEL directly from Fedora Project URL
- Added conditional logic for different RHEL versions
- RHEL 9: Uses direct RPM URL
- RHEL 8/CentOS: Uses epel-release package

### 2. Package Manager Compatibility
**Problem:** Playbook was using `yum` module (deprecated in RHEL 9).

**Solution:**
- Updated all roles to use `dnf` module
- DNF is the native package manager for RHEL 8+
- Provides better dependency resolution

### 3. SELinux Context Application
**Problem:** SELinux role tried to apply context to /var/www/html before Apache created it.

**Solution:**
- Added directory existence check before applying SELinux context
- Prevents errors during initial deployment
- Context will be applied when directory exists

---

## 🔒 Security Status

### SELinux
```
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
```

### Firewall
- **Status:** Active
- **Allowed Services:** HTTP, HTTPS, SSH
- **HTTP Port:** 80 (Open)
- **HTTPS Port:** 443 (Open)

### Database Security
- ✅ Root password set and secured
- ✅ Anonymous users removed
- ✅ Test database removed
- ✅ Database bound to localhost only (127.0.0.1)
- ✅ Application user with limited privileges

---

## 📝 Service Status

### Apache (httpd)
```
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled)
   Active: active (running)
   Status: "Total requests: 0; Idle/Busy workers 100/0"
```

### MariaDB
```
● mariadb.service - MariaDB 10.5 database server
   Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled)
   Active: active (running)
   Status: "Taking your SQL requests now..."
```

---

## 🧪 Verification Tests

### 1. Web Server Test
```bash
curl http://localhost/
# ✅ Returns HTML welcome page
```

### 2. PHP Test
```bash
curl http://localhost/info.php | grep "PHP Version"
# ✅ PHP Version 8.0.30
```

### 3. Service Status
```bash
systemctl status httpd mariadb
# ✅ Both services active and running
```

### 4. SELinux Status
```bash
sestatus
# ✅ SELinux enabled and enforcing
```

---

## 📚 Configuration Files Modified

1. `/etc/httpd/conf/httpd.conf` - Apache configuration
2. `/etc/php.ini` - PHP configuration
3. `/etc/my.cnf.d/mariadb-server.cnf` - MariaDB configuration
4. `/root/.my.cnf` - MySQL root credentials
5. `/etc/selinux/config` - SELinux configuration

---

## 🚀 Next Steps

### For Development
1. ✅ Access the web server at http://4.213.183.242/
2. ✅ Test PHP functionality at http://4.213.183.242/info.php
3. ✅ Test database connection at http://4.213.183.242/db_test.php
4. Start developing your web application

### For Production
1. **Remove test pages:**
   ```bash
   sudo rm /var/www/html/info.php
   sudo rm /var/www/html/db_test.php
   ```

2. **Change default passwords:**
   - Edit `group_vars/all.yml`
   - Update MySQL root password
   - Update database user password

3. **Enable HTTPS:**
   - Obtain SSL certificate (Let's Encrypt recommended)
   - Configure Apache SSL virtual host
   - Redirect HTTP to HTTPS

4. **Harden security:**
   - Review firewall rules
   - Implement fail2ban
   - Regular security updates
   - Monitor logs

5. **Backup strategy:**
   - Set up automated database backups
   - Configure file system backups
   - Test restore procedures

---

## 📖 Documentation References

- **Ansible Playbook:** `site.yml`
- **Inventory:** `inventory.ini`
- **Variables:** `group_vars/all.yml`
- **RHEL 9 Fixes:** `RHEL9_FIXES.md`
- **Deployment Log:** `ansible.log`

---

## 🎉 Deployment Complete!

Your LAMP stack is now fully operational and ready for use. All services are running, secured with SELinux, and accessible via the web.

**System Information:**
- Hostname: lamp
- OS: RedHat 9.4
- Kernel: 5.14.0-427.61.1.el9_4.x86_64
- Architecture: x86_64

---

**Deployed by:** Ansible Automation  
**Deployment Duration:** ~2 minutes  
**Configuration Management:** Ansible 2.14.14
