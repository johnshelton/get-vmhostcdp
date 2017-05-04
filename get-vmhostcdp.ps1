<#
=======================================================================================
File Name: get-vmhostcdp.ps1
Created on: 
Created with VSCode
Version 1.0
Last Updated: 
Last Updated by: John Shelton | c: 260-410-1200 | e: john.shelton@lucky13solutions.com

Purpose: Collect the CDP Information from all VMHosts by VCenter Server

Notes: 

Change Log:


=======================================================================================
#>
#
# Define Parameter(s)
#
param (
  [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
  [string] $VCenterServer = $(throw "-VCenterServer is required.")
)
#
# Define Output Variable
$CDPInfo = @()
#
# Load VMWare PSSnapin
#
Add-PSSnapin VMWare.VimAutomation.Core
#
connect-viserver $VCenterServer
#
$VMHosts = Get-VMHost | Where-Object {$_.ConnectionState -eq "Connected"}
#
#
# Define Output Variables
#
$ExecutionStamp = Get-Date -Format yyyyMMdd_hh-mm-ss
$path = "c:\temp\"
$FilenamePrepend = 'temp_'
$FullFilename = "get-vmhostcdp.ps1"
$FileName = $FullFilename.Substring(0, $FullFilename.LastIndexOf('.'))
$FileExt = '.csv'
$OutputFile = $path + $FilenamePrePend + '_' + $FileName + '_' + $ExecutionStamp + $FileExt
#
$PathExists = Test-Path $path
IF($PathExists -eq $False)
  {
  New-Item -Path $path -ItemType  Directory
  }
<#
ForEach ($VMHost in $VMHosts){
  $HostNetworkSystem = Get-View $VMHost.ConfigManager.NetworkSystem
  ForEach ($PhysNIC in $HostNetworkSystem.NetworkInfo.PNic){
    $PNicInfo = $PhysNIC.QueryNetworkHing($PhysNIC.Device)
    ForEach ($NICCDPInfo in $PNicInfo){
      Write-Host $VMHost $PhysNIC.Device
      if($NICCDPInfo.ConnectedSwitchPort) {
        $NICCDPInfo.ConnectedSwitchPort
      }
      else {
        Write-Host "No CDP Information Availalbe."; Write-Host
      }
    }
  }
}
#>
Get-VMHost | Where-Object {$_.ConnectionState -eq "Connected"} |
%{Get-View $_.ID} |
%{$esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem} |
%{ foreach($physnic in $_.NetworkInfo.Pnic){
    $pnicInfo = $_.QueryNetworkHint($physnic.Device)
    foreach($hint in $pnicInfo){
      Write-Host $esxname $physnic.Device
      $TempCDPInfo = New-Object psobject
      $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Host" -Value $esxname
      $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "PhysicalNIC" -Value $physnic.Device
      if( $hint.ConnectedSwitchPort ) {
        $hint.ConnectedSwitchPort
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "CDPVersion" -Value $hint.ConnectedSwitchPort.CdpVersion
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Timeout" -Value $hint.ConnectedSwitchPort.Timeout
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Ttl" -Value $hint.ConnectedSwitchPort.Ttl
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Samples" -Value $hint.ConnectedSwitchPort.Samples
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "DevId" -Value $hint.ConnectedSwitchPort.DevId
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Address" -Value $hint.ConnectedSwitchPort.Address
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "PortId" -Value $hint.ConnectedSwitchPort.PortId
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "SoftwareVersion" -Value $hint.ConnectedSwitchPort.SoftwareVersion
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "HardwarePlatform" -Value $hint.ConnectedSwitchPort.HardwarePlatform
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Vlan" -Value $hint.ConnectedSwitchPort.Vlan
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "FullDuplex" -Value $hint.ConnectedSwitchPort.FullDuplex
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Mtu" -Value $hint.ConnectedSwitchPort.Mtu
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "SystemName" -Value $hint.ConnectedSwitchPort.SystemName
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "MgmtAddr" -Value $hint.ConnectedSwitchPort.MgmtAddr
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Location" -Value $hint.ConnectedSwitchPort.Location
      }
      else {
        Write-Host "No CDP information available."; Write-Host
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "CDPVersion" -Value "No CDP Info Available"
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Timeout" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Ttl" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Samples" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "DevId" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Address" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "PortId" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "SoftwareVersion" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "HardwarePlatform" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Vlan" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "FullDuplex" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Mtu" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "SystemName" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "MgmtAddr" -Value ""
        $TempCDPInfo | Add-Member -MemberType NoteProperty -Name "Location" -Value ""        
      }
    $CDPInfo += $TempCDPInfo
    }
  }
$CDPInfo | Export-Csv $OutputFile
} 


