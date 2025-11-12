/********************************************
 *  Copyright (c) 2025 
 *  Author: negative-slack (Nader Alnatsheh).
 *  All rights reserved.
 *******************************************/

`ifndef APB_ASSERTIONS__SV
`define APB_ASSERTIONS__SV 

program apb_assertions (
    apb_if.monitor_mp assert_intf
);

  // property to check that a signal is in a known state
  property SIGNAL_VALID(signal);
    @(posedge assert_intf.PCLK) !$isunknown(
        signal
    );
  endproperty : SIGNAL_VALID

  PRESETn_VALID :
  assert property (SIGNAL_VALID(assert_intf.PRESETn))
  else $error("ERROR: Signal PRESETn is INVALID @ time=%0t", $time);

  PSEL_VALID :
  assert property (SIGNAL_VALID(assert_intf.PSEL))
  else $error("ERROR: Signal PSEL is INVALID @ time=%0t", $time);

  // property to check that if a PSEL is active, then
  // the signal is in a known state
  property CONTROL_SIGNAL_VALID(signal);
    @(posedge assert_intf.PCLK) $onehot(
        assert_intf.PSEL
    ) |-> !$isunknown(
        signal
    );
  endproperty : CONTROL_SIGNAL_VALID

  PADDR_VALID :
  assert property (CONTROL_SIGNAL_VALID(assert_intf.PADDR))
  else $error("ERROR: Signal PADDR is INVALID when Signal PSEL is Asserted @ time=%0t", $time);

  PWRITE_VALID :
  assert property (CONTROL_SIGNAL_VALID(assert_intf.PWRITE))
  else $error("ERROR: Signal PWRITE is INVALID when Signal PSEL is Asserted @ time=%0t", $time);

  PENABLE_VALID :
  assert property (CONTROL_SIGNAL_VALID(assert_intf.PENABLE))
  else $error("ERROR: Signal PENABLE is INVALID when Signal PSEL is Asserted @ time=%0t", $time);

  // Check that write data is in a known state if a write
  property PWDATA_SIGNAL_VALID;
    @(posedge assert_intf.PCLK) ($onehot(
        assert_intf.PSEL
    ) && assert_intf.PWRITE) |-> !$isunknown(
        assert_intf.PWDATA
    );
  endproperty : PWDATA_SIGNAL_VALID

  PWDATA_VALID :
  assert property (PWDATA_SIGNAL_VALID);

  // Check that if PENABLE is active, then the signal is in a known state
  property PENABLE_SIGNAL_VALID(signal);
    @(posedge assert_intf.PCLK) $rose(
        assert_intf.PENABLE
    ) |-> !$isunknown(
        signal
    ) [* 1: $] ##1 $fell(
        assert_intf.PENABLE
    );
  endproperty : PENABLE_SIGNAL_VALID

  PREADY_VALID :
  assert property (PENABLE_SIGNAL_VALID(assert_intf.PREADY));

  PSLVERR_VALID :
  assert property (PENABLE_SIGNAL_VALID(assert_intf.PSLVERR));

  // Check that read data is in a known state if a read
  property PRDATA_SIGNAL_VALID;
    @(posedge assert_intf.PCLK) ($rose(
        assert_intf.PENABLE && !assert_intf.PWRITE && assert_intf.PREADY
    )) |-> !$isunknown(
        assert_intf.PRDATA
    ) [* 1: $] ##1 $fell(
        assert_intf.PENABLE
    );
  endproperty : PRDATA_SIGNAL_VALID

  PRDATA_VALID :
  assert property (PRDATA_SIGNAL_VALID);

endprogram

`endif

//   /* 1. PSEL-PENABLE Timing : Check that PENABLE signal
//  is asserted exactly one cycle after PSEL is asserted. */
//   property p1;
//     @(posedge assert_intf.PCLK) disable iff (!assert_intf.PRESETn) $rose(
//         assert_intf.PSEL
//     ) |=> assert_intf.PENABLE;
//   endproperty

//   assert property (p1)
//   else
//     $error(
//         "PENABLE FAILED TO ASSERT AFTER EXACTLY 1 CC FROM WHEN PSEL IS ASSERTED @ t=%0t -> PSEL=%0b, PENABLE=%0b",
//         $time,
//         assert_intf.PSEL,
//         assert_intf.PENABLE
//     );

//   /* 2. Transfer End Deassertion : Ensure that once a transfer is complete
//  (PREADY is asserted), PENABLE go low before a new transfer starts.​ */
//   property p2;
//     @(posedge assert_intf.PCLK) disable iff (!assert_intf.PRESETn) $rose(
//         assert_intf.PREADY
//     ) |=> !assert_intf.PENABLE;
//   endproperty

//   assert property (p2)
//   else $error("PENABLE FAILED TO BE LOW EXACTLY AFTER 1 CC FROM WHEN PREADY IS HIGH");

//   property p3;
//     @(posedge assert_intf.PCLK) disable iff (!assert_intf.PRESETn) ($rose(
//         assert_intf.PSEL
//     )) |-> ($stable(
//         assert_intf.PADDR
//     ) && $stable(
//         assert_intf.PWRITE
//     ) && $stable(
//         assert_intf.PWDATA
//     )) until (!assert_intf.PREADY);
//   endproperty

//   assert property (p3)
//   else $error("PADDR, PWRITE, PWDATA, FAILED TO BE STABLE UNTIL PREADY IS DEASSERTED");

//   property p4;
//     @(posedge assert_intf.PCLK) disable iff (!assert_intf.PRESETn) $rose(
//         assert_intf.PREADY
//     ) |=> ($stable(
//         assert_intf.PENABLE
//     )) until (!assert_intf.PREADY);
//   endproperty

//   assert property (p4)
//   else $error("PENABLE FAILED TO BE STABLE UNTIL PREADY IS DEASSERTED");

// endprogram
