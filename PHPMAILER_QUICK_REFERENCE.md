# PHPMailer Quick Reference Card

## 🚀 Quick Start

### Include PHPMailer
```php
<?php
require_once '/var/www/phpmailer/mailer_config.php';
?>
```

## 📧 Send Simple Email

```php
sendEmail(
    'recipient@example.com',           // To
    'Email Subject',                   // Subject
    '<h1>HTML Body</h1>',             // HTML Body
    'Plain text body'                  // Plain Text (optional)
);
```

## 📎 Send Email with Attachments

```php
sendEmailWithAttachments(
    'recipient@example.com',           // To
    'Email with Files',                // Subject
    '<h1>See attached</h1>',          // HTML Body
    ['/path/to/file1.pdf', '/path/to/file2.jpg'],  // Attachments
    'Plain text body'                  // Plain Text (optional)
);
```

## 🎨 Send HTML Email

```php
$htmlBody = '
<html>
<head>
    <style>
        .container { max-width: 600px; margin: 0 auto; }
        .header { background: #667eea; color: white; padding: 20px; }
        .button { background: #667eea; color: white; padding: 10px 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header"><h1>Welcome!</h1></div>
        <p>Thank you for joining us.</p>
        <a href="https://example.com" class="button">Get Started</a>
    </div>
</body>
</html>';

sendEmail('user@example.com', 'Welcome!', $htmlBody, 'Welcome! Thank you for joining us.');
```

## 🔧 Advanced Usage

```php
$mail = getMailer();

// Recipients
$mail->addAddress('recipient@example.com', 'John Doe');
$mail->addCC('cc@example.com');
$mail->addBCC('bcc@example.com');
$mail->addReplyTo('reply@example.com');

// Content
$mail->Subject = 'Subject Line';
$mail->Body = '<h1>HTML Body</h1>';
$mail->AltBody = 'Plain text body';

// Attachments
$mail->addAttachment('/path/to/file.pdf');
$mail->addAttachment('/path/to/image.jpg', 'custom-name.jpg');

// Embedded images
$mail->addEmbeddedImage('/path/to/logo.png', 'logo_cid');
$mail->Body = '<img src="cid:logo_cid">';

// Send
if ($mail->send()) {
    echo "Email sent!";
} else {
    echo "Error: " . $mail->ErrorInfo;
}
```

## 🔄 Multiple Recipients

```php
$recipients = ['user1@example.com', 'user2@example.com', 'user3@example.com'];

foreach ($recipients as $recipient) {
    sendEmail($recipient, 'Newsletter', '<h1>Monthly Update</h1>', 'Monthly Update');
    sleep(1); // Avoid rate limiting
}
```

## ⚠️ Error Handling

```php
try {
    $mail = getMailer();
    $mail->addAddress('recipient@example.com');
    $mail->Subject = 'Test';
    $mail->Body = 'Test message';
    
    if (!$mail->send()) {
        error_log("Email Error: " . $mail->ErrorInfo);
        echo "Failed to send email.";
    } else {
        echo "Email sent successfully!";
    }
} catch (Exception $e) {
    error_log("Email Exception: " . $e->getMessage());
    echo "An error occurred.";
}
```

## 📋 Configuration Constants

| Constant | Description |
|----------|-------------|
| `AZURE_SMTP_HOST` | SMTP server hostname |
| `AZURE_SMTP_PORT` | SMTP port (587 or 465) |
| `AZURE_SMTP_USERNAME` | SMTP username |
| `AZURE_SMTP_PASSWORD` | SMTP password |
| `AZURE_SMTP_ENCRYPTION` | Encryption (tls/ssl) |
| `MAIL_FROM_ADDRESS` | Default sender email |
| `MAIL_FROM_NAME` | Default sender name |
| `MAIL_LOG_PATH` | Log directory |
| `MAIL_DEBUG_LEVEL` | Debug level (0-4) |

## 🛠️ Helper Functions

### getMailer()
Returns a configured PHPMailer instance.

```php
$mail = getMailer();
// Configure and send...
```

### sendEmail($to, $subject, $body, $altBody = '')
Send a simple email.

**Parameters:**
- `$to` (string): Recipient email
- `$subject` (string): Email subject
- `$body` (string): HTML body
- `$altBody` (string): Plain text body (optional)

**Returns:** `bool` - Success status

### sendEmailWithAttachments($to, $subject, $body, $attachments = [], $altBody = '')
Send email with attachments.

