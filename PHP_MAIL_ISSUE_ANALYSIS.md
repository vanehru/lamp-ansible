# PHP Mail Issue Analysis & Resolution
**Date**: December 28, 2024  
**Issue**: SMTP Authentication Failure

---

## 🔴 Problem Identified

**Error Message**: `SMTP Error: Could not authenticate`

**Log Location**: `/var/log/phpmailer/phpmailer_errors_2025-12-28.log`

**Root Cause**: The Azure Communication Services SMTP credentials configured in the system are **invalid or expired**.

---

## 🔍 Current Configuration

### SMTP Settings in Use

```
SMTP Host: smtp.azurecomm.net
SMTP Port: 587
SMTP Username: smtp@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net
SMTP Password: a6fc9829-c543-4913-96ba-aca7dc6e65f0
Encryption: TLS
```

### What's Working ✅

1. **Network Connectivity**: Server can reach smtp.azurecomm.net:587
2. **PHPMailer Installation**: Library is properly installed and loaded
3. **SELinux Configuration**: Properly configured (httpd_can_sendmail: ON)
4. **Firewall Rules**: Ports 587 and 465 are open
5. **File Permissions**: Configuration file has correct permissions (0640)
6. **Test Interface**: Web interface is accessible

### What's NOT Working ❌

1. **SMTP Authentication**: Credentials are being rejected by Azure SMTP server

---

## 🔧 Resolution Steps

### Option 1: Update Azure Communication Services Credentials (RECOMMENDED)

The current credentials may be:
- Expired
- Revoked
- Invalid for the Azure Communication Services instance
- Not properly configured in Azure portal

**Steps to Fix:**

1. **Log into Azure Portal**
   - Navigate to your Azure Communication Services resource
   - Go to "Keys" or "Email" section

2. **Verify/Generate New SMTP Credentials**
   - Check if the current credentials are still valid
   - Generate new SMTP credentials if needed
   - Note down the new username and password

3. **Update Ansible Configuration**
   
   Edit: `/home/azureuser/Desktop/lamp-ansible/group_vars/all.yml`
   
   ```yaml
   # Azure Communication Services SMTP Settings
   azure_smtp_host: "smtp.azurecomm.net"
   azure_smtp_port: 587
   azure_smtp_username: "YOUR_NEW_SMTP_USERNAME"
   azure_smtp_password: "YOUR_NEW_SMTP_PASSWORD"
   azure_smtp_encryption: "tls"
   ```

4. **Redeploy Configuration**
   
   ```bash
   cd /home/azureuser/Desktop/lamp-ansible
   ansible-playbook site.yml --tags phpmailer
   ```

5. **Test Again**
   
   Visit: `http://YOUR_SERVER_IP/test_email.php`

---

### Option 2: Verify Azure Email Domain Configuration

Azure Communication Services requires proper email domain setup:

1. **Check Email Domain Status**
   - In Azure Portal, go to your Communication Services resource
   - Navigate to "Email" → "Domains"
   - Verify the domain is properly configured and verified

2. **Verify Sender Address**
   - The "From" address must match a verified domain
   - Current: `noreply@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net`
   - This should be a verified Azure Communication Services domain

3. **Check SMTP Authentication Method**
   - Azure Communication Services may require specific authentication
   - Verify you're using the correct SMTP endpoint and credentials

---

### Option 3: Use Alternative SMTP Provider (If Azure Issues Persist)

If Azure credentials cannot be resolved, consider using an alternative SMTP service:

**Popular Options:**
- SendGrid
- Mailgun
- Amazon SES
- Gmail SMTP (for testing only)

**To Switch Providers:**

Edit `group_vars/all.yml`:
```yaml
azure_smtp_host: "smtp.sendgrid.net"  # or your provider
azure_smtp_port: 587
azure_smtp_username: "apikey"  # provider-specific
azure_smtp_password: "your-api-key"
azure_smtp_encryption: "tls"
mail_from_address: "noreply@yourdomain.com"
```

Then redeploy:
```bash
ansible-playbook site.yml --tags phpmailer
```

---

## 🧪 Testing & Verification

### Step 1: Test SMTP Authentication Manually

Create a test script to verify credentials:

