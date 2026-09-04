SHELL := /bin/bash

# ============================================================
# CONFIGURACIÓN
# ============================================================

PDK := sky130A
RUN_TAG := run1

RESULTS_DIR := librelane_runs

FINAL_CSV := final_metrics.csv

ALGORITHMS := montecarlo_cuda qlearning_cuda sarsa_cuda amlib

TIMEOUT := 1800


# ============================================================
# Buscar todos los Verilog
# ============================================================

VERILOG_FILES := $(shell find $(ALGORITHMS) -type f -name '*.v' | sort)


# ============================================================
# Targets
# ============================================================

.PHONY: all help list dirs run force csv csv-final clean

all: run


help:
	@echo ""
	@echo "=============================================="
	@echo " LibreLane batch flow"
	@echo "=============================================="
	@echo ""
	@echo "make list       -> listar todos los Verilog"
	@echo "make dirs       -> crear directorios"
	@echo "make run        -> ejecutar todos los diseños"
	@echo "make force      -> borrar runs y ejecutar todo"
	@echo "make csv        -> generar CSV de metricas"
	@echo "make csv-final  -> generar CSV con TODAS las metricas de runs/$(RUN_TAG)/final"
	@echo "make clean      -> borrar resultados"
	@echo ""


# ============================================================
# LISTAR VERILOG
# ============================================================

list:
	@echo ""
	@echo "=============================================="
	@echo " Verilog encontrados"
	@echo "=============================================="
	@echo ""

	@find $(ALGORITHMS) -type f -name '*.v' | sort

	@echo ""
	@echo "Total: $$(find $(ALGORITHMS) -type f -name '*.v' | wc -l)"
	@echo ""


# ============================================================
# CREAR DIRECTORIOS
# ============================================================

dirs:
	@echo ""
	@echo "Creando directorios..."
	@echo ""

	@for file in $(VERILOG_FILES); do \
		algorithm="$$(echo "$$file" | cut -d/ -f1)"; \
		configuration="$$(echo "$$file" | cut -d/ -f2)"; \
		filename="$$(basename "$$file" .v)"; \
		mkdir -p "$(RESULTS_DIR)/$$algorithm/$$configuration/$$filename"; \
		echo "  -> $(RESULTS_DIR)/$$algorithm/$$configuration/$$filename"; \
	done

	@echo ""
	@echo "Directorios creados."


# ============================================================
# EJECUTAR LIBRELANE
# ============================================================

