set procedure to .\api.prg additive

class TranslateDB Of DATABASE
	with(this)
		databasename = 'TranslateDB'
		loginstring = 'SYSDBA/masterkey'
		active = True
	endwith
endclass

// Classe che gestisce la tabella outputstrings
// File				:			translate.prg
class Outputstrings
	this.oDb = new translatedb()
	
	this.oQ = new query()
	this.oQ.database = this.oDb
	this.oQ.sql = "SELECT * FROM OUTPUTSTRINGS"
	this.oQ.active = True
/*	
	this.q = new query()
	this.q.database = this.oDb
	this.q.sql = 'SELECT * FROM OUTPUTSTRINGS'
	this.q.active = True

	// Cosa fa		:			Inserisce i dati nella tabella
	// pr_sFile		:			stringa, percorso del file
	// pr_sFunction:			stringa, nome della funzione
	// pr_nRiga		:			numerico, numero della riga
	// pr_sRiga		:			stringa, riga da inserire
	// Ritorna		:			lc_bRet, true se inserimento riuscito, altrimenti false
	// File			:			translate.prg
	function insertTb(pr_sFile,pr_sFunction,pr_nRiga,pr_sRiga)
		local lc_sFile,lc_sFunction,lc_nRiga,lc_sRiga,lc_sSql,lc_bRet
		
		lc_sFile = pr_sFile
		lc_sFunction = pr_sFunction
		lc_nRiga = pr_nRiga
		lc_sRiga = pr_sRiga
		lc_bRet = False
		
		this.q.rowset.beginAppend()
		this.q.rowset.fields['sFile'].Value = lc_sFile
		this.q.rowset.fields['sFunction'].Value = lc_sFunction
		this.q.rowset.fields['nRiga'].Value = lc_nRiga
		this.q.rowset.fields['sRiga'].Value = lc_sRiga
		// Cosa fa			:			Genera l'md5 di una stringa di testo
		// pr_sStringa		:			stringa, stringa di testo dalla quale generare l'md5
		// Ritorna			:			lc_sRet -> stringa, md5 della stringa
		// File				:			api.prg
		this.q.rowset.fields['sHash'].Value = md5(lc_sRiga)
		this.q.rowset.save()
		
		try
			lc_bRet = True
		catch(Exception e)
			return lc_bRet
		endtry

		return lc_bRet
*/
	// Cosa fa			:			Genera l'hash (firebird sql) della colonna sRiga, per ogni riga nella tabella e lo salva in sHash
	function hash()
		local lc_sSql
		lc_sSql = 'UPDATE OUTPUTSTRINGS SET SHASH=HASH(SRIGA)'
		this.oDb.executesql(lc_sSql)
		return

	// Cosa fa			:			Aggiorna il campo cEscludi della tabella per ogni riga
	//									Viene settato a 'x' se l'hash della riga è presente nella tabella delle esclusioni
	function updateEsclusioni()
		local lc_sSql,q1
		
		q1 = new query()
		q1.database = this.odb
		q1.requestlive = False
		q1.sql = 'SELECT OUTPUTSTRINGS.ID FROM OUTPUTSTRINGS JOIN ESCLUSIONI ON OUTPUTSTRINGS.SHASH=ESCLUSIONI.SHASH'
		q1.active = True
		
		if q1.rowset.endofset
			return
		endif
	
		lc_sSql = 'UPDATE OUTPUTSTRINGS SET CESCLUDI="x" WHERE '
		do while not(q1.rowset.endOfSet)
			lc_sSql += 'ID='+q1.rowset.fields['id'].Value+' OR '
			q1.rowset.next()
		enddo
		
		
		lc_sSql = substr(lc_sSql,1,len(lc_sSql)-4)
		this.odb.executesql(lc_sSql)
		
		q1.active = False
		release object q1
		q1 = NULL
		
		return
		
	// Cosa fa			:			Imposta il campo cEscludi a '' basandosi sull'hash
	// pr_sHash			:			stringa, hash associato alla riga alla quale modificare il campo cEscludi
	function unsetEscludi(pr_sHash)
		local lc_sSql,lc_sHash
		
		lc_sHash = pr_sHash
		lc_sSql = 'UPDATE OUTPUTSTRINGS SET CESCLUDI="" WHERE SHASH="'+lc_sHash+'"'
		this.odb.executesql(lc_sSql)
		return
		
		
	// Cosa fa			:			Imposta il campo cEscludi a 'x' basandosi sull'hash
	// pr_sHash			:			stringa, hash associato alla riga alla quale modificare il campo cEscludi
	function setEscludi(pr_sHash)
		local lc_sSql,lc_sHash
		lc_sHash = pr_sHash
		lc_sSql = 'UPDATE OUTPUTSTRINGS SET CESCLUDI="x" WHERE SHASH="'+lc_sHash+'"'
		this.odb.executesql(lc_sSql)
		return
	
	// Cosa fa			:			Estrae tutte le righe di output (solamente il campo sRiga) dove cEscludi NON è 'x'
	// Ritorna			:			lc_aRet -> array, array contenente tutte le righe estratte con la select
	// Obsoleta			:			Vedi getSRiga()
	function getOutputStrings()
		local lc_aRet,q
		
		lc_aRet = new array()
		
		q = new query()
		q.database = this.oDb
		q.sql = "SELECT SRIGA FROM OUTPUTSTRINGS WHERE CESCLUDI IS NULL"
		q.requestlive = False
		q.active = True
		
		do while not(q.rowset.endOfSet)
			lc_aRet.add(q.rowset.fields['sRiga'].Value)
			q.rowset.next()
		enddo

		q.active = False
		release object q
		q = NULL

		return lc_aRet

	// Cosa fa			:			Estrae i valori dai campi sRiga e sHash, basandosi sul valore di pr_sFile
	// pr_sFile			:			stringa, percorso del file (sFile nella tabella) dal quale estrarre sRiga e sHash
	// Ritorna			:			lc_aRet -> array, così formato:
	//										[1] =>
	//											[1] => Stringa in italiano (sRiga)
	//											[2] => Hash della stringa in italiano (sHash)
	//										...
	function getSRigaSHashFilePath(pr_sFile)
		local lc_sFile,lc_sSql,lc_aRet,q,lc_sRiga,lc_sHash,i
		
		lc_sFile = pr_sFile
		lc_sSql = "SELECT SRIGA,SHASH FROM OUTPUTSTRINGS WHERE SFILE='"+lc_sFile+"'"
		
		q = new query()
		q.database = this.oDb
		q.sql = lc_sSql
		q.active = True

		lc_aRet = new array(q.rowset.count())
		i = 1
		
		// Riempio l'array che devo ritornare
		do while not(q.rowset.endOfSet)
			lc_sRiga = q.rowset.fields["sRiga"].Value
			lc_sHash = q.rowset.fields["sHash"].Value
			
			lc_aRet[i] = {lc_sRiga,lc_sHash}
			q.rowset.next()
			i += 1
		enddo
		
		q.active = False
		release object q
		q = NULL
		return lc_aRet

	// Cosa fa			:			Estrae la colonna sRiga dalla tabella
	// pr_sRiga			:			stringa(opzionale), clausola da usare nella where
	// Ritorna			:			lc_aRet -> array, contiene tutte le righe del rowset
	function getSRiga(pr_sRiga)
		local lc_sRiga
		
		if pcount()>0
			lc_sRiga = pr_sRiga
			this.oQ.active = False
			this.oQ.sql = "SELECT SRIGA FROM OUTPUTSTRINGS WHERE SRIGA = :riga"
			this.oQ.params["riga"] = lc_sRiga
			this.oQ.active = False
		else
			this.oQ.sql = "SELECT SRIGA FROM OUTPUTSTRINGS"
		endif
		
		lc_aRet = new array()
		
		do while not(q.rowset.endOfSet)
			lc_aRet.add(q.rowset.fields["sRiga"].Value)
			q.rowset.next()
		enddo
		
		return lc_aRet

	// Cosa fa			:			Estrae tutte le righe di output (solamente il campo sRiga e sHash) dove cEscludi NON è 'x'
	// Ritorna			:			lc_aRet -> array, array contenente tutte le righe estratte con la select, così strutturato
	//									lc_aRet[1] =>
	//													[1] = "stringa"				Stringa
	//													[2] = 6172384712349			Hash	
	function getSRigaSHash()
		local lc_aRet,q,i,lc_count
		
		lc_aRet = new array()
		
		q = new query()
		q.database = this.oDb
		q.sql = "SELECT SRIGA,SHASH FROM OUTPUTSTRINGS WHERE CESCLUDI IS NULL"
		q.requestlive = False
		q.active = True
		
		lc_count = q.rowset.count()
		lc_aRet = new array(lc_count)
		
		i = 1
		
		do while not(q.rowset.endOfSet)
			lc_aRet[i] = {q.rowset.fields['sRiga'].Value,q.rowset.fields['sHash'].Value}
			q.rowset.next()
			i += 1
		enddo

		q.active = False
		release object q
		q = NULL

		return lc_aRet
		
	// Cosa fa			:			Chiude la connessione al db, rilasciando l'oggetto this.oDb e this.q
	function releaseConnection()
		this.oQ.active = False
		release object this.oQ
		this.oQ = NULL

		this.oDb.active = False
		release object this.oDb
		this.oDb = NULL
		return
