program apb_assertions (
    apb_if.assert_mp intf
);

  /* 1. PSEL-PENABLE Timing : Check that PENABLE signal
   is asserted exactly one cycle after PSEL is asserted. */
  property p1;
    @(posedge intf.PCLK) disable iff (!intf.PRESETn) $rose(
        intf.PSEL
    ) |=> intf.PENABLE;
  endproperty

  assert property (p1)
  else
    $error(
        "PENABLE FAILED TO ASSERT AFTER EXACTLY 1 CC FROM WHEN PSEL IS ASSERTED @ t=%0t -> PSEL=%0b, PENABLE=%0b",
        $time,
        intf.PSEL,
        intf.PENABLE
    );

  /* 2. Transfer End Deassertion : Ensure that once a transfer is complete
   (PREADY is asserted), PENABLE go low before a new transfer starts.​ */
  property p2;
    @(posedge intf.PCLK) disable iff (!intf.PRESETn) $rose(
        intf.PREADY
    ) |=> !intf.PENABLE;
  endproperty

  assert property (p2)
  else $error("PENABLE FAILED TO BE LOW EXACTLY AFTER 1 CC FROM WHEN PREADY IS HIGH");

  property p3;
    @(posedge intf.PCLK) disable iff (!intf.PRESETn) ($rose(
        intf.PSEL
    )) |-> ($stable(
        intf.PADDR
    ) && $stable(
        intf.PWRITE
    ) && $stable(
        intf.PWDATA
    )) until (!intf.PREADY);
  endproperty

  assert property (p3)
  else $error("PADDR, PWRITE, PWDATA, FAILED TO BE STABLE UNTIL PREADY IS DEASSERTED");

  property p4;
    @(posedge intf.PCLK) disable iff (!intf.PRESETn) $rose(
        intf.PREADY
    ) |=> ($stable(
        intf.PENABLE
    )) until (!intf.PREADY);
  endproperty

  assert property (p4)
  else $error("PENABLE FAILED TO BE STABLE UNTIL PREADY IS DEASSERTED");
  
endprogram
