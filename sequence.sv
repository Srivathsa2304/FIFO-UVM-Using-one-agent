class f_sequence extends uvm_sequence#(f_sequence_item);
  `uvm_object_utils(f_sequence)
  
  function new(string name = "f_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("******** Idle condition ********"), UVM_LOW)
    repeat(15) begin
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {{i_rden,i_wren} == 00;});
      finish_item(req);
    `uvm_info(get_type_name(), $sformatf("********Continuous writes ********"), UVM_LOW)
    repeat(15) begin
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {{i_rden,i_wren} == 01;});
      finish_item(req);
    end
    `uvm_info(get_type_name(), $sformatf("******** Continuous reads ********"), UVM_LOW)
    repeat(15) begin
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {{i_rden,i_wren} == 10;});
      finish_item(req);
    end
    `uvm_info(get_type_name(), $sformatf("******** Parallel write and read ********"), UVM_LOW)
    repeat(15) begin
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with  {{i_rden,i_wren} == 11;});
      finish_item(req);
    end
      `uvm_info(get_type_name(), $sformatf("******** Alternate write and read ********"), UVM_LOW)
    repeat(15) begin
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {{i_rden,i_wren} == 01;});
      finish_item(req);

      start_item(req);
      assert(req.randomize() with {{i_rden,i_wren} == 10;});
      finish_item(req);
    end
  endtask
endclass
  
  
