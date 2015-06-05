// Traduce il PI!!!!!

shell(true,true)
clear

set procedure to translate.prg additive
set procedure to api.prg additive

local lc_args,_i,lc_parola

if argcount()>0
   lc_args=new array()
   for _i=1 to argcount()
      lc_args.Add(argvector(_i))
   next

   lc_sPath=lc_args[1]
	pb_sSiglaLingua = lc_args[2]
	
   release object lc_args
   lc_args=NULL

	_PATH_TO_SCAN = lc_sPath
else
	pb_sSiglaLingua = ''
	_PATH_TO_SCAN = 'H:\Project Invoice\'
endif

//#define _PATH_TO_SCAN	"H:\Project Invoice\"
//#define _PATH_TO_SCAN	".\"
// deve essere sempre minuscolo
#define _File_Exclude	"backup"

///////////////////////////////////////

clear

local lc_array,lc_dir,lc_files

public lc_aext,pb_oTrad,pb_oF,pb_oFTradotto

lc_aext=new array()

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
lc_aext.add("pop")
//lc_aext.add("sql")

lc_aext.Sort()

pb_oTrad = new Traduzioni()
pb_oF = new File()
pb_oFTradotto = new File()

AttraversaDir(_PATH_TO_SCAN)


pb_oFTradotto.close()
release object pb_oFTradotto
pb_oFTradotto = NULL

release object pb_oF
pb_oF = NULL

pb_oTrad.releaseConnection()
release object pb_oTrad
pb_oTrad = NULL

release object lc_aext
lc_aext=NULL

return


function AttraversaDir(pr_dir)
	local lc_dir,lc_olddir,i,lc_fine,lc_file,lc_ext,lc_newdir,lc_buffer,lc_adir,lc_sFileDest,lc_nTradLen,lc_bTradotta

   lc_dir=pr_dir

   lc_olddir=set("DIRECTORY")

   private pv_dir

   pv_dir="'"+lc_dir+"'"

	SET DIRECTORY TO &pv_dir.

   lc_adir=new array()
   lc_adir.Dir("*.*","D")

   lc_fine=lc_adir.Size/5
   for i=1 to lc_fine
//   	? lc_adir[i,1], lc_adir[i,5]

   	if lc_adir[i,5]=="....D" 
      	lc_newdir=lc_adir[i,1]
			
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
				
				lc_filePath = SET("DIRECTORY")+"\"+lc_adir[i,1]
				// Cosa fa				:			Estrae tutte le traduzioni e le righe originali delle righe tradotte basandosi sul percorso del file
				// pr_sFile				:			stringa, percorso del file (sFile nella tabella outputstrings). Es: C:\Programmi\prova.txt
				// pr_sSiglaLingua	:			stringa, sigla della lingua della quale estrarre le traduzioni. Es: EN
				// Ritorna				:			lc_aRet -> array, così composto:
				//											[1] =>
				//												[1] => Riga originale (sRiga nella tabella outputstrings)
				//												[2] => Riga tradotta (sTraduzione nella tabella Traduzioni)

				lc_aTraduzioni = pb_oTrad.getTraduzioni(lc_filePath,pb_sSiglaLingua)
				
				lc_nTradLen = ALEN(lc_aTraduzioni)
				// Il percorso e il nome del file saranno dati dal percorso corrente, dal nome del file e dalla sigla della lingua
				// Es: H:\Project Invoice\api.prg_EN
				lc_sFileDest = lc_filePath+"_"+pb_sSiglaLingua
				
				// Se non ho estratto nulla, salvo il file così com'è e continuo con il prossimo
				if lc_nTradLen <= 0
					// Copio il file nella cartella di destinazione
					pb_oF.copy(lc_filePath,lc_sFileDest)
					loop
				endif
				
				// Apro il file
				pb_oF.open(lc_filePath)
				
				// Creo il nuovo file nel quale adranno eventuali righe tradotte
				try
					pb_oFTradotto.create(lc_sFileDest,"W")
				catch(Exception e)
					? "Errore durante la creazione del file: "+lc_sFileDest
					loop
				endtry
				
				// Scansiono il file riga per riga per controllare se ci sono delle righe da tradurre
				? "Sto traducendo il file "+lc_filePath+" ..."
				do while not(pb_oF.eof())
					// Estraggo la riga dal file
					lc_sRow = pb_oF.gets()
					lc_bTradotta = False
					
					// Scansiono l'array delle traduzioni (nel primo elemento) per cercare una corrispondenza della riga
					// e nel caso tradurre la riga. Nel caso non esista una traduzione per la riga, la salvo così come è
					for i21 = 1 to lc_nTradLen
						// Se la riga del file sorgente è presente nell'array delle traduzioni...
						if lc_sRow == lc_aTraduzioni[i21][1]
							// ... La traduco
							lc_sTraduzione = lc_aTraduzioni[i21][2]
							pb_oFTradotto.puts(lc_sTraduzione)
							lc_bTradotta = True
							exit
						endif
					next
					
					// Se non è una riga da tradurre (=già tradotta sopra) la salvo così com'è
					if not(lc_bTradotta)
						pb_oFTradotto.puts(lc_sRow)
						lc_bTradotta = False
					endif
				
				enddo
				
				pb_oFTradotto.close()
				
				// Chiudo il file
				pb_oF.close()
				
				// Rinomino i file
				? "Sto eliminando il vecchio file"
				pb_oF.delete(lc_filePath)
				
				? "Sto rinominando il file..."
				pb_oFTradotto.rename(lc_sFileDest,lc_filePath)

			endif
      endif
   next

   release object lc_adir
   lc_adir=NULL

   pv_dir="'"+lc_olddir+"'"
   SET DIRECTORY TO &pv_dir.
	return