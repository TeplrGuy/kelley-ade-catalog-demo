#Requires -Version 7.0
<#
.SYNOPSIS
Validation script for Azure Deployment Environments catalog demo.

.DESCRIPTION
This script validates that the ADE demo environment has been set up correctly.
It checks for:
- Resource group exists
- Dev Center exists
- Catalog is connected and synced
- Project exists
- Required role assignments are in place
- Environment definitions are available

.PARAMETER SubscriptionId
The Azure subscription ID.

.PARAMETER ResourceGroupName
Name of the resource group.

.PARAMETER DevCenterName
Name of the Dev Center.

.PARAMETER ProjectName
Name of the project.

.PARAMETER CatalogName
Name of the catalog.

.EXAMPLE
.\validate-demo.ps1 `
  -SubscriptionId "b6f10878-9f8a-4b3f-8bc5-3464cdd79c77" `
  -ResourceGroupName "rg-ade-demo-eastus" `
  -DevCenterName "dc-platform-demo" `
  -ProjectName "ProjectAlpha" `
  -CatalogName "platform-catalog"

.NOTES
Author: Platform Engineering Team
Version: 1.0
Created: June 3, 2026
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$DevCenterName,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $false)]
    [string]$CatalogName = "platform-catalog"
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$ValidationsPassed = 0
$ValidationsFailed = 0
$ValidationsWarning = 0

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=====================================================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "=====================================================================" -ForegroundColor Cyan
}

function Write-Check {
    param([string]$Message)
    Write-Host "[CHECK] $Message" -ForegroundColor Blue -NoNewline
}

function Write-Pass {
    Write-Host " [PASS]" -ForegroundColor Green
    $script:ValidationsPassed++
}

function Write-Fail {
    param([string]$Message = "")
    Write-Host " [FAIL]" -ForegroundColor Red
    if ($Message) {
        Write-Host "        $Message" -ForegroundColor Red
    }
    $script:ValidationsFailed++
}

function Write-Warn {
    param([string]$Message = "")
    Write-Host " [WARN]" -ForegroundColor Yellow
    if ($Message) {
        Write-Host "        $Message" -ForegroundColor Yellow
    }
    $script:ValidationsWarning++
}

# ============================================================================
# Validation Functions
# ============================================================================

function Validate-Subscription {
    Write-Header "Validating Subscription"

    Write-Check "Subscription is set correctly..."
    $currentSub = az account show --query "id" -o tsv 2>$null
    
    if ($LASTEXITCODE -eq 0 -and $currentSub -eq $SubscriptionId) {
        Write-Pass
    } else {
        Write-Fail "Subscription mismatch"
        Write-Host "Expected: $SubscriptionId" -ForegroundColor Red
        Write-Host "Current: $currentSub" -ForegroundColor Red
    }
}

function Validate-ResourceGroup {
    Write-Header "Validating Resource Group"

    Write-Check "Resource group exists: $ResourceGroupName..."
    $rgExists = az group exists --name $ResourceGroupName 2>$null
    
    if ($LASTEXITCODE -eq 0 -and $rgExists -eq "true") {
        Write-Pass
        
        Write-Check "Resource group has resources..."
        $resourceList = az resource list --resource-group $ResourceGroupName -o json 2>$null | ConvertFrom-Json
        $resourceCount = @($resourceList).Count
        if ($resourceCount -gt 0) {
            Write-Host " [$resourceCount resources]" -ForegroundColor Green
            Write-Pass
        } else {
            Write-Warn "Resource group is empty"
        }
    } else {
        Write-Fail "Resource group does not exist"
    }
}

function Validate-DevCenter {
    Write-Header "Validating Dev Center"

    Write-Check "Dev Center exists: $DevCenterName..."
    $dc = az devcenter admin devcenter show `
        --resource-group $ResourceGroupName `
        --name $DevCenterName `
        --query "{name:name, id:id, principalId:identity.principalId}" `
        2>$null | ConvertFrom-Json

    if ($LASTEXITCODE -eq 0 -and $dc) {
        Write-Pass
        
        Write-Check "Dev Center has system-assigned managed identity..."
        if ($dc.principalId) {
            Write-Host " [$($dc.principalId)]" -ForegroundColor Green
            Write-Pass
        } else {
            Write-Fail "Managed identity not found"
        }
    } else {
        Write-Fail "Dev Center does not exist"
    }
}

function Validate-Catalog {
    Write-Header "Validating Catalog"

    Write-Check "Catalog exists: $CatalogName..."
    $catalog = az devcenter admin catalog show `
        --resource-group $ResourceGroupName `
        --dev-center-name $DevCenterName `
        --name $CatalogName `
        --query "{name:name, syncState:syncState, syncType:syncType}" `
        2>$null | ConvertFrom-Json

    if ($LASTEXITCODE -eq 0 -and $catalog) {
        Write-Pass
        
        Write-Check "Catalog has synced successfully..."
        if ($catalog.syncState -eq "Succeeded") {
            Write-Host " [SYNCED]" -ForegroundColor Green
            Write-Pass
        } elseif ($catalog.syncState -eq "InProgress") {
            Write-Host " [IN_PROGRESS]" -ForegroundColor Yellow
            Write-Warn "Sync is still in progress"
        } else {
            Write-Host " [$($catalog.syncState)]" -ForegroundColor Yellow
            Write-Warn "Catalog sync status: $($catalog.syncState)"
        }
    } else {
        Write-Fail "Catalog does not exist"
    }
}

