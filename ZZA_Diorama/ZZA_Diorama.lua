-- Zugzielanzeigen im Bahnhof Hersbruck r.Pegnitz

-- Gleis1


ZZA_Demo_Gl1 = {"#101","#102","#105"}

function  ZZA_Gl1 (ziel_Gl1, zwziel_Gl1, zeit_Gl1, zugnr_Gl1, 
			zeit_FZUG_1_Gl1, zugnr_FZUG_1_Gl1, ziel_FZUG_1_Gl1, zeit_FZUG_2_Gl1, zugnr_FZUG_2_Gl1, ziel_FZUG_2_Gl1, Info_Gl1)
	for k, Anzeige in pairs(ZZA_Demo_Gl1)do
		EEPStructureSetTextureText (Anzeige, 1, ziel_Gl1)
		EEPStructureSetTextureText (Anzeige, 2, ziel_Gl1)
		EEPStructureSetTextureText (Anzeige, 3, zwziel_Gl1)
		EEPStructureSetTextureText (Anzeige, 4, zwziel_Gl1)
		EEPStructureSetTextureText (Anzeige, 5, zeit_Gl1)
		EEPStructureSetTextureText (Anzeige, 6, zeit_Gl1)
		EEPStructureSetTextureText (Anzeige, 7, zugnr_Gl1)
		EEPStructureSetTextureText (Anzeige, 8, zugnr_Gl1)
		EEPStructureSetTextureText (Anzeige, 11, zeit_FZUG_1_Gl1)
		EEPStructureSetTextureText (Anzeige, 12, zeit_FZUG_1_Gl1)
		EEPStructureSetTextureText (Anzeige, 13, zugnr_FZUG_1_Gl1)
		EEPStructureSetTextureText (Anzeige, 14, zugnr_FZUG_1_Gl1)
		EEPStructureSetTextureText (Anzeige, 15, ziel_FZUG_1_Gl1)
		EEPStructureSetTextureText (Anzeige, 16, ziel_FZUG_1_Gl1)
		EEPStructureSetTextureText (Anzeige, 19, zeit_FZUG_2_Gl1)
		EEPStructureSetTextureText (Anzeige, 20, zeit_FZUG_2_Gl1)
		EEPStructureSetTextureText (Anzeige, 21, zugnr_FZUG_2_Gl1)
		EEPStructureSetTextureText (Anzeige, 22, zugnr_FZUG_2_Gl1)
		EEPStructureSetTextureText (Anzeige, 23, ziel_FZUG_2_Gl1)
		EEPStructureSetTextureText (Anzeige, 24, ziel_FZUG_2_Gl1)
		EEPStructureSetTextureText (Anzeige, 33, Info_Gl1)
	end
end
function zeitrechnen1()
	FZUG1_1 = select(2,EEPLoadData(101))
	DPos1_1 = select(2,EEPLoadData(102))
	FZUG2_1 = select(2,EEPLoadData(103))
	DPos2_1 = select(2,EEPLoadData(104))
	zeit_ZZ1 = select(2,EEPLoadData(105))										-- Zeitstring aus Slot lesen
	if string.len(zeit_ZZ1) == 17 then												-- wenn der Zeitstring mindestens 5 Zeichen hat (eine Zeit gespeichert ist)
		zeit_Gl1 = string.sub(zeit_ZZ1,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl1 = string.sub(zeit_ZZ1,7,12)
		zeit_FZUG_2_Gl1 = string.sub(zeit_ZZ1,13,18)
	elseif string.len(zeit_ZZ1) == 11 then
		zeit_Gl1 = string.sub(zeit_ZZ1,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl1 = string.sub(zeit_ZZ1,7,12)
		zeit_FZUG_2_Gl1 = ""
	elseif string.len(zeit_ZZ1) == 5 then
		zeit_Gl1 = string.sub(zeit_ZZ1,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl1 = ""
		zeit_FZUG_2_Gl1 = ""
	else
		zeit_Gl1 = ""
		zeit_FZUG_1_Gl1 = ""
		zeit_FZUG_2_Gl1 = ""
	end
end
function zeitrechnen1_2()
	if zeit_Gl1 == "" then														-- wenn keine Abfahrtszeit gefunden
		zeit_Gl1 = string.format("%02d:%02d", EEPTimeH, EEPTimeM  + Ankanz)		-- Abfahrtszeit = EEPZeit + Verzögerung für Anfahrt
		if EEPTimeM  + Ankanz >= 60 then										-- volle Stunde überschritten
			zeit_Gl1 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM  + Ankanz - 60)	-- dann den Wert für die Stunde um 1 erhöhen und Minutenwert -60
		end
		if EEPTimeH + 1 > 23 then 															-- wenn der Stundenwert größer als 23 (neuer Tag)
			zeit_Gl1 = string.format("%02d:%02d", EEPTimeH - 23 , EEPTimeM  + Ankanz - 60)	-- den Stundenwert um 23 reduzieren
		end
		zeit_ZZ1 = zeit_Gl1														-- den Zeitstring mit der Abfahrtszeit beschreiben
	end
	if FZUG1_1 ~= "" then																						-- wenn ein Folgezug gespeichert ist
		if zeit_FZUG_1_Gl1 == "" then
			zeit_FZUG_1_Gl1 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos1_1  * ZZATimer)					-- die Abfahrtszeit errechnen
			if EEPTimeM + DPos1_1  * ZZATimer >= 60 then
				zeit_FZUG_1_Gl1 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos1_1  * ZZATimer) - 60)	--s.o.
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_1_Gl1 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_1  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ1 = zeit_ZZ1..","..zeit_FZUG_1_Gl1								-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_1_Gl1 = FZUG1_1
		if FZUG1_1 == "RE40" then
			ziel_FZUG_1_Gl1 = "Regensburg Hbf"
		elseif FZUG1_1 == "RB30" then
			ziel_FZUG_1_Gl1 = "Neuhaus(Pegnitz)"
		end
	else
		zeit_FZUG_1_Gl1 = ""
		zugnr_FZUG_1_Gl1 = ""
		ziel_FZUG_1_Gl1 = ""
	end
	if FZUG2_1 ~= "" then																						-- wenn ein 2. Folgezug gespeichert ist
		if zeit_FZUG_2_Gl1 == "" then
			zeit_FZUG_2_Gl1 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos2_1  * ZZATimer)					-- Abfahrtszeit errechnen
			if EEPTimeM + DPos2_1  * ZZATimer >= 60 then
				zeit_FZUG_2_Gl1 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos2_1  * ZZATimer) - 60)
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_2_Gl1 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_1  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ1 = zeit_ZZ1..","..zeit_FZUG_2_Gl1						-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_2_Gl1 = FZUG2_1
		if FZUG2_1 == "RE40" then
			ziel_FZUG_2_Gl1 = "Regensburg Hbf"
		elseif FZUG2_1 == "RB30" then
			ziel_FZUG_2_Gl1 = "Neuhaus(Pegnitz)"
		end
	else
		zeit_FZUG_2_Gl1 = ""
		zugnr_FZUG_2_Gl1 = ""
		ziel_FZUG_2_Gl1 = ""
	end
