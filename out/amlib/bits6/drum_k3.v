// DRUM de 6 bits, k=3 bits seleccionados
// Hashemi, Bahar & Reda, ICCAD 2015.
//
// RTL VERBATIM de AM-Lib (https://github.com/skycrapers/AM-Lib), concatenado
// en un solo fichero y envuelto con top multiplier(A,B,P) para out/Makefile.
// OJO: estilo estructural, distinto del estilo por columnas de los circuitos
// del agente y de los baselines exact_array/bam_*. Ver README.md.
`define C_LOG_2(n) ((n)<=1?0:(n)<=2?1:(n)<=4?2:(n)<=8?3:(n)<=16?4:(n)<=32?5:6)
module LOD(in,out);
//leading one detector
parameter n=16;//length
input  [n-1:0] in;
output [n-1:0] out;


genvar i;
generate
	wire [n-1:0] in_r;
    for (i=0; i<n; i=i+1) begin: ReverseIn
        assign in_r[i] = in[n-1-i];
    end
endgenerate

wire [n-1:0] in_r_change;
wire [n-1:0] out_r;
assign in_r_change  = (~in_r) + 1;
assign out_r = in_r & in_r_change;

genvar j;
generate
    for (j=0; j<n; j=j+1) begin: ReverseResult
        assign out[j] = out_r[n-1-j];
    end
endgenerate

endmodule

module ENCODER(in,out);
//encoder:n bits(only one bit equals one) --> log_n bits
parameter n=16,log_n = `C_LOG_2(n),k=6;

input  wire [n-1:0] in;
output reg  [log_n-1:0] out;

integer i;
always @(*) 
  begin
    out = k-1; // default value if 'in' is 0
    for (i=n-1; i>k-1; i=i-1)
      if (in[i]) out = i[3:0];
  end
  
endmodule

module add_onebit
(
input wire a,
input wire b,
input wire ci,
output wire sum,
output wire co);
//(sum,cout,a,b,cin);
//input a,b,cin;
//output sum;
//output cout;

assign sum=a^b^ci;
assign co=a&b|b&ci|a&ci;

endmodule

module ADDER(a,b,cin,result);
parameter n=4;
input  [n-1:0] a;
input  [n-1:0] b;
input          cin;
output [n : 0] result;

wire [n:0] c/*verilator split_var*/;
assign c[0]=cin;

genvar i;
generate
  for(i=0;i<n;i=i+1)
    begin:generate_adder
	  add_onebit add0(.a(a[i]),.b(b[i]),.ci(c[i]),.sum(result[i]),.co(c[i+1]));
	    //FA add0(.a(a[i]),.b(b[i]),.cin(c[i]),.sum(result[i]),.carry(c[i+1]));
	end
endgenerate

assign result[n]=c[n];

endmodule




module MUX(in,lod_en,out);
//selecting k bits out of n-bit original number
parameter n=16,k=6,log_n = `C_LOG_2(n);

input  wire [n-1:0]     in;
input  wire [log_n-1:0] lod_en;
output reg  [k-1:0]     out;

always @(*)
  begin
    if(lod_en > k-1)
	  out = {in[lod_en-:(k-1)],1'b1};
	else
	  out = in[k-1:0];
  end

endmodule

module MULT_DIR(a,b,result);
parameter n=6;

input  wire  [n-1:0]     a;
input  wire  [n-1:0]     b;
output  wire [2*n-1:0]   result;

assign result = a*b;
endmodule


module BARREL_SHIFTER(approx,encode_sum,result);
//encoder:n bits(only one bit equals one) --> log_n bits
parameter n=12,k=6,shift_n = 5,result_n=32;

input  wire [n-1:0] approx;
input  wire [shift_n-1:0] encode_sum;
output wire [result_n-1:0] result;

assign result={16'd0,approx}<<(encode_sum-2*k+2);
  
endmodule

module top
  #(parameter
	  k     = 8, //selecting k bits
	  n     = 16,//length of original number
	  log_n = `C_LOG_2(n) //bits number of encoder result
  )
  (
   input  wire [n-1  :0] a,
   input  wire [n-1  :0] b,
   output wire [2*n-1:0] result
   );

wire [n-1:0] lod_a,lod_b;
LOD #(.n(n))lod1(.in(a),.out(lod_a));
LOD #(.n(n))lod2(.in(b),.out(lod_b));

wire [log_n-1:0] lod_a_en,lod_b_en;
ENCODER #(.n(n),.k(k))encode1(.in(lod_a),.out(lod_a_en));
ENCODER #(.n(n),.k(k))encode2(.in(lod_b),.out(lod_b_en));

wire [log_n:0] en_sum;
ADDER #(.n(log_n))add_shift(.a(lod_a_en),.b(lod_b_en),.cin(1'b0),.result(en_sum));

wire [k-1:0] multa,multb;
MUX #(.n(n),.k(k))mux1(.in(a),.lod_en(lod_a_en),.out(multa));
MUX #(.n(n),.k(k))mux2(.in(b),.lod_en(lod_b_en),.out(multb));

wire [2*k-1:0] multc;
MULT_DIR #(.n(k)) mult0(.a(multa),.b(multb),.result(multc));
BARREL_SHIFTER #(.n(2*k),.k(k),.shift_n(log_n+1),.result_n(2*n))shift_result(.approx(multc),.encode_sum(en_sum),.result(result));

endmodule

module multiplier (input [5:0] A, input [5:0] B, output [11:0] P);
    top #(.k(3), .n(6), .log_n(`C_LOG_2(6))) u_drum (.a(A), .b(B), .result(P));
endmodule
