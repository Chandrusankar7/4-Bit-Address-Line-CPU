///////////////////////////////////////////////////////////////////
//Module: FourBitCPU
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a module for 4 bit CPU that performs 16 types of processor operations
module FourBitCPU(pc_if _if);
parameter n=4;
reg [n-1:0] regs[1:0]; // registers, where regs[0]=A and regs[1]=B; In this way it can be easily extended.
reg [n-1:0] stackPoint, addPoint, temp; // temporary storage, opcode, address and stack pointers
integer progCount,i;

initial
begin
progCount = 0; // Program counter, counting from 0 to 15
i = 0; // initializing
{_if.s_flag, _if.c_flag, _if.z_flag, _if.HLT} = 0;
stackPoint = 4'b1110;
  /*for (i=0; i<(2^n); i=i+1)
    begin
      mem[i]=i;
      stackReg[i]=i;
    end*/
end

// instructions, memory addresses are being loaded -- before the computer starts
always @(posedge _if.clk)
begin

if (_if.rst)
begin
  for (i=0; i<(2^n); i=i+1)
    _if.mem[i]=i;
_if.c_flag = 0; 
_if.z_flag = 0;
_if.s_flag = 0;
_if.myoutput=0;
end

if(progCount < 16 && !_if.HLT) // for 16 operations, counter shall count up to 16 or until HLT is given
addPoint = _if.progReg[progCount][3:0]; // lower nibble represents the address
begin
case(_if.opcode) //case statement for the opcode.
4'b0000:      //Addition
begin
  {_if.c_flag, _if.myoutput} <= _if.mem[_if.address]+_if.myinput;
if (_if.mem[_if.address] == 0) _if.z_flag = 1;
else _if.z_flag = 1;
_if.HLT=1'b0;
_if.s_flag=1'b0;

end

4'b0001:      //Subtraction
begin
if (_if.mem[_if.address] < _if.myinput)
begin
  _if.z_flag=1'b0; 
  _if.s_flag = 1;
  {_if.c_flag, _if.myoutput} <= _if.myinput-_if.mem[_if.address];
  end
  else 
    _if.s_flag = 0;
    _if.z_flag=1'b0; 
    {_if.c_flag, _if.myoutput} <= _if.mem[_if.address]-_if.myinput;
if (_if.mem[_if.address] == 0) _if.z_flag = 1;
_if.myoutput<=_if.mem[_if.address];
_if.c_flag=1'b0;
_if.HLT=1'b0;
end

4'b0010:      //Exchange
begin
  temp = _if.mem[_if.address];
  _if.mem[_if.address] = _if.mem[(_if.address)+1];
  _if.mem[(_if.address)+1] = temp;
_if.myoutput=_if.mem[_if.address];
_if.HLT=1'b0;
end

4'b0011:      //Move
begin
_if.mem[_if.address] = _if.mem[0]; 
if (_if.mem[_if.address] == 0) _if.z_flag = 1;
  else _if.z_flag = 0;
_if.myoutput=_if.mem[_if.address];
_if.HLT=1'b0;
end

4'b0100:      //Rotate Right
begin
  _if.myoutput=_if.mem[_if.address]>>1;
  _if.HLT=1'b0;
  //$display ("mem[address]=%b, myinput=%b, myoutput=%b", mem[address], myinput, myoutput);
end

4'b0101: 
begin
_if.mem[_if.address] = _if.myinput;      //Input
_if.myoutput=_if.mem[_if.address];
_if.z_flag = (_if.mem[_if.address] == 0)? 1:0;
_if.HLT=1'b0;
end

4'b0110: 
  begin
    _if.myoutput = _if.mem[_if.address];     //Output
    _if.z_flag = (_if.mem[_if.address] == 0)? 1:0;
    _if.HLT=1'b0;
  end

4'b0111:                              //AND Operation
begin
_if.mem[_if.address] = _if.mem[_if.address]&_if.myinput;
_if.myoutput=_if.mem[_if.address]; 
_if.HLT=1'b0;
if (_if.mem[_if.address] == 0) _if.z_flag = 1;
end

4'b1000:                              //FLAG Reset
begin
_if.c_flag = 0; 
_if.z_flag = 0;
_if.s_flag = 0;
_if.HLT=1'b0;
_if.myoutput=_if.mem[_if.address];
end

