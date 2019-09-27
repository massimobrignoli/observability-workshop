Add-Type -AssemblyName System.IO.Compression.FileSystem
$workshopPath = "C:\Users\Administrator\Desktop\workshop-content"
$downloadPath = "C:\Users\Administrator\Downloads\"
# Beats used in the workshop
$filebeat_link = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.2-windows-x86_64.zip'
$metricbeat_link = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.3.2-windows-x86_64.zip'
$heartbeat_link = 'https://artifacts.elastic.co/downloads/beats/heartbeat/heartbeat-7.3.2-windows-x86_64.zip'
$winlogbeat_link = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.3.2-windows-x86_64.zip'


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
