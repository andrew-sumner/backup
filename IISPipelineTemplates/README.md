# Introduction

A set reusable templates for building and deploying applicaitons with [Azure DevOps YAML pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started).

For working examples see:

* [HBL.EA.GfvCalculator](https://heartlandbank.visualstudio.com/Enterprise%20Applications/_git/HBL.EA.GfvCalculator) - Single Web App & Database
* [HBL.EA.Complain](https://heartlandbank.visualstudio.com/Enterprise%20Applications/_git/HBL.EA.Complain) - Multiple Web Apps with common database

# Approach

It is assumed that each Web Application will run under it's own application pool. When accessing a database the application pool will be assinged a service account so that database connections can use integrated security rather than storing passwords in plain text in configuration files.

Web apps are deployed in seperate jobs - so if there are multiple Web application in a solution, these will be deployed in parallel - if there are enough free agents in the agent pool. _To be confirmed if will stick with this approach - could do all deployments in sequence which may make for simpler templates._

Deployments are run on the build agent using WinRM to push to the target server. _Security will not allow Azure DevOps deployment agents to run on our production servers._

# Templates

| Name | Purpose |
| ---- | ------- |
| database-deploy.yml | Deploys a dacpac |
| database-deployreport.yml | Produces a database change report from a DacPac so database changes can be reviewed before they are applied to a database |
| iis-webapp-deploy.yml | Internal template, should not be called directly |
| dotnetcore-build.yml | Visual Studio solution, parameter defaults are set for web applications - for newer dotnet core applications |
| visualstudio-build.yml | Builds a Visual Studio solution, parameter defaults are set for web applications - for older dotnet framework applications |
| webapp-and-database-deploy.yml | Checks for database changes and requests approval to proceed if database changed detected, stops web app(s) & deploys database changes |
| webapp-deploy.yml | Deploys a Web application |

# Security

If the pipeline can scan for deprecated / vulneratble packages then all projects should be built reglarly.

The dotnet cli will do this, but it will only work for dotnet core.

https://learn.microsoft.com/en-us/nuget/concepts/security-best-practices

https://learn.microsoft.com/en-us/azure/defender-for-cloud/azure-devops-extension


# Contribute

Pull requests gratefully accepted.


# Required Project Files

##  parameters.xml
WebApp project - include only

```xml
<parameters>
  <parameter name="CsvPath" defaultValue="C:\GFVCalculator\GFV.csv">
    <parameterEntry kind="XmlFile" scope="Web.config" match="/configuration/appSettings/add[@key='CsvPath']/@value" />
  </parameter>
  <parameter name="OutputCsvPath" defaultValue="C:\GFVCalculator\">
    <parameterEntry kind="XmlFile" scope="Web.config" match="/configuration/appSettings/add[@key='OutputCsvPath']/@value" />
  </parameter>
  <parameter name="SaveCsvPath" defaultValue="C:\GFVCalculator\">
    <parameterEntry kind="XmlFile" scope="Web.config" match="/configuration/appSettings/add[@key='SaveCsvPath']/@value" />
  </parameter>
</parameters>
```

## db.publish.xml
Database project, include and PreserveNewest

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <IncludeCompositeObjects>True</IncludeCompositeObjects>
    <TargetDatabaseName>dbname</TargetDatabaseName>
    <ProfileVersionNumber>1</ProfileVersionNumber>
    <ExcludeUsers>True</ExcludeUsers>
    <ExcludeLogins>True</ExcludeLogins>
    <ExcludeDatabaseRoles>True</ExcludeDatabaseRoles>
    <BlockOnPossibleDataLoss>True</BlockOnPossibleDataLoss>
    <IgnoreColumnOrder>True</IgnoreColumnOrder>
    <ScriptDatabaseOptions>False</ScriptDatabaseOptions>
  </PropertyGroup>
</Project>
```

OR

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="Current" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <IncludeCompositeObjects>True</IncludeCompositeObjects>
    <TargetDatabaseName>EA_Staging</TargetDatabaseName>
    <ProfileVersionNumber>1</ProfileVersionNumber>
    <ExcludeUsers>True</ExcludeUsers>
    <ExcludeLogins>True</ExcludeLogins>
    <ExcludeDatabaseRoles>True</ExcludeDatabaseRoles>
    <BlockOnPossibleDataLoss>True</BlockOnPossibleDataLoss>
    <IgnoreColumnOrder>True</IgnoreColumnOrder>
    <ScriptDatabaseOptions>False</ScriptDatabaseOptions>
    <!-- Settings to allow tables, views, and sp's to be dropped -->
    <DropObjectsNotInSource>True</DropObjectsNotInSource>
    <DropExtendedPropertiesNotInSource>False</DropExtendedPropertiesNotInSource>
    <DropDmlTriggersNotInSource>False</DropDmlTriggersNotInSource>
    <DoNotDropStoredProcedures>False</DoNotDropStoredProcedures>
    <DoNotDropTables>False</DoNotDropTables>
    <DoNotDropViews>False</DoNotDropViews>
    <DoNotDropXmlSchemaCollections>True</DoNotDropXmlSchemaCollections>
    <DoNotDropUserDefinedDataTypes>True</DoNotDropUserDefinedDataTypes>
    <DoNotDropUserDefinedTableTypes>True</DoNotDropUserDefinedTableTypes>
    <DoNotDropUsers>True</DoNotDropUsers>
    <DoNotDropWorkloadClassifiers>True</DoNotDropWorkloadClassifiers>
    <DoNotDropAggregates>True</DoNotDropAggregates>
    <DoNotDropApplicationRoles>True</DoNotDropApplicationRoles>
    <DoNotDropAssemblies>True</DoNotDropAssemblies>
    <DoNotDropAsymmetricKeys>True</DoNotDropAsymmetricKeys>
    <DoNotDropAudits>True</DoNotDropAudits>
    <DoNotDropBrokerPriorities>True</DoNotDropBrokerPriorities>
    <DoNotDropCertificates>True</DoNotDropCertificates>
    <DoNotDropClrUserDefinedTypes>True</DoNotDropClrUserDefinedTypes>
    <DoNotDropColumnEncryptionKeys>True</DoNotDropColumnEncryptionKeys>
    <DoNotDropColumnMasterKeys>True</DoNotDropColumnMasterKeys>
    <DoNotDropContracts>True</DoNotDropContracts>
    <DoNotDropCredentials>True</DoNotDropCredentials>
    <DoNotDropCryptographicProviders>True</DoNotDropCryptographicProviders>
    <DoNotDropDatabaseAuditSpecifications>True</DoNotDropDatabaseAuditSpecifications>
    <DoNotDropDatabaseRoles>True</DoNotDropDatabaseRoles>
    <DoNotDropDatabaseScopedCredentials>True</DoNotDropDatabaseScopedCredentials>
    <DoNotDropDatabaseTriggers>True</DoNotDropDatabaseTriggers>
    <DoNotDropDatabaseWorkloadGroups>True</DoNotDropDatabaseWorkloadGroups>
    <DoNotDropDefaults>True</DoNotDropDefaults>
    <DoNotDropEndpoints>True</DoNotDropEndpoints>
    <DoNotDropErrorMessages>True</DoNotDropErrorMessages>
    <DoNotDropEventNotifications>True</DoNotDropEventNotifications>
    <DoNotDropEventSessions>True</DoNotDropEventSessions>
    <DoNotDropExternalDataSources>True</DoNotDropExternalDataSources>
    <DoNotDropExternalFileFormats>True</DoNotDropExternalFileFormats>
    <DoNotDropExternalStreamingJobs>True</DoNotDropExternalStreamingJobs>
    <DoNotDropExternalStreams>True</DoNotDropExternalStreams>
    <DoNotDropExternalTables>True</DoNotDropExternalTables>
    <DoNotDropFileTables>True</DoNotDropFileTables>
    <DoNotDropFilegroups>True</DoNotDropFilegroups>
    <DoNotDropFiles>True</DoNotDropFiles>
    <DoNotDropFullTextCatalogs>True</DoNotDropFullTextCatalogs>
    <DoNotDropFullTextStoplists>True</DoNotDropFullTextStoplists>
    <DoNotDropLinkedServerLogins>True</DoNotDropLinkedServerLogins>
    <DoNotDropLinkedServers>True</DoNotDropLinkedServers>
    <DoNotDropLogins>True</DoNotDropLogins>
    <DoNotDropMessageTypes>True</DoNotDropMessageTypes>
    <DoNotDropPartitionFunctions>True</DoNotDropPartitionFunctions>
    <DoNotDropPartitionSchemes>True</DoNotDropPartitionSchemes>
    <DoNotDropPermissions>True</DoNotDropPermissions>
    <DoNotDropQueues>True</DoNotDropQueues>
    <DoNotDropRemoteServiceBindings>True</DoNotDropRemoteServiceBindings>
    <DoNotDropRoleMembership>True</DoNotDropRoleMembership>
    <DoNotDropRoutes>True</DoNotDropRoutes>
    <DoNotDropRules>True</DoNotDropRules>
    <DoNotDropScalarValuedFunctions>True</DoNotDropScalarValuedFunctions>
    <DoNotDropSearchPropertyLists>True</DoNotDropSearchPropertyLists>
    <DoNotDropSecurityPolicies>True</DoNotDropSecurityPolicies>
    <DoNotDropSequences>True</DoNotDropSequences>
    <DoNotDropServerAuditSpecifications>True</DoNotDropServerAuditSpecifications>
    <DoNotDropServerRoleMembership>True</DoNotDropServerRoleMembership>
    <DoNotDropServerRoles>True</DoNotDropServerRoles>
    <DoNotDropServerTriggers>True</DoNotDropServerTriggers>
    <DoNotDropServices>True</DoNotDropServices>
    <DoNotDropSignatures>True</DoNotDropSignatures>
    <DoNotDropSymmetricKeys>True</DoNotDropSymmetricKeys>
    <DoNotDropSynonyms>True</DoNotDropSynonyms>
    <DoNotDropTableValuedFunctions>True</DoNotDropTableValuedFunctions>
  </PropertyGroup>
</Project>
```

## .gitignore
Database Project - allow publish.xml

```text
!/<project name>/*.[Pp]ublish.xml
```

## azure-pipelines.yml

```yaml
resources:
  repositories:
  - repository: templates
    type: git
    name: AzureDevOpsPipelineTemplates

parameters:
- name: blockOnPossibleDataLoss
  displayName: 'Block database changes on potential data loss?'
  type: boolean
  default: true

trigger:
  branches:
    include:
    - '*'

# Regularly confirm that builds work, packages not deprecated, etc
schedules:
- cron: "0 12 * * 0"
  displayName: Weekly Sunday build
  branches:
    include:
    - main
  always: true

name: $(date:yyyyMMdd)$(rev:.r)

pool:
  name: Enterprise Applications Build

stages:

- stage: build
  variables:
  - name: BuildSolution
    value: '**\*.sln'
  - name: BuildConfiguration
    value: 'release'
  - name: BuildPlatform
    value: 'any cpu'
  - group: Vault

  jobs:

  - template: visualstudio-build.yml@templates
    parameters:
      additionalSteps:
      - task: PublishBuildArtifacts@1
        displayName: Publish artifact 'database'
        inputs:
          PathtoPublish: 'GFV_Calculator.GFVEntitiesDB\bin\$(BuildConfiguration)'
          ArtifactName: 'database'
          publishLocation: 'Container'

- stage: dev
  variables:
  - group: dev-db-hblsql4-i1-ag1l
  - group: dev-app-vm-ham4-aentap1
  - group: Vault
  - name: ConnectionString
    value: data source=$(database_server);initial catalog=dbname;Integrated Security=True;MultipleActiveResultSets=True;App=EntityFramework

  jobs:
  - template: webapp-and-database-deploy.yml@templates
    parameters:
      environment: dev
      # Database
      dacpacFile: GFV.dacpac
      publishProfile: GFV.publish.xml
      connectionString: $(ConnectionString)
      blockOnDataLoss: ${{ parameters.BlockOnPossibleDataLoss }}
      notifyUsers: person
      # Web App
      webAppName: GfvCalculator2
      webDeployPackage: GFV_Calculator.Web.zip
      webDeployParamFile: GFV_Calculator.Web.SetParameters.xml
      webDeployOverrideParameters: |
        name="GFVEntities-Web.config Connection String",value="metadata=res://*/Entity.GfvEntity.csdl|res://*/Entity.GfvEntity.ssdl|res://*/Entity.GfvEntity.msl;provider=System.Data.SqlClient;provider connection string='$(ConnectionString)'"
      appPoolUser: service account
```
