if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

<#
    1. Check site URL.
    2. Remove TODOs.
    3. Check email settings.
#>
$siteURL = "http://spswebprod2010/sites/contracts"
$currentDate = Get-Date
$logFile = "C:\Temp\Contracts_with_deadline.txt"

Write-Host "Process started"
$currentDate > $logFile

$query = New-Object Microsoft.SharePoint.SPQuery
$query.Query = @"
<Where>
  <And>
    <And>
      <And>
        <Eq>
          <FieldRef Name="IsActive" />
          <Value Type="Boolean">1</Value>
        </Eq>
        <Eq>
          <FieldRef Name="ActiveNotification" />
          <Value Type="Boolean">1</Value>
        </Eq>
      </And>
      <IsNotNull>
        <FieldRef Name="DateEnd" />
      </IsNotNull>
    </And>
    <IsNotNull>
      <FieldRef Name="DateNotifyCount" />
    </IsNotNull>
  </And>
</Where>
<OrderBy>
  <FieldRef Name="BaseId" Ascending="True" />
  <FieldRef Name="ID" Ascending="True" />
</OrderBy>
"@
$query.ViewAttributes = "Scope='RecursiveAll'"


$web = Get-SPWeb -identity $siteURL 
$list = $web.Lists["���������"]
$listItems = $list.GetItems($query)

$listItemsCount = $listItems.Count;
Write-Host "Items: " $listItemsCount

if ($listItemsCount -lt 1) {
     break;
} 
else 
{
    [string]::Format("Items: {0}", $listItemsCount) >> $logFile

	foreach ($item in $listItems)
	{
            [string]::Format("�� ������ �������� �������������� ��� �� {0} .������� �����������...", $item["ID"]) >> $logFile

            if ($item["DateNotifyCount"] -eq $null)
            {
                [string]::Format("��� �������� ������ ����������� ��� �� {0}", $item["ID"]) >> $logFile
                continue
            }
                        

            $endDate = Get-Date -Date $item["DateEnd"]
            $difference = New-TimeSpan -Start $currentDate -End $endDate
            $realDiff = $difference.Days + 1
            $notificationDays = $item["DateNotifyCount"]
            
            Write-Host "������� �� ������:" $realDiff
            [string]::Format("������� �� ������: {0}", $realDiff) >> $logFile
            Write-Host "������ �����������:" $notificationDays
            [string]::Format("������ �����������: {0}", $notificationDays) >> $logFile

            if ($endDate.Date -ge $currentDate.Date -and ($realDiff -le $notificationDays))
            {
                if ($item["NotificationPersons"] -eq $null)
                {
                    [string]::Format("** ��� �������� ������� ����������� ��� �� item: {0}", $item["ID"]) >> $logFile
                }
                else 
                {
                    $emails = @() 
                    foreach($peopleItem in $item["NotificationPersons"]) {
                        $emails += $peopleItem.User.Email
                    }
					$emails +="serafeim.kroustallis@alpha.gr"

                    $emailList = [string]::Join(",", $emails)
                    [string]::Format("Emails: {0}", $emailList) >> $logFile
                    
                    $supplier = ""
                    if ($item["Supplier"] -ne $null) {
                        $supplier = $item["Supplier"].Split("#")[1];
                    }
                    
                    try
                    {
                        Write-Host "�������� email ��� �� item" $item["ID"]
                        [string]::Format("�������� email ��� �� item: {0}", $item["ID"]) >> $logFile

                        $symvasiURL = [String]::Format("{0}/Lists/SymvaseisNew/Item/displayifs.aspx?List=60107ad2-D8f96-D430c-Dae01-D5b4ef09ddd21&ID={1}&Source={0}/Lists/SymvaseisNew/Custom3.aspx&ContentTypeId=0x010076FE1E8038482F408713009609D0E723", $siteURL, $item["ID"])
                        $linkToSymvasi = [String]::Format("<a href={0}>{1}</a>", $symvasiURL, $item["Title"])

                        $SMTPServer = "10.29.23.50"
                        $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer)

                        $SMTPMessage = new-object Net.Mail.MailMessage
                        $SMTPMessage.IsBodyHtml = $true
                        $SMTPMessage.From = "SPS_notifications@alpha.gr"
                        $SMTPMessage.To.Add([String]::Format("{0}", $emailList)) # "serafeim.kroustallis@alpha.gr,panagiota.mavrogianni@alpha.gr"
                        $SMTPMessage.Subject = [String]::Format("���������� ��� �� �������(NEW): {0}", $item["MyId"]) # kwdikos 
                        $SMTPMessage.Body = [String]::Format("<b>����������</b></br></br>� ������� ��� <b>����������</b> {0} �� �� <b>����������� ���������</b> {1}, <b>������ ���������</b> {2} ��� <b>������ ��������� SAP</b> {3} ����������� �������� � ����� ��� <b>����������</b> {4} </br></br> ����������� ��� ��� ��������� ���.", $supplier, $linkToSymvasi, $item["MyId"], $item["ContractCodeSAP"], $item["DateEnd"].ToShortDateString())
                
                        $SMTPClient.Send($SMTPMessage)
                        Write-Host "�������� email ��� �� item" $item["ID"] "������������"
                        [string]::Format("�������� email ��� �� item: {0} ������������", $item["ID"]) >> $logFile
                        
                    }
                    catch [Exception]
                    {
                        [string]::Format("����� ���� ��� �������� email ��� �� item: {0}, Error: {1} ", $item["ID"], $_.Exception.Message) >> $logFile
                    }
                }
		    }
    }
}

$web.Dispose();
Write-Host "Process finished"