end
function RE_40_1()																	-- für Route RE_40_1
	zeitrechnen1()
	ok, TZZA1 = EEPStructureGetTagText("#101")										-- TagTaxt aus ZZA lesen
	if TZZA1 ~= "leer" then															-- wenn der TagText nicht "leer" ist
		gl1schreibdaten(FZUG1_1,DPos1_1,FZUG2_1,DPos2_1)							-- die Daten schreiben
	elseif TZZA1 == "leer" then														-- wenn der TagText "leer" lautet
		ziel_Gl1 = "Regensburg Hbf"													-- Ziel für die Route festlegen
		zwziel_Gl1 = "Neukirchen(b Sulzb)  -  Sulzbach-Rosenberg"					-- Zwischenziel für die Route festlegen
		zeitrechnen1_2()
		zugnr_Gl1 = "RE40"															-- die angezeigte Route für den Zug festlegen
		Info_Gl1 = ""
		ZZA_Gl1 (ziel_Gl1, zwziel_Gl1, zeit_Gl1, zugnr_Gl1, 
		zeit_FZUG_1_Gl1, zugnr_FZUG_1_Gl1, ziel_FZUG_1_Gl1, zeit_FZUG_2_Gl1, zugnr_FZUG_2_Gl1, ziel_FZUG_2_Gl1, Info_Gl1)
		EEPStructureSetTagText("#101",zeit_ZZ1)
	end
end

function RB_30()
	zeitrechnen1()
	ok, TZZA1 = EEPStructureGetTagText("#101")
	if TZZA1 ~= "leer" then
		gl1schreibdaten(FZUG1_1,DPos1_1,FZUG2_1,DPos2_1)
	elseif TZZA1 == "leer" then
		ziel_Gl1 = "Neuhaus (Pegnitz)"
		zwziel_Gl1 = "Vorra(Pegnitz) - Velden(b Hersbruck)"
		zeitrechnen1_2()
		zugnr_Gl1 = "RB30"
		Info_Gl1 = ""
		ZZA_Gl1 (ziel_Gl1, zwziel_Gl1, zeit_Gl1, zugnr_Gl1, 
		zeit_FZUG_1_Gl1, zugnr_FZUG_1_Gl1, ziel_FZUG_1_Gl1, zeit_FZUG_2_Gl1, zugnr_FZUG_2_Gl1, ziel_FZUG_2_Gl1, Info_Gl1)
		EEPStructureSetTagText("#101",zeit_ZZ1)
	end
end
function Gl1_aus ()													-- Ausschalten oder Weiterschalten der ZZA
	tagzeit1 = select(2,EEPStructureGetTagText("#101"))				-- Zeitstring lesen
	FZazeit1 = string.sub(tagzeit1,7,string.len(tagzeit1))			-- Abfahrtszeit 1. Folgezug errechnen
	FZbzeit1 = string.sub(FZazeit1,7,string.len(FZazeit1))			-- Abfahrtszeit 2. Folgezug errechnen
	EEPStructureSetTagText("#101","leer")							-- TagText "leer" eintragen
	DPos1_1 = select(2,EEPLoadData(102))							-- Depotposition des 1. Folgezugs auslesen
	FZUG2_1 = select(2,EEPLoadData(103))							-- Route des 2. Folgezugs lesen
	DPos2_1 = select(2,EEPLoadData(104))							-- Position des 2. Folgezugs im Depot lesen
	if DPos1_1 ~= 0 then											-- wenn eine Position für den ersten Folgezug gespeichert ist
		zeit_Gl1 = FZazeit1											-- die Abfahrtszeit festlegen
	else															-- sonst (wenn kein Folgezug vorhanden)
		zeit_Gl1 = ""												-- die Zeit löschen
	end
	EEPSaveData(101,FZUG2_1)										-- die Folgezüge nach vorne holen
	EEPSaveData(102,DPos2_1)
	EEPSaveData(103,"")												-- den 2. Folgezug löschen
	EEPSaveData(104,0)												-- die 2. Position löschen
	EEPSaveData(105,FZazeit1)	
	if FZUG1_1 == "RB30" then
		RB_30()
	elseif FZUG1_1 == "RE40" then 
		RE_40_1()
	else
		ziel_Gl1 = ""
		zwziel_Gl1 = ""
		zeit_Gl1 = ""
		zugnr_Gl1 = ""
		zeit_FZUG_1_Gl1 = ""
		zugnr_FZUG_1_Gl1 = ""
		ziel_FZUG_1_Gl1 = ""
		zeit_FZUG_2_Gl1 = ""
		zugnr_FZUG_2_Gl1 = ""
		ziel_FZUG_2_Gl1 = ""
		Info_Gl1 = ""
		ZZA_Gl1 (ziel_Gl1, zwziel_Gl1, zeit_Gl1, zugnr_Gl1, 
		zeit_FZUG_1_Gl1, zugnr_FZUG_1_Gl1, ziel_FZUG_1_Gl1, zeit_FZUG_2_Gl1, zugnr_FZUG_2_Gl1, ziel_FZUG_2_Gl1, Info_Gl1) 
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Datenslots für die Anzeigen an ZZA Gleis 2 = 201 - 204
-- Gleis2



ZZA_Demo_Gl2 = {"#106","#109","#110"}

