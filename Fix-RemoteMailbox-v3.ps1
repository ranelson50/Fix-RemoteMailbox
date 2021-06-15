function Fix-RemoteMailbox {
    param (
        [Parameter(Mandatory=$true)]
        [String[]]
        $Users
    )
    $script:UserTable=@()
    
    # This function is verified to work up to the point of printing the user table gathered from Exchange Online, proceed at your own risk
    # after this point

    Connect-ExchangeOnline
        foreach ($Entry in $Users) {
            $Name=Get-Mailbox $Entry | Select-Object -ExpandProperty alias
            $Routing="$Entry@contoso.mail.onmicrosoft.com"
            $Primary="$Entry@contoso.com"
            $Guid=Get-Mailbox $Entry | Select-Object -ExpandProperty ExchangeGuid    
            $EntryValues=New-Object PSObject -Property @{
                Name= $Name
                RemoteRoutingAddress= $Routing
                PrimarySMTPAddress= $Primary
                ExchangeGuid= $Guid
            }
        $script:UserTable+=$EntryValues
        }
    Disconnect-ExchangeOnline -confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue
    
    $script:UserTable

    $script:UserTable | ForEach-Object -Process {Invoke-Command -ConfigurationName Microsoft.Exchange -ConnectionUri http://exch.contoso.com/Powershell -ScriptBlock {Enable-RemoteMailbox $Using:_.Name -RemoteRoutingAddress $Using:_.RemoteRoutingAddress -PrimarySmtpAddress $Using:_.PrimarySMTPAddress} | Out-Null;
        Start-Sleep -Seconds 5;
        Invoke-Command -ConfigurationName Microsoft.Exchange -ConnectionUri http://exch.contoso.com/Powershell -ScriptBlock {Set-RemoteMailbox $Using:_.Name -ExchangeGuid $Using:_.ExchangeGuid} | Out-Null;
        Start-Sleep -Seconds 5;
        Invoke-Command -ConfigurationName Microsoft.Exchange -ConnectionUri http://exch.contoso.com/Powershell -ScriptBlock {Get-RemoteMailbox $Using:_.Name | Select-Object RemoteRoutingAddress, PrimarySMTPAddress, ExchangeGuid}
        }
}