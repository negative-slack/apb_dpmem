package apb_pkg;

parameter ADDR_WIDTH = 32; // 2^32 = 4gb
parameter DATA_WIDTH = 32;

typedef logic [ADDR_WIDTH-1:0] addr_t;
typedef logic [DATA_WIDTH-1:0] data_t;

typedef enum bit [1:0] {
    IDLE,
    SETUP,
    ACCESS
} apb_state_t;

endpackage
