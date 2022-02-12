--[[Beispiel-Parameter, die im Hauptskript stehen sollten
		FmS_Tabelle = {
		[15] = {FmS_Slot = 125,FmS_Route = {"Alle","Gleis 1","Gleis 2","Gleis 3","Gleis 4"}, 
		FmS_FW ={{4,3,2,1},{1},{2},{3},{4}}Ausgabe = "Text", m = true},
						}

 Die Parameter setzen sich wie folgt zusammen:
 [15]        >> Die Fahrstrassen-ID
 FmS_Slot	 >> Der zu prüfende Slot
 FmS_Route  >> Die Routen, für die die Fahrstrasse gelten sollen. Mindestens eine Route muss dort stehen, notfalls "Alle".
 FmS_FW     >> Die Fahrwege der Fahrstrasse, wobei der bevorzugte Fahrweg stehts am Ende stehen muss.
 
 Die Zuordnung ist so, dass die ersten Fahrwege zu der erstgenannten Route gehören, die zweiten Fahrwege zur 2. Route, usw.
 Im obrigen Beispiel der Fahrstrasse 15 gehören also die Fahrwege {4,3,2,1} zur Route Alle,
                                                                       {1} zur Route Gleis 1
																	   {2} zur Route Gleis 2 usw.

 Besonderheit!!
 Man kann die Fahrstrassen frühstens nach einer bestimmten Zeit stellen lassen.
 Soll also zum Beispiel im Bahnhof der Zug erst 60 Sekunden stehen, bevor die Fahrstrasse gestellt werden soll,
 kann man das mit einer Minus-Zahl vor dem ersten Fahrweg angeben.
 Siehe dazu auch das 2. Beispiel weiter hinten {-60,1}
 Der Zug wartet also mindestens 60 Sekunden.
-- Ab hier nichts verändern!
]]

FmS_Dauer = {}
------------------------------------ Fahrstrassentabelle
FmS_Tabelle = {
	[28] = {FmS_Slot = 1,FmS_Route = {"RB_30","RB_30_1","RE_32","RE_40","Gueter"}, FmS_FW = {{3},{1},{1},{3},{2}},
	Ausgabe = "Einfahrt West in den Bahnhof", m = true},
	[22] = {FmS_Slot = 2,FmS_Route = {"RB_30","RE_41"}, FmS_FW = {{-45,1},{-45,1}},
	Ausgabe = "Ausfahrt West Gleis 6", m = true},
	[26] = {FmS_Slot = 3,FmS_Route = {"Gueter"}, FmS_FW = {{1}},
	Ausgabe = "Ausfahrt West Gleis 4", m = true},
	[27] = {FmS_Slot = 4,FmS_Route = {"RE_40","RE_47"}, FmS_FW = {{-45,1},{-45,1}},
	Ausgabe = "Ausfahrt West Gleis 2", m = true},
	[39] = {FmS_Slot = 5,FmS_Route = {"RB_30","RE_40"}, FmS_FW = {{-45,1},{-45,1}},
	Ausgabe = "Ausfahrt Ost Gleis 1", m = true},
	[38] = {FmS_Slot = 6,FmS_Route = {"Gueter"}, FmS_FW = {{1}},
	Ausgabe = "Ausfahrt Ost Gleis 3", m = true},
	[37] = {FmS_Slot = 7,FmS_Route = {"RB_30_1","RE_32"}, FmS_FW = {{-45,1},{-45,1}},
	Ausgabe = "Ausfahrt Ost Gleis 5", m = true},
	[44] = {FmS_Slot = 8,FmS_Route = {"RB_30","RB_30_1","RE_32","RE_40"}, FmS_FW = {{1},{1},{1},{1}},
	Ausgabe = "Einfahrt Depot R-Züge", m = true},
	[45] = {FmS_Slot = 9,FmS_Route = {"Gueter"}, FmS_FW = {{1}},
	Ausgabe = "Einfahrt Depot Güter", m = true},
	[47] = {FmS_Slot = 10,FmS_Route = {"RB_30","RE_40","RE_41","RE_47"}, FmS_FW = {{1},{2},{1},{2}},
	Ausgabe = "Einfahrt Ost Gleise 2 und 6", m = true},	
	[48] = {FmS_Slot = 11,FmS_Route = {"Gueter"}, FmS_FW = {{1}},
	Ausgabe = "Einfahrt Ost Gleis 4 ", m = true},																													--Wenn Zahl - dann Wartezeit
 }
----------------------------------- Ende Fahrstrassentabelle
----------------------------------- Steuerung für Schaltung der Fahrstrassen
function FS_mit_Slot()

	for FmS_k,FmS_v in pairs(FmS_Tabelle) do										-- Schleife durch die Tabelle FmS_Tabelle
		if select(2,EEPLoadData(FmS_Tabelle[FmS_k].FmS_Slot))then					-- wenn der Slot einen Wert hat
			Z_Name = select(2,EEPLoadData(FmS_Tabelle[FmS_k].FmS_Slot))				-- Name aus dem Slot lesen
			FmS_Z_Route = select(2,EEPGetTrainRoute(Z_Name))						-- Route aus Name 
			for FmS_R = 1,#FmS_Tabelle[FmS_k].FmS_Route do							-- alle Route im Tabellenfeld prüfen
				if FmS_Tabelle[FmS_k].FmS_Route[FmS_R] == FmS_Z_Route then			-- wenn Ãœbereinstimmung
					for FmS_Fahrweg = 1,#FmS_Tabelle[FmS_k].FmS_FW[FmS_R] do		-- Schleife durch alle Fahrwege der Route