4'b1001:                              //OR Operation
begin
_if.mem[_if.address] = _if.mem[_if.address] | _if.myinput;
_if.myoutput=_if.mem[_if.address];
_if.z_flag = (_if.mem[_if.address] == 0)? 1:0;
_if.c_flag=1'b0;
_if.s_flag=1'b0;
_if.HLT=1'b0;
end

4'b1010:			      //EXOR Operation
begin
_if.mem[_if.address] = _if.mem[_if.address] ^ _if.myinput;
_if.myoutput=_if.mem[_if.address];
_if.z_flag = (_if.mem[_if.address] == 0)? 1:0;
_if.c_flag=1'b0;
_if.s_flag=1'b0;
_if.HLT=1'b0;
end

4'b1011:                              //PUSH Operation
begin
stackPoint = stackPoint - 1;
_if.stackReg[stackPoint] = _if.mem[_if.address];
_if.myoutput=_if.stackReg[stackPoint];
_if.HLT=1'b0;
end

4'b1100:                              //POP Operation
begin
_if.mem[_if.address] = _if.stackReg[stackPoint];
stackPoint = stackPoint + 1;
_if.myoutput=_if.mem[_if.address];
_if.HLT=1'b0;
end

4'b1101:       
begin                       //Rotate Left                          
_if.myoutput=_if.mem[_if.address]<<1;
_if.z_flag = (_if.mem[_if.address] == 0)? 1:0;
end

4'b1110:                              //Inverse
begin
_if.mem[_if.address] = ~(_if.mem[_if.address]);
_if.myoutput=_if.mem[_if.address];
_if.HLT=1'b0;
end

4'b1111:                             //HLT
begin
_if.HLT = 1;
end
  
default: _if.myoutput=0;
endcase
progCount = progCount + 1;
_if.HLT=1'b0;
end
end
endmodule


///////////////////////////////////////////////////////////////////
//Class: Packet
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a class used for creating packets of every variables in the 4 bit PC system
class packet;
parameter n =4;
rand bit [3:0] opcode;
rand bit [n-1:0] address; 
rand bit [3:0] myinput;
bit [7:0] progReg[0:15];
bit [3:0] dataStore[0:15];
bit [3:0] stackReg[0:15];
bit  [3:0] myoutput;
bit  [7:0] mem [((2^n)-1):0];
bit  HLT, s_flag, z_flag, c_flag;
bit clk, rst;

function void print(string tag="");
  $display("name : %s ",tag);
  $display("Address = %b, opcode = %b, myinput = %b",address, opcode, myinput);
 /* foreach (progReg[i])
  $display("progReg = %b",progReg[i]);
  foreach (dataStore[i])
  $display("dataStore = %b",dataStore[i]);
  foreach (stackReg[i])
  $display("stackReg = %b",stackReg[i]);*/
  $display("myoutput = %b",myoutput);
  $display("HLT = %b, s_flag = %b, z_flag = %b, c_flag = %b",HLT, s_flag, z_flag, c_flag); 
endfunction

function void copy(packet tmp);
 this.address = tmp.address;
 this.opcode = tmp.opcode;
 this.myinput = tmp.myinput;
 this.progReg = tmp.progReg;
 this.dataStore = tmp.dataStore;
 this.stackReg = tmp.stackReg;
 this.myoutput = tmp.myoutput;
 this.HLT = tmp.HLT;
 this.s_flag = tmp.s_flag;
 this.z_flag = tmp.z_flag;
 this.c_flag = tmp.c_flag;
 this.clk = tmp.clk;
 this.rst = tmp.rst;
endfunction

endclass

///////////////////////////////////////////////////////////////////
//Class: generator
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a class used for generating random variables of the clas 's handle "item"
class generator;
 int loop = 4;
 event drv_done;
 mailbox drv_mbx;
 task run();
 for (int i = 0; i < loop; i++)
 begin
 packet item = new;
 item.randomize();
 $display ("T=%0t **********************[Generator] Loop:%0d/%0d create next item**********************", $time, i+1, loop);
 drv_mbx.put(item);
 $display ("T=%0t **********************[Generator] Wait for driver to be done**********************", $time);
 @(drv_done);
 end
 endtask
endclass


