# Quick Deployment Guide - PHPMailer with Azure Email Services

## 🚀 Ready to Deploy!

All files have been created and configured. Follow these steps to deploy PHPMailer with Azure Communication Services.

## ✅ Pre-Deployment Checklist

- [x] PHPMailer role created in `roles/phpmailer/`
- [x] Azure SMTP credentials configured in `group_vars/all.yml`
- [x] Playbook updated with phpmailer role
- [x] Templates created for configuration and testing
- [x] Documentation completed

## 📋 Deployment Steps

### Step 1: Verify Inventory Configuration

Ensure your `inventory.ini` has the correct server details:

```bash
cat inventory.ini
```

Should show your webserver configuration.

### Step 2: Test Ansible Connection

```bash
ansible webservers -m ping
```

Expected output: `SUCCESS`

### Step 3: Deploy PHPMailer (Recommended - Incremental)

Deploy only the PHPMailer role first to test:

```bash
ansible-playbook site.yml --tags phpmailer -v
```

**What this does:**
- Installs Composer
- Installs PHPMailer via Composer
- Configures Azure SMTP settings
- Sets up SELinux permissions
- Configures firewall rules
- Creates log directory
- Deploys test scripts

**Expected Duration:** 2-5 minutes

### Step 4: Verify Deployment

After successful deployment, verify the installation:

```bash
# Check Composer
ansible webservers -m shell -a "composer --version"

# Check PHPMailer installation
ansible webservers -m shell -a "ls -la /var/www/phpmailer/vendor/phpmailer"

# Check configuration file
ansible webservers -m shell -a "ls -la /var/www/phpmailer/mailer_config.php"

# Check test scripts
ansible webservers -m shell -a "ls -la /var/www/html/test_email.php"

# Check SELinux booleans
ansible webservers -m shell -a "getsebool httpd_can_sendmail"
ansible webservers -m shell -a "getsebool httpd_can_network_connect"

# Check firewall rules
ansible webservers -m shell -a "firewall-cmd --list-ports"

# Check log directory
ansible webservers -m shell -a "ls -la /var/log/phpmailer"
```

### Step 5: Test Email Sending

#### Option A: Web Interface (Recommended)

1. Open your browser
2. Navigate to: `http://YOUR_SERVER_IP/test_email.php`
3. Enter a test email address
4. Click "Send Test Email"
5. Check your inbox (and spam folder)

#### Option B: Command Line

SSH into your server and run:

```bash
php -r '
require "/var/www/phpmailer/mailer_config.php";
$result = sendEmail(
    "your-email@example.com",
    "Test from CLI",
    "<h1>Test Email</h1><p>This is a test from command line.</p>",
    "Test Email - This is a test from command line."
);
echo $result ? "✅ Email sent successfully!\n" : "❌ Failed to send email.\n";
'
```

### Step 6: Check Logs

View the logs to verify email sending:

```bash
# SSH into server
ssh root@YOUR_SERVER_IP

# View today's logs
tail -f /var/log/phpmailer/phpmailer_$(date +%Y-%m-%d).log

# View sent emails log
tail -f /var/log/phpmailer/phpmailer_sent_$(date +%Y-%m-%d).log

# View error logs (if any)
tail -f /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log
```

## 🔧 Alternative Deployment Options

### Full LAMP Stack Deployment

If you want to deploy everything from scratch:

```bash
ansible-playbook site.yml
```

### Deploy with Check Mode (Dry Run)

Test what would happen without making changes:

```bash
ansible-playbook site.yml --tags phpmailer --check
```

### Deploy with Maximum Verbosity

For detailed debugging information:

```bash
ansible-playbook site.yml --tags phpmailer -vvv
```

## 📊 Expected Output

### Successful Deployment Output

```
PLAY [Deploy LAMP Stack with SELinux on RHEL/CentOS] **************************

TASK [Gathering Facts] *********************************************************
ok: [lamp-server]

TASK [phpmailer : Install required PHP extensions for PHPMailer] **************
ok: [lamp-server]

TASK [phpmailer : Check if Composer is installed] *****************************
ok: [lamp-server]

TASK [phpmailer : Download Composer installer] ********************************
changed: [lamp-server]

TASK [phpmailer : Install Composer] *******************************************
changed: [lamp-server]

TASK [phpmailer : Create PHPMailer directory] *********************************
changed: [lamp-server]

TASK [phpmailer : Install PHPMailer via Composer] *****************************
changed: [lamp-server]

TASK [phpmailer : Deploy PHPMailer configuration file] ************************
changed: [lamp-server]

TASK [phpmailer : Deploy email test script] **********************************
changed: [lamp-server]

TASK [phpmailer : Configure SELinux to allow PHP to send emails] *************
changed: [lamp-server]

TASK [phpmailer : Allow SMTP port through firewall (587)] ********************
changed: [lamp-server]

PLAY RECAP *********************************************************************
lamp-server                : ok=15   changed=10   unreachable=0    failed=0
```

