# 引导扇区二进制输出文件名
BOOT_BIN = boot.bin

# 软盘镜像输出文件名
FLOPPY_IMG = floppy.img

# 汇编源代码文件名
ASM_SRC = boot.asm

# 汇编器可执行文件名
NASM = nasm

# QEMU 模拟器（i386 = 模拟 32 位 x86）
QEMU = qemu-system-i386

# 磁盘操作工具
DD = dd

# 默认目标：编译并制作镜像
all: $(FLOPPY_IMG)

# 汇编 boot.asm -> boot.bin
$(BOOT_BIN): $(ASM_SRC)
	# -f bin = 纯二进制格式，-o = 输出文件名
	$(NASM) -f bin $(ASM_SRC) -o $(BOOT_BIN)

# 制作软盘镜像
$(FLOPPY_IMG): $(BOOT_BIN)
	# 创建 1.44MB 空白软盘镜像（2880 × 512 = 1.44MB）
	$(DD) if=/dev/zero of=$(FLOPPY_IMG) bs=512 count=2880
	# 将引导扇区写入第 0 扇区，notrunc = 不截断目标文件
	$(DD) if=$(BOOT_BIN) of=$(FLOPPY_IMG) bs=512 count=1 conv=notrunc

# 在 QEMU 中启动
run: $(FLOPPY_IMG)
	# -fda = 从软盘镜像启动
	$(QEMU) -fda $(FLOPPY_IMG) -vga std

# 清理生成文件
clean:
	# -f = 强制删除，文件不存在也不报错
	rm -f $(BOOT_BIN) $(FLOPPY_IMG)

# 声明伪目标（不对应实际文件，避免与同名文件冲突）
.PHONY: all run clean

# ============================================================
# 用法
# ============================================================
#
# make        编译生成 boot.bin 和 floppy.img
# make run    编译并在 QEMU 中启动运行
# make clean  清理所有生成文件
