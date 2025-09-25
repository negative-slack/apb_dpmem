class transaction;

    rand logic [31:0]   PADDR;
    rand bit            PWRITE;
    bit PSEL;
    bit PENABLE;
    rand logic [31:0]   PWDATA;

    logic [31:0] PRDATA;
    bit PREADY;

    function void display(string name);
        $display("-------------------------");
        $display("- %s ",name);
        $display("-------------------------");
        $display("t=%0t, PADDR=%0h, PWRITE=%0b, PSEL=%0b, PENABLE=%0b, PWDATA=%0h, PRDATA=%0h, PREADY=%0b",
            $time, PADDR, PWRITE, PSEL, PENABLE, PWDATA, PRDATA, PREADY);
    endfunction : display

endclass : transaction
