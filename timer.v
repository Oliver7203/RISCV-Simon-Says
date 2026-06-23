// ============================================================================
// 檔案 4: timer.v (存入 src 資料夾)
// 功能描述: 硬體倒數計時器。倒數歸零時持續拉高 interrupt_req 以觸發 CPU 中斷。
// ============================================================================
`timescale 1ns / 1ps

module timer (
    input wire clk,
    input wire reset,
    input wire timer_en,          // 啟動計時
    input wire timer_clear,       // 清除中斷請求 (由 CPU 的 ISR 寫入)
    input wire [31:0] timer_load, // 初始倒數設定值
    output reg interrupt_req      // 中斷請求，輸出至 CPU
);

    reg [31:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= timer_load;
            interrupt_req <= 1'b0;
        end else if (timer_clear) begin
            interrupt_req <= 1'b0;       // CPU 確認中斷後清除狀態
            counter <= timer_load;       // 重置計數器
        end else if (timer_en) begin
            if (counter > 0) begin
                counter <= counter - 1;
            end else begin
                interrupt_req <= 1'b1;   // 倒數歸零，發出中斷請求
            end
        end else begin
            counter <= timer_load;       // 未啟動時維持滿水位
        end
    end
endmodule