///////////////////////////////////////////////////////////////////
//Class: driver
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a class used for sending the generated variables to the DUT through the virtual interface
class driver;
 virtual pc_if m_pc_vif;
 //virtual clk_if m_clk_vif;
 event drv_done;
 mailbox drv_mbx;
 task run();
 $display ("T=%0t **********************[Driver] starting**********************", $time);
 forever begin
 packet item;
 $display ("T=%0t **********************[Driver] waiting for item**********************", $time);
 drv_mbx.get(item);
 @ (posedge m_pc_vif.clk);
 $display("Driver");
 m_pc_vif.rst <= item.rst;
 m_pc_vif.address <= item.address;
 m_pc_vif.opcode <= item.opcode;
 m_pc_vif.myinput <= item.myinput; 
 m_pc_vif.mem <= item.mem; 
 m_pc_vif.clk <= item.clk;->drv_done;
 end
 endtask
endclass


///////////////////////////////////////////////////////////////////
//Class: monitor
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a class used for monitoring all the cariables in the system
class monitor;
 virtual pc_if m_pc_vif;
 mailbox scb_mbx; // Mailbox connected to scoreboard
 task run();
 $display ("T=%0t **********************[Monitor] starting**********************", $time);
 forever begin
 packet m_pkt = new();
 @(posedge m_pc_vif.clk);
 #1;
 m_pkt.clk = m_pc_vif.clk;
 m_pkt.rst = m_pc_vif.rst;
 m_pkt.address = m_pc_vif.address;
 m_pkt.opcode = m_pc_vif.opcode;
 m_pkt.myinput = m_pc_vif.myinput;
 m_pkt.progReg = m_pc_vif.progReg;
 m_pkt.dataStore = m_pc_vif.dataStore;
 m_pkt.stackReg = m_pc_vif.stackReg;
 m_pkt.myoutput = m_pc_vif.myoutput;
 m_pkt.mem = m_pc_vif.mem;
 m_pkt.HLT = m_pc_vif.HLT;
 m_pkt.s_flag = m_pc_vif.s_flag;
 m_pkt.z_flag = m_pc_vif.z_flag;
 m_pkt.c_flag = m_pc_vif.c_flag;
 m_pkt.print("Monitor");
 scb_mbx.put(m_pkt);
 end
 endtask
endclass


///////////////////////////////////////////////////////////////////
//Class: scoreboard
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a class used for comparing the obtained result with the golden response generated and print whether it is matching or mismatching
class scoreboard; 
 reg [3:0] stackPoint, addPoint, temp;
 integer progCount,i;
 parameter n =4;
 packet item = new();
packet ref_item = new();
 mailbox scb_mbx;
 task run();
 scb_mbx.get(item);
 item.print("Scoreboard");
 //ref_item = new();
 ref_item.copy(item);

progCount = 0; // Program counter, counting from 0 to 15
i = 0; // initializing
{ref_item.s_flag, ref_item.c_flag, ref_item.z_flag, ref_item.HLT} = 0;
stackPoint = 4'b1110;
   
       for (i=0; i<(2^n); i=i+1)
    begin
      ref_item.mem[i]=i;
      ref_item.stackReg[i]=i;
    end

forever begin
if(progCount < 16 && !ref_item.HLT) // for 16 operations, counter shall count up to 16 or until HLT is given
addPoint = ref_item.progReg[progCount][3:0]; // opcode check
begin
case(ref_item.opcode)
4'b0000:      //Addition
begin
  {ref_item.c_flag, ref_item.myoutput} <= ref_item.mem[ref_item.address]+ref_item.myinput;
if (ref_item.mem[ref_item.address] == 0) ref_item.z_flag = 1;
else ref_item.z_flag = 1;
ref_item.HLT=1'b0;
ref_item.s_flag=1'b0;

end

4'b0001:      //Subtraction
begin
if (ref_item.mem[ref_item.address] < ref_item.myinput)
begin
  ref_item.z_flag=1'b0; 
  ref_item.s_flag = 1;
  {ref_item.c_flag, ref_item.myoutput} <= ref_item.myinput-ref_item.mem[ref_item.address];
  end
  else 
    ref_item.s_flag = 0;
    ref_item.z_flag=1'b0; 
    {ref_item.c_flag, ref_item.myoutput} <= ref_item.mem[ref_item.address]-ref_item.myinput;
if (ref_item.mem[ref_item.address] == 0) ref_item.z_flag = 1;
ref_item.myoutput<=ref_item.mem[ref_item.address];
ref_item.c_flag=1'b0;
ref_item.HLT=1'b0;
end

4'b0010:      //Exchange
begin
  temp = ref_item.mem[ref_item.address];
  ref_item.mem[ref_item.address] = ref_item.mem[(ref_item.address)+1];
  ref_item.mem[(ref_item.address)+1] = temp;
