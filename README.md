# Translator

Translator will help you to translate your software.

What does it do? This software will get from your source code all lines containing particular type of instructions (all line that are displayed on the monitor, like *printf("Hello World!")*). You can also export extracted lines in csv file and translate them and the reimport them and translate your software.

This README will describe an overview of Translator. If you want to read all documentation specific to your language, see /doc/Your_Language-Translator-doc.txt or /src/Your_Language/README.md.

## How to install

Until the setup.exe will not be ready, you have to follow this steps to install Translator.

If you have dBase Plus you can build the project(from /src/Your-Language/Translate.prj) and run directly Translator in it.

### Steps:  
1) Download BDE from http://download.chip.eu/it/Borland-Database-Engine-5.1_1721427.html , install it and configure it:  
  - Open BDE Administrator  
  - Object -> New -> Database Driver Name: INTRBASE  
  - Name it: TranslateDB  
  - Set Server Name: C:\absolute_path\Your_Language\OUTPUTSTRINGS.GDB  
  - Set SqlQryMode: LOCAL  
  - User Name: SYSDBA (if you want to access to the database, password is: masterkey)

## How to use Translator  
Run translate.exe  
You will see a window like this:

  ![Main window](https://github.com/lucabertoni/Translator/blob/master/screenshot/main2.PNG?raw=true)

  - *Esegui scansione*: It will take the path that you want to scan (the path of your source code) from the entryfield below  
  - *Genera file traduzioni*: This button will make a file containing the original line (all the source code line)(IT (italian, but it's non important)), and a copy of original one that will be translated (Ex: ES). You have to export file with column separator: chr(30)(ascii 30)  
    ![Export window](https://github.com/lucabertoni/Translator/blob/master/screenshot/export.PNG?raw=true)  
  - *Importa traduzione*: After you have translated source code lines, you can import translations using this function  
    ![Export window](https://github.com/lucabertoni/Translator/blob/master/screenshot/import.PNG?raw=true)  
  - *Traduci*: Now you are ready to translate your source code!!! Click on this button!!!  
  Be careful: When you translate your software, translation will override original. **Make a copy!**  
  - *Leggi outputstrings*: This button will load in the grid all the rows extracted after scanning.  
  - *Leggi esclusioni*: You can read in the grid all exclusions that you have applied to the scan. You can add an exclusion by left-double-clicking on selected row in the outputstrings-grid.  
  - *Leggi traduzioni*: You can read all data in Traduzioni table using this button.  
  - *Cancella outputstrings/esclusioni/traduzioni*: You can clean Outputstrings/Esclusioni/Traduzioni tables by clicking on this button.


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

## Execution time

Total amount of source code lines: ~350000  
Total amount of extracted lines: 1137  
Computer details: AMD Opteron Processor 6140 2.57Ghz, 3,44GB (4Gb) Ram

Scanning time: 1.22 min  
Export file: 1 sec  
Import file: 1 sec  
Translation: 55 sec

## Info/Contacts:

Last Update: 08/06/2015

Author: Luca Bertoni

Contacts:

	Email: luca.bertoni24@gmail.com

	Facebook: https://www.facebook.com/LucaBertoniLucaBertoni   
