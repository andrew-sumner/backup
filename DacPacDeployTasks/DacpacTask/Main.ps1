Trace-VstsEnteringInvocation $MyInvocation 
Import-VstsLocStrings "$PSScriptRoot\Task.json"

function Write-Exception {
    param (
        $exception
    )

    $errorRecord = $PSItem
    try {
        if ($exception.Message) {
            Write-Error ($exception.Message)
        }
        else {
            Write-Error ($exception)
        }
    }
    catch {
        if ($_ -ne $null) {
            Write-Verbose "Write-Exception error:"
            Write-Verbose $_.ToString()
        }
    }

    throw $errorRecord
}

function Get-SingleFile {
    param (
        [string]$pattern
    )

    Write-Verbose "Finding files with pattern $pattern"
    $files = Find-VstsFiles -LegacyPattern "$pattern"
    Write-Verbose "Matched files = $files"

    if ($files -is [system.array]) {
        throw (Get-VstsLocString -Key "Foundmorethanonefiletodeploywithsearchpattern0Therecanbeonlyone" -ArgumentList $pattern)
    }
    else {
        if (!$files) {
            throw (Get-VstsLocString -Key "Nofileswerefoundtodeploywithsearchpattern0" -ArgumentList $pattern)
        }
        return $files
    }
}

function Get-Path ([string]$fullpath, [string]$filename) {
    $path = [System.IO.Path]::GetDirectoryName($fullpath)
    if ($path) {
        $filename = "$path\$filename"
    }

    return $filename
}

$action = Get-VstsInput -Name "Action" -Require
$dacpacFile = Get-VstsInput -Name "DacpacFile" -Require
$publishProfile = Get-VstsInput -Name "PublishProfile"
$connectionString = Get-VstsInput -Name "ConnectionString" -Require
$authscheme = Get-VstsInput -Name "AuthScheme" -Require
$sqlUsername = Get-VstsInput -Name "SqlUsername"
$sqlPassword = Get-VstsInput -Name "SqlPassword"
$runAsUsername = Get-VstsInput -Name "RunAsUsername"
$runAsPassword = Get-VstsInput -Name "RunAsPassword"
$blockOnDataLoss = Get-VstsInput -Name "BlockOnDataLoss" -AsBool -Default $true
$additionalArguments = Get-VstsInput -Name "AdditionalArguments"
$outputPath = Get-VstsInput -Name "OutputPath" -Require

Import-Module ".\SqlPackageOnTargetMachines.ps1" -Force 
Import-Module ".\DeployReport.ps1" -Force

# Telemetry for SQL Dacpac deployment on machine group #$encodedServerName = GetSHA256String($serverName) #$encodedDatabaseName = GetSHA256String($databaseName) #$telemetryJsonContent = -join("{`"serverName`": `"$encodedServerName`",",
#                              "`"databaseName`": `"$encodedDatabaseName`"}")
#Write-Host "##vso[telemetry.publish area=SqlDacpacDeploymentOnMachineGroup;feature=SqlDacpacDeploymentOnMachineGroup]$telemetryJsonContent"

