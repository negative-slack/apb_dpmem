`ifndef APB_PKG__SV
`define APB_PKG__SV 

package apb_pkg;

  localparam int ADDR_WIDTH = 10;
  localparam int DATA_WIDTH = 32;

  typedef logic [ADDR_WIDTH-1:0] addr_t;
  typedef logic [DATA_WIDTH-1:0] data_t;

  typedef enum bit [1:0] {
    IDLE,
    SETUP,
    ACCESS
  } apb_state_t;

  typedef struct packed {
    addr_t paddr;
    logic  pwrite;
    data_t pwdata;
  } apb_req_t;

  typedef struct packed {
    logic  pslverr;
    logic  pready;
    data_t prdata;
  } apb_rsp_t;

endpackage : apb_pkg

`endif
