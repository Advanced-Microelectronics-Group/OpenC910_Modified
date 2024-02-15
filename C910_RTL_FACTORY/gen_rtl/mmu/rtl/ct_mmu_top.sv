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
module ct_mmu_top(
    input   logic           biu_mmu_smp_disable,        
    input   logic           cp0_mmu_cskyee,             
    input   logic           cp0_mmu_icg_en,             
    input   logic           cp0_mmu_maee,               
    input   logic   [1 :0]  cp0_mmu_mpp,                
    input   logic           cp0_mmu_mprv,               
    input   logic           cp0_mmu_mxr,                
    input   logic           cp0_mmu_no_op_req,          
    input   logic           cp0_mmu_ptw_en,             
    input   logic   [1 :0]  cp0_mmu_reg_num,            
    input   logic           cp0_mmu_satp_sel,           
    input   logic           cp0_mmu_sum,                
    input   logic           cp0_mmu_tlb_all_inv,        
    input   logic   [63:0]  cp0_mmu_wdata,              
    input   logic           cp0_mmu_wreg,               
    input   logic   [1 :0]  cp0_yy_priv_mode,           
    input   logic           cpurst_b,                   
    input   logic           forever_cpuclk,             
    input   logic           hpcp_mmu_cnt_en,            
    input   logic           ifu_mmu_abort,              
    input   logic   [62:0]  ifu_mmu_va,                 
    input   logic           ifu_mmu_va_vld,             
    input   logic           lsu_mmu_abort0,             
    input   logic           lsu_mmu_abort1,             
    input   logic           lsu_mmu_bus_error,          
    input   logic   [63:0]  lsu_mmu_data,               
    input   logic           lsu_mmu_data_vld,           
    input   logic   [6 :0]  lsu_mmu_id0,                
    input   logic   [6 :0]  lsu_mmu_id1,                
    input   logic           lsu_mmu_st_inst0,           
    input   logic           lsu_mmu_st_inst1,           
    input   logic   [27:0]  lsu_mmu_stamo_pa,           
    input   logic           lsu_mmu_stamo_vld,          
    input   logic           lsu_mmu_tlb_all_inv,        
    input   logic   [15:0]  lsu_mmu_tlb_asid,           
    input   logic           lsu_mmu_tlb_asid_all_inv,   
    input   logic   [26:0]  lsu_mmu_tlb_va,             
    input   logic           lsu_mmu_tlb_va_all_inv,     
    input   logic           lsu_mmu_tlb_va_asid_inv,    
    input   logic   [63:0]  lsu_mmu_va0,                
    input   logic           lsu_mmu_va0_vld,            
    input   logic   [63:0]  lsu_mmu_va1,                
    input   logic           lsu_mmu_va1_vld,            
    input   logic   [27:0]  lsu_mmu_va2,                
    input   logic           lsu_mmu_va2_vld,            
    input   logic   [27:0]  lsu_mmu_vabuf0,             
    input   logic   [27:0]  lsu_mmu_vabuf1,             
    input   logic           pad_yy_icg_scan_en,         
    input   logic   [3 :0]  pmp_mmu_flg0,               
    input   logic   [3 :0]  pmp_mmu_flg1,               
    input   logic   [3 :0]  pmp_mmu_flg2,               
    input   logic   [3 :0]  pmp_mmu_flg3,               
    input   logic   [3 :0]  pmp_mmu_flg4,               
    input   logic   [26:0]  rtu_mmu_bad_vpn,            
    input   logic           rtu_mmu_expt_vld,           
    input   logic           rtu_yy_xx_flush,            
    output  logic           mmu_cp0_cmplt,              
    output  logic   [63:0]  mmu_cp0_data,               
    output  logic   [63:0]  mmu_cp0_satp_data,          
    output  logic           mmu_cp0_tlb_done,           
    output  logic   [33:0]  mmu_had_debug_info,         
    output  logic           mmu_hpcp_dutlb_miss,        
    output  logic           mmu_hpcp_iutlb_miss,        
    output  logic           mmu_hpcp_jtlb_miss,         
    output  logic           mmu_ifu_buf,                
    output  logic           mmu_ifu_ca,                 
    output  logic           mmu_ifu_deny,               
    output  logic   [27:0]  mmu_ifu_pa,                 
    output  logic           mmu_ifu_pavld,              
    output  logic           mmu_ifu_pgflt,              
    output  logic           mmu_ifu_sec,                
    output  logic           mmu_lsu_access_fault0,      
    output  logic           mmu_lsu_access_fault1,      
    output  logic           mmu_lsu_buf0,               
    output  logic           mmu_lsu_buf1,               
    output  logic           mmu_lsu_ca0,                
    output  logic           mmu_lsu_ca1,                
    output  logic           mmu_lsu_data_req,           
    output  logic   [39:0]  mmu_lsu_data_req_addr,      
    output  logic           mmu_lsu_data_req_size,      
    output  logic           mmu_lsu_mmu_en,             
    output  logic   [27:0]  mmu_lsu_pa0,                
    output  logic           mmu_lsu_pa0_vld,            
    output  logic   [27:0]  mmu_lsu_pa1,                
    output  logic           mmu_lsu_pa1_vld,            
    output  logic   [27:0]  mmu_lsu_pa2,                
    output  logic           mmu_lsu_pa2_err,            
    output  logic           mmu_lsu_pa2_vld,            
    output  logic           mmu_lsu_page_fault0,        
    output  logic           mmu_lsu_page_fault1,        
    output  logic           mmu_lsu_sec0,               
    output  logic           mmu_lsu_sec1,               
    output  logic           mmu_lsu_sec2,               
    output  logic           mmu_lsu_sh0,                
    output  logic           mmu_lsu_sh1,                
    output  logic           mmu_lsu_share2,             
    output  logic           mmu_lsu_so0,                
    output  logic           mmu_lsu_so1,                
    output  logic           mmu_lsu_stall0,             
    output  logic           mmu_lsu_stall1,             
    output  logic           mmu_lsu_tlb_busy,           
    output  logic           mmu_lsu_tlb_inv_done,       
    output  logic   [11:0]  mmu_lsu_tlb_wakeup,         
    output  logic           mmu_pmp_fetch3,             
    output  logic   [27:0]  mmu_pmp_pa0,                
    output  logic   [27:0]  mmu_pmp_pa1,                
    output  logic   [27:0]  mmu_pmp_pa2,                
    output  logic   [27:0]  mmu_pmp_pa3,                
    output  logic   [27:0]  mmu_pmp_pa4,                
    output  logic           mmu_xx_mmu_en,              
    output  logic           mmu_yy_xx_no_op          

);


