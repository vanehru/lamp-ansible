#!/bin/bash

#############################################
# LAMP Stack Deployment Script
# Automated deployment helper for Ansible
#############################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║         LAMP Stack Ansible Deployment Script          ║"
    echo "║    Apache • MySQL/MariaDB • PHP • SELinux Enabled     ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_ansible() {
    print_info "Checking Ansible installation..."
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not installed!"
        echo ""
        echo "Install Ansible:"
        echo "  RHEL/CentOS: sudo yum install epel-release -y && sudo yum install ansible -y"
        echo "  Ubuntu/Debian: sudo apt update && sudo apt install ansible -y"
        exit 1
    fi
    ANSIBLE_VERSION=$(ansible --version | head -n1)
    print_success "Ansible found: $ANSIBLE_VERSION"
}

check_inventory() {
    print_info "Checking inventory configuration..."
    if [ ! -f "$SCRIPT_DIR/inventory.ini" ]; then
        print_error "inventory.ini not found!"
        exit 1
    fi
    
    if grep -q "YOUR_SERVER_IP" "$SCRIPT_DIR/inventory.ini"; then
        print_error "Please configure your server IP in inventory.ini"
        echo ""
        echo "Edit inventory.ini and replace YOUR_SERVER_IP with your actual server IP"
        exit 1
    fi
    print_success "Inventory configured"
}

test_connection() {
    print_info "Testing connection to target servers..."
    if ansible webservers -m ping > /dev/null 2>&1; then
        print_success "Connection successful"
    else
        print_error "Cannot connect to target servers"
        echo ""
        echo "Troubleshooting:"
        echo "  1. Check server IP in inventory.ini"
        echo "  2. Verify SSH access: ssh root@YOUR_SERVER_IP"
        echo "  3. Check SSH key configuration"
        exit 1
    fi
}

show_menu() {
    echo ""
    echo "Select deployment option:"
    echo ""
    echo "  1) Full LAMP Stack Deployment (Recommended)"
    echo "  2) Deploy with verbose output"
    echo "  3) Dry run (check mode - no changes)"
    echo "  4) Deploy specific components"
    echo "  5) Test connection only"
    echo "  6) Show deployment status"
    echo "  7) Exit"
    echo ""
    read -p "Enter your choice [1-7]: " choice
}

deploy_full() {
    print_info "Starting full LAMP stack deployment..."
    echo ""
    ansible-playbook "$SCRIPT_DIR/site.yml"
    
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Deployment completed successfully!"
        show_access_info
    else
        print_error "Deployment failed. Check the output above for errors."
        exit 1
    fi
}

deploy_verbose() {
    print_info "Starting deployment with verbose output..."
    echo ""
    ansible-playbook "$SCRIPT_DIR/site.yml" -v
    
    if [ $? -eq 0 ]; then
        echo ""
        print_success "Deployment completed successfully!"
        show_access_info
    else
        print_error "Deployment failed. Check the output above for errors."
        exit 1
    fi
}

deploy_check() {
    print_info "Running deployment in check mode (no changes will be made)..."
    echo ""
    ansible-playbook "$SCRIPT_DIR/site.yml" --check
    echo ""
    print_info "Check mode completed. No actual changes were made."
}

deploy_specific() {
    echo ""
    echo "Available components:"
    echo "  1) Common (system setup)"
    echo "  2) SELinux"
    echo "  3) Apache"
    echo "  4) MySQL/MariaDB"
    echo "  5) PHP"
    echo ""
    read -p "Enter component number: " comp_choice
    
    case $comp_choice in
        1) TAG="common" ;;
        2) TAG="selinux" ;;
        3) TAG="apache" ;;
        4) TAG="mysql" ;;
        5) TAG="php" ;;
        *) print_error "Invalid choice"; return ;;
    esac
    
    print_info "Deploying $TAG..."
    ansible-playbook "$SCRIPT_DIR/site.yml" --tags "$TAG"
}

show_status() {
    print_info "Checking deployment status..."
    echo ""
    
    echo "Service Status:"
    ansible webservers -m shell -a "systemctl status httpd mariadb --no-pager" 2>/dev/null || print_warning "Could not retrieve service status"
    
    echo ""
    echo "SELinux Status:"
    ansible webservers -m shell -a "sestatus" 2>/dev/null || print_warning "Could not retrieve SELinux status"
    
    echo ""
    echo "Firewall Rules:"
    ansible webservers -m shell -a "firewall-cmd --list-services" 2>/dev/null || print_warning "Could not retrieve firewall rules"
}

show_access_info() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Deployment Successful! 🎉                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get server IP from inventory
    SERVER_IP=$(grep "ansible_host=" "$SCRIPT_DIR/inventory.ini" | head -n1 | sed 's/.*ansible_host=\([^ ]*\).*/\1/')
    
    echo "Access your LAMP stack:"
    echo ""
    echo -e "  ${BLUE}Home Page:${NC}      http://$SERVER_IP/"
    echo -e "  ${BLUE}PHP Info:${NC}       http://$SERVER_IP/info.php"
    echo -e "  ${BLUE}Database Test:${NC}  http://$SERVER_IP/db_test.php"
    echo ""
    echo -e "${YELLOW}Security Reminder:${NC}"
    echo "  • Remove test pages (info.php, db_test.php) in production"
    echo "  • Change default passwords in group_vars/all.yml"
    echo "  • Enable HTTPS for production use"
    echo ""
}

# Main script
main() {
    cd "$SCRIPT_DIR"
    
    print_header
    
    # Pre-flight checks
    check_ansible
    check_inventory
    
    # Show menu
    while true; do
        show_menu
        
        case $choice in
            1)
                test_connection
                deploy_full
                break
                ;;
            2)
                test_connection
                deploy_verbose
                break
                ;;
            3)
                test_connection
                deploy_check
                ;;
            4)
                test_connection
                deploy_specific
                ;;
            5)
                test_connection
                print_success "Connection test passed!"
                ;;
            6)
                show_status
                ;;
            7)
                print_info "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please select 1-7."
                ;;
        esac
    done
}

# Run main function
main
