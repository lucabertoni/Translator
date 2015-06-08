set procedure to api.prg additive
set procedure to translate.prg additive

shell(true,true)
clear

local lc_args,_i,lc_parola

if argcount()>0
   lc_args=new array()
   for _i=1 to argcount()
      lc_args.Add(argvector(_i))
   next
   lc_parola=lc_args[1]

   release object lc_args
   lc_args=NULL

   _PATH_TO_SCAN=lc_parola
else
	_PATH_TO_SCAN = "H:\Project Invoice\"
endif
#define _File_Exclude	"backup"
//#define _PATH_TO_SCAN	"H:\Project Invoice\"

///////////////////////////////////////

clear

local lc_array,lc_dir,lc_files,lc_logFile,lc_oFile,lc_oDb

public lc_aext,lc_aresult,pb_pathLogFile,pb_bLogVariabiliNonDichiarate,pb_sSql,pb_oOs,lc_aOS,pb_aOs

lc_aext=new array()
//lc_aext.add("ini")

lc_aext.add("prg")
lc_aext.add("rep")
lc_aext.add("lab")
lc_aext.add("crp")
lc_aext.add("wfm")
lc_aext.add("mnu")
lc_aext.add("cfm")
lc_aext.add("dmd")
lc_aext.add("cc")
lc_aext.add("php")
//lc_aext.add("sql")

lc_aext.Sort()

// Estraggo il numero di file che andrò ad analizzare
lc_sPath = 'C:\dBase Projects\stringhe\tree_tmp.txt'
lc_sVolume = substr(_PATH_TO_SCAN,1,2)
lc_sPath2Scan = substr(_PATH_TO_SCAN,3)
run(lc_sVolume+' && cd "'+lc_sPath2Scan+'" && dir /s /b *.prg *.rep *.lab *.crp *.wfm *.mnu *.cfm *.dmd *.cc *.php | find /c /v "" > "'+lc_sPath+'"')

if file(lc_sPath)
	lc_oFile = new file()
	lc_oFile.open(lc_sPath)
	lc_nFiles = val(lc_oFile.gets())

	lc_oFile.close()
	release object lc_oFile
	lc_oFile = NULL
endif

d = new database()
d.databaseName = 'translatedb'
d.loginstring = 'SYSDBA/masterkey'
d.active = true

q = new query()
q.database = d
q.sql = 'SELECT * FROM outputstrings'
q.active = true

// Estraggo le righe presenti ora nella tabella OutputStrings
pb_oOs = new Outputstrings()

// Cosa fa			:			Estrae la colonna sRiga dalla tabella
// pr_sRiga			:			stringa(opzionale), clausola da usare nella where
// Ritorna			:			lc_aRet -> array, contiene tutte le righe del rowset
pb_aOs =  pb_oOs.getSRiga()

lc_aresult=new array()
AttraversaDir(_PATH_TO_SCAN)

release object pb_aOs
pb_aOs = NULL

pb_oOs.releaseConnection()
release object pb_oOs
pb_oOs = NULL

q.active = false
release object q
q = NULL

d.active = false
release object d
d = NULL

release object lc_aext
lc_aext=NULL

return


function AttraversaDir(pr_dir)
	local lc_dir,lc_olddir,i,lc_fine,lc_file,lc_ext,lc_newdir,lc_buffer,lc_adir
   local lc_oSearchOutputStrings

   lc_dir=pr_dir

   lc_olddir=set("DIRECTORY")

   private pv_dir

   pv_dir = '"'+lc_dir+'"'

	SET DIRECTORY TO &pv_dir

   lc_adir=new array()
   lc_adir.Dir("*.*","D")

	lc_oSearchOutputStrings = new SearchOutputStrings()

   lc_fine=lc_adir.Size/5
   for i=1 to lc_fine
//   	? lc_adir[i,1], lc_adir[i,5]

   	if lc_adir[i,5]=="....D" 
      	lc_newdir=lc_adir[i,1]
      	? "New Dir "+lc_newdir

         if lc_adir[i,1]#"."

	      	AttraversaDir(lc_newdir)
         endif
      else
         lc_ext=lower(right(lc_adir[i,1],3))

         if lc_aext.Scan(lc_ext)>0
            // se c'è allora facciamo un controllo nel file				
            if lower(left(lc_adir[i,1],len(_File_Exclude)))==_File_Exclude
            	loop
            endif


