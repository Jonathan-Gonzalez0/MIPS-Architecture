# Integración parcial de Fase III

Esta publicacion excluye PASG_Backup y deja el PASG a cargo del otro integrante.
Los archivos PASG ya presentes en el historial no se modifican. La prueba de
esta carpeta valida ID a WB mediante estimulos; no implementa fetch real.

Para ejecutar todas las pruebas compartidas, incluida la propuesta experimental:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Zero_Extend_Experiment\run_checks.ps1 -IncludeExisting
```

Resultado esperado: 2,416 comprobaciones, 0 fallos. Las 493 comprobaciones
del PASG de respaldo no forman parte de esta publicacion. OS2=11 permanece
experimental y separado de la CU principal.

Esta carpeta prueba el camino desde una entrada ID explícita hasta WB. **No es
todavía la demostración completa con PASG real.** Los archivos anteriores del
repositorio se utilizan sin modificarlos.

## Ejecutar desde la raíz del repositorio

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Fase III_DEMO\run_checks.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Fase III_DEMO\run_checks.ps1" -IncludeUnitTests
```

La primera orden ejecuta 314 comprobaciones nuevas. La segunda también ejecuta
las 1,410 comprobaciones anteriores: 1,724 en total. El script crea compilados y
trazas en una carpeta temporal e imprime su ubicación. Usa Verilog 2005, `-Wall`
y `vvp -N`; solo se suprimen las advertencias de timescale heredado de archivos
originales. Cualquier otro diagnóstico de compilación o fallo termina la prueba.

## Disponibilidad verificada

| Parte | Estado |
|---|---|
| ControlUnit, NOPMux, IDEX, EXMEM, MEMWB | Módulos reales existentes conectados |
| InstructionMemory y programa de 100 bytes / 25 instrucciones | ROM real usada como fuente de estímulos |
| FOH, SOH, ALU | Módulos reales existentes conectados en EX |
| Register File | Módulo existente; no conectado a esta prueba parcial |
| RegDst, Branch Control, Write Condition, AND, Output/Target/Writeback MUX | Lógica combinacional implementada en los archivos nuevos |
| PASG | Incompleto: únicamente existen pc_register y address_adder |
| nPC e IF/ID | No incluidos en esta publicacion |
| RF/forwarding/DHDU, TAG y Data Memory dentro del sistema integrado | No conectados: el testbench suministra explícitamente sus valores de frontera |

## Conexiones y anchos

| Origen | Destino | Ancho |
|---|---|---:|
| I_ID | ControlUnit; campos SA, inmediato y destino | 32; campos de 5/16/5 bits |
| PC_ID + 8, TA_ID, PA_ID, PB_ID | IDEX | 32 cada uno |
| SA, inmediato, RD seleccionado | IDEX | 5, 16, 5 |
| ControlUnit | NOPMux | 13 controles, 21 bits |
| NOPMux | IDEX | Los mismos 13 controles, 21 bits |
| IDEX.PA/PB/SA/I y OS1/OS2 | FOH y SOH | 32/32/5/16 y 1/2 |
| FOH.OA, SOH.OB, OP_EX | ALU | 32, 32, 4 |
| LE/EQ/GT y BranchType_EX | Branch Control | 1/1/1 y 3 |
| SOH.OB, BranchTaken y WriteCond_EX | Write Condition | 32, 1, 2 |
| RF_LE_EX AND condición | EXMEM.RF_LE_in | 1 |
| ALU.Out o PC8_EX, elegido por OutSel_EX | EXMEM.ALU_in | 32 |
| PB_EX y RD_EX | EXMEM.SD_in y RD_in | 32, 5 |
| MemToReg/RW/E/Size/SE de EX | EXMEM | 1/1/1/2/1 |
| Jump_ID OR BranchTaken_EX | Redirect_IF, frontera sin PASG conectado | 1 |
| TA_ID o TA_EX, elegido por BranchTaken_EX | Target_IF, frontera sin PASG conectado | 32 |
| EXMEM.ALU/SD/RW/E/Size/SE | Frontera Data Memory | 32/32/1/1/2/1 |
| DataMemory_DO o EXMEM.ALU, elegido por MemToReg_MEM | MEMWB.PW_in | 32 |
| EXMEM.RD y RF_LE | MEMWB.RW_in y RF_LE_in | 5, 1 |
| Clk y Reset | IDEX, EXMEM, MEMWB | 1, 1 |