// &Wires; @31
wire            arb_dutlb_grant;            
wire            arb_iutlb_grant;            
wire    [2 :0]  arb_jtlb_acc_type;          
wire    [3 :0]  arb_jtlb_bank_sel;          
wire            arb_jtlb_cmp_with_va;       
wire    [41:0]  arb_jtlb_data_din;          
wire    [3 :0]  arb_jtlb_fifo_din;          
wire            arb_jtlb_fifo_write;        
wire    [8 :0]  arb_jtlb_idx;               
wire            arb_jtlb_req;               
wire    [47:0]  arb_jtlb_tag_din;           
wire    [26:0]  arb_jtlb_vpn;               
wire            arb_jtlb_write;             
wire            arb_ptw_grant;              
wire            arb_ptw_mask;               
wire            arb_tlboper_grant;          
wire    [1 :0]  arb_top_cur_st;             
wire            arb_top_tlboper_on;         
//wire            biu_mmu_smp_disable;        
//wire            cp0_mmu_cskyee;             
//wire            cp0_mmu_icg_en;             
//wire            cp0_mmu_maee;               
//wire    [1 :0]  cp0_mmu_mpp;                
//wire            cp0_mmu_mprv;               
//wire            cp0_mmu_mxr;                
//wire            cp0_mmu_no_op_req;          
//wire            cp0_mmu_ptw_en;             
//wire    [1 :0]  cp0_mmu_reg_num;            
//wire            cp0_mmu_satp_sel;           
//wire            cp0_mmu_sum;                
//wire            cp0_mmu_tlb_all_inv;        
//wire    [63:0]  cp0_mmu_wdata;              
//wire            cp0_mmu_wreg;               
//wire    [1 :0]  cp0_yy_priv_mode;           
//wire            cpurst_b;                   
wire            dutlb_arb_cmplt;            
wire            dutlb_arb_load;             
wire            dutlb_arb_req;              
wire    [26:0]  dutlb_arb_vpn;              
wire            dutlb_ptw_wfc;              
wire    [2 :0]  dutlb_top_ref_cur_st;       
wire            dutlb_top_ref_type;         
wire            dutlb_top_scd_updt;         
wire            dutlb_xx_mmu_off;           
//wire            forever_cpuclk;             
//wire            hpcp_mmu_cnt_en;            
///wire            ifu_mmu_abort;              
//wire    [62:0]  ifu_mmu_va;                 
//wire            ifu_mmu_va_vld;             
wire            iutlb_arb_cmplt;            
wire            iutlb_arb_req;              
wire    [26:0]  iutlb_arb_vpn;              
wire            iutlb_ptw_wfc;              
wire    [1 :0]  iutlb_top_ref_cur_st;       
wire            iutlb_top_scd_updt;         
wire            jtlb_arb_cmp_va;            
wire            jtlb_arb_par_clr;           
wire            jtlb_arb_pfu_cmplt;         
wire    [26:0]  jtlb_arb_pfu_vpn;           
wire            jtlb_arb_sel_1g;            
wire            jtlb_arb_sel_2m;            
wire            jtlb_arb_sel_4k;            
wire            jtlb_arb_tc_miss;           
wire    [2 :0]  jtlb_arb_type;              
wire    [26:0]  jtlb_arb_vpn;               
wire            jtlb_dutlb_acc_err;         
wire            jtlb_dutlb_pgflt;           
wire            jtlb_dutlb_ref_cmplt;       
wire            jtlb_dutlb_ref_pavld;       
wire            jtlb_iutlb_acc_err;         
wire            jtlb_iutlb_pgflt;           
wire            jtlb_iutlb_ref_cmplt;       
wire            jtlb_iutlb_ref_pavld;       
wire            jtlb_ptw_req;               
wire    [2 :0]  jtlb_ptw_type;              
wire    [26:0]  jtlb_ptw_vpn;               
wire            jtlb_regs_hit;              
wire            jtlb_regs_hit_mult;         
wire    [10:0]  jtlb_regs_tlbp_hit_index;   
wire            jtlb_tlboper_asid_hit;      
wire            jtlb_tlboper_cmplt;         
wire    [3 :0]  jtlb_tlboper_fifo;          
wire            jtlb_tlboper_read_idle;     
wire    [3 :0]  jtlb_tlboper_sel;           
wire            jtlb_tlboper_va_hit;        
wire    [15:0]  jtlb_tlbr_asid;             
wire    [13:0]  jtlb_tlbr_flg;              
wire            jtlb_tlbr_g;                
wire    [2 :0]  jtlb_tlbr_pgs;              
wire    [27:0]  jtlb_tlbr_ppn;              
wire    [26:0]  jtlb_tlbr_vpn;              
wire    [1 :0]  jtlb_top_cur_st;            
wire            jtlb_top_utlb_pavld;        
wire    [13:0]  jtlb_utlb_ref_flg;          
wire    [2 :0]  jtlb_utlb_ref_pgs;          
wire    [27:0]  jtlb_utlb_ref_ppn;          
wire    [26:0]  jtlb_utlb_ref_vpn;          
wire    [11:0]  jtlb_xx_fifo;               
wire            jtlb_xx_tc_read;            
//wire            lsu_mmu_abort0;             
//wire            lsu_mmu_abort1;             
//wire            lsu_mmu_bus_error;          
//wire    [63:0]  lsu_mmu_data;               
//wire            lsu_mmu_data_vld;           
//wire    [6 :0]  lsu_mmu_id0;                
//wire    [6 :0]  lsu_mmu_id1;                
//wire            lsu_mmu_st_inst0;           
//wire            lsu_mmu_st_inst1;           
//wire    [27:0]  lsu_mmu_stamo_pa;           
//wire            lsu_mmu_stamo_vld;          
//wire            lsu_mmu_tlb_all_inv;        
//wire    [15:0]  lsu_mmu_tlb_asid;           
//wire            lsu_mmu_tlb_asid_all_inv;   
//wire    [26:0]  lsu_mmu_tlb_va;             
//wire            lsu_mmu_tlb_va_all_inv;     
//wire            lsu_mmu_tlb_va_asid_inv;    
//wire    [63:0]  lsu_mmu_va0;                
//wire            lsu_mmu_va0_vld;            
//wire    [63:0]  lsu_mmu_va1;                
//wire            lsu_mmu_va1_vld;            
//wire    [27:0]  lsu_mmu_va2;                
//wire            lsu_mmu_va2_vld;            
//wire    [27:0]  lsu_mmu_vabuf0;             
//wire    [27:0]  lsu_mmu_vabuf1;             
//wire            mmu_cp0_cmplt;              
//wire    [63:0]  mmu_cp0_data;               
//wire    [63:0]  mmu_cp0_satp_data;          
//wire            mmu_cp0_tlb_done;           
//wire    [33:0]  mmu_had_debug_info;         
//wire            mmu_hpcp_dutlb_miss;        
//wire            mmu_hpcp_iutlb_miss;        
//wire            mmu_hpcp_jtlb_miss;         
//wire            mmu_ifu_buf;                
//wire            mmu_ifu_ca;                 
//wire            mmu_ifu_deny;               
//wire    [27:0]  mmu_ifu_pa;                 
//wire            mmu_ifu_pavld;              
//wire            mmu_ifu_pgflt;              
//wire            mmu_ifu_sec;                
//wire            mmu_lsu_access_fault0;      
//wire            mmu_lsu_access_fault1;      
//wire            mmu_lsu_buf0;               
//wire            mmu_lsu_buf1;               
//wire            mmu_lsu_ca0;                
//wire            mmu_lsu_ca1;                
//wire            mmu_lsu_data_req;           
//wire    [39:0]  mmu_lsu_data_req_addr;      
//wire            mmu_lsu_data_req_size;      
//wire            mmu_lsu_mmu_en;             
//wire    [27:0]  mmu_lsu_pa0;                
//wire            mmu_lsu_pa0_vld;            
//wire    [27:0]  mmu_lsu_pa1;                
//wire            mmu_lsu_pa1_vld;            
//wire    [27:0]  mmu_lsu_pa2;                
//wire            mmu_lsu_pa2_err;            
//wire            mmu_lsu_pa2_vld;            
//wire            mmu_lsu_page_fault0;        
//wire            mmu_lsu_page_fault1;        
//wire            mmu_lsu_sec0;               
//wire            mmu_lsu_sec1;               
//wire            mmu_lsu_sec2;               
//wire            mmu_lsu_sh0;                
//wire            mmu_lsu_sh1;                
//wire            mmu_lsu_share2;             
//wire            mmu_lsu_so0;                
//wire            mmu_lsu_so1;                
//wire            mmu_lsu_stall0;             
///wire            mmu_lsu_stall1;             
//wire            mmu_lsu_tlb_busy;           
//wire            mmu_lsu_tlb_inv_done;       
//wire    [11:0]  mmu_lsu_tlb_wakeup;         
//wire            mmu_pmp_fetch3;             
//wire    [27:0]  mmu_pmp_pa0;                
//wire    [27:0]  mmu_pmp_pa1;                
//wire    [27:0]  mmu_pmp_pa2;                
//wire    [27:0]  mmu_pmp_pa3;                
//wire    [27:0]  mmu_pmp_pa4;                
wire    [27:0]  mmu_sysmap_pa0;             
wire    [27:0]  mmu_sysmap_pa1;             
wire    [27:0]  mmu_sysmap_pa2;             
wire    [27:0]  mmu_sysmap_pa3;             
wire    [27:0]  mmu_sysmap_pa4;             
//wire            mmu_xx_mmu_en;              
//wire            mmu_yy_xx_no_op;            
//wire            pad_yy_icg_scan_en;         
//wire    [3 :0]  pmp_mmu_flg0;               
//wire    [3 :0]  pmp_mmu_flg1;               
//wire    [3 :0]  pmp_mmu_flg2;               
//wire    [3 :0]  pmp_mmu_flg3;               
//wire    [3 :0]  pmp_mmu_flg4;               
wire    [3 :0]  ptw_arb_bank_sel;           
wire    [41:0]  ptw_arb_data_din;           
wire    [3 :0]  ptw_arb_fifo_din;           
wire    [2 :0]  ptw_arb_pgs;                
wire            ptw_arb_req;                
wire    [47:0]  ptw_arb_tag_din;            
wire    [26:0]  ptw_arb_vpn;                
wire            ptw_jtlb_dmiss;             
wire            ptw_jtlb_imiss;             
wire            ptw_jtlb_pmiss;             
wire            ptw_jtlb_ref_acc_err;       
wire            ptw_jtlb_ref_cmplt;         
wire            ptw_jtlb_ref_data_vld;      
wire    [13:0]  ptw_jtlb_ref_flg;           
wire            ptw_jtlb_ref_pgflt;         
wire    [2 :0]  ptw_jtlb_ref_pgs;           
wire    [27:0]  ptw_jtlb_ref_ppn;           
wire    [3 :0]  ptw_top_cur_st;             
wire            ptw_top_imiss;              
wire    [15:0]  regs_jtlb_cur_asid;         
wire    [13:0]  regs_jtlb_cur_flg;          
wire            regs_jtlb_cur_g;            
wire    [27:0]  regs_jtlb_cur_ppn;          
wire            regs_mmu_en;                
wire    [15:0]  regs_ptw_cur_asid;          
wire    [27:0]  regs_ptw_satp_ppn;          
wire    [15:0]  regs_tlboper_cur_asid;      
wire    [2 :0]  regs_tlboper_cur_pgs;       
wire    [26:0]  regs_tlboper_cur_vpn;       
wire    [15:0]  regs_tlboper_inv_asid;      
wire            regs_tlboper_invall;        
wire            regs_tlboper_invasid;       
wire    [11:0]  regs_tlboper_mir;           
wire            regs_tlboper_tlbp;          
wire            regs_tlboper_tlbr;          
wire            regs_tlboper_tlbwi;         
wire            regs_tlboper_tlbwr;         
wire            regs_utlb_clr;              
//wire    [26:0]  rtu_mmu_bad_vpn;            
//wire            rtu_mmu_expt_vld;           
//wire            rtu_yy_xx_flush;            
wire    [4 :0]  sysmap_mmu_flg0;            
wire    [4 :0]  sysmap_mmu_flg1;            
wire    [4 :0]  sysmap_mmu_flg2;            
wire    [4 :0]  sysmap_mmu_flg3;            
wire    [4 :0]  sysmap_mmu_flg4;            
wire    [7 :0]  sysmap_mmu_hit0;            
wire    [7 :0]  sysmap_mmu_hit1;            
wire    [7 :0]  sysmap_mmu_hit2;            
wire    [7 :0]  sysmap_mmu_hit3;            
wire    [7 :0]  sysmap_mmu_hit4;            
wire    [3 :0]  tlboper_arb_bank_sel;       
wire            tlboper_arb_cmp_va;         
wire    [41:0]  tlboper_arb_data_din;       
wire    [3 :0]  tlboper_arb_fifo_din;       
wire            tlboper_arb_fifo_write;     
wire    [8 :0]  tlboper_arb_idx;            
wire            tlboper_arb_idx_not_va;     
wire            tlboper_arb_req;            
wire    [47:0]  tlboper_arb_tag_din;        
wire    [26:0]  tlboper_arb_vpn;            
wire            tlboper_arb_write;          
wire    [15:0]  tlboper_jtlb_asid;          
wire            tlboper_jtlb_asid_sel;      
wire            tlboper_jtlb_cmp_noasid;    
wire    [15:0]  tlboper_jtlb_inv_asid;      
wire            tlboper_jtlb_tlbwr_on;      
wire            tlboper_ptw_abort;          
wire            tlboper_regs_cmplt;         
wire            tlboper_regs_tlbp_cmplt;    
wire            tlboper_regs_tlbr_cmplt;    
wire            tlboper_top_lsu_cmplt;      
wire            tlboper_top_lsu_oper;       
wire            tlboper_top_tlbiall_cur_st; 
wire    [2 :0]  tlboper_top_tlbiasid_cur_st; 
wire    [3 :0]  tlboper_top_tlbiva_cur_st;  
wire    [1 :0]  tlboper_top_tlbp_cur_st;    
wire    [1 :0]  tlboper_top_tlbr_cur_st;    
wire    [1 :0]  tlboper_top_tlbwi_cur_st;   
wire    [1 :0]  tlboper_top_tlbwr_cur_st;   
wire            tlboper_utlb_clr;           
wire            tlboper_utlb_inv_va_req;    
wire            tlboper_xx_cmplt;           
wire    [2 :0]  tlboper_xx_pgs;             
wire            tlboper_xx_pgs_en;          
wire            utlb_clk;                   
wire            utlb_clk_en;                


