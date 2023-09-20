import uvm_pkg::*;
`include "uvm_macros.svh"

//INTERFACE

interface f_interface(input clk, rstn);
  bit i_wren;
  bit i_rden;
  bit [127:0] i_wrdata;
  bit o_full;
  bit o_empty;
  bit o_alm_full;
  bit o_alm_empty;
  bit [127:0] o_rddata;
  
  clocking d_cb @(posedge clk);
    default input #1 output #1;
    output i_wren;
    output i_rden;
    output i_wrdata;
    input o_full;
    input o_empty;
    input o_alm_full;
    input o_alm_empty;
    input o_rddata;
  endclocking
  
  clocking m_cb @(posedge clk);
    default input #1 output #1;
    input i_wren;
    input i_rden;
    input i_wrdata;
    input o_full;
    input o_empty;
    input o_alm_full;
    input o_alm_empty;
    input o_rddata;
  endclocking
  
  modport d_mp (input clk, rstn, clocking d_cb);
  modport m_mp (input clk, rstn, clocking m_cb);
    
endinterface
    
    
//SEQUENCE ITEM
    

class f_sequence_item extends uvm_sequence_item;
  rand bit i_wren;
  rand bit i_rden;
  rand bit [127:0] i_wrdata;
  bit o_full;
  bit o_alm_full;
  bit o_empty;
  bit o_alm_empty;
  bit [127:0] o_rddata;
  
 
  
  `uvm_object_utils_begin(f_sequence_item)
  `uvm_field_int(i_wren, UVM_ALL_ON)
  `uvm_field_int(i_rden, UVM_ALL_ON)
  `uvm_field_int(i_wrdata, UVM_ALL_ON)
  `uvm_field_int(o_rddata, UVM_ALL_ON)
  `uvm_field_int(o_full, UVM_ALL_ON)
  `uvm_field_int(o_empty, UVM_ALL_ON)
  `uvm_field_int(o_alm_full, UVM_ALL_ON)
  `uvm_field_int(o_alm_empty, UVM_ALL_ON)
  `uvm_object_utils_end
  
  //constraint c1 {i_wren != i_rden;}
   function new(string name = "f_sequence_item");
    super.new(name);
  endfunction
  
endclass


//SEQUENCE

class f_sequence extends uvm_sequence #(f_sequence_item);
  `uvm_object_utils(f_sequence)
  f_sequence_item req;
  
  
  function new(string name = "f_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_info(get_type_name(), $sformatf("******** Idle condition ********"), UVM_LOW);
    repeat(20) begin
      $display("IDLE");
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {i_rden==0;i_wren==0;});
      finish_item(req);
      end
    
      `uvm_info(get_type_name(), $sformatf("********Continuous writes ********"), UVM_LOW);
    repeat(20) begin
      $display("CONTINUOUS WRITES");
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {i_rden==0;i_wren==1;});
      finish_item(req);
    end
    
      `uvm_info(get_type_name(), $sformatf("******** Continuous reads ********"), UVM_LOW);
    repeat(20) begin
      $display("CONTINUOUS READS");
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {i_rden==1;i_wren==0;});
      finish_item(req);
    end
    
      `uvm_info(get_type_name(), $sformatf("******** Parallel write and read ********"), UVM_LOW);
    repeat(20) begin
      $display("PARALLEL WRITE AND READ");
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with  {i_rden==1;i_wren==1;});
      finish_item(req);
    end
    
      `uvm_info(get_type_name(), $sformatf("******** Alternate write and read ********"), UVM_LOW);
    repeat(20) begin
      $display("ALTERNATE WRITE AND READ");
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {i_rden==0;i_wren==1;});
      finish_item(req);
      
      req = f_sequence_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with {i_rden==1;i_wren==0;});
      finish_item(req);
    end
  endtask
endclass
  
    
//SEQUENCER

