# Extension con ceros: propuesta experimental

Este directorio permite estudiar ANDI, ORI y XORI sin modificar ningun archivo
existente. El SOH original de Jonathan y la CU definitiva permanecen intactos.
No representa la incorporacion definitiva de estas instrucciones al procesador.

## Ejecutar desde la raiz del repositorio

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Zero_Extend_Experiment\run_checks.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\Zero_Extend_Experiment\run_checks.ps1 -IncludeExisting
```

La primera orden ejecuta 402 comprobaciones experimentales. La segunda agrega
las 2,014 anteriores: 2,416 comprobaciones en conjunto. Los archivos .vvp y logs
se escriben en TEMP; el script imprime su ubicacion.

Se compila con Verilog 2005, -Wall y -Wno-timescale. Solo se desactiva el
diagnostico de timescale heredado; otros diagnosticos hacen fallar el script.
vvp -N y los contadores detectan fallos y terminaciones prematuras.

## Archivos

| Archivo | Contenido |
|---|---|
| soh_zero_extend_experimental.v | SOH independiente con la cuarta seleccion |
| control_unit_zero_extend_experimental.v | Adaptador que habilita los tres opcodes y reutiliza la CU original para los demas |
| phase3_zero_extend_path.v | Copia experimental del camino ID-WB; cambia el nombre del modulo y los tipos de CU y SOH |
| zero_extend_tb.v | SOH, controles, resultados de ALU y comparacion con el programa de ROM |
| zero_extend_pipeline_tb.v | Comprobacion de la propuesta con los registros y logica de etapas existentes |
| run_checks.ps1 | Pruebas nuevas y regresion opcional de las 2,014 anteriores |
| README.md | Funcionamiento, limites e incorporacion futura |

La copia del camino conserva las conexiones de
Fase III_DEMO/phase3_control_path.v. No sustituye el archivo original.

## Selecciones del SOH

| OS2 | SOH original | Propuesta |
|---|---|---|
| 00 | RB | RB |
| 01 | I con extension de signo | Sin cambio |
| 10 | {I,16'b0} | Sin cambio |
| 11 | Cero por el default del codigo | {16'b0,I} |

Por ejemplo, I=8001 produce 00008001 con la nueva seleccion, en lugar de
FFFF8001 de la seleccion 01. Solo cambia la semantica del codigo 11.
No aumenta el ancho de OS2 ni se agrega un puerto.

## Controles propuestos

| Instruccion | Opcode | OP de ALU | OS2 | RegDst | RF_LE | MemToReg | SRA | SRB |
|---|---|---|---|---|---|---|---|---|
| ANDI | 001100 | 0010 | 11 | 00 | 1 | 1 | 1 | 0 |
| ORI | 001101 | 0011 | 11 | 00 | 1 | 1 | 1 | 0 |
| XORI | 001110 | 0100 | 11 | 00 | 1 | 1 | 1 | 0 |

OS1=0 selecciona rs. RegDst=00 selecciona rt. MemToReg=1 elige el resultado
ALU segun nuestro diagrama. Jump, BranchType, WriteCond, RW, E, Size, SE, L
y OutSel se mantienen en cero. SRA y SRB son las indicaciones de registros
fuente del diagrama, no instrucciones de desplazamiento.

El adaptador alimenta NOP a la CU original solo para estos tres opcodes,
evitando su alerta de instruccion no soportada. Para las demas instrucciones
copia las 17 salidas originales. Esta organizacion evita duplicar todo el
decodificador durante el experimento. En una version definitiva resulta mas
simple agregar directamente los tres casos a la CU.

## Pruebas y alcance

- 48 comprobaciones del SOH: cuatro selectores, cuatro inmediatos y tres RB.
  Las tres selecciones anteriores coinciden con el SOH original.
- 96 comprobaciones de controles y resultados: tres instrucciones, inmediatos
  0000/7FFF/8001/FFFF y rs=00000000/FFFFFFFF/A5A55A5A/80000000.
- 50 comprobaciones de compatibilidad: controles y resultados para las 25
  palabras del archivo real de instrucciones, comparados con CU y ALU originales.
- 208 comprobaciones del camino experimental: ID, NOP MUX, ID/EX, FOH/SOH/ALU,
  EX/MEM, MUX de Writeback y MEM/WB, incluyendo retencion, reset sincrono,
  burbujas y recuperacion. Se mezclan ANDI/ORI/XORI con ADDI, LUI y OR.
- Con -IncludeExisting se ejecutan las 290 pruebas ampliadas de CU y el runner
  Fase III_DEMO/run_checks.ps1 -IncludeUnitTests, que aporta 1,724.

El testbench del camino genera instrucciones y operandos directamente en ID.
No contiene PASG ni Register File, y la respuesta de memoria es un valor de
prueba. Para estas instrucciones MemToReg=1 debe seleccionar ALU, no ese valor.
El resultado final de recuperacion es ORI: 80000000 | 00008001 = 80008001,
con destino r5 y RF_LE=1.

Esta publicacion excluye PASG_Backup y sus 493 comprobaciones. El programa de
ROM se conserva sin cambios. La integracion compartida usa un driver ROM->ID
y termina en t=84; no valida fetch mediante un PASG real. El paso por WB no
equivale a escribir un Register File conectado ni a ejecutar una CPU completa.

## Revision documental

Fase I, Tabla 2, marca OS2=11 como "No used". No exige que produzca cero.
La propuesta asigna una funcion al codigo no utilizado, conservando 00/01/10.
Sin embargo, Fase II indica que los componentes de Fase I no se deben modificar
al integrarlos y pide consultar al profesor si hace falta un cambio.
Conservar el archivo original protege el trabajo de Jonathan, pero no reemplaza
esa consulta antes de adoptar la nueva funcion en el diseno definitivo.

Se revisaron las especificaciones del proyecto y las notas de MIPS. El formato
inmediato usa rt como destino. La fila de XORI en las notas escribe rd en la
operacion, aunque el propio formato y la sintaxis usan rt; aqui se conserva
RegDst=00, seleccionando rt. Los inmediatos logicos se extienden con ceros,
segun el comportamiento MIPS32 solicitado.

## Cambios necesarios si se adopta la propuesta

1. Conservar un SOH nuevo en archivo independiente, con nombre de modulo
   distinto. No hace falta editar el SOH original de Jonathan.
2. En Control_Unit/control_unit.v habilitar ANDI/ORI/XORI con los controles de
   la tabla y actualizar la alerta y el comentario que actualmente los declaran
   pendientes.
3. En Fase III_DEMO/phase3_control_path.v cambiar el tipo de la instancia
   second_operand a la nueva version del SOH. Mantener exactamente:
   PB_EX -> RB, I_EX[15:0] -> I, OS2_EX[1:0] -> OS2, OB -> ALU.B.
4. En Control_Unit/control_unit_tb.v actualizar las expectativas de los nueve
   casos que ahora rechazan ANDI/ORI/XORI y la prueba de limitacion del SOH.
   El camino numerico de las pruebas ampliadas debe instanciar la nueva version;
   las pruebas del SOH original pueden conservarse como referencia.
5. En Fase III_DEMO/run_checks.ps1 y Zero_Extend_Experiment/run_checks.ps1 agregar
   el archivo nuevo a las listas de fuentes. Incluir las pruebas logicas nuevas
   y sus conteos, conservando la regresion anterior que siga siendo aplicable.
6. Documentar OS2=11 en la tabla del SOH y acordar la extension con el profesor.

No cambian ALU, FOH, NOP MUX, ID/EX, EX/MEM, MEM/WB, PASG, ROM, ni los anchos
de sus conexiones. OS2 ya tiene dos bits a lo largo de CU -> NOP MUX -> ID/EX
-> SOH. El bus de controles sigue teniendo 21 bits.

ALU_System/F1_Gonzalez_Rodriguez_Jonathan_alu_system.v tambien instancia el
SOH original. El camino integrado actual no utiliza ese wrapper. Si despues
se necesita un ALU System con la nueva funcion, conviene crear otro wrapper
independiente y seleccionar ese modulo en sus consumidores, conservando
intacto el archivo de Jonathan.

Ninguno de los cambios definitivos de esta lista se aplica en este experimento.