assign utlb_clk_en = regs_utlb_clr
                  || tlboper_utlb_clr
                  || tlboper_utlb_inv_va_req
                  || !regs_mmu_en
                  || jtlb_top_utlb_pavld
                  || dutlb_top_scd_updt
                  || iutlb_top_scd_updt;

// &Instance("gated_clk_cell", "x_utlb_gateclk"); @41
gated_clk_cell  x_utlb_gateclk (
  .clk_in             (forever_cpuclk    ),
  .clk_out            (utlb_clk          ),
  .external_en        (1'b0              ),
  .global_en          (1'b1              ),
  .local_en           (utlb_clk_en       ),
  .module_en          (cp0_mmu_icg_en    ),
  .pad_yy_icg_scan_en (pad_yy_icg_scan_en)
);


//==========================================================
// Instance utlbs
//==========================================================
// &Instance("ct_mmu_iutlb","x_ct_mmu_iutlb"); @53
ct_mmu_iutlb  x_ct_mmu_iutlb (.*);

// &Instance("ct_mmu_dutlb","x_ct_mmu_dutlb"); @54
ct_mmu_dutlb  x_ct_mmu_dutlb (.*);


//==========================================================
// Instance mmu regs
//==========================================================
// &Instance("ct_mmu_regs", "x_ct_mmu_regs"); @59
ct_mmu_regs  x_ct_mmu_regs (.*);


//==========================================================
// Instance cp0 & ctc request module
//==========================================================
// &Instance("ct_mmu_tlboper", "x_ct_mmu_tlboper"); @64
ct_mmu_tlboper  x_ct_mmu_tlboper (.*);


//==========================================================
// Instance jTLB request arbiter
//==========================================================
// &Instance("ct_mmu_arb", "x_ct_mmu_arb"); @69
ct_mmu_arb  x_ct_mmu_arb (.*);

//==========================================================
// Instance jTLB pipeline module
//==========================================================
// &Instance("ct_mmu_jtlb", "x_ct_mmu_jtlb"); @74
ct_mmu_jtlb  x_ct_mmu_jtlb (.*);


//==========================================================
// Instance PTW
//==========================================================
// &Instance("ct_mmu_ptw", "x_ct_mmu_ptw"); @79
ct_mmu_ptw  x_ct_mmu_ptw (.*);


//==========================================================
// Instance System Map
//==========================================================
// &Force("nonport", "sysmap_mmu_hit0"); @84
// &Force("nonport", "sysmap_mmu_hit1"); @85
// &Force("nonport", "sysmap_mmu_hit2"); @86
// &Force("nonport", "sysmap_mmu_hit4"); @87

// &ConnRule(s/_y/0/); @89
// &Instance("ct_mmu_sysmap", "x_ct_mmu_sysmap_0"); @90
ct_mmu_sysmap  x_ct_mmu_sysmap_0 (
  .mmu_sysmap_pa_y  (mmu_sysmap_pa0  ),
  .sysmap_mmu_flg_y (sysmap_mmu_flg0 ),
  .sysmap_mmu_hit_y (sysmap_mmu_hit0 )
);


// &ConnRule(s/_y/1/); @92
// &Instance("ct_mmu_sysmap", "x_ct_mmu_sysmap_1"); @93
ct_mmu_sysmap  x_ct_mmu_sysmap_1 (
  .mmu_sysmap_pa_y  (mmu_sysmap_pa1  ),
  .sysmap_mmu_flg_y (sysmap_mmu_flg1 ),
  .sysmap_mmu_hit_y (sysmap_mmu_hit1 )
);


// &ConnRule(s/_y/2/); @95
// &Instance("ct_mmu_sysmap", "x_ct_mmu_sysmap_2"); @96
ct_mmu_sysmap  x_ct_mmu_sysmap_2 (
  .mmu_sysmap_pa_y  (mmu_sysmap_pa2  ),
  .sysmap_mmu_flg_y (sysmap_mmu_flg2 ),
  .sysmap_mmu_hit_y (sysmap_mmu_hit2 )
);


// &ConnRule(s/_y/3/); @98
// &Instance("ct_mmu_sysmap", "x_ct_mmu_sysmap_3"); @99
ct_mmu_sysmap  x_ct_mmu_sysmap_3 (
  .mmu_sysmap_pa_y  (mmu_sysmap_pa3  ),
  .sysmap_mmu_flg_y (sysmap_mmu_flg3 ),
  .sysmap_mmu_hit_y (sysmap_mmu_hit3 )
);


// &ConnRule(s/_y/4/); @101
// &Instance("ct_mmu_sysmap", "x_ct_mmu_sysmap_4"); @102
ct_mmu_sysmap  x_ct_mmu_sysmap_4 (
  .mmu_sysmap_pa_y  (mmu_sysmap_pa4  ),
  .sysmap_mmu_flg_y (sysmap_mmu_flg4 ),
  .sysmap_mmu_hit_y (sysmap_mmu_hit4 )
);


// for dbg
assign mmu_had_debug_info[33:0] = {iutlb_top_ref_cur_st[1:0],
                                   dutlb_top_ref_cur_st[2:0], dutlb_top_ref_type,
                                   tlboper_top_tlbp_cur_st[1:0], tlboper_top_tlbr_cur_st[1:0],
                                   tlboper_top_tlbwi_cur_st[1:0], tlboper_top_tlbwr_cur_st[1:0],
                                   tlboper_top_tlbiasid_cur_st[2:0], tlboper_top_tlbiall_cur_st,
                                   tlboper_top_tlbiva_cur_st[3:0], tlboper_top_lsu_oper, tlboper_top_lsu_cmplt,
                                   arb_top_cur_st[1:0], arb_top_tlboper_on, jtlb_top_cur_st[1:0],
                                   ptw_top_cur_st[3:0], ptw_top_imiss};

// for coverage

// &ModuleEnd; @189
endmodule



