package apb_pkg;

parameter ADDR_WIDTH = 32; // 2^32 = 4gb
parameter DATA_WIDTH = 32;

typedef enum bit [1:0] {
    IDLE,
    SETUP,
    ACCESS
} apb_operation_states;

endpackage
