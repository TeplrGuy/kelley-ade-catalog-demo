#!/bin/bash

#
# validate-demo.sh
# Validation script for Azure Deployment Environments catalog demo
#
# Usage:
#   ./validate-demo.sh [options]
#
# Options:
#   --subscription-id STRING     Azure subscription ID (required)
#   --resource-group STRING      Resource group name (required)
#   --dev-center STRING          Dev Center name (required)
#   --project STRING             Project name (required)
#   --catalog-name STRING        Catalog name (default: platform-catalog)
#   --help                       Show this help message
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

VALIDATIONS_PASSED=0
VALIDATIONS_FAILED=0
VALIDATIONS_WARNING=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}=====================================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}=====================================================================${NC}"
}

print_check() {
    echo -n -e "${BLUE}[CHECK]${NC} $1"
}

print_pass() {
    echo -e " ${GREEN}[PASS]${NC}"
    ((VALIDATIONS_PASSED++))
}

print_fail() {
    echo -e " ${RED}[FAIL]${NC}"
    if [[ ! -z "${1:-}" ]]; then
        echo -e "        ${RED}$1${NC}"
    fi
    ((VALIDATIONS_FAILED++))
}

print_warn() {
    echo -e " ${YELLOW}[WARN]${NC}"
    if [[ ! -z "${1:-}" ]]; then
        echo -e "        ${YELLOW}$1${NC}"
    fi
    ((VALIDATIONS_WARNING++))
}

print_help() {
    cat << EOF
Usage: $0 [options]

Validation script for Azure Deployment Environments catalog demo.

Options:
  --subscription-id STRING    Azure subscription ID (required)
  --resource-group STRING     Resource group name (required)
  --dev-center STRING         Dev Center name (required)
  --project STRING            Project name (required)
  --catalog-name STRING       Catalog name (default: platform-catalog)
  --help                      Show this help message

Example:
  $0 \\
    --subscription-id "b6f10878-9f8a-4b3f-8bc5-3464cdd79c77" \\
    --resource-group "rg-ade-demo-eastus" \\
    --dev-center "dc-platform-demo" \\
    --project "ProjectAlpha"

EOF
}

# ============================================================================
# Argument Parsing
# ============================================================================

SUBSCRIPTION_ID=""
RESOURCE_GROUP=""
DEV_CENTER=""
PROJECT=""
CATALOG_NAME="platform-catalog"

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
        --help)
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$SUBSCRIPTION_ID" ]]; then
    echo -e "${RED}Missing required argument: --subscription-id${NC}"
    print_help
    exit 1
fi

if [[ -z "$RESOURCE_GROUP" ]]; then
    echo -e "${RED}Missing required argument: --resource-group${NC}"
    print_help
    exit 1
fi

if [[ -z "$DEV_CENTER" ]]; then
    echo -e "${RED}Missing required argument: --dev-center${NC}"
    print_help
    exit 1
fi

if [[ -z "$PROJECT" ]]; then
    echo -e "${RED}Missing required argument: --project${NC}"
    print_help
    exit 1
fi

# ============================================================================
# Validation Functions
# ============================================================================

validate_subscription() {
    print_header "Validating Subscription"

    print_check "Subscription is set correctly..."
    local current_sub=$(az account show --query "id" -o tsv 2>/dev/null || echo "")
    
    if [[ "$current_sub" == "$SUBSCRIPTION_ID" ]]; then
        print_pass
    else
        print_fail "Subscription mismatch (Expected: $SUBSCRIPTION_ID, Current: $current_sub)"
    fi
}

validate_resource_group() {
    print_header "Validating Resource Group"

    print_check "Resource group exists: $RESOURCE_GROUP..."
    local rg_exists=$(az group exists --name "$RESOURCE_GROUP" --query "boolean(@)" 2>/dev/null || echo "false")
    
    if [[ "$rg_exists" == "true" ]]; then
        print_pass
        
        print_check "Resource group has resources..."
        local resource_count=$(az resource list --resource-group "$RESOURCE_GROUP" --query "length(@)" 2>/dev/null || echo "0")
        if [[ $resource_count -gt 0 ]]; then
            echo -e " ${GREEN}[$resource_count resources]${NC}"
            print_pass
        else
            print_warn "Resource group is empty"
        fi
    else
        print_fail "Resource group does not exist"
    fi
}

