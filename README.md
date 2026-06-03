---
title: Azure Deployment Environments Catalog Demo
description: Enterprise-ready platform engineering demo showcasing self-service environment catalogs
---

# Azure Deployment Environments Catalog Demo

A customer-ready demonstration of platform engineering and self-service infrastructure provisioning using **Azure Deployment Environments (ADE)** with a catalog backed by GitHub or Azure Repos.

## What This Repository Contains

- **docs/customer-one-pager.html** – Executive-friendly one-pager for customer discussions (open in a browser)
- **docs/demo-walkthrough.md** – Detailed walkthrough script with talking points and customer discussion questions
- **docs/architecture-diagram.svg** – Reference architecture visualization
- **catalog/webapp-demo/** – A complete, curated environment definition suitable for ADE
- **samples/app/** – Sample application code deployable via the catalog
- **scripts/** – Setup and validation scripts (PowerShell and Bash)

## The Platform Engineering Story

This demo illustrates a **platform engineering pattern** where:

1. **Platform Team** (you) curates and publishes approved infrastructure templates into a catalog repository
2. **Catalog Repository** (GitHub or Azure Repos) serves as the single source of truth
3. **Azure Deployment Environments** syncs the catalog and provides self-service infrastructure
4. **Application Teams** self-service approved, standardized environments safely
5. **Governance** remains centralized while developer experience improves

### Key Benefits Demonstrated

- ✅ **Faster Onboarding** – App teams get approved infrastructure in minutes, not days
- ✅ **Standardization** – All environments follow platform standards automatically
- ✅ **Reduced Drift** – Template-driven consistency prevents infrastructure divergence
- ✅ **Better Governance** – RBAC and approvals remain centralized in Azure
- ✅ **Reduced Cognitive Load** – App teams don't need deep Terraform/IaC expertise
- ✅ **Consistent CI/CD** – All environments inherit platform-approved deployment patterns

## Quick Start

### Prerequisites

- Azure subscription (tenant: `16b3c013-d300-468d-ac64-7eda0820b6d3`, subscription: `b6f10878-9f8a-4b3f-8bc5-3464cdd79c77`)
- Azure CLI installed and authenticated
- PowerShell 7+ or Bash
- GitHub account (https://github.com/TeplrGuy) or Azure DevOps access (https://dev.azure.com/gappiahdemo-msft/)

### Setup Steps

#### 1. Prepare the Catalog Repository

```powershell
# Option A: Use GitHub
git clone https://github.com/TeplrGuy/ade-catalog-demo
cd ade-catalog-demo
git remote set-url origin https://github.com/TeplrGuy/ade-catalog-demo

# Option B: Use Azure DevOps
git clone https://dev.azure.com/gappiahdemo-msft/PlatformEngineering/_git/ade-catalog
cd ade-catalog
```

#### 2. Set Variables

```powershell
$AZURE_SUBSCRIPTION_ID = "b6f10878-9f8a-4b3f-8bc5-3464cdd79c77"
$RESOURCE_GROUP_NAME = "rg-ade-demo-eastus"
$LOCATION = "eastus"
$DEV_CENTER_NAME = "dc-platform-demo"
$PROJECT_NAME = "ProjectAlpha"
$CATALOG_NAME = "platform-catalog"
$GITHUB_REPO_URL = "https://github.com/TeplrGuy/ade-catalog-demo"
```

#### 3. Run Setup Script

```powershell
# PowerShell
.\scripts\setup-demo.ps1 -SubscriptionId $AZURE_SUBSCRIPTION_ID `
  -ResourceGroupName $RESOURCE_GROUP_NAME `
  -Location $LOCATION `
  -DevCenterName $DEV_CENTER_NAME `
  -ProjectName $PROJECT_NAME `
  -CatalogName $CATALOG_NAME `
  -CatalogRepoUrl $GITHUB_REPO_URL

# Or Bash
chmod +x scripts/setup-demo.sh
./scripts/setup-demo.sh
```

#### 4. Verify Setup

```powershell
# PowerShell
.\scripts\validate-demo.ps1 -ResourceGroupName $RESOURCE_GROUP_NAME

# Or Bash
chmod +x scripts/validate-demo.sh
./scripts/validate-demo.sh
```

## Demo Walkthrough

See **[docs/demo-walkthrough.md](docs/demo-walkthrough.md)** for:

- 2-minute executive summary
- 5-minute technical walkthrough
- Step-by-step customer presentation flow
- How to explain the platform engineering pattern
- Suggested customer discussion questions
- Talking points about GitHub Copilot integration

## Customer One-Pager

Open **[docs/customer-one-pager.html](docs/customer-one-pager.html)** in a web browser for a polished, executive-ready presentation slide.

**Note:** This file is self-contained and requires no build process. It uses Tailwind CSS via CDN and is safe to open locally.

## Catalog Structure

The `catalog/` directory contains **environment definitions** suitable for ADE:

```
catalog/
└── webapp-demo/
    ├── environment.yaml      # ADE environment definition
    ├── main.bicep            # Azure infrastructure template
    ├── parameters.json       # Template parameters
    └── README.md             # Environment documentation
```

### webapp-demo Environment

A simple, cost-effective environment demonstrating the ADE pattern:

- **App Service Plan** (Basic tier, low cost)
- **Web App** (Node.js or static HTML ready)
- **Optional Storage Account** (for demo content)
- **Managed Identity** (for secure auth)
- **RBAC** (built-in platform governance)

**Cost estimate:** ~$15–30/month for a demo environment.

## GitHub Copilot Integration

This demo supports GitHub Copilot for platform engineers:

- Generate template documentation
- Explain infrastructure code
- Scaffold new environment definitions
- Generate pipeline snippets
- Improve onboarding materials

See **docs/demo-walkthrough.md** for Copilot conversation examples.

## What You Can Show in a Customer Meeting

1. **Static Presentation** (5 min) – Open `docs/customer-one-pager.html` in a browser
2. **Repository Tour** (5 min) – Walk through `catalog/` structure and explain the pattern
3. **Live Demo** (10–15 min) – If setup is complete:
   - Show Azure DevCenter and catalog sync
   - Trigger a new environment deployment
   - Show the deployed web app
   - Explain governance and RBAC
4. **Discussion** (10 min) – Use talking points from `docs/demo-walkthrough.md`

## Manual Setup Steps

Some steps are easier to do in the Azure Portal. See **docs/demo-walkthrough.md** section "Portal Configuration Checklist" for detailed instructions on:

- Creating the Resource Group
- Provisioning the Dev Center
- Adding managed identity assignments
- Connecting the GitHub/Azure Repos catalog
- Testing self-service environment deployment

## Customization

To adapt this demo for your customer:

1. Replace placeholder names with customer-specific naming
2. Adjust Azure region (`$LOCATION`) as needed
3. Modify the web app sample in `samples/app/index.html`
4. Add customer branding to `docs/customer-one-pager.html`
5. Customize talking points in `docs/demo-walkthrough.md`

## Troubleshooting

### Catalog Sync Issues

If the ADE catalog doesn't sync from GitHub/Azure Repos:

1. Verify the repository URL in the Dev Center catalog settings
2. Check that the GitHub/Azure Repos PAT has `repo` scope
3. Confirm that `catalog/` directory structure matches ADE expectations
4. Run `validate-demo.ps1` or `validate-demo.sh` to check for missing files

### Deployment Failures

Common issues:

- **Insufficient quota:** Check VM/App Service quotas in the subscription
- **Region unavailability:** Some resource types may not be available in all regions
- **RBAC permissions:** Verify managed identity has contributor role on the resource group

## Support and Next Steps

### Pilot Phase Recommendations

1. **Week 1:** Set up Dev Center and validate catalog sync
2. **Week 2:** Test self-service deployment with one app team
3. **Week 3:** Gather feedback and iterate on environment definition
4. **Week 4:** Plan expansion to additional environment patterns

### Suggested Conversation with Contoso

- "How many infrastructure patterns does your platform team maintain today?"
- "What are the biggest pain points in current infrastructure provisioning?"
- "How can we reduce the time for app teams to get a new environment?"
- "What governance controls must remain centralized?"
- "How can GitHub Copilot improve your platform engineering team's productivity?"

## Support

For questions or issues:

1. Check **docs/demo-walkthrough.md** for detailed walkthroughs
2. Review **scripts/** for setup/validation logic
3. Consult [Azure Deployment Environments documentation](https://learn.microsoft.com/en-us/azure/deployment-environments/)
4. Review [ADE Catalog schema](https://learn.microsoft.com/en-us/azure/deployment-environments/configure-environments-github-repo)

---

**Last Updated:** June 3, 2026  
**Version:** 1.0  
**Audience:** Enterprise customer presentation, platform engineering teams
