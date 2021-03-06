begin:
addi $10, $31, 0
jal receive
addi $0, $0, 0
addi $31, $10, 0
addi $2, $0, 0
beq $2, $4, uart
addi $2, $0, 1
beq $2, $4, inputcode
addi $2, $0, 2
beq $2, $4, outputcode
addi $2, $0, 3
beq $2, $4, regcontent 
addi $2, $0, 4
beq $2, $4, ramcontent
addi $2, $0, 5
beq $2, $4, imple_all
addi $2, $0, 6
beq $2, $4, breakpoint
addi $2, $0, 7
beq $2, $4, unbreak
addi $2, $0, 8
beq $2, $4, go_on
addi $2, $0, 9
beq $2, $4, single
addi $2, $0, 10
beq $2, $4, single_part
addi $4, $0, 0xff
addi $10, $31, 0
jal send
addi $0, $0, 0
addi $31, $10, 0
j begin

breakpoint:
addi $10, $31, 0
jal receiveword
addi $0, $0, 0
addi $31, $10, 0
sll $4, $4, 2
addi $9, $4, 2048
lw $8, 0($9)
addi $10, $0, 0x08
sll $10, $10, 24
sw $10, 0($9)
j begin

unbreak:
beq $9, $0, begin
sw $8, 0($9)
addi $8, $0, 0
addi $9, $0, 0
j begin

go_on:
sw $8, 0($9)
addi $3, $9, 0
addi $9, $0, 0
addi $8, $0, 0
jr $3

imple_all:
addi $3, $0, 2048
jr $3

single:
bne $8, $0, break 
addi $9, $0, 2048
j init
break:
sw $8, 0($9)
init:
addi $3, $9, 0
srl $4, $8, 26
addi $1, $0, 0x02
bne $4, $1, jal_condition
addi $2, $0, 0x3ff
sll $2, $2, 16
addi $2, $2, 0xffff
and $9, $2, $8
bne $9, $0, testcode_end
addi $9, $0, 0
addi $8, $0, 0
jr $3
testcode_end:
sll $9, $9, 2
j single_end
jal_condition:
addi $1, $0, 0x03
bne $4, $1, jr_condition
addi $2, $0, 0x3ff
sll $2, $2, 16
addi $2, $2, 0xffff
and $9, $2, $8
sll $9, $9, 2
j single_end
jr_condition:
bne $4, $0, bne_condition
addi $2, $0, 0x3f
and $2, $8, $2
addi $1, $0, 0x08
bne $2, $1, bne_condition
addi $10, $31, 0
jal reg_into_ram
addi $0, $0, 0
addi $31, $10, 0
srl $2, $8, 21
sll $2, $2, 2
lw $9, 0($2)
j single_end
bne_condition:
addi $1, $0, 0x05
bne $4, $1, beq_condition
addi $10, $31, 0
jal reg_into_ram
addi $0, $0, 0
addi $31, $10, 0
srl $2, $8, 21
addi $1, $0, 0x1f
and $2, $2, $1
sll $2, $2, 2
lw $2, 0($2)
srl $7, $8, 16
and $7, $7, $1
sll $7, $7, 2
lw $7, 0($7)
bne $2, $7, bne_bne
addi $9, $9, 4
j single_end
bne_bne:
addi $1, $0, 0xffff
and $2, $8, $1
srl $7, $2, 15
bne $7, $0, bne_neg
sll $2, $2, 2
add $9, $2, $9
j single_end
bne_neg:
nor $2, $2, $2
addi $2, $2, 1
and $2, $2, $1
sll $2, $2, 2
sub $9, $9, $2
j single_end
beq_condition:
addi $1, $0, 0x04
bne $4, $1, normal
addi $10, $31, 0
jal reg_into_ram
addi $0, $0, 0
addi $31, $10, 0
srl $2, $8, 21
addi $1, $0, 0x1f
and $2, $2, $1
sll $2, $2, 2
lw $2, 0($2)
srl $7, $8, 16
and $7, $7, $1
sll $7, $7, 2
lw $7, 0($7)
beq $2, $7, beq_beq
addi $9, $9, 4
j single_end
beq_beq:
addi $1, $0, 0xffff
and $2, $8, $1
srl $7, $2, 15
bne $7, $0, beq_neg
sll $2, $2, 2
add $9, $2, $9
j single_end
beq_neg:
nor $2, $2, $2
addi $2, $2, 1
and $2, $2, $1
sll $2, $2, 2
sub $9, $9, $2
j single_end
normal:
addi $9, $9, 4
single_end:
lw $8, 0($9)
addi $10, $0 ,0x08
sll $10, $10, 24
sw $10, 0($9)
jr $3

