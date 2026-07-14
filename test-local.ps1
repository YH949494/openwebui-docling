\
$ErrorActionPreference = "Stop"

$image = "quay.io/docling-project/docling-serve-cpu:v1.26.0"
$name = "docling-test"

Write-Host "Removing any previous test container..."
docker rm -f $name 2>$null | Out-Null

Write-Host "Starting Docling locally on port 5001..."
docker run --rm -d `
  --name $name `
  -p 5001:5001 `
  -e DOCLING_SERVE_ENABLE_UI=false `
  -e DOCLING_SERVE_MAX_FILE_SIZE=52428800 `
  -e DOCLING_SERVE_MAX_NUM_PAGES=200 `
  $image

Write-Host "Waiting for startup..."
Start-Sleep -Seconds 20

Write-Host "Testing API docs endpoint..."
$response = Invoke-WebRequest -Uri "http://localhost:5001/docs" -UseBasicParsing
Write-Host "HTTP status: $($response.StatusCode)"

Write-Host ""
Write-Host "Docling is running locally at:"
Write-Host "http://localhost:5001"
Write-Host ""
Write-Host "View logs:"
Write-Host "docker logs -f $name"