Try {
    if ($authscheme -eq "sqlServerAuthentication") {
        $secureAdminPassword = "$sqlPassword" | ConvertTo-SecureString  -AsPlainText -Force
        $sqlServerCredentials = New-Object System.Management.Automation.PSCredential ("$sqlUserName", $secureAdminPassword)

        $connectionString = Convert-ConnectionString -connectionString $connectionString -sqlServerCredentials $sqlServerCredentials
    }

    $dacpacFile = Get-SingleFile -pattern $dacpacFile
    $sqlPackage = Get-SqlPackageOnTargetMachine
    $sqlPackageArguments = Get-SqlPackageCmdArgs -action $action -dacpacFile $dacpacFile -publishProfile $publishProfile -connectionString $connectionString -blockOnDataLoss $blockOnDataLoss -additionalArguments $additionalArguments -outputPath $outputPath

    #Write-Verbose -Verbose $sqlPackageArguments

    if ($authscheme -eq "windowsAuthenticationRunAs") {
        $password   = ConvertTo-SecureString -String $runAsPassword -AsPlainText -Force
        $credential = New-Object -Type PSCredential($runAsUsername,$password)

        Write-Host ("Executing Command -FileName ""$sqlPackage"" -Arguments $sqlPackageArguments as $runAsUsername") -Verbose

        $job = Start-Job -ScriptBlock {
            param ($sqlPackage, $sqlPackageArguments)
            Import-Module ".\SqlPackageOnTargetMachines.ps1"
            ExecuteCommand -FileName "$sqlPackage" -Arguments $sqlPackageArguments
        } -Credential $credential -Init ([ScriptBlock]::Create("Set-Location '$PSScriptRoot'")) -ArgumentList "$sqlPackage", "$sqlPackageArguments"
        Receive-Job -Job $job -Wait
    } else {
        if ($authscheme -eq "windowsAuthentication") {
            Write-Host ("Running ExecuteCommand -FileName ""$sqlPackage"" -Arguments $sqlPackageArguments as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)") -Verbose
        } else {
            Write-Host ("Running ExecuteCommand -FileName ""$sqlPackage"" -Arguments $sqlPackageArguments") -Verbose
        }

        Write-Verbose("Executing Command -FileName ""$sqlPackage"" -Arguments $sqlPackageArguments") -Verbose
        ExecuteCommand -FileName "$sqlPackage" -Arguments $sqlPackageArguments
    }

    switch ($action) {
        'Script' {
            [string[]]$report = Get-Content $outputPath
            Write-Output $report

            # Add output to summary page
            # $markdown = Get-Path $outputPath "Script.md"
            # '```sql' | Out-File $markdown -Encoding utf8
            # $report | Out-File $markdown -Append -Encoding utf8
            # '```' | Out-File $markdown -Append -Encoding utf8

            # try {
            #     Write-Host "Uploading Script '$markdown' to task summary page"
            #     Write-Host "##vso[task.uploadsummary]$markdown" -Verbose
            # }
            # catch {
            #     Write-Output $_.Exception
            # }
        }
        'DeployReport' {
            [xml]$report = Get-Content $outputPath

            [string[]]$fmtReport = Format-XML $report -indent 4
            $fmtReport | Write-Output

            # Add output to summary page
            # $markdown = Get-Path $outputPath "DeployReport.md"
            # '```xml' | Out-File $markdown -Encoding utf8
            # $fmtReport | Out-File $markdown -Append -Encoding utf8
            # '```' | Out-File $markdown -Append -Encoding utf8

            # Write-Host "Uploading DeployReport '$markdown' to task summary page"
            # Write-Host "##vso[task.uploadsummary]$markdown" -Verbose

            Write-Host "Setting variable DBChangesDetected = $($report.SelectNodes("//*[local-name()='Operations']").Count -gt 0)"
            Write-Host "##vso[task.setvariable variable=DBChangesDetected;isOutput=true]$($report.SelectNodes("//*[local-name()='Operations']").Count -gt 0)"

            Write-Host "Setting variable DBDataLossChangesDetected = $($report.SelectNodes("//*[local-name()='Alert']").Count -gt 0)"
            Write-Host "##vso[task.setvariable variable=DBDataLossChangesDetected;isOutput=true]$($report.SelectNodes("//*[local-name()='Alert']").Count -gt 0)"
        }
        'Publish' {
            [xml]$report = Get-Content $outputPath
            Format-XML $report -indent 4 | Write-Verbose -Verbose

            [string[]]$report = Get-Content (Replace-LastSubstring "$outputPath" .xml .sql)
            Write-Output $report.Replace('`n', '`r`n')
        }
        Default {
            throw "$action not supported"
        }
    }
}
Catch [System.Management.Automation.CommandNotFoundException] {
    Write-Exception($_.Exception)
}
Catch [Exception] {
    Write-Exception($_.Exception)
}