function  ZZA_Gl2 (ziel_Gl2, zwziel_Gl2, zeit_Gl2, zugnr_Gl2, 
			zeit_FZUG_1_Gl2, zugnr_FZUG_1_Gl2, ziel_FZUG_1_Gl2, zeit_FZUG_2_Gl2, zugnr_FZUG_2_Gl2, ziel_FZUG_2_Gl2, Info_Gl2)
	for k, Anzeige in pairs(ZZA_Demo_Gl2)do
		EEPStructureSetTextureText (Anzeige, 1, ziel_Gl2)
		EEPStructureSetTextureText (Anzeige, 2, ziel_Gl2)
		EEPStructureSetTextureText (Anzeige, 3, zwziel_Gl2)
		EEPStructureSetTextureText (Anzeige, 4, zwziel_Gl2)
		EEPStructureSetTextureText (Anzeige, 5, zeit_Gl2)
		EEPStructureSetTextureText (Anzeige, 6, zeit_Gl2)
		EEPStructureSetTextureText (Anzeige, 7, zugnr_Gl2)
		EEPStructureSetTextureText (Anzeige, 8, zugnr_Gl2)
		EEPStructureSetTextureText (Anzeige, 11, zeit_FZUG_1_Gl2)
		EEPStructureSetTextureText (Anzeige, 12, zeit_FZUG_1_Gl2)
		EEPStructureSetTextureText (Anzeige, 13, zugnr_FZUG_1_Gl2)
		EEPStructureSetTextureText (Anzeige, 14, zugnr_FZUG_1_Gl2)
		EEPStructureSetTextureText (Anzeige, 15, ziel_FZUG_1_Gl2)
		EEPStructureSetTextureText (Anzeige, 16, ziel_FZUG_1_Gl2)
		EEPStructureSetTextureText (Anzeige, 19, zeit_FZUG_2_Gl2)
		EEPStructureSetTextureText (Anzeige, 20, zeit_FZUG_2_Gl2)
		EEPStructureSetTextureText (Anzeige, 21, zugnr_FZUG_2_Gl2)
		EEPStructureSetTextureText (Anzeige, 22, zugnr_FZUG_2_Gl2)
		EEPStructureSetTextureText (Anzeige, 23, ziel_FZUG_2_Gl2)
		EEPStructureSetTextureText (Anzeige, 24, ziel_FZUG_2_Gl2)
		EEPStructureSetTextureText (Anzeige, 33, Info_Gl2)
	end
end
function zeitrechnen2()
	FZUG1_2 = select(2,EEPLoadData(201))
	DPos1_2 = select(2,EEPLoadData(202))
	FZUG2_2 = select(2,EEPLoadData(203))
	DPos2_2 = select(2,EEPLoadData(204))
	zeit_ZZ2 = select(2,EEPLoadData(205))										-- Zeitstring aus Slot lesen
	if string.len(zeit_ZZ2) == 17 then												-- wenn der Zeitstring mindestens 5 Zeichen hat (eine Zeit gespeichert ist)
		zeit_Gl2 = string.sub(zeit_ZZ2,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl2 = string.sub(zeit_ZZ2,7,12)
		zeit_FZUG_2_Gl2 = string.sub(zeit_ZZ2,13,18)
	elseif string.len(zeit_ZZ2) == 11 then
		zeit_Gl2 = string.sub(zeit_ZZ2,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl2 = string.sub(zeit_ZZ2,7,12)
		zeit_FZUG_2_Gl2 = ""
	elseif string.len(zeit_ZZ2) == 5 then
		zeit_Gl1 = string.sub(zeit_ZZ2,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl2 = ""
		zeit_FZUG_2_Gl2 = ""
	else
		zeit_Gl2 = ""
		zeit_FZUG_1_Gl2 = ""
		zeit_FZUG_2_Gl2 = ""
	end
end
function zeitrechnen2_2()
	if zeit_Gl2 == "" then														-- wenn keine Abfahrtszeit gefunden
		zeit_Gl2 = string.format("%02d:%02d", EEPTimeH, EEPTimeM  + Ankanz)		-- Abfahrtszeit = EEPZeit + Verzögerung für Anfahrt
		if EEPTimeM  + Ankanz >= 60 then										-- volle Stunde überschritten
			zeit_Gl2 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM  + Ankanz - 60)	-- dann den Wert für die Stunde um 1 erhöhen und Minutenwert -60
		end
		if EEPTimeH + 1 > 23 then 															-- wenn der Stundenwert größer als 23 (neuer Tag)
			zeit_Gl2 = string.format("%02d:%02d", EEPTimeH - 23 , EEPTimeM  + Ankanz - 60)	-- den Stundenwert um 23 reduzieren
		end
		zeit_ZZ2 = zeit_Gl2														-- den Zeitstring mit der Abfahrtszeit beschreiben
	end
	if FZUG1_2 ~= "" then																						-- wenn ein Folgezug gespeichert ist
		if zeit_FZUG_1_Gl2 == "" then
			zeit_FZUG_1_Gl2 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos1_2  * ZZATimer)					-- die Abfahrtszeit errechnen
			if EEPTimeM + DPos1_2  * ZZATimer >= 60 then
				zeit_FZUG_1_Gl2 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos1_2  * ZZATimer) - 60)	--s.o.
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_1_Gl2 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_2  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ2 = zeit_ZZ2..","..zeit_FZUG_1_Gl2								-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_1_Gl2 = FZUG1_2
		if FZUG1_2 == "RE40" then
			ziel_FZUG_1_Gl2 = "Nürnberg Hbf"
		elseif FZUG1_2 == "RE47" then
			ziel_FZUG_1_Gl2 = "Nürnberg Hbf"
		end
	else
		zeit_FZUG_1_Gl2 = ""
		zugnr_FZUG_1_Gl2 = ""
		ziel_FZUG_1_Gl2 = ""
	end
	if FZUG2_2 ~= "" then																						-- wenn ein 2. Folgezug gespeichert ist
		if zeit_FZUG_2_Gl2 == "" then
			zeit_FZUG_2_Gl2 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos2_2  * ZZATimer)					-- Abfahrtszeit errechnen
			if EEPTimeM + DPos2_2  * ZZATimer >= 60 then
				zeit_FZUG_2_Gl2 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos2_2  * ZZATimer) - 60)
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_2_Gl2 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_2  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ2 = zeit_ZZ2..","..zeit_FZUG_2_Gl2						-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_2_Gl2 = FZUG2_2
		if FZUG2_2 == "RE40" then
			ziel_FZUG_2_Gl2 = "Nürnberg Hbf"
		elseif FZUG2_2 == "RE47" then
			ziel_FZUG_2_Gl2 = "Nürnberg Hbf"
		end
	else
		zeit_FZUG_2_Gl2 = ""
		zugnr_FZUG_2_Gl2 = ""
		ziel_FZUG_2_Gl2 = ""
	end
