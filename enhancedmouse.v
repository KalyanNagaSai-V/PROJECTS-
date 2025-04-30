module ps2_mouse(
    input wire clk,             // FPGA clock
    input wire reset,
    input wire ps2_clk,         // PS/2 Clock from mouse
    input wire ps2_data,        // PS/2 Data from mouse
    output reg [7:0] x_movement,
    output reg [7:0] y_movement,
    output reg left_click,
    output reg right_click
);

    reg [10:0] shift_reg;       // 11-bit shift register for PS/2 frame
    reg [3:0] bit_count = 0;
    reg [7:0] byte_data;
    reg [2:0] byte_count = 0;

    reg [7:0] packet[2:0];      // 3-byte PS/2 packet

    always @(negedge ps2_clk or posedge reset) begin
        if (reset) begin
            bit_count <= 0;
        end else begin
            shift_reg <= {ps2_data, shift_reg[10:1]};
            bit_count <= bit_count + 1;

            if (bit_count == 10) begin
                byte_data <= shift_reg[8:1];  // Extract data bits (ignore start/stop/parity)
                packet[byte_count] <= shift_reg[8:1];
                byte_count <= byte_count + 1;
                bit_count <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (byte_count == 3) begin
            // Enhanced processing
            x_movement <= packet[1] << 1;       // Example enhancement: scaling X
            y_movement <= packet[2] << 1;       // Example enhancement: scaling Y
            left_click  <= packet[0][0];
            right_click <= packet[0][1];
            byte_count <= 0;
        end
    end
endmodule