// Cosa fa			:			Cerca tutte le stringhe che vengono mostrate a schermo
            //									in un file sorgente dBase
            //									Vengono considerate stringhe di output tutte quelle presenti in lc_aStringheValide
            // pr_filePath		:			Percorso del file da analizzare
            // Ritorna			:			Niente, scrive il tutto nel db (vedere writeDb())
            lc_oSearchOutputStrings.getAllOutputStrings(lc_adir[i,1])
         endif
      endif
   next

   release object lc_adir
   lc_adir=NULL

   pv_dir="'"+lc_olddir+"'"
   SET DIRECTORY TO &pv_dir.

	return

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

	// Cosa fa					:			Stabilisce se la keyword (msgbox(,?,value=,..) è commentata
	// pr_sStringa				:			stringa, stringa nella quale cercare e stabilire se una parola è commentata
	// pr_sKeyword				:			stringa, stringa da controllare
	// pr_sCommento			:			stringa, tipo di commento, es: '//'
	// Ritorna					:			lc_bRet -> logico, True se la keyword è commentata, altrimenti false
	function isCommentedKeyWord(pr_sStringa,pr_sKeyword,pr_sCommento)
		local lc_sKeyword,lc_sCommento,lc_bRet,lc_aWords,lc_sStringa,i,lc_fine,lc_sWord,lc_nCommentPosition
		local lc_nKeywordPosition,lc_bKeyword
		
		lc_sStringa = pr_sStringa
		lc_sKeyword = pr_sKeyword
		lc_sCommento = pr_sCommento
		lc_nKeywordPosition = 0
		lc_nCommentPosition = 0
		lc_fine = 0
		lc_bRet = False
		lc_bKeyword = False
		
		lc_aWords = new array()
		
		// Se non ci sono commenti nella riga ritorno False
		if not(lc_sCommento$lc_sStringa)
			release object lc_aWords
			lc_aWords = NULL
			return lc_bRet
		endif
			
		// Cosa fa						:			Esplode una stringa
		// pr_stringa					:			stringa, stringa da esplodere
		// pr_separatore				:			carattere sul quale viene esplosa la stringa
		// pr_aDelimitatoriInizio	:			array, delimitatori inizio, nei quali non deve agire il
		//												carattere separatore
		// pr_aDelimitatoriFine		:			array, determinano la fine del range nel quale non agisce il
		//												carattere separatore
		// pr_delimitatoreSpeciale	:			carattere, delimitatore speciale nel quale non hanno effetto né
		//												il carattere separatore, né i delimitatori. Se prima di esso c'è
		//												un carattere di escape (=> \) allora non è da calcolare come delimitatore
		lc_aWords = this.Explode(lc_sStringa,' ',new array(),new array(),NULL)
		lc_fine = lc_aWords.size
		for i = 1 to lc_fine
			lc_sWord = lc_aWords[i]
			// Trova solo la prima occorrenza della keyword, dato che il commento singolo commenta tutto il restante della riga
			// però potrebbero esserci due keyword nella frase, una commentata e una no, quindi prendo solo la prima occorrenza
			// dato che potrebbe essere la keyword non commentata
			if lc_sKeyword$lc_sWord and lc_bKeyword == False
				lc_nKeywordPosition = i
				lc_bKeyword = True
			elseif lc_sCommento$lc_sWord
				lc_nCommentPosition = i
			endif
		next
		
		if lc_nKeywordPosition > lc_nCommentPosition
			lc_bRet = True
		endif
		
		release object lc_aWords
		lc_aWords = NULL
		
		return lc_bRet

   // Cosa fa						:			Esplode una stringa
   // pr_stringa					:			stringa, stringa da esplodere
   // pr_separatore				:			carattere sul quale viene esplosa la stringa
   // pr_aDelimitatoriInizio	:			array, delimitatori inizio, nei quali non deve agire il
   //												carattere separatore
   // pr_aDelimitatoriFine		:			array, determinano la fine del range nel quale non agisce il
   //												carattere separatore
   // pr_delimitatoreSpeciale	:			carattere, delimitatore speciale nel quale non hanno effetto né
   //												il carattere separatore, né i delimitatori. Se prima di esso c'è
   //												un carattere di escape (=> \) allora non è da calcolare come delimitatore
	function Explode(pr_stringa,pr_separatore,pr_aDelimitatoriInizio,pr_aDelimitatoriFine,pr_delimitatoreSpeciale)
      local lc_stringa,lc_separatore,lc_aDelimitatoriInizio,lc_aDelimitatoriFine,lc_delimitatoreSpeciale
      local lc_aRet,lc_fine,lc_bDentroDelimitatori,lc_bDentroDelimatoreSpeciale,lc_carattere,lc_exploded
      local lc_count,lc_before

      lc_before = ""
      lc_count = 0
      lc_exploded = ""
      lc_bDentroDelimitatori = false
      lc_bDentroDelimitatoreSpeciale = false
      lc_aRet = new array()
      lc_stringa = pr_stringa
      lc_separatore = pr_separatore
      lc_aDelimitatoriInizio = pr_aDelimitatoriInizio
      lc_aDelimitatoriFine = pr_aDelimitatoriFine
      lc_delimitatoreSpeciale = pr_delimitatoreSpeciale

      lc_fine = len(lc_stringa)
      // Per ogni elemento della stringa...
      for i = 1 to lc_fine
    
         lc_carattere = substr(lc_stringa,i,1)

         // Se trovo il separatore
         if lc_carattere == lc_separatore

            // Se non sono dentro ai delimitatori/delimitatore speciale
            if not lc_bDentroDelimitatori and not lc_bDentroDelimitatoreSpeciale

               // Se la lunghezza della stringa esplosa è maggiore di 0 la memorizzo nell'array e poi la azzero
               if len(lc_exploded) > 0
                  lc_aRet.add(lc_exploded)
                  lc_exploded = ""
               endif
            // Se sono dentro i delimitatori, aggiungo la virgola alla stringa esplosa
            else
               lc_exploded += lc_carattere	
            endif
         endif

         // Se il carattere non è un separatore
         if not (lc_carattere == lc_separatore)

            // Guardo i vari casi...
            do case
               // Nel caso il carattere sia nei delimitatori iniziali...
               case this.IsIn(lc_carattere,lc_aDelimitatoriInizio)

                  // Se non sono dentro il delimitatore speciale, incremento il count dei delimitatori
                  // e entro nei delimitatori
                  if not lc_bDentroDelimitatoreSpeciale
                     lc_count += 1           
                     lc_bDentroDelimitatori = true    	
                  endif

                  lc_exploded += lc_carattere

               // Nel caso il carattere sia nei delimitatori iniziali...
               case this.IsIn(lc_carattere,lc_aDelimitatoriFine)
            	                                         
                  // Se non sono dentro il delimitatore speciale, decremento il count dei delimitatori
                  if not lc_bDentroDelimitatoreSpeciale
                     lc_count -= 1               	
                  endif

                  // Se il count è a 0 (ho chiuso tutti i delimitatori) allora esco dai delimitatori
                  if lc_count == 0
                     lc_bDentroDelimitatori = false
                  endif
                  lc_exploded += lc_carattere

               // Nel caso il carattere sia uguale al delimitatore speciale
               case lc_carattere == lc_DelimitatoreSpeciale

                  // Se prima c'è il carattere di escape, immagazzino il carattere normalmente
                  if lc_before == "\"
                     lc_exploded += lc_carattere
                  // Altrimenti 
                  else
                     // Se non sono dentro il range del delimitatore speciale, ci entro
                     if not lc_bDentroDelimitatoreSpeciale
                        lc_bDentroDelimitatoreSpeciale = true
                        lc_exploded += lc_carattere
                     // Altrimenti, se sono dentro il range del delimitatore speciale, esco
                     else
                        lc_bDentroDelimitatoreSpeciale = false
                        lc_exploded += lc_carattere
                     endif  	
                  endif
               otherwise
                  lc_exploded += lc_carattere
            endcase      
         endif

         lc_before = lc_carattere
      next

      // Nel caso sia rimasto qualcosa in lc_exploded, lo salvo nell'array
      if len(lc_exploded) > 0
         lc_aRet.add(lc_exploded)
      endif
      return lc_aRet

	// Cosa fa					:			Estrae la posizione dell'ultima occorrenza di un carattere in una stringa
	// pr_sStringa				:			stringa, dove cercare l'occorrenza del carattere
	// pr_cChar					:			carattere, carattere da cercare nella stringa
	// Ritorna					:			lc_nPosition -> numerico, posizione dell'ultima occorrenza di un carattere
	//											0 se carattere non presente nella stringa
	function getLastCharOccurrence(pr_sStringa,pr_cChar)
		local lc_sStringa,lc_cChar,i,lc_fine,lc_nPosition
		
		lc_sStringa = pr_sStringa
		lc_cChar = pr_cChar
		lc_fine = len(lc_sStringa)
		lc_nPosition = 0
		
		if not(lc_cChar$lc_sStringa)
			return lc_nPosition
		endif
		
		for i = 1 to lc_fine
			lc_carattere = substr(lc_sStringa,i,1)
			if lc_carattere == lc_cChar
				lc_nPosition = i
			endif
		next
		
		return lc_nPosition

	// Cosa fa					:			Controlla che il valore associato ad un elemento non sia un numero o un valore logico
	//											Es: oggetto.value = false,oggetto.value = true,oggetto.value = 7 (ritorna true)
	// pr_sStringa				:			stringa, stringa da analizzare
	// Ritorna					:			lc_bRet -> logico, false se il valore associato all'oggetto è un valore logico o un numero
	//											altrimenti, nel caso sia una stringa, true
	function IsString(pr_sStringa)
		local lc_sStringa,lc_sValue,lc_bRet,lc_sText
		
		lc_sStringa = pr_sStringa
		lc_bRet = False		
		lc_nEqualPosition = at('=',lc_sStringa)
