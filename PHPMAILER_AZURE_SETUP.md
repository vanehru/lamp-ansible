# PHPMailer with Azure Communication Services Setup Guide

This document provides comprehensive information about the PHPMailer integration with Azure Communication Services in this LAMP stack deployment.

## 📋 Table of Contents

- [Overview](#overview)
- [What's Included](#whats-included)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Testing](#testing)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)

## 🎯 Overview

This Ansible playbook now includes a complete PHPMailer setup configured to work with Azure Communication Services SMTP relay. This allows your PHP applications to send emails reliably through Azure's infrastructure.

### Key Features

- ✅ Automated PHPMailer installation via Composer
- ✅ Pre-configured Azure Communication Services SMTP settings
- ✅ SELinux properly configured for email sending
- ✅ Firewall rules for SMTP ports
- ✅ Helper functions for easy email sending
- ✅ Comprehensive logging system
- ✅ Test scripts and usage examples
- ✅ HTML and plain text email support
- ✅ Attachment support

## 📦 What's Included

### New Role: `phpmailer`

Located in `roles/phpmailer/`, this role handles:

1. **Composer Installation**: Installs PHP Composer package manager
2. **PHPMailer Library**: Installs PHPMailer 6.9+ via Composer
3. **Configuration**: Sets up Azure SMTP credentials and settings
4. **SELinux Configuration**: Enables `httpd_can_sendmail` and `httpd_can_network_connect`
5. **Firewall Rules**: Opens ports 587 (STARTTLS) and 465 (SSL)
6. **Logging**: Creates log directory with proper permissions
7. **Test Scripts**: Deploys test and example scripts

### Files Created

```
/var/www/phpmailer/
├── composer.json
├── composer.lock
├── vendor/
│   └── phpmailer/
└── mailer_config.php          # Main configuration file

/var/www/html/
├── test_email.php             # Interactive email testing page
└── send_email_example.php     # Usage examples and documentation

/var/log/phpmailer/
├── phpmailer_YYYY-MM-DD.log   # General logs
├── phpmailer_sent_YYYY-MM-DD.log    # Sent emails log
└── phpmailer_errors_YYYY-MM-DD.log  # Error logs
```

## ⚙️ Configuration

### Azure Communication Services Settings

The configuration is stored in `group_vars/all.yml`:

```yaml
# PHPMailer and Azure Email Services Configuration
phpmailer_install_dir: "/var/www/phpmailer"

# Azure Communication Services SMTP Settings
azure_smtp_host: "smtp.azurecomm.net"
azure_smtp_port: 587
azure_smtp_username: "smtp@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net"
azure_smtp_password: "a6fc9829-c543-4913-96ba-aca7dc6e65f0"
azure_smtp_encryption: "tls"

# Email Sender Configuration
mail_from_address: "noreply@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net"
mail_from_name: "smtp-poc-test"

# Email Testing
test_email_recipient: "admin@localhost"

# Email Logging Configuration
mail_log_enabled: true
mail_log_path: "/var/log/phpmailer"
mail_debug_level: 0
```

### Azure Credentials Reference

Your Azure Communication Services details:

- **Display Name**: smtp-poc-test
- **Application (client) ID**: 95953542-3599-44db-9801-866ac6ffb9f2
- **Object ID**: a0ac8ae4-9dc3-4ce9-989c-c6bfd489a21e
- **Directory (tenant) ID**: bdf92631-f7b8-4cb3-ac38-a62ffea8d728

## 🚀 Deployment

### Full Deployment

Deploy the entire LAMP stack including PHPMailer:

```bash
ansible-playbook site.yml
```

### Deploy Only PHPMailer

If you already have the LAMP stack running:

```bash
ansible-playbook site.yml --tags phpmailer
```

### Deploy with Verbose Output

```bash
ansible-playbook site.yml --tags phpmailer -v
```

### Verify Installation

After deployment, check the installation:

```bash
ansible webservers -m shell -a "composer --version"
ansible webservers -m shell -a "ls -la /var/www/phpmailer"
ansible webservers -m shell -a "php -r 'require \"/var/www/phpmailer/vendor/autoload.php\"; echo \"PHPMailer loaded successfully\n\";'"
```

## 🧪 Testing

### 1. Access the Test Page

Open your browser and navigate to:

```
http://YOUR_SERVER_IP/test_email.php
```

This interactive page allows you to:
- View current configuration
- Send test emails to any address
- See immediate results
- Check for errors

### 2. Command Line Testing

SSH into your server and run:

```bash
php -r '
require "/var/www/phpmailer/mailer_config.php";
$result = sendEmail(
    "your-email@example.com",
    "Test from CLI",
    "<h1>Test Email</h1><p>This is a test.</p>",
    "Test Email - This is a test."
);
echo $result ? "Success!\n" : "Failed!\n";
'
```

### 3. Check Logs

View the logs to troubleshoot issues:

```bash
# View general logs
tail -f /var/log/phpmailer/phpmailer_$(date +%Y-%m-%d).log

# View sent emails log
tail -f /var/log/phpmailer/phpmailer_sent_$(date +%Y-%m-%d).log

# View error logs
tail -f /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log
```

### 4. Verify SELinux Settings

```bash
getsebool httpd_can_sendmail
getsebool httpd_can_network_connect
```

Both should return `on`.

### 5. Check Firewall Rules

```bash
firewall-cmd --list-ports
```

Should show `587/tcp` and `465/tcp`.

## 💻 Usage Examples

### Example 1: Simple Email

```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';

$to = 'recipient@example.com';
$subject = 'Hello from PHPMailer';
$body = '<h1>Hello!</h1><p>This is a test email.</p>';
$altBody = 'Hello! This is a test email.';

if (sendEmail($to, $subject, $body, $altBody)) {
    echo "Email sent successfully!";
} else {
    echo "Failed to send email.";
}
?>
```

### Example 2: HTML Email with Styling

```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';

$to = 'user@example.com';
$subject = 'Welcome to Our Service!';

$body = '
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #667eea; color: white; padding: 20px; }
        .button { 
            display: inline-block; 
            padding: 12px 30px; 
            background: #667eea; 
            color: white; 
            text-decoration: none; 
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome!</h1>
        </div>
        <p>Thank you for joining us.</p>
        <a href="https://example.com" class="button">Get Started</a>
    </div>
</body>
</html>';

$altBody = 'Welcome! Thank you for joining us. Visit https://example.com to get started.';

sendEmail($to, $subject, $body, $altBody);
?>
```

### Example 3: Email with Attachments

```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';

$to = 'recipient@example.com';
$subject = 'Invoice for Your Order';
$body = '<h2>Invoice Attached</h2><p>Please find your invoice attached.</p>';

$attachments = [
    '/path/to/invoice.pdf',
    '/path/to/receipt.pdf'
];

if (sendEmailWithAttachments($to, $subject, $body, $attachments)) {
    echo "Email with attachments sent!";
}
?>
```

### Example 4: Advanced Usage

```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';

try {
    $mail = getMailer();
    
    // Recipients
    $mail->addAddress('recipient@example.com', 'John Doe');
    $mail->addCC('cc@example.com');
    $mail->addBCC('bcc@example.com');
    
    // Reply-To
    $mail->addReplyTo('noreply@example.com', 'No Reply');
    
    // Content
    $mail->Subject = 'Advanced Email Example';
    $mail->Body    = '<h1>HTML Body</h1>';
    $mail->AltBody = 'Plain text version';
    
    // Attachments
    $mail->addAttachment('/path/to/file.pdf');
    
    $mail->send();
    echo "Email sent!";
    
} catch (Exception $e) {
    echo "Error: " . $mail->ErrorInfo;
}
?>
```

For more examples, visit: `http://YOUR_SERVER_IP/send_email_example.php`

## 🔧 Troubleshooting

### Issue: Email Not Sending

**Check 1: Verify SMTP Credentials**
```bash
cat /var/www/phpmailer/mailer_config.php | grep AZURE_SMTP
```

**Check 2: Test SMTP Connection**
```bash
telnet smtp.azurecomm.net 587
```

**Check 3: Review Logs**
```bash
tail -50 /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log
```

**Check 4: SELinux Status**
```bash
getsebool httpd_can_sendmail
getsebool httpd_can_network_connect
```

If `off`, enable them:
```bash
sudo setsebool -P httpd_can_sendmail on
sudo setsebool -P httpd_can_network_connect on
```

### Issue: Permission Denied

**Fix File Permissions**
```bash
sudo chown -R apache:apache /var/www/phpmailer
sudo chmod 640 /var/www/phpmailer/mailer_config.php
sudo chown -R apache:apache /var/log/phpmailer
sudo chmod 755 /var/log/phpmailer
```

### Issue: Composer Not Found

**Reinstall Composer**
```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
```

### Issue: PHPMailer Class Not Found

**Reinstall PHPMailer**
```bash
cd /var/www/phpmailer
sudo -u apache composer install
```

### Issue: Firewall Blocking SMTP

**Check and Add Rules**
```bash
sudo firewall-cmd --list-ports
sudo firewall-cmd --permanent --add-port=587/tcp
sudo firewall-cmd --permanent --add-port=465/tcp
sudo firewall-cmd --reload
```

### Enable Debug Mode

To see detailed SMTP communication, edit `/var/www/phpmailer/mailer_config.php`:

```php
define('MAIL_DEBUG_LEVEL', 2); // Change from 0 to 2
```

Or update `group_vars/all.yml`:
```yaml
mail_debug_level: 2
```

Then redeploy:
```bash
ansible-playbook site.yml --tags phpmailer
```

## 🔒 Security Best Practices

### 1. Use Ansible Vault for Credentials

**Encrypt sensitive variables:**

```bash
# Create encrypted vault file
ansible-vault create group_vars/vault.yml
```

Add to `vault.yml`:
```yaml
vault_azure_smtp_username: "smtp@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net"
vault_azure_smtp_password: "a6fc9829-c543-4913-96ba-aca7dc6e65f0"
```

Update `group_vars/all.yml`:
```yaml
azure_smtp_username: "{{ vault_azure_smtp_username }}"
azure_smtp_password: "{{ vault_azure_smtp_password }}"
```

**Run playbook with vault:**
```bash
ansible-playbook site.yml --ask-vault-pass
```

### 2. Remove Test Scripts in Production

```bash
ansible webservers -m file -a "path=/var/www/html/test_email.php state=absent"
ansible webservers -m file -a "path=/var/www/html/send_email_example.php state=absent"
```

Or add to your playbook:
```yaml
- name: Remove test scripts in production
  file:
    path: "{{ item }}"
    state: absent
  loop:
    - "{{ apache_document_root }}/test_email.php"
    - "{{ apache_document_root }}/send_email_example.php"
  when: environment == "production"
```

### 3. Restrict File Permissions

```bash
sudo chmod 640 /var/www/phpmailer/mailer_config.php
sudo chown apache:apache /var/www/phpmailer/mailer_config.php
```

### 4. Implement Rate Limiting

Add delays between bulk emails to avoid rate limiting:

```php
foreach ($recipients as $recipient) {
    sendEmail($recipient, $subject, $body);
    sleep(1); // 1 second delay
}
```

### 5. Validate Email Addresses

Always validate email addresses before sending:

```php
$email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
if ($email) {
    sendEmail($email, $subject, $body);
}
```

### 6. Disable Debug Mode in Production

Set in `group_vars/all.yml`:
```yaml
mail_debug_level: 0  # Disable debug output
```

### 7. Monitor Logs Regularly

Set up log rotation:

```bash
sudo cat > /etc/logrotate.d/phpmailer << EOF
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

## 📊 Configuration Reference

### Available Helper Functions

| Function | Description |
|----------|-------------|
| `getMailer()` | Returns configured PHPMailer instance |
| `sendEmail($to, $subject, $body, $altBody)` | Send simple email |
| `sendEmailWithAttachments($to, $subject, $body, $attachments, $altBody)` | Send email with attachments |

### Configuration Constants

| Constant | Description |
|----------|-------------|
| `AZURE_SMTP_HOST` | SMTP server hostname |
| `AZURE_SMTP_PORT` | SMTP port (587 or 465) |
| `AZURE_SMTP_USERNAME` | SMTP username |
| `AZURE_SMTP_PASSWORD` | SMTP password |
| `AZURE_SMTP_ENCRYPTION` | Encryption type (tls/ssl) |
| `MAIL_FROM_ADDRESS` | Default sender email |
| `MAIL_FROM_NAME` | Default sender name |
| `MAIL_LOG_PATH` | Log directory path |
| `MAIL_DEBUG_LEVEL` | Debug verbosity (0-4) |

## 📚 Additional Resources

- [PHPMailer GitHub](https://github.com/PHPMailer/PHPMailer)
- [PHPMailer Documentation](https://github.com/PHPMailer/PHPMailer/wiki)
- [Azure Communication Services Documentation](https://docs.microsoft.com/azure/communication-services/)
- [Azure Email Communication Services](https://docs.microsoft.com/azure/communication-services/concepts/email/email-overview)

## 🆘 Support

If you encounter issues:

1. Check the logs at `/var/log/phpmailer/`
2. Verify SELinux settings: `getsebool httpd_can_sendmail`
3. Test SMTP connectivity: `telnet smtp.azurecomm.net 587`
4. Review firewall rules: `firewall-cmd --list-ports`
5. Enable debug mode and check output

---

**Last Updated**: December 2024  
**Version**: 1.0  
**Ansible Role**: phpmailer
