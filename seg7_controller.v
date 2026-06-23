// ============================================================================
// 檔案 6: seg7_controller.v (存入 src 資料夾)
// 功能描述: 4 位數動態掃描七段顯示器控制器 (將 16-bit 數值轉為 4 位數顯示)
// ============================================================================
`timescale 1ns / 1ps

module seg7_controller (
    input wire clk,
    input wire reset,
    input wire [15:0] display_data, // 來源資料 (例如: 16'h1234)
    output reg [6:0] seg,           // 段選輸出 (a-g, 低電位亮)
    output reg [3:0] an             // 位選輸出 (低電位亮)
);

    reg [19:0] refresh_counter; // 掃描頻率除頻器
    wire [1:0] scan_sel;
    reg [3:0] hex_digit;

    always @(posedge clk or posedge reset) begin
        if (reset) refresh_counter <= 0;
        else refresh_counter <= refresh_counter + 1;
    end
    
    assign scan_sel = refresh_counter[19:18];

    always @(*) begin
        case(scan_sel)
            2'b00: begin an = 4'b1110; hex_digit = display_data[3:0];   end // Digit 0
            2'b01: begin an = 4'b1101; hex_digit = display_data[7:4];   end // Digit 1
            2'b10: begin an = 4'b1011; hex_digit = display_data[11:8];  end // Digit 2
            2'b11: begin an = 4'b0111; hex_digit = display_data[15:12]; end // Digit 3
        endcase
    end

    // Hex 轉 7-Segment Decoder (共陽極，低電位亮)
    always @(*) begin
        case(hex_digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
