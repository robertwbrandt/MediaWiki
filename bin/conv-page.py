#!/usr/bin/python
# https://www.mediawiki.org/wiki/Convert_Socialtextwiki_to_Mediawiki#Copy_the_original_files_to_the_new_host

import re
import sys

filename = sys.argv[1]

f = open(filename, "r")
text = f.read()
(header,content) = text.split('\n\n',1)

# trim content lines
lines = content.split('\n')
lines2 = [line.strip() for line in lines]
content = '\n'.join(lines2)

# headings
p = re.compile('^\^\^\^\^(.*)$', re.M)
content = p.sub('====\\1 ====', content)
p = re.compile('^\^\^\^(.*)$', re.M)
content = p.sub('===\\1 ===', content)
p = re.compile('^\^\^(.*)$', re.M)
content = p.sub('==\\1 ==', content)
p = re.compile('^\^(.*)$', re.M)
content = p.sub('=\\1 =', content)

# bold
p = re.compile('([^\*]+)\*([^\*]+)\*', re.M)
content = p.sub('\\1\'\'\'\\2\'\'\'', content)

# link
p = re.compile('\[([^\]]+)\]', re.M)
content = p.sub('[[\\1]]', content)

# file
p = re.compile('{file: ([^}]+)}', re.M)
content = p.sub('[[Media:\\1]]', content)

# image
p = re.compile('{image: ([^}]+)}', re.M)
content = p.sub('[[Bild:\\1]]', content)

# item level 1
p = re.compile('\342\200\242\011', re.M)
content = p.sub('* ', content)

# table, only partially, do the rest manually!
# you have to add {|... , |} , and check for errors due to empty cells
p = re.compile('[^\n]\|', re.M)
content = p.sub('\n|', content)
p = re.compile('\|\s*\|', re.M)
content = p.sub('|-\n|', content)

# lines with many / * + symbols were used as separator lines...
p = re.compile('[\/]{15,200}', re.M)
content = p.sub('----', content)
p = re.compile('[\*]{15,200}', re.M)
content = p.sub('----', content)
p = re.compile('[\+]{15,200}', re.M)
content = p.sub('----', content)

# external links
p = re.compile('\"([^\"]+)\"<http(.*)>\s*\n', re.M)
content = p.sub('[http\\2 \\1]\n\n', content)
p = re.compile('\"([^\"]+)\"<http(.*)>', re.M)
content = p.sub('[http\\2 \\1]', content)


# add categories
content += '\n'
header_lines = header.split('\n')
for line in header_lines:
    if re.match('^[Cc]ategory: ', line):
        category = re.sub('^[Cc]ategory: (.*)$', '\\1', line)
        content += '[[Category:' + category + ']]\n'

# departments / workspaces
if re.match('data/zsi-fe', filename):
    content += '[[Category:FE]]\n'
if re.match('data/zsi-ac', filename):
    content += '[[Category:AC]]\n'
if re.match('data/zsi-tw', filename):
    content += '[[Category:TW]]\n'

print content

