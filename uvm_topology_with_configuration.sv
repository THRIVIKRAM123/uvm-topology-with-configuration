`include "uvm_macros.svh"
import uvm_pkg::*;

//....................... Config class  ..............................


class config1 extends uvm_object;
  `uvm_object_utils(config1)
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  int no_of_agents=1;
  function new(string name="config1");
    super.new(name);
  endfunction
endclass

//.......................  Driver class  ...............................


class driver extends uvm_driver;
  `uvm_component_utils(driver)
  
  function new(string name="driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

//.......................  Monitor class ...............................


class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  function new(string name="monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

//.......................  Sequencer class  ..............................


class seqr extends uvm_sequencer;
  `uvm_component_utils(seqr)
  
  function new(string name="seqr", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

//.......................  Agent class  ...................................


class agent extends uvm_agent;
  config1 cfg;
  driver drvh;
  monitor monh;
  seqr seqh;
  
  `uvm_component_utils(agent)
  
  function new(string name="agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Retrieve the configuration for the agent
    if (!uvm_config_db#(config1)::get(this, "", "config1", cfg)) begin
      `uvm_fatal("CONFIG", "Configuration not found in agent")
    end
    
    if (cfg.is_active == UVM_ACTIVE) begin
      drvh = driver::type_id::create("drvh", this);
      seqh = seqr::type_id::create("seqh", this);
    end
    
    monh = monitor::type_id::create("monh", this);
  endfunction
endclass

//..........................  Environment class  ............................


class env extends uvm_env;
  `uvm_component_utils(env)
  config1 cfg;
agent agh[];
  //int no_of_agents=3;
  function new(string name="env", uvm_component parent );
    super.new(name, parent);
  endfunction
  
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   if (!uvm_config_db#(config1)::get(this, "", "config1", cfg)) 
    begin
      `uvm_fatal("CONFIG", "Configuration not found in environment")
    end

    agh=new[cfg.no_of_agents];
   // agh = agent::type_id::create("agh", this);
foreach(agh[i])
	begin
		agh[i] = agent::type_id::create($sformatf("agh[%0d]",i),this);
	end

  endfunction
endclass



//..............................  Test class  ...................................


class test extends uvm_test;
  `uvm_component_utils(test)
  env env_h;
  config1 cfg;
  
  function new(string name="test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cfg = config1::type_id::create("cfg");
    env_h = env::type_id::create("env_h", this);

    uvm_config_db#(config1)::set(this, "*", "config1", cfg);
  endfunction
 
endclass



//...............................  Top-level module  ...............................
module top;
  initial
  begin
    uvm_top.enable_print_topology = 1;
    run_test("test");
  end
endmodule