single_part:
bne $8, $0, break_part
addi $9, $0, 2048
j init_part
break_part:
sw $8, 0($9)
init_part:
addi $3, $9, 0
srl $4, $8, 26
addi $1, $0, 0x02
bne $4, $1, jal_condition_part
addi $2, $0, 0x3ff
sll $2, $2, 16
addi $2, $2, 0xffff
and $9, $2, $8
bne $9, $0, testcode_end_part
addi $9, $0, 0
addi $8, $0, 0
jr $3
testcode_end_part:
sll $9, $9, 2
j single_end_part
jal_condition_part:
addi $1, $0, 0x03
bne $4, $1, jr_condition_part
addi $9, $9, 8
j single_end_part
jr_condition_part:
bne $4, $0, bne_condition_part
addi $2, $0, 0x3f
and $2, $8, $2
addi $1, $0, 0x08
bne $2, $1, bne_condition_part
addi $10, $31, 0
jal reg_into_ram
addi $0, $0, 0
addi $31, $10, 0
srl $2, $8, 21
sll $2, $2, 2
lw $9, 0($2)
j single_end_part
bne_condition_part:
addi $1, $0, 0x05
bne $4, $1, beq_condition_part
addi $10, $31, 0
jal reg_into_ram
addi $0, $0, 0
addi $31, $10, 0
srl $2, $8, 21
addi $1, $0, 0x1f
and $2, $2, $1
sll $2, $2, 2
lw $2, 0($2)
srl $7, $8, 16
and $7, $7, $1
sll $7, $7, 2
lw $7, 0($7)
bne $2, $7, bne_bne_part
addi $9, $9, 4
j single_end_part
bne_bne_part:
addi $1, $0, 0xffff
and $2, $8, $1
srl $7, $2, 15
bne $7, $0, bne_neg_part
sll $2, $2, 2
add $9, $2, $9
j single_end_part
bne_neg_part:
addi $9, $9, 4
j single_end_part
beq_condition_part:
addi $1, $0, 0x04
bne $4, $1, normal_part
addi $10, $31, 0
jal reg_into_ram
addi $0, $0, 0
addi $31, $10, 0
srl $2, $8, 21
addi $1, $0, 0x1f
and $2, $2, $1
sll $2, $2, 2
lw $2, 0($2)
srl $7, $8, 16
and $7, $7, $1
sll $7, $7, 2
lw $7, 0($7)
beq $2, $7, beq_beq_part
addi $9, $9, 4
j single_end_part
beq_beq_part:
addi $1, $0, 0xffff
and $2, $8, $1
srl $7, $2, 15
bne $7, $0, beq_neg_part
sll $2, $2, 2
add $9, $2, $9
j single_end_part
beq_neg_part:
addi $9, $9, 4
j single_end_part
normal_part:
addi $9, $9, 4
single_end_part:
lw $8, 0($9)
addi $10, $0 ,0x08
sll $10, $10, 24
sw $10, 0($9)
jr $3


reg_into_ram:
sw $0, 0($0)
sw $1, 4($0)
sw $2, 8($0)
sw $3, 12($0)
sw $4, 16($0)
sw $5, 20($0)
sw $6, 24($0)
sw $7, 28($0)
sw $8, 32($0)
sw $9, 36($0)
sw $10, 40($0)
sw $11, 44($0)
sw $12, 48($0)
sw $13, 52($0)
sw $14, 56($0)
sw $15, 60($0)
sw $16, 64($0)
sw $17, 68($0)
sw $18, 72($0)
sw $19, 76($0)
sw $20, 80($0)
sw $21, 84($0)
sw $22, 88($0)
sw $23, 92($0)
sw $24, 96($0)
sw $25, 100($0)
sw $26, 104($0)
sw $27, 108($0)
sw $28, 112($0)
sw $29, 116($0)
sw $30, 120($0)
sw $31, 124($0)
jr $31

ramcontent:
addi $10, $31, 0
jal receiveword
addi $0, $0, 0
addi $31, $10, 0
lw $1, 0($4)
addi $4, $1, 0
addi $10, $31, 0
jal sendword
addi $0, $0, 0
addi $31, $10, 0
j begin

