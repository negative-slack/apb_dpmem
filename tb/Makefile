clean:
	@echo "Cleaning up generated files..."
	rm -rf *.log *.jou *.pb

cleanw:
	del /Q *.log *.jou *.pb 2>nul || exit 0

vivado:
	vivado -mode tcl -source run.tcl

verilator:
	verilator -Wall --cc --sv -f apb.f --top-module top