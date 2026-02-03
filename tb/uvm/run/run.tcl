exec xvlog -sv -f apb_dpmem_uvm.f -L uvm -define NO_OF_TRANSACTIONS=1000;

# Elaborates a design that has one top design unit
# After compilation, xelab generates an executable snapshot with the name top.
# Without the -s top switch, xelab creates the snapshot by concatenating the unit names.
exec xelab top -s top -cc_type sbct -timescale 1ns/10ps;

exec xsim top -testplusarg UVM_TESTNAME=apb_dpmem_test -runall

exec xcrg -cc_dir ./xsim.codeCov -cc_db top -cc_report xcrg_code_cov_report -report_format html
exec xcrg -dir ./xsim.covdb -db_name top -report_dir xcrg_func_cov_report -report_format html