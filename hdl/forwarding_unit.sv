//---------------------------------------------------------------
//                        RISC-V Core
//                          Ver 1.0
//                     EDABK  Laboratory
//                      Copyright  2021
//---------------------------------------------------------------
//    Copyright © 2021 by EDABK Laboratory
//    All rights reserved.
//
//    Module  : Forwarding_Unit
//    Project : RISC-V pipeline
//    Author  : Pham Ngoc Lam, Nguyen Van Chien, Duong Van Bien
//    Company : EDABK Laboratory
//    Date    : July 23rd 2021
//----------------------------------------------------------------
module forwarding_unit (
  input         [4:0] ID_EX_rs1       ,
  input         [4:0] ID_EX_rs2       ,
  input         [4:0] ID_EX_rd        ,
  input         [4:0] IF_ID_rs1       ,
  input         [4:0] IF_ID_rs2       ,
  input         [4:0] MEM_WB_rd       ,
  input         [4:0] EX_MEM_rd       ,
  input               EX_MEM_reg_write,
  input               MEM_WB_reg_write,
  input               ID_EX_reg_write ,
  input               branch          ,
  output  logic [1:0] forward_a       ,
  output  logic [1:0] forward_b       ,
  output  logic [1:0] forward_comp1   ,
  output  logic [1:0] forward_comp2   
);

//----------------------------------------------------------------
//         Data Memory
//----------------------------------------------------------------
always_comb begin : proc_forward_ex_hazard
  // MUX A
  if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1)) begin
    forward_a = 2'b10;
  end
  else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && ~(EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1)) && (MEM_WB_rd == ID_EX_rs1)) begin
    forward_a = 2'b01;
  end
  else forward_a = 2'b00;
end

//----------------------------------------------------------------
//         Data Memory
//----------------------------------------------------------------
always_comb begin : proc_forward_mem_hazard
  // MUX B
  if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2)) begin
    forward_b = 2'b10;
  end
  else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && ~(EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2)) && (MEM_WB_rd == ID_EX_rs2)) begin
    forward_b = 2'b01;
  end
  else  forward_b = 2'b00;
end

//----------------------------------------------------------------
//         Data Memory
//----------------------------------------------------------------
always_comb begin : proc_forward_alu_result_to_branch_compare
  // forward alu result back to branch compare
  if (branch && (ID_EX_rd != 0) && ID_EX_reg_write && (IF_ID_rs1 == ID_EX_rd)) begin
    forward_comp1 = 2'b01;
  end
  else if (branch && (EX_MEM_rd != 0) && ~(ID_EX_reg_write && (IF_ID_rs1 == ID_EX_rd)) && EX_MEM_reg_write && (EX_MEM_rd == IF_ID_rs1)) begin
    forward_comp1 = 2'b10;
  end
  else forward_comp1 = 2'b00;
  // forward alu result back to branch compare

end

//----------------------------------------------------------------
//         Data Memory
//----------------------------------------------------------------
always_comb begin : proc_forward_mem_to_branch_compare // forward mem result to branch compare
  if (branch && (EX_MEM_rd != 0) && ~(ID_EX_reg_write && (IF_ID_rs1 == ID_EX_rd)) && EX_MEM_reg_write && (EX_MEM_rd == IF_ID_rs2)) begin
    forward_comp2 = 2'b10;
  end 
  else if (branch && (ID_EX_rd != 0) && ID_EX_reg_write && (IF_ID_rs2 == ID_EX_rd)) begin
    forward_comp2 = 2'b01;
  end
  else forward_comp2 = 2'b00;
end

endmodule : forwarding_unit
