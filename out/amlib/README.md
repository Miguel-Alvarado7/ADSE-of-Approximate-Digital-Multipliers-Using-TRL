# State-of-the-art baselines for the LibreLane flow

26 reference multipliers at 2, 4 and 6 bits, ready for `make run`
from `/home/gmunserver/out`. All expose the same top as the
agent-generated circuits:

    module multiplier (input [B-1:0] A, input [B-1:0] B, output [2B-1:0] P);

Each `.v` is self-contained (single file, no `include`), which is what
the `Makefile` requires when copying the RTL to `src/`.

## Usage

    cd /home/gmunserver/out
    make list          # now lists 101 designs (75 RL + 26 baselines)
    make run           # inside the LibreLane nix-shell
    make csv-final

`amlib` is already in `ALGORITHMS`. Folders are named `bits2/`, `bits4/`
and `bits6/` so the Makefile derives the clock period (5 / 10 / 20 ns)
the same way as for the agent circuits.

## What is here and where it comes from

| File | RTL origin | Reference |
|---|---|---|
| `exact_array.v` | Generated | Exact array multiplier. Normalizes area and power. |
| `bam_h*_v*.v` | Reimplemented | Mahdiani, Ahmadi, Fakhraie & Lucas, *Bio-inspired imprecise computational blocks*, IEEE TCAS-I 57(4), 2010. |
| `udm_kulkarni.v` | **Verbatim from AM-Lib** | Kulkarni, Gupta & Ercegovac, *Trading accuracy for power with an underdesigned multiplier architecture*, VLSI Design 2011. |
| `drum_k*.v` | **Verbatim from AM-Lib** | Hashemi, Bahar & Reda, *DRUM: A Dynamic Range Unbiased Multiplier*, ICCAD 2015. |

Source library: <https://github.com/skycrapers/AM-Lib>. Also cite the
survey: Wu, Chen, Xiao, Wang, Wen, Han, Yin, Qian & Zhuo, *A Survey on
Approximate Multiplier Designs for Energy Efficiency*, ACM TODAES, 2023,
doi:10.1145/3610291.

## Three caveats that affect how results are reported

**1. BAM is reimplemented, not copied.** The BAM `top.v` in AM-Lib is
hand-unrolled for 16 bits and does not support any other width. The pruning
rule is identical to theirs (`pp(i,j)` is kept if `j >= HOR` and `(i+j) >= VER`),
but the RTL is ours. State it that way in any publication.

**2. Two RTL styles coexist here.** `exact_array` and `bam_*` are written
in the same column style as the agent circuits, so their area is directly
comparable. `udm_kulkarni` and `drum_*` are the original structural RTL
from AM-Lib: their area includes the coding style, not just the algorithm.
Do not mix both groups in a single curve without saying so.

**3. Width coverage.** UDM exists only at 2 and 4 bits: its `ApproxMult` is
recursive over halves and at 6 bits the recursion does not terminate. DRUM
only at 4 and 6 bits: at 2 bits there is no room left for the `k` parameter.

## Accuracy already measured

`accuracy_metrics.csv` carries MED, NMED, peak error and ER for all 26,
measured with an exhaustive sweep using the project's
`verification/tb_multiplier_universal.v`. It joins with the `make csv-final`
output on `(algorithm, configuration, topology)` to get the
accuracy/area frontier without re-simulating.