**Parameters:**
- `$to` (string): Recipient email
- `$subject` (string): Email subject
- `$body` (string): HTML body
- `$attachments` (array): File paths to attach
- `$altBody` (string): Plain text body (optional)

**Returns:** `bool` - Success status

## 📝 Best Practices

### ✅ DO
- Always provide plain text alternative (`AltBody`)
- Validate email addresses before sending
- Add delays between bulk emails (`sleep(1)`)
- Use try-catch for error handling
- Log errors for debugging
- Test in development first

### ❌ DON'T
- Don't send without validating email addresses
- Don't send bulk emails without delays
- Don't ignore error handling
- Don't expose credentials in code
- Don't test in production
- Don't forget to remove test scripts

## 🔍 Debugging

### Enable Debug Mode
Edit `/var/www/phpmailer/mailer_config.php`:
```php
define('MAIL_DEBUG_LEVEL', 2); // 0=off, 2=server messages
```

### Check Logs
```bash
tail -f /var/log/phpmailer/phpmailer_$(date +%Y-%m-%d).log
tail -f /var/log/phpmailer/phpmailer_errors_$(date +%Y-%m-%d).log
```

### Test SMTP Connection
```bash
telnet smtp.azurecomm.net 587
```

## 🔒 Security Tips

1. **Validate Input**
   ```php
   $email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
   if ($email) {
       sendEmail($email, $subject, $body);
   }
   ```

2. **Sanitize Content**
   ```php
   $subject = htmlspecialchars($_POST['subject']);
   $name = htmlspecialchars($_POST['name']);
   ```

3. **Rate Limiting**
   ```php
   foreach ($recipients as $recipient) {
       sendEmail($recipient, $subject, $body);
       sleep(1); // 1 second delay
   }
   ```

## 📊 Common Use Cases

### Contact Form
```php
$name = htmlspecialchars($_POST['name']);
$email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
$message = htmlspecialchars($_POST['message']);

$body = "<h2>New Contact Form Submission</h2>
         <p><strong>Name:</strong> $name</p>
         <p><strong>Email:</strong> $email</p>
         <p><strong>Message:</strong> $message</p>";

sendEmail('admin@example.com', 'Contact Form: ' . $name, $body);
```

### Order Confirmation
```php
$orderNumber = $_POST['order_number'];
$customerEmail = $_POST['customer_email'];

$body = "<h1>Order Confirmation</h1>
         <p>Thank you for your order!</p>
         <p><strong>Order Number:</strong> $orderNumber</p>
         <p>We'll send you updates as your order is processed.</p>";

sendEmail($customerEmail, 'Order Confirmation #' . $orderNumber, $body);
```

### Password Reset
```php
$resetToken = bin2hex(random_bytes(32));
$resetLink = "https://example.com/reset?token=$resetToken";

$body = "<h1>Password Reset Request</h1>
         <p>Click the link below to reset your password:</p>
         <p><a href='$resetLink'>Reset Password</a></p>
         <p>This link expires in 1 hour.</p>";

sendEmail($userEmail, 'Password Reset Request', $body);
```

### Newsletter
```php
$subscribers = getSubscribers(); // Your function to get subscribers

foreach ($subscribers as $subscriber) {
    $body = "<h1>Monthly Newsletter</h1>
             <p>Hi {$subscriber['name']},</p>
             <p>Here's what's new this month...</p>";
    
    sendEmail($subscriber['email'], 'Newsletter - December 2024', $body);
    sleep(1); // Rate limiting
}
```

## 🌐 Testing URLs

- **Test Interface**: `http://YOUR_SERVER_IP/test_email.php`
- **Examples**: `http://YOUR_SERVER_IP/send_email_example.php`
- **PHP Info**: `http://YOUR_SERVER_IP/info.php`

## 📚 More Information

- **Full Documentation**: `PHPMAILER_AZURE_SETUP.md`
- **Deployment Guide**: `DEPLOY_PHPMAILER.md`
- **Implementation Summary**: `PHPMAILER_IMPLEMENTATION_SUMMARY.md`

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Email not sending | Check logs: `/var/log/phpmailer/phpmailer_errors_*.log` |
| Permission denied | `chown -R apache:apache /var/www/phpmailer` |
| SELinux blocking | `setsebool -P httpd_can_sendmail on` |
| Cannot access test page | `systemctl restart httpd` |
| SMTP connection failed | `telnet smtp.azurecomm.net 587` |

---

**Quick Deploy**: `ansible-playbook site.yml --tags phpmailer`  
**Configuration**: `/var/www/phpmailer/mailer_config.php`  
**Logs**: `/var/log/phpmailer/`