ref_item.myoutput=ref_item.mem[ref_item.address];
ref_item.HLT=1'b0;
end

4'b0011:      //Move
begin
ref_item.mem[ref_item.address] = ref_item.mem[0]; 
if (ref_item.mem[ref_item.address] == 0) ref_item.z_flag = 1;
  else ref_item.z_flag = 0;
ref_item.myoutput=ref_item.mem[ref_item.address];
ref_item.HLT=1'b0;
end

4'b0100:      //Rotate Right
begin
  ref_item.myoutput=ref_item.mem[ref_item.address]>>1;
  ref_item.HLT=1'b0;
  //$display ("mem[address]=%b, myinput=%b, myoutput=%b", mem[address], myinput, myoutput);
end

4'b0101: 
begin
ref_item.mem[ref_item.address] = ref_item.myinput;      //Input
ref_item.myoutput=ref_item.mem[ref_item.address];
ref_item.z_flag = (ref_item.mem[ref_item.address] == 0)? 1:0;
ref_item.HLT=1'b0;
end

4'b0110: 
  begin
    ref_item.myoutput = ref_item.mem[ref_item.address];     //Output
    ref_item.z_flag = (ref_item.mem[ref_item.address] == 0)? 1:0;
    ref_item.HLT=1'b0;
  end

4'b0111:                              //AND Operation
begin
ref_item.mem[ref_item.address] = ref_item.mem[ref_item.address]&ref_item.myinput;
ref_item.myoutput=ref_item.mem[ref_item.address]; 
ref_item.HLT=1'b0;
if (ref_item.mem[ref_item.address] == 0) ref_item.z_flag = 1;
end

4'b1000:                              //FLAG Reset
begin
ref_item.c_flag = 0; 
ref_item.z_flag = 0;
ref_item.s_flag = 0;
ref_item.HLT=1'b0;
ref_item.myoutput=ref_item.mem[ref_item.address];
end

4'b1001:                              //OR Operation
begin
ref_item.mem[ref_item.address] = ref_item.mem[ref_item.address] | ref_item.myinput;
ref_item.myoutput=ref_item.mem[ref_item.address];
ref_item.z_flag = (ref_item.mem[ref_item.address] == 0)? 1:0;
ref_item.c_flag=1'b0;
ref_item.s_flag=1'b0;
ref_item.HLT=1'b0;
end

4'b1010:			      //EXOR Operation
begin
ref_item.mem[ref_item.address] = ref_item.mem[ref_item.address] ^ ref_item.myinput;
ref_item.myoutput=ref_item.mem[ref_item.address];
ref_item.z_flag = (ref_item.mem[ref_item.address] == 0)? 1:0;
ref_item.c_flag=1'b0;
ref_item.s_flag=1'b0;
ref_item.HLT=1'b0;
end

4'b1011:                              //PUSH Operation
begin
stackPoint = stackPoint - 1;
ref_item.stackReg[stackPoint] = ref_item.mem[ref_item.address];
ref_item.myoutput=ref_item.stackReg[stackPoint];
ref_item.HLT=1'b0;
end

4'b1100:                              //POP Operation
begin
ref_item.mem[ref_item.address] = ref_item.stackReg[stackPoint];
stackPoint = stackPoint + 1;
ref_item.myoutput=ref_item.mem[ref_item.address];
ref_item.HLT=1'b0;
end

4'b1101:       
begin                       //Rotate Left                          
ref_item.myoutput=ref_item.mem[ref_item.address]<<1;
ref_item.z_flag = (ref_item.mem[ref_item.address] == 0)? 1:0;
end

4'b1110:                              //Inverse
begin
ref_item.mem[ref_item.address] = ~(ref_item.mem[ref_item.address]);
ref_item.myoutput=ref_item.mem[ref_item.address];
ref_item.HLT=1'b0;
end

4'b1111:                             //HLT
begin
ref_item.HLT = 1;
end
  
