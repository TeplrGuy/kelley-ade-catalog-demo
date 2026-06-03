#!/bin/bash

#
# setup-demo.sh
# Setup script for Azure Deployment Environments catalog demo
#
# Usage:
#   ./setup-demo.sh [options]
#
# Options:
#   --subscription-id STRING     Azure subscription ID (required)
#   --resource-group STRING      Resource group name (required)
#   --location STRING            Azure region (required)
#   --dev-center STRING          Dev Center name (required)
#   --project STRING             Project name (required)
#   --catalog-name STRING        Catalog name (default: platform-catalog)
#   --catalog-url STRING         Catalog repository URL (required)
#   --catalog-branch STRING      Git branch (default: main)
#   --catalog-path STRING        Path in repo to catalog folder (default: catalog)
#   --github-token STRING        GitHub Personal Access Token (if GitHub repo)
#   --skip-role STRING           Skip RBAC role assignment (default: false)
#   --what-if                    Show what would happen without making changes
#   --help                       Show this help message
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_VERSION="1.0"
SCRIPT_START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Default values
CATALOG_NAME="platform-catalog"
CATALOG_BRANCH="main"
CATALOG_PATH="catalog"
GITHUB_TOKEN=""
SKIP_ROLE_ASSIGNMENT=false
WHAT_IF=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}=====================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}=====================================================================${NC}"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC}   $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_help() {
    cat << EOF
Usage: $0 [options]

Setup script for Azure Deployment Environments catalog demo.

Options:
  --subscription-id STRING      Azure subscription ID (required)
  --resource-group STRING       Resource group name (required)
  --location STRING             Azure region (required)
  --dev-center STRING           Dev Center name (required)
  --project STRING              Project name (required)
  --catalog-name STRING         Catalog name (default: platform-catalog)
  --catalog-url STRING          Catalog repository URL (required)
  --catalog-branch STRING       Git branch (default: main)
  --catalog-path STRING         Path in repo to catalog folder (default: catalog)
  --github-token STRING         GitHub Personal Access Token (if GitHub repo)
  --skip-role                   Skip RBAC role assignment
  --what-if                     Show what would happen without making changes
  --help                        Show this help message

Example:
  $0 \\
    --subscription-id "b6f10878-9f8a-4b3f-8bc5-3464cdd79c77" \\
    --resource-group "rg-ade-demo-eastus" \\
    --location "eastus" \\
    --dev-center "dc-platform-demo" \\
    --project "ProjectAlpha" \\
    --catalog-url "https://github.com/TeplrGuy/ade-catalog-demo" \\
    --github-token "<YOUR_GITHUB_PAT>"

EOF
}

# ============================================================================
# Argument Parsing
# ============================================================================

SUBSCRIPTION_ID=""
RESOURCE_GROUP=""
LOCATION=""
DEV_CENTER=""
PROJECT=""
CATALOG_URL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --subscription-id)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        --resource-group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --dev-center)
            DEV_CENTER="$2"
            shift 2
            ;;
        --project)
            PROJECT="$2"
            shift 2
            ;;
        --catalog-name)
            CATALOG_NAME="$2"
            shift 2
            ;;
        --catalog-url)
            CATALOG_URL="$2"
            shift 2
            ;;
        --catalog-branch)
            CATALOG_BRANCH="$2"
            shift 2
            ;;
        --catalog-path)
            CATALOG_PATH="$2"
            shift 2
            ;;
        --github-token)
            GITHUB_TOKEN="$2"
            shift 2
            ;;
        --skip-role)
            SKIP_ROLE_ASSIGNMENT=true
            shift
            ;;
        --what-if)
            WHAT_IF=true
            shift
            ;;
        --help)
            print_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$SUBSCRIPTION_ID" ]]; then
    print_error "Missing required argument: --subscription-id"
    print_help
    exit 1
fi

if [[ -z "$RESOURCE_GROUP" ]]; then
    print_error "Missing required argument: --resource-group"
    print_help
    exit 1
fi

if [[ -z "$LOCATION" ]]; then
    print_error "Missing required argument: --location"
    print_help
    exit 1
fi

if [[ -z "$DEV_CENTER" ]]; then
    print_error "Missing required argument: --dev-center"
    print_help
    exit 1
fi

if [[ -z "$PROJECT" ]]; then
    print_error "Missing required argument: --project"
    print_help
    exit 1
fi

if [[ -z "$CATALOG_URL" ]]; then
    print_error "Missing required argument: --catalog-url"
    print_help
    exit 1
fi

# ============================================================================
# Prerequisite Checks
# ============================================================================

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check Azure CLI
    print_step "Checking Azure CLI..."
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI not found. Please install it from https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    print_success "Azure CLI is installed"

    # Check authentication
    print_step "Checking Azure authentication..."
    if ! az account show &> /dev/null; then
        print_error "Not authenticated to Azure. Run: az login"
        exit 1
    fi
    print_success "Azure authentication is valid"
}

# ============================================================================
# Setup Functions
# ============================================================================

set_subscription() {
    print_header "Setting Target Subscription"

    print_step "Setting subscription to $SUBSCRIPTION_ID..."
    az account set --subscription "$SUBSCRIPTION_ID" 2>/dev/null

    local current_sub=$(az account show --query "name" -o tsv 2>/dev/null)
    print_success "Subscription set: $current_sub"
}

