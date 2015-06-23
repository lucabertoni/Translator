import common

class Translator():
	"""
		Classe che gestisce il traduttore
	"""
	def __init__(self):
		pass

	def translateString(self,sString):
		"""
			Cosa fa			:			Estrapola la traduzione di una stringa dal db
			sString			:			stringa, testo del quale estrapolare la traduzione
			Ritorna			:			sRet -> stringa, traduzione della stringa se trovata in db,
										oppure la stringa stessa
		"""
		pass

	def translate(self,sPath,lExt):
		"""
			Cosa fa			:			Sostituisce ogni stringa presente nei codici sorgenti con translateString("stringa")
			sPath			:			stringa, percorso della cartella che contiene i sorgenti
			lExt			:			lista, lista delle estensioni dei file da analizzare
		"""
		
		# Estraggo la lista dei file presenti nella cartella che hanno come estensione .xxx
		lFiles = getFolderContent(sPath)