regcontent:
addi $10, $31, 0
jal reg_into_ram
addi $0, $0, 0
jal receive
addi $0, $0, 0
sll $1, $4, 2
lw $4, 0($1)
jal sendword
addi $0, $0, 0
addi $31, $10, 0
j begin

outputcode:
addi $6, $0, 2048
out:
beq $5, $6, begin
lw $4, 0($6)
addi $10, $31, 0
jal sendword
addi $0, $0, 0
addi $31, $10, 0
addi $6, $6, 4
j out

inputcode:
addi $5, $0, 2048 
in:
addi $10, $31, 0
jal receiveword
addi $0, $0, 0
addi $31, $10, 0
beq $0, $4, begin
sw $4, 1024($0)
sw $4, 0($5)
addi $5, $5, 4
j in

uart:
addi $10, $31, 0
jal receive
addi $0, $0, 0
jal send
addi $0, $0, 0
addi $31, $10, 0
j begin

receive:
lw $1, 1036($0)
beq $1, $0, receive
lw $4, 1040($0)
rsleep:
addi $3, $0, 100
addi $7, $0, 0
rsleeploop:
addi $7, $7, 1
bne $7, $3, rsleeploop
jr $31

send:
#data to send
sw $4, 1032($0)
#ena
addi $1, $0, 1
sw $1, 1028($0)
senddown:
lw $1, 1044($0)
beq $1, $0, senddown
ssleep:
addi $3, $0, 100
addi $7, $0, 0
ssleeploop:
addi $7, $7, 1
bne $7, $3, ssleeploop
jr $31

receiveword:
addi $4, $0, 0
re1:
lw $1, 1036($0)
beq $1, $0, re1
lw $1, 1040($0)
add $4, $4, $1
sll $4, $4, 8
rsleep1:
addi $3, $0, 100
addi $7, $0, 0
rsleeploop1:
addi $7, $7, 1
bne $7, $3, rsleeploop1
re2:
lw $1, 1036($0)
beq $1, $0, re2
lw $1, 1040($0)
add $4, $4, $1
sll $4, $4, 8
rsleep2:
addi $3, $0, 100
addi $7, $0, 0
rsleeploop2:
addi $7, $7, 1
bne $7, $3, rsleeploop2
re3:
lw $1, 1036($0)
beq $1, $0, re3
lw $1, 1040($0)
add $4, $4, $1
sll $4, $4, 8
rsleep3:
addi $3, $0, 100
addi $7, $0, 0
rsleeploop3:
addi $7, $7, 1
bne $7, $3, rsleeploop3
re4:
lw $1, 1036($0)
beq $1, $0, re4
lw $1, 1040($0)
add $4, $4, $1
rsleep4:
addi $3, $0, 100
addi $7, $0, 0
rsleeploop4:
addi $7, $7, 1
bne $7, $3, rsleeploop4
jr $31

sendword:
#protect $4
sw $4, 16($0)
srl $4, $4, 24
sw $4, 1032($0)
addi $1, $0, 1
sw $1, 1028($0)
sdown1:
lw $1, 1044($0)
beq $1, $0, sdown1
ssleep1:
addi $3, $0, 100
addi $7, $0, 0
ssleeploop1:
addi $7, $7, 1
bne $7, $3, ssleeploop1
lw $4, 16($0)
srl $4, $4, 16
sw $4, 1032($0)
addi $1, $0, 1
sw $1, 1028($0)
sdown2:
lw $1, 1044($0)
beq $1, $0, sdown2
ssleep2:
addi $3, $0, 100
addi $7, $0, 0
ssleeploop2:
addi $7, $7, 1
bne $7, $3, ssleeploop2
lw $4, 16($0)
srl $4, $4, 8
sw $4, 1032($0)
addi $1, $0, 1
sw $1, 1028($0)
sdown3:
lw $1, 1044($0)
beq $1, $0, sdown3
ssleep3:
addi $3, $0, 100
addi $7, $0, 0
ssleeploop3:
addi $7, $7, 1
bne $7, $3, ssleeploop3
lw $4, 16($0)
sw $4, 1032($0)
addi $1, $0, 1
sw $1, 1028($0)
sdown4:
lw $1, 1044($0)
beq $1, $0, sdown4
ssleep4:
addi $3, $0, 100
addi $7, $0, 0
ssleeploop4:
addi $7, $7, 1
bne $7, $3, ssleeploop4
jr $31
