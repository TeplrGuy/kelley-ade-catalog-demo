---
title: Web App Demo Environment - Catalog Documentation
description: Production-ready web application environment template for Azure Deployment Environments
---

# Web App Demo Environment

A production-ready, governed infrastructure template for deploying scalable web applications on Azure. This environment is designed to be self-serviced by application teams while maintaining enterprise governance and compliance standards.

## Overview

This environment definition deploys a complete web application hosting platform on Azure App Service with:

- ✅ **App Service Plan** – Scalable compute for web hosting
- ✅ **Web App** – Your application runtime (Node.js, .NET, Python)
- ✅ **Managed Identity** – Secure, passwordless authentication
- ✅ **Application Insights** – Built-in monitoring and diagnostics
- ✅ **Azure Storage Account** (optional) – File and blob storage
- ✅ **Compliance Governance** – Automatic tagging, RBAC, audit logging

## Use Cases

This environment is ideal for:

- **Web Applications** – Traditional web apps, single-page applications (SPAs), static sites
- **API Backends** – RESTful APIs, GraphQL endpoints running on App Service
- **Dev/Test/Staging** – Development and pre-production environments
- **Production Workloads** – With scale-up to Standard or Premium SKUs
- **Quick Prototypes** – Spin up a web app in minutes for proof-of-concept work

## Parameters

When deploying this environment, you'll customize these parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `environmentName` | string | `webapp` | Logical name for this environment (used in resource naming) |
| `appServicePlanSku` | enum | `Basic` | App Service Plan pricing tier: `Basic`, `Standard`, or `Premium` |
| `webAppRuntime` | enum | `NODE\|18-lts` | Runtime stack: `NODE\|18-lts`, `DOTNETCORE\|7.0`, or `PYTHON\|3.11` |
| `enableStorage` | boolean | `true` | Provision an Azure Storage Account for file storage |
| `environment` | enum | `dev` | Environment type: `dev`, `staging`, or `prod` |
| `costCenter` | string | `engineering` | Cost center code for billing and chargebacks |
| `department` | string | `platform-engineering` | Department name for resource tagging |

## What Gets Deployed

### Core Infrastructure

```
Resource Group
├── App Service Plan (basic compute layer)
├── Web App (your application runtime)
├── Managed Identity (for app authentication)
├── Application Insights (monitoring)
├── Log Analytics Workspace (centralized logging)
└── Azure Storage Account (optional, for file storage)
```

### Governance Built In

- **Tags** – All resources automatically tagged with department, cost center, environment, and creation date
- **Managed Identity** – Every web app gets its own identity for secure authentication to Azure services
- **RBAC Roles** – Minimum necessary permissions assigned:
  - Web App can read from Storage Account
  - Web App can access Resource Group
- **Diagnostic Logging** – All logs flow to Log Analytics workspace for centralized audit and compliance
- **Resource Locks** – Web app has a "cannot delete" lock to prevent accidental removal
- **HTTPS Only** – Web apps enforce HTTPS; HTTP is redirected

## Cost Estimates

### Development Environment (Basic SKU)

| Resource | Monthly Cost | Notes |
|----------|-------------|-------|
| App Service Plan (B1) | ~$15 | Shared compute, suitable for dev |
| Storage Account | $1–5 | Depends on usage |
| Application Insights | ~$0 | Free tier up to 5 GB ingestion |
| Log Analytics | ~$0 | Free tier for initial retention |
| **Total** | **~$15–20** | |

### Production Environment (Standard SKU)

| Resource | Monthly Cost | Notes |
|----------|-------------|-------|
| App Service Plan (S1) | ~$65 | Dedicated compute, autoscale support |
| Storage Account | $5–20 | Depends on usage |
| Application Insights | $0–50+ | Depends on ingestion volume |
| Log Analytics | $30–100+ | Depends on data retention |
| **Total** | **~$100–235** | |

