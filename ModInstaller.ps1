# =====================================

# Minecraft Modpack Installer

# =====================================

chcp 65001 > $null

$global:lang = "vi"

# ===============================

# LINKS

# ===============================

$urls = @{
SKLauncher = "https://download164.mediafire.com/3ji48egshetqr37/SKlauncher-3.2.18_Setup.exe"
FullMods = "https://download152.mediafire.com/p7cgdc6uj71425c/My_Mods_Pack.zip"
ClientMods = "https://download148.mediafire.com/epxn3ivqfml8w4e/Client_Side_Mods.zip"
Forge = "https://download152.mediafire.com/w7ke9amo1b3dchg/forge-1.20.1-47.4.10-installer.jar"
Java17 = "https://github.com/adoptium/temurin17-binaries/releases/latest/download/OpenJDK17U-jdk_x64_windows_hotspot.msi"
}

# ===============================

# TRANSLATION

# ===============================

function T($vi,$en){
if($global:lang -eq "vi"){return $vi}else{return $en}
}

# ===============================

# EXECUTION POLICY CHECK

# ===============================

function CheckExecutionPolicy{

$policy = Get-ExecutionPolicy

if($policy -eq "Restricted"){

$msg = T `"Phát hiện ExecutionPolicy đã tắt, sẽ làm file không chạy được, bạn có muốn bật không? (Y/N)"`
"ExecutionPolicy is disabled and scripts cannot run. Enable it? (Y/N)"

$ans = Read-Host $msg

if($ans -eq "Y" -or $ans -eq "y"){

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Write-Host "ExecutionPolicy enabled."

}else{

exit

}

}

}

# ===============================

# DOWNLOAD FUNCTION

# ===============================

