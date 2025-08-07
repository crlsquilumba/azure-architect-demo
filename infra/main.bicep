//define un nombre base para todos los recursos para evitar colisiones
param baseName string = 'evalproy${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

// --- 1. Key Vault para Secretos ---
// Demuestra que piensas en la seguridad desde el principio
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${baseName}-kv'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [] // Las configuraremos después
  }
}

// --- 2. App Service Plan (El servidor) ---
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${baseName}-plan'
  location: location
  sku: {
    name: 'F1' // Usa el nivel gratuito para la demo
    tier: 'Free'
  }
}

// --- 3. App Service (La API .NET) ---
resource apiAppService 'Microsoft.Web/sites@2022-09-01' = {
  name: '${baseName}-api'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v7.0' // O la versión que uses
    }
  }
}

// --- 4. Static Web App (El Frontend React) ---
resource frontendApp 'Microsoft.Web/staticSites@2022-09-01' = {
  name: '${baseName}-frontend'
  location: location
  sku: {
    name: 'Free' // Usa el nivel gratuito
    tier: 'Free'
  }
}

// --- Salidas ---
// Exporta los nombres y endpoints para que el pipeline de despliegue los use
output apiHostName string = apiAppService.properties.defaultHostName
output frontendHostName string = frontendApp.properties.defaultHostname