# Directory Structure

``` bash 
│   .gitignore
│   LICENSE
│
├───doc
│       spec.pdf
│       spec.tex
│
├───inc
│       apb_dpmem_defines.svh
│       apb_dpmem_pkg.sv
│
├───src
│       apb_assertions.sv
│       apb_dpmem.sv
│       apb_if.sv
│
├───tb
│   ├───oop
│   │   │   apb.f
│   │   │   apb.vcd
│   │   │   apb_coverage.sv
│   │   │   Driver.sv
│   │   │   Environment.sv
│   │   │   Generator.sv
│   │   │   Makefile
│   │   │   Monitor.sv
│   │   │   run.tcl
│   │   │   Scoreboard.sv
│   │   │   Test.sv
│   │   │   top.sv
│   │   │   Transaction.sv
│   │   │   xsim.log
│   │   │
│   ├───test_plan
│   │       apb_testplan.csv
│   │
│   └───uvm
│       ├───run
│       │   │   apb_dpmem_uvm.f
│       │   │   apb_dpmem_uvm.vcd
│       │   │   Makefile
│       │   │   run.tcl
│       │   │   top.sv
│       │   │   xsim.log
│       │
│       └───test
│           ├───env
│           │   │   apb_dpmem_environment.sv
│           │   │   apb_dpmem_environment_pkg.sv
│           │   │
│           │   ├───agent
│           │   │       apb_dpmem_agent.sv
│           │   │       apb_dpmem_agent_pkg.sv
│           │   │       apb_dpmem_driver.sv
│           │   │       apb_dpmem_monitor.sv
│           │   │       apb_dpmem_sequencer.sv
│           │   │       apb_dpmem_transaction.sv
│           │   │
│           │   ├───ref_model
│           │   │       apb_dpmem_ref_model.sv
│           │   │       apb_dpmem_ref_model_pkg.sv
│           │   │
│           │   ├───scoreboard
│           │   │       apb_dpmem_scoreboard.sv
│           │   │       apb_dpmem_scoreboard_pkg.sv
│           │   │
│           │   └───subscriber
│           │           apb_dpmem_coverage.sv
│           │           apb_dpmem_coverage_pkg.sv
│           │
│           ├───sequence_lib
│           │       apb_dpmem_sequence.sv
│           │       apb_dpmem_sequence_pkg.sv
│           │
│           └───src
│                   apb_dpmem_test.sv
│                   apb_dpmem_test_pkg.sv
```