function DownloadFile($url,$file){

$retry=3

for($i=1;$i -le $retry;$i++){

try{

Write-Host (T "Đang tải:" "Downloading:") $url

$request=[System.Net.HttpWebRequest]::Create($url)
$response=$request.GetResponse()

$total=$response.ContentLength
$stream=$response.GetResponseStream()

$buffer=New-Object byte[] 8192
$fileStream=[System.IO.File]::Create($file)

$totalRead=0
$sw=[System.Diagnostics.Stopwatch]::StartNew()

while(($read=$stream.Read($buffer,0,$buffer.Length)) -gt 0){

$fileStream.Write($buffer,0,$read)

$totalRead += $read

$percent=($totalRead/$total)*100

$speed=($totalRead/1MB)/$sw.Elapsed.TotalSeconds

$remain=$total-$totalRead

if($speed -gt 0){
$eta=$remain/1MB/$speed
}else{
$eta=0
}

$status="{0:N1}% | {1:N2} MB/s | ETA {2:N0}s" -f $percent,$speed,$eta

Write-Progress `-Activity (T "Đang tải file..." "Downloading file...")`
-Status $status `
-PercentComplete $percent

}

$fileStream.Close()
$stream.Close()

Write-Host (T "Tải hoàn tất." "Download complete.")

return

}catch{

Write-Host (T "Lỗi tải, thử lại..." "Download failed, retrying...")
Start-Sleep 2

}

}

Write-Host (T "Tải thất bại sau nhiều lần thử." "Download failed after retries.")
exit

}

# ===============================

# CHECK CURL

# ===============================

function CheckCurl{

Write-Host (T "Đang kiểm tra curl..." "Checking curl...")

if(!(Get-Command curl -ErrorAction SilentlyContinue)){

Write-Host (T "Không tìm thấy curl. Sẽ dùng downloader PowerShell." "Curl not found. Using PowerShell downloader.")

}

}

# ===============================

# CHECK JAVA

# ===============================

function CheckJava{

try{
java -version 2>$null
}catch{

$ans=Read-Host (T "Máy bạn chưa cài Java. Bạn có muốn cài Java 17? (Y/N)" "Java not found. Install Java 17? (Y/N)")

if($ans -eq "Y"){

$tmp="$env:TEMP\java17.msi"

DownloadFile $urls.Java17 $tmp

Start-Process msiexec.exe -ArgumentList "/i `"$tmp`" /quiet /norestart" -Wait

}

}

}

# ===============================

# INSTALL FORGE

# ===============================

function InstallForge{

Write-Host (T "Đang cài Forge 1.20.1..." "Installing Forge 1.20.1...")

$tmp="$env:TEMP\forge.jar"

DownloadFile $urls.Forge $tmp

java -jar $tmp --installClient

}

# ===============================

# RAM DETECT

# ===============================

function GetRAM{

$ram=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory

return [math]::Round($ram/1GB)

}

# ===============================

# CREATE PROFILE

# ===============================

function CreateProfile($name,$ram){

$uuid=[guid]::NewGuid().ToString("N")

$mc="$env:APPDATA.minecraft"
$json="$mc\launcher_profiles.json"

if(!(Test-Path $json)){

'{"profiles":{},"settings":{},"version":6}' | Out-File $json -Encoding UTF8

}

$data=Get-Content $json | ConvertFrom-Json

$profile=@{

created=(Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
gameDir="$mc\versions$name"
javaArgs="-Xmx${ram}M"
lastVersionId="1.20.1-forge-47.4.10"
name=$name
type="custom"

}

$data.profiles | Add-Member $uuid $profile

$data | ConvertTo-Json -Depth 10 | Set-Content $json

}

# ===============================

# INSTALL SKLAUNCHER

# ===============================

function InstallSKLauncher{

$tmp="$env:TEMP\sklauncher.exe"

DownloadFile $urls.SKLauncher $tmp

Start-Process $tmp -Wait

}

# ===============================

# FULL INSTALL

# ===============================

function InstallFull{

CheckCurl
CheckJava
InstallForge

$mc="$env:APPDATA.minecraft"

if(!(Test-Path $mc)){
New-Item $mc -ItemType Directory
}

$zip="$mc\modpack.zip"

DownloadFile $urls.FullMods $zip

Expand-Archive $zip "$mc\versions" -Force

$ram=GetRAM

if($ram -lt 4){

Write-Host (T "Ram tối thiểu là 4GB." "Minimum RAM is 4GB.")

}elseif($ram -lt 10){

$ans=Read-Host (T "Ram thấp. Bạn có muốn set riêng không? (Y/N)" "Low RAM detected. Set custom RAM?")

if($ans -eq "Y"){

$r=Read-Host (T "Ram cấp cho game (GB):" "RAM to allocate (GB)")
$ram=$r*1024

}

}else{

$ram=6500

}

CreateProfile "TheSybauModpack" $ram

Write-Host (T `"Bạn đang dùng cấu hình được set cho máy yếu, nếu thấy đồ họa game xấu vui lòng tự chỉnh lại!"`
"Low-end configuration installed. Adjust graphics settings if needed.")

}

# ===============================

# CLIENT MODS

# ===============================

function InstallClientMods{

$name=Read-Host (T "Nhập tên folder modpack:" "Enter modpack folder name")

$dir="$env:APPDATA.minecraft\versions$name"

New-Item $dir -ItemType Directory -Force

$zip="$dir\mods.zip"

DownloadFile $urls.ClientMods $zip

Expand-Archive $zip $dir -Force

$ans=Read-Host (T "Tạo launcher profile? (Y/N)" "Create launcher profile? (Y/N)")

if($ans -eq "Y"){

$r=Read-Host (T "Ram cấp cho game (GB):" "RAM for game (GB)")

CreateProfile $name ($r*1024)

}

}

# ===============================

# MAIN

# ===============================

CheckExecutionPolicy

while($true){

Clear-Host

Write-Host "================================="
Write-Host " Minecraft Modpack Installer"
Write-Host "================================="

Write-Host "1. $(T "Cài đặt SKLauncher" "Install SKLauncher")"
Write-Host "2. $(T "Tải Và Cài Đặt Toàn Bộ Mod Yêu Cầu Và Các Option Được Setting Sẵn" "Download And Install All Mods And Options")"
Write-Host "3. $(T "Chỉ Tải Mods" "Download Mods Only")"
Write-Host "4. Switch to English interface"
Write-Host "5. Exit"

$op=Read-Host ">>"

switch($op){

"1"{InstallSKLauncher}
"2"{InstallFull}
"3"{InstallClientMods}
"4"{$global:lang="en"}
"5"{exit}

}

Pause

}
