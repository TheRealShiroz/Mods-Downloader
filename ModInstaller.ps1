```powershell
#Requires -Version 5
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$Lang = "VI"

# ---------------- HEADER ----------------

function ShowHeader {
    Clear-Host
    Write-Host "====================================="
    Write-Host "  Minecraft Modpack Installer"
    Write-Host "====================================="
    Write-Host ""
}

# ---------------- EXECUTION POLICY ----------------

function CheckExecutionPolicy {

    $policy = Get-ExecutionPolicy

    if ($policy -eq "Restricted") {

        if ($Lang -eq "VI") {
            $msg = "Phát hiện ExecutionPolicy đã tắt, bạn có muốn bật không? (Y/N)"
        } else {
            $msg = "ExecutionPolicy disabled. Enable it? (Y/N)"
        }

        $ans = Read-Host $msg

        if ($ans -match "Y|y") {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        } else {
            exit
        }
    }
}

# ---------------- DOWNLOAD FUNCTION ----------------

function DownloadFile($url,$path){

    $start = Get-Date

    Invoke-WebRequest $url -OutFile $path -UseBasicParsing

    $end = Get-Date
    $size = (Get-Item $path).Length

    $time = ($end-$start).TotalSeconds

    if($time -gt 0){
        $speed = [math]::Round(($size/1MB)/$time,2)
        Write-Host "Speed: $speed MB/s"
    }

}

# ---------------- JAVA CHECK ----------------

function CheckJava {

    $java = Get-Command java -ErrorAction SilentlyContinue

    if(!$java){

        if($Lang -eq "VI"){
            $ask = Read-Host "Máy bạn chưa cài Java. Bạn có muốn cài Java 17? (Y/N)"
        }
        else{
            $ask = Read-Host "Java not found. Install Java 17? (Y/N)"
        }

        if($ask -match "Y|y"){

            $url="https://download.oracle.com/java/17/latest/jdk-17_windows-x64_bin.exe"
            $out="$env:TEMP\java17.exe"

            Write-Host "Downloading Java..."
            DownloadFile $url $out

            Start-Process $out -Wait
        }
    }

}

# ---------------- RAM CHECK ----------------

function CheckRAM {

$ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory /1GB

$ram=[math]::Round($ram)

if($ram -lt 4){

    if($Lang -eq "VI"){
        Write-Host "Ram yêu cầu tối thiểu là 4Gb"
    }
    else{
        Write-Host "Minimum RAM required: 4GB"
    }

}

elseif($ram -lt 10){

    if($Lang -eq "VI"){
        $ans=Read-Host "Ram thấp hơn 10GB. Bạn có muốn set riêng không? (Y/N)"
    }
    else{
        $ans=Read-Host "RAM below 10GB. Configure manually? (Y/N)"
    }

}

else{

    if($Lang -eq "VI"){
        Write-Host "Đã phát hiện RAM >=10GB, dùng config mặc định."
    }
    else{
        Write-Host "Detected RAM >=10GB using default config."
    }

}

}

# ---------------- INSTALL FORGE ----------------

function InstallForge {

$forge="$env:TEMP\forge.jar"

$url="https://www.mediafire.com/file/w7ke9amo1b3dchg/forge-1.20.1-47.4.10-installer.jar/file"

Write-Host "Downloading Forge..."

DownloadFile $url $forge

Write-Host "Installing Forge..."

java -jar $forge --installClient

}

# ---------------- INSTALL SKLAUNCHER ----------------

function InstallLauncher {

ShowHeader

$url="https://www.mediafire.com/file/3ji48egshetqr37/SKlauncher-3.2.18_Setup.exe/file"

$out="$env:TEMP\sklauncher.exe"

Write-Host "Downloading SKLauncher..."

DownloadFile $url $out

Start-Process $out

}

# ---------------- DOWNLOAD MODS ----------------

function DownloadModsOnly {

ShowHeader

$url="https://www.mediafire.com/file/epxn3ivqfml8w4e/Client_Side_Mods.zip/file"

$out="$env:TEMP\mods.zip"

Write-Host "Downloading Mods..."

DownloadFile $url $out

}

# ---------------- INSTALL ALL ----------------

function InstallAll {

ShowHeader

CheckJava
CheckRAM
InstallForge
DownloadModsOnly

if($Lang -eq "VI"){
Write-Host "Bạn đang dùng cấu hình cho máy yếu. Nếu thấy đồ họa xấu hãy tự chỉnh."
}
else{
Write-Host "Low-end config applied. Adjust graphics if needed."
}

}

# ---------------- LANGUAGE ----------------

function SwitchLanguage {

if($Lang -eq "VI"){
$script:Lang="EN"
}
else{
$script:Lang="VI"
}

}

# ---------------- MENU ----------------

function ShowMenu {

ShowHeader

if($Lang -eq "VI"){

Write-Host "1. Cài đặt SKLauncher"
Write-Host "2. Tải Và Cài Đặt Toàn Bộ Mod Yêu Cầu Và Các Option Được Setting Sẵn"
Write-Host "3. Chỉ Tải Mods"
Write-Host "4. Switch to English interface"
Write-Host "5. Thoát"

}

else{

Write-Host "1. Install SKLauncher"
Write-Host "2. Download And Install All Mods And Options"
Write-Host "3. Download Mods Only"
Write-Host "4. Switch to Vietnamese interface"
Write-Host "5. Exit"

}

}

# ---------------- MAIN LOOP ----------------

CheckExecutionPolicy

while($true){

ShowMenu

$choice=Read-Host "Select option"

switch($choice){

"1"{InstallLauncher}

"2"{InstallAll}

"3"{DownloadModsOnly}

"4"{SwitchLanguage}

"5"{exit}

default{Write-Host "Invalid option"}

}

pause

}
```
