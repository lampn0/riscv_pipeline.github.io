//---------------------------------------------------------------
//                        RISC-V Core
//                          Ver 1.0
//                     EDABK  Laboratory
//                      Copyright  2021
//---------------------------------------------------------------
//    Copyright © 2021 by EDABK Laboratory
//    All rights reserved.
//
//    Module  : tb_riscv_pipeline_top
//    Project : RISC-V pipeline
//    Author  : Pham Ngoc Lam, Nguyen Van Chien, Duong Van Bien
//    Company : EDABK Laboratory
//    Date    : July 23rd 2021
//----------------------------------------------------------------
`timescale 1ns/10ps
module tb_riscv_pipeline_top ();
logic clk;
logic reset_n;

riscv_pipeline_top riscv_pipeline_top(
  .clk    (clk    ),
  .reset_n(reset_n)
  );

always #5 clk = ~clk;

initial begin
  clk = 0;
  reset_n = 1;
  repeat(1) @(posedge clk);
  reset_n = 0;
  repeat(1) @(posedge clk);
  reset_n = 1;
  repeat(20) @(posedge clk);
  $finish;
end

endmodule : tb_riscv_pipeline_top