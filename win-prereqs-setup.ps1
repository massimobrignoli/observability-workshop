Add-Type -AssemblyName System.IO.Compression.FileSystem
$workshopPath = "C:\Users\Administrator\Desktop\workshop-content"
$downloadPath = "C:\Users\Administrator\Downloads\"
# Beats used in the workshop
$filebeat_link = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.7.0-windows-x86_64.zip'
$metricbeat_link = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.7.0-windows-x86_64.zip'
$heartbeat_link = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.7.0-windows-x86_64.zip'
$winlogbeat_link = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.7.0-windows-x86_64.zip'
$auditbeat_link = 'https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.7.0-windows-x86_64.zip'
$packetbeat_link = 'https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.7.0-windows-x86_64.zip'
# APM
$apm_link = 'https://github.com/bvader/spring-petclinic/archive/master.zip'
$agent_link = 'https://search.maven.org/remotecontent?filepath=co/elastic/apm/elastic-apm-agent/1.16.0/elastic-apm-agent-1.16.0.jar'
$java_link = 'https://download.oracle.com/otn-pub/java/jdk/13.0.1+9/cec27d702aa74d5a8630c65ae61e4305/jdk-13.0.1_windows-x64_bin.exe'
$java_link_zip = 'https://download.oracle.com/otn-pub/java/jdk/13.0.1+9/cec27d702aa74d5a8630c65ae61e4305/jdk-13.0.1_windows-x64_bin.zip'

function Setup-Prereqs ()
{    
	# Notepad++ for users to work with files	
	$prereq_1 = 'https://notepad-plus-plus.org/repository/7.x/7.6.6/npp.7.6.6.Installer.x64.exe'	
	
    If (!(Test-Path -Path $downloadPath -PathType Container)) {New-Item -Path $downloadPath -ItemType Directory | Out-Null}
    
    $packages = @(
    @{title='Notepad++ 7.6.6';url=$prereq_1;Arguments=' /Q /S';Destination=$downloadPath}
	#add other prereq details here
    )
    
    foreach ($package in $packages) {
            $packageName = $package.title
            $fileName = Split-Path $package.url -Leaf
            $destinationPath = $package.Destination + "\" + $fileName
    
    If (!(Test-Path -Path $destinationPath -PathType Leaf)) {
    
        Write-Host "Downloading $packageName"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($package.url,$destinationPath)
        }
    }
    
    foreach ($package in $packages) {
        $packageName = $package.title
        $fileName = Split-Path $package.url -Leaf
        $destinationPath = $package.Destination + "\" + $fileName
        $Arguments = $package.Arguments
        Write-Output "Installing $packageName"
		Invoke-Expression -Command "$destinationPath $Arguments"
    }
}
# Download and Unzip Beats
function Download-Beats(){
    If (!(Test-Path -Path $workshopPath -PathType Container)) {New-Item -Path $workshopPath -ItemType Directory | Out-Null}

    $beats = @(
    @{title='Filebeat';url=$filebeat_link;Arguments=''},
    @{title='Metricbeat';url=$metricbeat_link;Arguments=''},
    @{title='Heartbeat';url=$heartbeat_link;Arguments=''},
    @{title='Packetbeat';url=$packetbeat_link;Arguments=''},
    @{title='Auditbeat';url=$auditbeat_link;Arguments=''},
    @{title='Winlogbeat';url=$winlogbeat_link;Arguments=''}
    )
    
    foreach ($beat in $beats) {
            $beatName = $beat.title
            $fileName = Split-Path $beat.url -Leaf
            $destinationPath = $workshopPath + "\" + $fileName
			Write-Output "Beats Download Location =  $destinationPath"
    
            If (!(Test-Path -Path $destinationPath -PathType Leaf)) {
                Write-Host "Downloading $beatName"
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($beat.url,$destinationPath)
            }
        }
    
    foreach ($beat in $beats) {
        $beatName = $beat.title
        $fileName = Split-Path $beat.url -Leaf
        $zipFile = $workshopPath + "\" + $fileName
        Write-Output "Unzipping $beatName"
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $workshopPath)

	}
}

# Download and Unzip Beats
function Download-APM(){
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    If (!(Test-Path -Path $workshopPath -PathType Container)) {New-Item -Path $workshopPath -ItemType Directory | Out-Null}
    $destinationPath = $workshopPath + '\apm'
    If (!(Test-Path -Path $destinationPath -PathType Container)) {New-Item -Path $destinationPath -ItemType Directory | Out-Null}
    $appPath = $destinationPath + "\spring-petclinic-master"
    
    Write-Output "Downloading APM APP"
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($apm_link,$destinationPath + "\master.zip")
	
	Write-Output "Unzip APM APP"

	[System.IO.Compression.ZipFile]::ExtractToDirectory($destinationPath + "\master.zip", $destinationPath)
	
	Write-Output "Downloading APM Agent"

	$webClient.DownloadFile($agent_link,$appPath + "\elastic-apm-agent-1.16.0.jar")
	
	Write-Output "Install Java"
	#create config file for silent install
	$text = '
	INSTALL_SILENT=Enable
	AUTO_UPDATE=Enable
	SPONSORS=Disable
	REMOVEOUTOFDATEJRES=1
	'
	$text | Set-Content "$destinationPath\jdkinstall.cfg"
	$cookie = "oraclelicense=accept-securebackup-cookie"
	$webClient.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie) 
	$webClient.DownloadFile($java_link_zip,$destinationPath + "\jdk.zip")
	[System.IO.Compression.ZipFile]::ExtractToDirectory($destinationPath + "\jdk.zip", $destinationPath)
	#Start-Process -FilePath "$destinationPath\jdk.exe" -ArgumentList INSTALLCFG="$destinationPath\jdkinstall.cfg"
	#Start-Sleep -s 180	
	#[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-13.0.1")
	[System.Environment]::SetEnvironmentVariable("JAVA_HOME", $destinationPath + "\jdk-13.0.1")
	[System.Environment]::SetEnvironmentVariable("Path", [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) + ";$($env:JAVA_HOME)\bin")
		
	Write-Output "Maven package"
	cd $appPath
	.\mvnw.cmd package
	
}

function Copy-Data()
{
	If (!(Test-Path -Path $downloadPath -PathType Container)) {New-Item -Path $downloadPath -ItemType Directory | Out-Null}
	$downloadPath = "C:\Users\Administrator\Downloads\"
	Write-Output 'downloadPath = $downloadPath'
	$dataOrigin = $downloadPath +'\observability-workshop\data\*'
	$dataDest = $workshopPath + '\data\logs\'
		
	Copy-Item $dataOrigin -Destination $dataDest -Recurse
	$nginxZipFile = $dataDest+'nginx\nginx.zip'
	$nginxExtractLocation = $dataDest+'nginx'
	
	Write-Output 'nginxZipFile' + $nginxExtractLocation
	[System.IO.Compression.ZipFile]::ExtractToDirectory($nginxZipFile, $nginxExtractLocation)
	
	Remove-Item $nginxZipFile
	
}
Setup-Prereqs
Download-Beats
Copy-Data
Download-APM
