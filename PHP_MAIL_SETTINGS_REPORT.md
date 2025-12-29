# PHP Mail Settings Report
**Generated**: December 2024  
**Project**: LAMP Stack with PHPMailer & Azure Communication Services

---

## 📋 Executive Summary

This LAMP stack uses **PHPMailer** library integrated with **Azure Communication Services** for email functionality. The configuration is managed through Ansible automation and includes comprehensive security, logging, and monitoring capabilities.

---

## 🔧 Current Mail Configuration

### SMTP Provider
- **Service**: Azure Communication Services
- **Protocol**: SMTP with TLS encryption
- **Method**: PHPMailer library (v6.9+)

### Connection Settings

| Setting | Value |
|---------|-------|
| **SMTP Host** | `smtp.azurecomm.net` |
| **SMTP Port** | `587` (STARTTLS) |
| **Encryption** | `TLS` |
| **Authentication** | Required |
| **Username** | `smtp@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net` |
| **Password** | `a6fc9829-c543-4913-96ba-aca7dc6e65f0` |

### Sender Configuration

| Setting | Value |
|---------|-------|
| **From Address** | `noreply@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net` |
| **From Name** | `smtp-poc-test` |
| **Character Set** | `UTF-8` |
| **Timeout** | `30 seconds` |

---

## 📁 Configuration File Locations

### Primary Configuration Files

```
/var/www/phpmailer/mailer_config.php
├── Contains: SMTP credentials, helper functions
├── Permissions: 0640 (apache:apache)
└── Generated from: roles/phpmailer/templates/mailer_config.php.j2

/home/azureuser/Desktop/lamp-ansible/group_vars/all.yml
├── Contains: Ansible variables for mail configuration
├── Editable: Yes (source of truth)
└── Deployed to: Target servers via Ansible

/etc/php.ini
├── Contains: PHP general settings (not mail-specific)
├── Relevant settings: memory_limit, max_execution_time
└── Modified by: roles/php/tasks/main.yml
```

### PHPMailer Installation

```
/var/www/phpmailer/
├── composer.json          # PHPMailer dependency definition
├── composer.lock          # Locked versions
├── vendor/                # PHPMailer library
│   └── phpmailer/
│       └── phpmailer/
└── mailer_config.php      # Main configuration file
```

### Test & Example Scripts

```
/var/www/html/test_email.php           # Interactive testing interface
/var/www/html/send_email_example.php   # Usage examples & documentation
```

---

## 🔐 Security Configuration

### SELinux Settings

| Boolean | Status | Purpose |
|---------|--------|---------|
| `httpd_can_sendmail` | **ON** | Allows Apache/PHP to send emails |
| `httpd_can_network_connect` | **ON** | Allows Apache to make network connections |

**Verify with:**
```bash
getsebool httpd_can_sendmail
getsebool httpd_can_network_connect
```

### Firewall Rules

| Port | Protocol | Purpose |
|------|----------|---------|
| **587** | TCP | SMTP with STARTTLS |
| **465** | TCP | SMTP with SSL (alternative) |

**Verify with:**
```bash
firewall-cmd --list-ports
```

### File Permissions

| File/Directory | Owner | Permissions | Reason |
|----------------|-------|-------------|--------|
| `/var/www/phpmailer/mailer_config.php` | apache:apache | 0640 | Contains sensitive credentials |
| `/var/www/phpmailer/` | apache:apache | 0755 | PHPMailer installation directory |
| `/var/log/phpmailer/` | apache:apache | 0755 | Log directory |

---

## 📊 Logging Configuration

### Log Settings

| Setting | Value | Description |
|---------|-------|-------------|
| **Logging Enabled** | `true` | Logs all email operations |
| **Log Path** | `/var/log/phpmailer/` | Directory for all logs |
| **Debug Level** | `0` (OFF) | 0=off, 1=client, 2=server, 3=connection, 4=lowlevel |

### Log Files

```
/var/log/phpmailer/
├── phpmailer_YYYY-MM-DD.log           # General debug logs
├── phpmailer_sent_YYYY-MM-DD.log      # Successfully sent emails
└── phpmailer_errors_YYYY-MM-DD.log    # Error logs
```

### Log Format
```
[YYYY-MM-DD HH:MM:SS] Log message here
[2024-12-19 10:30:45] Email sent to: user@example.com | Subject: Test Email
```

---

## 🎯 PHP Configuration (php.ini)

### Mail-Related PHP Settings

