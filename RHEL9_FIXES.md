# RHEL 9.4 Compatibility Fixes

## Changes Made

This document summarizes the changes made to make the LAMP stack Ansible playbook compatible with RHEL 9.4.

### Date: 2025-12-27

## Issues Fixed

1. **Package Manager Update**: Changed from `yum` to `dnf` (native package manager for RHEL 9)
2. **EPEL Repository**: Fixed EPEL installation for RHEL 9 (requires direct RPM URL instead of package name)

## Files Modified

### 1. roles/common/tasks/main.yml
- Changed `yum` to `dnf` for all package operations
- Added conditional EPEL installation based on distribution version:
  - RHEL 9: Install from Fedora Project URL
  - RHEL 8: Use epel-release package
  - CentOS: Use epel-release package
- Removed `epel-release` from common packages list

### 2. roles/apache/tasks/main.yml
- Changed `yum` to `dnf` for Apache package installation

### 3. roles/mysql/tasks/main.yml
- Changed `yum` to `dnf` for MariaDB package installation

### 4. roles/php/tasks/main.yml
- Changed `yum` to `dnf` for PHP package installation

### 5. roles/selinux/tasks/main.yml
- Changed `yum` to `dnf` for SELinux package installation

## Technical Details

### EPEL Installation for RHEL 9
```yaml
- name: Install EPEL repository for RHEL 9
  dnf:
    name: "https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm"
    state: present
    disable_gpg_check: yes
  when: ansible_distribution == "RedHat" and ansible_distribution_major_version == "9"
```

### Package Manager Change
- Old: `yum` module
- New: `dnf` module
- Reason: DNF is the default package manager for RHEL 8+ and provides better dependency resolution

## Compatibility

The updated playbook now supports:
- ✅ RHEL 9.x (including 9.4)
- ✅ RHEL 8.x
- ✅ CentOS 7/8/9
- ✅ Rocky Linux 8/9
- ✅ AlmaLinux 8/9

## Next Steps

After these fixes, the playbook can be executed successfully with:
```bash
./deploy.sh
```

Or directly:
```bash
ansible-playbook site.yml
```

## Verification

After deployment, verify the installation:
1. Check services: `systemctl status httpd mariadb`
2. Access web server: `http://SERVER_IP/`
3. Test PHP: `http://SERVER_IP/info.php`
4. Test database: `http://SERVER_IP/db_test.php`
5. Verify SELinux: `sestatus`
