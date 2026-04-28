; 设置程序起始偏移地址为 0x7C00（BIOS 加载 MBR 的地址）
[org 0x7C00]

; 将段地址值 0x0000 装入 ax（配合 org 0x7C00，段地址从 0 开始）
mov ax, 0x0000

; 设置数据段 DS = 0x0000（不能直接写立即数到段寄存器）
mov ds, ax

; 设置附加段 ES = 0x0000（BIOS 中断内部可能用到）
mov es, ax

; 设置栈段 SS = 0x0000
mov ss, ax

; 设置栈指针 SP = 0x7C00（栈向下增长，代码向上增长，互不干扰）
mov sp, 0x7C00

; 将字符串首地址偏移量装入 SI，准备逐字符读取
mov si, msg

.print_loop:
    ; 从 DS:SI 读 1 字节到 AL，SI 自动 +1
    lodsb

    ; 比较 AL 和 0（0 = 字符串结束符）
    cmp al, 0

    ; 如果 AL == 0，跳转到 .done（字符串打印完毕）
    je .done

    ; 设置 BIOS 中断功能号 0x0E（电传打字模式，输出字符并前进光标）
    mov ah, 0x0E

    ; 设置显示页号 = 0（第 0 页）
    mov bh, 0

    ; 设置字符颜色属性（高 4 位 0 = 黑色背景，低 4 位 7 = 白色前景）
    mov bl, 0x07

    ; 调用 BIOS 显示服务中断 0x10，输出 AL 中的字符到屏幕
    int 0x10

    ; 跳回循环开头，继续打印下一个字符
    jmp .print_loop

.done:
    ; 让 CPU 停止执行，进入低功耗状态
    hlt

    ; 如果被意外唤醒，跳回 hlt 继续停止
    jmp .done

; 定义以 0 结尾的字符串数据，标签 msg 指向首地址
msg: db "Hello QEMU", 0

; 用 0 填充到第 510 字节（$ - $$ = 已生成字节数）
times 510 - ($ - $$) db 0

; 写入 MBR 启动标志（小端序存储为 55 AA，BIOS 靠它识别可启动扇区）
dw 0xAA55

; ============================================================
; 用法
; ============================================================
;
; 编译：
;   nasm -f bin boot.asm -o boot.bin
;
; 制作软盘镜像：
;   dd if=/dev/zero of=floppy.img bs=512 count=2880
;   dd if=boot.bin of=floppy.img bs=512 count=1 conv=notrunc
;
; 在 QEMU 中运行：
;   qemu-system-i386 -fda floppy.img
;
; 或使用 Makefile：
;   make        编译并制作镜像
;   make run    编译并在 QEMU 中启动
;   make clean  清理生成文件
