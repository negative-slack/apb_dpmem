clean:
	@echo "Cleaning up generated files..."
	rm -rf *.log *.jou *.pb

vivado:
	vivado -mode tcl -source run.tcl

verilator:
	verilator -Wall --cc --sv -f apb.f --top-module top