endclass

// Classe che gestisce la tabella esclusioni
class Esclusioni
	this.oDb = new translatedb()
	
	// Cosa fa			:			Elimina una riga dalla tabella
	// pr_sCampo		:			stringa, Campo nel quale cercare un valore che determina la cancellazione della riga
	// pr_sValore		:			undefined, Valore da cercare nella tabella per determinare quali righe cancellare
	function delete(pr_sCampo,pr_sValore)
		local lc_sCampo,lc_sSql
		private lc_sValore
		
		lc_sCampo = pr_sCampo
		lc_sValore = pr_sValore
		
		if type('lc_sValore') == 'C'
			lc_sSql = 'DELETE FROM ESCLUSIONI WHERE '+lc_sCampo+'="'+lc_sValore+'"'
		else
			lc_sSql = 'DELETE FROM ESCLUSIONI WHERE '+lc_sCampo+'='+lc_sValore
		endif
		
		this.oDb.executesql(lc_sSql)
		return
		
	// Cosa fa			:			Aggiunge una riga nella tabella
	// pr_sHash			:			stringa, valore da inserire nel campo sHash della tabella
	function add(pr_sHash)
		local lc_sHash
		lc_sHash = pr_sHash
		lc_sSql = 'INSERT INTO ESCLUSIONI(SHASH) VALUES("'+lc_sHash+'")'
		this.oDb.executesql(lc_sSql)
		return
	
	// Cosa fa			:			Chiude la connessione al db, rilasciando l'oggetto this.oDb
	function releaseConnection()
		this.oDb.active = False
		release object this.oDb
		this.oDb = NULL
		return