end

function RE_40()
	zeitrechnen2()
	ok, TZZA2 = EEPStructureGetTagText("#106")
	if TZZA2 ~= "leer" then
		gl2schreibdaten(FZUG1_2,DPos1_2,FZUG2_2,DPos2_2)
	elseif TZZA2 == "leer" then
		ziel_Gl2 = "Nürnberg Hbf"
		zwziel_Gl2 = "Lauf rechts Pegnitz"
		zeitrechnen2_2()
		zugnr_Gl2 = "RE40"
		Info_Gl2 = ""
		ZZA_Gl2 (ziel_Gl2, zwziel_Gl2, zeit_Gl2, zugnr_Gl2, 
		zeit_FZUG_1_Gl2, zugnr_FZUG_1_Gl2, ziel_FZUG_1_Gl2, zeit_FZUG_2_Gl2, zugnr_FZUG_2_Gl2, ziel_FZUG_2_Gl2, Info_Gl2)
		EEPStructureSetTagText("#106",zeit_ZZ2)
	end
end
function RE_47()
	zeitrechnen2()
	ok, TZZA2 = EEPStructureGetTagText("#106")
	if TZZA2 ~= "leer" then
		gl2schreibdaten(FZUG1_2,DPos1_2,FZUG2_2,DPos2_2)
	elseif TZZA2 == "leer" then
		ziel_Gl2 = "Nürnberg Hbf"
		zwziel_Gl2 = ""
		zeitrechnen2_2()
		zugnr_Gl2 = "RE47"
		Info_Gl2 = ""
		ZZA_Gl2 (ziel_Gl2, zwziel_Gl2, zeit_Gl2, zugnr_Gl2, 
		zeit_FZUG_1_Gl2, zugnr_FZUG_1_Gl2, ziel_FZUG_1_Gl2, zeit_FZUG_2_Gl2, zugnr_FZUG_2_Gl2, ziel_FZUG_2_Gl2, Info_Gl2)
		EEPStructureSetTagText("#106",zeit_ZZ2)
	end
end


function Gl2_aus ()
	tagzeit2 = select(2,EEPStructureGetTagText("#106"))				-- Zeitstring lesen
	FZazeit2 = string.sub(tagzeit2,7,string.len(tagzeit2))			-- Abfahrtszeit 1. Folgezug errechnen
	FZbzeit2 = string.sub(FZazeit2,7,string.len(FZazeit2))			-- Abfahrtszeit 2. Folgezug errechnen
	EEPStructureSetTagText("#106","leer")
	DPos1_2 = select(2,EEPLoadData(202))
	FZUG2_2 = select(2,EEPLoadData(203))
	DPos2_2 = select(2,EEPLoadData(204))
	if DPos1_2 ~= 0 then
		zeit_Gl2 = FZazeit2
	else
		zeit_Gl2 = ""
	end
	EEPSaveData(201,FZUG2_2)
	EEPSaveData(202,DPos2_2)
	EEPSaveData(203,"")
	EEPSaveData(204,0)	
	EEPSaveData(205,FZazeit2)	
	if FZUG1_2 == "RE47" then 
		RE_47()
	elseif FZUG1_2 == "RE40" then 
		RE_40()
	else
		ziel_Gl2 = ""
		zwziel_Gl2 = ""
		zeit_Gl2 = ""
		zugnr_Gl2 = ""
		zeit_FZUG_1_Gl2 = ""
		zugnr_FZUG_1_Gl2 = ""
		ziel_FZUG_1_Gl2 = ""
		zeit_FZUG_2_Gl2 = ""
		zugnr_FZUG_2_Gl2 = ""
		ziel_FZUG_2_Gl2 = ""
		Info_Gl2 = ""
		ZZA_Gl2 (ziel_Gl2, zwziel_Gl2, zeit_Gl2, zugnr_Gl2, 
		zeit_FZUG_1_Gl2, zugnr_FZUG_1_Gl2, ziel_FZUG_1_Gl2, zeit_FZUG_2_Gl2, zugnr_FZUG_2_Gl2, ziel_FZUG_2_Gl2, Info_Gl2) 
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Gleis 3 nur Güter
ZZA_Demo_Gl3 = {"#103","#108","#112"}
function ZZA_Gl3_ein()
	for k, Anzeige in pairs(ZZA_Demo_Gl3)do
		EEPStructureSetTextureText (Anzeige, 1, "Durchfahrt Güterzug")
		EEPStructureSetTextureText (Anzeige, 2, "Durchfahrt Güterzug")
		EEPStructureSetTextureText (Anzeige, 3, "Bitte Vorsicht")
		EEPStructureSetTextureText (Anzeige, 4, "Bitte Vorsicht")
		EEPStructureSetTextureText (Anzeige, 33, "Zurücktreten von der Bahnsteigkante")
	end
end
function ZZA_Gl3_aus()
	for k, Anzeige in pairs(ZZA_Demo_Gl3)do
		EEPStructureSetTextureText (Anzeige, 1, "")
		EEPStructureSetTextureText (Anzeige, 2, "")
		EEPStructureSetTextureText (Anzeige, 3, "")
		EEPStructureSetTextureText (Anzeige, 4, "")
		EEPStructureSetTextureText (Anzeige, 33, "")
	end
end
-- Gleis 4 nur Güter
ZZA_Demo_Gl4 = {"#113","#117","#119"}
function ZZA_Gl4_ein()
	for k, Anzeige in pairs(ZZA_Demo_Gl4)do
		EEPStructureSetTextureText (Anzeige, 1, "Durchfahrt Güterzug")
		EEPStructureSetTextureText (Anzeige, 2, "Durchfahrt Güterzug")
		EEPStructureSetTextureText (Anzeige, 3, "Bitte Vorsicht")
		EEPStructureSetTextureText (Anzeige, 4, "Bitte Vorsicht")
		EEPStructureSetTextureText (Anzeige, 33, "Zurücktreten von der Bahnsteigkante")
	end
