#Requires -Modules Rubrik
#Requires -Version 5
# --------------------
# Protected VMs and hosts
# --------------------
# This script will report on all protected VMs, hosts with filesets and hosts with protected SQL DBs on a Rubrik cluster
# The script will only report systems protected by an SLA
# --------------------
# Written by: Cor van 't Hoff <cor.vanthoff@rubrik.com>
# --------------------
Import-Module Rubrik
# Replace variables here:
$rubrik_cluster = 'rubrik-cluster.com'
$rubrik_user = 'admin'
$rubrik_pass = 'password'
# Do not change anything after this point
# Set up web headers for certain API calls
$headers = @{
    Authorization = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $rubrik_user,$rubrik_pass)))
    Accept = 'application/json'
}
# Connect to Rubrik cluster
$rk_connection = Connect-Rubrik -Server $rubrik_cluster -Username $rubrik_user -Password $(ConvertTo-SecureString -String $rubrik_pass -AsPlainText -Force)
#Put filesets, SQL host and VMs in variables
$rk_all_file = Get-RubrikFileset -PrimaryClusterID local | Where-Object {$_.EffectiveSlaDomainName -ne 'Unprotected'}
$rk_all_sql = (Get-RubrikDatabase | Where-Object {$_.EffectiveSlaDomainName -ne 'Unprotected'}).rootProperties.rootName | Sort-Object -Unique
$rk_all_vms = Get-RubrikVM -PrimaryClusterID local | Where-Object {$_.EffectiveSlaDomainName -ne 'Unprotected'} 
# Print the variables to output.
foreach ($rk_vm in $rk_all_vms) {
    Write-Output "$($rk_vm.name)"
}
Write-Output $rk_all_sql
foreach ($rk_file in $rk_all_file) {
    Write-Output "$($rk_file.hostname)"
}