endclass

// Classe che gestisce la tabella "traduzioni"
class Traduzioni
	this.oDb = new translatedb()
	this.oQ = new query()
	this.oQ.database = this.oDb
	this.oQ.sql = "SELECT * FROM TRADUZIONI"
	this.oQ.active = True
	
	// Cosa fa				:			Esegue un insert nella tabella
	// pr_sSiglaLingua	:			stringa, sigla della lingua da inserire nel db. Es: ES
	// pr_sTraduzione		:			stringa, testo tradotto della stringa originale. Es: msgbox("Esto es un errrrrorrreee!!")
	// pr_sHash				:			stringa, hash della stringa originale(in italiano). Es: 7456684490365942249
	function insert(pr_sSiglaLingua,pr_sTraduzione,pr_sHash)
		local lc_sSiglaLingua,lc_sTraduzione,lc_sHash
		
		lc_sSiglaLingua = pr_sSiglaLingua
		lc_sTraduzione = pr_sTraduzione
		lc_sHash = pr_sHash
		
		this.oQ.rowset.beginAppend()
		this.oQ.rowset.fields["sSiglaLingua"].Value = lc_sSiglaLingua
		this.oQ.rowset.fields["sTraduzione"].Value = lc_sTraduzione
		this.oQ.rowset.fields["sHash"].Value = lc_sHash
		this.oQ.rowset.save()
		return

