// ============================================================================
// 檔案 2: riscv_core.v (存入 src 資料夾)
// 功能描述: RISC-V 核心骨架，包含硬體中斷跳轉 (ISR) 與 EPC 暫存器
// ============================================================================
`timescale 1ns / 1ps

module riscv_core(
    input wire clk,
    input wire reset,
    input wire interrupt_req,     // 硬體中斷請求訊號 (來自 Timer)
    output wire [31:0] mem_addr,  // 輸出給 System Bus 的位址
    output wire [31:0] mem_wdata, // 輸出給 System Bus 的資料
    output wire mem_wen,          // 記憶體/MMIO 寫入致能
    output wire mem_ren,          // 記憶體/MMIO 讀取致能
    input wire [31:0] mem_rdata   // 從 System Bus 讀回的資料
);

    reg [31:0] PC;
    reg [31:0] EPC; // Exception PC 
    
    wire [31:0] next_PC;
    wire [31:0] instruction;
    
    // 中斷服務常式 (ISR) 的固定入口位址
    parameter ISR_ADDRESS = 32'h0000_00F0;

    // --- PC 更新與硬體中斷跳轉邏輯 ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 32'h0000_0000;
        end else if (interrupt_req) begin
            // 發生中斷：保存當前 PC 並強制跳轉
            EPC <= PC;
            PC <= ISR_ADDRESS;
        end else begin
            PC <= next_PC; 
        end
    end

    // --- 例示化指令記憶體 ---
    instruction_mem imem (
        .addr(PC),
        .inst(instruction)
    );

    // ========================================================================
    // (以下區域為 ALU 連線展示，需依你的課程基礎教材連線補齊其他元件)
    // ========================================================================
    
    wire [3:0] alu_ctrl;
    wire [31:0] alu_result;
    wire [31:0] reg_rs1_data, reg_rs2_data;
    
    assign mem_addr = alu_result;
    assign mem_wdata = reg_rs2_data;
    
    // 例示化 ALU (內部包含 8-bit 乘法器)
    alu my_alu (
        .a(reg_rs1_data),
        .b(reg_rs2_data),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero()
    );
    
endmodule