/*
		if lc_nEqualPosition <= 0
			lc_bRet = True
			return lc_bRet
		endif
*/		
		lc_sValue = lower(rtrim(ltrim(substr(lc_sStringa,lc_nEqualPosition+1))))
		
		if not(lc_sValue == 'false') and not(lc_sValue == 'true')
			// Cosa fa				:				Controlla se una stringa è un numero
			//											Es: la stringa '1234' è un numero
			//												            '1234asdjfha' non lo è
			// pr_sStringa			:				stringa, stringa da controllare
			// Ritorna				:				lc_bRet -> logico, true se la stringa è un numero, altrimenti false
			if not(isDigit(lc_sValue))
				if "'"$lc_sValue or '"'$lc_sValue
					lc_bRet = True
				endif
			endif
		endif
		
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
						// Cosa fa					:			Stabilisce se la keyword (msgbox(,?,value=,..) è commentata
						// pr_sStringa				:			stringa, stringa nella quale cercare e stabilire se una parola è commentata
						// pr_sKeyword				:			stringa, stringa da controllare
						// pr_sCommento			:			stringa, tipo di commento, es: '//'
						// Ritorna					:			lc_bRet -> logico, True se la keyword è commentata, altrimenti false
						if not this.isCommentedKeyWord(lc_row,lc_elemento,'//')
							// Cosa fa					:			Controlla che il valore associato ad un elemento non sia un numero o un valore logico
							//											Es: oggetto.value = false,oggetto.value = true,oggetto.value = 7 (ritorna false)
							//												 oggetto.value = "prova" ritorna true
							// pr_sStringa				:			stringa, stringa da analizzare
							// Ritorna					:			lc_bRet -> logico, false se il valore associato all'oggetto è un valore logico o un numero
							//											altrimenti, nel caso sia una stringa, true
							if this.IsString(lc_row)
								lc_bRet = true
								exit
							endif
						endif
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

      q.rowset.beginAppend()

      q.rowset.fields['sFile'].value = lc_filePath
      q.rowset.fields['sFunction'].value = lc_sFunction
      q.rowset.fields['nRiga'].value = lc_nRow
      q.rowset.fields['sRiga'].value = lc_row

      q.rowset.save()
                              
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
//      lc_aStringheValide.add("?")
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
      lc_aStringheNonValide.add('.fields[')
		
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
					// Se la riga non è presente in db, la salvo
					if pb_aOs.Scan(lc_row) == 0
						// Cosa fa			:			Scrive nel db i dati
						// pr_filePath		:			stringa, percorso del file
						// pr_sFunction	:			stringa, nome delle funzione
						// pr_nRow			:			numerico (intero), numero della riga
						// pr_row			:			stringa, riga estratta dal sorgente
						this.writeDb(lc_filePath,lc_sFunction,lc_nRow,lc_row)
						
						// Aggiungo anche la riga all'array
						pb_aOs.add(lc_row)
					endif
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