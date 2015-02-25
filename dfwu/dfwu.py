#!/usr/bin/env python
'''

DFWU (DDNS Firewall Update) v201502250237
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/dfwu

Example usage with CSF (ConfigServer Security & Firewall):
/usr/bin/dfwu.py /etc/dfwu.ini

'''

# Prerequisite modules
try:
	from distutils.spawn import find_executable as which
	from configobj import ConfigObj
	import inspect, os, sys, socket, hashlib
except Exception, e:
	print 'DFWU: failed to import prerequisite modules (%s)' % e
	sys.exit()

# Main method
def main():

	# Program Variables
	prog			=	{ 'stack' : inspect.stack()[-1][1] }
	prog['path']	=	os.path.dirname( os.path.abspath( prog[ 'stack' ] ) )
	prog['name']	=	os.path.basename( prog[ 'stack' ] )

	# Configuration
	try:
		fileIni			=	sys.argv[1]
		config			=	ConfigObj( fileIni )
		if ( os.path.isfile( fileIni ) == False ):
			raise Exception( "'%s' does not exist!" % ( fileIni ) )
	except Exception, e:
		print 'DFWU: failed with configuration file (%s)' % e
		sys.exit()

	# Configuration - Core
	core			=	config.pop( 'core', {} )
	fwFile			=	core.get( 'fwFile',			'/etc/csf/csf-ddns.allow' )
	fwFileBytes		=	core.get( 'fwFileBytes',	1000 ) # default is 1 kilobyte
	fwName			=	core.get( 'fwName',			which( 'csf' ) )
	fwArgs			=	core.get( 'fwArgs',			'--restart' )
	del core

	# Hash of DDNS file
	try:
		if ( os.path.isfile( fwFile ) == False ):
			raise Exception( "'%s' does not exist!" % ( fwFile ) )
		fwFileHash		=	hashlib.sha1( open( fwFile ).read( int(fwFileBytes) ) ).hexdigest()
	except Exception, e:
		print 'DFWU: failed with DDNS file (%s)' % e
		sys.exit()
	
	# Firewall file: static content
	output	=	'#\n'
	output	+=	'# DO NOT MODIFY, CHANGES WILL BE OVERWRITTEN!\n'
	output	+=	'# AUTO-GENERATED BY DFWU (DDNS Firewall Update)\n'
	output	+=	'# %s/%s %s\n' % ( prog[ 'path' ], prog[ 'name' ], fileIni )
	output	+=	'# \n'
	output	+=	'# Louis T. Getterman IV (@LTGIV)\n'
	output	+=	'# www.GotGetLLC.com / www.opensour.cc/dfwu\n'
	output	+=	'#\n'

	# Firewall file: dynamic content
	for rulename, values in config.iteritems():

		# Hosts or empty list if doesn't exist
		hosts	=	values.get( 'hosts', [ ] )

		# Rule or empty string if doesn't exist
		rule	=	values.get( 'rule', '' )

		# Human-readability for differentiating firewall rules
		output	+=	'# %s\n' % ( rulename )

		# If host is a string (single host), convert it to list format
		if isinstance( hosts, str ):
			hosts	=	[ hosts ]
			pass # END : isinstance

		# Try/except hosts
		try:
			# Firewall file: dynamic content - iterate each host, adding current host with current rule
			for host in hosts:
				output	+=	'%s\n' % ( rule.replace( '%host%', socket.gethostbyname( host ) ) )
				pass # END : for host
			pass # END : for rulename, values
		except Exception, e:
			output	+=	'# Failure for "%s": %s\n' % ( host, str( e ) )
	
	# Hashes match? If not, overwrite firewall file, and apply changes.
	if hashlib.sha1( output ).hexdigest() == fwFileHash:
		print 'DFWU: No update needed.'
	else:
		print 'DFWU: Updating and restarting firewall.'
		f	=	open( fwFile, 'w' )
		f.write( output )
		f.close()
		print os.popen( fwName+' '+fwArgs ).read()

# Program called directly
if __name__ == "__main__":
	main()
