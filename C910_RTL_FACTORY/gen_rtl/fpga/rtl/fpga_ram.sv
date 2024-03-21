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
module fpga_ram #(
        parameter       DATAWIDTH           = 2,
        parameter       ADDRWIDTH           = 2
    )
    (
        input                               PortAClk,
        input           [(ADDRWIDTH-1):0]   PortAAddr,
        input           [(DATAWIDTH-1):0]   PortADataIn,
        input                               PortAWriteEnable,
        //input                             PortAChipEnable,
        output reg      [(DATAWIDTH-1):0]   PortADataOut
    );

    localparam          MEMDEPTH            = 2**(ADDRWIDTH);

    reg                 [(DATAWIDTH-1):0]   mem [(MEMDEPTH-1):0] /* synthesis syn_ramstyle = "no_rw_check" */;

    always @ (posedge PortAClk) begin
        if (PortAWriteEnable) begin
            mem[PortAAddr]  <= PortADataIn;
            PortADataOut    <= PortADataIn;
        end
        else begin
            PortADataOut    <= mem[PortAAddr];
        end
    end

endmodule
