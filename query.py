import subprocess
import re

class Package:
	separators = re.compile('[/\s]')
	def __init__(self, header, description):
		data = self.separators.split(header)
		self.source = data[0]
		self.name = data[1]
		self.version = data[2]
		self.description = description

def search_package(term):
	output = subprocess.check_output(['package-query', '-Ss', term])
	output = iter(output.strip().split('\n'))
	results = []
	for header in output:
		description = output.next()
		package = Package(header, description)
		results.append(package)
	return results
