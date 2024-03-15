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

module ct_f_spsram_512x96 #(
        parameter       ADDR_WIDTH          = 9,
        parameter       DATA_WIDTH          = 96,
        parameter       WRAP_SIZE           = 24
    )
    (
        input           [ADDR_WIDTH-1:0]    A,
        input                               CEN,
        input                               CLK,
        input           [DATA_WIDTH-1:0]    D,
        input                               GWEN,
        output          [DATA_WIDTH-1:0]    Q,
        input           [DATA_WIDTH-1:0]    WEN
    );

    // &Regs; @5
    reg                 [ADDR_WIDTH-1:0]    addr_holding;

    // &Wires; @6
    wire                [ADDR_WIDTH-1:0]    addr;
    wire                [WRAP_SIZE-1:0]     ram0_din;
    wire                [WRAP_SIZE-1:0]     ram0_dout;
    wire                                    ram0_wen;
    wire                [WRAP_SIZE-1:0]     ram1_din;
    wire                [WRAP_SIZE-1:0]     ram1_dout;
    wire                                    ram1_wen;
    wire                [WRAP_SIZE-1:0]     ram2_din;
    wire                [WRAP_SIZE-1:0]     ram2_dout;
    wire                                    ram2_wen;
    wire                [WRAP_SIZE-1:0]     ram3_din;
    wire                [WRAP_SIZE-1:0]     ram3_dout;
    wire                                    ram3_wen;

    // &Force("bus","Q",DATA_WIDTH-1,0); @7

    //write enable
    // &Force("nonport","ram0_wen"); @13
    // &Force("nonport","ram1_wen"); @14
    // &Force("nonport","ram2_wen"); @15
    // &Force("nonport","ram3_wen"); @16

    // &Force("bus","WEN",DATA_WIDTH-1,0); @18
    assign ram0_wen = !CEN && !WEN[23] && !GWEN;
    assign ram1_wen = !CEN && !WEN[47] && !GWEN;
    assign ram2_wen = !CEN && !WEN[71] && !GWEN;
    assign ram3_wen = !CEN && !WEN[DATA_WIDTH-1] && !GWEN;

    //din
    // &Force("nonport","ram0_din"); @25
    // &Force("nonport","ram1_din"); @26
    // &Force("nonport","ram2_din"); @27
    // &Force("nonport","ram3_din"); @28
    // &Force("bus","D",4*WRAP_SIZE-1,0); @29
    assign ram0_din[WRAP_SIZE-1:0] = D[WRAP_SIZE-1:0];
    assign ram1_din[WRAP_SIZE-1:0] = D[2*WRAP_SIZE-1:WRAP_SIZE];
    assign ram2_din[WRAP_SIZE-1:0] = D[3*WRAP_SIZE-1:2*WRAP_SIZE];
    assign ram3_din[WRAP_SIZE-1:0] = D[4*WRAP_SIZE-1:3*WRAP_SIZE];
    //address
    // &Force("nonport","addr"); @35
    always @ (posedge CLK) begin
        if (!CEN) begin
            addr_holding[ADDR_WIDTH-1:0] <= A[ADDR_WIDTH-1:0];
        end
    end

    assign addr[ADDR_WIDTH-1:0] = CEN ? addr_holding[ADDR_WIDTH-1:0] : A[ADDR_WIDTH-1:0];

    //dout
    // &Force("nonport","ram0_dout"); @47
    // &Force("nonport","ram1_dout"); @48
    // &Force("nonport","ram2_dout"); @49
    // &Force("nonport","ram3_dout"); @50
    assign Q[WRAP_SIZE-1:0]                = ram0_dout[WRAP_SIZE-1:0];
    assign Q[2*WRAP_SIZE-1:WRAP_SIZE]      = ram1_dout[WRAP_SIZE-1:0];
    assign Q[3*WRAP_SIZE-1:2*WRAP_SIZE]    = ram2_dout[WRAP_SIZE-1:0];
    assign Q[4*WRAP_SIZE-1:3*WRAP_SIZE]    = ram3_dout[WRAP_SIZE-1:0];

    fpga_ram    #(
                    .DATAWIDTH          (WRAP_SIZE),
                    .ADDRWIDTH          (ADDR_WIDTH)
                )
                ram0 (
                    .PortAClk           (CLK),
                    .PortAAddr          (addr),
                    .PortADataIn        (ram0_din),
                    .PortAWriteEnable   (ram0_wen),
                    .PortADataOut       (ram0_dout)
                );

    fpga_ram    #(
                    .DATAWIDTH          (WRAP_SIZE),
                    .ADDRWIDTH          (ADDR_WIDTH)
                )
                ram1 (
                    .PortAClk           (CLK),
                    .PortAAddr          (addr),
                    .PortADataIn        (ram1_din),
                    .PortAWriteEnable   (ram1_wen),
                    .PortADataOut       (ram1_dout)
                );

    fpga_ram    #(
                    .DATAWIDTH          (WRAP_SIZE),
                    .ADDRWIDTH          (ADDR_WIDTH)
                )
                ram2 (
                    .PortAClk           (CLK),
                    .PortAAddr          (addr),
                    .PortADataIn        (ram2_din),
                    .PortAWriteEnable   (ram2_wen),
                    .PortADataOut       (ram2_dout)
                );

    fpga_ram    #(
                    .DATAWIDTH          (WRAP_SIZE),
                    .ADDRWIDTH          (ADDR_WIDTH)
                )
                ram3 (
                    .PortAClk           (CLK),
                    .PortAAddr          (addr),
                    .PortADataIn        (ram3_din),
                    .PortAWriteEnable   (ram3_wen),
                    .PortADataOut       (ram3_dout)
                );

endmodule
