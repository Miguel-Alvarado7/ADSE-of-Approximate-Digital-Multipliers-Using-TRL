"""Agentes tabulares VECTORIZADOS para entornos CUDA (BinaryMathEnvCUDAOptimized).

Los agentes arrastran torch y se cargan bajo demanda. Se usa __getattr__
a nivel de clase de módulo (compatible con Python 3.6, donde el __getattr__ de
módulo de PEP 562 aún no existe).
"""

import importlib
import sys
from types import ModuleType

__all__ = [
    "MonteCarloAgentCUDA",
    "QLearningAgentCUDA",
    "SarsaAgentCUDA",
]

_LAZY_MODULES = {
    "MonteCarloAgentCUDA": ".cuda.montecarlo",
    "QLearningAgentCUDA": ".cuda.qlearning",
    "SarsaAgentCUDA": ".cuda.sarsa",
}


class _AgentsModule(ModuleType):
    def __getattr__(self, name):
        module_name = _LAZY_MODULES.get(name)
        if module_name is not None:
            module = importlib.import_module(module_name, __name__)
            value = getattr(module, name)
            setattr(self, name, value)
            return value
        raise AttributeError(f"module {__name__!r} has no attribute {name!r}")


sys.modules[__name__].__class__ = _AgentsModule
