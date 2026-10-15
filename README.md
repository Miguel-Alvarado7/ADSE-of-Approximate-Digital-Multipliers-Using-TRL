# Binary Multipliers with Reinforcement Learning

Synthesis of binary multiplier circuits with RL: an agent fills a
partial-product table and the environment evaluates it as a circuit
(real Verilog on CPU, vectorized tensors on CUDA).

## Required tools

| Tool | Required | Installation |
|---|---|---|
| **Python 3.10+** | Yes | python.org (add to PATH) |
| **pip packages** | Yes | `pip install -r requirements.txt` |
| **Icarus Verilog** (`iverilog`, `vvp`) | Yes (CPU and verification) | Windows: `choco install iverilog` or installer from bleyer.org · Ubuntu: `sudo apt install iverilog` · macOS: `brew install icarus-verilog` |
| **PyTorch** | Yes (`*_cuda.py` scripts) | In `requirements.txt`. With GPU: `pip install torch --index-url https://download.pytorch.org/whl/cu124` (automatic fallback to CPU if no GPU) |
| **pygame** | Optional (render only, `BinaryMathEnvSecuencial`) | `pip install pygame` |
| **CUDA + NVIDIA driver** | Optional (GPU acceleration) | Up-to-date driver + PyTorch with cu12x support |

## Quick installation

```bash
pip install -r requirements.txt
pip install pygame          # optional
# install Icarus Verilog for your OS (table above)
```

## Usage

Each algorithm has a CPU script (iverilog per episode) and a batched CUDA one
(GPU; falls back to CPU automatically if no CUDA is available). Each writes to
its own `out/<algo>/` folder.

```bash
# CPU training (evaluates with iverilog, one episode at a time)
python train_mc.py --bits 2 --episodes 1000
python train_qlearning.py --bits 2 --episodes 1000
python train_sarsa.py --bits 2 --episodes 1000

# Batched training (GPU; falls back to CPU automatically if no CUDA)
python train_mc_cuda.py --n-envs 512 --episodes 100000
python train_qlearning_cuda.py --n-envs 512 --episodes 100000
python train_sarsa_cuda.py --n-envs 512 --episodes 100000

# Verify the Verilog of the best circuit found (from the repo root).
# A single universal testbench covers any --bits: pass the width with -D.
iverilog -s tb_multiplier -D BITS=2 -o out/simv out/montecarlo_cuda/best_multiplier_cuda.v verification/tb_multiplier_universal.v
vvp out/simv

# For other widths, change BITS and the DUT:
iverilog -s tb_multiplier -D BITS=6 -o out/simv out/montecarlo_cuda/bits6/best_multiplier_cuda.v verification/tb_multiplier_universal.v
vvp out/simv   # PASS/FAIL + MAE, Peak Error and % of exact answers
```

Note: the universal testbench and template live in `verification/`
(versioned) and the generated circuits in `out/<algo>/` (git-ignored).
The testbench runs an exhaustive 2^BITS x 2^BITS sweep comparing against A*B;
without `-D BITS=<n>` it defaults to 2 bits. The number of partial
products is not visible from simulation: count it with
`grep -c "wire pp" <dut>.v`.

## Algorithms

| Algorithm | Type | Update | CPU script | CUDA script |
|---|---|---|---|---|
| **Monte Carlo** | On-policy, first-visit | `Q += α(G − Q)` | `train_mc.py` | `train_mc_cuda.py` |
| **Q-learning** | Off-policy TD(0) | `Q += α(r + γ·max Q' − Q)` | `train_qlearning.py` | `train_qlearning_cuda.py` |
| **SARSA** | On-policy TD(0) | `Q += α(r + γ·Q' − Q)` | `train_sarsa.py` | `train_sarsa_cuda.py` |

- **CPU** reward scale: `100 − 100·error` (100 = perfect circuit).
- **CUDA** reward scale: `[-10, 0]` (0 = perfect circuit).
- CUDA agents add `--gamma` (default `0.95`) for TD.
- All CUDA updates average targets per `(s, a)` pair with
  `index_put_(accumulate=True)`: since n_envs episodes share the same
  states, advanced indexing `Q[states, actions] += ...` would drop
  all but one of the duplicates.