end
function ZZA_Gl4_aus()
	for k, Anzeige in pairs(ZZA_Demo_Gl4)do
		EEPStructureSetTextureText (Anzeige, 1, "")
		EEPStructureSetTextureText (Anzeige, 2, "")
		EEPStructureSetTextureText (Anzeige, 3, "")
		EEPStructureSetTextureText (Anzeige, 4, "")
		EEPStructureSetTextureText (Anzeige, 33, "")
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Datenslots für die Anzeigen an ZZA Gleis 3 = 301 - 304


-- Gleis5



ZZA_Demo_Gl5 = {"#115","#118","#121"}

function  ZZA_Gl5 (ziel_Gl5, zwziel_Gl5, zeit_Gl5, zugnr_Gl5, 
					zeit_FZUG_1_Gl5, zugnr_FZUG_1_Gl5, ziel_FZUG_1_Gl5, zeit_FZUG_2_Gl5, zugnr_FZUG_2_Gl5, ziel_FZUG_2_Gl5, Info_Gl5)
	for k, Anzeige in pairs(ZZA_Demo_Gl5)do
		EEPStructureSetTextureText (Anzeige, 1, ziel_Gl5)
		EEPStructureSetTextureText (Anzeige, 2, ziel_Gl5)
		EEPStructureSetTextureText (Anzeige, 3, zwziel_Gl5)
		EEPStructureSetTextureText (Anzeige, 4, zwziel_Gl5)
		EEPStructureSetTextureText (Anzeige, 5, zeit_Gl5)
		EEPStructureSetTextureText (Anzeige, 6, zeit_Gl5)
		EEPStructureSetTextureText (Anzeige, 7, zugnr_Gl5)
		EEPStructureSetTextureText (Anzeige, 8, zugnr_Gl5)
		EEPStructureSetTextureText (Anzeige, 11, zeit_FZUG_1_Gl5)
		EEPStructureSetTextureText (Anzeige, 12, zeit_FZUG_1_Gl5)
		EEPStructureSetTextureText (Anzeige, 13, zugnr_FZUG_1_Gl5)
		EEPStructureSetTextureText (Anzeige, 14, zugnr_FZUG_1_Gl5)
		EEPStructureSetTextureText (Anzeige, 15, ziel_FZUG_1_Gl5)
		EEPStructureSetTextureText (Anzeige, 16, ziel_FZUG_1_Gl5)
		EEPStructureSetTextureText (Anzeige, 19, zeit_FZUG_2_Gl5)
		EEPStructureSetTextureText (Anzeige, 20, zeit_FZUG_2_Gl5)
		EEPStructureSetTextureText (Anzeige, 21, zugnr_FZUG_2_Gl5)
		EEPStructureSetTextureText (Anzeige, 22, zugnr_FZUG_2_Gl5)
		EEPStructureSetTextureText (Anzeige, 23, ziel_FZUG_2_Gl5)
		EEPStructureSetTextureText (Anzeige, 24, ziel_FZUG_2_Gl5)
		EEPStructureSetTextureText (Anzeige, 33, Info_Gl5)
	end
end
function zeitrechnen5()
	FZUG1_5 = select(2,EEPLoadData(501))
	DPos1_5 = select(2,EEPLoadData(502))
	FZUG2_5 = select(2,EEPLoadData(503))
	DPos2_5 = select(2,EEPLoadData(504))
	zeit_ZZ5 = select(2,EEPLoadData(505))										-- Zeitstring aus Slot lesen
	if string.len(zeit_ZZ5) == 17 then												-- wenn der Zeitstring mindestens 5 Zeichen hat (eine Zeit gespeichert ist)
		zeit_Gl5 = string.sub(zeit_ZZ5,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl5 = string.sub(zeit_ZZ5,7,12)
		zeit_FZUG_2_Gl5 = string.sub(zeit_ZZ5,13,18)
	elseif string.len(zeit_ZZ5) == 11 then
		zeit_Gl5 = string.sub(zeit_ZZ5,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl5 = string.sub(zeit_ZZ5,7,12)
		zeit_FZUG_2_Gl5 = ""
	elseif string.len(zeit_ZZ5) == 5 then
		zeit_Gl5 = string.sub(zeit_ZZ5,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl5 = ""
		zeit_FZUG_2_Gl5 = ""
	else
		zeit_Gl5 = ""
		zeit_FZUG_1_Gl5 = ""
		zeit_FZUG_2_Gl5 = ""
	end
end
function zeitrechnen5_2()
	if zeit_Gl5 == "" then														-- wenn keine Abfahrtszeit gefunden
		zeit_Gl5 = string.format("%02d:%02d", EEPTimeH, EEPTimeM  + Ankanz)		-- Abfahrtszeit = EEPZeit + Verzögerung für Anfahrt
		if EEPTimeM  + Ankanz >= 60 then										-- volle Stunde überschritten
			zeit_Gl5 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM  + Ankanz - 60)	-- dann den Wert für die Stunde um 1 erhöhen und Minutenwert -60
		end
		if EEPTimeH + 1 > 23 then 															-- wenn der Stundenwert größer als 23 (neuer Tag)
			zeit_Gl5 = string.format("%02d:%02d", EEPTimeH - 23 , EEPTimeM  + Ankanz - 60)	-- den Stundenwert um 23 reduzieren
		end
		zeit_ZZ5 = zeit_Gl5														-- den Zeitstring mit der Abfahrtszeit beschreiben
	end
	if FZUG1_5 ~= "" then																						-- wenn ein Folgezug gespeichert ist
		if zeit_FZUG_1_Gl5 == "" then
			zeit_FZUG_1_Gl5 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos1_5  * ZZATimer)					-- die Abfahrtszeit errechnen
			if EEPTimeM + DPos1_5  * ZZATimer >= 60 then
				zeit_FZUG_1_Gl5 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos1_5  * ZZATimer) - 60)	--s.o.
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_1_Gl5 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_5  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ5 = zeit_ZZ5..","..zeit_FZUG_1_Gl5								-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_1_Gl5 = FZUG1_5
		if FZUG1_5 == "RE32" then
			ziel_FZUG_1_Gl5 = "Lichtenfels"
		elseif FZUG1_5 == "RB30" then
			ziel_FZUG_1_Gl5 = "Neuhaus(Pegnitz)"
		end
	else
		zeit_FZUG_1_Gl5 = ""
		zugnr_FZUG_1_Gl5 = ""
		ziel_FZUG_1_Gl5 = ""
	end
	if FZUG2_5 ~= "" then																						-- wenn ein 2. Folgezug gespeichert ist
		if zeit_FZUG_2_Gl5 == "" then
			zeit_FZUG_2_Gl5 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos2_5  * ZZATimer)					-- Abfahrtszeit errechnen
			if EEPTimeM + DPos2_5  * ZZATimer >= 60 then
				zeit_FZUG_2_Gl5 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos2_5  * ZZATimer) - 60)
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_2_Gl5 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_5  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ5 = zeit_ZZ5..","..zeit_FZUG_2_Gl5						-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_2_Gl5 = FZUG2_5
		if FZUG2_5 == "RE32" then
			ziel_FZUG_2_Gl5 = "Lichtenfels"
		elseif FZUG2_5 == "RB30" then
			ziel_FZUG_2_Gl5 = "Neuhaus(Pegnitz)"
		end
	else
		zeit_FZUG_2_Gl5 = ""
		zugnr_FZUG_2_Gl5 = ""
		ziel_FZUG_2_Gl5 = ""
	end
