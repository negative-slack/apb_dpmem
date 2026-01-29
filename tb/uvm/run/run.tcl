exec xvlog -sv -f apb_dpmem_uvm.f -L uvm -define NO_OF_TRANSACTIONS=1000;
exec xelab top -s top -cc_type sbct -timescale 1ns/10ps;
exec xsim top -testplusarg UVM_TESTNAME=apb_dpmem_test -testplusarg UVM_VERBOSITY=UVM_LOW -runall
