function Fix-RemoteMailbox {
    param ($MailUser
    )
Connect-ExchangeOnline

$GUID=Get-Mailbox $MailUser | Select-Object -ExpandProperty ExchangeGuid

Disconnect-ExchangeOnline -confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue

$RemoteAddress = "$MailUser@contoso.mail.onmicrosoft.com"

$OnMSAddress = "$MailUser@contoso.onmicrosoft.com"

$PrimarySMTP = "$MailUser@contoso.com"

Set-ADUser $MailUser -Add @{proxyAddress="smtp:"+"$RemoteAddress"}

Set-ADUser $MailUser -Add @{proxyAddress="smtp:"+"$OnMSAddress"}

Write-Output "Please wait, configuration in progress"

Start-Sleep -Seconds 30

Invoke-Command -ConfigurationName Microsoft.Exchange -ConnectionUri http://exch.contoso.com/Powershell -ScriptBlock {Enable-RemoteMailbox "$Using:MailUser" -RemoteRoutingAddress "$Using:RemoteAddress" -PrimarySmtpAddress "$Using:PrimarySMTP"} | Out-Null

Start-Sleep -Seconds 5

Invoke-Command -ConfigurationName Microsoft.Exchange -ConnectionUri http://exch.contoso.com/Powershell -ScriptBlock {Set-RemoteMailbox "$Using:MailUser" -ExchangeGuid "$Using:GUID"} | Out-Null

Start-Sleep -Seconds 5

Invoke-Command -ConfigurationName Microsoft.Exchange -ConnectionUri http://exch.contoso.com/Powershell -ScriptBlock {Get-RemoteMailbox "$Using:MailUser" | Select-Object RemoteRoutingAddress, PrimarySMTPAddress, ExchangeGuid}

Get-AdUser "$MailUser" | Set-AdObject -Replace @{msExchRecipientDisplayType=-1073741818}

Write-Output "The task is complete."
}