validate_dev_center() {
    print_header "Validating Dev Center"

    print_check "Dev Center exists: $DEV_CENTER..."
    local dc=$(az devcenter admin devcenter show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEV_CENTER" \
        --query "{name:name, principalId:identity.principalId}" \
        2>/dev/null || echo "")
    
    if [[ ! -z "$dc" ]]; then
        print_pass
        
        print_check "Dev Center has system-assigned managed identity..."
        local principal_id=$(echo "$dc" | jq -r '.principalId' 2>/dev/null || echo "")
        if [[ ! -z "$principal_id" ]]; then
            echo -e " ${GREEN}[$principal_id]${NC}"
            print_pass
        else
            print_fail "Managed identity not found"
        fi
    else
        print_fail "Dev Center does not exist"
    fi
}

validate_catalog() {
    print_header "Validating Catalog"

    print_check "Catalog exists: $CATALOG_NAME..."
    local catalog=$(az devcenter admin catalog show \
        --resource-group "$RESOURCE_GROUP" \
        --dev-center-name "$DEV_CENTER" \
        --name "$CATALOG_NAME" \
        --query "{name:name, syncState:syncState}" \
        2>/dev/null || echo "")
    
    if [[ ! -z "$catalog" ]]; then
        print_pass
        
        print_check "Catalog has synced successfully..."
        local sync_state=$(echo "$catalog" | jq -r '.syncState' 2>/dev/null || echo "Unknown")
        
        if [[ "$sync_state" == "Succeeded" ]]; then
            echo -e " ${GREEN}[SYNCED]${NC}"
            print_pass
        elif [[ "$sync_state" == "InProgress" ]]; then
            echo -e " ${YELLOW}[IN_PROGRESS]${NC}"
            print_warn "Sync is still in progress"
        else
            echo -e " ${YELLOW}[$sync_state]${NC}"
            print_warn "Catalog sync status: $sync_state"
        fi
    else
        print_fail "Catalog does not exist"
    fi
}

validate_catalog_environments() {
    print_header "Validating Catalog Environments"

    print_check "Catalog contains environment definitions..."
    local environments=$(az devcenter admin catalog environment-definition list \
        --resource-group "$RESOURCE_GROUP" \
        --dev-center-name "$DEV_CENTER" \
        --catalog-name "$CATALOG_NAME" \
        --query "length(@)" \
        2>/dev/null || echo "0")
    
    if [[ $environments -gt 0 ]]; then
        echo -e " ${GREEN}[$environments environment(s)]${NC}"
        print_pass
        
        echo ""
        echo -e "${CYAN}Available environment definitions:${NC}"
        az devcenter admin catalog environment-definition list \
            --resource-group "$RESOURCE_GROUP" \
            --dev-center-name "$DEV_CENTER" \
            --catalog-name "$CATALOG_NAME" \
            --query "[].{name:name, templatePath:templatePath}" \
            2>/dev/null | jq -r '.[] | "  - \(.name) (template: \(.templatePath))"'
    else
        print_fail "No environment definitions found in catalog"
    fi
}

validate_project() {
    print_header "Validating Project"

    print_check "Project exists: $PROJECT..."
    local project=$(az devcenter admin project show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$PROJECT" \
        --query "{name:name}" \
        2>/dev/null || echo "")
    
    if [[ ! -z "$project" ]]; then
        print_pass
    else
        print_fail "Project does not exist"
    fi
}

show_summary() {
    print_header "Validation Summary"

    echo ""
    echo -e "${CYAN}Results:${NC}"
    echo -e "  Passed:   ${GREEN}$VALIDATIONS_PASSED${NC}"
    echo -e "  Failed:   ${RED}$VALIDATIONS_FAILED${NC}"
    echo -e "  Warnings: ${YELLOW}$VALIDATIONS_WARNING${NC}"
    echo ""

    if [[ $VALIDATIONS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All critical validations passed!${NC}"
        echo ""
        echo -e "${GREEN}Your ADE catalog demo environment is ready for testing.${NC}"
        echo -e "${GREEN}You can now create environments using the Developer Portal:${NC}"
        echo -e "${CYAN}  https://aka.ms/devportal${NC}"
        return 0
    else
        echo -e "${RED}✗ Some validations failed. Please review the errors above.${NC}"
        return 1
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

print_header "Azure Deployment Environments Catalog Demo -- Validation"
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource Group: $RESOURCE_GROUP"
echo ""

# Set subscription
az account set --subscription "$SUBSCRIPTION_ID" 2>/dev/null

# Run validations
validate_subscription
validate_resource_group
validate_dev_center
validate_catalog
validate_catalog_environments
validate_project
show_summary

exit_code=$?
exit $exit_code
