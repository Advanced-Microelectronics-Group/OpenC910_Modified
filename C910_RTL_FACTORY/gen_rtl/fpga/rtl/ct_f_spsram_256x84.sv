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

module ct_f_spsram_256x84 #(
        parameter       ADDR_WIDTH          = 8,
        parameter       DATA_WIDTH          = 84,
        parameter       WRAP_SIZE           = 42
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

    // &Regs; @26
    reg                 [ADDR_WIDTH-1:0]    addr_holding;

    // &Wires; @27
    wire                [ADDR_WIDTH-1:0]    addr;
    wire                [WRAP_SIZE-1:0]     ram0_din;
    wire                [WRAP_SIZE-1:0]     ram0_dout;
    wire                                    ram0_wen;
    wire                [WRAP_SIZE-1:0]     ram1_din;
    wire                [WRAP_SIZE-1:0]     ram1_dout;
    wire                                    ram1_wen;

    //write enable
    // &Force("nonport","ram0_wen"); @33
    // &Force("nonport","ram1_wen"); @34
    // &Force("bus","WEN",DATA_WIDTH-1,0); @35
    assign ram0_wen = !CEN && !WEN[41] && !GWEN;
    assign ram1_wen = !CEN && !WEN[DATA_WIDTH-1] && !GWEN;

    //din
    // &Force("nonport","ram0_din"); @40
    // &Force("nonport","ram1_din"); @41
    // &Force("bus","D",2*WRAP_SIZE-1,0); @42
    assign ram0_din[WRAP_SIZE-1:0] = D[WRAP_SIZE-1:0];
    assign ram1_din[WRAP_SIZE-1:0] = D[2*WRAP_SIZE-1:WRAP_SIZE];
    //address
    // &Force("nonport","addr"); @46
    always @ (posedge CLK) begin
        if (!CEN) begin
            addr_holding[ADDR_WIDTH-1:0] <= A[ADDR_WIDTH-1:0];
        end
    end

    assign addr[ADDR_WIDTH-1:0] = CEN ? addr_holding[ADDR_WIDTH-1:0] : A[ADDR_WIDTH-1:0];
    //dout
    // &Force("nonport","ram0_dout"); @57
    // &Force("nonport","ram1_dout"); @58

    assign Q[WRAP_SIZE-1:0]             = ram0_dout[WRAP_SIZE-1:0];
    assign Q[2*WRAP_SIZE-1:WRAP_SIZE]   = ram1_dout[WRAP_SIZE-1:0];

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

endmodule
