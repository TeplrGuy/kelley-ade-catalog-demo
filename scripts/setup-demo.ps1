#Requires -Version 7.0
<#
.SYNOPSIS
Setup script for Azure Deployment Environments catalog demo.

.DESCRIPTION
This script provisions the necessary Azure resources for the ADE catalog demo:
- Resource Group
- Azure Dev Center
- Catalog (if needed)
- Project
- RBAC role assignments for the Dev Center managed identity

.PARAMETER SubscriptionId
The Azure subscription ID where resources will be created.

.PARAMETER ResourceGroupName
Name of the resource group to create or use.

.PARAMETER Location
Azure region for resources (e.g., eastus, westus2).

.PARAMETER DevCenterName
Name of the Dev Center to create.

.PARAMETER ProjectName
Name of the Dev Center project.

.PARAMETER CatalogName
Name of the catalog.

.PARAMETER CatalogRepoUrl
GitHub or Azure Repos URL for the catalog repository.

.PARAMETER CatalogBranch
Branch name in the catalog repository (default: main).

.PARAMETER CatalogPath
Path within the repository to the catalog folder (default: catalog).

.PARAMETER GitHubToken
GitHub Personal Access Token (if using GitHub catalog).

.EXAMPLE
.\setup-demo.ps1 `
  -SubscriptionId "b6f10878-9f8a-4b3f-8bc5-3464cdd79c77" `
  -ResourceGroupName "rg-ade-demo-eastus" `
  -Location "eastus" `
  -DevCenterName "dc-platform-demo" `
  -ProjectName "ProjectAlpha" `
  -CatalogName "platform-catalog" `
  -CatalogRepoUrl "https://github.com/TeplrGuy/ade-catalog-demo" `
  -GitHubToken "<your-github-pat>"

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
    [ValidateLength(1, 64)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [ValidateSet('eastus', 'westus2', 'centralus', 'northeurope', 'westeurope', 'southcentralus', 'australiaeast')]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [ValidateLength(3, 26)]
    [string]$DevCenterName,

    [Parameter(Mandatory = $true)]
    [ValidateLength(1, 64)]
    [string]$ProjectName,

    [Parameter(Mandatory = $false)]
    [string]$CatalogName = "platform-catalog",

    [Parameter(Mandatory = $true)]
    [ValidatePattern('^https://')]
    [string]$CatalogRepoUrl,

    [Parameter(Mandatory = $false)]
    [string]$CatalogBranch = "main",

    [Parameter(Mandatory = $false)]
    [string]$CatalogPath = "catalog",

    [Parameter(Mandatory = $false)]
    [string]$GitHubToken = "",

    [Parameter(Mandatory = $false)]
    [switch]$SkipRoleAssignment = $false,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf = $false
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

$ScriptVersion = "1.0"
$ScriptStartTime = Get-Date
$IsGitHubRepo = $CatalogRepoUrl -match "github\.com"
$IsAzureDevOpsRepo = $CatalogRepoUrl -match "dev\.azure\.com"

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

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK]   $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Test-Prerequisites {
    Write-Header "Checking Prerequisites"

    # Check Azure CLI
    Write-Step "Checking Azure CLI..."
    try {
        $azVersion = az --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Azure CLI is installed"
        }
    }
    catch {
        Write-Error-Custom "Azure CLI not found. Please install it from https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    }

    # Check authentication
    Write-Step "Checking Azure authentication..."
    $currentUser = az account show 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Not authenticated to Azure. Run: az login"
        exit 1
    }
    Write-Success "Azure authentication is valid"
}

function Set-TargetSubscription {
    Write-Header "Setting Target Subscription"

    Write-Step "Setting subscription to $SubscriptionId..."
    az account set --subscription $SubscriptionId
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to set subscription"
        exit 1
    }

    $sub = az account show --query "{name:name, id:id}" 2>$null | ConvertFrom-Json
    Write-Success "Subscription set: $($sub.name) ($($sub.id))"
}

