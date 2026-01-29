`ifndef APB_DPMEM_SEQUENCE__SV
`define APB_DPMEM_SEQUENCE__SV 

/* The uvm_sequence class provides the interfaces necessary in order to
 create streams of sequence items and/or other sequences.
 
 Class Hierarchy
  uvm_void
  |
    uvm_object
    |
      uvm_transaction
      |
        uvm_sequence_item
        |
          uvm_sequence_base
          |
            uvm_sequence#*(REQ, RSP)
            |
            Class Declaration:
              virtual class uvm_sequence#( type REQ = uvm_sequence_item, type RSP = REQ) extends uvm_sequence_base
              REQ req > The sequence contains a field of the request type called req.
                        The user can use this field, if desired, or create another field to use.

              RSP rsp >  The sequence contains a field of the response type called rsp.
                         The user can use this field, if desired, or create another field to use.
              |
              |
              apb_dpmem_sequence         
*/

class apb_dpmem_sequence extends uvm_sequence #(apb_dpmem_transaction);

  ///////////////////////////////////////////////////////////////////////////////
  // Declaration of Sequence utils
  //////////////////////////////////////////////////////////////////////////////
  `uvm_object_utils(apb_dpmem_sequence)

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : new
  // Description : sequence constructor
  //////////////////////////////////////////////////////////////////////////////
  function new(string name = "apb_dpmem_sequence");
    super.new(name);
  endfunction

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : body 
  // Description : This is the user-defined task where the main sequence code resides.
  //               This method should not be called directly by the user.
  //////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : start_item 
  // Description : start_item and finish_item together will initiate operation of a sequence item.
  //               If the item has not already been initialized using create_item,
  //               then it will be initialized here to use the default sequencer specified by m_sequencer.
  //               Randomization may be done between start_item and finish_item to ensure late generation
  // Declaretion : virtual task start_item (
  //    	uvm_sequence_item 	item,	  	
  //    	int 	set_priority	 = 	-1,
  //    	uvm_sequencer_base 	sequencer	 = 	null) 
  //////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////
  // Method name : finish_item 
  // Description : finish_item, together with start_item will initiate operation of a sequence item.
  //               Finish_item must be called after start_item with no delays or delta-cycles.
  //               Randomization, or other functions may be called between the start_item and finish_item calls.
  // Declaretion : virtual task finish_item (
  //    	uvm_sequence_item 	item,	  	
  //    	int 	set_priority	 = 	-1) 
  //////////////////////////////////////////////////////////////////////////////
  virtual task body();
    for (int i = 0; i < `NO_OF_TRANSACTIONS; i++) begin
      req = apb_dpmem_sequence::type_id::create("req");
      start_item(req);
      assert (req.randomize());
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION NUM : %0d", i), UVM_LOW);
      req.print();
      finish_item(req);
    end
  endtask

endclass : apb_dpmem_sequence

`endif