// Cosa fa			:			Genera l'hash (firebird sql) della colonna sOriginale, per ogni riga nella tabella e lo salva in sHash
	function hash()
		local lc_sSql
		lc_sSql = 'UPDATE TRADUZIONE SET SHASH=HASH(SORIGINALE)'
		this.oDb.executesql(lc_sSql)
		return
			
	// Cosa fa			:			Cancella tutto il contenuto della tabella Traduzione
	function deleteAll()
		this.oDb.executesql("DELETE FROM TRADUZIONE")
		return

	// Cosa fa				:			Controlla se un elemento è già presente nella tabella basandosi sulla
	//										sigla della lingua e sull'hash della stringa originale
	// pr_sSiglaLingua	:			stringa, sigla della lingua. Es: ES
	// pr_sHash				:			stringa, hash. Es: 7456684490365942249
	// Ritorna				:			lc_bRet -> logico, true se l'elemento è presente, altrimenti false
	function IsIn(pr_sSiglaLingua,pr_sHash)
		local lc_sSiglaLingua,lc_sHash,lc_bRet
		
		lc_sSiglaLingua = pr_sSiglaLingua
		lc_sHash = pr_sHash
		lc_bRet = False
		
		this.oQ.sql = 'SELECT ID FROM TRADUZIONI WHERE SSIGLALINGUA = "'+lc_sSiglaLingua+'" AND SHASH = "'+lc_sHash+'"'
		if this.oQ.rowset.count() > 0
			lc_bRet = True
		endif
		
		return lc_bRet
	
	// Cosa fa				:			Estrae tutte le traduzioni e le righe originali delle righe tradotte basandosi sul percorso del file
	// pr_sFile				:			stringa, percorso del file (sFile nella tabella outputstrings). Es: C:\Programmi\prova.txt
	// pr_sSiglaLingua	:			stringa, sigla della lingua della quale estrarre le traduzioni. Es: EN
	// Ritorna				:			lc_aRet -> array, così composto:
	//											[1] =>
	//												[1] => Riga originale (sRiga nella tabella outputstrings)
	//												[2] => Riga tradotta (sTraduzione nella tabella Traduzioni)
	function getTraduzioni(pr_sFile,pr_sSiglaLingua)
		local lc_oOs,lc_sFile,lc_aData,i,lc_fine,lc_sSql,lc_sTraduzione,lc_sSiglaLingua,lc_aRet
		
		lc_sFile = pr_sFile
		lc_sSiglaLingua = pr_sSiglaLingua
		lc_oOs = new OutputStrings()
		// Cosa fa			:			Estrae i valori dai campi sRiga e sHash, basandosi sul valore di pr_sFile
		// pr_sFile			:			stringa, percorso del file (sFile nella tabella) dal quale estrarre sRiga e sHash
		// Ritorna			:			lc_aRet -> array, così formato:
		//										[1] =>
		//											[1] => Stringa in italiano (sRiga)
		//											[2] => Hash della stringa in italiano (sHash)
		//										...
		lc_aData = lc_oOS.getSRigaSHashFilePath(lc_sFile)
		
		lc_fine = ALEN(lc_aData)
		lc_aRet = new array(lc_fine)
		
		for i = 1 to lc_fine
			lc_sStringa = lc_aData[i][1]
			lc_sHash = lc_aData[i][2]
			
			lc_sSql = "SELECT STRADUZIONE FROM TRADUZIONI WHERE SSIGLALINGUA='"+lc_sSiglaLingua+"' AND SHASH='"+lc_sHash+"'"
			
			this.oQ.sql = lc_sSql
			
			// Non dovrebbero esserci doppioni, nel caso considero la prima traduzione
			if this.oQ.rowset.count() > 1
				? "Trovata più di una traduzione per questa riga. Considero la prima. Riga e Hash: "
				? "|"+lc_sStringa+"|"
				? "|"+lc_sHash+"|"
			endif
			
			lc_sTraduzione = this.oQ.rowset.fields["STRADUZIONE"].Value
			lc_aRet[i] = {lc_sStringa,lc_sTraduzione}
		next
		
		release object lc_aData
		lc_aData = NULL
		
		lc_oOs.releaseConnection()
		release object lc_oOs
		lc_oOS = NULL
		
		return lc_aRet
	// Cosa fa			:			Riesegue una select sulla tabella		
	function reselect()
		this.oQ.sql = "SELECT * FROM TRADUZIONI"
		return
	
	// Cosa fa			:			Chiude la connessione al db, rilasciando l'oggetto this.oDb
	function releaseConnection()
		this.oQ.active = False
		release object this.oQ
		this.oQ = NULL
	
		this.oDb.active = False
		release object this.oDb
		this.oDb = NULL
		return
	
