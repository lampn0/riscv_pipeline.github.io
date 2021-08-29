  //---------------------------------------------------------------
//                        RISC-V Core
//                          Ver 1.0
//                     EDABK  Laboratory
//                      Copyright  2021
//---------------------------------------------------------------
//    Copyright © 2021 by EDABK Laboratory
//    All rights reserved.
//
//    Module  : register_write
//    Project : RISC-V pipeline
//    Author  : Pham Ngoc Lam, Nguyen Van Chien, Duong Van Bien
//    Company : EDABK Laboratory
//    Date    : July 23rd 2021
//----------------------------------------------------------------
module register_write (
  input               MEM_WB_mem_to_reg ,
  input        [31:0] MEM_WB_mem_data   ,
  input        [31:0] MEM_WB_alu_out    ,
  output logic [31:0] wb_data           
);

//----------------------------------------------------------------
//         Register MEM/WB
//----------------------------------------------------------------
always_comb begin : proc_mem_wb_register
  wb_data = (MEM_WB_mem_to_reg) ? MEM_WB_mem_data : MEM_WB_alu_out;
end

endmodule : register_write