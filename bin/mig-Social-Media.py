#!/usr/bin/python
"""
Script for a migrating SocialText Wiki pages and sites to MediaWiki

https://www.mediawiki.org/wiki/Convert_Socialtextwiki_to_Mediawiki#Copy_the_original_files_to_the_new_host
"""
import argparse, textwrap, errno
import fnmatch, subprocess, re, datetime
import xml.etree.ElementTree as ElementTree

import urlparse
# Import Brandt Common Utilities
import sys, os
sys.path.append( os.path.realpath( os.path.join( os.path.dirname(__file__), "/opt/brandt/common" ) ) )
import brandt
sys.path.pop()

version = 0.3
args = {}

args['socialtext'] = "/var/www/socialtext/"
args['mediawiki']  = "http://wiki/"
args['wikiname']   = ""
args['page']       = ""

class customUsageVersion(argparse.Action):
  def __init__(self, option_strings, dest, **kwargs):
    self.__version = str(kwargs.get('version', ''))
    self.__prog = str(kwargs.get('prog', os.path.basename(__file__)))
    self.__row = min(int(kwargs.get('max', 80)), brandt.getTerminalSize()[0])
    self.__exit = int(kwargs.get('exit', 0))
    super(customUsageVersion, self).__init__(option_strings, dest, nargs=0)
  def __call__(self, parser, namespace, values, option_string=None):
    # print('%r %r %r' % (namespace, values, option_string))
    if self.__version:
      print self.__prog + " " + self.__version
      print "Copyright (C) 2013 Free Software Foundation, Inc."
      print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>."
      version  = "This program is free software: you can redistribute it and/or modify "
      version += "it under the terms of the GNU General Public License as published by "
      version += "the Free Software Foundation, either version 3 of the License, or "
      version += "(at your option) any later version."
      print textwrap.fill(version, self.__row)
      version  = "This program is distributed in the hope that it will be useful, "
      version += "but WITHOUT ANY WARRANTY; without even the implied warranty of "
      version += "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the "
      version += "GNU General Public License for more details."
      print textwrap.fill(version, self.__row)
      print "\nWritten by Bob Brandt <projects@brandt.ie>."
    else:
      print "Usage: " + self.__prog + " [-S PATH] [-M URL] [-p PAGE] -w wiki"
      print "\nScript for a migrating SocialText Wiki pages and sites to MediaWiki\n"
      print "Options:"
      options = []

      options.append(("-S, --socialtext PATH", "SocialText Base File Path (default: %s)" % args['socialtext']))
      options.append(("-M, --mediawiki URL",   "MediaWiki Base URL (default: %s)" % args['mediawiki']))
      options.append(("-w, --wikiname WIKI",   "Name of wiki to migrate"))
      options.append(("-p, --page PAGE",       "Name of page in the wiki to migrate (default is all pages)"))
      options.append(("-h, --help",            "Show this help message and exit"))
      options.append(("-v, --version",         "Show program's version number and exit"))

      length = max( [ len(option[0]) for option in options ] )
      for option in options:
        description =  textwrap.wrap(option[1], (self.__row - length - 5))
        print "  " + option[0].ljust(length) + "   " + description[0]
        for n in range(1,len(description)): print " " * (length + 5) + description[n]
    exit(self.__exit)
def command_line_args():
  global args
  parser = argparse.ArgumentParser(add_help=False)
  parser.add_argument('-v', '--version', action=customUsageVersion, version=version, max=80)
  parser.add_argument('-h', '--help', action=customUsageVersion) 
  parser.add_argument('-S', '--socialtext',
                    required=False,
                    default=args['socialtext'],
                    action='store',
                    type=str)
  parser.add_argument('-M', '--mediawiki',
                    required=False,
                    default=args['mediawiki'],
                    action='store',
                    type=str)
  parser.add_argument('-w', '--wikiname',
                    required=True,
                    default=args['wikiname'],
                    action='store',
                    type=str)
  parser.add_argument('-p', '--page',
                    required=False,
                    default=args['page'],
                    action='store',
                    type=str)
  args.update(vars(parser.parse_args()))

# Start program
if __name__ == "__main__":
  command_line_args()
  # if args['setup']: setup()
  print args
  args['mediawiki'] = urlparse.urljoin( args['mediawiki'], args['wikiname'] )
  print "Verify that the MediaWiki api is present. %s" % args['mediawiki']


  args['socialtext'] = os.path.join( args['socialtext'], "plugin", args['wikiname'] )
  print "Verify that the SocialText wiki is present. %s" % args['socialtext']



