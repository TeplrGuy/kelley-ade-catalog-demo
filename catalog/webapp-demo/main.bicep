// ============================================================================
// Web App Demo Environment - Azure Infrastructure Template (Bicep)
// ============================================================================
// This template deploys a production-ready web application hosting platform
// with governance controls built in.
//
// Governance:
// - Managed identity for secure app authentication
// - RBAC role assignments (least privilege)
// - Comprehensive tagging (department, cost center, environment, etc.)
// - Diagnostic logging to Log Analytics workspace
// - Application Insights for monitoring
// - Optional Azure Storage Account for file storage
// ============================================================================

@minLength(3)
@maxLength(24)
@description('Name of the environment (used in resource naming)')
param environmentName string

@description('App Service Plan pricing tier')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param appServicePlanSku string = 'Basic'

@description('Web App runtime stack')
param webAppRuntime string = 'NODE|18-lts'

@description('Enable Azure Storage Account')
param enableStorage bool = true

@description('Environment type: dev, staging, or prod')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environment string = 'dev'

@description('Cost center code')
param costCenter string = 'engineering'

@description('Department name')
param department string = 'platform-engineering'

@description('Azure region for resources')
param location string = resourceGroup().location

// ============================================================================
// Variables: Naming conventions and derived values
// ============================================================================

var environmentNameSafe = replace(toLower(environmentName), ' ', '-')
var timestamp = utcNow('yyyyMMddHHmmss')
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 5)

// Resource naming with safe characters and uniqueness
var appServicePlanName = 'asp-${environmentNameSafe}-${uniqueSuffix}'
var webAppName = 'app-${environmentNameSafe}-${uniqueSuffix}'
var storageAccountName = 'st${replace(environmentNameSafe, '-', '')}${uniqueSuffix}'
var appInsightsName = 'ai-${environmentNameSafe}-${uniqueSuffix}'
var logAnalyticsWorkspaceName = 'law-${environmentNameSafe}-${uniqueSuffix}'
var managedIdentityName = 'mi-${environmentNameSafe}-${uniqueSuffix}'

// Common tags applied to all resources
var commonTags = {
  managedBy: 'azure-deployment-environments'
  environment: environment
  department: department
  costCenter: costCenter
  createdOn: timestamp
  pattern: 'webapp-demo'
  templateVersion: '1.0'
}

// App Service Plan SKU mapping
var skuMap = {
  'Basic': {
    name: 'B1'
    tier: 'Basic'
    capacity: 1
  }
  'Standard': {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  'Premium': {
    name: 'P1v2'
    tier: 'PremiumV2'
    capacity: 1
  }
}

// ============================================================================
// Resources: Log Analytics Workspace (for diagnostics)
// ============================================================================

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: commonTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// ============================================================================
// Resources: Managed Identity (for web app authentication)
// ============================================================================

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: commonTags
}

// ============================================================================
// Resources: Application Insights (for monitoring)
// ============================================================================

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    RetentionInDays: 30
  }
}

// ============================================================================
// Resources: App Service Plan
// ============================================================================

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: commonTags
  kind: 'linux'
  sku: {
    name: skuMap[appServicePlanSku].name
    tier: skuMap[appServicePlanSku].tier
    capacity: skuMap[appServicePlanSku].capacity
  }
  properties: {
    reserved: true // Required for Linux
  }
}

// ============================================================================
// Resources: Web App
// ============================================================================

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  tags: commonTags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    virtualNetworkSubnetId: null
  }
}

// ============================================================================
// Resources: Web App Configuration
// ============================================================================

resource webAppConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'web'
  parent: webApp
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'index.html'
      'index.htm'
      'default.html'
    ]
    netFrameworkVersion: 'v6.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: true
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: true
    publishingUsername: 'username'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
  }
}

// ============================================================================
// Resources: Web App Runtime Configuration
// ============================================================================

resource webAppRuntimeSettings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: webApp
  properties: {
    'APPINSIGHTS_INSTRUMENTATIONKEY': appInsights.properties.InstrumentationKey
    'ApplicationInsightsAgent_EXTENSION_VERSION': '~3'
    'XDT_MicrosoftApplicationInsights_Mode': 'recommended'
    'DiagnosticServices_EXTENSION_VERSION': '~3'
    'WEBSITE_NODE_DEFAULT_VERSION': '18-lts'
    'ENVIRONMENT': environment
    'DEPARTMENT': department
  }
}

// ============================================================================
// Resources: Web App Diagnostic Settings
// ============================================================================

resource webAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-logs-to-${logAnalyticsWorkspace.name}'
  scope: webApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// ============================================================================
// Resources: Azure Storage Account (Optional)
// ============================================================================

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = if (enableStorage) {
  name: storageAccountName
  location: location
  tags: commonTags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: false
  }
}

// ============================================================================
// Resources: Storage Account Diagnostic Settings (Optional)
// ============================================================================

resource storageAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableStorage) {
  name: 'send-logs-to-${logAnalyticsWorkspace.name}'
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// ============================================================================
// Resources: RBAC Role Assignments
// ============================================================================

// Assign the managed identity a reader role on the storage account
resource storageBlobReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableStorage) {
  scope: storageAccount
  name: guid(storageAccount.id, managedIdentity.id, 'Storage Blob Data Reader')
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1' // Storage Blob Data Reader
    )
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Assign the managed identity contributor role on the resource group
resource resourceGroupContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: guid(resourceGroup().id, managedIdentity.id, 'Contributor')
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
    )
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// Resources: Management Lock (Prevent accidental deletion)
// ============================================================================

resource webAppLock 'Microsoft.Authorization/locks@2020-05-01' = {
  scope: webApp
  name: 'resource-lock-${webAppName}'
  properties: {
    level: 'CanNotDelete'
    notes: 'Prevent accidental deletion of web app'
  }
}

// ============================================================================
// Outputs: Resource information for developers
// ============================================================================

output resourceGroupId string = resourceGroup().id
output resourceGroupName string = resourceGroup().name

output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name

output webAppId string = webApp.id
output webAppName string = webApp.name
output webAppUrl string = 'https://${webApp.properties.defaultHostName}'
output webAppHostName string = webApp.properties.defaultHostName

output managedIdentityId string = managedIdentity.id
output managedIdentityClientId string = managedIdentity.properties.clientId
output managedIdentityPrincipalId string = managedIdentity.properties.principalId

output appInsightsId string = appInsights.id
output appInsightsName string = appInsights.name
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name

output storageAccountId string = enableStorage ? storageAccount.id : ''
output storageAccountName string = enableStorage ? storageAccount.name : ''
output storageAccountUrl string = enableStorage ? 'https://${storageAccount.name}.blob.${environment().suffixes.storage}' : ''

output deploymentDate string = timestamp
output environment string = environment
output costCenter string = costCenter
output department string = department

output webAppConnectionString string = 'https://${webApp.properties.defaultHostName}'
output managedIdentityTenantId string = subscription().tenantId