-- prüfen auf Wartezeit					
						if FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg] <= 0 and FmS_Dauer[FmS_k] == nil then 			-- wenn Wert kleiner 0 und Wartezeit ist 0
							if FmS_k == 39 then																			-- wenn FS an Gleis 1
								Halt = select(2,EEPStructureGetTagText("#101"))											-- In ZZA eingetragene Zeit lesen
								if Halt ~= "" and Halt ~= nil and Halt ~= "leer" then									-- wenn schon Zeit im ZZA 
									Anzwert = tonumber(string.sub(Halt,1,2))*3600 + tonumber(string.sub(Halt,4,5))*60	-- in Sekunden seit 0 Uhr umrechnen
									if Anzwert - EEPTime > 45 then														-- mit EEP Zeit vergleichen und wenn > 45
										print("Aufenthalt an Gleis 1 = ", Anzwert - EEPTime, " Sekunden.")
										FmS_Dauer[FmS_k] = Anzwert 														-- die Aufenhaltsdauer setzen
									else
										FmS_Dauer[FmS_k] = EEPTime + (FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg]*-1)	-- Wartezeit zu EEP-Zeit addieren
									end
								end
							elseif FmS_k == 27 then																		-- wenn FS an Gleis 2
								Halt = select(2,EEPStructureGetTagText("#106"))											-- In ZZA eingetragene Zeit lesen
								if Halt ~= "" and Halt ~= nil and Halt ~= "leer" then									-- wenn schon Zeit im ZZA 
									Anzwert = tonumber(string.sub(Halt,1,2))*3600 + tonumber(string.sub(Halt,4,5))*60
									if Anzwert - EEPTime > 45 then
										print("Aufenthalt an Gleis 2 = ", Anzwert - EEPTime, " Sekunden.")
										FmS_Dauer[FmS_k] = Anzwert 
									else
										FmS_Dauer[FmS_k] = EEPTime + (FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg]*-1)	-- Wartezeit zu EEP-Zeit addieren
									end
								end
							elseif FmS_k == 37 then																		-- wenn FS an Gleis 5
								Halt = select(2,EEPStructureGetTagText("#115"))											-- In ZZA eingetragene Zeit lesen
								if Halt ~= "" and Halt ~= nil and Halt ~= "leer" then									-- wenn schon Zeit im ZZA 
									Anzwert = tonumber(string.sub(Halt,1,2))*3600 + tonumber(string.sub(Halt,4,5))*60
									if Anzwert - EEPTime > 45 then
										print("Aufenthalt an Gleis 5 = ", Anzwert - EEPTime, " Sekunden.")
										FmS_Dauer[FmS_k] = Anzwert 
									else
										FmS_Dauer[FmS_k] = EEPTime + (FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg]*-1)	-- Wartezeit zu EEP-Zeit addieren
									end
								end
							elseif FmS_k == 22 then																		-- wenn FS an Gleis 6
								Halt = select(2,EEPStructureGetTagText("#122"))											-- In ZZA eingetragene Zeit lesen
								if Halt ~= "" and Halt ~= nil and Halt ~= "leer" then									-- wenn schon Zeit im ZZA 
									Anzwert = tonumber(string.sub(Halt,1,2))*3600 + tonumber(string.sub(Halt,4,5))*60
									if Anzwert - EEPTime > 45 then
										print("Aufenthalt an Gleis 6 = ", Anzwert - EEPTime, " Sekunden.")
										FmS_Dauer[FmS_k] = Anzwert 
									else
										FmS_Dauer[FmS_k] = EEPTime + (FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg]*-1)	-- Wartezeit zu EEP-Zeit addieren
									end
								end
							end
						elseif FmS_Dauer[FmS_k]~= nil and EEPTime < FmS_Dauer[FmS_k] and FmS_Dauer[FmS_k] - EEPTime < 10 and FmS_Dauer[FmS_k] - EEPTime > 7 then
						-- sonst wenn eine Wartezeit gespeichert ist die kleiner > als die EEPZeit und die Differenz kleiner als 10 und größer 7
							if FmS_k == 39 then										-- wenn die Fahrstraße 39ist
								tuerzu_1()											-- Funktion für das Schliessen der Türen an Gleis 1 aufrufen
							elseif FmS_k == 27 then									-- sonst für Fahrstraße 27 
								tuerzu_2()											-- Funktion für das Schliessen der Türen an Gleis 2 aufrufen
							elseif FmS_k == 37 then									-- sonst für Fahrstraße 37
								tuerzu_5()											-- Funktion für das Schliessen der Türen an Gleis 5 aufrufen
							elseif FmS_k == 22 then									-- sonst für Fahrstraße 22
								tuerzu_6()											-- Funktion für das Schliessen der Türen an Gleis 6 aufrufen
							end
						elseif FmS_Dauer[FmS_k]~= nil and EEPTime >= FmS_Dauer[FmS_k] then				-- sonst wenn Wartezeit ungleich 0 und EEP Zeit grösser
							if FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg] > 0 then					-- wenn der Fahrstrassenwert > 0 
								EEPSetSignal(FmS_k,FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg]+1,1)	-- Fahrstrasse schalten
							end
-- Ende der Wartezeitprüfung							
						elseif FmS_Dauer[FmS_k] == nil then												-- sonst wenn Wartezeit 0 
							EEPSetSignal(FmS_k,FmS_Tabelle[FmS_k].FmS_FW[FmS_R][FmS_Fahrweg]+1,1)		-- Fahrstrasse schalten
						end
					end
				end
			end
		end
	end
end
function auflosenost()
	EEPSetSignal(37,1,1)
	EEPSetSignal(39,1,1)
end
function auflosenwest()
	EEPSetSignal(22,1,1)
	EEPSetSignal(26,1,1)
	EEPSetSignal(27,1,1)
end

print("Script Fahrstrassen_Hersbruck Version 1.1 wurde eingebunden")
