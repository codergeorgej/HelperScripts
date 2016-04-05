function Get-UACStatus{
	[cmdletBinding(SupportsShouldProcess = $true)]
    param([parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
        [string]$Computer)
		
    [string]$RegistryValue = "EnableLUA"
    [string]$RegistryPath = "Software\Microsoft\Windows\CurrentVersion\Policies\System"
    [bool]$UACStatus = $false
    $OpenRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
    $Subkey = $OpenRegistry.OpenSubKey($RegistryPath,$false)
    $Subkey.ToString() | Out-Null
    $UACStatus = ($Subkey.GetValue($RegistryValue) -eq 1)
    write-host $Subkey.GetValue($RegistryValue)
    return $UACStatus
} 

function Set-UACStatus{
	
	param(
		[cmdletbinding()]
		[parameter(ValueFromPipeline= $false, ValueFromPipelineByPropertyName= $true, Mandatory = $false)]
		[string]$Computer = $env:ComputerName,
		[parameter(ValueFromPipeline= $false, ValueFromPipelineByPropertyName= $true, Mandatory = $true)]
		[bool]$enabled
	)
	[string]$RegistryValue= "EnableLUA"
	[string]$RegistryPath= "Software\Microsoft\Windows\CurrentVersion\Policies\System"
	$OpenRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
	$Subkey = $OpenRegistry.OpenSubKey($RegistryPath,$true)
	$Subkey.ToString() | Out-Null
	if ($enabled -eq $true){
		$Subkey.SetValue($RegistryValue, 1)
	}else{
		$Subkey.SetValue($RegistryValue, 0)
	}
	$UACStatus= $Subkey.GetValue($RegistryValue)
	$UACStatus
	$Restart = Read-Host "`nSetting this requires a reboot of $Computer. Would you like to reboot $Computer [y/n]?"
	if ($Restart -eq "y"){
		Restart-Computer $Computer -force
		Write-Host "Rebooting $Computer"
	}else{
		Write-Host "Please restart $Computer when convenient"
	}
}
