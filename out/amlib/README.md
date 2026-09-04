# Baselines del estado del arte para el flujo LibreLane

26 multiplicadores de referencia a 2, 4 y 6 bits, listos para `make run`
desde `/home/gmunserver/out`. Todos exponen el mismo top que los circuitos
generados por los agentes:

    module multiplier (input [B-1:0] A, input [B-1:0] B, output [2B-1:0] P);

Cada `.v` es autocontenido (un solo fichero, sin `include`), que es lo que
exige el `Makefile` al copiar el RTL a `src/`.

## Uso

    cd /home/gmunserver/out
    make list          # ahora lista 101 diseños (75 RL + 26 baselines)
    make run           # dentro del nix-shell de LibreLane
    make csv-final

`amlib` ya está en `ALGORITHMS`. Las carpetas se llaman `bits2/`, `bits4/`
y `bits6/` para que el Makefile deduzca el período de reloj (5 / 10 / 20 ns)
igual que con los circuitos del agente.

## Qué hay y de dónde viene

| Fichero | Origen del RTL | Referencia |
|---|---|---|
| `exact_array.v` | Generado | Multiplicador array exacto. Normaliza área y potencia. |
| `bam_h*_v*.v` | Reimplementado | Mahdiani, Ahmadi, Fakhraie & Lucas, *Bio-inspired imprecise computational blocks*, IEEE TCAS-I 57(4), 2010. |
| `udm_kulkarni.v` | **Verbatim de AM-Lib** | Kulkarni, Gupta & Ercegovac, *Trading accuracy for power with an underdesigned multiplier architecture*, VLSI Design 2011. |
| `drum_k*.v` | **Verbatim de AM-Lib** | Hashemi, Bahar & Reda, *DRUM: A Dynamic Range Unbiased Multiplier*, ICCAD 2015. |

Librería de origen: <https://github.com/skycrapers/AM-Lib>. Citar además la
survey: Wu, Chen, Xiao, Wang, Wen, Han, Yin, Qian & Zhuo, *A Survey on
Approximate Multiplier Designs for Energy Efficiency*, ACM TODAES, 2023,
doi:10.1145/3610291.

## Tres advertencias que afectan a cómo se reportan los resultados

**1. BAM está reimplementado, no copiado.** El `top.v` de BAM en AM-Lib está
desenrollado a mano para 16 bits y no admite otro ancho. La regla de poda es
idéntica a la suya (se conserva `pp(i,j)` si `j >= HOR` y `(i+j) >= VER`),
pero el RTL es nuestro. Debe decirse así en cualquier publicación.

**2. Dos estilos de RTL conviven aquí.** `exact_array` y `bam_*` están
escritos en el mismo estilo por columnas que los circuitos del agente, así
que su área es comparable directamente. `udm_kulkarni` y `drum_*` son el RTL
estructural original de AM-Lib: su área incluye el estilo de codificación,
no sólo el algoritmo. No mezclar ambos grupos en una misma curva sin decirlo.

**3. Coberturas de ancho.** UDM sólo existe en 2 y 4 bits: su `ApproxMult` es
recursivo por mitades y a 6 bits la recursión no termina. DRUM sólo en 4 y 6
bits: a 2 bits no queda margen para el parámetro `k`.

## Precisión ya medida

`accuracy_metrics.csv` trae MED, NMED, peak error y ER de los 26, medidos con
barrido exhaustivo usando `verification/tb_multiplier_universal.v` del repo
del proyecto. Se cruza con la salida de `make csv-final` por
`(algorithm, configuration, topology)` para obtener la frontera
precisión/área sin volver a simular.
