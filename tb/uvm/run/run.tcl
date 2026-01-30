exec xvlog -sv -f apb_dpmem_uvm.f -L uvm -define NO_OF_TRANSACTIONS=1000;
exec xelab top -s top -cc_type sbct -timescale 1ns/10ps;
exec xsim top -testplusarg UVM_TESTNAME=apb_dpmem_test -testplusarg UVM_VERBOSITY=UVM_LOW -runall
exec xcrg -cc_dir ./xsim.codeCov -cc_db top -cc_report xcrg_code_cov_report -report_format html
exec xcrg -dir ./xsim.covdb -db_name top -report_dir xcrg_func_cov_report -report_format html