end

function RE_32()
	zeitrechnen5()
	ok, TZZA5 = EEPStructureGetTagText("#115")
	if TZZA5 ~= "leer" then
		Gl5schreibdaten(FZUG1_5,DPos1_5,FZUG2_5,DPos2_5)
	elseif TZZA5 == "leer" then
		ziel_Gl5 = "Lichtenfels"
		zwziel_Gl5 = "Pegnitz - Bayreuth Hbf - Kulmbach"
		zeitrechnen5_2()
		zugnr_Gl5 = "RE32"
		Info_Gl5 = ""
		ZZA_Gl5 (ziel_Gl5, zwziel_Gl5, zeit_Gl5, zugnr_Gl5, 
		zeit_FZUG_1_Gl5, zugnr_FZUG_1_Gl5, ziel_FZUG_1_Gl5, zeit_FZUG_2_Gl5, zugnr_FZUG_2_Gl5, ziel_FZUG_2_Gl5, Info_Gl5) 
		EEPStructureSetTagText("#115",zeit_ZZ5)
	end
end


function RB_30_1()
	zeitrechnen5()
	ok, TZZA5 = EEPStructureGetTagText("#115")
	if TZZA5 ~= "leer" then
		Gl5schreibdaten(FZUG1_5,DPos1_5,FZUG2_5,DPos2_5)
	elseif TZZA5 == "leer" then
		ziel_Gl5 = "Neuhaus(Pegnitz)"
		zwziel_Gl5 = "Hohenstadt(Mittelfr) - Rupprechtstegen"
		zeitrechnen5_2()
		zugnr_Gl5 = "RB30"
		Info_Gl5 = ""
		ZZA_Gl5 (ziel_Gl5, zwziel_Gl5, zeit_Gl5, zugnr_Gl5, 
		zeit_FZUG_1_Gl5, zugnr_FZUG_1_Gl5, ziel_FZUG_1_Gl5, zeit_FZUG_2_Gl5, zugnr_FZUG_2_Gl5, ziel_FZUG_2_Gl5, Info_Gl5) 
		EEPStructureSetTagText("#115",zeit_ZZ5)
	end
end



function Gl5_aus ()
	tagzeit5 = select(2,EEPStructureGetTagText("#115"))				-- Zeitstring lesen
	FZazeit5 = string.sub(tagzeit5,7,string.len(tagzeit5))			-- Abfahrtszeit 1. Folgezug errechnen
	FZbzeit5 = string.sub(FZazeit5,7,string.len(FZazeit5))			-- Abfahrtszeit 2. Folgezug errechnen
	EEPStructureSetTagText("#115","leer")
	DPos1_5 = select(2,EEPLoadData(502))
	FZUG2_5 = select(2,EEPLoadData(503))
	DPos2_5 = select(2,EEPLoadData(504))
	if DPos1_5 ~= 0 then
		zeit_Gl5 = FZazeit5
	else
		zeit_Gl5 = ""
	end
	EEPSaveData(501,FZUG2_5)
	EEPSaveData(502,DPos2_5)
	EEPSaveData(503,"")
	EEPSaveData(504,0)
	EEPSaveData(505,FZazeit5)		
	if FZUG1_5 == "RB30" then 
		RB_30_1()
	elseif FZUG1_5 == "RE32" then 
		RE_32()
	else
		ziel_Gl5 = ""
		zwziel_Gl5 = ""
		zeit_Gl5 = ""
		zugnr_Gl5 = ""
		zeit_FZUG_1_Gl5 = ""
		zugnr_FZUG_1_Gl5 = ""
		ziel_FZUG_1_Gl5 = ""
		zeit_FZUG_2_Gl5 = ""
		zugnr_FZUG_2_Gl5 = ""
		ziel_FZUG_2_Gl5 = ""
		Info_Gl5 = ""
		ZZA_Gl5 (ziel_Gl5, zwziel_Gl5, zeit_Gl5, zugnr_Gl5, 
		zeit_FZUG_1_Gl5, zugnr_FZUG_1_Gl5, ziel_FZUG_1_Gl5, zeit_FZUG_2_Gl5, zugnr_FZUG_2_Gl5, ziel_FZUG_2_Gl5, Info_Gl5) 
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------------------
-- Datenslots für die Anzeigen an ZZA Gleis 3 = 301 - 304


-- Gleis6



ZZA_Demo_Gl6 = {"#122","#125","#128"}