endclass

// Cosa fa			:			Crea il file per le traduzioni delle righe
// pr_aRighe		:			array, righe da inserire nel file (= da tradurre), così strutturato:
// pr_sLingua		:			stringa, sigla della lingua da usare per la generazione del file
// pr_sPath			:			stringa, percorso nel quale salvare il file
//									lc_aRet[1] =>
//													[1] = "stringa"				Stringa
//													[2] = 6172384712349			Hash
function writeFileTraduzioni(pr_aRighe,pr_sLingua,pr_sPath)
	local lc_aOs,lc_fine,lc_sPath,lc_oF,lc_sRiga,lc_nCount,lc_sLingua,lc_sPath
	
	lc_aOs = pr_aRighe
	lc_nCount = 0
	lc_sLingua = pr_sLingua
	lc_sPath = pr_sPath
	
	lc_fine = lc_aOs.size
	
	lc_oF = new file()

? "|"+lc_sPath+"|"
	if file(lc_sPath)
		// !!! Sostituisce tutto il contenuto del file !!!
		lc_oF.open(lc_sPath,'W')
	else
		lc_oF.create(lc_sPath,"W")
	endif

//	Array così strutturato:
//	lc_aOs[i][1] = "stringa"
//	lc_aOs[i][2] = 6172384712349
	for i = 1 to lc_fine
		lc_sRiga = 'IT'+chr(30)+lc_aOs[i][1]+chr(30)+lc_aOs[i][2]			// chr(30) = record separator
		lc_oF.puts(lc_sRiga)
		lc_sRiga = lc_sLingua+chr(30)+lc_aOs[i][1]+chr(30)+lc_aOs[i][2]
		lc_oF.puts(lc_sRiga)
	next

	lc_oF.close()
	release object lc_oF
	lc_oF = NULL
	
	return
	
// Cosa fa				:				Importa il file contenente la traduzione delle righe e salva il contenuto nella tabella Traduzioni
// pr_sPath				:				stringa, percorso del file da importare.
// pr_sLingua			:				stringa, sigla della lingua da importare. Es: EN
// N.B.					:				Il file importato dovrà rispettare il seguente formato:
//											IT+carattere separatore (chr 30)+stringa originale+carattere separatore (chr 30)+Hash -> Questa riga sarà scartata
//											EN+carattere separatore (chr 30)+stringa tradotta+carattere separatore (chr 30)+Hash
function importFileTraduzioni(pr_sPath,pr_sLingua)
	local lc_sPath,lc_sLingua,lc_oF,lc_sRiga

	lc_sPath = pr_sPath
	lc_sLingua = pr_sLingua
	
	lc_oFile = new file()
	
	if file(lc_sPath)
		lc_oF.open(lc_sPath)
	else
		msgbox("File inesistente","File inesistente",16)
		return
	endif
	
	do while not(lc_oF.eof())
		// Faccio un gets per estrarre la riga originale (da scartare), poi faccio il gets della riga che mi interessa
		lc_oF.gets()
		lc_sRiga = lc_oF.gets()
		
		lc_aRiga = split(lc_sRiga,chr(30))
	enddo
	
	return