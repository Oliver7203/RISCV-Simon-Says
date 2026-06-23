// ============================================================================
// 檔案 3: alu.v (存入 src 資料夾)
// 功能描述: 算術邏輯單元，整合了專題所需的自訂 8-bit 無號整數乘法器
// ============================================================================
`timescale 1ns / 1ps

module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [3:0] alu_ctrl,
    output reg [31:0] result,
    output wire zero
);

    // --- 自訂硬體加速器：8-bit 無號整數乘法器 ---
    wire [15:0] mul8_result;
    assign mul8_result = a[7:0] * b[7:0];

    // --- ALU 運算邏輯 ---
    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a & b;          // AND
            4'b0001: result = a | b;          // OR
            4'b0010: result = a + b;          // ADD
            4'b0110: result = a - b;          // SUB
            
            // 【專題亮點】自訂指令對應的 ALU 操作碼 (假設 Decoder 分配為 1000)
            4'b1000: result = {16'b0, mul8_result}; // Custom Instruction: MUL8 
            
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
