cleanw:
	@echo "Cleaning up generated files..."
	cmd /C "del /Q *.log *.jou *.pb *.wdb *.txt 2>nul"
	cmd /C "rmdir /S /Q xsim.dir xsim.codeCov xsim.covdb xcrg_code_cov_report xcrg_func_cov_report 2>nul"
	@echo "Clean completed"

vivado:
	vivado -mode tcl -source run.tcl