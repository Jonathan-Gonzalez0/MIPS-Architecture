param([switch]$IncludeUnitTests)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$resultPath = Join-Path ([System.IO.Path]::GetTempPath()) ('mips-phase3-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $resultPath | Out-Null

$aluSources = @(
    'ALU_System\foh\F1_Gonzalez_Rodriguez_Jonathan_foh.v'
    'ALU_System\soh\F1_Gonzalez_Rodriguez_Jonathan_soh.V'
    'ALU_System\alu\F1_Gonzalez_Rodriguez_Jonathan_alu.v'
)
$cuSources = @('Control_Unit\control_unit.v', 'Control_Unit\control_unit_tb.v')
$nopSources = @('NOP_MUX\nop_mux.v', 'NOP_MUX\nop_mux_tb.v')
$idSources = @('NOP_MUX\nop_mux.v', 'Pipeline_Registers\id_ex.v', 'Pipeline_Registers\id_ex_tb.v')
$exSources = @('Pipeline_Registers\ex_mem.v', 'Pipeline_Registers\ex_mem_tb.v')
$wbSources = @('Pipeline_Registers\mem_wb.v', 'Pipeline_Registers\mem_wb_tb.v')
$integrationSources = @(
    'Fase III_DEMO\phase3_control_path.v'
    'Fase III_DEMO\phase3_stage_logic.v'
    'Fase III_DEMO\phase3_partial_tb.v'
    'Control_Unit\control_unit.v'
    'NOP_MUX\nop_mux.v'
    'Pipeline_Registers\id_ex.v'
    'Pipeline_Registers\ex_mem.v'
    'Pipeline_Registers\mem_wb.v'
    'Instruction Memory\instruction_memory.v'
) + $aluSources

$cases = @()
if ($IncludeUnitTests) {
    $cases += @{ Top='control_unit_tb'; Sources=$cuSources; Count=25; Prefix='RESULT' }
    $cases += @{ Top='control_unit_alu_tb'; Sources=($cuSources + $aluSources + @('ALU_System\F1_Gonzalez_Rodriguez_Jonathan_alu_system.v')); Count=26; Prefix='ALU_RESULT' }
    $cases += @{ Top='nop_mux_tb'; Sources=$nopSources; Count=100; Prefix='RESULT' }
    $cases += @{ Top='id_ex_tb'; Sources=$idSources; Count=730; Prefix='RESULT' }
    $cases += @{ Top='ex_mem_tb'; Sources=$exSources; Count=328; Prefix='RESULT' }
    $cases += @{ Top='mem_wb_tb'; Sources=$wbSources; Count=176; Prefix='RESULT' }
    $cases += @{ Top='mem_wb_path_tb'; Sources=($wbSources + @('Pipeline_Registers\ex_mem.v')); Count=25; Prefix='PATH_RESULT' }
}
$cases += @{ Top='phase3_partial_tb'; Sources=$integrationSources; Count=314; Prefix='PARTIAL_RESULT' }

$totalPassed = 0
Push-Location -LiteralPath $repoRoot
try {
    foreach ($case in $cases) {
        $top = $case.Top
        $sources = $case.Sources
        $executable = Join-Path $resultPath ($top + '.vvp')
        $buildLog = Join-Path $resultPath ($top + '.build.log')
        $runLog = Join-Path $resultPath ($top + '.log')

        # Only inherited-timescale warnings from original files are disabled.
        $diagnostics = @(& iverilog -g2005 -Wall -Wno-timescale -s $top -o $executable @sources 2>&1)
        $buildExit = $LASTEXITCODE
        [System.IO.File]::WriteAllLines($buildLog, [string[]]$diagnostics)
        if (($buildExit -ne 0) -or ($diagnostics.Count -ne 0)) {
            throw "Compilation diagnostics for ${top}: $($diagnostics -join [Environment]::NewLine)"
        }

        $trace = @(& vvp -N $executable 2>&1)
        $runExit = $LASTEXITCODE
        [System.IO.File]::WriteAllLines($runLog, [string[]]$trace)
        $expectedLine = '^' + $case.Prefix + ': passed=' + $case.Count + ' failed=0 total=' + $case.Count
        if ($top -eq 'phase3_partial_tb') { $expectedLine += ' end_time=84' }
        $expectedLine += '$'
        if (($runExit -ne 0) -or
            (@($trace | Select-String -Pattern '^FAIL').Count -ne 0) -or
            (@($trace | Select-String -Pattern $expectedLine).Count -ne 1)) {
            throw "Test failure in $top. Inspect $runLog"
        }
        $totalPassed += $case.Count
        Write-Output "$top : passed=$($case.Count) failed=0 log=$runLog"
    }
    Write-Output "TOTAL: passed=$totalPassed failed=0"
    Write-Output 'FULL_PHASE_III_COMPLETE=NO: PASG/nPC/IF-ID are missing; integration is partial.'
    Write-Output "RESULT_DIRECTORY=$resultPath"
}
finally {
    Pop-Location
}