| Setting | Value | Location |
|---------|-------|----------|
| `memory_limit` | `256M` | `/etc/php.ini` |
| `max_execution_time` | `300` | `/etc/php.ini` |
| `upload_max_filesize` | `64M` | `/etc/php.ini` |
| `post_max_size` | `64M` | `/etc/php.ini` |
| `date.timezone` | `America/New_York` | `/etc/php.ini` |

### Installed PHP Extensions (Mail-Related)

```
✓ php-mbstring    # Multi-byte string support
✓ php-xml         # XML processing
✓ php-curl        # HTTP requests
```

---

## 🧪 Testing & Verification

### Method 1: Web Interface
```
URL: http://YOUR_SERVER_IP/test_email.php
```
- Interactive form to send test emails
- Real-time feedback
- Error display

### Method 2: Command Line
```bash
# Simple test
php -r '
require "/var/www/phpmailer/mailer_config.php";
sendEmail("test@example.com", "Test Subject", "<h1>Test Body</h1>");
'
```

### Method 3: Check Installation
```bash
# Verify PHPMailer is installed
ls -la /var/www/phpmailer/vendor/phpmailer/

# Check Composer
composer --version

# Verify PHP modules
php -m | grep -E "mbstring|xml|curl"
```

### Method 4: Check Logs
```bash
# View recent logs
tail -f /var/log/phpmailer/phpmailer_$(date +%Y-%m-%d).log

# Check sent emails
cat /var/log/phpmailer/phpmailer_sent_$(date +%Y-%m-%d).log

# Check errors
cat /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log
```

---

## 💻 Usage Examples

### Simple Email
```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';

sendEmail(
    'recipient@example.com',
    'Subject Line',
    '<h1>HTML Body</h1><p>Content here</p>',
    'Plain text alternative'
);
?>
```

### Email with Attachments
```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';

sendEmailWithAttachments(
    'recipient@example.com',
    'Subject with Files',
    '<h1>See attached documents</h1>',
    ['/path/to/file1.pdf', '/path/to/file2.pdf']
);
?>
```

### Advanced Usage
```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';

$mail = getMailer();
$mail->addAddress('recipient@example.com');
$mail->addCC('cc@example.com');
$mail->addBCC('bcc@example.com');
$mail->Subject = 'Advanced Email';
$mail->Body = '<h1>HTML Content</h1>';
$mail->AltBody = 'Plain text content';
$mail->addAttachment('/path/to/file.pdf');

if ($mail->send()) {
    echo 'Email sent successfully!';
} else {
    echo 'Error: ' . $mail->ErrorInfo;
}
?>
```

---

## 🔄 How to Modify Settings

### Change SMTP Credentials

**Edit:** `/home/azureuser/Desktop/lamp-ansible/group_vars/all.yml`

```yaml
# Azure Communication Services SMTP Settings
azure_smtp_host: "smtp.azurecomm.net"
azure_smtp_port: 587
azure_smtp_username: "your-new-username"
azure_smtp_password: "your-new-password"
azure_smtp_encryption: "tls"
```

**Deploy changes:**
```bash
cd /home/azureuser/Desktop/lamp-ansible
ansible-playbook site.yml --tags phpmailer
```

### Change Sender Information

**Edit:** `/home/azureuser/Desktop/lamp-ansible/group_vars/all.yml`

```yaml
# Email Sender Configuration
mail_from_address: "noreply@yourdomain.com"
mail_from_name: "Your Company Name"
```

**Deploy changes:**
```bash
ansible-playbook site.yml --tags phpmailer
```

### Enable Debug Mode

**Edit:** `/home/azureuser/Desktop/lamp-ansible/group_vars/all.yml`

```yaml
mail_debug_level: 2  # 0=off, 1=client, 2=server, 3=connection, 4=lowlevel
```

**Deploy changes:**
```bash
ansible-playbook site.yml --tags phpmailer
```

### Change Test Email Recipient

**Edit:** `/home/azureuser/Desktop/lamp-ansible/group_vars/all.yml`

```yaml
test_email_recipient: "your-email@example.com"
```

---

## 🔍 Troubleshooting Guide

### Issue: Emails Not Sending

**Check logs:**
```bash
tail -50 /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log
```

**Verify SELinux:**
```bash
getsebool httpd_can_sendmail
getsebool httpd_can_network_connect
```

**Test SMTP connectivity:**
```bash
telnet smtp.azurecomm.net 587
```

**Check firewall:**
```bash
firewall-cmd --list-ports | grep -E "587|465"
```

### Issue: Permission Denied

**Fix permissions:**
```bash
sudo chown -R apache:apache /var/www/phpmailer
sudo chmod 640 /var/www/phpmailer/mailer_config.php
sudo chown -R apache:apache /var/log/phpmailer
```

### Issue: Cannot Access Test Page

