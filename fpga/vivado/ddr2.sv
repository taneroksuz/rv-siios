import configure::*;
import wires::*;

module ddr2_phy (
  input  logic        reset,
  input  logic        clock_ref,
  output logic        clock_mem,
  output logic        reset_mem,
  input  logic        phase_step,
  output logic        phase_done,
  input  logic [12:0] cmd_addr,
  input  logic [ 2:0] cmd_ba,
  input  logic        cmd_cs_n,
  input  logic        cmd_ras_n,
  input  logic        cmd_cas_n,
  input  logic        cmd_we_n,
  input  logic        cmd_cke,
  input  logic [63:0] wr_data,
  input  logic [ 7:0] wr_mask,
  input  logic        wr_start,
  output logic [63:0] rd_data,
  output logic [12:0] ddr2_addr,
  output logic [ 2:0] ddr2_ba,
  output logic        ddr2_ras_n,
  output logic        ddr2_cas_n,
  output logic        ddr2_we_n,
  output logic        ddr2_ck_p,
  output logic        ddr2_ck_n,
  output logic        ddr2_cke,
  output logic        ddr2_cs_n,
  output logic [ 1:0] ddr2_dm,
  output logic        ddr2_odt,
  inout  wire  [15:0] ddr2_dq,
  inout  wire  [ 1:0] ddr2_dqs_p,
  inout  wire  [ 1:0] ddr2_dqs_n
);
  timeunit 1ns; timeprecision 1ps;

  logic clkfb_out;
  logic clkfb_in;
  logic clkout0;
  logic clkout1;
  logic clkout2;
  logic clock_dqs;
  logic clock_cap;
  logic locked;

  MMCME2_ADV #(
    .BANDWIDTH          ("OPTIMIZED"),
    .CLKFBOUT_MULT_F    (DDR2_CLK_MULT),
    .CLKFBOUT_PHASE     (0.000),
    .CLKIN1_PERIOD      (5.000),
    .CLKOUT0_DIVIDE_F   (DDR2_CLK_DIVIDE),
    .CLKOUT0_PHASE      (0.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT1_DIVIDE     (DDR2_CLK_DIVIDE),
    .CLKOUT1_PHASE      (270.000),
    .CLKOUT1_DUTY_CYCLE (0.500),
    .CLKOUT2_DIVIDE     (DDR2_CLK_DIVIDE),
    .CLKOUT2_PHASE      (0.000),
    .CLKOUT2_DUTY_CYCLE (0.500),
    .CLKOUT2_USE_FINE_PS("TRUE"),
    .DIVCLK_DIVIDE      (1),
    .REF_JITTER1        (0.023),
    .STARTUP_WAIT       ("FALSE"),
    .COMPENSATION       ("ZHOLD")
  ) mmcm_comp (
    .CLKIN1      (clock_ref),
    .CLKIN2      (1'b0),
    .CLKINSEL    (1'b1),
    .CLKFBIN     (clkfb_in),
    .CLKFBOUT    (clkfb_out),
    .CLKFBOUTB   (),
    .CLKOUT0     (clkout0),
    .CLKOUT0B    (),
    .CLKOUT1     (clkout1),
    .CLKOUT1B    (),
    .CLKOUT2     (clkout2),
    .CLKOUT2B    (),
    .CLKOUT3     (),
    .CLKOUT3B    (),
    .CLKOUT4     (),
    .CLKOUT5     (),
    .CLKOUT6     (),
    .CLKINSTOPPED(),
    .CLKFBSTOPPED(),
    .DADDR       (7'b0),
    .DCLK        (1'b0),
    .DEN         (1'b0),
    .DI          (16'b0),
    .DWE         (1'b0),
    .DO          (),
    .DRDY        (),
    .PSCLK       (clock_mem),
    .PSEN        (phase_step),
    .PSINCDEC    (1'b1),
    .PSDONE      (phase_done),
    .LOCKED      (locked),
    .PWRDWN      (1'b0),
    .RST         (~reset)
  );

  BUFG bufg_fb_comp (
    .I(clkfb_out),
    .O(clkfb_in)
  );

  BUFG bufg_mem_comp (
    .I(clkout0),
    .O(clock_mem)
  );

  BUFG bufg_dqs_comp (
    .I(clkout1),
    .O(clock_dqs)
  );

  BUFG bufg_cap_comp (
    .I(clkout2),
    .O(clock_cap)
  );

  logic [1:0] reset_sync = 0;

  always_ff @(posedge clock_mem) begin
    if (reset == 0 || locked == 0) begin
      reset_sync <= 2'b00;
    end
    else begin
      reset_sync <= {reset_sync[0], 1'b1};
    end
  end

  assign reset_mem = reset_sync[1];

  (* IOB = "TRUE" *)logic [12:0] addr_q;
  (* IOB = "TRUE" *)logic [ 2:0] ba_q;
  (* IOB = "TRUE" *)logic [ 0:0] cs_n_q;
  (* IOB = "TRUE" *)logic [ 0:0] ras_n_q;
  (* IOB = "TRUE" *)logic [ 0:0] cas_n_q;
  (* IOB = "TRUE" *)logic [ 0:0] we_n_q;
  (* IOB = "TRUE" *)logic [ 0:0] cke_q;
  (* IOB = "TRUE" *)logic [ 0:0] odt_q;

  always_ff @(posedge clock_mem) begin
    if (reset_mem == 0) begin
      addr_q  <= 0;
      ba_q    <= 0;
      cs_n_q  <= 1;
      ras_n_q <= 1;
      cas_n_q <= 1;
      we_n_q  <= 1;
      cke_q   <= 0;
      odt_q   <= 0;
    end
    else begin
      addr_q  <= cmd_addr;
      ba_q    <= cmd_ba;
      cs_n_q  <= cmd_cs_n;
      ras_n_q <= cmd_ras_n;
      cas_n_q <= cmd_cas_n;
      we_n_q  <= cmd_we_n;
      cke_q   <= cmd_cke;
      odt_q   <= 0;
    end
  end

  assign ddr2_addr  = addr_q;
  assign ddr2_ba    = ba_q;
  assign ddr2_cs_n  = cs_n_q;
  assign ddr2_ras_n = ras_n_q;
  assign ddr2_cas_n = cas_n_q;
  assign ddr2_we_n  = we_n_q;
  assign ddr2_cke   = cke_q;
  assign ddr2_odt   = odt_q;

  logic [ 2:0] wr_cnt;
  logic [63:0] wr_data_q;
  logic [ 7:0] wr_mask_q;
  logic [15:0] beat_a;
  logic [15:0] beat_b;
  logic [ 1:0] mask_a;
  logic [ 1:0] mask_b;
  logic        dq_oe;
  logic        dqs_oe;
  logic        dqs_tog;

  always_ff @(posedge clock_mem) begin
    if (reset_mem == 0) begin
      wr_cnt    <= 0;
      wr_data_q <= 0;
      wr_mask_q <= 8'hFF;
      beat_a    <= 0;
      beat_b    <= 0;
      mask_a    <= 2'b11;
      mask_b    <= 2'b11;
    end
    else begin
      if (wr_start == 1) begin
        wr_cnt    <= 3'd1;
        wr_data_q <= wr_data;
        wr_mask_q <= wr_mask;
      end
      else if (wr_cnt == 3'd5) begin
        wr_cnt <= 3'd0;
      end
      else if (wr_cnt != 3'd0) begin
        wr_cnt <= wr_cnt + 3'd1;
      end

      if (wr_cnt == 3'd1) begin
        beat_a <= wr_data_q[63:48];
        beat_b <= wr_data_q[47:32];
        mask_a <= wr_mask_q[7:6];
        mask_b <= wr_mask_q[5:4];
      end
      else if (wr_cnt == 3'd2) begin
        beat_a <= wr_data_q[31:16];
        beat_b <= wr_data_q[15:0];
        mask_a <= wr_mask_q[3:2];
        mask_b <= wr_mask_q[1:0];
      end
      else begin
        mask_a <= 2'b11;
        mask_b <= 2'b11;
      end
    end
  end

  assign dqs_tog = (wr_cnt == 3'd2) || (wr_cnt == 3'd3);
  assign dqs_oe  = (wr_cnt >= 3'd1) && (wr_cnt <= 3'd5);
  assign dq_oe   = (wr_cnt >= 3'd2) && (wr_cnt <= 3'd5);

  logic ck_out;

  ODDR #(
    .DDR_CLK_EDGE("SAME_EDGE"),
    .INIT        (1'b0),
    .SRTYPE      ("SYNC")
  ) ck_oddr (
    .Q (ck_out),
    .C (clock_dqs),
    .CE(1'b1),
    .D1(1'b0),
    .D2(1'b1),
    .R (1'b0),
    .S (1'b0)
  );

  OBUFDS ck_obufds (
    .I (ck_out),
    .O (ddr2_ck_p),
    .OB(ddr2_ck_n)
  );

  logic [15:0] dq_q1;
  logic [15:0] dq_q2;

  genvar i;

  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_dq
      logic dq_out;
      logic dq_in;

      ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT        (1'b0),
        .SRTYPE      ("SYNC")
      ) dq_oddr (
        .Q (dq_out),
        .C (clock_mem),
        .CE(1'b1),
        .D1(beat_a[i]),
        .D2(beat_b[i]),
        .R (1'b0),
        .S (1'b0)
      );

      IOBUF dq_iobuf (
        .O (dq_in),
        .IO(ddr2_dq[i]),
        .I (dq_out),
        .T (~dq_oe)
      );

      IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
        .INIT_Q1     (1'b0),
        .INIT_Q2     (1'b0),
        .SRTYPE      ("ASYNC")
      ) dq_iddr (
        .Q1(dq_q1[i]),
        .Q2(dq_q2[i]),
        .C (clock_cap),
        .CE(1'b1),
        .D (dq_in),
        .R (1'b0),
        .S (1'b0)
      );
    end

    for (i = 0; i < 2; i = i + 1) begin : gen_dm
      logic dm_out;

      ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT        (1'b1),
        .SRTYPE      ("SYNC")
      ) dm_oddr (
        .Q (dm_out),
        .C (clock_mem),
        .CE(1'b1),
        .D1(mask_a[i]),
        .D2(mask_b[i]),
        .R (1'b0),
        .S (1'b0)
      );

      OBUF dm_obuf (
        .I(dm_out),
        .O(ddr2_dm[i])
      );
    end

    for (i = 0; i < 2; i = i + 1) begin : gen_dqs
      logic dqs_out;

      ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT        (1'b0),
        .SRTYPE      ("SYNC")
      ) dqs_oddr (
        .Q (dqs_out),
        .C (clock_dqs),
        .CE(1'b1),
        .D1(1'b0),
        .D2(dqs_tog),
        .R (1'b0),
        .S (1'b0)
      );

      IOBUFDS dqs_iobufds (
        .O  (),
        .IO (ddr2_dqs_p[i]),
        .IOB(ddr2_dqs_n[i]),
        .I  (dqs_out),
        .T  (~dqs_oe)
      );
    end
  endgenerate

  logic [63:0] cap = 0;
  logic [63:0] cap_sync1 = 0;
  logic [63:0] cap_sync2 = 0;

  always_ff @(posedge clock_cap) begin
    cap <= {cap[31:0], dq_q1, dq_q2};
  end

  always_ff @(posedge clock_mem) begin
    cap_sync1 <= cap;
    cap_sync2 <= cap_sync1;
  end

  assign rd_data = cap_sync2;

endmodule

import configure::*;
import wires::*;

module ddr2_ctrl (
  input  logic               reset,
  input  logic               clock,
  input  mem_in_type         ddr2_in,
  output mem_out_type        ddr2_out,
  output logic               ddr2_ready,
  output logic        [12:0] cmd_addr,
  output logic        [ 2:0] cmd_ba,
  output logic               cmd_cs_n,
  output logic               cmd_ras_n,
  output logic               cmd_cas_n,
  output logic               cmd_we_n,
  output logic               cmd_cke,
  output logic        [63:0] wr_data,
  output logic        [ 7:0] wr_mask,
  output logic               wr_start,
  input  logic        [63:0] rd_data,
  output logic               phase_step,
  input  logic               phase_done
);
  timeunit 1ns; timeprecision 1ps;

  localparam INIT_PER = 25000;
  localparam INIT_NOP = 50;

  localparam SC_RCD  = 2;
  localparam SC_RP   = 2;
  localparam SC_RFC  = 16;
  localparam SC_MRD  = 2;
  localparam SC_DLLK = 200;

  localparam REF_PER = 900;

  localparam RD_DONE = 16;
  localparam WR_DONE = 16;

  localparam logic [4:0] RD_BASE = 6;

  localparam TAP_CNT  = DDR2_CLK_DIVIDE * DDR2_PHASE_STEP;
  localparam TAP_MAX  = TAP_CNT - 1;
  localparam TAP_BITS = $clog2(TAP_CNT);

  localparam logic [26:0] TRAIN_ADDR = 27'h7FFF800;
  localparam logic [63:0] TRAIN_DATA = 64'hA55A_3CC3_0FF0_5AA5;

  localparam logic [12:0] PRECHARGE_ALL = 13'h0400;

  localparam logic [12:0] MR_RESET  = 13'h0332;
  localparam logic [12:0] MR_NORMAL = 13'h0232;
  localparam logic [12:0] EMR1_OCD  = 13'h0380;
  localparam logic [12:0] EMR1_BASE = 13'h0000;
  localparam logic [12:0] EMR_ZERO  = 13'h0000;

  localparam [3:0] S_INIT = 0;
  localparam [3:0] S_IDLE = 1;
  localparam [3:0] S_ACT  = 2;
  localparam [3:0] S_RW   = 3;
  localparam [3:0] S_WAIT = 4;

  localparam [3:0] T_WRITE = 0;
  localparam [3:0] T_READ  = 1;
  localparam [3:0] T_EVAL  = 2;
  localparam [3:0] T_SHIFT = 3;
  localparam [3:0] T_STEP  = 4;
  localparam [3:0] T_SEEK  = 5;
  localparam [3:0] T_DONE  = 6;

  typedef struct packed {
    logic [3:0]          state;
    logic [3:0]          tstate;
    logic [4:0]          step;
    logic [15:0]         delay;
    logic [15:0]         refresh_timer;
    logic [0:0]          refresh_req;
    logic [0:0]          pending;
    logic [26:0]         addr;
    logic [31:0]         wdata;
    logic [3:0]          wstrb;
    logic [0:0]          write;
    logic [31:0]         rdata;
    logic [0:0]          ready;
    logic [12:0]         cmd_addr;
    logic [2:0]          cmd_ba;
    logic [0:0]          cmd_cs_n;
    logic [0:0]          cmd_ras_n;
    logic [0:0]          cmd_cas_n;
    logic [0:0]          cmd_we_n;
    logic [0:0]          cmd_cke;
    logic [63:0]         wr_data;
    logic [7:0]          wr_mask;
    logic [0:0]          wr_start;
    logic [4:0]          rd_timer;
    logic [4:0]          rd_offset;
    logic [63:0]         rd_data;
    logic [0:0]          reading;
    logic [0:0]          train;
    logic [0:0]          train_done;
    logic [0:0]          train_ok;
    logic [TAP_BITS-1:0] tap;
    logic [2:0]          offset;
    logic [TAP_BITS-1:0] run_len;
    logic [TAP_BITS-1:0] run_start;
    logic [TAP_BITS-1:0] best_len;
    logic [TAP_BITS-1:0] best_tap;
    logic [2:0]          best_offset;
    logic [0:0]          phase_step;
    logic [0:0]          phase_busy;
  } reg_type;

  localparam reg_type init_reg = '{
      state : S_INIT,
      tstate : T_WRITE,
      step : 0,
      delay : INIT_PER,
      refresh_timer : REF_PER,
      refresh_req : 0,
      pending : 0,
      addr : 0,
      wdata : 0,
      wstrb : 0,
      write : 0,
      rdata : 0,
      ready : 0,
      cmd_addr : 0,
      cmd_ba : 0,
      cmd_cs_n : 1,
      cmd_ras_n : 1,
      cmd_cas_n : 1,
      cmd_we_n : 1,
      cmd_cke : 0,
      wr_data : 0,
      wr_mask : '1,
      wr_start : 0,
      rd_timer : 0,
      rd_offset : RD_BASE,
      rd_data : 0,
      reading : 0,
      train : 0,
      train_done : 0,
      train_ok : 0,
      tap : 0,
      offset : 0,
      run_len : 0,
      run_start : 0,
      best_len : 0,
      best_tap : 224,
      best_offset : 3,
      phase_step : 0,
      phase_busy : 0
  };

  reg_type r, rin, v;

  always_comb begin

    v = r;

    v.cmd_cs_n   = 0;
    v.cmd_ras_n  = 1;
    v.cmd_cas_n  = 1;
    v.cmd_we_n   = 1;
    v.cmd_cke    = (r.state == S_INIT && r.step == 0) ? 1'b0 : 1'b1;
    v.wr_start   = 0;
    v.ready      = 0;
    v.phase_step = 0;

    if (phase_done == 1) begin
      v.phase_busy = 0;
    end

    if (r.refresh_timer == 0) begin
      v.refresh_timer = REF_PER;
      v.refresh_req   = 1;
    end
    else begin
      v.refresh_timer = r.refresh_timer - 1'b1;
    end

    if (ddr2_in.mem_valid == 1 && r.pending == 0) begin
      v.addr    = ddr2_in.mem_addr[26:0];
      v.wdata   = ddr2_in.mem_wdata;
      v.wstrb   = ddr2_in.mem_wstrb;
      v.write   = |ddr2_in.mem_wstrb;
      v.pending = 1;
    end

    case (r.state)

      S_INIT: begin
        if (r.delay != 0) begin
          v.delay = r.delay - 1'b1;
        end
        else begin
          case (r.step)
            0: begin
              v.delay = INIT_NOP;
            end
            1: begin
              v.cmd_addr  = PRECHARGE_ALL;
              v.cmd_ba    = 0;
              v.cmd_ras_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_RP;
            end
            2: begin
              v.cmd_addr  = EMR_ZERO;
              v.cmd_ba    = 3'd2;
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_MRD;
            end
            3: begin
              v.cmd_addr  = EMR_ZERO;
              v.cmd_ba    = 3'd3;
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_MRD;
            end
            4: begin
              v.cmd_addr  = EMR1_BASE;
              v.cmd_ba    = 3'd1;
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_MRD;
            end
            5: begin
              v.cmd_addr  = MR_RESET;
              v.cmd_ba    = 3'd0;
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_MRD;
            end
            6: begin
              v.cmd_addr  = PRECHARGE_ALL;
              v.cmd_ba    = 0;
              v.cmd_ras_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_RP;
            end
            7: begin
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.delay     = SC_RFC;
            end
            8: begin
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.delay     = SC_RFC;
            end
            9: begin
              v.cmd_addr  = MR_NORMAL;
              v.cmd_ba    = 3'd0;
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_DLLK;
            end
            10: begin
              v.cmd_addr  = EMR1_OCD;
              v.cmd_ba    = 3'd1;
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_MRD;
            end
            11: begin
              v.cmd_addr  = EMR1_BASE;
              v.cmd_ba    = 3'd1;
              v.cmd_ras_n = 0;
              v.cmd_cas_n = 0;
              v.cmd_we_n  = 0;
              v.delay     = SC_MRD;
            end
            default: begin
              v.state = S_IDLE;
            end
          endcase
          v.step = r.step + 1'b1;
        end
      end

      S_IDLE: begin
        if (v.refresh_req == 1) begin
          v.cmd_ras_n   = 0;
          v.cmd_cas_n   = 0;
          v.refresh_req = 0;
          v.delay       = SC_RFC;
          v.reading     = 0;
          v.train       = 1;
          v.state       = S_WAIT;
        end
        else if (r.train_done == 0) begin
          case (r.tstate)

            T_WRITE: begin
              v.addr    = TRAIN_ADDR;
              v.wr_data = TRAIN_DATA;
              v.wr_mask = 8'h00;
              v.write   = 1;
              v.train   = 1;
              v.delay   = SC_RCD - 1;
              v.state   = S_ACT;
              v.tstate  = T_READ;
            end

            T_READ: begin
              v.addr      = TRAIN_ADDR;
              v.write     = 0;
              v.train     = 1;
              v.rd_offset = RD_BASE + {2'b00, r.offset};
              v.delay     = SC_RCD - 1;
              v.state     = S_ACT;
              v.tstate    = T_EVAL;
            end

            T_EVAL: begin
              if (r.rd_data == TRAIN_DATA) begin
                if (r.run_len == 0) begin
                  v.run_start = r.tap;
                end
                v.run_len = r.run_len + 1'b1;
              end
              else begin
                if (r.run_len > r.best_len) begin
                  v.best_len    = r.run_len;
                  v.best_tap    = r.run_start + (r.run_len >> 1);
                  v.best_offset = r.offset;
                end
                v.run_len = 0;
              end
              v.tstate = T_SHIFT;
            end

            T_SHIFT: begin
              v.phase_step = 1;
              v.phase_busy = 1;
              v.tstate     = T_STEP;
            end

            T_STEP: begin
              if (r.phase_busy == 0) begin
                if (r.tap == TAP_MAX) begin
                  v.tap = 0;
                  if (r.run_len > r.best_len) begin
                    v.best_len    = r.run_len;
                    v.best_tap    = r.run_start + (r.run_len >> 1);
                    v.best_offset = r.offset;
                  end
                  v.run_len = 0;
                  if (r.offset == 3'd7) begin
                    v.offset    = 0;
                    v.rd_offset = RD_BASE + {2'b00, v.best_offset};
                    v.tstate    = T_SEEK;
                  end
                  else begin
                    v.offset = r.offset + 1'b1;
                    v.tstate = T_READ;
                  end
                end
                else begin
                  v.tap    = r.tap + 1'b1;
                  v.tstate = T_READ;
                end
              end
            end

            T_SEEK: begin
              if (r.phase_busy == 0) begin
                if (r.tap == r.best_tap) begin
                  v.tstate = T_DONE;
                end
                else begin
                  v.phase_step = 1;
                  v.phase_busy = 1;
                  v.tap        = (r.tap == TAP_MAX) ? '0 : r.tap + 1'b1;
                end
              end
            end

            default: begin
              v.train_done = 1;
              v.train_ok   = (r.best_len != 0);
            end

          endcase
        end
        else if (r.pending == 1) begin
          v.pending = 0;
          v.train   = 0;
          if (r.addr[2] == 0) begin
            v.wr_data = {r.wdata[15:0], r.wdata[31:16], 32'h00000000};
            v.wr_mask = {~r.wstrb[1:0], ~r.wstrb[3:2], 4'b1111};
          end
          else begin
            v.wr_data = {32'h00000000, r.wdata[15:0], r.wdata[31:16]};
            v.wr_mask = {4'b1111, ~r.wstrb[1:0], ~r.wstrb[3:2]};
          end
          v.delay = SC_RCD - 1;
          v.state = S_ACT;
        end
      end

      S_ACT: begin
        v.cmd_addr  = r.addr[26:14];
        v.cmd_ba    = r.addr[13:11];
        v.cmd_ras_n = 0;
        v.state     = S_RW;
      end

      S_RW: begin
        if (r.delay != 0) begin
          v.delay = r.delay - 1'b1;
        end
        else begin
          v.cmd_addr  = {2'b00, 1'b1, r.addr[10:3], 2'b00};
          v.cmd_ba    = r.addr[13:11];
          v.cmd_cas_n = 0;
          v.rd_timer  = 0;
          if (r.write == 1) begin
            v.cmd_we_n = 0;
            v.wr_start = 1;
            v.reading  = 0;
            v.delay    = WR_DONE;
          end
          else begin
            v.reading = 1;
            v.delay   = RD_DONE;
          end
          v.state = S_WAIT;
        end
      end

      default: begin
        v.rd_timer = r.rd_timer + 1'b1;
        if (r.reading == 1 && r.rd_timer == r.rd_offset) begin
          v.rd_data = rd_data;
        end
        if (r.delay != 0) begin
          v.delay = r.delay - 1'b1;
        end
        else begin
          if (r.train == 1) begin
            v.train = 0;
          end
          else begin
            if (r.addr[2] == 0) begin
              v.rdata = {r.rd_data[47:32], r.rd_data[63:48]};
            end
            else begin
              v.rdata = {r.rd_data[15:0], r.rd_data[31:16]};
            end
            v.ready = 1;
          end
          v.state = S_IDLE;
        end
      end

    endcase

    ddr2_out.mem_ready = r.ready;
    ddr2_out.mem_error = 0;
    ddr2_out.mem_rdata = r.rdata;

    ddr2_ready = r.train_ok;

    cmd_addr   = r.cmd_addr;
    cmd_ba     = r.cmd_ba;
    cmd_cs_n   = r.cmd_cs_n;
    cmd_ras_n  = r.cmd_ras_n;
    cmd_cas_n  = r.cmd_cas_n;
    cmd_we_n   = r.cmd_we_n;
    cmd_cke    = r.cmd_cke;
    wr_data    = r.wr_data;
    wr_mask    = r.wr_mask;
    wr_start   = r.wr_start;
    phase_step = r.phase_step;

    rin = v;

  end

  always_ff @(posedge clock) begin
    if (reset == 0) begin
      r <= init_reg;
    end
    else begin
      r <= rin;
    end
  end

endmodule

import configure::*;
import wires::*;

module ddr2 (
  input  logic               reset_cpu,
  input  logic               clock_cpu,
  input  logic               clock_ddr,
  input  mem_in_type         ddr2_in,
  output mem_out_type        ddr2_out,
  output logic        [12:0] ddr2_addr,
  output logic        [ 2:0] ddr2_ba,
  output logic               ddr2_ras_n,
  output logic               ddr2_cas_n,
  output logic               ddr2_we_n,
  output logic               ddr2_ck_p,
  output logic               ddr2_ck_n,
  output logic               ddr2_cke,
  output logic               ddr2_cs_n,
  output logic        [ 1:0] ddr2_dm,
  output logic               ddr2_odt,
  inout  wire         [15:0] ddr2_dq,
  inout  wire         [ 1:0] ddr2_dqs_p,
  inout  wire         [ 1:0] ddr2_dqs_n,
  output logic               ddr2_complete
);
  timeunit 1ns; timeprecision 1ps;

  logic clock_mem;
  logic reset_mem;

  mem_in_type  ddr2_ctrl_in;
  mem_out_type ddr2_ctrl_out;

  logic [12:0] cmd_addr;
  logic [ 2:0] cmd_ba;
  logic        cmd_cs_n;
  logic        cmd_ras_n;
  logic        cmd_cas_n;
  logic        cmd_we_n;
  logic        cmd_cke;
  logic [63:0] wr_data;
  logic [ 7:0] wr_mask;
  logic        wr_start;
  logic [63:0] rd_data;
  logic        phase_step;
  logic        phase_done;

  cdc cdc_comp (
    .src_clk    (clock_cpu),
    .src_rstn   (reset_cpu),
    .src_mem_in (ddr2_in),
    .src_mem_out(ddr2_out),
    .dst_clk    (clock_mem),
    .dst_rstn   (reset_mem),
    .dst_mem_in (ddr2_ctrl_in),
    .dst_mem_out(ddr2_ctrl_out)
  );

  ddr2_ctrl ddr2_ctrl_comp (
    .reset     (reset_mem),
    .clock     (clock_mem),
    .ddr2_in   (ddr2_ctrl_in),
    .ddr2_out  (ddr2_ctrl_out),
    .ddr2_ready(ddr2_complete),
    .cmd_addr  (cmd_addr),
    .cmd_ba    (cmd_ba),
    .cmd_cs_n  (cmd_cs_n),
    .cmd_ras_n (cmd_ras_n),
    .cmd_cas_n (cmd_cas_n),
    .cmd_we_n  (cmd_we_n),
    .cmd_cke   (cmd_cke),
    .wr_data   (wr_data),
    .wr_mask   (wr_mask),
    .wr_start  (wr_start),
    .rd_data   (rd_data),
    .phase_step(phase_step),
    .phase_done(phase_done)
  );

  ddr2_phy ddr2_phy_comp (
    .reset     (reset_cpu),
    .clock_ref (clock_ddr),
    .clock_mem (clock_mem),
    .reset_mem (reset_mem),
    .phase_step(phase_step),
    .phase_done(phase_done),
    .cmd_addr  (cmd_addr),
    .cmd_ba    (cmd_ba),
    .cmd_cs_n  (cmd_cs_n),
    .cmd_ras_n (cmd_ras_n),
    .cmd_cas_n (cmd_cas_n),
    .cmd_we_n  (cmd_we_n),
    .cmd_cke   (cmd_cke),
    .wr_data   (wr_data),
    .wr_mask   (wr_mask),
    .wr_start  (wr_start),
    .rd_data   (rd_data),
    .ddr2_addr (ddr2_addr),
    .ddr2_ba   (ddr2_ba),
    .ddr2_ras_n(ddr2_ras_n),
    .ddr2_cas_n(ddr2_cas_n),
    .ddr2_we_n (ddr2_we_n),
    .ddr2_ck_p (ddr2_ck_p),
    .ddr2_ck_n (ddr2_ck_n),
    .ddr2_cke  (ddr2_cke),
    .ddr2_cs_n (ddr2_cs_n),
    .ddr2_dm   (ddr2_dm),
    .ddr2_odt  (ddr2_odt),
    .ddr2_dq   (ddr2_dq),
    .ddr2_dqs_p(ddr2_dqs_p),
    .ddr2_dqs_n(ddr2_dqs_n)
  );

endmodule