create_resource_group() {
    print_header "Creating Resource Group"

    print_step "Checking if resource group exists: $RESOURCE_GROUP..."
    if az group exists --name "$RESOURCE_GROUP" --query "boolean(@)" 2>/dev/null | grep -q "true"; then
        print_success "Resource group already exists: $RESOURCE_GROUP"
        return
    fi

    print_step "Creating resource group: $RESOURCE_GROUP in $LOCATION..."
    
    if [[ "$WHAT_IF" == "true" ]]; then
        print_warning "[WhatIf] Would create resource group: $RESOURCE_GROUP"
        return
    fi

    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --query "id" \
        2>/dev/null

    print_success "Resource group created"
}

create_dev_center() {
    print_header "Creating Azure Dev Center"

    print_step "Checking if Dev Center exists: $DEV_CENTER..."
    local existing=$(az devcenter admin devcenter list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[?name=='$DEV_CENTER'].id" \
        2>/dev/null)

    if [[ ! -z "$existing" ]]; then
        print_success "Dev Center already exists: $DEV_CENTER"
        return
    fi

    print_step "Creating Dev Center: $DEV_CENTER..."
    
    if [[ "$WHAT_IF" == "true" ]]; then
        print_warning "[WhatIf] Would create Dev Center: $DEV_CENTER"
        return
    fi

    az devcenter admin devcenter create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEV_CENTER" \
        --location "$LOCATION" \
        --identity-type SystemAssigned \
        2>/dev/null

    print_success "Dev Center created: $DEV_CENTER"
}

add_catalog() {
    print_header "Adding Catalog to Dev Center"

    print_step "Checking if catalog already exists: $CATALOG_NAME..."
    local existing=$(az devcenter admin catalog list \
        --resource-group "$RESOURCE_GROUP" \
        --dev-center-name "$DEV_CENTER" \
        --query "[?name=='$CATALOG_NAME'].id" \
        2>/dev/null)

    if [[ ! -z "$existing" ]]; then
        print_success "Catalog already exists: $CATALOG_NAME"
        return
    fi

    print_step "Adding catalog: $CATALOG_NAME..."
    print_step "Repository URL: $CATALOG_URL"
    print_step "Branch: $CATALOG_BRANCH"
    print_step "Path: $CATALOG_PATH"

    if [[ "$WHAT_IF" == "true" ]]; then
        print_warning "[WhatIf] Would add catalog: $CATALOG_NAME"
        return
    fi

    local cmd="az devcenter admin catalog create \
        --resource-group '$RESOURCE_GROUP' \
        --dev-center-name '$DEV_CENTER' \
        --name '$CATALOG_NAME' \
        --git-hub-url '$CATALOG_URL' \
        --branch '$CATALOG_BRANCH' \
        --path '$CATALOG_PATH'"

    if [[ ! -z "$GITHUB_TOKEN" ]] && [[ "$CATALOG_URL" == *"github.com"* ]]; then
        print_step "Using GitHub Personal Access Token for authentication..."
        cmd="$cmd --git-hub-pat '$GITHUB_TOKEN'"
    fi

    eval "$cmd" 2>/dev/null || {
        print_error "Failed to add catalog"
        print_error "If using GitHub, verify your PAT has 'repo' scope"
        exit 1
    }

    print_success "Catalog added successfully"
}

create_project() {
    print_header "Creating Dev Center Project"

    print_step "Checking if project exists: $PROJECT..."
    local existing=$(az devcenter admin project list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[?name=='$PROJECT'].id" \
        2>/dev/null)

    if [[ ! -z "$existing" ]]; then
        print_success "Project already exists: $PROJECT"
        return
    fi

    print_step "Creating project: $PROJECT..."
    
    if [[ "$WHAT_IF" == "true" ]]; then
        print_warning "[WhatIf] Would create project: $PROJECT"
        return
    fi

    az devcenter admin project create \
        --resource-group "$RESOURCE_GROUP" \
        --dev-center-name "$DEV_CENTER" \
        --name "$PROJECT" \
        --location "$LOCATION" \
        2>/dev/null

    print_success "Project created: $PROJECT"
}

# ============================================================================
# Summary
# ============================================================================

show_summary() {
    print_header "Setup Summary"

    echo ""
    echo -e "${CYAN}Configuration:${NC}"
    echo "  Subscription ID:       $SUBSCRIPTION_ID"
    echo "  Resource Group:        $RESOURCE_GROUP"
    echo "  Location:              $LOCATION"
    echo "  Dev Center:            $DEV_CENTER"
    echo "  Project:               $PROJECT"
    echo "  Catalog:               $CATALOG_NAME"
    echo "  Repository:            $CATALOG_URL"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Verify catalog sync status:"
    echo "     az devcenter admin catalog show -g $RESOURCE_GROUP -d $DEV_CENTER -n $CATALOG_NAME"
    echo ""
    echo "  2. View the Developer Portal:"
    echo "     https://aka.ms/devportal"
    echo ""
    echo "  3. Create your first environment using the portal or CLI"
    echo ""

    print_success "Setup completed successfully!"
}

# ============================================================================
# Main Execution
# ============================================================================

print_header "Azure Deployment Environments Catalog Demo -- Setup"
echo "Version: $SCRIPT_VERSION"
echo "Script started at: $SCRIPT_START_TIME"
echo ""

if [[ "$WHAT_IF" == "true" ]]; then
    print_warning "Running in WhatIf mode. No resources will be created."
    echo ""
fi

# Execute setup steps
check_prerequisites
set_subscription
create_resource_group
create_dev_center
add_catalog
create_project
show_summary