```bash
# SSH into the server
ssh user@lamp-server

# Create test script
cat > /tmp/test_smtp.php << 'EOF'
<?php
require '/var/www/phpmailer/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;

$mail = new PHPMailer(true);

try {
    $mail->SMTPDebug = SMTP::DEBUG_SERVER;
    $mail->isSMTP();
    $mail->Host = 'smtp.azurecomm.net';
    $mail->SMTPAuth = true;
    $mail->Username = 'smtp@44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net';
    $mail->Password = 'a6fc9829-c543-4913-96ba-aca7dc6e65f0';
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;
    
    // Just test connection, don't send
    $mail->smtpConnect();
    echo "\n\n✅ SMTP Authentication Successful!\n";
    
} catch (Exception $e) {
    echo "\n\n❌ SMTP Authentication Failed: {$mail->ErrorInfo}\n";
}
EOF

# Run test
php /tmp/test_smtp.php
```

### Step 2: Check Azure Portal

1. Log into Azure Portal
2. Navigate to your Communication Services resource
3. Check:
   - Resource status (Active/Suspended)
   - SMTP credentials validity
   - Email domain verification status
   - Any service alerts or issues

### Step 3: Verify Email Domain

```bash
# Check if the domain is properly configured
nslookup 44cb25b1-3f6f-4c4a-b4af-656b5bb20abf.azurecomm.net
```

---

## 📋 Checklist for Resolution

- [ ] Verify Azure Communication Services resource is active
- [ ] Check SMTP credentials in Azure Portal
- [ ] Confirm email domain is verified in Azure
- [ ] Generate new SMTP credentials if needed
- [ ] Update `group_vars/all.yml` with new credentials
- [ ] Redeploy configuration: `ansible-playbook site.yml --tags phpmailer`
- [ ] Test email sending via web interface
- [ ] Check logs: `/var/log/phpmailer/phpmailer_errors_*.log`
- [ ] Verify successful email in sent logs

---

## 🔐 Security Note

**IMPORTANT**: The current SMTP credentials are exposed in:
- Configuration files
- This documentation
- Potentially in version control

**Recommended Actions:**
1. Generate new credentials immediately
2. Use Ansible Vault to encrypt credentials
3. Never commit credentials to version control
4. Rotate credentials regularly

**To Encrypt Credentials:**

```bash
cd /home/azureuser/Desktop/lamp-ansible

# Create vault file
ansible-vault create group_vars/vault.yml

# Add to vault.yml:
vault_azure_smtp_username: "your-new-username"
vault_azure_smtp_password: "your-new-password"

# Update group_vars/all.yml:
azure_smtp_username: "{{ vault_azure_smtp_username }}"
azure_smtp_password: "{{ vault_azure_smtp_password }}"

# Deploy with vault:
ansible-playbook site.yml --tags phpmailer --ask-vault-pass
```

---

## 📞 Next Steps

1. **Immediate Action Required**: 
   - Obtain valid Azure Communication Services SMTP credentials
   - Update configuration with new credentials
   - Redeploy and test

2. **After Resolution**:
   - Document the working credentials (securely)
   - Set up credential rotation schedule
   - Implement monitoring for authentication failures

3. **Long-term Improvements**:
   - Use Ansible Vault for credential management
   - Set up automated testing
   - Implement email delivery monitoring
   - Configure alerts for authentication failures

---

## 🆘 Support Resources

- **Azure Communication Services Support**: https://docs.microsoft.com/azure/communication-services/
- **Azure Portal**: https://portal.azure.com
- **PHPMailer Troubleshooting**: https://github.com/PHPMailer/PHPMailer/wiki/Troubleshooting

---

## 📊 Summary

**Status**: ⚠️ SMTP Authentication Failure  
**Cause**: Invalid or expired Azure SMTP credentials  
**Impact**: Cannot send emails  
**Resolution**: Update credentials in Azure Portal and redeploy configuration  
**Priority**: HIGH - Requires immediate attention

**System Health (Other Components)**:
- ✅ PHPMailer: Installed and functional
- ✅ Network: SMTP server reachable
- ✅ Security: SELinux and firewall properly configured
- ✅ Permissions: File permissions correct
- ❌ Authentication: Credentials invalid

---

**Report Generated**: December 28, 2024  
**Next Review**: After credential update and redeployment
