--[[
Kleine Dioramaanlage von DH1 mit Lua-Steuerung der Fahrstra�en, der Zugzielanzeige und der T�ren an den Z�gen.
Quelle:
https://www.eepforum.de/filebase/file/2248-kleine-dioramaanlage-mit-lua-steuerung-der-fahrstra%C3%9Fen-der-zza-und-der-t%C3%BCren-an/

Der Bahnhof ist an den Bahnhof Hersbruck bei N�rnberg angelehnt.
Das Steckennetz, das als Grundlage f�r die Routen dient, ist z.B. hier zu finden:
https://bahnland-bayern.de/files/media/bahnland-bayern/service/streckennetz/beg_streckennetz.pdf 



Mit dem Start/Stop-Signal wird der Fahrbetrieb gestartet. Nach 'Stop' fahren die Z�ge und Fahrzeuge wieder in die Depots.

Die Zugzielanzeigetafeln, Modell ZZA6CDB2 aus Set V15NDB20015, und die Bahnsteigschilder aus dem gleichen Set werden unbedingt ben�tigt.

Die Stra�en k�nnen mit dem Tauschmanager durch anderen Einspurstra�en aus dem Grundbestand, z.B. "Einweg Asphaltstrasse Gehweg ohne", ersetzt werden.

Statt den Ampeln aus dem Set V13NDH10051 oder V13NDH10053 kann auch die mehrbegriffige Baustellenampel aus dem Set V100NDH1F065 (aus der Filebase) verwendet werden.
https://www.eepforum.de/filebase/file/334-dh1-kleines-set-mit-gehwegabschl%C3%BCssen-und-einer-baustellenampel/
Die KFZ-Ampel wird dann in den Objekteigenschaften nach rechts (-2.75) und unten (-0.78) versetzt, so dass der Fu� unter dem Gehsteig verschwindet.
Die Fu�g�nger-Ampel kann ebenfalls durch die Baustellenampel ersetzt und geeignet versteckt werden. 

Die Z�ge in den Depots k�nnen durch andere Z�ge mit geeigneter Routenzuordnung ersetzt oder erg�nzt werden. Damit die T�ren automatisch bet�tigt werden k�nnen m�ssen die Achsgruppen zugeordnet werden: 1 geschlossen, 2 links offen, 3 rechts offen (Bahnsteigseite) .




Ein paar Dinge, dir Ihr noch wissen solltet:

Die Z�ge aus den Depots 1 (West) und 2 (Ost) werden gleichzeitig alle 2:30 Minuten abgerufen.
Wenn Ihr die Frequenz �ndern m�chtet, dann k�nnt Ihr das bei stehender Anlage tun, indem Ihr im Anlagenscript den Wert 750 ver�ndert:
local ZugAbstand = 750

Ich empfehle aber, die Zeit nicht zu sehr zu verk�rzen.

Die Z�ge fahren dann entweder aus Osten oder aus Westen auf den Bahnhof zu und werden aufgrund ihrer Route in das vorgegebene Gleis gesteuert.



Im Script "ZZA_Diorama.lua" ist in Tabelle "Routen" angegeben in welches Gleis der jeweilige Zug fahren soll.
Ihr seht z.B., dass aus Westen die Routen RB_30 und RE_40 auf das Gleis 1 fahren.
Hier w�rde ich auch nichts ver�ndern da solche �nderungen weitergehende �nderungen in den Scripten nach sich ziehen.

Die Zugnummern, Zwischenziele, Ziele und die Info (Laufschrift) k�nnen dagegen frei ge�ndert werden.



Was Ihr ver�ndern k�nnt sind die beiden Zeilen am Anfang des Scripts "ZZA_Diorama.lua":

-- Zeitmultiplikator f�r Folgez�ge im ZZA
local ZZATimer = 2	-- Der Wert der hier steht wird verwendet um die Berechnung der Zeit f�r den n�chsten Zug durchzuf�hren
local Ankanz = 2	-- Der hier eingestellte Wert wird bei der Anzeige der Zeit im ZZA hinzu addiert (kann je nach Streckenl�nge variieren

Wenn der Wert ZZATimer ver�ndert wird dann wird im entsprechenden Zugzielanzeiger eine andere Abfahrtszeit f�r den ersten Zug angezeigt. 
Es entspricht in etwa der Zeit die der Zug vom Depot bis zur Einfahrt in den Bahnhof ben�tigt.

Der Wert Ankanz dient als Multiplikator, um die Zeiten f�r die Folgez�ge zu berechnen.

Es wird im jeweiligen Depot gepr�ft, ob dort noch weitere Z�ge f�r das gleiche Bahnhofsgleis auf wartend stehen 
und an wievielter Stelle sie sich befinden. Die ermittelte Position wird dann mit dem Wert Ankanz multipliziert 
und im ZZA als Abfahrtszeit des / der Folgez�ge angezeigt.

Bitte verwendet f�r beide Werte nur ganzzahlige Werte ohne Nachkommastellen.

Beispiel:

Ihr gebt bei ZZATimer eine 1 ein. Der Zug braucht 2 Minuten bis zum Bahnhof. 
In der Zugzielanzeige wird aber die EEP-Zeit vom Einschalten der Anzeige + 1 Minute angezeigt. 
Das schafft der Zug nicht und es wird mit gro�er Wahrscheinlichkeit eine Laufschrift angezeigt dass der Zug versp�tet abfahren wird.

Tragt Ihr stattdessen eine 3 ein, dann wird die EEP-Zeit + 3 Minuten in der ZZA angezeigt. 
Der Zug bleibt also l�nger am Bahnsteig stehen denn die angezeigte Abfahrtszeit wird eingehalten. 

Bitte beachtet, dass das Ganze nur korrekt funktioniert wenn in den beiden Depots in den Einstellungen der Haken f�r 'zuf�llig' nicht gesetzt ist.



Erweiterte Protokollanzeige: 
Wenn die globale Variable 'log' auf true (statt false) gesetzt wird, dann werden 
weitere Protokolle im Ereignisfenster angezeigt  und der Status der Zielzuganzeigen 
und der Ampeln wird als Tipp-Text sichtbar gemacht.  
--]]
log = log or false

-------------------------- Hilfsfunktionen zur Analyse der Skripte

-- Protokollausgabe bei Speicher-Funktionen

--[[
_EEPSaveData = EEPSaveData														-- Speichere die Original-Funktion
function EEPSaveData ( Slot, Text )
	local ok = _EEPSaveData( Slot, Text )										-- Original-Funktion aufrufen
	if log then 																-- Protokoll ausgeben
		local info = debug.getinfo(2, "nSl") 									-- siehe https://www.lua.org/pil/23.1.html
		print(string.format("%s %d %s: %s (%s): ", info.short_src, info.currentline, info.name, "EEPSaveData", tostring(ok))
			, string.format("[%d] = '%s'", Slot, Text) 
		)
	end
	return ok																	-- R�ckgabewert der Original-Funktion liefern
end
_EEPLoadData = EEPLoadData														-- Speichere die Original-Funktion
function EEPLoadData ( Slot )									
	local ok, Text = _EEPLoadData( Slot )										-- Original-Funktion aufrufen
	if log then 																-- Protokoll ausgeben
		local info = debug.getinfo(2, "nSl") 									-- siehe https://www.lua.org/pil/23.1.html
		print(string.format("%s %d %s: %s (%s): ", info.short_src, info.currentline, info.name, "EEPLoadData", tostring(ok))
			, string.format("[%d] : '%s'", Slot, Text) 
		) 
	end
	return ok, Text																-- R�ckgabewert der Original-Funktion liefern
end
--]]

-- Protokollausgabe bei TagText-Funktionen

--[[
_EEPStructureSetTagText = EEPStructureSetTagText								-- Speichere die Original-Funktion
function EEPStructureSetTagText ( Structure, Text )
	local ok = _EEPStructureSetTagText( Structure, Text )						-- Original-Funktion aufrufen
	if log then 																-- Protokoll ausgeben
		local info = debug.getinfo(2, "nSl") 									-- siehe https://www.lua.org/pil/23.1.html
		print(string.format("%s %d %s: %s (%s): ", info.short_src, info.currentline, info.name, "EEPStructureSetTagText", tostring(ok))
			, string.format("['%s'] = '%s'", Structure, Text) 
		) 
	end
	return ok																	-- R�ckgabewert der Original-Funktion liefern
end
_EEPStructureGetTagText = EEPStructureGetTagText								-- Speichere die Original-Funktion
function EEPStructureGetTagText ( Structure )									
	local ok, Text = _EEPStructureGetTagText( Structure )						-- Original-Funktion aufrufen
	if log then 																-- Protokoll ausgeben
		local info = debug.getinfo(2, "nSl") 									-- siehe https://www.lua.org/pil/23.1.html
		print(string.format("%s %d %s: %s (%s): ", info.short_src, info.currentline, info.name, "EEPStructureGetTagText", tostring(ok))
			, string.format("['%s'] : '%s'", Structure, Text) 
		) 
	end
	return ok, Text																-- R�ckgabewert der Original-Funktion liefern
end
--]]

-- Protokollausgabe bei InfoStructure-Funktionen

--[[
local _EEPChangeInfoStructure = EEPChangeInfoStructure
local function EEPChangeInfoStructure ( Structure, Text ) 
	-- Tipp-Text anzeigen
	local ok = _EEPChangeInfoStructure( Structure, Text )
	--if not ok then print( "ERROR: EEPChangeInfoStructure( '"..Structure.."' ) "..tostring(ok) .. "\n" .. debug.traceback() ) end
	
	if log then 																-- Protokoll ausgeben
		local info = debug.getinfo(2, "nSl") 									-- siehe https://www.lua.org/pil/23.1.html
		print(string.format("%s %d %s: %s (%s): ", info.short_src, info.currentline, info.name, "EEPChangeInfoStructure", tostring(ok))
			, string.format("['%s'] : '%s'", Structure, Text) 
		) 
	end
	
	-- Info aktivieren /deaktivieren
	if Text and Text ~= "" then
		ok = EEPShowInfoStructure( Structure, true )
	else
		ok = EEPShowInfoStructure( Structure, false )
	end
	--if not ok then print( "ERROR: EEPShowInfoStructure( '"..Structure.."' ) "..tostring(ok) ) end
end
--]]

-------------------------- Beginn des Skripts

I = 0
clearlog()
print("Willkommen auf meinem kleinen Diorama mit Zielzuganzeigen (DH1)\nEEP Version: ",EEPVer,"\n")

if log then print("Script 'ZZA_Demo' Version 1.2 wird geladen") end

require ("ZZA_Diorama\\ZZA_Diorama")
require ("ZZA_Diorama\\Fahrstrassen_Diorama")
require ("ZZA_Diorama\\Steuerung_Diorama")
require ("ZZA_Diorama\\Steuerung_Strassen")

local ZugAbstand = 750									-- Alle 750/5 Sekunden = 2:30 Minuten verl�sst ein Zug das Depot

-------------------------- Startsignal registrieren

local StartSignal = 52
EEPRegisterSignal(StartSignal)							-- Signal registrieren
_ENV["EEPOnSignal_"..StartSignal] = function(Stellung) 	-- Callback erzeugen (dynamisch statt einfach "function EEPOnSignal_52(Stellung)" )
	if Stellung == 1 then 								-- Wenn das Signal auf Fahrt gestellt wurde
		if I < ZugAbstand then 							-- und bislang noch wenig Zeit vergangen ist
			I = ZugAbstand - 25 						-- dann auf sp�teren Zeitpunkt springen damit Z�ge schneller das Depot verlassen
		end
	end
end

-------------------------- EEPMain

function EEPMain()
    I = I + 1

	abzweigkontrolle()					-- Abbiegen an Kreuzungen und Einfahrt in Kreisverkehr regeln
	
	FS_mit_Slot()						-- Schaltung der Fahrstrassen
	bue1zu()							-- Schranke schlie�en wenn notwendig

	if I % 300 == 0 then 				-- Jede Minute
		infotext()						-- Infofeld in der ZZA aktualisieren
		strassenlampen()				-- Stadtlampen einstellen
	end

	if EEPGetSignal(StartSignal) == 1 then
		if I % ZugAbstand == 0 then		-- Alle 750/5 Sekunden = 2:30 Minuten verl�sst ein Zug das Depot
			prfDept1()					-- Depot 1 West
			prfDept2()					-- Depot 2 Ost
		end

		if I % 75 == 0 then 			-- Alle 75/5 = 15 Sekunden verl�sst ein Auto ein Depot
			EEPSetSignal(181, 1) 		-- Stra�endepot 3 Ost			
			EEPSetSignal(194, 1)		-- Stra�endepot 4 Nord
			EEPSetSignal(195, 1)		-- Stra�endepot 5 S�d

		elseif I % 75 == 30 then		-- Kurz danach wird das Signal wieder auf 'Halt' gestellt
			EEPSetSignal(181, 2)		-- Stra�endepot 3 Ost		
			EEPSetSignal(194, 2)		-- Stra�endepot 4 Nord
			EEPSetSignal(195, 2)		-- Stra�endepot 5 S�d
		end
	end

	if I % 5 == 0 then 					-- Jede Sekunde
		kr_ampel()						-- Ampeln schalten
	end

	-- Zur Anlalyse des Skriptes: Nach den ersten Durchlauf werden die globalen Variablen und Funktionen angezeigt
	-- Quelle: https://github.com/FrankBuchholz/EEP/blob/master/ShowGlobalVariables.lua
	--if log and I == 1 then require("ShowGlobalVariables")() end

    return 1
end