## Top 5 circuits

All scripts save the **5 best distinct circuits** seen during
training (ranked by return, deduplicated by grid) to the agent
folder:

- `out/montecarlo_cuda/best_multiplier_cuda.v` … `best_multiplier_cuda_5.v`
- `out/qlearning_cuda/best_multiplier_cuda.v` … `best_multiplier_cuda_5.v`
- `out/sarsa_cuda/best_multiplier_cuda.v` … `best_multiplier_cuda_5.v`
- (and analogously `best_multiplier.v` in `out/montecarlo/`, `out/qlearning/`, `out/sarsa/`)

If fewer than 5 distinct circuits exist, whatever is available is saved.

## Structure

- `envs/` — environments: `base.py` (`BinaryMathEnv`, CPU/iverilog), `pygame_env.py` (`BinaryMathEnvSecuencial`), `cuda.py` (`BinaryMathEnvCUDA`), `cuda_optimized.py` (`BinaryMathEnvCUDAOptimized`, batched with chunked streaming)
- `agents/` — shared base (`_base.py`) and per-engine subpackages:
  - `agents/cpu/` — `base.py` (tabular CPU), `montecarlo.py`, `qlearning.py`, `sarsa.py`
  - `agents/cuda/` — `base.py` (batched tabular), `montecarlo.py`, `qlearning.py`, `sarsa.py`
- `training/` — shared helpers: `baseline.py`, `plot.py`, `artifacts.py` (TopK + Verilog export)
- `verification/` — universal testbench (`tb_multiplier_universal.v`, parametrized with `-D BITS=<n>`) and CPU-environment template (`testbench_template.v`)
- `docs/environment.md` — exhaustive environment documentation
- `out/` — per-agent results (Q, returns, `best_multiplier*.v`, plots) and Verilog scratch (`out/verilog/`)

## How the CUDA optimized environment evaluates

`BinaryMathEnvCUDAOptimized` fixes the OOM of `BinaryMathEnvCUDA` by removing
the massive expansion of `(A, B)` pairs to the GPU:

1. **Caches `action_vals`** — each action value only depends on the
   exhaustive pairs and the action space, NOT on the environment or `n_envs`, so
   it is computed once (recomputed per chunk if it does not fit in memory).
2. **Evaluates each grid with a single GEMM** in float32 (with TF32 disabled
   for accuracy), with shift factors folded into the presence matrix:
   `O(n_envs·n_actions·chunk)` instead of iterating over cells.
3. **Processes test cases in chunks** (`chunk_size` auto-tuned to the
   memory budget) and exposes `commit_episodes`/`evaluate_grids` to
   evaluate full episodes or arbitrary grids in one shot.

Measured on an RTX 4000 Ada (full training batch):

```
Bits=8, n_envs=64     627 ms -> 0.93 ms   (1875 MB -> 122 MB)
Bits=8, n_envs=1024      OOM -> 13.5 ms   (846 MB)
Bits=4, n_envs=4096    51.9 ms -> 0.93 ms (1616 MB -> 30 MB)
```

## Useful flags (CUDA scripts)

- `--bits N` / `--height N` — multiplier size and table rows
- `--n-envs N` / `--episodes N` — parallelism and episode budget.
  One batch is a single GEMM, so a low `--n-envs` buys no speedup (a batch
  with 64 takes the same as one with 4096); what governs learning is the
  number of batches = `episodes / n_envs`. On GPU ~1024 is recommended; the
  script default is 512.
- `--baseline-batches N` — random-baseline batches (default 8)
- `--alpha A` / `--gamma G` — learning rate and discount (TD)
- `--device cuda|cpu` — force device (default `cuda` with fallback)
- `--early-stop VAL` — stop threshold (0.0 = perfect circuit; `none` disables it)
