`timescale 1ns / 1ps
module FourBitCPU(rst, clk, opcode, address, myinput, myoutput, HLT, s_flag, z_flag, c_flag);
parameter n=4;
input rst, clk; 
input [3:0] opcode; 
input [n-1:0] address;
input [7:0] myinput; 
output reg [7:0] myoutput; 
output reg HLT, s_flag, z_flag, c_flag; 
reg [7:0] stackPoint, addPoint, temp; 
reg [7:0] stackReg[((2^n)-1):0];
reg [7:0] mem [((2^n)-1):0];
integer progCount = 0; 
integer i=0;

/*initial //Commenting since initial block is non-synthesizable
begin
{s_flag, c_flag, z_flag, HLT} = 0;
stackPoint = 4'b1110;
  for (i=0; i<(2^n); i=i+1)
    begin
      mem[i]=i;
      stackReg[i]=i;
    end
end*/

always @(posedge clk)
begin

if (rst)
begin
  for (i=0; i<(2^n); i=i+1)
    begin
      mem[i]=i;
      stackReg[i]=i;
    end
c_flag = 0; 
z_flag = 0;
s_flag = 0;
myoutput=0;
end

else if(progCount < 16 && !HLT)
begin
case(opcode) 
4'b0000:      //Addition
begin
  {c_flag, myoutput} <= mem[address]+myinput;
if (mem[address] == 0) z_flag = 1;
HLT=1'b0;
s_flag=1'b0;
end

4'b0001:      //Subtraction
begin
if (mem[address] < myinput)
begin
  z_flag=1'b0; 
  s_flag = 1;
  {c_flag, myoutput} <= myinput-mem[address];
  end
  else 
    s_flag = 0;
    z_flag=1'b0; 
    {c_flag, myoutput} <= mem[address]-myinput;
if (mem[address] == 0) z_flag = 1;
myoutput<=mem[address];
c_flag=1'b0;
HLT=1'b0;
end

4'b0010:      //Exchange
begin
temp = mem[address];
  mem[address] = mem[(address)+1];
  mem[(address)+1] = temp;
myoutput=mem[address];
HLT=1'b0;
end

4'b0011:      //Move
begin
mem[address] = mem[0]; 
if (mem[address] == 0) z_flag = 1;
myoutput=mem[address];
HLT=1'b0;
end

4'b0100:      //Rotate Right
begin
  myoutput=mem[address]>>1;
  HLT=1'b0;
  //$display ("mem[address]=%b, myinput=%b, myoutput=%b", mem[address], myinput, myoutput);
end

4'b0101: 
begin
mem[address] = myinput;      //Input
myoutput=mem[address];
z_flag = (mem[address] == 0)? 1:0;
HLT=1'b0;
end

4'b0110: 
  begin
    myoutput = mem[address];     //Output
    z_flag = (mem[address] == 0)? 1:0;
    HLT=1'b0;
  end

4'b0111:                              //AND Operation
begin
mem[address] = mem[address]&myinput;
myoutput=mem[address]; 
HLT=1'b0;
if (mem[address] == 0) z_flag = 1;
end

4'b1000:                              //FLAG Reset
begin
c_flag = 0; 
z_flag = 0;
s_flag = 0;
HLT=1'b0;
myoutput=mem[address];
end

4'b1001:                              //OR Operation
begin
mem[address] = mem[address] | myinput;
myoutput=mem[address];
z_flag = (mem[address] == 0)? 1:0;
c_flag=1'b0;
s_flag=1'b0;
HLT=1'b0;
end

4'b1010:			      //EXOR Operation
begin
mem[address] = mem[address] ^ myinput;
myoutput=mem[address];
z_flag = (mem[address] == 0)? 1:0;
c_flag=1'b0;
s_flag=1'b0;
HLT=1'b0;
end

4'b1011:                              //PUSH Operation
begin
stackPoint = stackPoint - 1;
stackReg[stackPoint] = mem[address];
myoutput=stackReg[stackPoint];
HLT=1'b0;
end

4'b1100:                              //POP Operation
begin
mem[address] = stackReg[stackPoint];
stackPoint = stackPoint + 1;
myoutput=mem[address];
HLT=1'b0;
end

4'b1101:       
begin                       //Rotate Left                          
myoutput=mem[address]<<1;
z_flag = (mem[address] == 0)? 1:0;
end

4'b1110:                              //Inverse
begin
mem[address] = ~(mem[address]);
myoutput=mem[address];
HLT=1'b0;
end

4'b1111:                             //HLT
begin
HLT = 1;
end
  
default: myoutput=0;
endcase
progCount = progCount + 1;
HLT=1'b0;
end
  
end
endmodule
