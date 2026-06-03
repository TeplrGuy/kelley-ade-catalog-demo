---
title: Contoso Azure Deployment Environments Catalog Demo
description: Ready-to-run demo showing governed self-service infrastructure with Azure Deployment Environments, Bicep templates, and Terraform templates
---

## Overview

This repository demonstrates a platform engineering pattern where platform teams publish approved infrastructure templates and developers self-service compliant environments.

## Included environment templates

* Bicep template: `catalog/webapp-demo/environment.yaml` with `catalog/webapp-demo/main.bicep`
* Terraform template: `catalog/webapp-terraform-demo/environment.yaml` with `catalog/webapp-terraform-demo/main.tf`

## Useful demo links

* GitHub catalog repository: <https://github.com/TeplrGuy/contoso-ade-catalog-demo>
* Azure Repos mirror: <https://dev.azure.com/gappiahdemo-msft/P/_git/contoso-ade-catalog-demo>
* Dev Center endpoint: <https://16b3c013-d300-468d-ac64-7eda0820b6d3-dc-contoso-platform.eastus.devcenter.azure.com>
* Project endpoint: <https://16b3c013-d300-468d-ac64-7eda0820b6d3-dc-contoso-platform.eastus.devcenter.azure.com/projects/ContosoPlatform>
* Bicep environment definition endpoint: <https://16b3c013-d300-468d-ac64-7eda0820b6d3-dc-contoso-platform.eastus.devcenter.azure.com/projects/ContosoPlatform/catalogs/github-catalog/environmentDefinitions/webapp-demo>
* Terraform environment definition endpoint (after catalog sync): <https://16b3c013-d300-468d-ac64-7eda0820b6d3-dc-contoso-platform.eastus.devcenter.azure.com/projects/ContosoPlatform/catalogs/github-catalog/environmentDefinitions/webapp-terraform-demo>

## Azure state used for this demo

* Subscription: `b6f10878-9f8a-4b3f-8bc5-3464cdd79c77`
* Resource group: `rg-contoso-ade-eastus`
* Dev Center: `dc-contoso-platform`
* Project: `ContosoPlatform`
* Catalog: `github-catalog`

## Validation status

* Catalog connectivity and sync: passed
* Environment definition discovery: passed
* Bicep compile: passes with linter warnings
* Terraform validate: passed (`terraform init -backend=false` + `terraform validate`)
* Environment create action: currently blocked by `EnvironmentActionForbidden` policy in tenant runtime path

## Quick verification commands

```powershell
./scripts/validate-demo.ps1 -SubscriptionId "b6f10878-9f8a-4b3f-8bc5-3464cdd79c77" -ResourceGroupName "rg-contoso-ade-eastus" -DevCenterName "dc-contoso-platform" -ProjectName "ContosoPlatform" -CatalogName "github-catalog"
```

```bash
az devcenter dev environment-definition list --dev-center-name dc-contoso-platform --project-name ContosoPlatform -o table
```

## Developer workflow with skills and agent hooks

1. Developer describes app intent in natural language.
2. Discovery skill in `docs/copilot-catalog-lookup.skill.md` queries live ADE catalogs and definitions.
3. Skill returns best template match plus minimal parameter set.
4. Agent hook or workflow job runs `az devcenter dev environment create` with approved parameters.
5. Developer receives environment URL and starts code deployment.

Example automation sequence:

```text
Intent -> Discovery Skill -> Template Match -> Environment Create -> App Deploy
```

## What to show in customer meetings

1. Platform team publishes one template and reuses it everywhere.
2. Developers self-service environments in minutes.
3. Governance is automatic through template controls, RBAC, and tagging.
4. Skills and agent hooks reduce manual IaC and speed onboarding.
