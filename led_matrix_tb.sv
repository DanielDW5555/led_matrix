// Code your testbench here
// or browse Examples

`timescale 1ns/1ps

module pixel_pannel;
  // Parameters
  parameter row_w = 32;
  parameter col_w = 16;
  parameter cnt_w = 5;

  
  // Regs/Wires
    // test bench
    reg rst;
    reg clk;
  	reg [row_w-1:0] tb_pkt_test_data;
    wire tb_serial_data_i;

    // scan_driver regs/wires
    wire sd_row_ready_o;
  	wire [row_w-1:0] sd_row_o;

    // row_select regs/wires
  	wire [col_w-1:0] rs_col_select;
  
  	// frame_selector
  	wire fs_serial_row_o;
  
  // Modules
  scan_driver #(
    .row_w(row_w)
  ) u_scan_driver(
    .rst(rst),
    .clk(clk),
    .serial_i(fs_serial_row_o),
    .row_ready_o(sd_row_ready_o),
    .row_o(sd_row_o)
  );
  
  row_select #(
    .col_w(col_w)
  ) u_row_select(
    .rst(rst),
    .clk(clk),
    .row_ready_i(sd_row_ready_o),
    .col_select(rs_col_select)
  );
  
  frame_selector #(
    .row_w(row_w),
    .col_w(col_w),
    .number_of_frames(1)
  ) u_frame_selector(
    .rst(rst),
    .clk(clk),
    .serial_row_o(fs_serial_row_o)
  );
  
  save_frame #(
    .row_w(row_w)
  ) u_save_frame(
    .rst(rst),
    .clk(clk),
    .row_ready_i(sd_row_ready_o),
    .row_i(sd_row_o)
  );
  
  assign tb_serial_data_i = tb_pkt_test_data[0];
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, pixel_pannel);
    
    // Inital values
    tb_pkt_test_data = 32'b11110000111100001111000011110000;
    clk = 0;
    
    // Resets module
    rst = 0;
    toggle_clk;
    rst = 1;
    toggle_clk;
    rst = 0;
    
    // Sends one frame
    
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    
    
    // Sends one frame
    /*
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    send_two_rows;
    */
    
    
  end
  
  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
  
  task send_bit;
    begin
      toggle_clk;
      tb_pkt_test_data = tb_pkt_test_data >> 1;
      // $display("[tb] tb_pkt_test_data: %0b", tb_pkt_test_data);
    end
  endtask
  
  task send_two_rows;
    begin
      tb_pkt_test_data = 32'b11110000111100001111000011110000;
    
      // Sends 32 bits of data to the scan_driver
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;

      tb_pkt_test_data = 32'b00001111000011110000111100001111;

      // Sends 32 bits of data to the scan_driver
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      send_bit;
      end
    endtask
  
endmodule
