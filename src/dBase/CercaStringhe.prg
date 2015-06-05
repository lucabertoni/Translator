class SearchOutputStrings
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
      lc_cDelimitatore = ''

      lc_bDentroDelimitatore = false

      lc_fine = len(lc_row)

      for i = 1 to lc_fine
      	lc_char = substr(lc_row,i,1)

         lc_bIsIn = this.IsIn(lc_char,lc_aDelimiter)
			
			if lc_bIsIn
				if lc_char == lc_cDelimitatore
					? lc_stringaindelimitatore
					lc_bdentrodelimitatore = False
					lc_aRet.add(lc_stringaInDelimitatore)
					lc_stringaindelimitatore = ''
					lc_cDelimitatore = ''
					loop
				else
					lc_bDentroDelimitatore = True
					lc_aStringaInDelimitatore = ''
					lc_cDelimitatore = lc_char
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
   //											Update: esegue anche un controllo sul numero di '=' presenti nella stringa(deve essere
   //											minore o uguale a 1)
	// pr_row					:			stringa -> Riga da controllare
   // pr_aStringheValide	:			Array contenente le varie possibilità
   // Ritorna					.			lc_bRet -> logico, true se nella stringa è presente un elemento dell'array(= stringa di output)
   //											Altrimenti false
	function IsOutputString(pr_row,pr_aStringheValide)
   	local lc_row,lc_aStringheValide,lc_fine,i,lc_elemento,lc_aDelimiter

      lc_row = pr_row
      lc_aStringheValide = pr_aStringheValide

      lc_bRet = false
/*
      lc_aDelimiter = new array()
      lc_aDelimiter.add("'")     
      lc_aDelimiter.add('"')
*/
      lc_fine = lc_aStringheValide.size
      for i = 1 to lc_fine
      	lc_elemento = lc_aStringheValide[i]

         if lc_elemento$lc_row
         	//if not(this.IsInDelimiter(lc_row,lc_elemento,lc_aDelimiter))
            	lc_newElemento = lc_elemento+'='
               if not(lc_newElemento$lc_row)
                  lc_bRet = true
                  exit
               endif
            //endif
         endif
      next
