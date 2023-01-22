module FourBitCPU_tb();
reg rst, clk; 
parameter n=4;
reg [7:0] myprogram; 
reg [7:0] myinput; 
wire [7:0] myoutput; 
wire HLT, s_flag, z_flag, c_flag;

always begin
clk=1;
#10;
clk=0;
#10;
end

initial begin
rst=0;
myprogram=$random;
myinput=$random;
$display ("myprogram=%b", myprogram);
$display ("myinput=%b", myinput);
#50 $display ("myoutput=%b, Zero flag = %b, Sign flag = %b, Carry flag = %b", myoutput, z_flag, s_flag, c_flag);
end

FourBitCPU inst0(.rst(rst), .clk(clk), .myprogram(myprogram), .myinput(myinput), .myoutput(myoutput), .HLT(HLT), .s_flag(s_flag), .z_flag(z_flag), .c_flag(c_flag));
endmodule
