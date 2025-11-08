program test (
    apb_if intf
);

  environment env;

  initial begin
    env = new(intf);
    env.main;
  end

endprogram