No se conectan directamente RF_LE_EX a EXMEM ni ALU_MEM a MEMWB: se conservan
la condición de escritura y los MUX indicados por el diagrama. El RW de memoria
es de un bit; el RW de MEMWB es el destino de cinco bits. Jump, RegDst, SRA y SRB
permanecen en ID. No existe L_MEM en esta interfaz.

## Qué comprueba la simulación

Clk comienza en 0 y cambia cada 2 unidades; Reset comienza en 1 y baja en 3;
S comienza en 0 y sube en 72; la simulación termina en 84. Las salidas de CU
se comparan con valores esperados para los códigos máquina reales. Un modelo
de referencia independiente comprueba todos los datos y controles de los tres
registros, incluida la lógica de EX, latencias y retención entre flancos.

El NOP MUX borra su salida en 72; EX registra los ceros en 74, MEM en 78 y WB
desactiva RF_LE en 82. Una burbuja borra controles; sus datos no tienen por qué
ser cero. Reset sí borra todos los bits de los registros en el flanco positivo.

El monitor imprime PC e instrucción de la entrada **ID estimulada**, mnemónico
y controles reales en ID, EX, MEM y WB. El driver lineal ROM->ID no implementa
PASG ni IF/ID y no consume Redirect_IF. Por tanto, no valida fetch, brinco
retardado, redirección de PC, hazards ni ejecución de un programa completo.
Hasta tiempo 84 se presentan 20 de las 25 palabras en la entrada ID; los ceros
del NOP MUX suprimen las últimas capturas de control conforme a S.

PA_ID y PB_ID son estímulos que fuerzan casos concretos: MOVZ rechaza una
escritura; el primer BGEZAL no toma el branch y el segundo sí; BEQ/BGTZ toman
su branch. TA_ID es un patrón para probar el selector de targets y **no** el
target MIPS generado por TAG. DataMemory_DO es una función de prueba de la
dirección, no una RAM con tamaños, extensiones o escrituras reales.

## Bloqueos y diferencias documentales

1. Falta PASG completo con nPC e IF/ID. Esto impide presentar la figura de
   Fase III como circuito integrado y validado. No se reemplazó por constantes
   ni se creó un módulo PASG ficticio.
2. La figura de Fase III fija J=0, Clr=0, LE=1, TAI=0 y RS=0 para recorrer el
   programa de controles sin usar TAG. El diagrama completo de Fase II sí tiene
   realimentación de Jump/BranchTaken. La integración final debe identificar
   claramente qué configuración está demostrando; esta prueba deja IF expuesto.
3. Fase III pide monitorear solamente controles que llegan a cada etapa, pero
   su ejemplo menciona L_MEM. Nuestro diagrama no registra L en EXMEM. El monitor
   lo indica como ausente, sin fabricar un valor ni copiar L_EX. Hay riesgo de
   discrepancia si se exige literalmente ese campo; debe aclararse con el profesor.
4. 00233904 tiene rs=1, rt=3, rd=7 y sa=4 no utilizado; no coincide con la etiqueta
   SLLV r3,r1,r7. Se conservan sus bits y la alerta del módulo original.
5. 0471FFFD es BGEZAL r3,-3 en ambas apariciones, no BAL incondicional. 1060FFFD
   es BEQ r3,r0,-3, no B incondicional. 0C000004 es JAL con índice 4 (destino bajo
   0x10), no desplazamiento relativo de cuatro bytes.

## Para completar la entrega

- Incorporar PASG/nPC/IF-ID reales y comprobar su enlace a la ROM y a ID.
- Conectar el PASG real con la configuración explícita de Fase III: J=0, Clr=0,
  LE=1 y TAI=RS=0. Mantener identificada la diferencia con el lazo de saltos de
  Fase II, sin alterar componentes probados.
- Repetir el monitor y los checks hasta tiempo 84 con el fetch real; la latencia
  de IF/ID debe formar parte de la referencia, no asumirse igual a este driver.
- Resolver el criterio de monitoreo para L_MEM.

Para la demostración de propagación de controles, Data Memory, RF y hazards
completos no aparecen en la figura de prueba del profesor. La ejecución del
datapath completo de Fase II sí requiere conectarlos y validarlos. Esos dos
alcances no se declaran equivalentes en esta entrega parcial.
