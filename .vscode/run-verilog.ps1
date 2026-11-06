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
    $otherSources = @(Get-ChildItem -LiteralPath $sourceDirectory -File -Recurse |
        Where-Object {
            $_.Extension -eq '.v' -and
            $_.FullName -ne $testbenchFile.FullName -and
            $_.BaseName -notmatch '_tb$'
        } |
        Sort-Object FullName)
    $simulationPath = Join-Path ([System.IO.Path]::GetTempPath()) (
        'verilog-' + [guid]::NewGuid().ToString('N') + '.vvp'
    )

    # Include implementations in child folders; only the active testbench is a root.
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
        if ($testbenchFile.BaseName -eq 'MIPS_top_tb') {
            $tracePath = Join-Path $sourceDirectory 'MIPS_top_output.txt'
            $simulationOutput = @()
            $simulationErrorPreference = $ErrorActionPreference
            try {
                # Capture module alerts and native errors without losing vvp's exit code.
                $ErrorActionPreference = 'Continue'
                & $vvpPath $simulationPath 2>&1 | Tee-Object -Variable simulationOutput
                $resultCode = $LASTEXITCODE
            } finally {
                $ErrorActionPreference = $simulationErrorPreference
                $simulationOutput | ForEach-Object { $_.ToString() } |
                    Set-Content -LiteralPath $tracePath -Encoding UTF8
            }
            Write-Host "Simulation output saved to $tracePath"
        } else {
            & $vvpPath $simulationPath
            $resultCode = $LASTEXITCODE
        }
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
