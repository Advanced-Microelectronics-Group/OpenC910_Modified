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

module ct_spsram_256x59 #(
        parameter       ADDR_WIDTH          = 8,
        parameter       DATA_WIDTH          = 59
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

    // &Force("bus","Q",DATA_WIDTH-1,0); @34
    // &Force("bus","WEN",DATA_WIDTH-1,0); @35
    // &Force("bus","A",ADDR_WIDTH-1,0); @36
    // &Force("bus","D",DATA_WIDTH-1,0); @37

    //********************************************************
    //*                        FPGA memory                   *
    //********************************************************
    //{WEN[58],WEN[57:29],WEN[28:0]}
    ct_f_spsram_256x59  x_ct_f_spsram_256x59 (
                            .A              (A   ),
                            .CEN            (CEN ),
                            .CLK            (CLK ),
                            .D              (D   ),
                            .GWEN           (GWEN),
                            .Q              (Q   ),
                            .WEN            (WEN )
                        );

endmodule
