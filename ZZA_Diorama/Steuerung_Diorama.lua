----------------------------------- Zeitmultiplikator für Folgezüge im ZZA
ZZATimer = 2					-- Der Wert der hier steht wird im Script ZZA_Hersbruck verwendet um die Berechnung der Zeit für den nächsten Zug durchzuführen
Ankanz = 2						-- der hier eingestellte Wert wird bei der Anzeige der Zeit im ZZA hinzu addiert (kann je nach Streckenlänge variieren
----------------------------------- Anforderungen erzeugen
for dl = 1, 99 do
	_ENV["anmelden_"..dl] = function(zn) -- anmelden_1, ... anmelden_100
		EEPSaveData(dl,zn)
	end
end
for dl = 1,2 do
	EEPRegisterRoadTrack(dl)
end
function slotplus_100 () 
	slot100 = select(2,EEPLoadData(100))
	slot100 = slot100 + 1
	EEPSaveData(100,slot100)
end
function slotmin_100 () 
	slot100 = select(2,EEPLoadData(100))
	slot100 = slot100 - 1
	if slot100 <= 0 then
		slot100 = 0
		bue1auf()
	end
	EEPSaveData(100,slot100)
end
function bue1zu()
	buez = 0
	slot100 = select(2,EEPLoadData(100))
	if slot100 > 0 then
		for dl = 1,2 do
			buebes = select(2,EEPIsRoadTrackReserved(dl))
			if buebes == true then
				buez = buez + 1
			end
		end
		if buez == 0 then
			EEPSetSignal(55,2,1)
		end
	end
end
function bue1auf()
	EEPSetSignal(55,1,1)
end
EEPRegisterSignal(61)
function EEPOnSignal_61 (stellung)
	if stellung == 2 then 
		slotplus_100()
		EEPSetSignal(61,1)
	end
end
function zeitanzeige()
	print(string.format("%02d:%02d:%02d", EEPTimeH, EEPTimeM, EEPTimeS))
end

--------------------------------- Fahrstrassensignale aus Tabelle registrieren und callback erzeugen
for k,v in pairs (FmS_Tabelle) do
	EEPRegisterSignal(k)									-- jeweiliges Signal registrieren
	_ENV["EEPOnSignal_"..k] = function (stellung)			-- Callback erzeugen
		if stellung > 1 then								-- wenn eine Fahrstraße geschaltet wird
			EEPSaveData(FmS_Tabelle[k].FmS_Slot, false)		-- Datenslot "löschen"
			FmS_Dauer[k] = nil								-- Wert für Dauer "löschen"
			if FmS_Tabelle[k].m then						-- wenn der Marker für Ausgabe noch eingeschaltet ist									 
				zeitanzeige()
				print(FmS_Tabelle[k].Ausgabe)				-- Meldung ausgeben
				FmS_Tabelle[k].m = false					-- Marker für Ausgabe ausschalten
			end
		elseif stellung == 1 then							-- wenn die Fahrstraße aufgelöst wurde
			FmS_Tabelle[k].m = true							-- Marker für Ausgabe einschalten
		end
	end
end
-------------------------- Ausgabe des Zugs, der ein Depot verlassen hat
function EEPOnTrainExitTrainyard(Depot_ID, zn)
	zroute = select(2,EEPGetTrainRoute(zn))					-- Route aus Zugname ermitteln
	if Depot_ID == 1 or Depot_ID == 2 then
		zeitanzeige()
		print("Der Zug ",zn, " hat das Depot ",Depot_ID," verlassen!\nRoute = ",zroute)
	end
end 
-------------------------- Startsignal registrieren
EEPRegisterSignal(52)										-- Signal 56 registrieren
function EEPOnSignal_52(stellung)							-- Callback erzeugen
	if stellung == 1 then 									-- wenn das Signal auf Fahrt gestellt wurde
		if I < 750 then I = 725 end							-- und der Zähler kleiner als 450 ist, dann den Zähler auf 400 stellen
	end
end
---------------------------------------------prüfen ob Zu im Depot ist
function prfDept1()							-- wenn ein wartender Zug in Depot 1 ist dann auswerfen
	Depot_1 = EEPGetTrainyardItemsCount(1)						-- Anzahl der Züge im Depot 1 ermitteln
	--print("Das Depot 1 hält ",Depot_1," Züge")
	for dl = 1, Depot_1 do										-- Schleife durch die Zugliste in Depot 1
		Dep1Zname = EEPGetTrainyardItemName(1,dl)				-- Name des Zugs an der aktuellen Position ermitteln
		Dep1Status = EEPGetTrainyardItemStatus(1,Dep1Zname,0)	-- Prüfen des Status des aktuellen Zug in der Depotliste
		if Dep1Status == 1 then									-- wenn der Zug im Depot steht
			EEPGetTrainFromTrainyard(1, "", dl)					-- Zug an der gefundenen Stelle aus dem Depot schicken
			break												-- Schleife verlassen
		end
	end
end
function prfDept2()							-- wenn ein wartender Zug in Depot 2 ist dann auswerfen
	Depot_2 = EEPGetTrainyardItemsCount(2)						-- Anzahl der Züge im Depot 1 ermitteln
	--print("Das Depot 2 hält ",Depot_2," Züge")
	for dl = 1, Depot_2 do										-- Schleife durch die Zugliste in Depot 1
		Dep2Zname = EEPGetTrainyardItemName(2,dl)				-- Name des Zugs an der aktuellen Position ermitteln
		Dep2Status = EEPGetTrainyardItemStatus(2,Dep2Zname,0)	-- Prüfen des Status des aktuellen Zug in der Depotliste
		if Dep2Status == 1 then									-- wenn der Zug im Depot steht
			EEPGetTrainFromTrainyard(2, "", dl)					-- Zug an der gefundenen Stelle aus dem Depot schicken
			break												-- Schleife verlassen
		end
	end
end
for dl = 1,6 do
	if I < 5 and EEPGetSignal(52) == 2 then
		_ENV["zeit_Gl"..dl] = ""
		EEPSaveData(dl * 100 + 5,_ENV["zeit_Gl"..dl])
		_ENV["DPos_"..dl] = 0														-- Zwischenspeicher für Sortieren
		_ENV["FZUG_"..dl] = ""
		_ENV["FZUG1_"..dl] = ""	; EEPSaveData((100 * dl) + 1,	"")					-- Variable für Folgezug 1
		_ENV["DPos1_"..dl] = 0	; EEPSaveData((100 * dl) + 2,	0)	
		_ENV["FZUG2_"..dl] = ""	; EEPSaveData((100 * dl) + 3,	"")					-- Variable für Folgezug 2
		_ENV["DPos2_"..dl] = 0	; EEPSaveData((100 * dl) + 4,	0)
	end
end
sortgleis = 0
--RB_30  soll immer auf Gleis 1 einfahren.  Dieser kommt vom West-Depot und fährt in Richtung Ost-Depot.
--RB_30_1 soll immer auf Gleis 5 einfahren. Dieser kommt ebenfalls vom West-Depot und fährt in Richtung Ost-Depot.
--RB_30_2 soll immer auf Gleis 6 einfahren. Der Zug kommt vom Ost-Depot und fährt in Richtung West-Depot.
--------------------------------------------------------------------------------------------------------------------
routenzz = {"RB_30",	"RB_30_1",	"RE_32",	"RE_40",	"RE_41",	"RE_47"}
gleisewest = {1,			5,			5,			1,			0,			0} 
gleiseost = {6,				0,			0,			2,			6,			2} -- RB30 wird hier als RB_30_2 behandelt
--------------------------------------------------------------------------------------------------------------------
for z = 1,6 do 
	_ENV["Name_Ausg"..z] = function ()
		_ENV["FZUG1_"..z] = select(2,EEPLoadData((100 * z) + 1))	-- Werte aus den Slots lesen
		_ENV["DPos1_"..z] = select(2,EEPLoadData((100 * z) + 2))
		_ENV["FZUG2_"..z] = select(2,EEPLoadData((100 * z) + 3))
		_ENV["DPos2_"..z] = select(2,EEPLoadData((100 * z) + 4))
		_ENV["FZUG1_"..z] = string.sub(_ENV["FZUG1_"..z], 1,2)..string.sub(_ENV["FZUG1_"..z], 4,5)  -- neu zusammensetzen aus Zeichen 1,2,4 und 5
		--print("in Name_Ausg",z," ",_ENV["FZUG1_"..z])
		_ENV["FZUG2_"..z] = string.sub(_ENV["FZUG2_"..z], 1,2)..string.sub(_ENV["FZUG2_"..z], 4,5)  -- neu zusammensetzen aus Zeichen 1,2,4 und 5
		--print("in Name_Ausg",z," ",_ENV["FZUG2_"..z])
		EEPSaveData((100 * z) + 1, _ENV["FZUG1_"..z])
		EEPSaveData((100 * z) + 2, _ENV["DPos1_"..z])
		EEPSaveData((100 * z) + 3, _ENV["FZUG2_"..z])
		EEPSaveData((100 * z) + 4, _ENV["DPos2_"..z])
	end
end
------------------------------------------------------------------------------------------------------------------------
function ZZ_West(zn)											-- Aufruf in Kontaktpunkt
	zz_route1 = select(2,EEPGetTrainRoute(zn))					-- Route aus Zugname ermitteln
	if zz_route1 ~= "Gueter" then 								-- wenn die Route nicht Gueter ist
		for k, v in pairs (routenzz) do								-- Schleife durch die Tabelle routenzz
		--print("Route des Zugs Depot 1 = ",zz_route1,"\nRoute in Tabelle = ",v," Zähler ",k)
			if v == zz_route1 then									-- wenn der aktuelle Wert in der Tabelle gleich der Route des Zugs
				zzgleisw = gleisewest[k]								-- Gleis für diese Route aus der Tabelle gleisewest lesen
				--print("West für ZZA = ", zzgleisw)
				break												-- Schleife abbrechen
			end
		end
		if zzgleisw == 1 and select(2,EEPStructureGetTagText("#101")) == "leer" then 		-- wenn Zielgleis = 1 und die ZZA leer ist
			prfdep_1(zzgleisw)										-- Funktion zum Prüfen auf Flogezüge in Depot 1 aufrufen
			_ENV["sortieren"..zzgleisw]()							-- Funktion zur Festlegung der Reihenfolge aufrufen
			_ENV["Name_Ausg"..zzgleisw]()							-- Funktion zur Umwandlung der Namen für die Ausgabe aufrufen
		elseif zzgleisw == 5 and select(2,EEPStructureGetTagText("#115")) == "leer" then 		-- wenn Zielgleis = 1 und die ZZA leer ist
			prfdep_1(zzgleisw)										-- Funktion zum Prüfen auf Flogezüge in Depot 1 aufrufen
			_ENV["sortieren"..zzgleisw]()							-- Funktion zur Festlegung der Reihenfolge aufrufen
			_ENV["Name_Ausg"..zzgleisw]()							-- Funktion zur Umwandlung der Namen für die Ausgabe aufrufen
		end
		if zz_route1 == "RB_30" then RB_30() end					-- Aufruf der Anzeigefunktion für Route RB_30 aus West
		if zz_route1 == "RB_30_1" then RB_30_1() end				-- Aufruf der Anzeigefunktion für Route RB_30_1 aus West
		if zz_route1 == "RE_32" then RE_32() end					-- Aufruf der Anzeigefunktion für Route RE_32 aus West
		if zz_route1 == "RE_40" then RE_40_1() end					-- Aufruf der Anzeigefunktion für Route RE_40 aus West	
	end
end
----------------------------------
function ZZ_Ost(zn)												-- Aufruf in Kontaktpunkt
	zz_route2 = select(2,EEPGetTrainRoute(zn))					-- Route aus Zugname ermitteln
	if zz_route2 ~= "Gueter" then 								-- wenn die Route nicht Gueter ist
		for k, v in pairs (routenzz) do							-- Schleife durch die Tabelle routenzz
		--print("Route des Zugs Depot 2 ",zz_route2,"\nRoute in Tabelle = ",v," Zähler ",k)
			if v == zz_route2 then									-- wenn der aktuelle Wert in der Tabelle gleich der Route des Zugs
				zzgleiso = gleiseost[k]								-- Gleis für diese Route aus der Tabelle gleisewest lesen
				--print("Ost für ZZA = ", zzgleiso)
				break												-- Schleife abbrechen
			end
		end
		if zzgleiso == 2 and select(2,EEPStructureGetTagText("#106")) == "leer" then 		-- wenn Zielgleis = 1 und die ZZA leer ist
			--prfdep_1(zzgleiso)										-- Funktion zum Prüfen auf Flogezüge in Depot 1 aufrufen
			prfdep_2(zzgleiso)										-- Funktion zum Prüfen auf Flogezüge in Depot 2 aufrufen
			_ENV["sortieren"..zzgleiso]()							-- Funktion zur Festlegung der Reihenfolge aufrufen
			_ENV["Name_Ausg"..zzgleiso]()							-- Funktion zur Umwandlung der Namen für die Ausgabe aufrufen
		elseif zzgleiso == 6 and select(2,EEPStructureGetTagText("#122")) == "leer" then 		-- wenn Zielgleis = 1 und die ZZA leer ist
			--prfdep_1(zzgleiso)										-- Funktion zum Prüfen auf Flogezüge in Depot 1 aufrufen
			prfdep_2(zzgleiso)										-- Funktion zum Prüfen auf Flogezüge in Depot 2 aufrufen
			_ENV["sortieren"..zzgleiso]()							-- Funktion zur Festlegung der Reihenfolge aufrufen
			_ENV["Name_Ausg"..zzgleiso]()							-- Funktion zur Umwandlung der Namen für die Ausgabe aufrufen
		end
		if zz_route2 == "RB_30" then RB_30_2() 	end			-- Aufruf der Anzeigefunktion für Route RB_30 aus Ost
		if zz_route2 == "RE_40" then RE_40() end			-- Aufruf der Anzeigefunktion für Route RE_40 aus Ost
		if zz_route2 == "RE_41" then RE_41() end			-- Aufruf der Anzeigefunktion für Route RE_41 aus Ost
		if zz_route2 == "RE_47" then RE_47() end			-- Aufruf der Anzeigefunktion für Route RE_47 aus Ost	
	end
end
-----------------------------------------------------------------------------------------------------------------------------
function prfdep_1(depotgleis1)
	_ENV["FZUG1_"..depotgleis1] = ""									-- Variablen zurücksetzen
	_ENV["DPos1_"..depotgleis1] = 0
	_ENV["FZUG2_"..depotgleis1] = ""									-- Variablen zurücksetzen
	_ENV["DPos1_"..depotgleis1] = 0
	--print("In prfdep_1, depotgleis1 = ",depotgleis1)
	Depot_1 = EEPGetTrainyardItemsCount(1)							-- Anzahl der Züge im Depot ermitteln
	--print(Depot_1," Züge in Depot 1")
	for dl = 1, Depot_1 do											-- Schleife durch die Zugliste in Depot 1
		DepZname = EEPGetTrainyardItemName(1,dl)					-- Name des Zugs an der aktuellen Position ermitteln
		DepStatus = EEPGetTrainyardItemStatus(1,DepZname,0)			-- Prüfen des Status des aktuellen Zug in der Depotliste
		--print("Zugname Depot 1 ",dl," ",DepZname,"\nStatus = ",DepStatus)
		if DepStatus == 1 then										-- wenn der Zug im Depot steht (wartend)							
			Deproute = select(2,EEPGetTrainRoute(DepZname))			-- die Route dieses Zugs ermitteln
			if Deproute ~= "Gueter" then 
				for k,v in pairs (routenzz) do							-- Schleife durch die Tabelle routenzz
				--print("Route im Depot 1 = ",Deproute,"\nRoute in Liste = ",v)									-- wenn Durchlauf 1
					if v == Deproute then								-- wenn der aktuelle Wert in der Tabelle gleich der Route des Depotzugs
						fzgleisw = gleisewest[k]						-- das Gleis für diese Route ermitteln
						--print("Depot 1 Folgezuggleis = ",fzgleisw," Zielgleis = ",depotgleis1)
						--break											-- innere Schleife verlassen
					end
				end
				if depotgleis1 == fzgleisw then								-- wenn das Gleis für den aktuellen Zug und das Gleis für den FZUG gleich sind
					if _ENV["FZUG1_"..depotgleis1] == "" then				-- wenn noch kein Folgezug gespeichert ist
						_ENV["FZUG1_"..depotgleis1] = Deproute				-- die Route des FZUGs in der Varialben FZUG1 speichern
						_ENV["DPos1_"..depotgleis1] = dl					-- die Position im Depot merken
					elseif _ENV["FZUG1_"..depotgleis1] ~= "" and _ENV["FZUG2_"..depotgleis1] == "" then	-- wenn schon Folgezug1 und kein Folgezug2
						_ENV["FZUG2_"..depotgleis1] = Deproute				-- die Route des FZUGs in der Varialben FZUG2 speichern
						_ENV["DPos2_"..depotgleis1] = dl					-- die Position im Depot merken
					end
				end
			end
			if _ENV["FZUG2_"..depotgleis1] ~= "" then						-- wenn eine  2. Route gefunden wurde
				break														-- Schleife verlassen
			elseif _ENV["FZUG1_"..depotgleis1] == "" then					-- sonst wenn keine 1 Route gefunden wurde
				_ENV["DPos1_"..depotgleis1] = 0								-- Einträge löschen
				_ENV["FZUG2_"..depotgleis1] = ""
				_ENV["DPos2_"..depotgleis1] = 0
			end
		end
	end
	--print("in Depotprüfung 1, \nFZUG = ", _ENV["FZUG1_"..depotgleis1],"\nPosition in Liste = ", _ENV["DPos1_"..depotgleis1])
	EEPSaveData((100 * depotgleis1) + 1, _ENV["FZUG1_"..depotgleis1])
	EEPSaveData((100 * depotgleis1) + 2, _ENV["DPos1_"..depotgleis1])	-- Werte in den Slots speichern
	EEPSaveData((100 * depotgleis1) + 3, _ENV["FZUG2_"..depotgleis1])
	EEPSaveData((100 * depotgleis1) + 4, _ENV["DPos2_"..depotgleis1])
end
----------------
function prfdep_2(depotgleis2) 
	_ENV["FZUG2_"..depotgleis2] = ""									-- Variablen zurücksetzen
	_ENV["DPos2_"..depotgleis2] = 0
	Depot_2 = EEPGetTrainyardItemsCount(2)							-- Anzahl der Züge im Depot ermitteln
	--print(Depot_2," Züge in Depot 2")
	for dl = 1, Depot_2 do											-- Schleife durch die Zugliste in Depot 1
		DepZname = EEPGetTrainyardItemName(2,dl)					-- Name des Zugs an der aktuellen Position ermitteln
		DepStatus = EEPGetTrainyardItemStatus(2,DepZname,0)			-- Prüfen des Status des aktuellen Zug in der Depotliste
		--print("Zugname Depot 2 ",dl," ",DepZname,"\nStatus = ",DepStatus)
		if DepStatus == 1 then										-- wenn der Zug im Depot steht (wartend)							
			Deproute = select(2,EEPGetTrainRoute(DepZname))			-- die Route dieses Zugs ermitteln
			if Deproute ~= "Gueter" then 							-- wenn die Route nicht Gueter ist
				for k,v in pairs (routenzz) do						-- Schleife durch die Tabelle routenzz
				--print("Route im Depot 2 = ",Deproute,"\nRoute in Liste = ",v)									
					if v == Deproute then							-- wenn der aktuelle Wert in der Tabelle gleich der Route des Depotzugs
						fzgleiso = gleiseost[k]						-- das Gleis für diese Route ermitteln
						--print("Depot 2 Folgezuggleis = ",fzgleiso," Zielgleis = ",depotgleis2)
						break										-- innere Schleife verlassen
					end
				end
				if depotgleis2 == fzgleiso then								-- wenn das Gleis für den aktuellen Zug und das Gleis für den FZUG gleich sind
					if _ENV["FZUG1_"..depotgleis2] == "" then				-- wenn noch kein Folgezug gespeichert ist
						_ENV["FZUG1_"..depotgleis2] = Deproute				-- die Route des FZUGs in der Varialben FZUG1 speichern
						_ENV["DPos1_"..depotgleis2] = dl					-- die Position im Depot merken
					elseif _ENV["FZUG1_"..depotgleis2] ~= "" and _ENV["FZUG2_"..depotgleis2] == "" then	-- wenn schon Folgezug1 und kein Folgezug2
						_ENV["FZUG2_"..depotgleis2] = Deproute				-- die Route des FZUGs in der Varialben FZUG2 speichern
						_ENV["DPos2_"..depotgleis2] = dl					-- die Position im Depot merken
					end
				end
			end
			if _ENV["FZUG2_"..depotgleis2] ~= "" then						-- wenn eine  2. Route gefunden wurde
				break														-- Schleife verlassen
			elseif _ENV["FZUG1_"..depotgleis2] == "" then					-- sonst wenn keine 1 Route gefunden wurde
				_ENV["DPos1_"..depotgleis2] = 0								-- Einträge löschen
				_ENV["FZUG2_"..depotgleis2] = ""
				_ENV["DPos2_"..depotgleis2] = 0
			end
		end
	end
	--print("in Depotprüfung 1, \nFZUG = ", _ENV["FZUG1_"..depotgleis1],"\nPosition in Liste = ", _ENV["DPos1_"..depotgleis1])
	EEPSaveData((100 * depotgleis2) + 1, _ENV["FZUG1_"..depotgleis2])
	EEPSaveData((100 * depotgleis2) + 2, _ENV["DPos1_"..depotgleis2])	-- Werte in den Slots speichern
	EEPSaveData((100 * depotgleis2) + 3, _ENV["FZUG2_"..depotgleis2])
	EEPSaveData((100 * depotgleis2) + 4, _ENV["DPos2_"..depotgleis2])
end
--------------------------------------------------------------------------------
for dl = 1,6 do
	_ENV["sortieren"..dl] = function()												-- 3 Funktionen erzeugen
		_ENV["DPos_"..dl] = 0														-- Zwischenspeicher zurücksetzen
--print("In sortieren",dl)
		_ENV["FZUG1_"..dl] = select(2,EEPLoadData((100 * dl) + 1))					-- Werte aus den Slots lesen
		_ENV["DPos1_"..dl] = select(2,EEPLoadData((100 * dl) + 2))
		_ENV["FZUG2_"..dl] = select(2,EEPLoadData((100 * dl) + 3))
		_ENV["DPos2_"..dl] = select(2,EEPLoadData((100 * dl) + 4))
--print("vor sortieren \nFolgezug 1 ",_ENV["FZUG1_"..dl]," Folgezug 2 ",_ENV["FZUG2_"..dl],"\nPosition 1 ",_ENV["DPos1_"..dl]," Position 2 ",_ENV["DPos2_"..dl])
		if _ENV["DPos1_"..dl] > _ENV["DPos2_"..dl] and _ENV["DPos2_"..dl] > 0 then	-- Wenn die Listenposition in Depot 1 kleiner ist als die in Depot 2
			_ENV["DPos_"..dl] = _ENV["DPos2_"..dl]									-- Wert von Depot 2 zwischenspeichern
			_ENV["FZUG_"..dl] = _ENV["FZUG2_"..dl]									-- Route in Depot 2 zwischenspeichern
			_ENV["DPos2_"..dl] = _ENV["DPos1_"..dl]									-- Wert von Depot 1 in Depot 2 schreiben
			_ENV["FZUG2_"..dl] = _ENV["FZUG1_"..dl]									-- Route von Depot 1 in Depot 2 schreiben
			_ENV["DPos1_"..dl] = _ENV["DPos_"..dl]									-- Wert von Zwischenspeicher in Depot 1 schreiben
			_ENV["FZUG1_"..dl] = _ENV["FZUG_"..dl]									-- Route von Zwischenspeicher in Depot 1 schreiben
		elseif _ENV["DPos1_"..dl] == 0 and _ENV["DPos2_"..dl] > 0 then
			_ENV["DPos_"..dl] = _ENV["DPos2_"..dl]									-- Wert von Depot 2 zwischenspeichern
			_ENV["FZUG_"..dl] = _ENV["FZUG2_"..dl]									-- Route in Depot 2 zwischenspeichern
			_ENV["DPos2_"..dl] = _ENV["DPos1_"..dl]									-- Wert von Depot 1 in Depot 2 schreiben
			_ENV["FZUG2_"..dl] = _ENV["FZUG1_"..dl]									-- Route von Depot 1 in Depot 2 schreiben
			_ENV["DPos1_"..dl] = _ENV["DPos_"..dl]									-- Wert von Zwischenspeicher in Depot 1 schreiben
			_ENV["FZUG1_"..dl] = _ENV["FZUG_"..dl]	
		end
--print("nach sortieren \nFolgezug 1 ",_ENV["FZUG1_"..dl]," Folgezug 2 ",_ENV["FZUG2_"..dl],"\nPosition 1 ",_ENV["DPos1_"..dl]," Position 2 ",_ENV["DPos2_"..dl])
		EEPSaveData((100 * dl) + 1, _ENV["FZUG1_"..dl])								-- Werte in die Slots scheiben
		EEPSaveData((100 * dl) + 2, _ENV["DPos1_"..dl])
		EEPSaveData((100 * dl) + 3, _ENV["FZUG2_"..dl])
		EEPSaveData((100 * dl) + 4, _ENV["DPos2_"..dl])	
	end
end
Infotexttabelle = {	
					{"#101","#102","#105",33},{"#106","#109","#110",33},{"#103","#108","#112",33},
					{"#113","#117","#119",33},{"#115","#118","#121",33},{"#122","#125","#128",33}
					}
function infotext()																	-- Funktion zur Veränderung des Infofeldes in der ZZA
	for k,v in pairs (Infotexttabelle) do
		_ENV["zeit_Gl"..k] = string.sub(select(2,EEPStructureGetTagText(v[1])),1,5)			
		if _ENV["zeit_Gl"..k]~= "" and _ENV["zeit_Gl"..k]~= nil then				-- wenn bereits eine Zeit im ZZA angezeigt wird
			--print("Gleis ",k," Wert in Zeitanzeige = ",_ENV["zeit_Gl"..k])
			akzeit = string.format("%02d:%02d", EEPTimeH, EEPTimeM)					-- aktuelle EEP Zeit in variable schreiben
			--print("Vergleichszeit EEP = ",akzeit)
			if _ENV["zeit_Gl"..k] < akzeit then										-- wenn die Zeit in ZZA kleiner ist als die aktuelle Zeit 
				minwert1 = string.sub(_ENV["zeit_Gl"..k], 4)						-- Minutenwerte auslesen aus ZZA
				minwert2 = string.sub(akzeit, 4)									-- Minutenwerte auslesen aus EEP Zeit
				if minwert2 < minwert1 then
					minwert2 = minwert2 + 60
				end
				versp = minwert2 - minwert1											-- den Wert für Verspätung errechnen
				_ENV["Info_Gl"..k] = "--- Abfahrt voraussichtlich ".. math.floor(versp +0,5) .. " Minute(n) später!!! ---"		-- Infotext definieren
				for dl = 1,3 do
					EEPStructureSetTextureText(v[dl],v[4],_ENV["Info_Gl"..k])		-- Infotest in ZZA anzeigen
				end
			end
		end
	end
end
sigtabtuer = {16,15,13,14,12,11}													-- Tabelle mit den Signalen für die Prüfung ob ein Zug gehalten wird
for k, v in pairs (sigtabtuer) do											-- Schleife durch die Tabelle
	_ENV["tuerzu_"..k] = function()											-- Funktionen tuerzu_xy erzeugen	
		if EEPGetSignalTrainsCount(v) > 0 then								-- prüfen ob am Signal ein Zug gehalten wird
			zugname = EEPGetSignalTrainName(v, 1)							-- den Zugname ermitteln
			wagenzahl = EEPGetRollingstockItemsCount(zugname)				-- Anzahl der Fahrzeuge
			for dl1 = 0, wagenzahl - 1 do									-- Schleife durch die Anzahl der Fahrzeuge
				rmname = EEPGetRollingstockItemName(zugname,dl1)			-- den Name des Rollmaterials auslesen
				EEPRollingstockSetSlot(rmname,1)							-- Achsengruppe 1 bei allen Fahrzeugen einstellen
			end
		end
	end
end
--------------- Kreisverkehr
KrVgln = {77,75,78,79}
KrVglo = {97,96,95,94}
KrVgls = {88,89,90,91}
KrVglw = {82,83,84,85}
for dl = 1,4 do
	EEPRegisterRoadTrack(KrVgln[dl])
	EEPRegisterRoadTrack(KrVglo[dl])
	EEPRegisterRoadTrack(KrVgls[dl])
	EEPRegisterRoadTrack(KrVglw[dl])
end
function Einfkrv()
	glfrn = nil
	glfro = nil
	glfrs = nil
	glfrw = nil
	for dl = 1,4 do
		glprn = select(2,EEPIsRoadTrackReserved(KrVgln[dl]))
		if glprn == true then glfrn = true; end
		glpro = select(2,EEPIsRoadTrackReserved(KrVglo[dl]))
		if glpro == true then glfro = true; end
		glprs = select(2,EEPIsRoadTrackReserved(KrVgls[dl]))
		if glprs == true then glfrs = true; end
		glprw = select(2,EEPIsRoadTrackReserved(KrVglw[dl]))
		if glprw == true then glfrw = true; end
	end
	if glfrn then
		EEPSetSignal(103,2)
	else
		EEPSetSignal(103,1)
	end
	if glfro then
		EEPSetSignal(104,2)
	else
		EEPSetSignal(104,1)
	end
	if glfrs then
		EEPSetSignal(105,2)
	else
		EEPSetSignal(105,1)
	end
	if glfrw then
		EEPSetSignal(102,2)
	else
		EEPSetSignal(102,1)
	end
end
T_kreuzg = {
			--- Einmündung I
			[112] = {203,206,212},
			[113] = {203,206,212,199,8,207,416},
			[115] = {203,206,212,200},	-- ,208
			[116] = {207},
			[114] = {208,198},
			--- Einmündung II
			[118] = {59,61,62},
			[119] = {59,61,62,39,55,56,73,71},
			[117] = {59,61,62,64,63},	-- ,70
			[121] = {71},
			[120] = {69,70},
			--- Einmündung III
			[122] = {40,41,44},
			[123] = {40,41,44,33,36,35,51,52},
			[124] = {40,41,44,37,45},	-- ,53
			[125] = {51},
			[126] = {53,38},
			--- Einmündung IV
			[127] = {47,122,130},
			[128] = {47,122,130,136,129,127,224,131},
			[129] = {47,122,130,233,121},	-- ,132
			[130] = {131},
			[131] = {123,132},
			--- Einmündung V
			[132] = {149,145,142},
			[133] = {149,145,142,157,141,140,144,235},
			[134] = {149,145,142,236,147},	-- ,146
			[135] = {144},
			[136] = {137,146},
			--- Einmündung VI
			[161] = {31,239,247},
			[162] = {31,239,247,254,244,246,248,250},
			[163] = {31,239,247,251,240},	-- ,249
			[164] = {248},
			[165] = {249,243},
			--- Einmündung VII
			[166] = {296,294,297},
			[167] = {296,294,297,255,290,298,315,300},
			[168] = {296,294,297,316,291},	-- ,299
			[169] = {300},
			[165] = {287,299},
			--- Einmündung VIII
			[171] = {284,280,302},
			[172] = {284,280,302,271,274,301,303,542},
			[173] = {284,280,302,544,278},	-- ,304
			[174] = {303},
			[175] = {275,304},
			--- Einmündung IX
			[176] = {314,308,309},
			[177] = {314,308,309,270,269,310,311,545},
			[178] = {314,308,309,550,305},	-- ,312
			[179] = {311},
			[180] = {265,312},
			}
for strasig, strID in pairs (T_kreuzg) do
	for liste, strgl in pairs (T_kreuzg[strasig]) do
		EEPRegisterRoadTrack(strgl)
	end
end
function abzweigkontrolle()
	for strasig, strID in pairs (T_kreuzg) do
		anhalten = nil
		for liste, strgl in pairs (T_kreuzg[strasig]) do
			einm_bes = select(2,EEPIsRoadTrackReserved(strgl))
			if einm_bes == true then
				anhalten = true
			end
		end
		if not anhalten then
			EEPSetSignal(strasig,1)
		else
			EEPSetSignal(strasig,2)
		end
	end
end
durchgang = 1																				-- Zaehler fuer Ampelschaltung Kreuzung		
rot = 0																						-- Verzoegerung bei Stellung Rot  Kreuzungen
gruen = 0
ampeln = 	{			
						{182,183,184,185}, 													-- Kreuzung 		
			}
function kr_ampel()
	stellung = EEPGetSignal(ampeln[1][durchgang])											-- die Stellung der Ampel auslesen
	if stellung == 1 then																	-- wenn Ampel rot
		rot = rot + 1																		-- Zaehler erhoehen
		if rot > 5 then																		-- wenn der Zaehler groeßer 10 ist
			rot = 4																			-- den Zaehler auf 9 zurueck setzen
			for k, v in pairs (ampeln) do
				EEPSetSignal(v[durchgang],2,1)												-- Ampel auf rot-gelb stellen
			end
		end
	elseif stellung == 2 then																-- sonst wenn Ampel rot-gelb
		for k, v in pairs (ampeln) do
			EEPSetSignal(v[durchgang],3,1)													-- Ampel auf gruen stellen
		end																					-- Ampel auf gruen stellen
	elseif stellung == 3 then																-- sonst wenn Ampel gruen
		gruen= gruen + 1																	-- Zaehler erhoehen
		if gruen > 5 then																	-- wenn Zaehler groesser als 10
			gruen = 0 																		-- den Zaehler auf 9 zurueck setzen
			for k, v in pairs (ampeln) do
				EEPSetSignal(v[durchgang],4,1)												-- Ampel auf gelb stellen
			end
		end
	elseif stellung == 4 then																-- wenn Ampel gelb
		for k, v in pairs (ampeln) do
			EEPSetSignal(v[durchgang],1,1)													-- Ampel auf rot stellen
		end
		durchgang = durchgang + 1															-- Durchgangszaehler um 1 erhoehen
		if durchgang > 4 then 																-- Wenn alle 5 Phasen geschaltet sind 
			durchgang = 1																	-- Durchgangszaehler wieder auf 1 stellen
		end						-- dadurch werden alle Phasen immer wieder durchgeschaltet. Die 5. Phase ist fuer die Fussgaengerampeln gedacht
	end
end
-------------- Stadtlampen einstellen
function strassenlampen()
	for dl = 308,480 do
		if EEPTimeH <= 6 or EEPTimeH >= 18 then
			EEPStructureSetLight("#"..dl,true)
			EEPStructureSetAxis("#"..dl,"Lichtintensität",75)
		else
			EEPStructureSetLight("#"..dl,false)
			EEPStructureSetAxis("#"..dl,"Lichtintensität",0)
		end
	end
end
lampID = {
			"#312","#308","#313","#314","#315","#329",
			"#316","#317","#318","#319","#320","#330",
		}
print("Script Steuerung_Diorama Version 1.0 wurde eingebunden")