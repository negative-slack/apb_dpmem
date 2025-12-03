// MIT License

// Copyright (c) 2025 negative-slack (Nader Alnatsheh)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

`ifndef APB_ASSERTIONS__SV
`define APB_ASSERTIONS__SV 

module apb_assertions (
    apb_if.sva_mp assert_intf
);

  // property to check that the (PRESETn, PSEL) signals are always in a known state
  property SIGNAL_VALID(logic signal);
    @(posedge assert_intf.PCLK) !$isunknown(
        signal
    );
  endproperty : SIGNAL_VALID

  // PRESETn is always in a known state
  PRESETn_VALID :
  assert property (SIGNAL_VALID(assert_intf.PRESETn))
  // $display("SUCCESS: PRESETn signal is always VALID");
  else
    $error("ASSERT ERROR: Signal PRESETn is INVALID @ time=%0t", $time);


  // PSEL is always in a known state
  PSEL_VALID :
  assert property (SIGNAL_VALID(assert_intf.PSEL))
  else $error("ASSERT ERROR: Signal PSEL is INVALID @ time=%0t", $time);
  /*************************************************************************/

  // property to check that if a PSEL is active, then
  // the CONTROL signals (PENABLE, PADDR, PWRITE) is always in a known state
  property TRANSACTION_CONTROL_SIGNAL_VALID(logic signal);
    @(posedge assert_intf.PCLK) $onehot(
        assert_intf.PSEL
    ) |-> !$isunknown(
        signal
    );
  endproperty : TRANSACTION_CONTROL_SIGNAL_VALID

  // PENABLE  is valid when PSEL is active
  PENABLE_VALID :
  assert property (TRANSACTION_CONTROL_SIGNAL_VALID(assert_intf.PENABLE))
  else $error("ASSERT ERROR: Signal PENABLE is INVALID when Signal PSEL is Asserted @ time=%0t", $time);

  // PADDR is valid when PSEL is active
  PADDR_VALID :
  assert property (TRANSACTION_CONTROL_SIGNAL_VALID(assert_intf.PADDR))
  else $error("ASSERT ERROR: Signal PADDR is INVALID when Signal PSEL is Asserted @ time=%0t", $time);

  // PWRITE  is valid when PSEL is active
  PWRITE_VALID :
  assert property (TRANSACTION_CONTROL_SIGNAL_VALID(assert_intf.PWRITE))
  else $error("ASSERT ERROR: Signal PWRITE is INVALID when Signal PSEL is Asserted @ time=%0t", $time);
  /*************************************************************************/

  // property to check that write control signals (PSTRB, PWDATA) are 
  // in a known state if a pwrite is asserted
  property WRITE_CONTROL_PSTRB_SIGNAL_VALID(signal);
    @(posedge assert_intf.PCLK) ($onehot(
        assert_intf.PSEL
    ) && assert_intf.PWRITE) |-> !$isunknown(
        signal
    );
  endproperty : WRITE_CONTROL_PSTRB_SIGNAL_VALID

  // PWDATA  is valid when PWRITE is active
  PWDATA_VALID :
  assert property (WRITE_CONTROL_PSTRB_SIGNAL_VALID(assert_intf.PWDATA))
  else
    $error(
        "ASSERT ERROR: Signal PWDATA is INVALID when Signal PSEL and PWRITE are Asserted @ time=%0t", $time
    );

  // PSTRB  is valid when PWRITE is active
  PSTRB_VALID :
  assert property (WRITE_CONTROL_PSTRB_SIGNAL_VALID(assert_intf.PSTRB))
  else
    $error(
        "ASSERT ERROR: Signal PSTRB is INVALID when Signal PSEL and PWRITE are Asserted @ time=%0t", $time
    );
  /*************************************************************************/

  // Check that if PENABLE is active, then the signals (PREADY, PSLVERR) are in a known state
  property SLV_OUTPUT_SIGNAL_VALID(signal);
    @(posedge assert_intf.PCLK) $rose(
        assert_intf.PENABLE
    ) |-> !$isunknown(
        signal
    ) [* 1: $] ##1 $fell(
        assert_intf.PENABLE  // PENABLE MUST FALL ONE CLOCK CYCLE AFTER 
    );
  endproperty : SLV_OUTPUT_SIGNAL_VALID

  PREADY_VALID :
  assert property (SLV_OUTPUT_SIGNAL_VALID(assert_intf.PREADY))
  else $error("ASSERT ERROR: Signal PREADY is INVALID when Signal PENABLE is Asserted @ time=%0t", $time);

  PSLVERR_VALID :
  assert property (SLV_OUTPUT_SIGNAL_VALID(assert_intf.PSLVERR))
  else $error("ASSERT ERROR: Signal PSLVERR is INVALID when Signal PENABLE is Asserted @ time=%0t", $time);
  /*************************************************************************/

  // Check that read data is in a known state if a read transaction
  property PRDATA_SIGNAL_VALID;
    @(posedge assert_intf.PCLK) ($rose(
        assert_intf.PENABLE && !assert_intf.PWRITE && assert_intf.PREADY
    )) |-> !$isunknown(
        assert_intf.PRDATA
    ) [* 1: $] ##1 $fell(
        assert_intf.PENABLE  // PENABLE MUST FALL ONE CLOCK CYCLE AFTER 
    );
  endproperty : PRDATA_SIGNAL_VALID

  PRDATA_VALID :
  assert property (PRDATA_SIGNAL_VALID);
  /*************************************************************************/

  // PENABLE is de-asserted once PREADY becomes active
  property PREADY_1_PENABLE_0;
    @(posedge assert_intf.PCLK) $rose(
        assert_intf.PENABLE && assert_intf.PREADY
    ) |=> !assert_intf.PENABLE;
  endproperty

  PENABLE_DEASSERT_1CC_AFTER_PREADY :
  assert property (PREADY_1_PENABLE_0)
  else
    $error(
        "ASSERT ERROR: PENABLE FAILED TO DEASSERT EXACTLY 1 CC AFTER PREADY IS ASSERTED @ time=%0t", $time
    );

  property PSEL_1_PENABLE_1;
    @(posedge assert_intf.PCLK) $rose(
        assert_intf.PSEL
    ) |=> (assert_intf.PENABLE);
  endproperty

  assert property (PSEL_1_PENABLE_1)
  else
    $error("ASSERT ERROR: PENABLE FAILED TO ASSERT EXACTLY 1 CC AFTER PSEL IS ASSERTED @ time=%0t", $time);

  // property PSEL_ASSERT_SIGNAL_STABLE(signal);
  //   @(posedge assert_intf.PCLK) ($onehot(
  //       assert_intf.PSEL
  //   ) |-> $stable(
  //       signal
  //   ) [* 1: $] ##1 $fell(
  //       assert_intf.PENABLE
  //   ));
  // endproperty

  // assert property (PSEL_ASSERT_SIGNAL_STABLE(assert_intf.PSEL))
  // else
  //   $error(
  //       "ASSERT ERROR: PSEL FAILED TO STAY STABLE UNTIL PENABLE IS  DEASSERTED (END OF TRANSACTION)@ time=%0t",
  //       $time
  //   );

  // assert property (PSEL_ASSERT_SIGNAL_STABLE(assert_intf.PADDR))
  // else
  //   $error(
  //       "ASSERT ERROR: PADDR FAILED TO STAY STABLE UNTIL PENABLE IS  DEASSERTED (END OF TRANSACTION)@ time=%0t",
  //       $time
  //   );

  // assert property (PSEL_ASSERT_SIGNAL_STABLE(assert_intf.PWRITE))
  // else
  //   $error(
  //       "ASSERT ERROR: PWRITE FAILED TO STAY STABLE UNTIL PENABLE IS  DEASSERTED (END OF TRANSACTION)@ time=%0t",
  //       $time
  //   );

endmodule

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
