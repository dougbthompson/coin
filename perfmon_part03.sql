
I didnt think about this post to be honest, and I believed the series was complete with Part I and Part II, but when it was time to implement and deploy the solution to multiple servers, I realised that it would be useful to deploy programatically and not going one server after another clicking and clicking and clicking you get it, right?

 
Background

As I said, when its time to deploy the solution explained in my previous posts to a number of servers it might get very tedious, specially if we have servers running multiple instances, since each have different counter names because the instance name is part of that name, and if we create one template, that wont apply to all cases, so a lot of manual intervention.

So I decided to do what I like the most and got to write some queries that combined with some powershell will do the job for me.

The logic is easy, we have three tables where we are going to insert the different SQL Servers we want to deploy to (Server\Instance format), then we will have one table for windows counters and another for SQL Server counters.

To get a list of all counters available, you can run this command

1
typeperf -q > c:\temp\all_server_counters.txt
 
This will bring the whole list of performance counters, you need to run this in a SQL Server with a default instance installed to get SQL Server performance counters

Then you can review them and choose those you are most interested.

The query will generate just one row per server but it will contain all server counters plus SQL Server counters for each instance, so we will have the whole picture in one output file and well be able to correlate the data easier.

After that, I use logman to remotely create the different Data Collectors on each server, be sure you have enough administrative privileges.

Import-Module sqlps -DisableNameChecking
  
$cmssrv = "localhost\MSSQL2016";
$templatePath = "c:\temp\templates\"; 
$outputPath = "c:\Perfmon\"
  
$serverlist = invoke-sqlcmd -ServerInstance $cmssrv -Database "master" -query "
IF OBJECT_ID('tempdb..#SQLServers')         IS NOT NULL DROP TABLE #SQLServers
IF OBJECT_ID('tempdb..#ServerCounters')     IS NOT NULL DROP TABLE #ServerCounters
IF OBJECT_ID('tempdb..#SQLServerCounters')  IS NOT NULL DROP TABLE #SQLServerCounters
  
CREATE TABLE #SQLServers        (ID INT NOT NULL IDENTITY, instance_name SYSNAME)
CREATE TABLE #ServerCounters    (ID INT NOT NULL IDENTITY, counter_name SYSNAME)
CREATE TABLE #SQLServerCounters (ID INT NOT NULL IDENTITY, counter_name SYSNAME)
  
INSERT INTO #SQLServers
VALUES ('localhost')
, ('localhost\MSSQL2014')
, ('localhost\MSSQL2016')
, ('localhost\MSSQL2017')
  
INSERT INTO #ServerCounters ( counter_name )
VALUES ('\Memory\Available MBytes')
, ('\NUMA Node Memory(*)\Available MBytes')
, ('\Paging File(*)\% Usage')
, ('\PhysicalDisk(*)\Avg. Disk Queue Length')
, ('\PhysicalDisk(*)\Current Disk Queue Length')
, ('\PhysicalDisk(*)\Disk Reads/sec')
, ('\PhysicalDisk(*)\Disk Writes/sec')
, ('\PhysicalDisk(*)\Avg. Disk sec/Read')
, ('\PhysicalDisk(*)\Avg. Disk sec/Write')
, ('\PhysicalDisk(*)\Avg. Disk Read Queue Length')
, ('\PhysicalDisk(*)\Avg. Disk Write Queue Length')
, ('\System\Processor Queue Length')
, ('\Processor(*)\% Processor Time')
, ('\Network Interface(*)\Bytes Total/sec')
, ('\Network Interface(*)\Packets/sec')
, ('\Network Interface(*)\Packets Received/sec')
, ('\Network Interface(*)\Packets Sent/sec')
  
INSERT INTO #SQLServerCounters ( counter_name )
VALUES ('\SQLServer:Buffer Manager\Page life expectancy')
, ('\SQLServer:Buffer Node(*)\Page life expectancy')
, ('\SQLServer:General Statistics\User Connections')
, ('\SQLServer:Memory Manager\Memory Grants Pending')
, ('\SQLServer:SQL Statistics\Batch Requests/sec')
, ('\SQLServer:SQL Statistics\SQL Compilations/sec')
, ('\SQLServer:SQL Statistics\SQL Re-Compilations/sec')
  
SELECT DISTINCT 
        CASE 
            WHEN CHARINDEX('\', s.instance_name) > 0 
                THEN LEFT(s.instance_name, CHARINDEX('\', s.instance_name) - 1) 
            ELSE s.instance_name 
        END AS server_name
        , STUFF((SELECT CHAR(10) + counter_name FROM #ServerCounters AS c ORDER BY ID FOR XML PATH('')), 1,1,'') 
        + 
        (SELECT CHAR(10) + 
                    CASE WHEN CHARINDEX('\', s1.instance_name) = 0  
                        THEN c.counter_name 
                        ELSE REPLACE(c.counter_name, 'SQLServer', 'MSSQL$' + CONVERT(SYSNAME, RIGHT(s1.instance_name, LEN(s1.instance_name) - CHARINDEX('\', s1.instance_name))))
                    END
             FROM #SQLServerCounters AS c 
             CROSS APPLY #SQLServers AS s1
             ORDER BY s1.instance_name, c.ID 
             FOR XML PATH('')
        ) AS template
    FROM #SQLServers AS s
    ORDER BY server_name"
  
foreach ($servername in $serverlist) {
      
    $OutputExists = Get-Item -Path $templatePath -ErrorAction SilentlyContinue;
  
    if ($OutputExists -eq $null) {
        Write-Output "Creating directory $templatePath";
        New-Item -Path $templatePath -Type Directory;
    }
  
    $templateFile = "$($templatePath)\$($servername.server_name)_DBA_collector.txt";
    $servername.template | Out-File -FilePath $templateFile;
    $serverOutputPath = "$($outputPath)$($servername.server_name)";
  
    $OutputExists = Get-Item -Path $serverOutputPath -ErrorAction SilentlyContinue;
  
    if ($OutputExists -eq $null) {
        Write-Output "Creating directory $serverOutputPath";
        New-Item -Path $serverOutputPath -Type Directory;
    }
      
    try{
        Write-Output "Trying to create counter in $($servername.server_name)";
        logman create counter -s $servername.server_name -cf $templateFile -n "DBA_perfmonCollector" -f "csv" -si 15 -o "$($serverOutputPath)\$($servername.server_name)" -a -cnf "24:00:00" -v "nnnnnn";
        logman start -s $servername.server_name -n "DBA_perfmonCollector";
    }
    catch{
        Write-Output "Failed to create counter in $($servername.server_name)";
    }
}
 
After successfully running this powershell script you will have your Data collectors created on each server.

Id recommend to use a shared folder to centralize all the outputs in one location and also avoid filling the c:\ drive which can be a real pain in the back.

 
Conclusion

As I said, I didnt expect to write this post, but I felt something was missing with just the two previous posts.

I am currently working on some reports to make the data a bit more usable because the amount of information can be huge and really defeat the purpose of having it.

Hope you like it and stay tuned!

Thanks!

