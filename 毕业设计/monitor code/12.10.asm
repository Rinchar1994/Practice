addi $12, $0, 1 
addi $13, $0, 16
begin:
sw $12, 1024($0)
jal sleep
addi $0, $0, 0
addi $12, $12, 1
bne $12, $13, begin
j end

sleep:
lui $14, 0x0008
addi $15, $0, 0
loop:
addi $15, $15, 1
bne $15, $14, loop
jr $31

end:
addi $12, $0, 0

