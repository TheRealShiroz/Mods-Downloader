#Requires -Version 5
[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new()

$Lang="VI"

$ForgeURL="https://download.mcbbs.net/forge/minecraftforge/1.20.1-47.4.10/forge-1.20.1-47.4.10-installer.jar"
$SKURL="https://download.skmedix.pl/sklauncher/SKlauncher-3.2.18_Setup.exe"
$ModsURL="https://download2261.mediafire.com/epxn3ivqfml8w4e/Client_Side_Mods.zip"

function Header{
Clear-Host
Write-Host "====================================="
Write-Host " Minecraft Modpack Installer"
Write-Host "====================================="
}

function CheckExecutionPolicy{

$policy=Get-ExecutionPolicy

if($policy -eq "Restricted"){

if($Lang -eq "VI"){
$ans=Read-Host "Phát hiện ExecutionPolicy bị tắt. Bật lên? (Y/N)"
}else{
$ans=Read-Host "ExecutionPolicy disabled. Enable it? (Y/N)"
}

if($ans -match "Y|y"){
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}else{
exit
}

}

}

function CheckCurl{

$curl=Get-Command curl -ErrorAction SilentlyContinue

if(!$curl){

Write-Host "Installing curl..."

winget install curl -e

}

}

function Download($url,$path){

$retry=0

while($retry -lt 5){

try{

$start=Get-Date

Invoke-WebRequest $url -OutFile $path -UseBasicParsing

$size=(Get-Item $path).Length
$time=((Get-Date)-$start).TotalSeconds

$speed=[math]::Round(($size/1MB)/$time,2)

Write-Host "Speed $speed MB/s"

return

}catch{

$retry++

Write-Host "Retry $retry..."

}

}

Write-Host "Download failed"
exit

}

function CheckJava{

$java=Get-Command java -ErrorAction SilentlyContinue

if(!$java){

if($Lang -eq "VI"){
$ans=Read-Host "Máy bạn chưa cài Java 17. Cài đặt? (Y/N)"
}else{
$ans=Read-Host "Java 17 not detected. Install? (Y/N)"
}

if($ans -match "Y|y"){

$url="https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe"
$out="$env:TEMP\java17.exe"

Download $url $out

Start-Process $out -Wait

}

}

}

function CheckRAM{

$ram=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB
$ram=[math]::Round($ram)

if($ram -lt 4){

Write-Host "Minimum RAM 4GB"

}elseif($ram -lt 10){

if($Lang -eq "VI"){
Read-Host "Ram <10GB, bạn muốn tự chỉnh config? (Enter)"
}else{
Read-Host "RAM <10GB configure manually (Enter)"
}

}else{

Write-Host "Using default config"

}

}

function InstallForge{

Header

$forge="$env:TEMP\forge.jar"

Write-Host "Downloading Forge..."

Download $ForgeURL $forge

Write-Host "Installing Forge..."

java -jar $forge --installClient

}

function InstallSKLauncher{

Header

$out="$env:TEMP\sklauncher.exe"

Write-Host "Downloading SKLauncher..."

Download $SKURL $out

Start-Process $out

}

function DownloadMods{

Header

$out="$env:TEMP\mods.zip"

Write-Host "Downloading Mods..."

Download $ModsURL $out

}

function InstallAll{

Header

CheckJava
CheckRAM
InstallForge
DownloadMods

if($Lang -eq "VI"){
Write-Host "Bạn đang dùng config máy yếu. Nếu đồ họa xấu hãy chỉnh lại."
}else{
Write-Host "Low end config applied."
}

}

function SwitchLang{

if($Lang -eq "VI"){
$script:Lang="EN"
}else{
$script:Lang="VI"
}

}

function Menu{

Header

if($Lang -eq "VI"){

Write-Host "1. Cài đặt SKLauncher"
Write-Host "2. Tải Và Cài Đặt Toàn Bộ Mod Yêu Cầu Và Các Option Được Setting Sẵn"
Write-Host "3. Chỉ Tải Mods"
Write-Host "4. Switch to English interface"
Write-Host "5. Thoát"

}else{

Write-Host "1. Install SKLauncher"
Write-Host "2. Download And Install All Mods And Options"
Write-Host "3. Download Mods Only"
Write-Host "4. Switch to Vietnamese interface"
Write-Host "5. Exit"

}

}

CheckExecutionPolicy
CheckCurl

while($true){

Menu

$choice=Read-Host "Select"

switch($choice){

"1"{InstallSKLauncher}

"2"{InstallAll}

"3"{DownloadMods}

"4"{SwitchLang}

"5"{exit}

default{Write-Host "Invalid"}

}

pause

}
