// Funzione main: getAllOutputStrings(), inizia tutto da qui
clear

local lc_oSearchOutputStrings,lc_aOutputStrings,lc_sPath,i,lc_fine,lc_sPathLogFile,lc_buffer

lc_oSearchOutputStrings = new SearchOutputStrings()

lc_sPath = 'C:\Documents and Settings\luca\Desktop\api1.prg'
lc_sPathLogFile = 'C:\Documents and Settings\luca\Desktop\OutputStringsLog.txt'
 
lc_aOutputStrings = lc_oSearchOutputStrings.getAllOutputStrings(lc_sPath)

lc_fine = lc_aOutputStrings.size

for i = 1 to lc_fine
	lc_buffer = lc_aOutputStrings[i]
	lc_oSearchOutputStrings.writeLog(lc_buffer,lc_sPathLogFile)
next

class SearchOutputStrings

	// Cosa fa			:			Scrive il buffer nel file aperto in modalità append
   // pr_buffer		:			stringa, testo da scrivere nel file
   // pr_sPath			:			stringa, percorso del file nel quale scrivere
	function writeLog(pr_buffer,pr_sPath)
   	local lc_buffer,lc_sPath

      lc_oFile = new file()
      lc_sPath = pr_sPath
      lc_buffer = pr_buffer

      if FILE(lc_sPath)
      	try
            lc_oFile.open(lc_sPath,'A')
         catch (Exception e)
         	? 'Impossibile aprire (in append) il file di log: '+e
         endtry
      else
      	try
            lc_oFile.create(lc_sPath,'A')
         catch (Exception e)
				? 'Impossibile creare il file di log: '+e
         endtry
      endif

      lc_oFile.puts(lc_buffer)

      release object lc_oFile
      lc_oFile = NULL

   	return

	// Cosa fa			:			Apre un file in lettura
   //	pr_filePath		:			stringa -> percorso del file da aprire
   // Ritorna			:			lc_oFile -> oggetto file (aperto in lettura)
   //									Se c'è un errore, oppure il file non esiste, ritorna
   //									un oggetto file vuoto
	function ReadFile(pr_filePath)
   	local lc_oFile,lc_filePath

      lc_filePath = pr_filePath
      lc_oFile = new File()

     	try
	      lc_oFile.open(lc_filePath,"R")
      catch (Excpetion e)
   	endtry

   	return lc_oFile

   // Cosa fa			:			Controlla se una parola/stringa è un elemento dell'array (=la parola è nell'array)
   //	pr_elemento		:			elemento da cercare nell'array
   //	pr_aArray		.			array -> array nel quale cercare
   //	Ritorna			:			lc_bRet -> logico, true se l'elemento è presente nell'array, altrimenti false
	function IsIn(pr_elemento,pr_aArray)
   	local lc_bRet,lc_char,lc_aDelimiter,lc_elementoArray,lc_fine,i

      lc_bRet = false

      lc_aArray = pr_aArray
      lc_elemento = pr_elemento

      lc_fine = lc_aArray.size

      for i = 1 to lc_fine
      	lc_elementoArray = lc_aArray[i]

         if lc_elemento == lc_elementoArray
         	lc_bRet = true
            exit
         endif
      next

   	return lc_bRet

   // Cosa fa			:			Fa un substring della stringa in base ai delimitatori passati
   //									"stringa di 'prova'" -> se come delimitatore c'è "'", allora, estrae prova
   // pr_row			:			stringa -> stringa da analizzare
   // pr_aDelimiter	:			array -> array che contiene i delimitatori
	//									Es: ",',|,/,$,...
	// Ritorna			:			lc_aRet -> array contenente tutte le parti di stringa trovate tra i delimitatori
	function MySubstr(pr_row,pr_aDelimiter)
   	local lc_row,lc_aDelimiter,lc_aRet,i,lc_char,lc_bDentroDelimitatore,lc_bIsIn,lc_stringaInDelimitatore,lc_cDelimitatore

      lc_row = pr_row
      lc_aDelimiter = pr_aDelimiter

      lc_aRet = new array()

      lc_stringaInDelimitatore = ""
      lc_cDelimitatore = null

      lc_bDentroDelimitatore = false

      lc_fine = len(lc_row)

      for i = 1 to lc_fine
      	lc_char = substr(lc_row,i,1)

         lc_bIsIn = this.IsIn(lc_char,lc_aDelimiter)

         if lc_bIsIn
         	if not lc_bDentroDelimitatore
               lc_cDelimitatore = lc_char
               lc_bDentroDelimitatore = true
               loop
            endif
         endif

			if lc_bIsIn
				if lc_char == lc_cDelimitatore
            	lc_aRet.add(lc_stringaInDelimitatore)
               lc_stringaInDelimitatore = ""
            	lc_bDentroDelimitatore = false
               lc_cDelimitatore = ""
               loop
            endif
         endif

			lc_stringaInDelimitatore += lc_char
      next

   	return lc_aRet

	// Cosa fa			:			Controlla se una parola/stringa è all'interno di un delimitatore
   //	pr_row			:			stringa -> stringa da analizzare
   //	pr_elemento		:			stringa -> parola/stringa da cercare nel delimitatore
   // pr_aDelimiter	:			array -> array contenente tutti i possibili delimitatori ("es: "/'/|/...")
   // Ritorna			:			lc_bRet -> logico, true se elemento all'interno dei delimitatori, altrimenti false
	function IsInDelimiter(pr_row,pr_elemento,pr_aDelimiter)
   	local lc_row,lc_elemento,lc_aDelimiter,lc_aRow,lc_fine

      lc_row = pr_row
      lc_elemento = pr_elemento
		lc_aDelimiter = pr_aDelimiter

		lc_bRet = false

      if not(lc_elemento$lc_row)
      	return lc_bRet
      endif

		lc_aRow = this.MySubstr(lc_row,lc_aDelimiter)

		lc_fine = lc_aRow.size

      for i = 1 to lc_fine
      	lc_row = lc_aRow[i]

         if lc_elemento$lc_row
         	lc_bRet = true
            exit
         endif
      next
      		
   	return lc_bRet

   // Cosa fa					:			Stabilisce se una stringa è una stringa che viene mostrata a monitor
   //											Per fare ciò, controlla per ogni elemento (parola/stringa) (fino a quando non trovo una corrispondenza)
   //											dell'array (che contiene le varie possibilità) se è nella riga
	// pr_row					:			stringa -> Riga da controllare
   // pr_aStringheValide	:			Array contenente le varie possibilità
   // Ritorna					.			lc_bRet -> logico, true se nella stringa è presente un elemento dell'array(= stringa di output)
   //											Altrimenti false
	function IsOutputString(pr_row,pr_aStringheValide)
   	local lc_row,lc_aStringheValide,lc_fine,i,lc_elemento,lc_aDelimiter

      lc_row = pr_row
      lc_aStringheValide = pr_aStringheValide

      lc_bRet = false

      lc_aDelimiter = new array()
      lc_aDelimiter.add("'")     
      lc_aDelimiter.add('"')

      lc_fine = lc_aStringheValide.size
      for i = 1 to lc_fine
      	lc_elemento = lc_aStringheValide[i]

         if lc_elemento$lc_row
         	if not(this.IsInDelimiter(lc_row,lc_elemento,lc_aDelimiter))
               lc_bRet = true
               exit
            endif
         endif

      next

   	return lc_bRet

	// Cosa fa			:			Cerca tutte le stringhe che vengono mostrate a schermo
	//									in un file sorgente dBase
   //									Vengono considerate stringhe di output tutte quelle presenti in lc_aStringheValide
	// pr_filePath		:			Percorso del file da analizzare
   // Ritorna			:			lc_aRet -> assocarray così formato
   //											[]
	function getAllOutputStrings(pr_filePath)
		local lc_aRet,lc_filePath,lc_row,lc_bContinuo,lc_aStringheValide,lc_bOutputString,lc_nRow

      lc_bOutputString = false

      lc_aRet = new array()

      lc_filePath = pr_filePath

      // Cosa fa			:			Apre un file in lettura
      //	pr_filePath		:			stringa -> percorso del file da aprire
      // Ritorna			:			lc_oFile -> oggetto file (aperto in lettura)
      //									Se c'è un errore, oppure il file non esiste, ritorna
      //									un oggetto file vuoto
      lc_oFile = this.ReadFile(lc_filePath)

      lc_bContinuo = true
      lc_nRow = 0

      // Array contenente tutte le occasioni nelle quali deve essere estratta la riga
      // Es: quando nella riga è presente "msgbox" oppure "text"
      // Le parole non vengono considerate se all'interno di " o '
      lc_aStringheValide = new array()
      lc_aStringheValide.add("msgbox")
      lc_aStringheValide.add("a")
      lc_aStringheValide.add("text")
      lc_aStringheValide.add("speedtip")
      lc_aStringheValide.add("value")
      lc_aStringheValide.add("datasource")
      lc_aStringheValide.add("description")
		
		do while lc_bContinuo

      	if(lc_oFile.eof())
         	lc_bContinuo = false
            loop
         endif

			lc_row = lc_oFile.gets()
         lc_nRow += 1

         lc_bOutputString = this.IsOutputString(lc_row,lc_aStringheValide)

         if lc_bOutputString

         	// Aggiungo il numero della riga in fondo
            lc_row += ';'+lc_nRow
         	lc_aRet.add(lc_row)
         endif
			
      enddo

   return lc_aRet

endclass