function  ZZA_Gl6 (ziel_Gl6, zwziel_Gl6, zeit_Gl6, zugnr_Gl6, 
					zeit_FZUG_1_Gl6, zugnr_FZUG_1_Gl6, ziel_FZUG_1_Gl6, zeit_FZUG_2_Gl6, zugnr_FZUG_2_Gl6, ziel_FZUG_2_Gl6, Info_Gl6)
	for k, Anzeige in pairs(ZZA_Demo_Gl6)do
		EEPStructureSetTextureText (Anzeige, 1, ziel_Gl6)
		EEPStructureSetTextureText (Anzeige, 2, ziel_Gl6)
		EEPStructureSetTextureText (Anzeige, 3, zwziel_Gl6)
		EEPStructureSetTextureText (Anzeige, 4, zwziel_Gl6)
		EEPStructureSetTextureText (Anzeige, 5, zeit_Gl6)
		EEPStructureSetTextureText (Anzeige, 6, zeit_Gl6)
		EEPStructureSetTextureText (Anzeige, 7, zugnr_Gl6)
		EEPStructureSetTextureText (Anzeige, 8, zugnr_Gl6)
		EEPStructureSetTextureText (Anzeige, 11, zeit_FZUG_1_Gl6)
		EEPStructureSetTextureText (Anzeige, 12, zeit_FZUG_1_Gl6)
		EEPStructureSetTextureText (Anzeige, 13, zugnr_FZUG_1_Gl6)
		EEPStructureSetTextureText (Anzeige, 14, zugnr_FZUG_1_Gl6)
		EEPStructureSetTextureText (Anzeige, 15, ziel_FZUG_1_Gl6)
		EEPStructureSetTextureText (Anzeige, 16, ziel_FZUG_1_Gl6)
		EEPStructureSetTextureText (Anzeige, 19, zeit_FZUG_2_Gl6)
		EEPStructureSetTextureText (Anzeige, 20, zeit_FZUG_2_Gl6)
		EEPStructureSetTextureText (Anzeige, 21, zugnr_FZUG_2_Gl6)
		EEPStructureSetTextureText (Anzeige, 22, zugnr_FZUG_2_Gl6)
		EEPStructureSetTextureText (Anzeige, 23, ziel_FZUG_2_Gl6)
		EEPStructureSetTextureText (Anzeige, 24, ziel_FZUG_2_Gl6)
		EEPStructureSetTextureText (Anzeige, 33, Info_Gl6)
	end
end
function zeitrechnen6()
	FZUG1_6 = select(2,EEPLoadData(601))
	DPos1_6 = select(2,EEPLoadData(602))
	FZUG2_6 = select(2,EEPLoadData(603))
	DPos2_6 = select(2,EEPLoadData(604))
	zeit_ZZ6 = select(2,EEPLoadData(605))										-- Zeitstring aus Slot lesen
	if string.len(zeit_ZZ6) == 17 then												-- wenn der Zeitstring mindestens 5 Zeichen hat (eine Zeit gespeichert ist)
		zeit_Gl6 = string.sub(zeit_ZZ6,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl6 = string.sub(zeit_ZZ6,7,12)
		zeit_FZUG_2_Gl6 = string.sub(zeit_ZZ6,13,18)
	elseif string.len(zeit_ZZ6) == 11 then
		zeit_Gl6 = string.sub(zeit_ZZ6,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl6 = string.sub(zeit_ZZ6,7,12)
		zeit_FZUG_2_Gl6 = ""
	elseif string.len(zeit_ZZ6) == 5 then
		zeit_Gl6 = string.sub(zeit_ZZ6,1,5)											-- Abfahrtszeit aus dem Zeitstring kürzen
		zeit_FZUG_1_Gl6 = ""
		zeit_FZUG_2_Gl6 = ""
	else
		zeit_Gl6 = ""
		zeit_FZUG_1_Gl6 = ""
		zeit_FZUG_2_Gl6 = ""
	end
end
function zeitrechnen6_2()
	if zeit_Gl6 == "" then														-- wenn keine Abfahrtszeit gefunden
		zeit_Gl6 = string.format("%02d:%02d", EEPTimeH, EEPTimeM  + Ankanz)		-- Abfahrtszeit = EEPZeit + Verzögerung für Anfahrt
		if EEPTimeM  + Ankanz >= 60 then										-- volle Stunde überschritten
			zeit_Gl6 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM  + Ankanz - 60)	-- dann den Wert für die Stunde um 1 erhöhen und Minutenwert -60
		end
		if EEPTimeH + 1 > 23 then 															-- wenn der Stundenwert größer als 23 (neuer Tag)
			zeit_Gl6 = string.format("%02d:%02d", EEPTimeH - 23 , EEPTimeM  + Ankanz - 60)	-- den Stundenwert um 23 reduzieren
		end
		zeit_ZZ6 = zeit_Gl6														-- den Zeitstring mit der Abfahrtszeit beschreiben
	end
	if FZUG1_6 ~= "" then																						-- wenn ein Folgezug gespeichert ist
		if zeit_FZUG_1_Gl6 == "" then
			zeit_FZUG_1_Gl6 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos1_6  * ZZATimer)					-- die Abfahrtszeit errechnen
			if EEPTimeM + DPos1_6  * ZZATimer >= 60 then
				zeit_FZUG_1_Gl6 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos1_6  * ZZATimer) - 60)	--s.o.
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_1_Gl6 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_6  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ6 = zeit_ZZ6..","..zeit_FZUG_1_Gl6								-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_1_Gl6 = FZUG1_6
		if FZUG1_6 == "RB30" then
			ziel_FZUG_1_Gl6 = "Nürnberg Hbf"
		elseif FZUG1_6 == "RE41" then
			ziel_FZUG_1_Gl6 = "Nürnberg Hbf"
		end
	else
		zeit_FZUG_1_Gl6 = ""
		zugnr_FZUG_1_Gl6 = ""
		ziel_FZUG_1_Gl6 = ""
	end
	if FZUG2_6 ~= "" then																						-- wenn ein 2. Folgezug gespeichert ist
		if zeit_FZUG_2_Gl6 == "" then
			zeit_FZUG_2_Gl6 = string.format("%02d:%02d", EEPTimeH, EEPTimeM + DPos2_6  * ZZATimer)					-- Abfahrtszeit errechnen
			if EEPTimeM + DPos2_6  * ZZATimer >= 60 then
				zeit_FZUG_2_Gl6 = string.format("%02d:%02d", EEPTimeH + 1, EEPTimeM + (DPos2_6  * ZZATimer) - 60)
			end
			if EEPTimeH + 1 > 23 then
				zeit_FZUG_2_Gl6 = string.format("%02d:%02d", EEPTimeH - 23, EEPTimeM + (DPos1_6  * ZZATimer) - 60)	--s.o.
			end
			zeit_ZZ6 = zeit_ZZ6..","..zeit_FZUG_2_Gl6						-- den Zeitstring mit der Abfahrtszeit beschreiben
		end
		zugnr_FZUG_2_Gl6 = FZUG2_6
		if FZUG2_6 == "RB30" then
			ziel_FZUG_2_Gl6 = "Nürnberg Hbf"
		elseif FZUG2_6 == "RE41" then
			ziel_FZUG_2_Gl6 = "Nürnberg Hbf"
		end
	else
		zeit_FZUG_2_Gl6 = ""
		zugnr_FZUG_2_Gl6 = ""
		ziel_FZUG_2_Gl6 = ""
	end
