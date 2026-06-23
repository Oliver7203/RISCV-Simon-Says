# ============================================================================
# 檔案 7: game_logic.s (存入 src 資料夾)
# 功能描述: Simon Says 遊戲的 RISC-V 組合語言主程式邏輯
# ============================================================================

.data
    # 定義 MMIO 記憶體位址
    .equ TIMER_ADDR,  0x40000000
    .equ BUTTON_ADDR, 0x40000010
    .equ LED_ADDR,    0x40000020
    .equ UART_ADDR,   0x40000030
    .equ SEG7_ADDR,   0x40000040

.text
.globl _start

_start:
    # 1. 初始化
    li t0, SEG7_ADDR
    li t1, 0            
    sw t1, 0(t0)        

game_loop:
    # 2. 出題 (閃爍 LED)
    li t0, LED_ADDR
    li t1, 0b0001       # 點亮 LED 0
    sw t1, 0(t0)

    # 3. 啟動 Timer (設定超時中斷)
    li t0, TIMER_ADDR
    li t1, 1            # 寫入 bit 0 = 1 啟動
    sw t1, 0(t0)

wait_input:
    # 4. 輪詢按鍵 (Polling)
    li t0, BUTTON_ADDR
    lw t1, 0(t0)
    beq t1, zero, wait_input 

    # 5. 比對成功，關閉 Timer，計分
    li t0, TIMER_ADDR
    li t1, 2            # 寫入 bit 1 = 1 清除
    sw t1, 0(t0)

    # (此處可執行自訂乘法分數運算)
    
    # UART 傳送成功字元 'W'
    li t0, UART_ADDR
    li t1, 87           
    sw t1, 0(t0)

    j game_loop         

# 中斷服務常式 (ISR)
.org 0x00F0
isr_game_over:
    # LED 全亮警告
    li t0, LED_ADDR
    li t1, 0b1111       
    sw t1, 0(t0)

    # UART 傳送 'G'
    li t0, UART_ADDR
    li t1, 71           
    sw t1, 0(t0)
    
    # 清除中斷
    li t0, TIMER_ADDR
    li t1, 2            
    sw t1, 0(t0)

end_loop:
    j end_loop
