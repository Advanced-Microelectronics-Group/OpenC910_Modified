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

module ct_ifu_ibuf_entry (
        input                               cp0_ifu_icg_en,
        input                               cp0_yy_clk_en,
        input                               cpurst_b,
        input                               entry_create_32_start_x,
        input                               entry_create_acc_err_x,
        input                               entry_create_bkpta_x,
        input                               entry_create_bkptb_x,
        input                               entry_create_fence_x,
        input                               entry_create_high_expt_x,
        input           [15:0]              entry_create_inst_data_v,
        input                               entry_create_no_spec_x,
        input           [14:0]              entry_create_pc_v,
        input                               entry_create_pgflt_x,
        input                               entry_create_split0_x,
        input                               entry_create_split1_x,
        input                               entry_create_vl_pred_x,
        input           [7 :0]              entry_create_vl_v,
        input           [1 :0]              entry_create_vlmul_v,
        input           [2 :0]              entry_create_vsew_v,
        input                               entry_create_x,
        input                               entry_data_create_clk_en_x,
        input                               entry_data_create_x,
        input                               entry_pc_create_clk_en_x,
        input                               entry_pc_create_x,
        input                               entry_retire_x,
        input                               entry_spe_data_vld,
        input                               entry_vld_create_clk_en_x,
        input                               entry_vld_retire_clk_en_x,
        input                               forever_cpuclk,
        input                               ibuf_flush,
        input                               pad_yy_icg_scan_en,
        output reg                          entry_32_start_x,
        output reg                          entry_acc_err_x,
        output reg                          entry_bkpta_x,
        output reg                          entry_bkptb_x,
        output reg                          entry_fence_x,
        output reg                          entry_high_expt_x,
        output reg      [15:0]              entry_inst_data_v,
        output reg                          entry_no_spec_x,
        output reg      [14:0]              entry_pc_v,
        output reg                          entry_pgflt_x,
        output reg                          entry_split0_x,
        output reg                          entry_split1_x,
        output reg                          entry_vl_pred_x,
        output reg      [7 :0]              entry_vl_v,
        output reg                          entry_vld_x,
        output reg      [1 :0]              entry_vlmul_v,
        output reg      [2 :0]              entry_vsew_v
    );

    // &Wires; @25
    wire                                    ibuf_entry_pc_clk;
    wire                                    ibuf_entry_pc_clk_en;
    wire                                    ibuf_entry_spe_clk;
    wire                                    ibuf_entry_spe_clk_en;
    wire                                    ibuf_entry_update_clk;
    wire                                    ibuf_entry_update_clk_en;
    wire                                    ibuf_entry_vld_clk;
    wire                                    ibuf_entry_vld_clk_en;

    //==========================================================
    //Inst Buffer Entry Fields Description:
    //+-----+------+----------+---------+-------+-----------+--------+--------+-------+
    //| vld | inst | 32_start | acc_err | pgflt | high_expt | split1 | split0 | fence |
    //+-----+------+----------+---------+-------+-----------+--------+--------+-------+
    //==========================================================
    //vld           means entry valid
    //inst[15:0]    means the half word inst data
    //32_start      means this half is the start of 32 inst
    //acc_err       means this half have acc_err expt
    //pgflt         means this half have pgflt expt
    //tinv          means this half have tinv expt
    //tfatal        means this half have tfatal expt
    //high_expt      means 32 bit inst & expt happen at low half
    //split1        means predecode info
    //split0        means predecode info
    //fence         means predecode info

    //==========================================================
    //                  Entry Valid Signal
    //==========================================================
    //----------------------Gate Clock--------------------------
    // &Instance("gated_clk_cell","x_ibuf_entry_vld_clk"); @49
    gated_clk_cell      x_ibuf_entry_vld_clk (
                            .clk_in                (forever_cpuclk       ),
                            .clk_out               (ibuf_entry_vld_clk   ),
                            .external_en           (1'b0                 ),
                            .global_en             (cp0_yy_clk_en        ),
                            .local_en              (ibuf_entry_vld_clk_en),
                            .module_en             (cp0_ifu_icg_en       ),
                            .pad_yy_icg_scan_en    (pad_yy_icg_scan_en   )
                        );

    // &Connect( .clk_in         (forever_cpuclk), @50
    //           .clk_out        (ibuf_entry_vld_clk),//Out Clock @51
    //           .external_en    (1'b0), @52
    //           .global_en      (cp0_yy_clk_en), @53
    //           .local_en       (ibuf_entry_vld_clk_en),//Local Condition @54
    //           .module_en      (cp0_ifu_icg_en) @55
    //         ); @56
    assign ibuf_entry_vld_clk_en = entry_vld_create_clk_en_x ||
           entry_vld_retire_clk_en_x ||
           ibuf_flush;
    always @(posedge ibuf_entry_vld_clk or negedge cpurst_b) begin
        if(!cpurst_b)
            entry_vld_x <= 1'b0;
        else if(ibuf_flush)
            entry_vld_x <= 1'b0;
        else if(entry_create_x)
            entry_vld_x <= 1'b1;
        else if(entry_retire_x)
            entry_vld_x <= 1'b0;
        else
            entry_vld_x <= entry_vld_x;
    end

    //==========================================================
    //                  Entry Data Signal
    //==========================================================
    //----------------------Gate Clock--------------------------
    // &Instance("gated_clk_cell","x_ibuf_entry_update_clk"); @78
    gated_clk_cell      x_ibuf_entry_update_clk (
                            .clk_in                   (forever_cpuclk          ),
                            .clk_out                  (ibuf_entry_update_clk   ),
                            .external_en              (1'b0                    ),
                            .global_en                (cp0_yy_clk_en           ),
                            .local_en                 (ibuf_entry_update_clk_en),
                            .module_en                (cp0_ifu_icg_en          ),
                            .pad_yy_icg_scan_en       (pad_yy_icg_scan_en      )
                        );

    // &Connect( .clk_in         (forever_cpuclk), @79
    //           .clk_out        (ibuf_entry_update_clk),//Out Clock @80
    //           .external_en    (1'b0), @81
    //           .global_en      (cp0_yy_clk_en), @82
    //           .local_en       (ibuf_entry_update_clk_en),//Local Condition @83
    //           .module_en      (cp0_ifu_icg_en) @84
    //         ); @85
    assign ibuf_entry_update_clk_en = entry_data_create_clk_en_x;

    // &Instance("gated_clk_cell","x_ibuf_entry_spe_clk"); @88
    gated_clk_cell      x_ibuf_entry_spe_clk (
                            .clk_in                (forever_cpuclk       ),
                            .clk_out               (ibuf_entry_spe_clk   ),
                            .external_en           (1'b0                 ),
                            .global_en             (cp0_yy_clk_en        ),
                            .local_en              (ibuf_entry_spe_clk_en),
                            .module_en             (cp0_ifu_icg_en       ),
                            .pad_yy_icg_scan_en    (pad_yy_icg_scan_en   )
                        );

    // &Connect( .clk_in         (forever_cpuclk), @89
    //           .clk_out        (ibuf_entry_spe_clk),//Out Clock @90
    //           .external_en    (1'b0), @91
    //           .global_en      (cp0_yy_clk_en), @92
    //           .local_en       (ibuf_entry_spe_clk_en),//Local Condition @93
    //           .module_en      (cp0_ifu_icg_en) @94
    //         ); @95
    assign ibuf_entry_spe_clk_en = entry_spe_data_vld ||
           entry_acc_err_x    ||
           entry_pgflt_x      ||
           entry_high_expt_x  ||
           entry_bkpta_x      ||
           entry_bkptb_x      ||
           entry_no_spec_x;

    // &Instance("gated_clk_cell","x_ibuf_entry_pc_clk"); @104
    gated_clk_cell      x_ibuf_entry_pc_clk (
                            .clk_in               (forever_cpuclk      ),
                            .clk_out              (ibuf_entry_pc_clk   ),
                            .external_en          (1'b0                ),
                            .global_en            (cp0_yy_clk_en       ),
                            .local_en             (ibuf_entry_pc_clk_en),
                            .module_en            (cp0_ifu_icg_en      ),
                            .pad_yy_icg_scan_en   (pad_yy_icg_scan_en  )
                        );

    // &Connect( .clk_in         (forever_cpuclk), @105
    //           .clk_out        (ibuf_entry_pc_clk),//Out Clock @106
    //           .external_en    (1'b0), @107
    //           .global_en      (cp0_yy_clk_en), @108
    //           .local_en       (ibuf_entry_pc_clk_en),//Local Condition @109
    //           .module_en      (cp0_ifu_icg_en) @110
    //         ); @111
    assign ibuf_entry_pc_clk_en = entry_pc_create_clk_en_x;

    //--------------------Register Update-----------------------
    //_x _v for instance entry convinent
    //entry 32 start is control signal, should use entry create to
    always @(posedge ibuf_entry_update_clk or negedge cpurst_b) begin
        if(!cpurst_b)
            entry_32_start_x <= 1'b0;
        else if(entry_create_x)
            entry_32_start_x <= entry_create_32_start_x;
        else
            entry_32_start_x <= entry_32_start_x;
    end

    always @(posedge ibuf_entry_update_clk or negedge cpurst_b) begin
        if(!cpurst_b) begin
            entry_inst_data_v[15:0] <= 16'b0;
            //    entry_32_start_x        <= 1'b0;
            entry_split1_x          <= 1'b0;
            entry_split0_x          <= 1'b0;
            entry_fence_x           <= 1'b0;
            entry_vlmul_v[1:0]      <= 2'b0;
            entry_vsew_v[2:0]       <= 3'b0;
            entry_vl_v[7:0]         <= 8'b0;
        end
        else if(entry_data_create_x) begin
            entry_inst_data_v[15:0] <= entry_create_inst_data_v[15:0];
            //    entry_32_start_x        <= entry_create_32_start_x;
            entry_split1_x          <= entry_create_split1_x;
            entry_split0_x          <= entry_create_split0_x;
            entry_fence_x           <= entry_create_fence_x;
            entry_vlmul_v[1:0]      <= entry_create_vlmul_v[1:0];
            entry_vsew_v[2:0]       <= entry_create_vsew_v[2:0];
            entry_vl_v[7:0]         <= entry_create_vl_v[7:0];
        end
        else begin
            entry_inst_data_v[15:0] <= entry_inst_data_v[15:0];
            //    entry_32_start_x        <= entry_32_start_x;
            entry_split1_x          <= entry_split1_x;
            entry_split0_x          <= entry_split0_x;
            entry_fence_x           <= entry_fence_x;
            entry_vlmul_v[1:0]      <= entry_vlmul_v[1:0];
            entry_vsew_v[2:0]       <= entry_vsew_v[2:0];
            entry_vl_v[7:0]         <= entry_vl_v[7:0];
        end
    end

    always @(posedge ibuf_entry_spe_clk or negedge cpurst_b) begin
        if(!cpurst_b) begin
            entry_acc_err_x         <= 1'b0;
            entry_pgflt_x           <= 1'b0;
            entry_high_expt_x       <= 1'b0;
            entry_bkpta_x           <= 1'b0;
            entry_bkptb_x           <= 1'b0;
            entry_no_spec_x         <= 1'b0;
            entry_vl_pred_x       <= 1'b0;
        end
        else if(entry_data_create_x) begin
            entry_acc_err_x         <= entry_create_acc_err_x;
            entry_pgflt_x           <= entry_create_pgflt_x;
            entry_high_expt_x       <= entry_create_high_expt_x;
            entry_bkpta_x           <= entry_create_bkpta_x;
            entry_bkptb_x           <= entry_create_bkptb_x;
            entry_no_spec_x         <= entry_create_no_spec_x;
            entry_vl_pred_x       <= entry_create_vl_pred_x;
        end
        else begin
            entry_acc_err_x         <= entry_acc_err_x;
            entry_pgflt_x           <= entry_pgflt_x;
            entry_high_expt_x       <= entry_high_expt_x;
            entry_bkpta_x           <= entry_bkpta_x;
            entry_bkptb_x           <= entry_bkptb_x;
            entry_no_spec_x         <= entry_no_spec_x;
            entry_vl_pred_x       <= entry_vl_pred_x;
        end
    end

    // &Force("output","entry_ecc_err_x"); @208

    always @(posedge ibuf_entry_pc_clk or negedge cpurst_b) begin
        if(!cpurst_b)
            entry_pc_v[14:0] <= 15'b0;
        else if(entry_pc_create_x)
            entry_pc_v[14:0] <= entry_create_pc_v[14:0];
        else
            entry_pc_v[14:0] <= entry_pc_v[14:0];
    end

    // &Force("output","entry_inst_data_v"); @222
    // &Force("output","entry_pc_v"); @223
    // &Force("output","entry_32_start_x"); @224
    // &Force("output","entry_acc_err_x"); @225
    // &Force("output","entry_pgflt_x"); @226
    // &Force("output","entry_high_expt_x"); @227
    // &Force("output","entry_split1_x"); @228
    // &Force("output","entry_split0_x"); @229
    // &Force("output","entry_fence_x"); @230
    // &Force("output","entry_vlmul_v"); @231
    // &Force("output","entry_vl_v"); @232
    // &Force("output","entry_vsew_v"); @233
    // &Force("output","entry_bkpta_x"); @234
    // &Force("output","entry_bkptb_x"); @235
    // &Force("output","entry_no_spec_x"); @236
    // &Force("output","entry_vl_pred_x"); @237
    // &Force("output","entry_vld_x"); @238

endmodule