function New-ResourceGroup {
    Write-Header "Creating Resource Group"

    Write-Step "Checking if resource group exists: $ResourceGroupName..."
    $rgExists = az group exists --name $ResourceGroupName --query "boolean()"

    if ($rgExists -eq "true") {
        Write-Success "Resource group already exists: $ResourceGroupName"
        return
    }

    Write-Step "Creating resource group: $ResourceGroupName in $Location..."
    
    if ($WhatIf) {
        Write-Warning-Custom "[WhatIf] Would create resource group: $ResourceGroupName"
        return
    }

    $result = az group create `
        --name $ResourceGroupName `
        --location $Location `
        --query "id" `
        2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Resource group created: $result"
    }
    else {
        Write-Error-Custom "Failed to create resource group"
        exit 1
    }
}

function New-DevCenter {
    Write-Header "Creating Azure Dev Center"

    Write-Step "Checking if Dev Center exists: $DevCenterName..."
    $dcExists = az devcenter admin devcenter list `
        --resource-group $ResourceGroupName `
        --query "[?name=='$DevCenterName'].id" `
        2>$null | ConvertFrom-Json

    if ($dcExists -and $dcExists.Count -gt 0) {
        Write-Success "Dev Center already exists: $DevCenterName"
        return
    }

    Write-Step "Creating Dev Center: $DevCenterName..."
    
    if ($WhatIf) {
        Write-Warning-Custom "[WhatIf] Would create Dev Center: $DevCenterName"
        return
    }

    $result = az devcenter admin devcenter create `
        --resource-group $ResourceGroupName `
        --name $DevCenterName `
        --location $Location `
        --identity-type SystemAssigned `
        2>$null | ConvertFrom-Json

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dev Center created: $($result.name)"
        Write-Success "Managed Identity Principal ID: $($result.identity.principalId)"
        return $result.identity.principalId
    }
    else {
        Write-Error-Custom "Failed to create Dev Center"
        exit 1
    }
}

function Add-Catalog {
    Write-Header "Adding Catalog to Dev Center"

    Write-Step "Checking if catalog already exists: $CatalogName..."
    $catalogExists = az devcenter admin catalog list `
        --resource-group $ResourceGroupName `
        --dev-center-name $DevCenterName `
        --query "[?name=='$CatalogName'].id" `
        2>$null | ConvertFrom-Json

    if ($catalogExists -and $catalogExists.Count -gt 0) {
        Write-Success "Catalog already exists: $CatalogName"
        return
    }

    Write-Step "Adding catalog: $CatalogName..."
    Write-Step "Repository URL: $CatalogRepoUrl"
    Write-Step "Branch: $CatalogBranch"
    Write-Step "Path: $CatalogPath"

    if ($WhatIf) {
        Write-Warning-Custom "[WhatIf] Would add catalog: $CatalogName"
        return
    }

    # Build command
    $catalogCmd = @(
        "devcenter", "admin", "catalog", "create",
        "--resource-group", $ResourceGroupName,
        "--dev-center-name", $DevCenterName,
        "--name", $CatalogName,
        "--git-hub-url", $CatalogRepoUrl,
        "--branch", $CatalogBranch,
        "--path", $CatalogPath
    )

    # Add token if GitHub
    if ($IsGitHubRepo -and $GitHubToken) {
        Write-Step "Using GitHub Personal Access Token for authentication..."
        $catalogCmd += "--git-hub-pat", $GitHubToken
    }

    $result = az @catalogCmd 2>$null | ConvertFrom-Json

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Catalog added: $($result.name)"
        Write-Success "Sync status: $($result.syncState)"
    }
    else {
        Write-Error-Custom "Failed to add catalog"
        Write-Error-Custom "If using GitHub, verify your PAT has 'repo' scope"
        exit 1
    }
}

