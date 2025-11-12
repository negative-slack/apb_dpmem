exec xvlog -sv -f apb.f;
exec xelab top -s top -cc_type sbct -timescale 1ns/10ps ;
#exec xelab top -s top -timescale 1ns/10ps ;
exec xsim top -runall ;
exec xcrg -cc_dir ./xsim.codeCov -cc_db top -cc_report xcrg_code_cov_report -report_format html
exec xcrg -dir ./xsim.covdb -db_name top -report_dir xcrg_func_cov_report -report_format html