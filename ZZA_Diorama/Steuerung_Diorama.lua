--[[
Lua-Aufrufe in Kontakten (Ermittelt über https://frankbuchholz.github.io/EEP_convert_anl3_file/EEP_Inventar.html ):

anmelden_1		Eisenbahn 5		
anmelden_2		Eisenbahn 64	
anmelden_3		Eisenbahn 111	
anmelden_4		Eisenbahn 81	
anmelden_5		Eisenbahn 96	
anmelden_6		Eisenbahn 41	
anmelden_7		Eisenbahn 92	
anmelden_8		Eisenbahn 252	
anmelden_9		Eisenbahn 204	
anmelden_10		Eisenbahn 207	
anmelden_11		Eisenbahn 142	

slotmin_100		Eisenbahn 31	
slotmin_100		Eisenbahn 32	

prfDept1		Eisenbahn 41	
prfDept2		Eisenbahn 100	

ZZ_West			Eisenbahn 5 und Eisenbahn 32
ZZ_Ost			Eisenbahn 103 und Eisenbahn 251

Aufruf in EEPMain:

prfDept1
prfDept2
infotext

--]]

if log then print("Script 'Steuerung_Diorama' Version 1.2 wird geladen") end

-- Initialisierung: Aufruf in mehreren Kontakten
for k = 1, 99 do
	_ENV["anmelden_"..k] = function (Zugname) -- anmelden_1, ... anmelden_100
		EEPSaveData( k, Zugname )
	end
end

----------------------------------- Hilfsfunktion zur Zeitumrechnung

local function zeitanzeige()
	return string.format("%02d:%02d:%02d ", EEPTimeH, EEPTimeM, EEPTimeS)
end

----------------------------------- Initialisierung: Fahrstrassensignale aus Tabelle registrieren und callback erzeugen
for Signal, Fahrstrasse in pairs (FmS_Tabelle) do
	EEPRegisterSignal( Signal )								-- jeweiliges Signal registrieren
	
	_ENV["EEPOnSignal_"..Signal] = function (Stellung)		-- Callback erzeugen
		if Stellung > 1 then								-- wenn eine Fahrstraße geschaltet wird
			EEPSaveData( Fahrstrasse.Slot, false )			-- Datenslot "löschen"
			Fahrstrasse.Dauer = nil							-- Wert für Dauer "löschen"
			if Fahrstrasse.StatusZeitanzeige ~= true then	-- wenn der Marker für Ausgabe noch nicht eingeschaltet ist									 
				print(zeitanzeige(), Fahrstrasse.Ausgabe)	-- Meldung ausgeben
				Fahrstrasse.StatusZeitanzeige = true		-- Marker für erfolgte Ausgabe einschalten
			end
			
		elseif Stellung == 1 then							-- wenn die Fahrstraße aufgelöst wurde
			Fahrstrasse.StatusZeitanzeige = false			-- Marker für Ausgabe ausschalten
		end
	end
end

-------------------------- Ausgabe des Zugs, der ein Depot verlassen hat

-- Aufruf über Ereignis von EEP
function EEPOnTrainExitTrainyard (Depot, Zugname)
	if Depot == DepotWest or Depot == DepotOst then			-- Nur für Züge
		local ok, RouteId = EEPGetTrainRoute( Zugname )		-- RouteId aus Zugname ermitteln
		print(zeitanzeige(), "Der Zug '",Zugname,"' hat das Depot ",Depot," mit Route '",RouteId,"' verlassen")
	end
end 

----------------------------------- regelmäßige Depotprüfung

local function prfDepot (Depot)												-- Wenn ein wartender Zug im Depot ist dann auswerfen
	local Anzahl = EEPGetTrainyardItemsCount( Depot )						-- Anzahl der im Depot gemeldeten Züge ermitteln

	-- Protokoll
	if false and log then 
		local inFahrt = 0													-- Anzahl der fahrenden Züge, die im Deport gemeldet sind
		local wartend = 0													-- Anzahl der im Deport stehenden Züge
		for Position = 1, Anzahl do											-- Schleife durch die Zugliste in Depot
			local Zugname = EEPGetTrainyardItemName( Depot, Position )		-- Name des Zugs an der aktuellen Position ermitteln
			local Status = EEPGetTrainyardItemStatus( Depot, Zugname, 0 )	-- Prüfen des Status des aktuellen Zug in der Depotliste
			if Status == 0 then												-- wenn der Zug fährt 
				inFahrt = inFahrt + 1
			elseif Status == 1 then											-- wenn der Zug im Depot steht
				wartend = wartend + 1
			end
		end
		print("Im Depot ",Depot," sind ",Anzahl," Züge angemeldet (",inFahrt," in Fahrt, ",wartend," wartend)") 
	end
	
	-- Ersten wartenden Zug aus dem Depot schicken
	for Position = 1, Anzahl do												-- Schleife durch die Zugliste in Depot
		local Zugname = EEPGetTrainyardItemName( Depot, Position )			-- Name des Zugs an der aktuellen Position ermitteln
		local Status = EEPGetTrainyardItemStatus( Depot, Zugname, 0 )		-- Prüfen des Status des aktuellen Zug in der Depotliste
		if Status == 1 then													-- wenn der Zug im Depot steht
			EEPGetTrainFromTrainyard( Depot, "", Position )					-- Zug an der gefundenen Stelle aus dem Depot schicken
			break															-- Schleife nach erstem wartenden Zug verlassen
		end
	end
end

-- Aufruf in EEPMain					(Regelmäßig alle 2:30 Minuten)
-- Aufruf in Kontakt auf Eisenbahn 41 	(bei Einfahrt eines Güterzuges auf Gleis 3)
function prfDept1()							
	prfDepot( DepotWest )				-- wenn ein wartender Zug in Depot West ist, dann auswerfen				
end

-- Aufruf in EEPMain					(Regelmäßig alle 2:30 Minuten)
-- Aufruf in Kontakt auf Eisenbahn 100 	(bei Einfahrt eines Güterzuges auf Gleis 4)
function prfDept2()							
	prfDepot( DepotOst )				-- wenn ein wartender Zug in Depot Ost ist, dann auswerfen
end

----------------------------------- Depotprüfung

local function prfdep(Depot, Gleis)
	
	local AnzahlZuege = EEPGetTrainyardItemsCount( Depot )					-- Anzahl der Züge im Depot ermitteln
	if log then print("Depotprüfung für Depot ",Depot,": ",AnzahlZuege," Züge im Depot") end
	
	local FRoute1, DPos1 = "", 0											-- Variablen initialisieren
	local FRoute2, DPos2 = "", 0

	for Position = 1, AnzahlZuege do										-- Schleife durch die Zugliste im Depot
		local Zugname = EEPGetTrainyardItemName( Depot, Position )			-- Name des Zugs an der aktuellen Position ermitteln
		local ZugStatus = EEPGetTrainyardItemStatus( Depot, Zugname, 0 )	-- Prüfen des Status des aktuellen Zug in der Depotliste
		--print("Depot ",Depot," ",Position," Zugname ",Zugname," Status = ",ZugStatus)
		
		if ZugStatus == 1 then												-- wenn der Zug im Depot steht (wartend)							
			local ok, RouteId = EEPGetTrainRoute( Zugname )					-- die Route dieses Zugs ermitteln
			if RouteId ~= "Gueter" then 
				local fzgleis = Routen[Depot][RouteId].Gleis
				--print("Depot ",Depot," Folgezuggleis = ",fzgleis," Zielgleis = ",Gleis)
				
				if Gleis == fzgleis then									-- wenn das Gleis für den aktuellen Zug und das Gleis für den FZUG gleich sind
				
					if FRoute1 == "" then									-- wenn noch kein Folgezug gespeichert ist
						FRoute1 = RouteId									-- Route merken
						DPos1 = Position									-- die Position im Depot merken
						
					elseif FRoute1 ~= "" and FRoute2 == "" then				-- wenn schon Folgezug1 und kein Folgezug2
						FRoute2 = RouteId									-- Route merken
						DPos2 = Position									-- die Position im Depot merken
					end
				end
			end
			if FRoute2 ~= "" then											-- wenn eine  2. Route gefunden wurde
				break														-- Schleife verlassen
			elseif FRoute1 == "" then										-- sonst wenn keine 1 Route gefunden wurde
				DPos1 = 0													-- Einträge löschen
				FRoute2 = ""
				DPos2 = 0
			end
		end
	end
	
	if   ( DPos1 == 0    and DPos2 > 0 ) 									-- Wenn Depot 1 keinen Folgezug kennt 
	  or ( DPos1 > DPos2 and DPos2 > 0 )then 								-- oder die Listenposition in Depot 1 größer ist als die in Depot 2
		schreibeDaten (Gleis, nil, FRoute2, DPos2, FRoute1, DPos1)			-- dann tauschen (kommt nicht vor!?)
		if log then print("TAUSCHEN") end
	else	
		schreibeDaten (Gleis, nil, FRoute1, DPos1, FRoute2, DPos2)			-- sonst direkt schreiben
	end
	
	--if log then print("Ergebnis der Depotprüfung für Depot ",Depot,": FRoute1 ", FRoute1," DPos1 ",DPos1," FRoute2 ", FRoute2," DPos2 ",DPos2) end
end

-- Prüfe Folgeaktionen für Zug
local function ZugPruefung (Depot, Zugname)
	local ok, RouteId = EEPGetTrainRoute( Zugname )						-- RouteId aus Zugname ermitteln
	
	if RouteId ~= "Gueter" then 										-- wenn die RouteId nicht Gueter ist
		local Route = Routen[Depot][RouteId]
		local Gleis = Route.Gleis	
	
		local ok, ZZA_Tag = EEPStructureGetTagText( Zugzielanzeigetafeln[Gleis][1] )
		if ZZA_Tag == nil or ZZA_Tag == "" or ZZA_Tag == "leer" then	-- wenn ZZA leer ist
			prfdep( Depot, Gleis )										-- Funktion zum Prüfen auf Folgezüge im Depot aufrufen
		end
		
		ZZA_berechnen( Depot, RouteId )									-- Aufruf der Anzeigefunktion für Route
	end
end

-- Aufruf in Kontakt auf Eisenbahn 6 (Ausfahrt aus Depot West) und Eisenbahn 32 (Einfahrt in Bahnhof von West)
function ZZ_West (Zugname)	
	ZugPruefung( DepotWest, Zugname )
end

-- Aufruf in Kontakt auf Eisenbahn 251 (Ausfahrt aus Depot Ost) und Eisenbahn 103 (Einfahrt in Bahnhof von Ost)
-- Warum nicht auch auf Eisenbahn 123 (ebenfalls Einfahrt in Bahnhof von Ost)?
function ZZ_Ost (Zugname)													
	ZugPruefung( DepotOst, Zugname )
end

----------------------------------- Verspätungen anzeigen

local InfotextLaufschriftFeld = 33

-- Aufruf in EEPMain
function infotext()																	-- Verspätungen anzeigen
	for Gleis, Anzeigetafeln in pairs (Zugzielanzeigetafeln) do
		local Zeit = string.sub(select(2,EEPStructureGetTagText( Anzeigetafeln[1] )), 1, 5)	
		
		if Zeit ~= nil and Zeit ~= "" then											-- wenn bereits eine Zeit im ZZA angezeigt wird
			local akZeit = string.format("%02d:%02d", EEPTimeH, EEPTimeM)			-- aktuelle EEP Zeit in Variable schreiben
			if Zeit < akZeit then													-- wenn die Zeit in ZZA kleiner ist als die aktuelle Zeit 
				local minwert1 = tonumber(string.sub(Zeit, 4, 5))					-- Minutenwerte auslesen aus ZZA
				local minwert2 = EEPTimeM --tonumber(string.sub(akZeit, 4, 5))		-- Minutenwerte auslesen aus EEP Zeit

				if minwert2 < minwert1 then
					minwert2 = minwert2 + 60
				end
				local Verspaetung = minwert2 - minwert1								-- den Wert für Verspätung errechnen
				local InfoText = "--- Abfahrt voraussichtlich ".. math.floor(Verspaetung+0, 5) .. " Minute(n) später!!! ---" -- Infotext definieren
				for _, Anzeige in pairs(Anzeigetafeln) do
					EEPStructureSetTextureText(Anzeige, InfotextLaufschriftFeld, InfoText)	-- Infotext in ZZA anzeigen
				end
			end
		end
	end
end

----------------------------------- Türen schließen kurz vor der Abfahrt

local Haltesignale = {	-- Tabelle mit den Haltesignalen im Bahnhof für die Prüfung ob ein Zug gehalten wird
	-- [Gleis] = Signal
	[1] = 16, 
	[2] = 15, 
	[3] = 13, 
	[4] = 14, 
	[5] = 12, 
	[6] = 11,
}
function tuerzu (Gleis)
	--if log then print("Gleis ", Gleis, " tuerzu()") end
	
	local Signal = Haltesignale[Gleis]
	if EEPGetSignalTrainsCount( Signal ) > 0 then							-- prüfen ob am Signal ein Zug gehalten wird
		local Zugname = EEPGetSignalTrainName( Signal, 1 )					-- den Zugname ermitteln
		local AnzahlWagen = EEPGetRollingstockItemsCount( Zugname )			-- Anzahl der Fahrzeuge
		for Position = 0, AnzahlWagen - 1 do								-- Schleife durch die Anzahl der Fahrzeuge (Index beginnt bei 0!)
			local rmname = EEPGetRollingstockItemName( Zugname, Position )	-- den Name des Rollmaterials auslesen
			EEPRollingstockSetSlot( rmname, 1 )								-- Achsengruppe 1 bei allen Fahrzeugen einstellen (Türen zu)
		end
	end
end
