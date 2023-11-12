Write-Host "Please drag and drop the Bitwarden JSON export file here, then press Enter:"
$jsonFilePath = Read-Host

# Remove quotes if added by the drag-and-drop operation
$jsonFilePath = $jsonFilePath -replace '"',''

# Check if the file exists
if (-not (Test-Path -Path $jsonFilePath)) {
    Write-Host "File not found. Please ensure the file path is correct."
    exit
}

# Read and parse the JSON file
try {
    $jsonData = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
} catch {
    Write-Host "Failed to read or parse the JSON file. Please ensure the file is a valid JSON format."
    exit
}

# Create a hashtable to track duplicates and a list for unique items
$duplicateTracker = @{}
$uniqueItems = @()

# Iterate over each item in the JSON data
foreach ($item in $jsonData.items) {
    # Extract item name, URI, username, and password
    $itemName = $item.name
    $itemUsername = $null
    $itemPassword = $null

    if ($item.login) {
        $itemUsername = $item.login.username
        $itemPassword = $item.login.password
    }

    # Create a unique key based on item name, username, and password
    $uniqueKey = "$itemName|$itemUsername|$itemPassword"

    # Check if this key already exists in the hashtable
    if ($duplicateTracker.ContainsKey($uniqueKey)) {
        $duplicateTracker[$uniqueKey] += 1
    } else {
        $duplicateTracker.Add($uniqueKey, 1)
        $uniqueItems += $item
    }
}

# Display the duplicates
foreach ($key in $duplicateTracker.Keys) {
    if ($duplicateTracker[$key] -gt 1) {
        Write-Host "Duplicate found: $key (Count: $($duplicateTracker[$key]))"
    }
}

# Ask the user if they want to remove duplicates
Write-Host "Do you want to remove the duplicates? (Y/N)"
$removeDuplicates = Read-Host

if ($removeDuplicates -eq "Y" -or $removeDuplicates -eq "y") {
    # Update JSON data with unique items only
    $jsonData.items = $uniqueItems

    # Define the new file path
    $newFilePath = [System.IO.Path]::ChangeExtension($jsonFilePath, ".nodupes.json")

    # Save the updated JSON data to a new file
    $jsonData | ConvertTo-Json -Depth 100 | Set-Content -Path $newFilePath
    Write-Host "Duplicates removed. New file saved as: $newFilePath"
} else {
    Write-Host "No changes made to the original file."
}

Write-Host "Process complete."