## 🎯 Quick Test Checklist

After deployment, verify these items:

- [ ] Composer is installed: `composer --version`
- [ ] PHPMailer directory exists: `/var/www/phpmailer/`
- [ ] Configuration file exists: `/var/www/phpmailer/mailer_config.php`
- [ ] Test page accessible: `http://YOUR_SERVER_IP/test_email.php`
- [ ] Examples page accessible: `http://YOUR_SERVER_IP/send_email_example.php`
- [ ] SELinux booleans enabled: `httpd_can_sendmail` and `httpd_can_network_connect`
- [ ] Firewall ports open: `587/tcp` and `465/tcp`
- [ ] Log directory exists: `/var/log/phpmailer/`
- [ ] Test email sends successfully
- [ ] Test email received in inbox

## 🐛 Troubleshooting Quick Fixes

### Issue: Composer Installation Failed

```bash
# Manual installation
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

# Re-run playbook
ansible-playbook site.yml --tags phpmailer
```

### Issue: SELinux Blocking Email

```bash
# Enable SELinux booleans manually
ansible webservers -m shell -a "setsebool -P httpd_can_sendmail on"
ansible webservers -m shell -a "setsebool -P httpd_can_network_connect on"
```

### Issue: Permission Denied

```bash
# Fix permissions
ansible webservers -m shell -a "chown -R apache:apache /var/www/phpmailer"
ansible webservers -m shell -a "chmod 640 /var/www/phpmailer/mailer_config.php"
ansible webservers -m shell -a "chown -R apache:apache /var/log/phpmailer"
```

### Issue: Cannot Access Test Page

```bash
# Check Apache status
ansible webservers -m shell -a "systemctl status httpd"

# Restart Apache
ansible webservers -m shell -a "systemctl restart httpd"

# Check SELinux context
ansible webservers -m shell -a "ls -Z /var/www/html/test_email.php"
```

### Issue: Email Not Sending

1. **Enable Debug Mode**: Edit `group_vars/all.yml`:
   ```yaml
   mail_debug_level: 2
   ```
   
2. **Redeploy**:
   ```bash
   ansible-playbook site.yml --tags phpmailer
   ```

3. **Check Logs**:
   ```bash
   tail -50 /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log
   ```

4. **Test SMTP Connection**:
   ```bash
   telnet smtp.azurecomm.net 587
   ```

## 📚 Next Steps After Successful Deployment

1. **Test Email Functionality**: Send test emails to verify everything works
2. **Review Documentation**: Check `PHPMAILER_AZURE_SETUP.md` for detailed usage
3. **Implement in Your Application**: Use the helper functions in your PHP code
4. **Security Hardening**: Consider using Ansible Vault for credentials
5. **Remove Test Scripts**: Delete test scripts before going to production
6. **Set Up Monitoring**: Monitor logs for email delivery issues
7. **Configure Log Rotation**: Set up logrotate for PHPMailer logs

## 🔒 Production Readiness

Before going to production:

1. **Use Ansible Vault** for sensitive credentials
2. **Remove test scripts**: `test_email.php` and `send_email_example.php`
3. **Disable debug mode**: Set `mail_debug_level: 0`
4. **Set up log rotation**: Configure logrotate for `/var/log/phpmailer/`
5. **Implement rate limiting**: Add delays between bulk emails
6. **Monitor logs**: Set up alerts for email failures
7. **Backup configuration**: Keep a secure backup of your configuration

## 📞 Support Resources

- **Detailed Documentation**: `PHPMAILER_AZURE_SETUP.md`
- **Progress Tracker**: `TODO.md`
- **PHPMailer Docs**: https://github.com/PHPMailer/PHPMailer/wiki
- **Azure Email Services**: https://docs.microsoft.com/azure/communication-services/

## ✨ Summary

You now have a complete PHPMailer setup with Azure Communication Services integration! 

**Key Features:**
- ✅ Automated installation and configuration
- ✅ Azure SMTP integration
- ✅ SELinux compatible
- ✅ Firewall configured
- ✅ Comprehensive logging
- ✅ Helper functions for easy use
- ✅ Test interface included
- ✅ Full documentation

**Ready to deploy?** Run:
```bash
ansible-playbook site.yml --tags phpmailer -v
```

---

**Good luck with your deployment! 🚀**