class f_sequencer extends uvm_sequencer#(f_sequence_item);
  `uvm_component_utils(f_sequencer)
  
  function new(string name = "f_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass
  
    
//DRIVER

class f_driver extends uvm_driver#(f_sequence_item);
  virtual f_interface vif;
  f_sequence_item req;
  `uvm_component_utils(f_driver)
  
  function new(string name = "f_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual f_interface)::get(this, "", "vif", vif))
      `uvm_fatal("Driver: ", "No vif is found!");
  endfunction

  virtual task run_phase(uvm_phase phase);
//      vif.d_mp.d_cb.i_wren <= 'b0;
//     vif.d_mp.d_cb.i_rden <= 'b0;
//     vif.d_mp.d_cb.i_wrdata <= 'b0;
    forever begin
      
      if(vif.d_mp.rstn==0) begin
    vif.d_mp.d_cb.i_wren <= 'b0;
    vif.d_mp.d_cb.i_rden <= 'b0;
    vif.d_mp.d_cb.i_wrdata <= 'b0;
    end
      seq_item_port.get_next_item(req);
      if(req.i_wren == 1)
        main_write(req.i_wrdata);
      
      if(req.i_rden == 1)
        main_read();
      
      seq_item_port.item_done();
    end
  endtask
  
    virtual task main_write(input [127:0] din);
    @(posedge vif.d_mp.clk)
    vif.d_mp.d_cb.i_wren <= 'b1;
    vif.d_mp.d_cb.i_wrdata <= din;
    @(posedge vif.d_mp.clk)
    vif.d_mp.d_cb.i_wren <= 'b0;
  endtask
  
  virtual task main_read();
    @(posedge vif.d_mp.clk)
    vif.d_mp.d_cb.i_rden <= 'b1;
    @(posedge vif.d_mp.clk)
    vif.d_mp.d_cb.i_rden <= 'b0;
  endtask

endclass

//MONITOR
    
class f_monitor extends uvm_monitor;
  virtual f_interface vif;
  f_sequence_item item_got;
  uvm_analysis_port#(f_sequence_item) item_got_port;
  `uvm_component_utils(f_monitor)
  
  function new(string name = "f_monitor", uvm_component parent);
    super.new(name, parent);
    item_got_port = new("item_got_port", this);
  endfunction
  

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_got = f_sequence_item::type_id::create("item_got");
    if(!uvm_config_db#(virtual f_interface)::get(this, "", "vif", vif))
      `uvm_fatal("Monitor: ", "No vif is found!");
  endfunction
      
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.m_mp.clk)
      if(vif.m_mp.m_cb.i_wren == 1)begin
       // $display("\n WRITE is high");
        item_got.i_wrdata = vif.m_mp.m_cb.i_wrdata;
        item_got.i_wren = 'b1;
        item_got.i_rden = 'b0;
        item_got.o_full = vif.m_mp.m_cb.o_full;
        item_got.o_alm_full = vif.m_mp.m_cb.o_alm_full;
        item_got_port.write(item_got);
      end
      
      if(vif.m_mp.m_cb.i_rden == 1)begin
        //@(posedge vif.m_mp.clk)
        //$display("\n READ is high");
        item_got.o_rddata = vif.m_mp.m_cb.o_rddata;
        item_got.i_rden = 'b1;
        item_got.i_wren = 'b0;
        item_got.o_empty = vif.m_mp.m_cb.o_empty;
        item_got.o_alm_empty = vif.m_mp.m_cb.o_alm_empty;
        $display("item got = %0d", item_got.o_rddata);
        $display("item got interface = %0d", vif.m_mp.m_cb.o_rddata);
        item_got_port.write(item_got);
      end
    end
  endtask
endclass

    
    
//AGENT

// `include "f_sequence_item.sv"
// `include "f_sequence.sv"
// `include "f_sequencer.sv"
// `include "f_driver.sv"
// `include "f_monitor.sv"

class f_agent extends uvm_agent;
  f_sequencer f_seqr;
  f_driver f_dri;
  f_monitor f_mon;
  `uvm_component_utils(f_agent)
  
  function new(string name = "f_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(get_is_active() == UVM_ACTIVE) begin
      f_seqr = f_sequencer::type_id::create("f_seqr", this);
      f_dri = f_driver::type_id::create("f_dri", this);
    end
    f_mon = f_monitor::type_id::create("f_mon", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE)
      f_dri.seq_item_port.connect(f_seqr.seq_item_export);
  endfunction
  
endclass
 
    
    
//SCOREBOARD
    
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
  
  bit [127:0] queue[$];
  
  function void write(input f_sequence_item item_got);
    bit [127:0] examdata;
    if(item_got.i_wren == 'b1)begin
      queue.push_back(item_got.i_wrdata);
      `uvm_info("write Data", $sformatf("i_wren: %0b i_rden: %0b i_wrdata: %0d o_full: %0b,o_alm_full: %0b,o_empty: %0b,o_alm_empty: %0b",item_got.i_wren, item_got.i_rden,item_got.i_wrdata, item_got.o_full,item_got.o_alm_full,item_got.o_empty,item_got.o_alm_empty), UVM_LOW);
    end
    if (item_got.i_rden == 'b1)begin
      if(queue.size() >= 'd1)begin
        examdata = queue.pop_front();
        `uvm_info("Read Data", $sformatf("examdata: %0d o_rddata: %0d o_empty: %0b,o_alm_empty: %0b, item_got read data = %0d,o_full: %0b,o_alm_full: %0b", examdata, item_got.o_rddata, item_got.o_empty,item_got.o_alm_empty,item_got.o_rddata,item_got.o_full,item_got.o_alm_full), UVM_LOW);
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
            
//ENVIRONMENT       
        
// `include "f_agent.sv"
// `include "f_scoreboard.sv"

class f_environment extends uvm_env;
  f_agent f_agt;
  f_scoreboard f_scb;
  `uvm_component_utils(f_environment)
  
  function new(string name = "f_environment", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    f_agt = f_agent::type_id::create("f_agt", this);
    f_scb = f_scoreboard::type_id::create("f_scb", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    f_agt.f_mon.item_got_port.connect(f_scb.item_got_export);
  endfunction
  
endclass  

//TEST

    
// `include "f_environment.sv"

class f_test extends uvm_test;
  f_sequence f_seq;
  f_environment f_env;
  `uvm_component_utils(f_test)
  
  function new(string name = "f_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    f_seq = f_sequence::type_id::create("f_seq", this);
    f_env = f_environment::type_id::create("f_env", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    f_seq.start(f_env.f_agt.f_seqr);
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this, 100);
  endtask
  
endclass
 
    
//TOP
    
// import uvm_pkg::*;
// `include "uvm_macros.svh"
// `include "f_interface.sv"
// `include "f_test.sv"

module tb;
  bit clk;
  bit rstn;
  
  always #5 clk = ~clk;
  
  initial begin
    clk = 1;
    rstn = 0;
    #5;
    rstn = 1;
  end
  
  f_interface tif(clk, rstn);
  
  my_fifo dut(.clk(tif.clk),
               .rstn(tif.rstn),
               .i_wrdata(tif.i_wrdata),
               .i_wren(tif.i_wren),
               .i_rden(tif.i_rden),
               .o_full(tif.o_full),
               .o_empty(tif.o_empty),
               .o_alm_full(tif.o_alm_full),
               .o_alm_empty(tif.o_alm_empty),
               .o_rddata(tif.o_rddata));
  
  initial begin
    uvm_config_db#(virtual f_interface)::set(null, "", "vif", tif);
    $dumpfile("dump.vcd"); 
    $dumpvars;
    run_test("f_test");
  end
  
  initial begin
    #2000 $finish;
  end
  
endmodule
    
