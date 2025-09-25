program test(apb_if intf);

    environment env;

    initial begin
        env = new(intf);
        env.run;
    end

endprogram