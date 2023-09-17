class f_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp#(f_sequence_item, f_scoreboard) item_got_export;
  `uvm_component_utils(f_scoreboard)
  
  function new(string name = "f_scoreboard", uvm_component parent);
    super.new(name, parent);
    item_got_export = new("item_got_export", this);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  int queue[$];
  
  function void write(input f_sequence_item item_got);
    bit [127:0] examdata;
    if(item_got.i_wren == 'b1)begin
      queue.push_back(item_got.i_wrdata);
      `uvm_info("write Data", $sformatf("i_wren: %0b i_rden: %0b i_wrdata: %0d o_full: %0b,o_alm_full: %0b",item_got.i_wren, item_got.i_rden,item_got.i_wrdata, item_got.o_full,item_got.o_alm_full), UVM_LOW);
    end
    if (item_got.i_rden == 'b1)begin
      if(queue.size() >= 'd1)begin
        examdata = queue.pop_front();
        `uvm_info("Read Data", $sformatf("examdata: %0d o_rddata: %0d o_empty: %0b,o_alm_empty: %0b", examdata, item_got.o_rddata, item_got.o_empty,item_got.o_alm_empty), UVM_LOW);
        if(examdata == item_got.o_rddata)begin
          $display("-------- 		Pass! 		--------");
        end
        else begin
          $display("--------		Fail!		--------");
          $display("--------		Check empty	--------");
        end
      end
    end
  endfunction
endclass
        
