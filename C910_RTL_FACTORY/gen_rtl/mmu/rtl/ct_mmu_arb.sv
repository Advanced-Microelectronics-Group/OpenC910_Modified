/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// &ModuleBeg; @28
module ct_mmu_arb(
// &Ports; @29
input     logic           cp0_mmu_icg_en        ,
input     logic           cp0_mmu_no_op_req     ,
input     logic           cpurst_b              ,
input     logic           dutlb_arb_cmplt       ,
input     logic           dutlb_arb_load        ,
input     logic           dutlb_arb_req         ,
input     logic   [26:0]  dutlb_arb_vpn         ,
input     logic           dutlb_xx_mmu_off      ,
input     logic           forever_cpuclk        ,
input     logic           iutlb_arb_cmplt       ,
input     logic           iutlb_arb_req         ,
input     logic   [26:0]  iutlb_arb_vpn         ,
input     logic           jtlb_arb_cmp_va       ,
input     logic           jtlb_arb_par_clr      ,
input     logic           jtlb_arb_pfu_cmplt    ,
input     logic   [26:0]  jtlb_arb_pfu_vpn      ,
input     logic           jtlb_arb_sel_1g       ,
input     logic           jtlb_arb_sel_2m       ,
input     logic           jtlb_arb_sel_4k       ,
input     logic           jtlb_arb_tc_miss      ,
input     logic   [2 :0]  jtlb_arb_type         ,
input     logic   [26:0]  jtlb_arb_vpn          ,
input     logic           lsu_mmu_va2_vld       ,
input     logic           pad_yy_icg_scan_en    ,
input     logic   [3 :0]  ptw_arb_bank_sel      ,
input     logic   [41:0]  ptw_arb_data_din      ,
input     logic   [3 :0]  ptw_arb_fifo_din      ,
input     logic   [2 :0]  ptw_arb_pgs           ,
input     logic           ptw_arb_req           ,
input     logic   [47:0]  ptw_arb_tag_din       ,
input     logic   [26:0]  ptw_arb_vpn           ,
input     logic   [3 :0]  tlboper_arb_bank_sel  ,
input     logic           tlboper_arb_cmp_va    ,
input     logic   [41:0]  tlboper_arb_data_din  ,
input     logic   [3 :0]  tlboper_arb_fifo_din  ,
input     logic           tlboper_arb_fifo_write,
input     logic   [8 :0]  tlboper_arb_idx       ,
input     logic           tlboper_arb_idx_not_va,
input     logic           tlboper_arb_req       ,
input     logic   [47:0]  tlboper_arb_tag_din   ,
input     logic   [26:0]  tlboper_arb_vpn       ,
input     logic           tlboper_arb_write     ,
input     logic           tlboper_xx_cmplt      ,
input     logic   [2 :0]  tlboper_xx_pgs        ,
input     logic           tlboper_xx_pgs_en     ,
output    logic           arb_dutlb_grant       ,
output    logic           arb_iutlb_grant       ,
output    logic   [2 :0]  arb_jtlb_acc_type     ,
output    logic   [3 :0]  arb_jtlb_bank_sel     ,
output    logic           arb_jtlb_cmp_with_va  ,
output    logic   [41:0]  arb_jtlb_data_din     ,
output    logic   [3 :0]  arb_jtlb_fifo_din     ,
output    logic           arb_jtlb_fifo_write   ,
output    logic   [8 :0]  arb_jtlb_idx          ,
output    logic           arb_jtlb_req          ,
output    logic   [47:0]  arb_jtlb_tag_din      ,
output    logic   [26:0]  arb_jtlb_vpn          ,
output    logic           arb_jtlb_write        ,
output    logic           arb_ptw_grant         ,
output    logic           arb_ptw_mask          ,
output    logic           arb_tlboper_grant     ,
output    logic   [1 :0]  arb_top_cur_st        ,
output    logic           arb_top_tlboper_on    ,
output    logic           mmu_yy_xx_no_op
);
       

