# Translator

Translator will help you to translate your software.

This README will describe an overview of Translator. If you want to read all documentation specific to your language, see /doc/Your_Language-Translator-doc.txt.

# How to install

Until the setup.exe will not be ready, you have to follow this steps to install Translator.

If you have dBase Plus you can build the project(from /src/Your-Language/Translate.prj) and run directly Translator in it.

### Steps:  
1) Download BDE from http://download.chip.eu/it/Borland-Database-Engine-5.1_1721427.html , install it and configure it:  
  - Open BDE Administrator  
  - Object -> New -> Database Driver Name: INTRBASE  
  - Name it: TranslateDB  
  - Set Server Name: C:\absolute_path\translate\OUTPUTSTRINGS.GDB  
  - Set SqlQryMode: LOCAL  
  - User Name: SYSDBA (if you want to access to the database, password is: masterkey)

# How to use Translator  
Run translate.exe  
You will see a window like this:  
  
