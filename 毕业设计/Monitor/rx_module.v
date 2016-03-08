/******************************************************************************
*
*            Module    :     rx_module
*          File Name   :     rx_module.v
*            Author    :     JC_Wang
*            Version   :     1.0
*            Date      :     2012/12/5
*         Description  :     UART接收模块
*           
*
********************************************************************************/

module rx_module(
    //input               GClk,         /*       system topest clock                      */
    input               clk16x,       /*       sample clock,16×115200                   */
    input               rst_n,        /*        glabol reset signal                     */
    input               rx,           /*           serial data in                       */
    output reg          DataReady,    /*       a complete byte has been received        */
    output reg[7:0]     DataReceived  /*       Bytes received                           */
);

 
/*  捕获rx的下降沿，即起始信号  */    
reg trigger_r0;
wire neg_tri;
always@(posedge clk16x or posedge rst_n)  /*下降沿使用全局时钟来捕获的，其实用clk16x来捕获也可以*/
begin
    if(rst_n)
        begin
            trigger_r0<=1'b0;
        end
    else
        begin    
            trigger_r0<=rx;
        end
end

assign neg_tri = trigger_r0 & ~rx;

//----------------------------------------------    
/*     counter control      */
reg cnt_en;
always@(posedge clk16x or posedge rst_n)
begin
    if(rst_n)
        cnt_en<=1'b0;
    else if(neg_tri==1'b1)      /*如果捕获到下降沿，则开始计数*/
        cnt_en<=1'b1;
    else if(cnt==8'd152)
        cnt_en<=1'b0;
   
end
//---------------------------------------------
/*      counter module ，对采样时钟进行计数       */
reg [7:0] cnt;
always@(posedge clk16x or posedge rst_n)
begin
    if(rst_n)
        cnt<=8'd0;
    else if(cnt_en)
        cnt<=cnt+1'b1;
    else
        cnt<=8'd0;

end
//---------------------------------------------
/*      receive module        */
always@(posedge clk16x or posedge rst_n)
begin
    if(rst_n)
        begin
            DataReceived<=8'b0;
				DataReady <= 1'b0;
        end
    else if(cnt_en)
        case(cnt)
            8'd24:   DataReceived[0] <= rx;    /*在各个采样时刻，读取接收到的数据*/
            8'd40:   DataReceived[1] <= rx;
            8'd56:   DataReceived[2] <= rx;
            8'd72:   DataReceived[3] <= rx;
            8'd88:   DataReceived[4] <= rx;
            8'd104:  DataReceived[5] <= rx;
            8'd120:  DataReceived[6] <= rx;
            8'd136:  DataReceived[7] <= rx;
				8'd152:  DataReady <= 1'b1;
            
        endcase
	 else
	     DataReady <= 1'b0;

end

endmodule