--[[
Lua-Aufrufe in Kontakten (Ermittelt über https://frankbuchholz.github.io/EEP_convert_anl3_file/EEP_Inventar.html ):

Gl1_aus	Eisenbahn 109	

Gl2_aus	Eisenbahn 67	

ZZA_Gl3_ein	Eisenbahn 6		
ZZA_Gl3_aus	Eisenbahn 99	

ZZA_Gl4_ein	Eisenbahn 230	
ZZA_Gl4_aus	Eisenbahn 63	

Gl5_aus	Eisenbahn 253	

Gl6_aus	Eisenbahn 71	
--]]

if log then print("Script 'ZZA_Diorama' Version 1.2 wird geladen") end

----------------------------------- Zeitmodifikatoren für Folgezüge im ZZA

local ZZATimer = 2	-- Der Faktor, der hier steht wird verwendet, um die Berechnung der Zeit für den nächsten Zug durchzuführen
local Ankanz = 2	-- Der hier eingestellte Dauer in Minuten wird bei der Anzeige der Zeit im ZZA hinzu addiert (kann je nach Streckenlänge variieren)

----------------------------------- Daten-Slots je Gleis

GleisSlots = {	-- Speicherslots
	-- [Gleis] = { Liste der Slots }
	[1] = { AnkunftZeiten = 105, FRoute1 = 101, DPos1 = 102, FRoute2 = 103, DPos2 = 104 },
	[2] = { AnkunftZeiten = 205, FRoute1 = 201, DPos1 = 202, FRoute2 = 203, DPos2 = 204 },
	[3] = { AnkunftZeiten = 305, FRoute1 = 301, DPos1 = 302, FRoute2 = 303, DPos2 = 304 },
	[4] = { AnkunftZeiten = 405, FRoute1 = 401, DPos1 = 402, FRoute2 = 403, DPos2 = 404 },
	[5] = { AnkunftZeiten = 505, FRoute1 = 501, DPos1 = 502, FRoute2 = 503, DPos2 = 504 },
	[6]	= { AnkunftZeiten = 605, FRoute1 = 601, DPos1 = 602, FRoute2 = 603, DPos2 = 604 },
}

-- Daten-Slots schreiben / lesen 
function schreibeDaten (Gleis, AnkunftZeiten, FRoute1, DPos1, FRoute2, DPos2)
	local Slots = GleisSlots[Gleis]
	assert(Slots, "schreibeDaten "..Gleis.."\n"..debug.traceback())
	
	if AnkunftZeiten then 
		EEPSaveData( Slots.AnkunftZeiten, AnkunftZeiten ) 			-- Ankunftszeit
	end

	EEPSaveData( Slots.FRoute1, FRoute1 ) 							-- Folgezug 1 
	EEPSaveData( Slots.DPos1, DPos1 ) 								-- Position des 1. Zugs in der Depotliste 

	EEPSaveData( Slots.FRoute2, FRoute2 ) 							-- Folgezug 2 
	EEPSaveData( Slots.DPos2, DPos2 ) 								-- Position des 2. Zugs in der Depotliste 
end

function leseDaten (Gleis)
	local Slots = GleisSlots[Gleis]
	
	AnkunftZeiten = select(2,EEPLoadData( Slots.AnkunftZeiten )) 	-- Ankunftszeit

	FRoute1 = select(2,EEPLoadData( Slots.FRoute1 )) 				-- Folgezug 1 
	DPos1 = select(2,EEPLoadData( Slots.DPos1 )) 					-- Position des 1. Zugs in der Depotliste 

	FRoute2 = select(2,EEPLoadData( Slots.FRoute2 )) 				-- Folgezug 2 
	DPos2 = select(2,EEPLoadData( Slots.DPos2 )) 					-- Position des 2. Zugs in der Depotliste 
	
	return AnkunftZeiten, FRoute1, DPos1, FRoute2, DPos2 
end

----------------------------------- Depots und Routen von Bahnhof Hersbruck

DepotWest = 1
DepotOst  = 2

Routen = { 	-- Routen je Depot der Personenzüge ab Bahnhof Hersbruck (keine Güterzüge]
			-- Die Zugnummern, Zwischenziele, Ziele und die Info (Laufschrift) können geändert werden, nicht jedoch die Gleiszuordnungen!
	[DepotWest] = {
		-- [RouteId] = { Liste der Daten zu einer Route }
		["RB_30"] = {		-- Von West nach Ost	2 Züge mit Route RB_30 im Depot West
			Gleis 			= 1,
			Zugnummer 		= "RB30",
			Zwischenziel 	= "Vorra(Pegnitz) - Velden(b Hersbruck)",	
			Ziel 			= "Neuhaus(Pegnitz)",
			Info			= "",
		},
		["RB_30_1"] = {		-- Von West nach Ost 	2 Züge mit Route RB_30_1 im Depot West
			Gleis 			= 5,
			Zugnummer 		= "RB30",
			Zwischenziel 	= "Hohenstadt(Mittelfr) - Rupprechtstegen",
			Ziel 			= "Neuhaus(Pegnitz)",
			Info			= "",
		},
		["RE_32"] = {		-- Von West nach Ost 	2 Züge mit Route RE_32 im Depot West
			Gleis 			= 5,
			Zugnummer 		= "RE32",
			Zwischenziel 	= "Pegnitz - Bayreuth Hbf - Kulmbach",
			Ziel 			= "Lichtenfels",
			Info			= "Erster Halt in Pregniz",
		},
		["RE_40"] = {		-- Von West nach Ost 	2 Züge mit Route RE_40 im Depot West
			Gleis 			= 1,
			Zugnummer 		= "RE40",
			Zwischenziel 	= "Neukirchen(b Sulzb) - Sulzbach-Rosenberg",
			Ziel 			= "Regensburg Hbf",
			Info			= "",
		},
	},
	[DepotOst] = {		
		["RB_30"] = {		-- Von Ost nach West	2 Züge mit Route RB_30 im Depot Ost
			Gleis 			= 6,
			Zugnummer 		= "RB30",
			Zwischenziel 	= "Neunkirchen a Sand - Nürnberg Ost",
			Ziel 			= "Nürnberg Hbf",
			Info			= "",
		},
		["RE_40"] = {		-- Von Ost nach West 	2 Züge mit Route RE_40 im Depot Ost
			Gleis 			= 2,
			Zugnummer 		= "RE40",
			Zwischenziel 	= "Lauf rechts Pegnitz",
			Ziel 			= "Nürnberg Hbf",
			Info			= "",
		},
		["RE_41"] = {		-- Von Ost nach West	2 Züge mit Route RE_41 im Depot Ost
			Gleis 			= 6,
			Zugnummer 		= "RE41",
			Zwischenziel 	= "",
			Ziel 			= "Nürnberg Hbf",
			Info			= "Kein Zwischenhalt bis Nürnberg HbF",
		},
		["RE_47"] = {		-- Von Ost nach West	2 Züge mit Route RE_47 im Depot Ost
			Gleis 			= 2,
			Zugnummer 		= "RE47",
			Zwischenziel 	= "",
			Ziel 			= "Nürnberg Hbf",
			Info			= "Kein Zwischenhalt bis Nürnberg HbF",
		},
	},
}

----------------------------------- Bahnsteigschilder

-- Initialisierung der Bahnsteigschilder
local Bahnsteigschilder = {	-- Modell SAATDB2 aus Set V15NDB20015 
	-- [Gleis] = { Liste der Bahnsteigschilder }
	--      A (vorne)     B             C             D              E (hinten)
	[1] = { "#51", "#50", "#49", "#48", "#47", "#46", "#44", "#43",  "#41", "#40", },
	[2] = { "#61", "#60", "#59", "#58", "#57", "#56", "#54", "#53",  "#52", "#45", },
	[3] = { "#71", "#70", "#69", "#68", "#67", "#66", "#64", "#63",  "#62", "#55", },
	[4] = { "#65", "#72", "#73", "#74", "#76", "#77", "#78", "#79",  "#80", "#81", },
	[5] = { "#91", "#90", "#89", "#88", "#87", "#86", "#84", "#83",  "#82", "#75", },
	[6] = { "#94", "#93", "#92", "#85", "#97", "#96", "#95", "#100", "#99", "#98", },	
	
}
-- Initialisierung: Bahnsteigschilder mit den passenden Bahnsteigabschnitten versehen 
local Bahnsteigabschnitte = "AABBCCDDEE" -- Zur Prüfung der korrekten Reihenfolge kann "AaBbCcDdEeXx" verwendet werden.
for Gleis, Schilder in pairs(Bahnsteigschilder) do
	for position, Schild in ipairs(Schilder) do -- Hier ist ipairs wichtig, um die Reihenfolge einzuhalten
		local Bahnsteigabschnitt = string.sub(Bahnsteigabschnitte, position, position)	-- Einen Buchstaben exrahieren
		local ok = EEPStructureSetTextureText( Schild, 1, Bahnsteigabschnitt )
		assert(ok, "Gleis "..Gleis.."-"..position.." Schild "..Schild.." '"..Bahnsteigabschnitt.."' nicht gefunden")
		
		-- Zeige zur Kontrolle die Daten im Tipp-Text
		if log then 
			--EEPChangeInfoStructure( Schild, "Gleis "..Gleis.."-"..position.." "..Schild.." "..Bahnsteigabschnitt)
			EEPShowInfoStructure( Schild, true )
		else 
			EEPChangeInfoStructure( Schild, "" )
			EEPShowInfoStructure( Schild, false )
		end
	end
end

----------------------------------- Hilfsfunktionen für Zeitberechnungen

local function ZeitstringTeilen (Zeitstring)		-- Zeitstring mit bis zu 3 Angaben in einzelne Variablen aufteilen
													--  12345678901234567
													-- "15:30,15:32,15:35"
	local zeit1 = ""
	if string.len(Zeitstring) >= 5 then				-- wenn der Zeitstring mind. 1 Zeitangabe enthält
		zeit1 	= string.sub( Zeitstring, 1, 5 )	-- 1. Abfahrtszeit aus dem Zeitstring extrahieren
	end

	local zeit2 = ""
	if string.len(Zeitstring) >= 11 then			-- wenn der Zeitstring mind. 2 Zeitangaben enthält
		zeit2 = string.sub( Zeitstring, 7, 11 )		-- 2. Abfahrtszeit aus dem Zeitstring extrahieren
	end

	local zeit3 = ""
	if string.len(Zeitstring) >= 17 then			-- wenn der Zeitstring mind. 3 Zeitangaben enthält
		zeit3 = string.sub( Zeitstring, 13, 17 )	-- 3. Abfahrtszeit aus dem Zeitstring extrahieren
	end
	
	return zeit1, zeit2, zeit3
end

local function Zeitverzoegerung (Minuten)
	local h = EEPTimeH
	local m = EEPTimeM + Minuten
	while (m >= 60) do						-- Wenn volle Stunde überschritten
		h = h + 1							-- dann den Wert für die Stunde erhöhen und Minutenwert reduzieren
		m = m - 60					
	end
	if h >= 24 then 						-- Wenn voller Tag überschritten
		h = h % 24 							-- dann den Wert für die Stunde reduzieren
	end
	local Zeit = string.format("%02d:%02d", h, m)
	return Zeit
end	

local function zeitrechnen (Gleis)
	local AnkunftZeiten, FRoute1, DPos1, FRoute2, DPos2 = leseDaten(Gleis)
	local zeit, zeit_FZUG1, zeit_FZUG2 = ZeitstringTeilen(AnkunftZeiten) 	-- Zeitstring aufteilen (z.B. aus "15:30,15:32,15:35")
	
	if zeit == "" then												-- wenn keine Abfahrtszeiten gefunden
		zeit = Zeitverzoegerung( Ankanz )							-- Abfahrtszeit = EEPZeit + Verzögerung für Anfahrt
	end
	AnkunftZeiten = zeit											-- den Zeitstring mit der Abfahrtszeit beschreiben
	
	if FRoute1 ~= "" then											-- wenn ein Folgezug gespeichert ist
		if zeit_FZUG1 == "" then
			zeit_FZUG1 = Zeitverzoegerung( DPos1 * ZZATimer )		-- Abfahrtszeit = EEPZeit + Verzögerung für Anfahrt
		end	
		AnkunftZeiten = AnkunftZeiten..","..zeit_FZUG1				-- den Zeitstring mit der Abfahrtszeit beschreiben
	end
	
	if FRoute2 ~= "" then											-- wenn ein 2. Folgezug gespeichert ist
		if zeit_FZUG2 == "" then
			zeit_FZUG2 = Zeitverzoegerung( DPos2 * ZZATimer )		-- Abfahrtszeit = EEPZeit + Verzögerung für Anfahrt
		end
		AnkunftZeiten = AnkunftZeiten..","..zeit_FZUG2				-- den Zeitstring mit der Abfahrtszeit beschreiben
	end

	--if log then print("Function zeitrechnen: AnkunftZeiten (",string.len(AnkunftZeiten),") = '",AnkunftZeiten,"'") end
	
	schreibeDaten(Gleis, AnkunftZeiten, FRoute1, DPos1, FRoute2, DPos2)
	
	return AnkunftZeiten, FRoute1, DPos1, FRoute2, DPos2
end

----------------------------------- Zugzielanzeigetafeln

Zugzielanzeigetafeln = {	-- Modell ZZA6CDB2 aus Set V15NDB20015
	-- [Gleis] = { Liste der Anzeigetafeln West, Mitte, Ost }
	[1] = { "#101", "#102", "#105", },	-- Gleis 1
	[2] = { "#106", "#109", "#110", },	-- Gleis 2
	[3] = { "#103", "#108", "#112", },	-- Gleis 3
	[4] = { "#119", "#117", "#113", },	-- Gleis 4
	[5] = { "#121", "#118", "#115", },	-- Gleis 5
	[6] = { "#122", "#125", "#128", },	-- Gleis 6
}

-- Funktionen für Zuganzeige Modell ZZA6CDB2 aus Set V15NDB20015
-- https://eepshopping.de/docs/V15NDB20015_PDF.pdf

-- Umfangreiche Anzeige incl. Folgezüge auf Zugzielanzeigetafel
local function ZZA_aktualisieren (Gleis,
		ziel, zwziel, zeit, zugnr,
		zeit_FZUG1, zugnr_FZUG1, ziel_FZUG1, 
		zeit_FZUG2, zugnr_FZUG2, ziel_FZUG2, 
		Info
	)

	-- Nach dem Neuladen des Skrips ist manchmal diese Variable nicht definiert
	if not ziel_FZUG2 then
		print("\nziel_FZUG2 = nil\n"..debug.traceback())
		ziel_FZUG2 = "NIL"
	end
	
	-- Protokollierung der Zuganzeige im Ereignisfenster und im Tipp-Text
	local Anzeige = Zugzielanzeigetafeln[Gleis][1] -- West
	if log then
		-- Ausführlich im Ereignisprotokoll
		local Text = "| ZZA Gleis " .. Gleis 
			.. "\n| Ziel: " .. zeit       .. " " .. zugnr       .. " " .. ziel  .. (zwziel ~= "" and " via " .. zwziel or "")      
			.. "\n| Zug 1: " .. zeit_FZUG1 .. " " .. zugnr_FZUG1 .. " " .. ziel_FZUG1
			.. "\n| Zug 2: " .. zeit_FZUG2 .. " " .. zugnr_FZUG2 .. " " .. ziel_FZUG2
			.. (Info and Info ~= "" and ("\n| " .. Info) or "")
		print( Text )
		
		-- Kurzform im Tipp-Text
		-- <j> linkbündig, <c> zentriert, <r> rechtsbündig, <br> Zeilenwechsel 
		-- <b>Fett</b>, <i>Kursiv</i>, <fgrgb=0,0,0> Schriftfarbe, <bgrgb=0,0,0> Hintergrundfarbe
		-- siehe https://www.eepforum.de/forum/thread/34860-7-6-3-tipp-texte-f%C3%BCr-objekte-und-kontaktpunkte/
		Text = "<fgrgb=0,0,255>"  	-- blau, (default: Blocksatz)
			.. "Gleis " .. Gleis
			.. "<fgrgb=0,0,0><j>"	-- schwarz, linksbündig
			.. "<br><b>" .. zeit    .. " " .. zugnr       .. " " .. ziel .. "</b>" 
			.. "<br>" .. zeit_FZUG1 .. " " .. zugnr_FZUG1 .. " " .. ziel_FZUG1
			.. "<br>" .. zeit_FZUG2 .. " " .. zugnr_FZUG2 .. " " .. ziel_FZUG2 
		EEPChangeInfoStructure( Anzeige, Text )
		EEPShowInfoStructure( Anzeige, true )
	else	
		EEPChangeInfoStructure( Anzeige, "" )
		EEPShowInfoStructure( Anzeige, false )
	end

	for _, Anzeige in pairs(Zugzielanzeigetafeln[Gleis]) do
		EEPStructureSetTextureText( Anzeige, 1, ziel )			-- Zugziel
		EEPStructureSetTextureText( Anzeige, 2, ziel )
		EEPStructureSetTextureText( Anzeige, 3, zwziel )		-- Zwischenziele
		EEPStructureSetTextureText( Anzeige, 4, zwziel )
		EEPStructureSetTextureText( Anzeige, 5, zeit )			-- Zeit
		EEPStructureSetTextureText( Anzeige, 6, zeit )
		EEPStructureSetTextureText( Anzeige, 7, zugnr )			-- Zugnummer
		EEPStructureSetTextureText( Anzeige, 8, zugnr )
--		EEPStructureSetTextureText( Anzeige, 9, <text> )		-- Wagenlauf
--		EEPStructureSetTextureText( Anzeige, 10, <text> ) 
		EEPStructureSetTextureText( Anzeige, 11, zeit_FZUG1 )	-- Zeit Folgezug 1
		EEPStructureSetTextureText( Anzeige, 12, zeit_FZUG1 )
		EEPStructureSetTextureText( Anzeige, 13, zugnr_FZUG1 )	-- Zugnummer Folgezug 1
		EEPStructureSetTextureText( Anzeige, 14, zugnr_FZUG1 )
		EEPStructureSetTextureText( Anzeige, 15, ziel_FZUG1 )	-- Ziel Folgezug 1
		EEPStructureSetTextureText( Anzeige, 16, ziel_FZUG1 )
		EEPStructureSetTextureText( Anzeige, 17, "Gute Reise" )	-- Information Folgezug 1 (weiße Box)
		EEPStructureSetTextureText( Anzeige, 18, "Gute Reise" )
		EEPStructureSetTextureText( Anzeige, 19, zeit_FZUG2 )	-- Zeit Folgezug 2
		EEPStructureSetTextureText( Anzeige, 20, zeit_FZUG2 )
		EEPStructureSetTextureText( Anzeige, 21, zugnr_FZUG2 )	-- Zugnummer Folgezug 2
		EEPStructureSetTextureText( Anzeige, 22, zugnr_FZUG2 )
		EEPStructureSetTextureText( Anzeige, 23, ziel_FZUG2 )	-- Ziel Folgezug 2
		EEPStructureSetTextureText( Anzeige, 24, ziel_FZUG2 )
		EEPStructureSetTextureText( Anzeige, 25, "Bon Voyage" )	-- Information Folgezug 2 (weiße Box)
		EEPStructureSetTextureText( Anzeige, 26, "Bon Voyage" )
--		EEPStructureSetTextureText( Anzeige, 27, <text> )		-- Bahnsteigabschnitte
--		EEPStructureSetTextureText( Anzeige, 28, <text> )
		EEPStructureSetTextureText( Anzeige, 29, Gleis )		-- Gleisnummer
		EEPStructureSetTextureText( Anzeige, 30, Gleis )
--		EEPStructureSetTextureText( Anzeige, 31, <text> )		-- Überschrift "Folgezüge"
--		EEPStructureSetTextureText( Anzeige, 32, <text> )
		EEPStructureSetTextureText( Anzeige, 33, Info )			-- Infotext (Laufschrift)
	end
end

-- Durchfahrtsanzeige auf Zugzielanzeigetafel
local function ZZA_Durchfahrtsinfo (Gleis, Zugtyp)

	-- Protokollierung der Zuganzeige
	local Anzeige = Zugzielanzeigetafeln[Gleis][1] -- West
	if log then
		local Text = "Gleis " .. Gleis .. " Durchfahrt " .. Zugtyp
		-- Protokollierung im Ereignisfenster
		print( "| ZZA " .. Text )
		-- Protokollierung im Tipp-Text
		EEPChangeInfoStructure( Anzeige, Text )
		EEPShowInfoStructure( Anzeige, true )
	else	
		EEPChangeInfoStructure( Anzeige, "" )
		EEPShowInfoStructure( Anzeige, false )
	end

	for k, Anzeige in pairs(Zugzielanzeigetafeln[Gleis])do
		-- Alle Felder löschen
		for Feld = 1, 33 do
			EEPStructureSetTextureText( Anzeige, Feld, "" )
		end	
		-- Text anzeigen
		EEPStructureSetTextureText( Anzeige, 1, "Durchfahrt " .. Zugtyp )					-- Zugziel
		EEPStructureSetTextureText( Anzeige, 2, "Durchfahrt " .. Zugtyp )
		EEPStructureSetTextureText( Anzeige, 3, "Bitte Vorsicht" )							-- Zwischenziele
		EEPStructureSetTextureText( Anzeige, 4, "Bitte Vorsicht" )
		EEPStructureSetTextureText( Anzeige, 33, "Zurücktreten von der Bahnsteigkante" )	-- Infotext (Laufschrift)
	end
end

-- Anzeigetafel löschen
local function ZZA_aus (Gleis)
	-- Protokollierung im Ereignisfenster
	if log then
		print("Gleis ", Gleis, " Anzeige aus")
	end
	local Anzeige = Zugzielanzeigetafeln[Gleis][1] -- West
	EEPChangeInfoStructure( Anzeige, "" )
	EEPShowInfoStructure( Anzeige, false )

	-- Alle Felder löschen
	for _, Anzeige in pairs(Zugzielanzeigetafeln[Gleis])do
		for Feld = 1, 33 do
			-- Anzeigetafel
			local ok = EEPStructureSetTextureText( Anzeige, Feld, "" )
			assert(ok, "ERROR: EEPStructureSetTextureText( "..Anzeige..") "..tostring(ok))
		end	
	end
end

-- Ziele der Folgezüge bestimmen und ZZA aktualisieren
function ZZA_berechnen (Depot, RouteId)
	local Route = Routen[Depot][RouteId]
	local Gleis = Route.Gleis
	local Anzeigetafel = Zugzielanzeigetafeln[Gleis][1]								-- Erste Anzeigetafel des Gleises

	local ok, ZZA_Tag = EEPStructureGetTagText( Anzeigetafel )						-- TagTaxt aus ZZA lesen
	if ZZA_Tag == "leer" then														-- Wenn die Anzeige leer ist
		local AnkunftZeiten, FRoute1, DPos1, FRoute2, DPos2 = zeitrechnen(Gleis)	-- Ankunftzeiten neu berechnen
		EEPStructureSetTagText( Anzeigetafel, AnkunftZeiten )						-- Speichere Ankunftzeiten zusätzlich als TagText
		
		local zeit, zeit_FZUG1, zeit_FZUG2 = ZeitstringTeilen(AnkunftZeiten) 		-- Zeitstring aufteilen (z.B. aus "15:30,15:32,15:35")

		-- Zugnummern ermitteln
		local zugnr_FZUG1 = ""
		if Routen[Depot][FRoute1] then zugnr_FZUG1 = Routen[Depot][FRoute1].Zugnummer end
		
		local zugnr_FZUG2 = ""
		if Routen[Depot][FRoute2] then zugnr_FZUG2 = Routen[Depot][FRoute2].Zugnummer end
		
		-- Ziele für die Folgezüge je nach Route
		local ziel_FZUG1 = ""
		if FRoute1 ~= "" then
			ziel_FZUG1 = Routen[Depot][FRoute1].Ziel
			if log then print("Depot ",Depot," FRoute1 ",FRoute1," FRoute1 ",FRoute1," ziel_FZUG1 ",ziel_FZUG1) end
		end

		local ziel_FZUG2 = ""
		if FRoute2 ~= "" then
			ziel_FZUG2 = Routen[Depot][FRoute2].Ziel
			if log then print("Depot ",Depot," FRoute2 ",FRoute2," FRoute2 ",FRoute2," ziel_FZUG2 ",ziel_FZUG1) end
		end

		ZZA_aktualisieren (Gleis, 
			Route.Ziel, Route.Zwischenziel, zeit, Route.Zugnummer, 
			zeit_FZUG1, zugnr_FZUG1, ziel_FZUG1, 
			zeit_FZUG2, zugnr_FZUG2, ziel_FZUG2, 
			Route.Info)
	end
end

-- Ausschalten oder Weiterschalten der ZZA
function ZZA_Ausfahrt (Depot, Gleis)												
	local Anzeigetafel = Zugzielanzeigetafeln[Gleis][1]						-- Erste Anzeigetafel des Gleises

	local AnkunftZeiten, FRoute1, DPos1, FRoute2, DPos2 = leseDaten( Gleis )
	local zeit, zeit_FZUG1, zeit_FZUG2 = ZeitstringTeilen(AnkunftZeiten) 	-- Zeitstring aufteilen (z.B. aus "15:30,15:32,15:35")

	if zeit_FZUG2 == "" then		-- Im Zeitstring den aktuellen Zug entfernen und die Folgezüge nach vorne holen
		AnkunftZeiten = zeit_FZUG1
	else
		AnkunftZeiten = zeit_FZUG1 .. "," .. zeit_FZUG2
	end

	schreibeDaten(Gleis, AnkunftZeiten, FRoute2, DPos2, "", 0)				-- den Folgezug nach vorne holen und den 2. Folgezug löschen

	EEPStructureSetTagText( Anzeigetafel, "leer" )							-- Je nach Folgezug, die Zuganzeige aktualisieren
	if FRoute1 ~= "" then 
		ZZA_berechnen( Depot, FRoute1 )
	else
		ZZA_aus( Gleis )
	end
end

-- Initialisierung der Anzeigetafeln
for Gleis, _ in pairs(Zugzielanzeigetafeln) do
	--ZZA_aus(Gleis)
end

----------------------------------- Ausfahrtsfunktionen, die über Kontakte ausgelöst werden

-- Aufruf über Kontakt auf Eisenbahn 109 (Ausfahrt Gleis 1)
function Gl1_aus ()													-- Ausschalten oder Weiterschalten der ZZA
	--if log then print("Gl1_aus") end
	local Gleis = 1
	ZZA_Ausfahrt(DepotWest, Gleis)
end

-- Aufruf über Kontakt auf Eisenbahn 67 (Ausfahrt Gleis 2)
function Gl2_aus ()
	--if log then print("Gl2_aus") end
	local Gleis = 2
	ZZA_Ausfahrt(DepotOst, Gleis)
end

-- Aufruf für Route 'Gueter' über Kontakt auf Eisenbahn 6 (Ausfahrt aus Depot West)
function ZZA_Gl3_ein ()
	local Gleis = 3
	ZZA_Durchfahrtsinfo(Gleis, "Güterzug")
end

-- Aufruf über Kontakt auf Eisenbahn 99 (Ausfahrt Gleis 3)
function ZZA_Gl3_aus ()
	local Gleis = 3
	ZZA_aus(Gleis)
end

-- Aufruf für Route 'Gueter' über Kontakt auf Eisenbahn 230 (Ausfahrt aus Depot Ost)
function ZZA_Gl4_ein ()
	local Gleis = 4
	ZZA_Durchfahrtsinfo(Gleis, "Güterzug")
end

-- Aufruf über Kontakt auf Eisenbahn 63 (Ausfahrt Gleis 4)
function ZZA_Gl4_aus ()
	local Gleis = 4
	ZZA_aus(Gleis)
end

-- Aufruf über Kontakt auf Eisenbahn 253 (Ausfahrt Gleis 5)
function Gl5_aus ()
	--if log then print("Gl5_aus") end
	local Gleis = 5
	ZZA_Ausfahrt(DepotWest, Gleis)
end

-- Aufruf über Kontakt auf Eisenbahn 71 (Ausfahrt Gleis 6)
function Gl6_aus ()
	--if log then print("Gl6_aus") end
	local Gleis = 6
	ZZA_Ausfahrt(DepotOst, Gleis)	
end

