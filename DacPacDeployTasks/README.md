# DacPac Schema Compare & Publish Azure DevOps Extension

This DacPac task supports the DeployReport, Script, & Publish actions of SqlPackage.exe.

It is based on <https://github.com/microsoft/azure-pipelines-tasks/blob/master/Tasks/SqlDacpacDeploymentOnMachineGroupV0>.

## Requirements

SqlPackage must be installed on the server the deployment machine (azure devops agent) this task is running on.

This can be downloaded from <https://learn.microsoft.com/en-us/sql/tools/sqlpackage/sqlpackage-download?view=sql-server-ver15>.

## Parameters

The task parameters listed with a \* are required parameters for the task:

This section of the task is used to deploy SQL Server Database to an existing SQL Server using sqlpackage.exe.

- **Action\*:** Action to perform: DeployReport, Script, or Publish
- **DACPAC File\*:** Location of the DACPAC file on the agent or on a UNC path that is accessible to the credentials of the job like
- **Publish Profile:** Publish profile provide fine-grained control over SQL Server database creation or upgrades. Specify the path to the Publish profile XML file on the target machine or on a UNC share that is accessible by the machine administrator's credentials.
- **BlockOnDataLoss:** Block database changes on possible data loss, defaults to true.
- **Connection String\*:** Specify the SQL Server connection string like "Server=localhost;Database=Fabrikam;User ID=sqluser;Password=password;".
- **Authentication\*:** Select the authentication mode for connecting to the SQL Server. If the Windows authentication mode is selected, the agents's account will be used to connect to the SQL Server unless overridden by RunAs parameters. If the SQL Server Authentication mode is selected, then the SQL login and Password have to be provided in the parameters below.
- **SQL Username** : Provide the SQL Server login. The option is required and only available if SQL Server Authentication mode is selected.
- **SQL Password:** The password for the SQL Server login. The option is required and only available if SQL Server Authentication mode is selected.
- **RunAs User name** : Provide the SQL Server Windows login.
- **RunAs Password:** The password for the Windows login.
- **Output Path\*:** The path to publish reports to.
- **Additional SqlPackage.exe Arguments:** Additional SqlPackage.exe arguments that will be applied when creating or updating the SQL Server database like:

  /p:IgnoreAnsiNulls=True /p:IgnoreComments=True

  These arguments will override the settings in the Publish profile XML file (if provided). A full list of the arguments that can provided is listed in the ' **Properties**' sub-section of the ' **Publish Parameters, Properties, and SQLCMD Variables**' in the [SqlPackage.exe](https://msdn.microsoft.com/en-us/library/hh550080\(v=vs.103\).aspx) documentation. The SQLCMD variables can be also specified here. This is an optional parameter.

## Extension Development

You will need to install the following components in your development environment:

- Install [Node.js](https://nodejs.org)

    Check existing version using `node -v`, current version is v18.12.1 LTS, (upgraded HAMAPPDEV04 from v12.22.12)

- Install the extension packaging tool (TSF Cross-Platform Command-Line Interface) by running:

    ```cmd
    npm config set proxy http://webproxy.pgc.co.nz:8080
    npm config set https-proxy http://webproxy.pgc.co.nz:8080
    npm config set noproxy .pgc.co.nz
    npm config set strict-ssl false

    npm install -g tfx-cli
    ```

- Install the VstsTaskSdk module by running `Install-Module -Name VstsTaskSdk -AllowClobber`

    Move the generated files up one level as the files are placed in a sub folder with containing the version number, i.e. the files should be in ps_modules\VstsTaskSdk.

    To install modules you may need to configure a few things first

    1. Enable proxy in Windows - this is getting disabled via GPO every hour or so

    2. Check proxy in PowerShell

        ```powershell
        netsh winhttp show proxy

        Current WinHTTP proxy settings:

            Direct access (no proxy server).
        ```

    3. Set proxy in PowerShell

        ```powershell
        netsh winhttp import proxy source=ie
        ```

    4. Check SecurityProtocol - should be Tls12

        ```powershell
        [Net.ServicePointManager]::SecurityProtocol
        Ssl3, Tls

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        ```

### ps_modules folder

Was populated using command `Save-Module -Name VstsTaskSdk -Path .\ps_modules -Force`

### Publish the Extension - Cloud

<https://learn.microsoft.com/en-us/azure/devops/extend/publish/overview?toc=%2Fazure%2Fdevops%2Fmarketplace-extensibility%2Ftoc.json&view=azure-devops>

1. `npx tfx-cli extension create`
2. Open <https://marketplace.visualstudio.com/manage/publishers/publishername>
3. Upload file Westpac.DacpacDeploymentTasks-0.1.0.vsix
4. Ensure it's shared with organisation
5. Extension should show up under <https://organisation.visualstudio.com/_settings/extensions?tab=shared>
    1. Select "Marketplace"
    2. Select "Get it free"
    3. Someone with rights needs to install it in the organisation

### Publish the Extension - OnPremise

1. `npx tfx-cli extension create`
2. Open <https://tfs.westpac.co.nz/_gallery/manage>
3. Click 'Upload extension' button and choose the vsix file created in step 1
4. Find the extension in the list, select it, install to collection

### More Info

- <https://codingsight.medium.com/developing-azure-devops-extension-a4d354756815>
- <https://www.andrewhoefling.com/Blog/Post/dev-ops-vsts-custom-build-task-extension>
- <https://github.com/microsoft/azure-pipelines-tasks/blob/master/Tasks/AzurePowerShellV5/task.json#L100>
- <https://github.com/microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/README.md>
