param(
    [Parameter()]
    [string]$server,

    [Parameter()]
    [string]$user,

    [Parameter()]
    [string]$password
 )

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

while ($true) {

    if (!(Get-PowerCLIConfiguration -Scope User | Where-Object { $_.Name -eq 'DefaultVIServer' }).Value) {
        Connect-VIServer -Server $server -User $user -Password $password
    }

    # power.power.average
    Get-stat -Entity 172.20.70.72 -Realtime -Stat power.power.average -MaxSamples 55 | Export-Csv -Path "power.csv" -NoTypeInformation

    $vms = 'Spark master', 'Spark cluster 01', 'Spark cluster 02'
    foreach ($vm in $vms)
    {
        # power.power.average
        Get-stat -Entity $vm -Realtime -Stat "net.usage.average" -MaxSamples 55 -Instance '' | Export-Csv -Path "net.csv" -NoTypeInformation
        
        # cpu.usage.average
        Get-stat -Entity $vm -Realtime -Stat "cpu.usage.average" -MaxSamples 55 | Export-Csv -Path "cpu.csv" -NoTypeInformation
        
        # mem.usage.average
        Get-stat -Entity $vm -Realtime -Stat "mem.usage.average" -MaxSamples 55 | Export-Csv -Path "mem.csv" -NoTypeInformation
    }

    python save.py

    # 15 minute
    Start-Sleep 900
} 

