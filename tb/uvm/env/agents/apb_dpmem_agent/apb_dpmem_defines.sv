`ifndef APB_DEFINES__SV
`define APB_DEFINES__SV 

`ifndef APB_ADDR_WIDTH
`define APB_ADDR_WIDTH 32
`endif

`ifndef APB_DATA_WIDTH
`define APB_DATA_WIDTH 32
`endif

`ifndef APB_STRB_WIDTH
`define APB_STRB_WIDTH `APB_DATA_WIDTH/8
`endif

`endif