end

function RB_30_2 ()
	zeitrechnen6()
	ok, TZZA6 = EEPStructureGetTagText("#122")
	if TZZA6 ~= "leer" then
		Gl6schreibdaten(FZUG1_6,DPos1_6,FZUG2_6,DPos2_6)
	elseif TZZA6 == "leer" then
		ziel_Gl6 = "Nürnberg Hbf"
		zwziel_Gl6 = "Neunkirchen a Sand - Nürnberg Ost"
		zeitrechnen6_2()
		zugnr_Gl6 = "RB30"
		Info_Gl6 = ""
		ZZA_Gl6 (ziel_Gl6, zwziel_Gl6, zeit_Gl6, zugnr_Gl6, 
		zeit_FZUG_1_Gl6, zugnr_FZUG_1_Gl6, ziel_FZUG_1_Gl6, zeit_FZUG_2_Gl6, zugnr_FZUG_2_Gl6, ziel_FZUG_2_Gl6, Info_Gl6) 
		EEPStructureSetTagText("#122",zeit_ZZ6)
	end
end 



function RE_41 ()
	zeitrechnen6()
	ok, TZZA6 = EEPStructureGetTagText("#122")
	if TZZA6 ~= "leer" then
		Gl6schreibdaten(FZUG1_6,DPos1_6,FZUG2_6,DPos2_6)
	elseif TZZA6 == "leer" then
		ziel_Gl6 = "Nürnberg Hbf"
		zwziel_Gl6 = ""
		zeitrechnen6_2()
		zugnr_Gl6 = "RE 41"
		Info_Gl6 = ""
		ZZA_Gl6 (ziel_Gl6, zwziel_Gl6, zeit_Gl6, zugnr_Gl6, 
		zeit_FZUG_1_Gl6, zugnr_FZUG_1_Gl6, ziel_FZUG_1_Gl6, zeit_FZUG_2_Gl6, zugnr_FZUG_2_Gl6, ziel_FZUG_2_Gl6, Info_Gl6) 
		EEPStructureSetTagText("#122",zeit_ZZ6)
	end	
end 
function Gl6_aus ()
	tagzeit6 = select(2,EEPStructureGetTagText("#122"))				-- Zeitstring lesen
	FZazeit6 = string.sub(tagzeit6,7,string.len(tagzeit6))			-- Abfahrtszeit 1. Folgezug errechnen
	FZbzeit6 = string.sub(FZazeit6,7,string.len(FZazeit6))			-- Abfahrtszeit 2. Folgezug errechnen
	EEPStructureSetTagText("#122","leer")
	DPos1_6 = select(2,EEPLoadData(602))
	FZUG2_6 = select(2,EEPLoadData(603))
	DPos2_6 = select(2,EEPLoadData(604))
	if DPos1_6 ~= 0 then
		zeit_Gl6 = FZazeit6
	else
		zeit_Gl6 = ""
	end
	EEPSaveData(601,FZUG2_6)
	EEPSaveData(602,DPos2_6)
	EEPSaveData(603,"")
	EEPSaveData(604,0)
	EEPSaveData(605,FZazeit6)		
	if FZUG1_6 == "RB30" then 
		RB_30_2()
	elseif FZUG1_6 == "RE41" then 
		RE_41()
	else
		ziel_Gl6 = ""
		zwziel_Gl6 = ""
		zeit_Gl6 = ""
		zugnr_Gl6 = ""
		zeit_FZUG_1_Gl6 = ""
		zugnr_FZUG_1_Gl6 = ""
		ziel_FZUG_1_Gl6 = ""
		zeit_FZUG_2_Gl6 = ""
		zugnr_FZUG_2_Gl6 = ""
		ziel_FZUG_2_Gl6 = ""
		Info_Gl6 = ""
		ZZA_Gl6 (ziel_Gl6, zwziel_Gl6, zeit_Gl6, zugnr_Gl6, 
		zeit_FZUG_1_Gl6, zugnr_FZUG_1_Gl6, ziel_FZUG_1_Gl6, zeit_FZUG_2_Gl6, zugnr_FZUG_2_Gl6, ziel_FZUG_2_Gl6, Info_Gl6) 
	end
end
--=============================================================================================
-- Datenslots für die Anzeigen an ZZA Gleis 
function gl1schreibdaten (FZUG1_1,DPos1_1,FZUG2_1,DPos2_1)	-- Daten in Zwischenspeicher schreiben wenn in der Anzeige noch etwas steht
	EEPSaveData(101,FZUG1_1) 								-- Folgezug 1 für Gleis 1 in Slot 101 schreiben
	EEPSaveData(102,DPos1_1) 								-- Position des 1. Zugs in der Depotliste in Slot 102 schreiben
	EEPSaveData(103,FZUG2_1) 								-- Folgezug 2 für Gleis 1 in Slot 103 schreiben
	EEPSaveData(104,DPos2_1) 								-- Position des 2. Zugs in der Depotliste in Slot 104 schreiben
end
function gl2schreibdaten (FZUG1_2,DPos1_2,FZUG2_2,DPos2_2)
	EEPSaveData(201,FZUG1_2)
	EEPSaveData(202,DPos1_2)
	EEPSaveData(203,FZUG2_2)
	EEPSaveData(204,DPos2_2)
end
function Gl5schreibdaten (FZUG1_5,DPos1_5,FZUG2_5,DPos2_5)
	EEPSaveData(501,FZUG1_5)
	EEPSaveData(502,DPos1_5)
	EEPSaveData(503,FZUG2_5)
	EEPSaveData(504,DPos2_5)
end
function Gl6schreibdaten (FZUG1_6,DPos1_6,FZUG2_6,DPos2_6)
	EEPSaveData(601,FZUG1_6)
	EEPSaveData(602,DPos1_6)
	EEPSaveData(603,FZUG2_6)
	EEPSaveData(604,DPos2_6)
end
print("Script ZZA_Diorama Version 1.0 wurde eingebunden")