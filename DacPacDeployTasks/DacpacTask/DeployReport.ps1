function Convert-ConnectionString
{
    param (
    [string]$connectionString,
    [System.Management.Automation.PSCredential]$sqlServerCredentials
    )

    $sqlUsername = $sqlServerCredentials.UserName
    $sqlPassword = $sqlServerCredentials.GetNetworkCredential().password

    $ht = @{ }
    $connectionString -split ';' | %{ $s = $_ -split '='; $ht.Add($s[0],  $s[1]) }

    $ht.Remove('Integrated Security')
    $ht.Remove('App')
    $ht.Remove('User Id')
    $ht.Remove('Password')
    $ht.Add('User Id', $sqlUsername)
    $ht.Add('Password', $sqlPassword)

    $output = ''

    ForEach ($item in $ht.GetEnumerator()) {
        $output += "$($item.Name)=$($item.Value);"
    }

    return $output
}

function Format-XML ([xml]$xml, $indent=2) {
    $stringWriter = New-Object System.IO.StringWriter

    $xmlWriterSettings = New-Object System.Xml.XmlWriterSettings
    $xmlWriterSettings.Indent = $true
    $xmlWriterSettings.IndentChars = " "
    $xmlWriterSettings.NewLineChars = "`n"

    $xmlWriter = [System.XML.XmlWriter]::Create($StringWriter, $xmlWriterSettings)

    $xml.WriteContentTo($xmlWriter)
    $xmlWriter.Flush()
    $stringWriter.Flush()
    Write-Output $stringWriter.ToString() 
}
