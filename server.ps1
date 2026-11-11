param([int]$Port = 3000)

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }
$dataPath = Join-Path $root "data\site-content.json"

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".mp4"  = "video/mp4"
    ".ico"  = "image/x-icon"
    ".xml"  = "application/xml; charset=utf-8"
    ".txt"  = "text/plain; charset=utf-8"
}

# Bind TcpListener to Any IP (IPv4 and IPv6)
$listener = $null
$portsToTry = @($Port, 3000, 3001, 8080, 5000)
foreach ($p in $portsToTry) {
    try {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $p)
        $listener.Start()
        $Port = $p
        break
    } catch {
        $listener = $null
    }
}

if (-not $listener) {
    Write-Error "Could not bind to any port."
    exit 1
}

Write-Host "=================================================="
Write-Host " Scalora Modern Server (Universal TCP Socket)"
Write-Host " Website:   http://localhost:$Port/"
Write-Host " IP Link:   http://127.0.0.1:$Port/"
Write-Host " Admin CMS: http://localhost:$Port/admin"
Write-Host "=================================================="

function Send-Response($stream, [int]$statusCode, [string]$statusText, [string]$contentType, [byte[]]$bodyBytes, [hashtable]$extraHeaders = @{}) {
    $headerStr = "HTTP/1.1 $statusCode $statusText`r`n"
    $headerStr += "Content-Type: $contentType`r`n"
    $headerStr += "Content-Length: $($bodyBytes.Length)`r`n"
    $headerStr += "Access-Control-Allow-Origin: *`r`n"
    $headerStr += "Access-Control-Allow-Methods: GET, POST, OPTIONS`r`n"
    $headerStr += "Access-Control-Allow-Headers: Content-Type`r`n"
    $headerStr += "Connection: close`r`n"
    foreach ($k in $extraHeaders.Keys) {
        $headerStr += "$k`: $($extraHeaders[$k])`r`n"
    }
    $headerStr += "`r`n"

    $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($headerStr)
    $stream.Write($headerBytes, 0, $headerBytes.Length)
    if ($bodyBytes.Length -gt 0) {
        $stream.Write($bodyBytes, 0, $bodyBytes.Length)
    }
    $stream.Flush()
}

try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $stream.ReadTimeout = 4000

        try {
            # Read Request Headers
            $buffer = New-Object byte[] 8192
            $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
            if ($bytesRead -le 0) {
                $client.Close()
                continue
            }

            $rawRequest = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $bytesRead)
            $lines = $rawRequest -split "`r?`n"
            if ($lines.Length -lt 1) {
                $client.Close()
                continue
            }

            $firstLine = $lines[0] -split " "
            $method = $firstLine[0]
            $target = if ($firstLine.Length -gt 1) { $firstLine[1] } else { "/" }
            $pathOnly = ($target -split '\?')[0]
            $urlPath = [System.Uri]::UnescapeDataString($pathOnly).TrimStart('/')

            # Handle CORS preflight OPTIONS
            if ($method -eq "OPTIONS") {
                Send-Response $stream 204 "No Content" "text/plain" @()
                $client.Close()
                continue
            }

            # Parse Body for POST requests
            $body = ""
            if ($method -eq "POST") {
                $splitParts = [System.Text.RegularExpressions.Regex]::Split($rawRequest, "`r?`n`r?`n", 2)
                if ($splitParts.Length -gt 1) {
                    $body = $splitParts[1]
                }
            }

            # API: GET /api/content
            if ($urlPath -eq "api/content" -and $method -eq "GET") {
                if (Test-Path $dataPath) {
                    $dataBytes = [System.IO.File]::ReadAllBytes($dataPath)
                    Send-Response $stream 200 "OK" "application/json; charset=utf-8" $dataBytes
                } else {
                    $errBytes = [System.Text.Encoding]::UTF8.GetBytes('{"error":"not found"}')
                    Send-Response $stream 404 "Not Found" "application/json" $errBytes
                }
                $client.Close()
                continue
            }

            # API: POST /api/content (Save CMS)
            if ($urlPath -eq "api/content" -and $method -eq "POST") {
                if (-not [string]::IsNullOrEmpty($body)) {
                    [System.IO.File]::WriteAllText($dataPath, $body, [System.Text.Encoding]::UTF8)
                }
                $resBytes = [System.Text.Encoding]::UTF8.GetBytes('{"success":true,"message":"Saved"}')
                Send-Response $stream 200 "OK" "application/json; charset=utf-8" $resBytes
                $client.Close()
                continue
            }

            # API: POST /api/inquiries
            if ($urlPath -eq "api/inquiries" -and $method -eq "POST") {
                try {
                    $inquiryObj = $body | ConvertFrom-Json
                    if (Test-Path $dataPath) {
                        $contentJson = [System.IO.File]::ReadAllText($dataPath, [System.Text.Encoding]::UTF8)
                        $contentObj = $contentJson | ConvertFrom-Json
                        $newLead = [PSCustomObject]@{
                            id = "lead-" + [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
                            name = $inquiryObj.name
                            business = $inquiryObj.business
                            message = $inquiryObj.message
                            date = (Get-Date).ToString("yyyy-MM-dd HH:mm")
                            status = "New"
                        }
                        if (-not $contentObj.inquiries) {
                            $contentObj | Add-Member -MemberType NoteProperty -Name "inquiries" -Value @()
                        }
                        $list = [System.Collections.ArrayList]@($contentObj.inquiries)
                        [void]$list.Insert(0, $newLead)
                        $contentObj.inquiries = $list.ToArray()
                        $updatedJson = $contentObj | ConvertTo-Json -Depth 10
                        [System.IO.File]::WriteAllText($dataPath, $updatedJson, [System.Text.Encoding]::UTF8)
                    }
                    $resBytes = [System.Text.Encoding]::UTF8.GetBytes('{"success":true}')
                    Send-Response $stream 200 "OK" "application/json" $resBytes
                } catch {
                    $resBytes = [System.Text.Encoding]::UTF8.GetBytes('{"success":false}')
                    Send-Response $stream 400 "Bad Request" "application/json" $resBytes
                }
                $client.Close()
                continue
            }

            # Routes for Admin CMS
            if ($urlPath -eq "admin" -or $urlPath -eq "admin/" -or $urlPath -eq "wp-admin" -or $urlPath -eq "wp-admin/") {
                $urlPath = "public/admin.html"
            }

            # Default home route
            if ([string]::IsNullOrEmpty($urlPath) -or $urlPath -eq "index.html") {
                $urlPath = "preview.html"
            }

            # Resolve file path (check root and public/)
            $filePath = Join-Path $root $urlPath
            if (-not (Test-Path $filePath -PathType Leaf)) {
                $altPath = Join-Path $root ("public\" + $urlPath)
                if (Test-Path $altPath -PathType Leaf) {
                    $filePath = $altPath
                }
            }

            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $mime = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
                $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
                Send-Response $stream 200 "OK" $mime $fileBytes
            } else {
                $notFoundMsg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $urlPath")
                Send-Response $stream 404 "Not Found" "text/plain" $notFoundMsg
            }
        } catch {
            # Ignore individual client disconnects
        } finally {
            $client.Close()
        }
    }
} finally {
    $listener.Stop()
}
