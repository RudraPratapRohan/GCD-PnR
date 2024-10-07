`timescale 1ns / 1ps

module GCD(out,done,clk,rst,in1,in2,go);

input [31:0]in1,in2;
input clk,rst,go;

output [31:0]out;
output done;

wire a_gt_b,a_lt_b,a_eq_b; 
wire a_ld,b_ld,a_sel,b_sel; 
wire output_en;

controller c1(a_ld,b_ld,a_sel,b_sel,output_en,done,clk,rst,go,a_gt_b,a_lt_b,a_eq_b);
datapath d1(a_gt_b,a_lt_b,a_eq_b,out,output_en,clk,rst,a_ld,b_ld,a_sel,b_sel,in1,in2);

 
endmodule

module register(rnout,clk,rst,load,rin);

input [31:0] rin;
input clk,rst,load;

output reg [31:0] rnout;

always @(posedge clk)
     begin
	  if(rst==1)
	    rnout<=0;
	  else if(load==1)
	    rnout<=rin;
	  //else 
	   // rnout <= 0;////edited
	  end
	  
endmodule

module controller(a_ld,b_ld,a_sel,b_sel,output_en,done,clk,rst,go,a_gt_b,a_lt_b,a_eq_b);

input clk,rst,go;
input a_gt_b,a_lt_b,a_eq_b;

output reg a_ld,b_ld,a_sel,b_sel;
output reg output_en,done;

reg [2:0] cState,nState;


parameter a=3'b000;
parameter b=3'b001;
parameter c=3'b010;
parameter d=3'b011;
parameter e=3'b100;
parameter f=3'b101;
parameter g=3'b110;
parameter h=3'b111;


always @(posedge clk)
    begin 
	   if(rst==1)
		  cState<=a;
		else
		  cState<=nState;
	 end
	 
always @(go or a_gt_b or a_lt_b or a_eq_b or cState)
    begin
	   case(cState)
		    a:begin
			     if(go==0) nState<=a;
				  else nState <=b;
				end
			 
			 b:nState<=c;
			 
			 c:nState <=d;
			 
			 d:begin
			      if({a_gt_b,a_lt_b,a_eq_b}==3'b100)
					   nState <=e;
					else if({a_gt_b,a_lt_b,a_eq_b}==3'b010)
					   nState <=f;
					else if({a_gt_b,a_lt_b,a_eq_b}==3'b001)
					   nState <= h;
					//else nState <= h;////edited
				end
				
			  e:nState <= g;
			  f:nState <= g;
			  g:nState <= d;
			  h:nState <= a;
			  
			  default : nState<=a;
		 endcase
				
	 end
always @(go or a_gt_b or a_lt_b or a_eq_b or cState)
    begin
	   case(cState)
		    a:
			  begin
			   a_sel<=0;
				b_sel<=0;
				a_ld<=0;
				b_ld<=0;
				output_en<=0;
				done<=0;
			  end
			 
			 b:
			  begin
			   a_sel<=0;
				b_sel<=0;
				a_ld<=1;
				b_ld<=1;
				output_en<=0;
				done<=0;
			  end
			 
			 c:
			  begin
			   a_sel<=1;
				b_sel<=1;
				a_ld<=0;
				b_ld<=0;
				output_en<=0;
				done<=0;
			  end
			 
			 d:             //compare state
			  begin
			   a_sel<=0;// a=0 b=0
				b_sel<=0;
				a_ld<=0;
				b_ld<=0;
				output_en<=0;
				done<=0;
			  end
			 
			 e:              //a=a-b state
			  begin
			   a_sel<=1;
				b_sel<=0;
				a_ld<=1;
				b_ld<=0;
				output_en<=0;
				done<=0;
			  end
			 
			 f:             //b=b-a state
			  begin
			   a_sel<=0;
				b_sel<=1;
				a_ld<=0;
				b_ld<=1;
				output_en<=0;
				done<=0;
			  end
			 
			 g:            //waiting state
			  begin
			   a_sel<=0;
				b_sel<=0;
				a_ld<=0;
				b_ld<=0;
				output_en<=0;//en=1
				done<=0;
			  end
			 
			 h:             //
			  begin
			   a_sel<=0;
				b_sel<=0;
				a_ld<=0;
				b_ld<=0;
 				output_en<=1; //en=0
				done<=1;
			  end
			 default:
			  begin
			   a_sel<=0;
				b_sel<=0;
				a_ld<=0;
				b_ld<=0;
				output_en<=0;
				done<=0;
			  end
			endcase
		end

endmodule
module datapath(a_gt_b,a_lt_b,a_eq_b,out,output_en,clk,rst,a_ld,b_ld,a_sel,b_sel,in1,in2);

input clk,rst;
input a_ld,b_ld,a_sel,b_sel;
input [31:0]in1,in2;
input output_en;

output [31:0]out;
output a_gt_b,a_lt_b,a_eq_b;

wire [31:0] ta,tb,ts1,ts2,tm1,tm2;

substractor s1(ts1,ta,tb);
substractor s2(ts2,tb,ta);

mux m1(tm1,in1,ts1,a_sel);
mux m2(tm2,in2,ts2,b_sel);


register ra(ta,clk,rst,a_ld,tm1);
register rb(tb,clk,rst,b_ld,tm2);
register rout(out,clk,rst,output_en,tb);

comparator com(a_gt_b,a_lt_b,a_eq_b,ta,tb);

endmodule
module comparator(a_gt_b,a_lt_b,a_eq_b,a,b);

input [31:0] a,b;

output reg a_gt_b,a_lt_b,a_eq_b;

always @(a or b)
     begin 
	    
		 if(a>b)
		   {a_gt_b,a_lt_b,a_eq_b}<=3'b100;
		 else if(a<b)
		   {a_gt_b,a_lt_b,a_eq_b}<=3'b010;
		 else
		   {a_gt_b,a_lt_b,a_eq_b}<=3'b001;
	  end
	  
endmodule
module mux(mout,i0,i1,sel);

input [31:0]i0,i1;
input sel;

output reg [31:0]mout;

always @(i0 or i1 or sel)
     begin
	   if(sel==0)
	    mout<=i0;
		else
		 mout<=i1;
	  end
	  

endmodule
module substractor(s1,a,b);

input [31:0] a,b;
output reg [31:0]s1;

always @(a or b)
     begin
	   s1=a-b;
	  end
endmodule