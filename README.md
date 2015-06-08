# Translator

Translator will help you to translate your software.

This README will describe an overview of Translator. If you want to read all documentation specific to your language, see /doc/Your_Language-Translator-doc.txt or /src/Your_Language/README.md.

## How to install

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

## How to use Translator  
Run translate.exe  
You will see a window like this:

  ![Main window](https://github.com/lucabertoni/Translator/blob/master/screenshot/main.PNG?raw=true)

  - *Esegui scansione*: It will take the path that you want to scan (the path of your source code) from the entryfield below  
  - *Genera file traduzioni*: This button will make a file containing the original line (all the source code line)(IT (italian, but it's non important)), and a copy of original one that will be translated (Ex: ES). You have to export file with column separator: chr(30)(ascii 30)  
    ![Export window](https://github.com/lucabertoni/Translator/blob/master/screenshot/export.PNG?raw=true)  
  - *Importa traduzione*: After you have translated source code lines, you can import translations using this function  
    ![Export window](https://github.com/lucabertoni/Translator/blob/master/screenshot/import.PNG?raw=true)  
  - *Traduci*: Now you are ready to translate your source code!!! Click on this button!!!  
  Be careful: When you translate your software, translation will override original. **Make a copy!**  
  - *Leggi outputstrings*: This button will load in the grid all the rows extracted after scanning.  
  - *Leggi esclusioni*: You can read in the grid all exclusions that you have applied to the scan. You can add an exclusion by left-double-clicking on selected row in the outputstrings-grid.  
  - *Cancella outputstrings*: You have to clean Outputstrings table each scan. You can do it by clicking on *Cancella outputstrings*, writing *Luchino.2015* in the entryfield and pressing *Enter*.

Be careful: don't rename or move source file after scan and before translate. Translation is based on filename and file path.


## Supported Languages  
  - dBase

## Coming soon:  
  - Visual Basic  
  - C  
  - C++  
  - Python  
  - Java  
  - Javascript  
  - Php

## Info/Contacts:

Last Update: 05/06/2015

Author: Luca Bertoni

Version: 1.4

Contacts:

	Email: luca.bertoni24@gmail.com

	Facebook: https://www.facebook.com/LucaBertoniLucaBertoni 
