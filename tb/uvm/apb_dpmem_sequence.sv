class apb_dpmem_sequence extends uvm_sequence #(apb_dpmem_sequence_item);

  `uvm_object_utils(apb_dpmem_sequence);

  function new(string name = "apb_dpmem_sequence");
    super.new(name);
  endfunction

  virtual task body();

    req = apb_dpmem_sequence_item::type_id::create("req");
    wait_for_grant();
    assert (req.randomize());
    send_request(req);
    wait_for_item_done();
    get_response(rsp);

  endtask : body

endclass
