$ErrorActionPreference = "Inquire"

# Configure WinRM
function Install-WinRMHttpListener() {
    $httpListener = Get-Item -Path wsman:\localhost\listener\* | where {$_.Keys.Contains("Transport=HTTP")}
    if ($httpListener) {
        return $False
    }
    return $True
}


if (Install-WinRMHttpListener) {
    & winrm create winrm/config/Listener?Address=*+Transport=HTTP `@`{Hostname=`"$($ENV:COMPUTERNAME)`"`}
    if ($LastExitCode) { throw "Failed to setup WinRM HTTP listener" }
}

& winrm set winrm/config/service `@`{AllowUnencrypted=`"true`"`}
if ($LastExitCode) { throw "Failed to setup WinRM HTTP listener" }

& winrm set winrm/config/service/auth `@`{Basic=`"true`"`}
if ($LastExitCode) { throw "Failed to setup WinRM basic auth" }

& netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
if ($LastExitCode) { throw "Failed to setup WinRM HTTP firewall rules" }
