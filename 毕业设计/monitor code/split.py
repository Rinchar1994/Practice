fand = open('testcode.txt')
fw = open('testcode1.txt', 'w')
for line in fand:
	mystr = ''
	if line[0:2]=='08' or line[0:2]=='0c':
		trans = int(line, 16)
		trans = trans + 512
		temp = hex(trans)
		print temp
		mystr = '0'+temp[2:3]+' '+temp[3:5]+' '+temp[5:7]+' '+temp[7:9]+'\n'
	else:
		mystr = line[0:2]+' '+line[2:4]+' '+line[4:6]+' '+line[6:8]+'\n'
	fw.write(mystr)
fw.write('08 00 00 00\n')
fw.write('00 00 00 00\n')
fand.close()
fw.close()
