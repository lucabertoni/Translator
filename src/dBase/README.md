# dBase Translator

dBase Translator will help you to translate your dBase software.

This README will describe an overview of Translator for dBase. If you want to read general documentation, see /README.md.

## What dBase Translator get from source code

This script will scan all strings in function-return statement.

Translator for dBase will search this text in each source code line:  
	- "msgbox("  
	- "text="  
	- "speedtip="  
	- "value="  
	- "datasource="  
	- "description="

Translator for dBase will discard lines that observe above criteria but contains:  
	- "if "  
	- "case "  
	- "while "  
	- "for "  
	- ".fields["

If source code line observe above criteria, will be saved in OutputStrings table of the database.