default: ref_item.myoutput=0;
endcase
progCount = progCount + 1;
end

 assert (ref_item.s_flag != item.s_flag)
 $display("[%0t] Sign flag: Scoreboard Error! Output mismatch ref_s_flag=0x%0h s_flag=0x%0h", $time, ref_item.s_flag, item.s_flag);
 else
 $display("[%0t] Sign flag: Scoreboard Pass! Output match ref_s_flag=0x%0h s_flag=0x%0h", $time, ref_item.s_flag, item.s_flag);
  
 assert (ref_item.z_flag != item.z_flag)
   $display("[%0t] Zero flag: Scoreboard Error! Output mismatch ref_z_flag=0x%0h z_flag=0x%0h", $time, ref_item.z_flag, item.z_flag);
 else
 $display("[%0t] Zero flag: Scoreboard Pass! Output match ref_z_flag=0x%0h z_flag=0x%0h", $time, ref_item.z_flag, item.z_flag);
  
 assert (ref_item.c_flag != item.c_flag)
 $display("[%0t]  Carry flag: Scoreboard Error! Output mismatch ref_c_flag=0x%0h c_flag=0x%0h", $time, ref_item.c_flag, item.c_flag);
 else
 $display("[%0t] Carry flag: Scoreboard Pass! Output match ref_c_flag=0x%0h c_flag=0x%0h", $time, ref_item.c_flag, item.c_flag);
  
 assert (ref_item.myoutput != item.myoutput)
 $display("[%0t] MyOutput: Scoreboard Error! Output mismatch ref_MyOutput=0x%0h MyOutput=0x%0h", $time, ref_item.myoutput, item.myoutput);
 else
 $display("[%0t] MyOutput: Scoreboard Pass! Output match ref_MyOutput=0x%0h MyOutput=0x%0h", $time, ref_item.myoutput, item.myoutput);
 end
endtask
endclass

///////////////////////////////////////////////////////////////////
//Class: env
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a class used for creating complete environment for the layered testbench which has handles for all the classes
class env;
 generator g0; // Generate t
 driver d0; // Driver to
 monitor m0; // Monitor fr
 scoreboard s0; // Scoreboard
 mailbox scb_mbx; // Top level
 virtual pc_if m_pc_vif; // Virtual in
 //virtual clk_if m_clk_vif; // TB clk
 event drv_done;
 mailbox drv_mbx;
 function new();
 d0 = new;
 m0 = new;
 s0 = new;
 scb_mbx = new();
 g0 = new;
 drv_mbx = new;
 endfunction
 virtual task run();
 // Connect virtual interface handles
 d0.m_pc_vif = m_pc_vif;
 m0.m_pc_vif = m_pc_vif;
 // Connect mailboxes between each component
 d0.drv_mbx = drv_mbx;
 g0.drv_mbx = drv_mbx;
 m0.scb_mbx = scb_mbx;
 s0.scb_mbx = scb_mbx;
 // Connect event handles
 d0.drv_done = drv_done;
 g0.drv_done = drv_done;
 fork
 s0.run();
 d0.run();
 m0.run();
 g0.run();
 join_any
 endtask
endclass


///////////////////////////////////////////////////////////////////
//Class: test
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is a class used for test using which the environment sends testbench
class test;
 env e0;
 mailbox drv_mbx;
 function new();
 drv_mbx = new();
 e0 = new();
 endfunction

 virtual task run();
 e0.d0.drv_mbx = drv_mbx;
 e0.run();
 endtask
endclass


///////////////////////////////////////////////////////////////////
//Interface: pc_if
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is the interface for the entire layered testbench
interface pc_if(); //all the common signals are declared inside interface
  parameter n = 4;
  logic clk, rst; //Clock and reset signals fro the CPU
  logic [3:0] address;
  logic [n-1:0] opcode;

  logic [3:0] myinput; // Data that are clk_loaded before a computer run
  bit [7:0] progReg[0:15]; //instructions shall be loaded here
  bit [3:0] dataStore[0:15]; // data shall be loaded here
  bit [3:0] stackReg[0:15]; // stack registers shall contain the push operations
  logic [3:0] myoutput; //output shall be shown here under OUT operation
  bit [7:0] mem [((2^n)-1):0];

  logic HLT, s_flag, z_flag, c_flag; //Sign flags
  initial clk <= 0;
  always
  begin
  clk=1'b1;
  #10;
  clk=1'b0;
  #10;
  end
endinterface

///////////////////////////////////////////////////////////////////
//Module: tb_pc_layered
//Project: MTech-VLSI-Verilog_SystemVerilog_Lab_Assignment
//Description:
//This is the module used for creating the test environment
module tb_pc_layered;
 pc_if m_pc_if();
 FourBitCPU u0 (m_pc_if);
 initial begin
 test t0;
 t0 = new;
 t0.e0.m_pc_vif = m_pc_if;
 t0.run();
 #50 $finish;
 end
endmodule