// &Regs; @30
//reg     [1 :0]  arb_cur_st;            
//reg     [1 :0]  arb_nxt_st;            
reg             tlboper_on;            

// &Wires; @31
wire            arb_clk;               
wire            arb_clk_en;            
//wire            arb_dutlb_grant;       
wire            arb_idx_sel_1g;        
wire            arb_idx_sel_2m;        
wire            arb_idx_sel_4k;        
//wire            arb_iutlb_grant;       
//wire    [2 :0]  arb_jtlb_acc_type;     
//wire    [3 :0]  arb_jtlb_bank_sel;     
//wire            arb_jtlb_cmp_with_va;  
//wire    [41:0]  arb_jtlb_data_din;     
//wire    [3 :0]  arb_jtlb_fifo_din;     
//wire            arb_jtlb_fifo_write;   
//wire    [8 :0]  arb_jtlb_idx;          
//wire            arb_jtlb_req;          
//wire    [47:0]  arb_jtlb_tag_din;      
//wire    [26:0]  arb_jtlb_vpn;          
//wire            arb_jtlb_write;        
wire            arb_load_grant;        
wire            arb_par_clr;           
wire            arb_pfu_grant;         
//wire            arb_ptw_grant;         
//wire            arb_ptw_mask;          
wire            arb_read_huge;         
wire            arb_store_grant;       
//wire            arb_tlboper_grant;     
//wire    [1 :0]  arb_top_cur_st;        
//wire            arb_top_tlboper_on;    
wire    [8 :0]  arb_va_index;          
wire    [26:0]  arb_vpn;               
//wire            cp0_mmu_icg_en;        
//wire            cp0_mmu_no_op_req;     
//wire            cpurst_b;              
//wire            dutlb_arb_cmplt;       
//wire            dutlb_arb_load;        
//wire            dutlb_arb_req;         
//wire    [26:0]  dutlb_arb_vpn;         
//wire            dutlb_xx_mmu_off;      
//wire            forever_cpuclk;        
//wire            iutlb_arb_cmplt;       
//wire            iutlb_arb_req;         
//wire    [26:0]  iutlb_arb_vpn;         
//wire            jtlb_arb_cmp_va;       
//wire            jtlb_arb_par_clr;      
//wire            jtlb_arb_pfu_cmplt;    
//wire    [26:0]  jtlb_arb_pfu_vpn;      
//wire            jtlb_arb_sel_1g;       
//wire            jtlb_arb_sel_2m;       
//wire            jtlb_arb_sel_4k;       
//wire            jtlb_arb_tc_miss;      
//wire    [2 :0]  jtlb_arb_type;         
//wire    [26:0]  jtlb_arb_vpn;          
//wire            lsu_mmu_va2_vld;       
//wire            mmu_yy_xx_no_op;       
//wire            pad_yy_icg_scan_en;    
//wire    [3 :0]  ptw_arb_bank_sel;      
//wire    [41:0]  ptw_arb_data_din;      
//wire    [3 :0]  ptw_arb_fifo_din;      
//wire    [2 :0]  ptw_arb_pgs;           
//wire            ptw_arb_req;           
//wire    [47:0]  ptw_arb_tag_din;       
//wire    [26:0]  ptw_arb_vpn;           
//wire    [3 :0]  tlboper_arb_bank_sel;  
//wire            tlboper_arb_cmp_va;    
//wire    [41:0]  tlboper_arb_data_din;  
//wire    [3 :0]  tlboper_arb_fifo_din;  
//wire            tlboper_arb_fifo_write; 
//wire    [8 :0]  tlboper_arb_idx;       
//wire            tlboper_arb_idx_not_va; 
//wire            tlboper_arb_req;       
//wire    [47:0]  tlboper_arb_tag_din;   
//wire    [26:0]  tlboper_arb_vpn;       
//wire            tlboper_arb_write;     
wire            tlboper_fifo_wen;      
wire            tlboper_idx_not_va_sel; 
wire            tlboper_wen;           
//wire            tlboper_xx_cmplt;      
//wire    [2 :0]  tlboper_xx_pgs;        
//wire            tlboper_xx_pgs_en;     
wire            utlb_mask;             
wire            utlb_refill_on;        

