# Azure Devops YAML Pipeline Templates

## Introduction

Templates for use within Azure Devops YAML pipelines.

NOTE: Only supporting dotnetcore as we need to move from Azure Function V1 to V4.

| Template                              | Type  | Purpose |
|---------------------------------------|-------|---------|
| stage-azure-function-build.yml        | Stage | Builds dotnetcore function app and associated terraform |
| stage-azure-function-deploy.yml       | Stage | Applies terraform and deploys function app |
| stage-terraform-apply.yml             | Stage | Run terraform apply |
| stage-terraform-approve-and-apply.yml | Stage | Applies terraform, but has an extra step for approval of the teraform plan - is for use for infrastructure level deployments where risk of breaking an envrionment is higher than for example, deploying a single azure function app |
| <span style="white-space: nowrap;">stage-terraform-arm-template-build.yml</span> | Stage | Build terraform and include ARM template |
| stage-terraform-backend-bootstrap.yml | Stage | Creates storage account in an Azure Subscription for Terraform's backend state |
| dotnetcore-build.yml                  | Step  | Builds a dotnet core application |
| proxy-configure.yml                   | Step  | Set proxy environment variables targetting bluecoat proxy |
| proxy-unconfigure.yml                 | Step  | Remove proxy environment variables |
| release-annotation.yml                | Step  | Creates a release annotation in app insights |
| terraform-apply.yml                   | Step  | Applies a terraform template |
| terraform-build.yml                   | Step  | Pulls down modules in build stage, so that not impacted by changes in the modules in the release stage |

## Getting Started

See <https://tfs.westpac.co.nz/WestpacCollection/ICE/_git/WNZL.RBAC> for an working example of a function app.

Add this near the top of your yaml pipeline, typically I add it after the trigger:

```yaml
resources:
  repositories:
  - repository: templates
    name: DevOpsTools/PipelineTemplates
    type: git
    ref: main
    # ref: refs/tags/v1.0 # pin to tag
    # ref: rename # pin to branch 
```

Call the desired template, for example to configure the proxy add this step:

```yaml
- template: proxy-configure.yml@templates
```

YAML pipelines behave differently to classic build and release pipelines, for example:

1. A service connection name cannot be specified in a variable (e.g. in a variable group), these values must be hard coded in the base pipeline
2. There is no concept of a manual deployment, a release will run all stages and automatically deploy to production. See Approval Gates for a workaround
3. Ensure "Project Settings > Settings > Limit job authorization scope to referenced Azure DevOps repositories" is off otherwise your pipeline (terraform init step) will have no access to to Azure Devops based modules

## Approval Gates

### Environment

To avoid YAML pipelines automatically deploying into an environment, nagivate to `Pipelines > Envrionments > 'Your Environment' > Approvals and checks (menu item)` and add an approval check. I recommend setting this to a short interval like 5-10 minutes to avoid having multiple releases with active approvals on the go at any one time.

![Approvals](/docs/approvals.png =400x)

Your pipeline will now show a "Retry Stage" button where you can deploy the stage.

![Retry](/docs/retry.png =650x)

Note that completed stages can be re-run by hovering the mouse over the completed stage and selected the "Expand stage" button that appears in the to right corner and then clicking on the "Rerun stage" button.

### Notifications

If you're allowing the entire team (as in image above) you might want to consider turning of approval notifications to avoid spamming people.

Navigate to `Projects Settings > Notifications` and turn approval notifications off.

![Notifications](/docs/notifications.png =800x)

## Contribute

Contact (Email) The_IT_Crowd@westpac.co.nz.