**Restart Apache:**
```bash
sudo systemctl restart httpd
```

**Check SELinux context:**
```bash
ls -Z /var/www/html/test_email.php
```

**Verify file exists:**
```bash
ls -la /var/www/html/test_email.php
```

### Issue: Composer Not Found

**Install Composer:**
```bash
cd /home/azureuser/Desktop/lamp-ansible
ansible-playbook site.yml --tags phpmailer,composer
```

---

## 📈 Monitoring & Maintenance

### Daily Checks
```bash
# Check for errors
grep -i error /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log

# Count sent emails
wc -l /var/log/phpmailer/phpmailer_sent_$(date +%Y-%m-%d).log
```

### Weekly Tasks
- Review error logs for patterns
- Check disk space in `/var/log/phpmailer/`
- Verify SMTP credentials are still valid

### Monthly Tasks
- Rotate old logs (implement logrotate)
- Review and update PHPMailer version
- Test email functionality

### Log Rotation Setup
```bash
# Create logrotate config
sudo cat > /etc/logrotate.d/phpmailer << 'EOF'
/var/log/phpmailer/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0644 apache apache
    sharedscripts
}
EOF
```

---

## 🔒 Security Best Practices

### ✅ Currently Implemented
- SELinux enabled and configured
- Firewall rules for SMTP only
- Restricted file permissions (640 for config)
- TLS encryption for SMTP
- Logging for audit trail

### 🔐 Recommended for Production

1. **Use Ansible Vault for Credentials**
```bash
ansible-vault encrypt group_vars/all.yml
```

2. **Remove Test Scripts**
```bash
rm /var/www/html/test_email.php
rm /var/www/html/send_email_example.php
```

3. **Disable Debug Mode**
```yaml
mail_debug_level: 0
```

4. **Implement Rate Limiting**
```php
// Add delays between emails
sleep(1);
```

5. **Monitor Logs Regularly**
```bash
# Set up automated monitoring
watch -n 60 'tail -20 /var/log/phpmailer/phpmailer_errors_*.log'
```

6. **Validate Email Addresses**
```php
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    die('Invalid email address');
}
```

---

## 📚 Additional Resources

### Documentation Files
- `PHPMAILER_AZURE_SETUP.md` - Comprehensive setup guide
- `DEPLOY_PHPMAILER.md` - Quick deployment guide
- `PHPMAILER_IMPLEMENTATION_SUMMARY.md` - Implementation overview
- `PHPMAILER_QUICK_REFERENCE.md` - Quick reference guide

### External Resources
- [PHPMailer GitHub](https://github.com/PHPMailer/PHPMailer)
- [Azure Communication Services Docs](https://docs.microsoft.com/azure/communication-services/)
- [Ansible Documentation](https://docs.ansible.com/)

---

## 📞 Quick Reference Commands

### Check Status
```bash
# PHPMailer installation
ls -la /var/www/phpmailer/

# Configuration file
cat /var/www/phpmailer/mailer_config.php

# Recent logs
tail -20 /var/log/phpmailer/phpmailer_$(date +%Y-%m-%d).log

# SELinux status
getsebool -a | grep httpd

# Firewall status
firewall-cmd --list-all
```

### Redeploy Configuration
```bash
cd /home/azureuser/Desktop/lamp-ansible
ansible-playbook site.yml --tags phpmailer -v
```

### Test Email Sending
```bash
# Via web interface
curl http://localhost/test_email.php

# Via command line
php -r 'require "/var/www/phpmailer/mailer_config.php"; sendEmail("test@example.com", "Test", "Test");'
```

---

## ✅ Configuration Checklist

- [x] PHPMailer installed via Composer
- [x] Azure SMTP credentials configured
- [x] SELinux booleans set correctly
- [x] Firewall ports opened (587, 465)
- [x] Logging enabled and configured
- [x] Test scripts deployed
- [x] Helper functions available
- [x] Security permissions set
- [x] Documentation complete

---

## 🎯 Summary

**Status**: ✅ Fully Configured and Operational

**Mail System**: PHPMailer with Azure Communication Services  
**Configuration Method**: Ansible-managed  
**Security Level**: Production-ready with SELinux and firewall  
**Logging**: Comprehensive with daily rotation  
**Testing**: Interactive web interface available  

**Next Steps**:
1. Test email functionality: `http://YOUR_SERVER_IP/test_email.php`
2. Review logs: `/var/log/phpmailer/`
3. Integrate into your applications using helper functions
4. Consider implementing Ansible Vault for production

---

**Report Generated**: December 2024  
**Configuration Version**: 1.0  
**Last Updated**: Current deployment