function New-DevCenterProject {
    Write-Header "Creating Dev Center Project"

    Write-Step "Checking if project exists: $ProjectName..."
    $projectExists = az devcenter admin project list `
        --resource-group $ResourceGroupName `
        --query "[?name=='$ProjectName'].id" `
        2>$null | ConvertFrom-Json

    if ($projectExists -and $projectExists.Count -gt 0) {
        Write-Success "Project already exists: $ProjectName"
        return
    }

    Write-Step "Creating project: $ProjectName..."
    
    if ($WhatIf) {
        Write-Warning-Custom "[WhatIf] Would create project: $ProjectName"
        return
    }

    $result = az devcenter admin project create `
        --resource-group $ResourceGroupName `
        --dev-center-name $DevCenterName `
        --name $ProjectName `
        --location $Location `
        2>$null | ConvertFrom-Json

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Project created: $($result.name)"
    }
    else {
        Write-Error-Custom "Failed to create project"
        exit 1
    }
}

function Set-RoleAssignment {
    param([string]$PrincipalId)

    Write-Header "Setting RBAC Role Assignment"

    if (-not $PrincipalId) {
        Write-Warning-Custom "Principal ID not provided. Skipping role assignment."
        Write-Step "You can assign roles manually with:"
        Write-Host "  az role assignment create \" -ForegroundColor Gray
        Write-Host "    --assignee-object-id <DEV_CENTER_PRINCIPAL_ID> \" -ForegroundColor Gray
        Write-Host "    --role \"Contributor\" \" -ForegroundColor Gray
        Write-Host "    --scope /subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName" -ForegroundColor Gray
        return
    }

    if ($SkipRoleAssignment) {
        Write-Warning-Custom "Role assignment skipped (--SkipRoleAssignment)"
        return
    }

    Write-Step "Assigning Contributor role to Dev Center managed identity..."
    Write-Step "Principal ID: $PrincipalId"

    if ($WhatIf) {
        Write-Warning-Custom "[WhatIf] Would assign Contributor role"
        return
    }

    $roleAssigned = az role assignment list `
        --assignee $PrincipalId `
        --role "Contributor" `
        --scope /subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName `
        --query "length(@)" `
        2>$null

    if ($roleAssigned -gt 0) {
        Write-Success "Contributor role already assigned"
        return
    }

    az role assignment create `
        --assignee-object-id $PrincipalId `
        --role "Contributor" `
        --scope /subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName `
        2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "Role assignment completed"
    }
    else {
        Write-Warning-Custom "Failed to assign role. This may require elevated permissions."
    }
}

function Show-Summary {
    Write-Header "Setup Summary"

    Write-Host ""
    Write-Host "Configuration:" -ForegroundColor Cyan
    Write-Host "  Subscription ID:       $SubscriptionId"
    Write-Host "  Resource Group:        $ResourceGroupName"
    Write-Host "  Location:              $Location"
    Write-Host "  Dev Center:            $DevCenterName"
    Write-Host "  Project:               $ProjectName"
    Write-Host "  Catalog:               $CatalogName"
    Write-Host "  Repository:            $CatalogRepoUrl"
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Verify catalog sync status:"
    Write-Host "     az devcenter admin catalog show -g $ResourceGroupName -d $DevCenterName -n $CatalogName"
    Write-Host ""
    Write-Host "  2. List available environments:"
    Write-Host "     az devcenter admin devcenter list-environments -g $ResourceGroupName -d $DevCenterName"
    Write-Host ""
    Write-Host "  3. View the Developer Portal:"
    Write-Host "     https://aka.ms/devportal"
    Write-Host ""
    Write-Host "  4. Create your first environment using the portal or CLI"
    Write-Host ""

    $duration = (Get-Date) - $ScriptStartTime
    Write-Success "Setup completed in $($duration.TotalSeconds) seconds"
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Header "Azure Deployment Environments Catalog Demo -- Setup"
Write-Host "Version: $ScriptVersion"
Write-Host "Script started at: $ScriptStartTime"
Write-Host ""

if ($WhatIf) {
    Write-Warning-Custom "Running in WhatIf mode. No resources will be created."
    Write-Host ""
}

# Execute setup steps
Test-Prerequisites
Set-TargetSubscription
New-ResourceGroup
$principalId = New-DevCenter
Add-Catalog
New-DevCenterProject
Set-RoleAssignment -PrincipalId $principalId
Show-Summary

Write-Host ""
Write-Success "Setup completed successfully!"