parameter VPN_WIDTH  = 39-12;  // VPN
parameter PPN_WIDTH  = 40-12;  // PPN
parameter FLG_WIDTH  = 14;     // Flags
parameter PGS_WIDTH  = 3;      // Page Size
parameter ASID_WIDTH = 16;     // Flags

// Valid + VPN + ASID + PageSize + Global
parameter TAG_WIDTH  = 1+VPN_WIDTH+ASID_WIDTH+PGS_WIDTH+1;  
parameter DATA_WIDTH = PPN_WIDTH+FLG_WIDTH;

//==========================================================
//                  Gate Cell
//==========================================================
assign arb_clk_en = iutlb_arb_req 
                 || dutlb_arb_req
                 || tlboper_arb_req
                 || lsu_mmu_va2_vld
                 || utlb_mask;
// &Instance("gated_clk_cell", "x_jtlb_arb_gateclk"); @51
gated_clk_cell  x_jtlb_arb_gateclk (
  .clk_in             (forever_cpuclk    ),
  .clk_out            (arb_clk           ),
  .external_en        (1'b0              ),
  .global_en          (1'b1              ),
  .local_en           (arb_clk_en        ),
  .module_en          (cp0_mmu_icg_en    ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);

// &Connect( .clk_in     (forever_cpuclk  ), @52
//           .external_en(1'b0            ), @53
//           .global_en  (1'b1            ), @54
//           .module_en  (cp0_mmu_icg_en  ), @55
//           .local_en   (arb_clk_en      ), @56
//           .clk_out    (arb_clk         ) @57
//          ); @58


//==============================================================================
//                  Control Path
//==============================================================================
//==========================================================
//                  Grant Siangl
//==========================================================
// &Force("output","arb_iutlb_grant"); 
// &Force("output","arb_dutlb_grant"); 
// &Force("output","arb_tlboper_grant"); 
// &Force("output","arb_ptw_grant"); 

assign arb_pfu_grant   = lsu_mmu_va2_vld 
                     && !dutlb_xx_mmu_off // only valid when mmu is enabled
                     && !iutlb_arb_req
                     && !dutlb_arb_req
                     && !tlboper_arb_req
                     && !ptw_arb_req
                     && !utlb_mask;

assign arb_iutlb_grant = iutlb_arb_req
                     && !dutlb_arb_req
                     && !tlboper_arb_req
                     && !ptw_arb_req
                     && !utlb_mask;

assign arb_dutlb_grant = dutlb_arb_req
                     && !tlboper_arb_req
                     && !ptw_arb_req
                     && !utlb_mask;

assign arb_tlboper_grant = tlboper_arb_req
                     && !ptw_arb_req
                     && jtlb_arb_sel_4k;

assign arb_ptw_grant = ptw_arb_req;

assign arb_jtlb_req  = arb_iutlb_grant
                    || arb_pfu_grant
                    || arb_dutlb_grant
                    || arb_tlboper_grant
                    || arb_ptw_grant
                    || arb_read_huge
                    || arb_par_clr;

//==========================================================
//                  Req Mask FSM
//==========================================================

enum logic[1:0] {ARB_IDLE  = 2'b00,                 
                 ARB_IUTLB = 2'b01,
                 ARB_DUTLB = 2'b10,
                 ARB_PFU   = 2'b11                
                } arb_cur_st,arb_nxt_st;


always_ff@(posedge arb_clk or negedge cpurst_b)
begin
  if (!cpurst_b)
    arb_cur_st[1:0] <= ARB_IDLE;
  else
    arb_cur_st[1:0] <= arb_nxt_st[1:0];
end 

// &CombBeg; @121
always_comb
begin
case (arb_cur_st)
      ARB_IDLE:
      begin
        if(arb_pfu_grant)
          arb_nxt_st[1:0] = ARB_PFU;
        else if(arb_iutlb_grant)
          arb_nxt_st[1:0] = ARB_IUTLB;
        else if(arb_dutlb_grant)
          arb_nxt_st[1:0] = ARB_DUTLB;
        else
          arb_nxt_st[1:0] = ARB_IDLE;
      end
      ARB_IUTLB:
      begin
        if(iutlb_arb_cmplt)
          arb_nxt_st[1:0] = ARB_IDLE;
        else
          arb_nxt_st[1:0] = ARB_IUTLB;
      end
      ARB_DUTLB:
      begin
        if(dutlb_arb_cmplt)
          arb_nxt_st[1:0] = ARB_IDLE;
        else
          arb_nxt_st[1:0] = ARB_DUTLB;
      end
      ARB_PFU:
      begin
        if(jtlb_arb_pfu_cmplt)
          arb_nxt_st[1:0] = ARB_IDLE;
        else
          arb_nxt_st[1:0] = ARB_PFU;
      end
      default:
      begin
        arb_nxt_st[1:0] = ARB_IDLE;
      end
endcase
// &CombEnd; @160
end

// 1. tlboper(including ctc oper) req  only masked by ptw refill req
// 2. when tlboper started, it will stall all other req
always_ff @(posedge arb_clk or negedge cpurst_b)
begin
  if (!cpurst_b)
    tlboper_on <= 1'b0;
  else if(tlboper_on && tlboper_xx_cmplt)
    tlboper_on <= 1'b0;
  else if(arb_tlboper_grant)
    tlboper_on <= 1'b1;
end

assign utlb_mask      = (arb_cur_st[1:0] != ARB_IDLE)
                     || tlboper_on;

assign utlb_refill_on = (arb_cur_st[1:0] != ARB_IDLE);

assign arb_ptw_mask   = tlboper_on; 

assign mmu_yy_xx_no_op = cp0_mmu_no_op_req
                      && !utlb_refill_on;

assign arb_read_huge  = (jtlb_arb_sel_2m || jtlb_arb_sel_1g) && jtlb_arb_tc_miss;
assign arb_idx_sel_4k = tlboper_xx_pgs_en ? tlboper_xx_pgs[0] :
                        arb_ptw_grant ? ptw_arb_pgs[0] :
                        arb_par_clr ? jtlb_arb_sel_2m : jtlb_arb_sel_4k ;
assign arb_idx_sel_2m = tlboper_xx_pgs_en ? tlboper_xx_pgs[1] : 
                        arb_ptw_grant ? ptw_arb_pgs[1] :
                        arb_par_clr ? jtlb_arb_sel_1g : jtlb_arb_sel_2m ;
assign arb_idx_sel_1g = tlboper_xx_pgs_en ? tlboper_xx_pgs[2] : 
                        arb_ptw_grant ? ptw_arb_pgs[2] :
                        arb_par_clr ? !jtlb_arb_sel_1g && !jtlb_arb_sel_2m : jtlb_arb_sel_1g ;

// parity check fail invalid request
assign arb_par_clr = jtlb_arb_par_clr;

//==============================================================================
//                  Data Path
//==============================================================================
//==========================================================
//                  jTLB Index & VPN(tag for cmp)
//==========================================================
assign arb_vpn[VPN_WIDTH-1:0] =
                {VPN_WIDTH{arb_pfu_grant}}     & jtlb_arb_pfu_vpn[VPN_WIDTH-1:0]
              | {VPN_WIDTH{arb_iutlb_grant}}   & iutlb_arb_vpn[VPN_WIDTH-1:0]
              | {VPN_WIDTH{arb_read_huge}}     & jtlb_arb_vpn[VPN_WIDTH-1:0]
              | {VPN_WIDTH{arb_par_clr}}       & jtlb_arb_vpn[VPN_WIDTH-1:0]
              | {VPN_WIDTH{arb_dutlb_grant}}   & dutlb_arb_vpn[VPN_WIDTH-1:0]
              | {VPN_WIDTH{arb_tlboper_grant}} & tlboper_arb_vpn[VPN_WIDTH-1:0]
              | {VPN_WIDTH{arb_ptw_grant}}     & ptw_arb_vpn[VPN_WIDTH-1:0];
assign arb_jtlb_vpn[VPN_WIDTH-1:0] = arb_vpn[VPN_WIDTH-1:0];

assign arb_va_index[8:0] = {9{arb_idx_sel_4k}} & arb_vpn[8:0]
                         | {9{arb_idx_sel_2m}} & arb_vpn[17:9]
                         | {9{arb_idx_sel_1g}} & arb_vpn[26:18];

assign tlboper_idx_not_va_sel = arb_tlboper_grant && tlboper_arb_idx_not_va;
assign arb_jtlb_idx[8:0] = tlboper_idx_not_va_sel ? tlboper_arb_idx[8:0]
                                                  : arb_va_index[8:0];

assign arb_jtlb_bank_sel[3:0] = {4{arb_pfu_grant}}     & 4'b1111
                              | {4{arb_iutlb_grant}}   & 4'b1111
                              | {4{arb_read_huge}}     & 4'b1111
                              | {4{arb_par_clr}}       & 4'b1111
                              | {4{arb_dutlb_grant}}   & 4'b1111
                              | {4{arb_tlboper_grant}} & tlboper_arb_bank_sel[3:0]
                              | {4{arb_ptw_grant}}     & ptw_arb_bank_sel[3:0];

assign arb_jtlb_write = arb_tlboper_grant && tlboper_arb_write
                     || arb_ptw_grant     && 1'b1
                     || arb_par_clr;

assign arb_jtlb_fifo_write = arb_tlboper_grant && tlboper_arb_fifo_write
                          || arb_ptw_grant     && 1'b1 
                          || arb_par_clr;

assign arb_jtlb_cmp_with_va = arb_pfu_grant
                           || arb_iutlb_grant
                           || arb_dutlb_grant
                           || arb_read_huge && jtlb_arb_cmp_va
                           //|| arb_par_clr && jtlb_arb_cmp_va
                           || arb_tlboper_grant && tlboper_arb_cmp_va; 

assign arb_load_grant  = arb_dutlb_grant && dutlb_arb_load;
assign arb_store_grant = arb_dutlb_grant && !dutlb_arb_load;
assign arb_jtlb_acc_type[2:0] = {3{arb_pfu_grant}}     & 3'b100
                              | {3{arb_iutlb_grant}}   & 3'b011
                              | {3{arb_read_huge}}     & jtlb_arb_type[2:0]
                              | {3{arb_load_grant}}    & 3'b010
                              | {3{arb_store_grant}}   & 3'b110
                              | {3{arb_tlboper_grant}} & 3'b001
                              | {3{arb_par_clr}}       & 3'b000
                              | {3{arb_ptw_grant}}     & 3'b000;

//==========================================================
//                  jTLB Tag & Data Input
//==========================================================
assign tlboper_fifo_wen = arb_tlboper_grant && tlboper_arb_fifo_write;
assign arb_jtlb_fifo_din[3:0] = 
                            {4{tlboper_fifo_wen}} & tlboper_arb_fifo_din[3:0]
                          | {4{arb_ptw_grant}}    & ptw_arb_fifo_din[3:0];

assign tlboper_wen = arb_tlboper_grant && tlboper_arb_write;
assign arb_jtlb_tag_din[TAG_WIDTH-1:0]  = 
                {TAG_WIDTH{tlboper_wen}}   & tlboper_arb_tag_din[TAG_WIDTH-1:0]
              | {TAG_WIDTH{arb_ptw_grant}} & ptw_arb_tag_din[TAG_WIDTH-1:0];

assign arb_jtlb_data_din[DATA_WIDTH-1:0] = 
             {DATA_WIDTH{tlboper_wen}}   & tlboper_arb_data_din[DATA_WIDTH-1:0]
           | {DATA_WIDTH{arb_ptw_grant}} & ptw_arb_data_din[DATA_WIDTH-1:0];

// for dbg
assign arb_top_cur_st[1:0] = arb_cur_st[1:0];
assign arb_top_tlboper_on  = tlboper_on;


// &ModuleEnd; @278
endmodule


