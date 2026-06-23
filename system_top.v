// ============================================================================
// 檔案 1: system_top.v (存入 src 資料夾)
// 功能描述: 系統頂層模組，包含位址解碼器 (Address Decoder)，負責 CPU 與周邊溝通
// ============================================================================
`timescale 1ns / 1ps

module system_top(
    input wire clk,          // 100MHz 系統時脈 (接 Basys 3 的 W5)
    input wire reset,        // 系統重置 (接 Switch 0: V17)
    input wire [3:0] btn,    // 4 個十字按鈕輸入 (右, 左, 下, 上)
    output reg [3:0] led,    // 4 顆 LED 輸出
    output wire [6:0] seg,   // 七段顯示器 A-G 段選
    output wire [3:0] an,    // 七段顯示器 4 位數選
    output wire tx           // UART TX 傳送腳位
);

    // --- CPU 與 Memory 之間的內部連線 ---
    wire [31:0] cpu_address;
    wire [31:0] cpu_write_data;
    wire cpu_mem_write;
    wire cpu_mem_read;
    reg  [31:0] cpu_read_data;
    
    wire [31:0] data_mem_out;
    wire interrupt_req;

    // --- 例示化 RISC-V CPU 核心 ---
    riscv_core my_cpu (
        .clk(clk),
        .reset(reset),
        .interrupt_req(interrupt_req), 
        .mem_addr(cpu_address),
        .mem_wdata(cpu_write_data),
        .mem_wen(cpu_mem_write),
        .mem_ren(cpu_mem_read),
        .mem_rdata(cpu_read_data)
    );

    // --- 例示化 Data Memory ---
    wire dmem_we = cpu_mem_write & (cpu_address < 32'h4000_0000);
    data_mem my_dmem (
        .clk(clk),
        .we(dmem_we),
        .addr(cpu_address),
        .wdata(cpu_write_data),
        .rdata(data_mem_out)
    );

    // --- MMIO: 周邊硬體暫存器宣告 ---
    reg timer_en;
    reg timer_clear;
    reg uart_start;
    reg [7:0] uart_tx_data;
    reg [15:0] display_data;

    // --- 例示化周邊硬體 ---
    timer my_timer (
        .clk(clk),
        .reset(reset),
        .timer_en(timer_en),
        .timer_clear(timer_clear),
        .timer_load(32'd500_000_000), // 預設 5 秒超時 
        .interrupt_req(interrupt_req)
    );

    uart_tx my_uart (
        .clk(clk),
        .reset(reset),
        .tx_start(uart_start),
        .tx_data(uart_tx_data),
        .tx(tx),
        .tx_busy() 
    );

    seg7_controller my_seg7 (
        .clk(clk),
        .reset(reset),
        .display_data(display_data),
        .seg(seg),
        .an(an)
    );

    // =========================================================
    // Address Decoder - Read Path (CPU 讀取路徑)
    // =========================================================
    always @(*) begin
        cpu_read_data = 32'b0; 
        
        if (cpu_address < 32'h4000_0000) begin
            cpu_read_data = data_mem_out; 
        end 
        else if (cpu_address == 32'h4000_0010) begin
            cpu_read_data = {28'b0, btn}; 
        end
    end

    // =========================================================
    // Address Decoder - Write Path (CPU 寫入路徑)
    // =========================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            led <= 4'b0;
            timer_en <= 0;
            timer_clear <= 0;
            uart_start <= 0;
            display_data <= 16'b0;
        end else begin
            uart_start <= 0;
            timer_clear <= 0;
            
            if (cpu_mem_write) begin
                case (cpu_address)
                    32'h4000_0000: begin 
                        timer_en <= cpu_write_data[0];
                        timer_clear <= cpu_write_data[1]; 
                    end
                    32'h4000_0020: begin 
                        led <= cpu_write_data[3:0];
                    end
                    32'h4000_0030: begin 
                        uart_tx_data <= cpu_write_data[7:0];
                        uart_start <= 1;
                    end
                    32'h4000_0040: begin 
                        display_data <= cpu_write_data[15:0];
                    end
                endcase
            end
        end
    end
endmodule
