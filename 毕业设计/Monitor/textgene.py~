fopen = open('textgene.txt', 'w')
num = 32
for item in range(num):
	temp = item + 1
	fopen.write('reg'+str(item)+':\naddi $3, $0, 0x'+str(item)+'\nbne $3, $4, reg'+str(temp)+'\naddi $4, $'+str(item)+', 0\nj regout\n')
fopen.close
