RISC-V Simon Says 記憶力測試遊戲
基於 RISC-V 核心、Memory-Mapped I/O 與硬體中斷 (Hardware Interrupt) 實作的 FPGA 互動式記憶遊戲。

專題特色與功能:
本系統不只是單純的硬體邏輯電路，而是一個完整的 SoC (System on a Chip) 架構：
軟硬體協同運算： 由 RISC-V CPU 執行 C/Assembly 程式碼處理出題亂數與玩家輸入比對。
硬體 Timer 中斷機制： 獨立計時器，玩家超時未輸入時，直接觸發硬體中斷 (Interrupt) 強制跳轉至 Game Over 狀態。
自訂指令加速 (Custom ISA)： 擴充 CPU Decoder 與 ALU，實作 8-bit 無號整數乘法器指令，由 CPU 呼叫硬體加速計算連擊得分。
Memory-Mapped I/O (MMIO)： 透過位址解碼器，CPU 可直接讀寫實體周邊 (Buttons, LEDs, 7-Segment, UART)。
UART 即時戰況播報： 遊戲過關或結束時，透過 USB 序列埠將戰況字串傳送至電腦終端機。

開發環境與硬體需求
開發軟體： Xilinx Vivado
硬體平台： Digilent Basys 3 FPGA 開發板
其他軟體： Tera Term 或 PuTTY

專案目錄結構
RISCV-Simon-Says/
├── src/                    # Verilog 原始碼資料夾
│   ├── riscv_core.v        # 修改過後的 RISC-V CPU 核心 (含中斷與自訂 ALU)
│   ├── system_top.v        # 系統頂層模組 (包含 Address Decoder)
│   ├── timer.v             # 硬體計時器模組
│   ├── uart_tx.v           # UART 發送模組
│   ├── seg7_controller.v   # 七段顯示器掃描控制模組
│   ├── instruction_mem.v   # 指令記憶體 (預載入遊戲程式碼)
│   └── data_mem.v          # 資料記憶體
├── constrs/                # 腳位約束檔資料夾
│   └── basys3.xdc          # Basys 3 實體腳位設定檔
├── docs/                   # 文件資料夾
│   └── architecture.png    # 系統架構圖
└── README.md               # 本專案說明文件

如何重現專案

請按照以下步驟在您的電腦上重現本專題成果：

步驟 1：建立專案與匯入檔案
開啟 Xilinx Vivado，點選 Create Project。
專案類型選擇 RTL Project。
FPGA 晶片型號請搜尋並選擇 xc7a35tcpg236-1。
將本倉庫 src/ 目錄下的所有 .v 檔案加入 Design Sources。
將本倉庫 constrs/ 目錄下的 basys3.xdc 檔案加入 Constraints。

步驟 2：
點擊 Vivado 左側導覽列的 Generate Bitstream，等待 Synthesis 與 Implementation 跑完。
將 Basys 3 開發板透過 Micro-USB 連接至電腦，並開啟電源。
點選 Open Hardware Manager -> Open Target -> Auto Connect。
點選 Program Device 將產生的 .bit 檔燒錄進 Basys 3。

步驟 3：設定 UART 終端機 (選用)
在電腦端打開「裝置管理員」，確認 Basys 3 所對應的 USB Serial Port (COM Port 號碼)。
開啟 Tera Term 或 PuTTY。
建立 Serial 連線：選擇對應的 COM Port，並將 Baud Rate 設為 115200。

遊戲操作說明
系統重置： 將 Basys 3 最左側的 Switch 0 (V17) 往上撥再往下撥，系統即會初始化並進入遊戲。
記憶出題： 板子最右側的 4 顆 LED 會隨機閃爍出一個序列，請仔細記憶。
玩家輸入： 輪到玩家回合時，請依照剛剛 LED 的位置與順序，按下對應的十字按鍵：
上鍵 (T18)、下鍵 (U17)、左鍵 (W19)、右鍵 (T17)
過關與計分： 全對則進入下一關（節奏變快、序列變長），七段顯示器會即時更新「連擊加成總分」。
Game Over： 如果按錯順序，或者思考太久未按按鍵（觸發 Timer 中斷），LED 會全亮警告，遊戲結束。
