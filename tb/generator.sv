class generator;

    transaction trans;
    mailbox gen2driv_mbx;
    event ended;
    int num = 2000;

    function new(mailbox gen2driv_mbx);
        this.gen2driv_mbx = gen2driv_mbx;
    endfunction

    task main();
        for (int i = 0; i < num; i++) begin
            trans = new();
            trans.randomize();
            $display ("t=%0t [Generator] Loop:%0d/%0d create next transaction",
                $time, i+1, num);
            gen2driv_mbx.put(trans);
        end
        $display("t = %0t [Generator] Done generation of %0d items", $time,  num);
        trans.display("Generator");
        -> ended;
    endtask : main

endclass : generator


