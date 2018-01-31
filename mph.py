
$api_key = 'e6cbd5dd6302c462a7d4c92d87e23a50bba7a6e9f5b2c895630632f766d2f35e'

Function Get-EthStats
{
    $base_url = 'http://ethereum.miningpoolhub.com/index.php?page=api&action=getdashboarddata'
    $URL = "$($base_url)&api_key=$($api_key)&id="
    $WebRequest = Invoke-WebRequest $URL | ConvertFrom-Json
    $data = $WebRequest.getdashboarddata.data
    Write-Host "`r`nStatistics for: $($data.pool.info.name) [$($data.pool.info.currency)]"
    Write-Host "Block Time: $($data.raw.network.esttimeperblock)"
    $pool_hashrate = "{0:N2}" -f $data.pool.hashrate
    Write-Host "Pool Workers: $($data.pool.workers) | Hashrate: $($pool_hashrate) GH/s | Difficulty: $($data.pool.difficulty)"
    $my_hashrate = "{0:N2}" -f $data.personal.hashrate
    Write-Host "My Hashrate: $($my_hashrate) MH/s | Shares: $($data.personal.sharerate)"
    Write-Host "Confirmed balance: $($data.balance.confirmed)"
    Write-Host "Unconfirmed balance: $($data.balance.unconfirmed)"
    Write-Host "Estimated Balance: $($data.balance.confirmed + $data.balance.unconfirmed)"
    Write-Host "24-Hour rate: $($data.recent_credits_24hours.amount)"
}
Get-EthStats

