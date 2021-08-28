//---------------------------------------------------------------
//                        RISC-V Core
//                          Ver 1.0
//                     EDABK  Laboratory
//                      Copyright  2021
//---------------------------------------------------------------
//    Copyright © 2021 by EDABK Laboratory
//    All rights reserved.
//
//    Module  : instruction_fetch
//    Project : riscv_pipeline
//    Author  : Pham Ngoc Lam, Nguyen Van Chien, Duong Van Bien
//    Company : EDABK Laboratory
//    Date    : July 23rd 2021
//----------------------------------------------------------------
module instruction_fetch (
  input                 clk         , // Clock Signal
  input                 reset_n     , // Asynchronous Reset, Active LOW
  input         [31:0]  pc_branch   , // PC branch
  input                 pc_write    ,
  input                 pc_src      ,
  input                 IF_flush    ,
  input                 IF_ID_write ,
  output logic  [31:0]  IF_ID_pc    ,
  output logic  [31:0]  IF_ID_inst  
);

//----------------------------------------------------------------
//         Signal Declaration
//----------------------------------------------------------------
logic [31:0] pc_next;
logic [31:0] pre_pc;
logic [31:0] pc_ff;
logic [31:0] pc;
logic [31:0] inst;

//----------------------------------------------------------------
//         PC selection
//----------------------------------------------------------------
always_comb begin : proc_pc_selection
  pc_next  = pc_ff + 32'h0004;
  pre_pc   = pc_src ? pc_branch : pc_next;
  pc       = pc_write ? pre_pc : pc_ff;
end

//----------------------------------------------------------------
//         PC Flip-Flop
//----------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_pc_ff
  if(~reset_n) begin
    pc_ff <= 0;
  end 
  else if(pc_write) begin
    pc_ff <= pc_next;
  end
  else begin
    pc_ff <= pc_ff;
  end
end

//----------------------------------------------------------------
//         Intruction Memory
//----------------------------------------------------------------
localparam [31:0] NONE    = 32'h0000, // Nothing
                  INST1   = 32'h0004, // add  x8 ,x12   ,x14        --> 0000000_01110_01100_000_01000_0110011
                  INST2   = 32'h0008, // sub  x10,x12   ,x8         --> 0100000_01000_01100_000_01010_0110011
                  INST3   = 32'h000C, // addi x15,x10    ,-50       --> 111111001110_01010_000_01111_0010011
                  INST4   = 32'h0010, // lw   x14, 8(x2)            --> 000000001000_00010_010_01110_0000011
                  INST5   = 32'h0014, // add  x5 ,x19   , x14       --> 0000000_01110_10011_000_00101_0110011
                  INST6   = 32'h0018, // sw   x14, 4(x2)            --> 0000000_01110_00010_010_00100_0100011
                  INST7   = 32'h001C, // beq  x1 , x10 , offset(12) --> 0_000000_01010_00001_000_1100_0_1100011
                  INST8   = 32'h0020, // lw   x7 ,20(x5)            --> 000000010100_00101_010_00111_0000011
                  INST9   = 32'h0024, // addi x7 ,x11   ,2          --> 000000000010_01011_000_00111_0010011
                  INST10  = 32'h0028, // sw   x7 ,12(x5)            --> 000000000111_00101_010_01100_0100011
                  INST11  = 32'h002C, // sub  x2 ,x11   ,x7         --> 0100000_00111_01011_000_00010_0110011
                  INST12  = 32'h0030, // and  x14,x5    ,x3         --> 0000000_00011_00101_111_01110_0110011
                  INST13  = 32'h0034, // sw   x14,16(x5)            --> 000000001110_00101_010_10000_0100011
                  INST14  = 32'h0038, // beq  x1, x14 , offset(12)  --> 0_000000_01110_00001_000_1100_0_1100011 ; beq  x7, x13 , offset(12)  --> 0_000000_01101_00111_000_1100_0_1100011
                  INST15  = 32'h003C, // add  x8 ,x12   ,x14        --> 0000000_01110_01100_000_01000_0110011
                  INST16  = 32'h0040, // sub  x10,x12   ,x8         --> 0100000_01000_01100_000_01010_0110011
                  INST17  = 32'h0044, // addi x15,x10    ,-50       --> 111111001110_01010_000_01111_0010011
                  INST18  = 32'h0048, // lw   x14, 8(x2)            --> 000000001000_00010_010_01110_0000011
                  INST19  = 32'h004C; // add  x5 ,x19   , x14       --> 0000000_01110_10011_000_00101_0110011

always_comb begin : proc_instruction_memory
  case (pc)
    NONE    : inst = 32'b00000000000000000000000000000000;
    INST1   : inst = 32'b0000000_01110_01100_000_01000_0110011;
    INST2   : inst = 32'b0100000_01000_01100_000_01010_0110011;
    INST3   : inst = 32'b111111001110_01010_000_01111_0010011;
    INST4   : inst = 32'b000000001000_00010_010_01110_0000011;
    INST5   : inst = 32'b0000000_01110_10011_000_00101_0110011;
    INST6   : inst = 32'b0000000_01110_00010_010_00100_0100011;
    INST7   : inst = 32'b0_000000_01010_00001_000_1100_0_1100011;
    INST8   : inst = 32'b000000010100_00101_010_00111_0000011;
    INST9   : inst = 32'b000000000010_01011_000_00111_0010011;
    INST10  : inst = 32'b000000000111_00101_010_01100_0100011;
    INST11  : inst = 32'b0100000_00111_01011_000_00010_0110011;
    INST12  : inst = 32'b0000000_00011_00101_111_01110_0110011;
    INST13  : inst = 32'b000000001110_00101_010_10000_0100011;
    INST14  : inst = 32'b0_000000_01110_00001_000_1100_0_1100011;
    INST15  : inst = 32'b0000000_01110_01100_000_01000_0110011;
    INST16  : inst = 32'b0100000_01000_01100_000_01010_0110011;
    INST17  : inst = 32'b111111001110_01010_000_01111_0010011;
    INST18  : inst = 32'b000000001000_00010_010_01110_0000011;
    INST19  : inst = 32'b0000000_01110_10011_000_00101_0110011;
    default : inst = 32'b0;
  endcase
end

//----------------------------------------------------------------
//         Register IF/ID
//----------------------------------------------------------------
always_ff @(posedge clk or negedge reset_n) begin : proc_IF_ID_Register
  if(~reset_n) begin
     IF_ID_pc   <= 0;
     IF_ID_inst <= 0;
  end 
  else if(IF_flush) begin
    // Flush Register
    IF_ID_pc   <= 0;
    IF_ID_inst <= 0;
  end
  else if (~IF_ID_write) begin
    IF_ID_pc   <= IF_ID_pc;
    IF_ID_inst <= IF_ID_inst;
  end
  else begin
    IF_ID_pc   <= pc  ;
    IF_ID_inst <= inst;
  end
end

endmodule : instruction_fetch