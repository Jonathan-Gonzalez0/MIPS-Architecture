param(
    [Parameter(Mandatory = $true)]
    [string] $Testbench
)

$ErrorActionPreference = 'Stop'
$iverilogPath = 'C:\iverilog\bin\iverilog.exe'
$vvpPath = 'C:\iverilog\bin\vvp.exe'
$simulationPath = $null
$locationChanged = $false
$resultCode = 1

try {
    $testbenchFile = Get-Item -LiteralPath $Testbench
    if ($testbenchFile.PSIsContainer -or $testbenchFile.Extension -ne '.v') {
        throw 'Open and save your Verilog testbench (.v) before running this task.'
    }
    foreach ($programPath in @($iverilogPath, $vvpPath)) {
        if (-not (Test-Path -LiteralPath $programPath -PathType Leaf)) {
            throw "Simulator executable not found: $programPath"
        }
    }

    $sourceDirectory = $testbenchFile.Directory.FullName
    $otherSources = @(Get-ChildItem -LiteralPath $sourceDirectory -File |
        Where-Object { $_.Extension -eq '.v' -and $_.FullName -ne $testbenchFile.FullName } |
        Sort-Object Name)
    $simulationPath = Join-Path ([System.IO.Path]::GetTempPath()) (
        'verilog-' + [guid]::NewGuid().ToString('N') + '.vvp'
    )

    # Sibling modules are library sources, so other testbenches do not run.
    $compilerArgs = @('-I', $sourceDirectory, '-o', $simulationPath)
    foreach ($source in $otherSources) {
        $compilerArgs += @('-l', $source.FullName)
    }
    $compilerArgs += $testbenchFile.FullName

    Push-Location -LiteralPath $sourceDirectory
    $locationChanged = $true
    Write-Host "Compiling $($testbenchFile.Name)..."
    & $iverilogPath @compilerArgs
    $resultCode = $LASTEXITCODE

    if ($resultCode -eq 0) {
        Write-Host "Running $($testbenchFile.Name)..."
        & $vvpPath $simulationPath
        $resultCode = $LASTEXITCODE
    }
} catch {
    Write-Host "Verilog task: $($_.Exception.Message)" -ForegroundColor Red
    $resultCode = 1
} finally {
    if ($locationChanged) {
        Pop-Location
    }
    if ($simulationPath -and (Test-Path -LiteralPath $simulationPath -PathType Leaf)) {
        Remove-Item -LiteralPath $simulationPath -Force -ErrorAction SilentlyContinue
    }
}

exit $resultCode