run: dirs
	@set -e; \
	\
	echo ""; \
	echo "=============================================="; \
	echo " Comprobando LibreLane"; \
	echo "=============================================="; \
	\
	if ! command -v librelane >/dev/null 2>&1; then \
		echo ""; \
		echo "ERROR: librelane no está disponible."; \
		echo ""; \
		echo "Debes ejecutar make desde dentro del nix-shell"; \
		echo "del repositorio de LibreLane."; \
		echo ""; \
		exit 1; \
	fi; \
	\
	echo "LibreLane encontrado:"; \
	which librelane; \
	echo ""; \
	\
	echo "=============================================="; \
	echo " Iniciando ejecuciones"; \
	echo "=============================================="; \
	echo ""; \
	\
	for file in $(VERILOG_FILES); do \
		\
		algorithm="$$(echo "$$file" | cut -d/ -f1)"; \
		configuration="$$(echo "$$file" | cut -d/ -f2)"; \
		filename="$$(basename "$$file")"; \
		topology="$${filename%.v}"; \
		\
		case "$$configuration" in \
			bits2*) \
				bits=2; \
				period=5.0; \
				;; \
			bits4*) \
				bits=4; \
				period=10.0; \
				;; \
			bits6*) \
				bits=6; \
				period=20.0; \
				;; \
			*) \
				echo "ERROR: no puedo determinar los bits de $$file"; \
				exit 1; \
				;; \
		esac; \
		\
		design_dir="$(RESULTS_DIR)/$$algorithm/$$configuration/$$topology"; \
		src_dir="$$design_dir/src"; \
		run_dir="$$design_dir/runs/$(RUN_TAG)"; \
		config="$$design_dir/config.json"; \
		log="$$design_dir/librelane.log"; \
		\
		echo ""; \
		echo "----------------------------------------------"; \
		echo "Algorithm    : $$algorithm"; \
		echo "Configuration: $$configuration"; \
		echo "Topology     : $$topology"; \
		echo "Bits         : $$bits"; \
		echo "RTL          : $$file"; \
		echo "Output       : $$design_dir"; \
		echo "Clock        : $$period ns"; \
		echo "----------------------------------------------"; \
		\
		mkdir -p "$$src_dir"; \
		\
		cp "$$file" "$$src_dir/$$filename"; \
		\
		printf '%s\n' \
			'{' \
			'  "DESIGN_NAME": "multiplier",' \
			'  "VERILOG_FILES": "dir::src/*.v",' \
			'  "CLOCK_PORT": null,' \
			"  \"CLOCK_PERIOD\": $$period," \
			'  "FP_CORE_UTIL": 10,' \
			'  "PDN_VOFFSET": 2,' \
			'  "PDN_HOFFSET": 2,' \
			'  "PDN_VPITCH": 30,' \
			'  "PDN_HPITCH": 30' \
			'}' \
			> "$$config"; \
		\
		if [ -f "$$design_dir/metrics.json" ]; then \
			echo "[SKIP] metrics.json ya existe"; \
			continue; \
		fi; \
		\
		rm -rf "$$run_dir"; \
		\
		echo "Ejecutando LibreLane..."; \
		\
		if timeout $(TIMEOUT) \
			librelane \
				--pdk $(PDK) \
				--run-tag $(RUN_TAG) \
				--condensed \
				"$$config" \
				> "$$log" 2>&1; \
		then \
			echo "[OK] LibreLane terminó correctamente"; \
		else \
			echo "[ERROR] LibreLane falló"; \
			echo "        Log: $$log"; \
			continue; \
		fi; \
		\
		if [ -f "$$run_dir/final/metrics.json" ]; then \
			cp "$$run_dir/final/metrics.json" \
				"$$design_dir/metrics.json"; \
			echo "[OK] metrics.json guardado"; \
		else \
			echo "[WARNING] No se encontró:"; \
			echo "           $$run_dir/final/metrics.json"; \
		fi; \
	\
	done

	@echo ""
	@echo "=============================================="
	@echo " Batch terminado"
	@echo "=============================================="
	@echo ""


# ============================================================
# FORZAR EJECUCIÓN
# ============================================================

force:
	@echo "Eliminando ejecuciones anteriores..."
	@rm -rf "$(RESULTS_DIR)"
	@$(MAKE) run


# ============================================================
# GENERAR CSV
# ============================================================

csv:
	@echo ""
	@echo "Generando combined_librelane_results.csv..."
	@echo ""

	@printf '%s\n' \
		"algorithm,configuration,topology,bits,status,instance_area,die_area,wns,tns" \
		> combined_librelane_results.csv

	@for metrics in $$(find "$(RESULTS_DIR)" -type f -name 'metrics.json' | sort); do \
		\
		topology="$$(basename "$$(dirname "$$metrics")")"; \
		configuration="$$(basename "$$(dirname "$$(dirname "$$metrics")")")"; \
		algorithm="$$(basename "$$(dirname "$$(dirname "$$(dirname "$$metrics")")")")"; \
		\
		case "$$configuration" in \
			bits2*) bits=2 ;; \
			bits4*) bits=4 ;; \
			bits6*) bits=6 ;; \
			*) bits="" ;; \
		esac; \
		\
		instance_area="$$(jq -r '.design__instance__area // empty' "$$metrics" 2>/dev/null)"; \
		die_area="$$(jq -r '.design__die__area // empty' "$$metrics" 2>/dev/null)"; \
		wns="$$(jq -r '.timing__setup__ws // empty' "$$metrics" 2>/dev/null)"; \
		tns="$$(jq -r '.timing__setup__tns // empty' "$$metrics" 2>/dev/null)"; \
		\
		echo "$$algorithm,$$configuration,$$topology,$$bits,ok,$$instance_area,$$die_area,$$wns,$$tns" \
			>> combined_librelane_results.csv; \
	done

	@echo "CSV generado:"
	@echo "  combined_librelane_results.csv"
	@echo ""


