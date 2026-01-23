exec xvlog -sv -f apb_dpmem_uvm.f -L uvm -define NO_OF_TRANSACTIONS=2000;
exec xelab top -s top -cc_type sbct -timescale 1ns/10ps -L uvm;
exec xsim top -runall ;
