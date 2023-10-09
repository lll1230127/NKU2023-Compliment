.arch armv7-a

.section .data
a_value: .word 0  @ 定义一个名为a_value的数据变量，用于存储a的值
b_value: .word 0  @ 定义一个名为b_value的数据变量，用于存储b的值

.section .text
.global main       @ 声明main函数为全局可见

While:
    @ 函数开始
    push {lr}      @ 保存返回地址
    mov r0, #5     @ 初始化 i = 5
    mov r1, #7     @ 初始化 j = 7

while_loop:
    @ 检查 i < 100
    cmp r0, #100
    bge while_end   @ 如果 i >= 100，则跳出循环

    @ j = j + 1
    add r1, r1, #1

    @ 检查 j < 10 和 j > 7
    cmp r1, #10
    blt continue_check
    cmp r1, #7
    bgt continue_check

    @ 如果 j 在 8 和 9 之间，继续下一次循环
    b while_next

continue_check:
    @ i = i + 3
    add r0, r0, #3

    @ 检查 i > 30 或 j > 20
    cmp r0, #30
    bgt while_end
    cmp r1, #20
    bgt while_end

while_next:
    @ 继续下一次循环
    b while_loop

while_end:
    pop {lr}       @ 恢复返回地址
    bx lr          @ 返回

.section .text
.global main
.type main, %function
main:
    @ 主函数开始
    bl While      @ 调用 While 函数
    mov r0, r0    @ 返回值存储在 r0 寄存器中
    bx lr         @ 返回
