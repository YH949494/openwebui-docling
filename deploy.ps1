\
$ErrorActionPreference = "Stop"

$app = "yh-openwebui-docling"

Write-Host "Checking Fly CLI..."
fly version

Write-Host "Checking authentication..."
fly auth whoami

Write-Host "Checking whether app exists..."
$exists = $true
try {
    fly status -a $app | Out-Null
} catch {
    $exists = $false
}

if (-not $exists) {
    Write-Host "Creating Fly app: $app"
    fly apps create $app
}

Write-Host "Deploying Docling..."
fly deploy -a $app

Write-Host ""
Write-Host "Deployment finished."
Write-Host "Private OpenWebUI URL:"
Write-Host "http://$app.internal:5001"
Write-Host ""
Write-Host "Check status:"
Write-Host "fly status -a $app"
Write-Host ""
Write-Host "Check logs:"
Write-Host "fly logs -a $app"
