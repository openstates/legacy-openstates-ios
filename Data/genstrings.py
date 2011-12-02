import os

def main():
	allCodeFiles = os.popen("find . -name '*.m'").read().split('\n')
	allLprjFolders = os.popen("find . -name '*.lproj'").read().split('\n')
	
	if allCodeFiles:
		print '\n===============================\ncreate temporary code folder\n===============================\n'
		print os.popen('mkdir -v ./tempcodes_21312312').read()
		
		print '\n===============================\ncopy all code files to temporary folder\n===============================\n'
		for codeFile in allCodeFiles:
			if codeFile and codeFile <> '':
				print os.popen("cp -v '" + codeFile + "' ./tempcodes_21312312/").read()
	
		print '\n===============================\ngenery localizable strings files\n===============================\n'
		generiedCount = 0
		for folder in allLprjFolders:
			if folder and folder <> '' and folder.find('build') == -1:
				print os.popen("genstrings -u -a -o '" + folder + "' ./tempcodes_21312312/*.m").read()
				generiedCount += 1
					
		if generiedCount == 0:
			print os.popen("genstrings -u -a -o . ./tempcodes_21312312/*.m").read()
		
		print '\n===============================\nremove temporary code files\n===============================\n'
		print os.popen('rm -v -r -f ./tempcodes_21312312').read()
		
		print '\n===================== finished ===============================\n'
		
if __name__ == '__main__':
	print '\n\nusage: Copy this python file to your xcode project directory and just execute it.\n\n'
	main()