function Fix-RemoteMailbox {
    param ($MailUser
    )
Connect-ExchangeOnline

$GUID=Get-Mailbox $MailUser | Select-Object -ExpandProperty ExchangeGuid

Disconnect-ExchangeOnline -confirm:$false -InformationAction Ignore -ErrorAction SilentlyContinue

$RemoteAddress = "$MailUser@contoso.mail.onmicrosoft.com"

$PrimarySMTP = "$MailUser@contoso.com"

powershell.exe -NonInteractive -command  ".'D:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto -ClientApplication:ManagementShell;Enable-RemoteMailbox "$MailUser" -RemoteRoutingAddress "$RemoteAddress" -PrimarySmtpAddress "$PrimarySMTP";Set-RemoteMailbox "$MailUser" -ExchangeGuid "$GUID""

Get-AdUser "$MailUser" | Set-AdObject -Replace @{msExchRecipientDisplayType=-1073741818}

}