function Validate-CatalogEnvironments {
    Write-Header "Validating Catalog Environments"

    Write-Check "Catalog contains environment definitions..."
    $environmentList = az devcenter dev environment-definition list `
        --project-name $ProjectName `
        --dev-center-name $DevCenterName `
        -o json `
        2>$null | ConvertFrom-Json
    $environments = @($environmentList).Count

    if ($environments -gt 0) {
        Write-Host " [$environments environment(s)]" -ForegroundColor Green
        Write-Pass
        
        # Show environment definitions
        Write-Host ""
        Write-Host "Available environment definitions:" -ForegroundColor Cyan
        $envList = az devcenter dev environment-definition list `
            --project-name $ProjectName `
            --dev-center-name $DevCenterName `
            --query "[?catalogName=='$CatalogName'].{name:name, templatePath:templatePath}" `
            2>$null | ConvertFrom-Json

        foreach ($env in $envList) {
            Write-Host "  - $($env.name) (template: $($env.templatePath))" -ForegroundColor Green
        }
    } else {
        Write-Fail "No environment definitions found in catalog"
    }
}

function Validate-Project {
    Write-Header "Validating Project"

    Write-Check "Project exists: $ProjectName..."
    $project = az devcenter admin project show `
        --resource-group $ResourceGroupName `
        --name $ProjectName `
        --query "{name:name, devCenterId:devCenterId}" `
        2>$null | ConvertFrom-Json

    if ($LASTEXITCODE -eq 0 -and $project) {
        Write-Pass
    } else {
        Write-Fail "Project does not exist"
    }
}

function Validate-RoleAssignment {
    Write-Header "Validating Role Assignments"

    # Get Dev Center's managed identity
    $dc = az devcenter admin devcenter show `
        --resource-group $ResourceGroupName `
        --name $DevCenterName `
        --query "identity.principalId" -o tsv `
        2>$null

    if (-not $dc) {
        Write-Warn "Could not retrieve Dev Center managed identity"
        return
    }

    Write-Check "Dev Center managed identity has Contributor role..."
    $rgScope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName"
    $roles = az role assignment list `
        --assignee $dc `
        --role "Contributor" `
        --scope $rgScope `
        --query "length(@)" `
        2>$null

    if ($roles -gt 0) {
        Write-Pass
    } else {
        Write-Warn "Contributor role not found. Run setup script to assign it."
    }
}

function Validate-BicepTemplate {
    Write-Header "Validating Bicep Template Files"

    Write-Check "Bicep template exists in catalog..."
    $repoRoot = Join-Path $PSScriptRoot ".."
    $bicepPath = Join-Path $repoRoot "catalog/webapp-demo/main.bicep"
    $paramsPath = Join-Path $repoRoot "catalog/webapp-demo/parameters.json"

    if (Test-Path $bicepPath) {
        Write-Pass
        
        Write-Check "Parameters file exists..."
        if (Test-Path $paramsPath) {
            Write-Pass
        } else {
            Write-Fail "parameters.json not found"
        }
    } else {
        Write-Fail "main.bicep not found"
    }
}

function Show-Summary {
    Write-Header "Validation Summary"

    Write-Host ""
    Write-Host "Results:" -ForegroundColor Cyan
    Write-Host "  Passed:   $ValidationsPassed" -ForegroundColor Green
    Write-Host "  Failed:   $ValidationsFailed" -ForegroundColor Red
    Write-Host "  Warnings: $ValidationsWarning" -ForegroundColor Yellow
    Write-Host ""

    if ($ValidationsFailed -eq 0) {
        Write-Host "✓ All critical validations passed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your ADE catalog demo environment is ready for testing." -ForegroundColor Green
        Write-Host "You can now create environments using the Developer Portal:" -ForegroundColor Green
        Write-Host "  https://aka.ms/devportal" -ForegroundColor Cyan
        return $true
    } else {
        Write-Host "✗ Some validations failed. Please review the errors above." -ForegroundColor Red
        return $false
    }
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Header "Azure Deployment Environments Catalog Demo -- Validation"
Write-Host "Subscription: $SubscriptionId"
Write-Host "Resource Group: $ResourceGroupName"
Write-Host ""

# Set subscription
az account set --subscription $SubscriptionId 2>$null

# Run validations
Validate-Subscription
Validate-ResourceGroup
Validate-DevCenter
Validate-Catalog
Validate-CatalogEnvironments
Validate-Project
Validate-RoleAssignment
Validate-BicepTemplate

# Show results
$success = Show-Summary

# Exit with appropriate code
if ($success) {
    exit 0
} else {
    exit 1
}
