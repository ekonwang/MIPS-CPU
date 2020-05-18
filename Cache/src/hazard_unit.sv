`timescale 1ns / 1ps

// Hazard handler
module hazard_unit (
  input        [4:0] rs_d_i,
  input        [4:0] rt_d_i,
  input        [1:0] branch_d_i,
  input              pc_src_d_i,
  input        [2:0] jump_d_i,
  input        [4:0] rs_e_i,
  input        [4:0] rt_e_i,
  input        [4:0] write_reg_e_i,
  input              mem_to_reg_e_i,
  input              reg_write_e_i,
  input        [4:0] write_reg_m_i,
  input              mem_to_reg_m_i,
  input              reg_write_m_i,
  input        [4:0] write_reg_w_i,
  input              reg_write_w_i,
  input              stall_cache_i,
  output logic       stall_f_o,
  output logic       stall_d_o,
  output logic       flush_d_o,
  output logic       forward_a_d_o,
  output logic       forward_b_d_o,
  output logic       stall_e_o,
  output logic       flush_e_o,
  output logic [1:0] forward_a_e_o,
  output logic [1:0] forward_b_e_o,
  output logic       stall_m_o,
  output logic       stall_w_o
);

  logic lw_stall, branch_stall;

  // Solves data hazards with forwarding
  always_comb begin
    if (rs_e_i && rs_e_i == write_reg_m_i && reg_write_m_i) begin
      forward_a_e_o <= 2'b10;
    end else if (rs_e_i && rs_e_i == write_reg_w_i && reg_write_w_i) begin
      forward_a_e_o <= 2'b01;
    end else begin
      forward_a_e_o <= 2'b00;
    end
    if (rt_e_i && rt_e_i == write_reg_m_i && reg_write_m_i) begin
      forward_b_e_o <= 2'b10;
    end else if (rt_e_i && rt_e_i == write_reg_w_i && reg_write_w_i) begin
      forward_b_e_o <= 2'b01;
    end else begin
      forward_b_e_o <= 2'b00;
    end
  end

  // Solves control hazards with forwarding
  assign forward_a_d_o = rs_d_i && rs_d_i == write_reg_m_i && reg_write_m_i;
  assign forward_b_d_o = rt_d_i && rt_d_i == write_reg_m_i && reg_write_m_i;

  // Solves data hazards with stalls
  assign lw_stall = (rs_d_i == rt_e_i || rt_d_i == rt_e_i) && mem_to_reg_e_i;

  // Solves control hazards with stalls
  assign branch_stall = (branch_d_i || jump_d_i[1])
      && (reg_write_e_i && (rs_d_i == write_reg_e_i || rt_d_i == write_reg_e_i)
      || mem_to_reg_m_i && (rs_d_i == write_reg_m_i || rt_d_i == write_reg_m_i));

  assign stall_w_o = stall_cache_i;
  assign stall_m_o = stall_w_o;
  assign stall_e_o = stall_m_o;
  assign stall_d_o = lw_stall || branch_stall || stall_e_o;
  assign stall_f_o = stall_d_o;

  assign flush_e_o = stall_d_o;
  assign flush_d_o = pc_src_d_i || jump_d_i;

endmodule : hazard_unit