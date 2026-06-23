// ============================================================================
// 檔案 5: uart_tx.v (存入 src 資料夾)
// 功能描述: UART 發送器，Baud Rate = 115200 (於 100MHz 系統時脈下)
// ============================================================================
`timescale 1ns / 1ps

module uart_tx (
    input wire clk,
    input wire reset,
    input wire tx_start,      // 開始傳送觸發訊號
    input wire [7:0] tx_data, // 準備傳送的 8-bit ASCII 資料
    output reg tx,            // TX 實體腳位 (接回電腦)
    output reg tx_busy        // 忙碌狀態標示
);

    // 100MHz / 115200 baud = 868 ticks per bit
    parameter BIT_TMR_MAX = 16'd868; 
    
    reg [15:0] bit_timer;
    reg [3:0] bit_idx;
    reg [9:0] tx_shift_reg; 
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx <= 1'b1; // Idle state 必須是 High
            tx_busy <= 1'b0;
            bit_timer <= 0;
            bit_idx <= 0;
        end else begin
            if (tx_start && !tx_busy) begin
                tx_shift_reg <= {1'b1, tx_data, 1'b0}; 
                tx_busy <= 1'b1;
                bit_idx <= 0;
                bit_timer <= 0;
            end else if (tx_busy) begin
                if (bit_timer < BIT_TMR_MAX - 1) begin
                    bit_timer <= bit_timer + 1;
                end else begin
                    bit_timer <= 0;
                    tx <= tx_shift_reg[0]; // 從最低位元開始傳送
                    tx_shift_reg <= {1'b1, tx_shift_reg[9:1]}; // 資料右移
                    
                    if (bit_idx < 9) begin
                        bit_idx <= bit_idx + 1;
                    end else begin
                        tx_busy <= 1'b0; // 傳送完成，解除忙碌狀態
                    end
                end
            end
        end
    end
endmodule
