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

module ct_ifu_addrgen #(
        parameter       PC_WIDTH            = 40
    )
    (
        output          [9 :0]              addrgen_btb_index,
        output          [9 :0]              addrgen_btb_tag,
        output          [19:0]              addrgen_btb_target_pc,
        output                              addrgen_btb_update_vld,
        output                              addrgen_ibctrl_cancel,
        output          [7 :0]              addrgen_ipdp_chgflw_vl,
        output          [1 :0]              addrgen_ipdp_chgflw_vlmul,
        output          [2 :0]              addrgen_ipdp_chgflw_vsew,
        output          [15:0]              addrgen_l0_btb_update_entry,
        output                              addrgen_l0_btb_update_vld,
        output                              addrgen_l0_btb_update_vld_bit,
        output          [3 :0]              addrgen_l0_btb_wen,
        output          [38:0]              addrgen_pcgen_pc,
        output                              addrgen_pcgen_pcload,
        output                              addrgen_xx_pcload,
        input                               cp0_ifu_icg_en,
        input                               cp0_yy_clk_en,
        input                               cpurst_b,
        input                               forever_cpuclk,
        input           [38:0]              ibdp_addrgen_branch_base,
        input           [20:0]              ibdp_addrgen_branch_offset,
        input           [38:0]              ibdp_addrgen_branch_result,
        input                               ibdp_addrgen_branch_valid,
        input           [7 :0]              ibdp_addrgen_branch_vl,
        input           [1 :0]              ibdp_addrgen_branch_vlmul,
        input           [2 :0]              ibdp_addrgen_branch_vsew,
        input           [38:0]              ibdp_addrgen_btb_index_pc,
        input                               ibdp_addrgen_l0_btb_hit,
        input           [15:0]              ibdp_addrgen_l0_btb_hit_entry,
        output                              ifu_hpcp_btb_inst,
        output                              ifu_hpcp_btb_mispred,
        input                               lbuf_addrgen_active_state,
        input                               lbuf_addrgen_cache_state,
        input                               lbuf_addrgen_chgflw_mask,
        input                               pad_yy_icg_scan_en,
        input                               pcgen_addrgen_cancel
    );

    // &Regs; @24
    reg                 [9 :0]              addrgen_branch_index;
    reg                 [9 :0]              addrgen_branch_tag;
    reg                 [7 :0]              addrgen_branch_vl;
    reg                 [1 :0]              addrgen_branch_vlmul;
    reg                 [2 :0]              addrgen_branch_vsew;
    reg                                     addrgen_btb_mispred;
    reg                 [38:0]              addrgen_cal_result_flop;
    reg                                     addrgen_l0_btb_hit;
    reg                 [15:0]              addrgen_l0_btb_hit_entry;
    reg                                     addrgen_vld;

    // &Wires; @25
    wire                                    addrgen_flop_clk;
    wire                                    addrgen_flop_clk_en;
    wire                [38:0]              branch_base;
    wire                [38:0]              branch_cal_result;
    wire                [9 :0]              branch_index;
    wire                                    branch_mispred;
    wire                [38:0]              branch_offset;
    wire                [38:0]              branch_pred_result;
    wire                [9 :0]              branch_tag;
    wire                [7 :0]              branch_vl;
    wire                                    branch_vld;
    wire                                    branch_vld_for_gateclk;
    wire                [1 :0]              branch_vlmul;
    wire                [2 :0]              branch_vsew;
    wire                                    l0_btb_hit;
    wire                [15:0]              l0_btb_hit_entry;
    wire                                    l0_btb_update_vld;
    wire                [3 :0]              l0_btb_wen;

    // &Force("bus","ibdp_addrgen_branch_offset",20,0); @27
    // &Force("bus","ibdp_addrgen_btb_index_pc",38,0); @28
    //==========================================================
    //             Branch Adder Result Calculate
    //==========================================================
    //The reason why addrgen should not chgflw when lbuf cache state:
    //When lbuf cache state, the miss/mispred branch can only be loop end
    //While for loop end branch, we will not use BTB target as target PC
    //We use Loop Buffer adder get its target and it will not mispred/miss
    assign branch_vld_for_gateclk   = ibdp_addrgen_branch_valid &&
           !lbuf_addrgen_active_state &&
           !lbuf_addrgen_cache_state;
    assign branch_vld               =  branch_vld_for_gateclk &&
           !lbuf_addrgen_chgflw_mask;
    assign branch_base[PC_WIDTH-2:0]        = ibdp_addrgen_branch_base[PC_WIDTH-2:0];
    assign branch_offset[PC_WIDTH-2:0]      = {{19{ibdp_addrgen_branch_offset[20]}},ibdp_addrgen_branch_offset[20:1]};
    assign branch_vlmul[1:0]                = ibdp_addrgen_branch_vlmul[1:0];
    assign branch_vsew[2:0]                 = ibdp_addrgen_branch_vsew[2:0];
    assign branch_vl[7:0]                   = ibdp_addrgen_branch_vl[7:0];
    assign branch_pred_result[PC_WIDTH-2:0] = ibdp_addrgen_branch_result[PC_WIDTH-2:0];
    assign branch_cal_result[PC_WIDTH-2:0]  = branch_base[PC_WIDTH-2:0] + branch_offset[PC_WIDTH-2:0];
    assign branch_mispred                   = (branch_pred_result[PC_WIDTH-2:0] != branch_cal_result[PC_WIDTH-2:0]);
    assign branch_index[9:0]                = ibdp_addrgen_btb_index_pc[12:3];
    assign branch_tag[9:0]                  = {ibdp_addrgen_btb_index_pc[19:13],
            ibdp_addrgen_btb_index_pc[2:0]};
    assign l0_btb_hit              = ibdp_addrgen_l0_btb_hit;
    assign l0_btb_hit_entry[15:0]  = ibdp_addrgen_l0_btb_hit_entry[15:0];
    //==========================================================
    //                Addrgen Flop Infor
    //==========================================================
    always @(posedge addrgen_flop_clk or negedge cpurst_b) begin
        if(!cpurst_b)
            addrgen_vld <= 1'b0;
        else if(pcgen_addrgen_cancel)
            addrgen_vld <= 1'b0;
        else
            addrgen_vld <= branch_vld;
    end

    //_flop means the next cycle of addrgen IB stage
    always @(posedge addrgen_flop_clk or negedge cpurst_b) begin
        if(!cpurst_b) begin
            addrgen_cal_result_flop[PC_WIDTH-2:0]  <= {PC_WIDTH-1{1'b0}};
            addrgen_branch_index[9:0]              <= 10'b0;
            addrgen_branch_tag[9:0]                <= 10'b0;
            addrgen_btb_mispred                    <= 1'b0;
            addrgen_branch_vlmul[1:0]              <= 2'b0;
            addrgen_branch_vsew[2:0]               <= 3'b0;
            addrgen_branch_vl[7:0]                 <= 8'b0;
            addrgen_l0_btb_hit                     <= 1'b0;
            addrgen_l0_btb_hit_entry[15:0]         <= 16'b0;
        end
        else if(branch_vld) begin
            addrgen_cal_result_flop[PC_WIDTH-2:0]  <= branch_cal_result[PC_WIDTH-2:0];
            addrgen_branch_index[9:0]              <= branch_index[9:0];
            addrgen_branch_tag[9:0]                <= branch_tag[9:0];
            addrgen_btb_mispred                    <= branch_mispred;
            addrgen_branch_vlmul[1:0]              <= branch_vlmul[1:0];
            addrgen_branch_vsew[2:0]               <= branch_vsew[2:0];
            addrgen_branch_vl[7:0]                 <= branch_vl[7:0];
            addrgen_l0_btb_hit                     <= l0_btb_hit;
            addrgen_l0_btb_hit_entry[15:0]         <= l0_btb_hit_entry[15:0];
        end
        else begin
            addrgen_cal_result_flop[PC_WIDTH-2:0]  <= addrgen_cal_result_flop[PC_WIDTH-2:0];
            addrgen_branch_index[9:0]              <= addrgen_branch_index[9:0];
            addrgen_branch_tag[9:0]                <= addrgen_branch_tag[9:0];
            addrgen_btb_mispred                    <= addrgen_btb_mispred;
            addrgen_branch_vlmul[1:0]              <= addrgen_branch_vlmul[1:0];
            addrgen_branch_vsew[2:0]               <= addrgen_branch_vsew[2:0];
            addrgen_branch_vl[7:0]                 <= addrgen_branch_vl[7:0];
            addrgen_l0_btb_hit                     <= addrgen_l0_btb_hit;
            addrgen_l0_btb_hit_entry[15:0]         <= addrgen_l0_btb_hit_entry[15:0];
        end
    end

    //Gate Clk
    // &Instance("gated_clk_cell","x_addrgen_flop_clk"); @117
    gated_clk_cell  x_addrgen_flop_clk (
                        .clk_in              (forever_cpuclk     ),
                        .clk_out             (addrgen_flop_clk   ),
                        .external_en         (1'b0               ),
                        .global_en           (cp0_yy_clk_en      ),
                        .local_en            (addrgen_flop_clk_en),
                        .module_en           (cp0_ifu_icg_en     ),
                        .pad_yy_icg_scan_en  (pad_yy_icg_scan_en )
                    );

    // &Connect( .clk_in         (forever_cpuclk), @118
    //           .clk_out        (addrgen_flop_clk),//Out Clock @119
    //           .external_en    (1'b0), @120
    //           .global_en      (cp0_yy_clk_en), @121
    //           .local_en       (addrgen_flop_clk_en),//Local Condition @122
    //           .module_en      (cp0_ifu_icg_en) @123
    //         ); @124
    assign addrgen_flop_clk_en = branch_vld_for_gateclk ||
           addrgen_vld ||
           pcgen_addrgen_cancel;

    //==========================================================
    //                 Addrgen Change Flow
    //==========================================================
    assign addrgen_pcgen_pcload           = addrgen_vld && addrgen_btb_mispred;
    assign addrgen_xx_pcload              = addrgen_vld && addrgen_btb_mispred;
    assign addrgen_pcgen_pc[PC_WIDTH-2:0] = addrgen_cal_result_flop[PC_WIDTH-2:0];
    assign addrgen_ipdp_chgflw_vlmul[1:0] = addrgen_branch_vlmul[1:0];
    assign addrgen_ipdp_chgflw_vsew[2:0]  = addrgen_branch_vsew[2:0];
    assign addrgen_ipdp_chgflw_vl[7:0]    = addrgen_branch_vl[7:0];
    assign addrgen_btb_index[9:0]         = addrgen_branch_index[9:0];
    assign addrgen_btb_tag[9:0]           = addrgen_branch_tag[9:0];
    assign addrgen_btb_target_pc[19:0]    = addrgen_cal_result_flop[19:0];
    assign addrgen_btb_update_vld         = addrgen_pcgen_pcload;
    // &Force("output","addrgen_pcgen_pcload"); @144

    assign ifu_hpcp_btb_mispred           = addrgen_vld && addrgen_btb_mispred;
    assign ifu_hpcp_btb_inst              = addrgen_vld;

    //==========================================================
    //                 Addrgen IB Cancel
    //==========================================================
    assign addrgen_ibctrl_cancel = addrgen_pcgen_pcload;

    //==========================================================
    //                 Addrgen L0 BTB Update
    //==========================================================
    assign l0_btb_update_vld = addrgen_vld
           && addrgen_btb_mispred
           && addrgen_l0_btb_hit;
    assign l0_btb_wen[3]     = l0_btb_update_vld;
    assign l0_btb_wen[2:0]   = 3'b0;

    assign addrgen_l0_btb_update_vld         = l0_btb_update_vld;
    assign addrgen_l0_btb_wen[3:0]           = l0_btb_wen[3:0];
    assign addrgen_l0_btb_update_vld_bit     = 1'b0;
    assign addrgen_l0_btb_update_entry[15:0] = addrgen_l0_btb_hit_entry[15:0];
    // &ModuleEnd; @169
endmodule