# ============================================================
# GENERAR CSV COMPLETO DESDE runs/$(RUN_TAG)/final/metrics.json
# ============================================================

csv-final:
	@echo ""
	@echo "Generando $(FINAL_CSV)..."
	@echo ""

	@set -e; \
	\
	if ! command -v jq >/dev/null 2>&1; then \
		echo "ERROR: jq no está disponible."; \
		exit 1; \
	fi; \
	\
	metrics_files="$$(find "$(RESULTS_DIR)" -type f \
		-path '*/runs/$(RUN_TAG)/final/metrics.json' | sort)"; \
	\
	if [ -z "$$metrics_files" ]; then \
		echo "ERROR: no se encontró ningún runs/$(RUN_TAG)/final/metrics.json"; \
		echo "       en $(RESULTS_DIR)"; \
		exit 1; \
	fi; \
	\
	keys="$$(jq -s 'map(keys) | add | unique' $$metrics_files)"; \
	\
	{ \
		printf '%s' "algorithm,configuration,topology,bits,clock_period,critical_path_ns,"; \
		echo "$$keys" | jq -r '@csv'; \
	} > $(FINAL_CSV); \
	\
	for metrics in $$metrics_files; do \
		\
		design_dir="$$(dirname "$$(dirname "$$(dirname "$$(dirname "$$metrics")")")")"; \
		topology="$$(basename "$$design_dir")"; \
		configuration="$$(basename "$$(dirname "$$design_dir")")"; \
		algorithm="$$(basename "$$(dirname "$$(dirname "$$design_dir")")")"; \
		\
		case "$$configuration" in \
			bits2*) bits=2; period=5.0 ;; \
			bits4*) bits=4; period=10.0 ;; \
			bits6*) bits=6; period=20.0 ;; \
			*) bits=""; period="" ;; \
		esac; \
		\
		ws="$$(jq -r '.timing__setup__ws // empty' "$$metrics")"; \
		\
		critical_path="$$(LC_ALL=C awk -v p="$$period" -v w="$$ws" 'BEGIN { \
			if (p == "" || w == "") print ""; \
			else printf "%.6f", 0.6 * p - 0.25 - w; \
		}')"; \
		\
		printf '%s,%s,%s,%s,%s,%s,' \
			"$$algorithm" "$$configuration" "$$topology" \
			"$$bits" "$$period" "$$critical_path"; \
		\
		jq -r --argjson k "$$keys" '[ .[$$k[]] | if type == "number" and isinfinite then (if . > 0 then "inf" else "-inf" end) else . end ] | @csv' "$$metrics"; \
		\
	done >> $(FINAL_CSV); \
	\
	echo "CSV generado:"; \
	echo "  $(FINAL_CSV)"; \
	echo "  diseños : $$(( $$(wc -l < $(FINAL_CSV)) - 1 ))"; \
	echo "  columnas: $$(head -1 $(FINAL_CSV) | tr ',' '\n' | wc -l)"; \
	echo ""


# ============================================================
# LIMPIAR
# ============================================================

clean:
	@rm -rf "$(RESULTS_DIR)"
	@rm -f combined_librelane_results.csv
	@rm -f $(FINAL_CSV)
	@echo "Resultados eliminados."
