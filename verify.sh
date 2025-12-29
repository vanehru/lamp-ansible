#!/bin/bash

#############################################
# LAMP Stack Verification Script
# Verifies the deployment and configuration
#############################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║         LAMP Stack Verification Script                ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_section() {
    echo ""
    echo -e "${YELLOW}═══ $1 ═══${NC}"
}

verify_connection() {
    print_section "Connection Test"
    if ansible webservers -m ping > /dev/null 2>&1; then
        print_success "Can connect to target servers"
        return 0
    else
        print_error "Cannot connect to target servers"
        return 1
    fi
}

verify_services() {
    print_section "Service Status"
    
    # Check Apache
    if ansible webservers -m shell -a "systemctl is-active httpd" 2>/dev/null | grep -q "active"; then
        print_success "Apache (httpd) is running"
    else
        print_error "Apache (httpd) is not running"
    fi
    
    # Check MariaDB
    if ansible webservers -m shell -a "systemctl is-active mariadb" 2>/dev/null | grep -q "active"; then
        print_success "MariaDB is running"
    else
        print_error "MariaDB is not running"
    fi
    
    # Check if services are enabled
    if ansible webservers -m shell -a "systemctl is-enabled httpd mariadb" 2>/dev/null | grep -q "enabled"; then
        print_success "Services are enabled at boot"
    else
        print_error "Services may not be enabled at boot"
    fi
}

verify_selinux() {
    print_section "SELinux Status"
    
    SELINUX_STATUS=$(ansible webservers -m shell -a "getenforce" 2>/dev/null | grep -v "webservers" | tail -n1)
    
    if [[ "$SELINUX_STATUS" == *"Enforcing"* ]]; then
        print_success "SELinux is in Enforcing mode"
    elif [[ "$SELINUX_STATUS" == *"Permissive"* ]]; then
        print_info "SELinux is in Permissive mode"
    else
        print_error "SELinux status unclear: $SELINUX_STATUS"
    fi
    
    # Check SELinux booleans
    if ansible webservers -m shell -a "getsebool httpd_can_network_connect" 2>/dev/null | grep -q "on"; then
        print_success "SELinux boolean httpd_can_network_connect is enabled"
    else
        print_error "SELinux boolean httpd_can_network_connect is not enabled"
    fi
}

verify_firewall() {
    print_section "Firewall Configuration"
    
    # Check if firewalld is running
    if ansible webservers -m shell -a "systemctl is-active firewalld" 2>/dev/null | grep -q "active"; then
        print_success "Firewalld is running"
        
        # Check HTTP service
        if ansible webservers -m shell -a "firewall-cmd --list-services" 2>/dev/null | grep -q "http"; then
            print_success "HTTP service is allowed in firewall"
        else
            print_error "HTTP service is not allowed in firewall"
        fi
        
        # Check HTTPS service
        if ansible webservers -m shell -a "firewall-cmd --list-services" 2>/dev/null | grep -q "https"; then
            print_success "HTTPS service is allowed in firewall"
        else
            print_info "HTTPS service is not configured (optional)"
        fi
    else
        print_info "Firewalld is not running (may be disabled)"
    fi
}

verify_php() {
    print_section "PHP Configuration"
    
    # Check PHP version
    PHP_VERSION=$(ansible webservers -m shell -a "php -v" 2>/dev/null | grep "PHP" | head -n1)
    if [ ! -z "$PHP_VERSION" ]; then
        print_success "PHP installed: $PHP_VERSION"
    else
        print_error "PHP not found or not working"
    fi
    
    # Check PHP modules
    MODULE_COUNT=$(ansible webservers -m shell -a "php -m | wc -l" 2>/dev/null | grep -v "webservers" | tail -n1)
    if [ ! -z "$MODULE_COUNT" ] && [ "$MODULE_COUNT" -gt 20 ]; then
        print_success "PHP modules loaded: $MODULE_COUNT modules"
    else
        print_error "PHP modules may not be properly loaded"
    fi
}

verify_mysql() {
    print_section "MySQL/MariaDB Configuration"
    
    # Check MySQL version
    MYSQL_VERSION=$(ansible webservers -m shell -a "mysql --version" 2>/dev/null | grep -v "webservers" | tail -n1)
    if [ ! -z "$MYSQL_VERSION" ]; then
        print_success "MySQL/MariaDB installed: $MYSQL_VERSION"
    else
        print_error "MySQL/MariaDB client not found"
    fi
    
    # Check if we can connect (requires .my.cnf to be set up)
    if ansible webservers -m shell -a "mysql -e 'SELECT VERSION();'" 2>/dev/null | grep -q "VERSION"; then
        print_success "MySQL/MariaDB is accessible"
    else
        print_info "MySQL/MariaDB connection test skipped (credentials needed)"
    fi
}

verify_web_access() {
    print_section "Web Access Test"
    
    # Get server IP
    SERVER_IP=$(grep "ansible_host=" "$SCRIPT_DIR/inventory.ini" | head -n1 | sed 's/.*ansible_host=\([^ ]*\).*/\1/')
    
    if [ -z "$SERVER_IP" ]; then
        print_error "Could not determine server IP from inventory"
        return 1
    fi
    
    print_info "Testing web access to http://$SERVER_IP/"
    
    # Test HTTP access
    if curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP/" 2>/dev/null | grep -q "200"; then
        print_success "Web server is accessible (HTTP 200 OK)"
    else
        print_error "Web server is not accessible or returning error"
    fi
    
    # Test PHP info page
    if curl -s "http://$SERVER_IP/info.php" 2>/dev/null | grep -q "PHP Version"; then
        print_success "PHP is working (info.php accessible)"
    else
        print_info "PHP info page not accessible (may have been removed)"
    fi
}

show_summary() {
    print_section "Deployment Summary"
    
    # Get server IP
    SERVER_IP=$(grep "ansible_host=" "$SCRIPT_DIR/inventory.ini" | head -n1 | sed 's/.*ansible_host=\([^ ]*\).*/\1/')
    
    echo ""
    echo "Access URLs:"
    echo -e "  ${BLUE}Home Page:${NC}      http://$SERVER_IP/"
    echo -e "  ${BLUE}PHP Info:${NC}       http://$SERVER_IP/info.php"
    echo -e "  ${BLUE}Database Test:${NC}  http://$SERVER_IP/db_test.php"
    echo ""
    echo "Next Steps:"
    echo "  1. Access the URLs above to verify functionality"
    echo "  2. Remove test pages in production (info.php, db_test.php)"
    echo "  3. Deploy your application files"
    echo "  4. Configure SSL/TLS for HTTPS"
    echo ""
}

# Main script
main() {
    cd "$SCRIPT_DIR"
    
    print_header
    
    # Run all verification checks
    verify_connection || exit 1
    verify_services
    verify_selinux
    verify_firewall
    verify_php
    verify_mysql
    verify_web_access
    show_summary
    
    echo ""
    print_success "Verification complete!"
    echo ""
}

# Run main function
main
