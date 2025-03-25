# Run this command in PowerShell to start the scanner
iex "Start-Process powershell -ArgumentList '-NoExit -Command', '-NoProfile -ExecutionPolicy Bypass -Command', '`"& {
    Clear-Host;
    Write-Host \"`n`;
    Write-Host \"__/\\\_________________/\\\\\\\\\_____/\\\\\\\\\\\\\\\__/\\\\\\\\\\\\\\\__/\\\_______/\\\_        \" -ForegroundColor Cyan;
    Write-Host \"_\/\\\_______________/\\\\\\\\\\\\\__\///////\\\/////__\/\\\///////////__\///\\\___/\\\/__       \" -ForegroundColor Cyan;
    Write-Host \" _\/\\\______________/\\\/////////\\\_______\/\\\_______\/\\\_______________\///\\\\\\/____      \" -ForegroundColor Cyan;
    Write-Host \"  _\/\\\_____________\/\\\_______\/\\\_______\/\\\_______\/\\\\\\\\\\\_________\//\\\\______     \" -ForegroundColor Cyan;
    Write-Host \"   _\/\\\_____________\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\///////___________\/\\\\______    \" -ForegroundColor Cyan;
    Write-Host \"    _\/\\\_____________\/\\\/////////\\\_______\/\\\_______\/\\\__________________/\\\\\\_____   \" -ForegroundColor Cyan;
    Write-Host \"     _\/\\\_____________\/\\\_______\/\\\_______\/\\\_______\/\\\________________/\\\////\\\___  \" -ForegroundColor Cyan;
    Write-Host \"      _\/\\\\\\\\\\\\\\\_\/\\\_______\/\\\_______\/\\\_______\/\\\\\\\\\\\\\\\__/\\\/___\///\\\_ \" -ForegroundColor Cyan;
    Write-Host \"       _\///////////////__\///________\///________\///________\///////////////__\///_______\///__\" -ForegroundColor Cyan;
    Write-Host \"`n                                 FILE SCANNER v3.0\" -ForegroundColor Yellow;
    Write-Host \"_____________________________________________________________`n\" -ForegroundColor Cyan;

    # Main scanning function
    function Start-Scan {
        param($path)
        
        Add-Type -TypeDefinition @'
        using System;
        using System.Runtime.InteropServices;
        public class Verifier {
            [DllImport("wintrust.dll", CharSet=CharSet.Unicode)]
            private static extern uint WinVerifyTrust(IntPtr hWnd, Guid pgActionID, IntPtr pWVTData);
            
            public static string CheckFile(string file) {
                try {
                    Guid action = new Guid("00AAC56B-CD44-11d0-8CC2-00C04FC295EE");
                    int result = WinVerifyTrust(IntPtr.Zero, action, CreateFileInfo(file));
                    return result == 0 ? "TRUSTED" : 
                           result == 0x800B0100 ? "UNSIGNED" : 
                           result == 0x80096010 ? "REVOKED" : "FAKE";
                } catch { return "ERROR"; }
            }
            
            private static IntPtr CreateFileInfo(string file) {
                IntPtr ptr = Marshal.AllocCoTaskMem(100);
                Marshal.WriteInt32(ptr, 0, 100);
                Marshal.WriteIntPtr(ptr, 4, Marshal.StringToCoTaskMemUni(file));
                return ptr;
            }
        }
'@

        $files = Get-ChildItem $path -File -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Extension -match '\.(exe|dll|sys|msi|ps1|bat)' };
        $total = $files.Count;
        $counter = 0;
        
        Write-Host "`n  [STATUS] Scanning $total executable files...`n" -ForegroundColor Magenta;
        
        foreach ($file in $files) {
            $counter++;
            $progress = [math]::Round(($counter/$total)*100, 2);
            Write-Progress -Activity "  Scanning Files" -Status "$progress% Complete" -PercentComplete $progress -CurrentOperation $file.FullName;
            
            $status = [Verifier]::CheckFile($file.FullName);
            
            switch ($status) {
                "TRUSTED"   { Write-Host "  [VALID] $($file.FullName)" -ForegroundColor Green }
                "UNSIGNED"  { Write-Host "  [UNSIGNED] $($file.FullName)" -ForegroundColor Red }
                "REVOKED"   { Write-Host "  [REVOKED] $($file.FullName)" -ForegroundColor Magenta }
                "FAKE"      { Write-Host "  [FAKE] $($file.FullName)" -ForegroundColor Blue }
                default     { Write-Host "  [ERROR] $($file.FullName)" -ForegroundColor Yellow }
            }
        }
        
        Write-Host "`n  [COMPLETE] Scan finished! Press any key to exit..." -ForegroundColor Green;
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    }

    # Prompt for path and start scan
    $path = Read-Host "  [INPUT] Enter file path to scan (e.g. C:\ or C:\Folder)";
    if (Test-Path $path) {
        Start-Scan -path $path;
    } else {
        Write-Host "  [ERROR] Invalid path!" -ForegroundColor Red;
        Start-Sleep 3;
    }
}`"' -WindowStyle Normal"