"""Baselines aleatorios (referencia) para CPU y CUDA."""

import numpy as np

def random_baseline_cuda(agent_cls, env, n_batches, seed):
    """Política aleatoria uniforme como referencia (batched).

    Reutiliza el sampler del agente con epsilon=1.0 (exploración pura).
    `agent_cls` es cualquier TabularAgentCUDA; con epsilon=1.0 los valores de
    Q no influyen.

    Returns:
        (n_batches*n_envs,) float — retornos de cada episodio aleatorio.
    """
    agent = agent_cls(
        n_states=env.CC + 1,
        n_actions=env.n_actions,
        device=env.device.type,
        seed=seed,
    )
    returns_all = []
    for _ in range(n_batches):
        _, _, returns = agent.collect_batch(env, epsilon=1.0)
        returns_all.append(returns.cpu().numpy())
    return np.concatenate(returns_all)
