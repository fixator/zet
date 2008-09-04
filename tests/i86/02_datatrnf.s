# Recursive testbench for transfer data instructions, except "mov" 
#  but ("jmp" & "mov" must work!!)
#
# At the end (3591ns in rtl-model, 274380ns in spartan3), %ax=0x8cf1
#
# sahf   1
# lahf   2
# lds    3
# lea    4
# les    5
# pop    6 (reg,non-st), 7 (seg), 8 (mem)
# popf   9
# push  10 (reg), 11 (seg), 12 (mem) 
# pushf 13
# xchg  14 (reg-reg), 15 (reg-mem), 16 (reg-acum), 17 (reg-reg,byte)
# xlat  18
# in    19 (byte,imm) 20 (byte,dx) 21 (word,imm) 22 (word,dx)
# out   23 (byte,imm) 24 (byte,dx) 25 (word,imm) 26 (word,dx)

.code16
start:
movb $0xed, %ah     
sahf                    # (1)
lahf                    # (2) Now %ah must have 0xc7
movb %ah, %al
outb %al, $0xb7         # (19) 
movw $0xb7, %ax
movw %ax, %dx
movb $0xa5, %ah
inb  %dx, %al           # (24)
sahf               
lahf                # Now %ax must have 0x87c7

outw %ax, %dx           # (22)
movw $0xf752, %ax
movw %ax, %bx
inw  %dx, %ax           # (26)
xchg %bx, %ax       # (16)
movw %ax, %ds
lds  781(%bx), %si  # (3)  %ds=0x5678 and %si=0x1234

movw $-1, %bx

movw $0x1000, %ax
outw %ax, $0xb7         # (21)

movw $0x5798, %ax
movw %ax, %ss
movw $9, %sp
movw $0xabcd, %cx
push %cx                # (10)
movw $0x8cf1, %cx
movw %cx, %es
push %es                # (11)       
popf                    # (9)
les  -46(%bx,%si), %di  # (5) %di=0x8cf1, %es=%0xabcd
lea  -452(%bp,%di), %si # (4) %si=0x8b2d
pushf                   # (13)
inw  $0xb7, %ax         # (25)
movw %ax, %ds
pop  1(%si)             # (8)
xchg 2(%bx,%si), %di    # (15) %di=0x0cd3
push 2(%bx,%si)         # (12)
pop  %es                # (7)  %es=0x8cf1
pop  %dx                # (6)
push %dx
.byte 0x8f,0xc1         # (6) pop %cx (non-standard)
xchg %bx, %cx           # (14) %bx=0xabcd, %cx=0xffff
movw %es, (%bx,%di)
movw $0xb800, %bx
movw $0xa0a1, %ax
xlat                    # (18) %al=0x8c
xchg %al, %ah           # (17)
xlat                    # %ax=0x8cf1
movw $0xb7, %dx
outb %al, %dx           # (20)
movb $0xff, %al
inb  $0xb7, %al         # (23) %ax=0x8cf1

.org 65520
jmp start

.org 65524
.word 0x1234
.word 0x5678

.org 65535
.byte 0xff