param([switch]$IncludeExisting)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$resultPath = Join-Path ([System.IO.Path]::GetTempPath()) ('mips-zero-extend-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $resultPath | Out-Null

$aluSources = @(
    'ALU_System\foh\F1_Gonzalez_Rodriguez_Jonathan_foh.v'
    'ALU_System\soh\F1_Gonzalez_Rodriguez_Jonathan_soh.V'
    'ALU_System\alu\F1_Gonzalez_Rodriguez_Jonathan_alu.v'
    'ALU_System\F1_Gonzalez_Rodriguez_Jonathan_alu_system.v'
)
$commonSources = $aluSources + @(
    'Control_Unit\control_unit.v'
    'Fase III_DEMO\phase3_stage_logic.v'
    'Zero_Extend_Experiment\control_unit_zero_extend_experimental.v'
    'Zero_Extend_Experiment\soh_zero_extend_experimental.v'
)
$pipelineSources = $commonSources + @(
    'NOP_MUX\nop_mux.v'
    'Pipeline_Registers\id_ex.v'
    'Pipeline_Registers\ex_mem.v'
    'Pipeline_Registers\mem_wb.v'
    'Zero_Extend_Experiment\phase3_zero_extend_path.v'
    'Zero_Extend_Experiment\zero_extend_pipeline_tb.v'
)
$cases = @(
    @{Top='zero_extend_tb'; Sources=($commonSources + @('Zero_Extend_Experiment\zero_extend_tb.v')); Count=194; Prefix='ZERO_EXTEND_RESULT'; Experimental=$true}
    @{Top='zero_extend_pipeline_tb'; Sources=$pipelineSources; Count=208; Prefix='ZERO_EXTEND_PIPELINE_RESULT'; Experimental=$true}
)
if ($IncludeExisting) {
    $cases += @{
        Top='control_unit_coverage_tb'
        Sources=($aluSources + @('Control_Unit\control_unit.v','Control_Unit\control_unit_tb.v','Fase III_DEMO\phase3_stage_logic.v'))
        Count=290
        Prefix='COVERAGE_RESULT'
        Experimental=$false
    }
}

$experimentalPassed = 0
$existingPassed = 0
Push-Location -LiteralPath $repoRoot
try {
    foreach ($case in $cases) {
        $binary = Join-Path $resultPath ($case.Top + '.vvp')
        $buildLog = Join-Path $resultPath ($case.Top + '.build.log')
        $runLog = Join-Path $resultPath ($case.Top + '.log')
        $sources = $case.Sources
        $diagnostics = @(& iverilog -g2005 -Wall -Wno-timescale -s $case.Top -o $binary @sources 2>&1)
        $buildExit = $LASTEXITCODE
        [System.IO.File]::WriteAllLines($buildLog, [string[]]$diagnostics)
        if (($buildExit -ne 0) -or ($diagnostics.Count -ne 0)) {
            throw "Compilation diagnostics for $($case.Top): $($diagnostics -join [Environment]::NewLine)"
        }
        $trace = @(& vvp -N $binary 2>&1)
        $runExit = $LASTEXITCODE
        [System.IO.File]::WriteAllLines($runLog, [string[]]$trace)
        if ($case.Experimental -and
            (@($trace | Select-String -Pattern '^ALERT: ANDI/ORI/XORI unsupported').Count -ne 0)) {
            throw "An experimental opcode reached the original unsupported decoder. Inspect $runLog"
        }
        $expectedLine = '^' + $case.Prefix + ': passed=' + $case.Count + ' failed=0 total=' + $case.Count
        if ($case.Top -eq 'control_unit_coverage_tb') {
            $expectedLine += ' cases=143 soh_probes=4 jalr_destinations=32'
        }
        $expectedLine += '$'
        if (($runExit -ne 0) -or
            (@($trace | Select-String -Pattern '^FAIL').Count -ne 0) -or
            (@($trace | Select-String -Pattern $expectedLine).Count -ne 1)) {
            throw "Test failure in $($case.Top). Inspect $runLog"
        }
        if ($case.Experimental) { $experimentalPassed += $case.Count }
        else { $existingPassed += $case.Count }
        Write-Output "$($case.Top): passed=$($case.Count) failed=0 log=$runLog"
    }
    if ($IncludeExisting) {
        $oldTrace = @(& (Join-Path $repoRoot 'Fase III_DEMO\run_checks.ps1') -IncludeUnitTests)
        [System.IO.File]::WriteAllLines((Join-Path $resultPath 'existing_checks.log'), [string[]]$oldTrace)
        if (@($oldTrace | Select-String -Pattern '^TOTAL: passed=1724 failed=0$').Count -ne 1) {
            throw 'The existing runner did not report 1724 passes and zero failures.'
        }
        $existingPassed += 1724
        Write-Output "EXISTING_TESTS: passed=$existingPassed failed=0"
    }
    Write-Output "EXPERIMENTAL_TESTS: passed=$experimentalPassed failed=0"
    Write-Output "TOTAL: passed=$($experimentalPassed + $existingPassed) failed=0"
    Write-Output 'PROPOSAL_VALIDATED=YES; DEFINITIVE_CU_UPDATED=NO'
    Write-Output 'SHARED_SCOPE=NO_PASG_BACKUP; PARTIAL_ID_TO_WB_ONLY=YES'
    Write-Output "RESULT_DIRECTORY=$resultPath"
}
finally {
    Pop-Location
}
