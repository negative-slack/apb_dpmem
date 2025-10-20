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

  typedef enum bit {
    READ  = 0,
    WRITE = 1
  } apb_rw_t;

  typedef struct packed {
    addr_t   paddr;
    apb_rw_t pwrite;
    data_t   pwdata;
  } apb_req_t;

  typedef struct packed {
    data_t prdata;
    bit pready;
  } apb_rsp_t;

endpackage : apb_pkg