/*		
		release object lc_aDelimiter
		lc_aDelimiter = NULL
*/
   	return lc_bRet

	// Cosa fa			:			Elimina tutti gli spazi nel testo
   // pr_sText			:			stringa, testo dal quale eliminare gli spazi, es 'testo di prova'
   // Ritorna			:			lc_sRet -> stringa, stringa senza spazi, es 'testodiprova'
	function Trim(pr_sText)
   	local lc_sText,lc_sRet,lc_fine,i

      lc_sRet = ''

      lc_sText = pr_sText

      lc_fine = len(lc_sText)

      for i = 1 to lc_fine
      	lc_char = substr(lc_sText,i,1)

      	if not(lc_char == ' ')
         	lc_sRet += lc_char
         endif
      next

   	return lc_sRet

   // Cosa fa				:			Controlla se una riga è valida
   //										Non deve contenere al suo interno quello che c'è in pr_aInvalidWords
   // pr_sRiga				:			stringa, testo da analizzare
   // pr_aInvalidWords	:			array, contiene tutte quelle parole che determinano l'invalidità della stringa
   // Ritorna				:			lc_bRet -> true se la riga è valida, altrimenti false
	function isValid(pr_sRiga,pr_aInvalidWords)
   	local lc_sRiga,lc_aInvalidWords,lc_fine,i,lc_bRet

      lc_sRiga = pr_sRiga
      lc_aInvalidWords = pr_aInvalidWords

      lc_bRet = false

      lc_fine = lc_aInvalidWords.size

      for i = 1 to lc_fine
      	lc_sInvalidWord = lc_aInvalidWords[i]

         if lc_sInvalidWord$lc_sRiga
         	lc_bRet = false
         	exit
         else
         	lc_bRet = true
         endif
      next

   	return lc_bRet


   // Cosa fa			:			Elimina gli spazi e i tab all'inizio di una stringa (ltrim non elimina i tab!!)
   // pr_stringa		:			stringa -> stringa dall quale eliminare i caratteri
   // Ritorna			:			lc_newStringa -> stringa, stringa senza spazi/tab iniziali
   function tabsSpacesLTrim(pr_stringa)
      local lc_stringaNew,lc_stringa,lc_bContinuo,i,lc_char,lc_char,lc_asc

      lc_stringa = pr_stringa
      lc_stringaNew = ""

      if empty(lc_stringa)
         return lc_stringaNew
      endif

      i = 1
      do while true

         lc_char = substr(lc_stringa,i,1)
         lc_asc = asc(lc_char)

         if lc_asc == 9 or lc_asc == 32			// 9: tab, 32: spazio
            i++
            loop
         else
            lc_stringaNew = substr(lc_stringa,i)
            exit
         endif

      enddo	
      return lc_stringaNew


   // Cosa fa			:			Estrae il nome della funzione da una stringa di testo
   //									es: 'function nome_funzione(pr_parametro)', estrae 'nome_funzione'
   // pr_stringa		:			stringa -> stringa da analizzare e dalla quale estrarre il nome della funzione
   // Ritorna			:			lc_sRet -> stringa, stringa contenente il nome della funzione
   //									Se in pr_stringa non è presente 'function' -> lc_sRet sarà ""
   function getFunctionName(pr_stringa)
      local lc_stringa,lc_sRet,lc_parola,lc_parolaBefore,i,lc_char,lc_fine

      lc_stringa = pr_stringa
      lc_sRet = ""

      lc_stringa = lower(lc_stringa)

      if not("function "$lc_stringa)
         return lc_sRet
      endif

      // Cosa fa			:			Elimina gli spazi e i tab all'inizio di una stringa (ltrim non elimina i tab!!)
      // pr_stringa		:			stringa -> stringa dall quale eliminare i caratteri
      // Ritorna			:			lc_newStringa -> stringa, stringa senza spazi/tab iniziali
      lc_stringa = this.tabsSpacesLTrim(lc_stringa)

      lc_parolaBefore = ""
      lc_parola = ""
   
      lc_fine = len(lc_stringa)
      for i = 1 to lc_fine
         lc_char = substr(lc_stringa,i,1)

         // Controllo se ho incontrato uno spazio(fine parola), una parentesi (inizio parametri e fine nome funzione)
         // oppure se sono arrivato alla fine della riga [...]
         if lc_char == " " or lc_char == "(" or i == lc_fine
      																		

            if upper(lc_parolaBefore) == "FUNCTION"

               //[...] Se sono arrivato alla fine della riga, aggiungo un carattere (l'ultimo carattere) alla parola(nome funzione)
               // e salvo il nome della funzione
               if i == lc_fine
                  lc_parola += lc_char
               endif
               lc_sRet = lc_parola
               exit
            endif

            lc_parolaBefore = lc_parola
            lc_parola = ""
         else
            lc_parola += lc_char
         endif
      next

      return lc_sRet

   // Cosa fa			:			Scrive nel db i dati
   // pr_filePath		:			stringa, percorso del file
   // pr_sFunction	:			stringa, nome delle funzione
   // pr_nRow			:			numerico (intero), numero della riga
   // pr_row			:			stringa, riga estratta dal sorgente
	function writeDb(pr_filePath,pr_sFunction,pr_nRow,pr_row)
   	local lc_filePath,lc_sFunction,lc_nRow,lc_row

      lc_filePath = pr_filePath
      lc_sFunction = pr_sFunction
		lc_nRow = pr_nRow
      lc_row = pr_row

      d = new database()
      d.databaseName = 'StringheDB'
		d.loginstring = 'SYSDBA/masterkey'
      d.active = true

      q = new query()
      q.database = d
      q.sql = 'SELECT * FROM outputstrings'
      q.active = true

      q.rowset.beginAppend()

      q.rowset.fields['sFile'].value = lc_filePath
      q.rowset.fields['sFunction'].value = lc_sFunction
      q.rowset.fields['nRiga'].value = lc_nRow
      q.rowset.fields['sRiga'].value = lc_row

      q.rowset.save()
                                
      q.active = false
      release object q
      q = NULL

      d.active = false
      release object d
      d = NULL
       
   	return


	// Cosa fa			:			Cerca tutte le stringhe che vengono mostrate a schermo
	//									in un file sorgente dBase
   //									Vengono considerate stringhe di output tutte quelle presenti in lc_aStringheValide
	// pr_filePath		:			Percorso del file da analizzare
   // Ritorna			:			Niente, scrive il tutto nel db (vedere writeDb())
	function getAllOutputStrings(pr_filePath)
		local lc_aRet,lc_filePath,lc_row,lc_bContinuo,lc_aStringheValide,lc_bOutputString,lc_nRow
      local lc_aStringheNonValide,lc_bStringaOk,lc_sFunction,lc_count,i

      lc_bOutputString = false

      lc_aRet = new assocarray()

      lc_filePath = pr_filePath

      lc_sFunction = ''

      lc_aFunction = new array()

      // Cosa fa			:			Apre un file in lettura
      //	pr_filePath		:			stringa -> percorso del file da aprire
      // Ritorna			:			lc_oFile -> oggetto file (aperto in lettura)
      //									Se c'è un errore, oppure il file non esiste, ritorna
      //									un oggetto file vuoto
      lc_oFile = this.ReadFile(lc_filePath)

      lc_filePath = lc_oFile.path

      lc_bContinuo = true
      lc_nRow = 0

      // Array contenente tutte le occasioni nelle quali deve essere estratta la riga
      // Es: quando nella riga è presente "msgbox" oppure "text"
      // Le parole non vengono considerate se all'interno di " o '
      lc_aStringheValide = new array()
      lc_aStringheValide.add("msgbox(")
      lc_aStringheValide.add("?")
      lc_aStringheValide.add("text=")
      lc_aStringheValide.add("speedtip=")
      lc_aStringheValide.add("value=")
      lc_aStringheValide.add("datasource=")
      lc_aStringheValide.add("description=")

      // Array contenente tutti i casi nei quali la riga non deve essere considerata
      lc_aStringheNonValide = new array()
      lc_aStringheNonValide.add('if ')   
      lc_aStringheNonValide.add('case ')
      lc_aStringheNonValide.add('while ')
      lc_aStringheNonValide.add('for ')
		
		do while lc_bContinuo

      	if(lc_oFile.eof())
         	lc_bContinuo = false
            loop
         endif

			lc_row = lc_oFile.gets()
         lc_nRow += 1
         lc_sTempRow = lower(lc_row)
         
         // Cosa fa				:			Controlla se una riga è valida
         //										Non deve contenere al suo interno quello che c'è in pr_aInvalidWords
         // pr_sRiga				:			stringa, testo da analizzare
         // pr_aInvalidWords	:			array, contiene tutte quelle parole che determinano l'invalidità della stringa
         // Ritorna				:			lc_bRet -> true se la riga è valida, altrimenti false
         lc_bStringaOk = this.isValid(lc_sTempRow,lc_aStringheNonValide)

         if not(lc_bStringaOk)
         	loop
         endif

			if 'function '$lc_sTempRow
				lc_sFunction = this.getFunctionName(lc_sTempRow)
            loop
         endif

         lc_sTempRow = Trim(lc_sTempRow)

         lc_bOutputString = this.IsOutputString(lc_sTempRow,lc_aStringheValide)
		
         if lc_bOutputString
				if not(empty(lc_sFunction))
					this.writeDb(lc_filePath,lc_sFunction,lc_nRow,lc_row)
				endif
         endif
			
      enddo
		
		release object lc_aStringheValide
		lc_aStringheValide = NULL
		
		release object lc_aStringheNonValide
		lc_aStringheNonValide = NULL
		
		lc_oFile.close()
		release object lc_oFile
		lc_oFile = NULL
		
   	return

endclass