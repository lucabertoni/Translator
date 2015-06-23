#!/usr/bin/python3

from include.translator import Translator
from include.conf import __EXT__

oTranslator = Translator()
lExt = __ext__

sPath = input("Insert path to scan: ")

bDefaultExt = input("Use default file extension(*.py)? (y/n): ")

if bDefaultExt == 'y':
	oTranslator.translate(sPath,lExt)
else:
	sExt = input("Insert file extensions(separed by comma: txt,py,sql,exe): ")
	lExt = sExt.split(',')
	oTranslator.translate(sPath,lExt)