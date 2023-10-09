.arch armv7-a

.section .data
a_value: .word 0  @ 定义一个名为a_value的数据变量，用于存储a的值
b_value: .word 0  @ 定义一个名为b_value的数据变量，用于存储b的值

.section .text
.global main       @ 声明main函数为全局可见

ifElseIf:
    push {r4, lr}     @ 保存r4寄存器和返回地址

    bl getint         @ 调用getint函数，返回值存储在r0中
    mov r4, r0        @ 将返回值保存在r4寄存器中

    bl getint         @ 再次调用getint函数，返回值存储在r0中

    cmp r0, #4        @ 比较r0和4
    ble ifElseIf_LessOrEqual  @ 如果r0 <= 4，则跳转到ifElseIf_LessOrEqual标签

    cmp r4, #0xb       @ 比较r4和11（0xb的十进制表示）
    bne ifElseIf_Else  @ 如果r4 != 11，则跳转到ifElseIf_Else标签

ifElseIf_LessOrEqual:
    add r4, r4, #10   @ r4 += 10
    cmp r4, #12       @ 比较r4和12
    bge ifElseIf_If_Return  @ 如果r4 >= 12，则跳转到ifElseIf_If_Return标签
    mov r0, #2        @ 返回2
    b ifElseIf_End    @ 跳转到ifElseIf_End标签

ifElseIf_If_Return:
    mov r0, #1        @ 返回1


ifElseIf_Else:
    cmp r4, #10          @ 比较r4和10
    beq ifElseIf_Elif    @ 如果r4等于10，则跳转到ifElseIf_Elif标签

    cmp r0, #5           @ 比较r0和5
    bne ifElseIf_Else_Return  @ 如果r0不等于5，则跳转到ifElseIf_Else_Return标签
    mov r0, #15          @ 如果r0等于5，则设置r0为15
    b ifElseIf_End       @ 跳转到ifElseIf_End标签

ifElseIf_Else_Return:
    mov r0, #-10         @ 设置r0为-10

ifElseIf_Elif:
    mov r0, #25          @ 设置r0为25


ifElseIf_End:
    pop {r4, pc}      @ 恢复r4并返回

    .size ifElseIf, .-ifElseIf

main:
    push {r4, lr}     @ 保存r4寄存器和返回地址
    bl ifElseIf       @ 调用ifElseIf函数，返回值存储在r0中
    mov r1, r0        @ 将返回值复制到r1寄存器中
    bl putint         @ 调用putint函数打印r1中的值
    pop {r4, pc}      @ 恢复r4并返回
