// Code your design here

module scan_driver(
  rst,
  clk,
  serial_i,
  row_o,
  row_ready_o
);
  
  // Parameters
  parameter row_w = 32;
  parameter cnt_w = 6;
  
  // Inputs/Outputs
  input rst;
  input clk;
  input serial_i;
  
  output reg row_ready_o;
  output reg [row_w-1:0] row_o;
  
  // Regs/Wires
  reg [cnt_w-1:0] bit_cnt;
  reg [row_w-1:0] pixel_data;
  
  // Reset Logic
  always @(posedge rst) begin
    bit_cnt <= 0;
    pixel_data <= 0;
    row_ready_o <= 0;
  end
  
  // Logic
  always @(posedge clk) begin
    // Sets row_ready_o to be 0
    row_ready_o <= 0;
    
    // Stores serial bit
    pixel_data[row_w-1] = serial_i;
    
    // Shifts the data to the right
    // pixel_data = pixel_data >> 1;
    
    // Checks to see if the row is loaded with data
    if(bit_cnt == row_w-1) begin
      $display("Rendering Row: %0b", pixel_data);
      row_ready_o <= 1;
      row_o <= pixel_data;
      bit_cnt <= 0;
    end else begin
    
    // Counts up after the counter is checked
      bit_cnt = bit_cnt + 1;
      pixel_data = pixel_data >> 1;
    end
  end
  
endmodule

module row_select(
  rst,
  clk,
  row_ready_i,
  col_select
);
  
  // Parameters
  parameter col_w = 16;
  parameter cnt_w = 5;
  
  // Inputs/Outputs
  input rst;
  input clk;
  input row_ready_i;
  
  output reg [col_w:0] col_select;
  
  // Regs/Wires
  reg [cnt_w:0] col_cnt;
  
  // Reset Logic
  always @(posedge rst) begin
    col_cnt <= 0;
    col_select <= 0;
  end
  
  // Logic
  always @(posedge clk) begin
    // Changes select line when a row is ready to be rendered
    if(row_ready_i) begin
      col_select[col_cnt-1] <= 0;
      col_select[col_cnt] <= 1;
      //$display(col_cnt);
      //$display(col_select);
      col_cnt <= col_cnt + 1;
    end
    
    if(col_cnt == col_w+2) begin
        col_cnt <= 0;
        col_select <= 0;
    end
  end
endmodule

// 2D ram array that holdes a full 32x16 frame (512 bits) in a single address
module ram(
  rst,
  clk,
  // Enable ports
  write_enable,
  // Data ports
  write_addr_i,
  read_addr_i,
  write_data_i,
  read_data_o
  );
  
  // Parameters
  // Frame Information
  parameter row_w = 32;
  parameter col_w = 16;
  parameter number_of_frames = 1;
  // Data Information
  parameter data_w = row_w * col_w;
  
  // Inputs/Outputs
  input rst;
  input clk;
  input write_enable;
  input write_addr_i;
  input read_addr_i;
  input [data_w-1:0] write_data_i;
  
  output reg [data_w-1:0] read_data_o;
  
  // Regs/Wires
  reg [data_w-1:0] memory [number_of_frames:0];
  
  // Logic
  always @(posedge clk) begin
    read_data_o <= memory[read_addr_i];
    
    if(write_enable) begin
      memory[write_addr_i] <= write_data_i;
    end
  end
  
endmodule

// Currently selects one frame to render
module frame_selector(
  rst,
  clk,
  serial_row_o
  );
  
  // Parameters
  parameter row_w = 32;
  parameter col_w = 16;
  parameter data_w = row_w * col_w;
  parameter number_of_frames = 1;
  
  // Inputs/Outputs
  input rst;
  input clk;
  
  output serial_row_o;
  
  // Regs/Wires
    // Data
  	reg [data_w-1:0] current_row;
  	wire [data_w-1:0] rom_read_data_o;
    // Counters
  	reg [10:0] row_cnt;
  
  // Modules
  ram rom(
    .rst(rst),
    .clk(clk),
    // Enable ports
    .write_enable(1'b1),
    // Data ports
    .write_addr_i(1'b0),
    .read_addr_i(1'b0),
// V Image
    .write_data_i(512'b11111111111111111111111111111111100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000111111111111111111111111111111111),
    .read_data_o(rom_read_data_o)
  );
  
  assign serial_row_o = current_row[data_w-1];
  
  // Reset Logic
  always @(posedge rst) begin
    // current_row <= rom_read_data_o;
    current_row <= 512'b11111111111111111111111111111111100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000110000000000000000000000000000001100000000000000000000000000000011000000000000000000000000000000111111111111111111111111111111111;
    row_cnt <= 0;
  end
  
  always @(posedge clk) begin
    row_cnt = row_cnt + 1;
    
    // Shifts data to the right
    if(row_cnt == data_w+1) begin
      $display("row_cnt: ", row_cnt);
      row_cnt <= 0;
      current_row <= rom_read_data_o;
    end
    current_row <= current_row << 1;
  end
  
endmodule

module save_frame(
  rst,
  clk,
  row_i,
  row_ready_i
  );
  
  // Parameters
  parameter row_w = 32;
  integer f;
  
  // Inputs/Outputs
  input rst;
  input clk;
  input [row_w-1:0] row_i;
  input row_ready_i;
  
  // Regs/Wires
  
  initial begin
    f = $fopen("output.txt","w");
  end
  
  //Logic
  always @(posedge clk) begin
    if(row_ready_i) begin
      $fwrite(f,"%b\n",row_i);
    end
  end
  
endmodule