**Note:** Actual costs depend on traffic, storage usage, and data retention settings. See [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for precise estimates.

## Deployment

### Via Azure Developer Portal (Recommended for App Teams)

1. Go to **Azure Developer Portal**
2. Select **Create Environment**
3. Choose **Web App Demo Environment**
4. Fill in the parameters
5. Review and **Create**
6. Wait 2–5 minutes for deployment
7. Copy the web app URL and open it in a browser

### Via Azure CLI (For Platform Team or Testing)

```bash
# Set variables
RESOURCE_GROUP="rg-webapp-demo"
ENVIRONMENT_NAME="myapp"
LOCATION="eastus"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Deploy template
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file main.bicep \
  --parameters \
    environmentName=$ENVIRONMENT_NAME \
    appServicePlanSku="Basic" \
    webAppRuntime="NODE|18-lts" \
    enableStorage=true \
    environment="dev" \
    costCenter="engineering" \
    department="platform-engineering" \
    location=$LOCATION
```

### Via Terraform (For IaC Enthusiasts)

This Bicep template can be wrapped in Terraform. Contact your platform team for the Terraform module.

## Deployment Outputs

After successful deployment, you'll receive:

| Output | Example | Use Case |
|--------|---------|----------|
| `webAppUrl` | `https://app-myapp-abc12.azurewebsites.net` | Access your application |
| `webAppName` | `app-myapp-abc12` | Reference in scripts or pipelines |
| `appInsightsInstrumentationKey` | `12345678-...` | Configure monitoring in your app |
| `managedIdentityClientId` | `87654321-...` | Use for token exchange (passwordless auth) |
| `storageAccountUrl` | `https://stmyappabc12.blob.core.windows.net` | Access storage from your app |

## Post-Deployment: Next Steps

### 1. Deploy Your Application Code

```bash
# Option A: Git deployment
az webapp deployment source config-zip \
  --resource-group <rg> \
  --name <app-name> \
  --src app.zip

# Option B: GitHub Actions
# Use the publish profile from the web app
# Add it to your GitHub repo as a secret
# Create a .github/workflows/deploy.yml file
```

### 2. Configure Application Settings

```bash
# Set environment variables for your app
az webapp config appsettings set \
  --resource-group <rg> \
  --name <app-name> \
  --settings \
    DATABASE_URL="..." \
    API_KEY="..." \
    NODE_ENV="production"
```

### 3. Enable Managed Identity Authentication

If your app needs to authenticate to other Azure services (Storage, Database, Key Vault):

```bash
# Get the managed identity client ID from deployment outputs
# Use it in your app with MSAL or Azure SDK

# Example: Get a token for Storage
curl -X GET "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2017-09-01&resource=https://storage.azure.com/" \
  -H "Metadata:true"
```

### 4. Set Up CI/CD

Use Azure Pipelines or GitHub Actions to automatically deploy when you push code:

```yaml
# Example GitHub Actions workflow
name: Deploy Web App

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - uses: azure/appservice-build-deploy-action@v1
        with:
          app-name: '<app-name>'
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
```

## Monitoring & Troubleshooting

### View Logs

```bash
# Stream real-time logs
az webapp log tail \
  --resource-group <rg> \
  --name <app-name>

# Query Application Insights
az monitor app-insights metrics show \
  --resource-group <rg> \
  --app <app-name> \
  --metric requests/count
```

### Diagnose Issues

**Web app is not responding:**

1. Check Application Insights for errors
2. Review web app logs: `az webapp log tail ...`
3. Verify managed identity has correct roles
4. Check Storage connectivity (if used)

**High latency or CPU:**

1. Monitor Application Insights performance metrics
2. Check App Service Plan capacity (consider upgrading SKU)
3. Review code for inefficient queries or loops

**Storage access denied:**

1. Verify managed identity is assigned `Storage Blob Data Reader` role
2. Check Storage account firewall settings
3. Ensure Storage account allows access from your virtual network (if applicable)

## Governance & Compliance

This environment template enforces:

### ✅ Tagging Compliance

Every resource is tagged:

```
managedBy: azure-deployment-environments
environment: dev|staging|prod
department: <your-department>
costCenter: <cost-center-code>
createdOn: <deployment-date>
pattern: webapp-demo
templateVersion: 1.0
```

### ✅ RBAC Governance

Managed identity has minimum necessary permissions:

- **Storage Account:** `Storage Blob Data Reader` (read-only)
- **Resource Group:** `Contributor` (manage resources)

### ✅ Audit Logging

All activities logged to Log Analytics:

- HTTP requests and responses
- Diagnostic logs from the web app
- Storage account access logs

### ✅ Security Defaults

- HTTPS enforced (HTTP redirects to HTTPS)
- TLS 1.2 minimum
- Blob public access disabled
- Default to OAuth authentication

## Limitations & Considerations

| Limitation | Workaround |
|-----------|-----------|
| App Service doesn't support custom domains out of box | Add custom domain in App Service settings + DNS CNAME |
| Basic SKU has limited scale | Upgrade to Standard or Premium for autoscaling |
| No built-in database | Provision Azure Database separately and connect via connection string |
| No VNet integration by default | Add VNet integration in app settings if needed |
| Shared compute in Basic SKU | Consider Standard for production workloads |

## FAQ

**Q: Can I use this for production?**

A: Yes, with caveats. Basic SKU is suitable for low-traffic dev/test. For production, upgrade to Standard or Premium SKU.

**Q: How do I connect to a database?**

A: Add the database connection string as an application setting: `az webapp config appsettings set --settings DATABASE_URL="..."`

**Q: Can I scale the web app automatically?**

A: Yes, with Standard and Premium SKUs. Enable autoscale in App Service Plan settings.

**Q: How do I add a custom domain?**

A: Use Azure DNS or your domain registrar to create a CNAME pointing to `<app-name>.azurewebsites.net`. Then bind it in App Service.

**Q: What if I need more storage or computing?**

A: Use the resource outputs to provision additional Azure services (Database, Cache, Storage) and connect them via connection strings.

## Support & Feedback

For questions or issues:

1. **Review this document** – Check the FAQ and Troubleshooting sections
2. **Check Application Insights** – Look for error details and diagnostics
3. **Contact your platform team** – They own the catalog and can help troubleshoot
4. **Review logs in Log Analytics** – Query `AppServiceHTTPLogs` or `AppServiceConsoleLogs`

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | June 3, 2026 | Initial release |

---

**Maintained by:** Platform Engineering Team  
**Last Updated:** June 3, 2026  
**Catalog:** https://github.com/TeplrGuy/ade-catalog-demo
