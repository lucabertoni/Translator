// Cosa fa				:				Controlla se una stringa è un numero
//											Es: la stringa '1234' è un numero
//												            '1234asdjfha' non lo è
// pr_sStringa			:				stringa, stringa da controllare
// Ritorna				:				logico, true se la stringa è un numero, altrimenti false
function isDigit(pr_sStringa)
	local lc_sStringa,lc_nStringa,lc_bRet,lc_fine,lc_cChar,lc_sNumbers
	
	lc_sStringa = pr_sStringa
	lc_sNumbers = '0123456789'
	
	lc_fine = len(lc_sStringa)
	for i = 1 to lc_fine
		lc_cChar = substr(lc_sStringa,i,1)
		if not(lc_cChar$lc_sNumbers)
			return False
		endif
	next
	return True
	
// Cosa fa				:				Estrae tutte le stringhe poste tra [doppi]apici
//											Es: testo "di" 'prova' -> di,prova
// pr_sText				:				stringa, testo da analizzare
// Ritorna				:				lc_aRet -> array, contiene le stringhe estratte
//											Es: lc_aRet[1] = "di" (senza gli apici)
//												 lc_aRet[2] = "prova" (senza gli apici)
function getStrings(pr_sText)
	local lc_sText,lc_aRet,i,lc_fine,lc_char,lc_bDentroApici,lc_cApice,lc_sString
	
	lc_sText = pr_sText
	lc_aRet = new array()
	lc_fine = len(lc_sText)
	lc_bDentroApici = False
	lc_sString = ''
	
	for i = 1 to lc_fine
		lc_char = substr(lc_sText,i,1)
		if lc_char == '"' or lc_char == "'"
			// Se non sono dentro agli apici
			if not lc_bDentroApici
				lc_bDentroApici = True
				lc_cApice = lc_char
			// Se sono dentro agli apici
			else
				if lc_char == lc_cApice
					if not(empty(lc_sString))
						lc_aRet.add(lc_sString)
					endif
					lc_sString = ''
					lc_bDentroApici = False
				endif
			endif
		// Se il carattere non è un apice
		else
			if lc_bDentroApici
				lc_sString += lc_char
			endif
		endif
	next
	
	return lc_aRet
	
// Cosa fa				:			Splitta la riga sul carattere passato come parametro
// pr_sStringa			:			stringa, testo da splittare
// pr_cChar				:			carattere, carattere sul quale splittare la stringa
// Ritorna				:			lc_aRet -> array, contiene tutti gli elementi derivanti dallo split
//										Es: "Stringa da | splittare sul |carattere" "|"
//										lc_aRet[1] = "Stringa da "
//										lc_aRet[2] = " splittare sul "
//										lc_aRet[3] = "carattere"
function split(pr_sStringa,pr_cChar)
	local lc_sStringa,lc_cChar,lc_sApp,i,lc_fine,lc_carattere
	
	lc_sStringa = pr_sStringa
	lc_cChar = pr_cChar
	lc_sApp = ''
	lc_aRet = new array()
	
	lc_fine = len(lc_sStringa)
	
	for i = 1 to lc_fine
		lc_carattere = substr(lc_sStringa,i,1)
		
		if lc_carattere == lc_cChar
			lc_aRet.add(lc_sApp)
			lc_sApp = ''
			loop
		endif
		
		lc_sApp += lc_carattere
	next
	
	// Aggiungo quello che è rimasto appeso in coda
	if not(empty(lc_sApp))
		lc_aRet.add(lc_sApp)
	endif
	
	return lc_aRet
	

// pr_path ex: "C:\PROGRAMMI\PI\ARCHIVIO\RIBA" -- deve essere sempre presente c: o d: o altro
function MakeTree(pr_path)
	local ok,lc_path,lc_array,i,lc_fine,lc_unita
   private pv_oldpath,pv_dir,pv_app

   lc_path=pr_path

   if (":"$lc_path) or ("."$lc_path)
   	lc_ok=true
   else
   	lc_unita=left(SET("DIRECTORY"),2)

      if left(lc_path,1)=="\"
      	lc_path=lc_unita+lc_path
      else
      	lc_path=lc_unita+"\"+lc_path
      endif
   endif

//   if left(lc_path,2)="\\"
   	// percorso di rete ok
//      return true
//   endif

   if right(lc_path,1)=="\"
   	lc_path=left(lc_path,len(lc_path)-1)
   endif

	lc_array=Scomponi(lc_path,"\")	
   if lc_array.Size<=0
   	return false
   endif

   pv_oldpath='"'+SET("DIRECTORY")+'"'
   ? pv_oldpath

   lc_ok=true
   lc_fine=lc_array.Size
   for i=1 to lc_fine
   	try
         if ":"$lc_array[i]
         	lc_array[i]=lc_array[i]+"\"
         endif

			pv_dir='"'+lc_array[i]+'"'

	   	? pv_dir

         if pv_dir=="."

         else
	         cd &pv_dir.
         endif
      catch (Exception e)
      	if ":"$pv_dir
         	lc_ok=false
            exit
         else
         	try
            	pv_app='mkdir "'+(&pv_dir.)+'"'

               ? pv_app

	         	&pv_app.

		         cd &pv_dir.
            catch (Exception e)
            	lc_ok=false
               exit
            endtry
         endif
      endtry
   next

   release object lc_array
   lc_array=NULL

   cd &pv_oldpath.

  	return lc_ok
	
// Cosa fa			:			Estrae da un array multidimensionale (bidimensionale), l'elemento n del primo livello
// pr_aElements	:			array, array da analizzare, es:
//										[1] => "stringa"
//										[2] => array()
// pr_nElement		:			numerico (intero), numero dell'elemento da estrarre, es: 2
// Ritorna			:			lc_aRet -> array di elementi estratti, es:
//										[1] => pr_aElements[1][2]
//										[2] => pr_aElements[2][2]
//										[3] => pr_aElements[3][2]
//										...
function getMultiDimArrayElement(pr_aElements,pr_nElement)
	local lc_aElements,lc_nElement,lc_aRet,lc_fine,i
	
	lc_aElements = pr_aElements
	lc_nElement = pr_nElement
	lc_fine = ALEN(lc_aElements)
	lc_aRet = new array()
	
	for i = 1 to lc_fine
			lc_aRet.add(lc_aElements[i][lc_nElement])
		try
		catch (Exception e)
			lc_aRet.add(NULL)
		endtry
	next
	
	return lc_aRet