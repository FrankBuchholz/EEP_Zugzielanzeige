--[[
Lua-Aufrufe in Kontakten (Ermittelt über https://frankbuchholz.github.io/EEP_convert_anl3_file/EEP_Inventar.html ):	

slotmin_100		Eisenbahn 31	
slotmin_100		Eisenbahn 32	

Aufruf in EEPMain:

bue1zu
abzweigkontrolle
kr_ampel
strassenlampen
--]]
		
if log then print("Script 'Steuerung_Strassen' Version 1.2 wird geladen") end

----------------------------------- Bahnübergang

local buSlot = 100					-- Slot zur Speicherung der Anzahl Zuege am Bahnübergang 
local buAnmeldenSignal = 61			-- Signal zur Anmeldung von Zügen am Bahnübergang
local buSignal = 55					-- Signal der Schranke
local buStrassen = { 1, 2, }		-- Strassen-IDs für Besetzt-Abfrage des Bahnübergangs

-- Initialisierung: Registriere Strassen für Besetzt-Meldung
for _, TrackId in pairs(buStrassen) do
	EEPRegisterRoadTrack( TrackId )
end

-- Hilfsfunktion: Zeige die Anzahl, der am Bahnübergang angemeldeten Züge
local function buLog ( AnzahlZuege )
	if log and AnzahlZuege > 0 then 
		EEPChangeInfoSignal( buSignal, string.format("%d %s angemeldet", AnzahlZuege, (AnzahlZuege == 1 and "Zug" or "Züge")))
		EEPShowInfoSignal( buSignal, true )
	else
		EEPChangeInfoSignal( buSignal, "" )
		EEPShowInfoSignal( buSignal, false )
	end	
end

local function slotplus_100 () 		-- Erhöhe Anzahl der Züge am Bahnübergang
	local ok, AnzahlZuege = EEPLoadData( buSlot )
	AnzahlZuege = AnzahlZuege + 1
	EEPSaveData( buSlot, AnzahlZuege )
	buLog ( AnzahlZuege )
end

-- Aufruf in Kontakt auf Eisenbahn 31 und 32 (Zugschluss nach Verlassen des Bahnübergangs)
function slotmin_100 () 			-- Vermindere die Anzahl der Züge am Bahnübergang
	local ok, AnzahlZuege = EEPLoadData( buSlot )
	AnzahlZuege = AnzahlZuege - 1
	if AnzahlZuege <= 0 then
		AnzahlZuege = 0
		bue1auf()					-- Schranke öffnen
	end
	EEPSaveData( buSlot, AnzahlZuege )
	buLog ( AnzahlZuege )
end

-- Registriere Signal zur Anmeldung von Zügen am Bahnübergang
EEPRegisterSignal(buAnmeldenSignal)				-- Unsichtbares Signal auf Wasserweg 12
-- Auslösung über Fahrstrasse 22, 26 und 27 der Ausfahrt West und Fahrstrasse 28 der Einfahrt West
_ENV["EEPOnSignal_"..buAnmeldenSignal] = function ( Stellung ) -- statt: function EEPOnSignal_61 ( Stellung )
	--if log then print("EEPOnSignal_"..buAnmeldenSignal.." Stellung=", Stellung) end
	if Stellung == 2 then 						-- Wenn 'Halt'	
		slotplus_100()							-- dann erhöhe Anzahl der Züge am Bahnübergang
		EEPSetSignal( buAnmeldenSignal, 1 )		-- und setze das Signal wieder auf 'Fahrt'
	end
end

-- Aufruf in EEPMain
function bue1zu()
	local ok, AnzahlZuege = EEPLoadData( buSlot )
	if AnzahlZuege > 0 then
		local buBesetzt = false
		for _, TrackId in pairs(buStrassen) do	-- Sind die Strassen noch besetzt?
			local ok, besetzt = EEPIsRoadTrackReserved( TrackId )
			if besetzt then
				buBesetzt = true
			end
		end
		if not buBesetzt then
			EEPSetSignal( buSignal, 2, 1 )		-- Schranke schließen
		end
	end
end

-- Indirekter Aufruf in Kontakt über Funktion slotmin_100 (
function bue1auf()
	EEPSetSignal( buSignal, 1, 1 )				-- Schranke öffnen
end

----------------------------------- Kreuzungen und Kreisverkehr

local Einmuendungen = {
	-- Tabelle, der wartepflichtigen Einmündungen
	-- Die Nummern der Einmündungen (I, II, usw.) sind auf dem Straßenbahnlayer sichtbar.
	-- [Signal] = { Liste der Strassen für die Besetzt-Abfrage zu diesem Signal }

    -- Kreisverkehr
	[103] = { 77, 75, 78, 79, },	-- Nord
	[104] = { 97, 96, 95, 94, },	-- Ost
	[105] = { 88, 89, 90, 91, },	-- Sued
	[102] = { 82, 83, 84, 85, },	-- West

	--- Einmündung I
	[112] = { 203,206,212 },
	[113] = { 203,206,212,199,8,207,416 },
	[115] = { 203,206,212,200 },	-- ,208
	[116] = { 207 },
	[114] = { 208,198 },
	--- Einmündung II
	[118] = { 59,61,62 },
	[119] = { 59,61,62,39,55,56,73,71 },
	[117] = { 59,61,62,64,63 },	-- ,70
	[121] = { 71 },
	[120] = { 69,70 },
	--- Einmündung III
	[122] = { 40,41,44 },
	[123] = { 40,41,44,33,36,35,52 }, -- ,51 entfernt, kann zur Blockade führen wenn KFZ vor Signal 124 warten
	[124] = { 40,41,44,37,45 },	-- ,53
	[125] = { 51 },
	[126] = { 53,38 },
	--- Einmündung IV
	[127] = { 47,122,130 },
	[128] = { 47,122,130,136,129,127,224,131 },
	[129] = { 47,122,130,233,121 },	-- ,132
	[130] = { 131 },
	[131] = { 123,132 },
	--- Einmündung V
	[132] = { 149,145,142 },
	[133] = { 149,145,142,157,141,140,144,235 },
	[134] = { 149,145,142,236,147 },	-- ,146
	[135] = { 144 },
	[136] = { 137,146 },
	--- Einmündung VI
	[161] = { 31,239,247 },
	[162] = { 31,239,247,254,244,246,248,250 },
	[163] = { 31,239,247,251,240 },	-- ,249
	[164] = { 248 },
	[165] = { 249,243 },
	--- Einmündung VII
	[166] = { 296,294,297 },
	[167] = { 296,294,297,255,290,298,315 }, -- ,300 entfernt, kann zur Blockade führen wenn KFZ vor Signal 168 warten
	[168] = { 296,294,297,316,291 },	-- ,299
	[169] = { 300 },
	[165] = { 287,299 },
	--- Einmündung VIII
	[171] = { 284,280,302 },
	[172] = { 284,280,302,271,274,301,303,542 },
	[173] = { 284,280,302,544,278 },	-- ,304
	[174] = { 303 },
	[175] = { 275,304 },
	--- Einmündung IX
	[176] = { 314,308,309 },
	[177] = { 314,308,309,270,269,310,311,545 },
	[178] = { 314,308,309,550,305 },	-- ,312
	[179] = { 311 },
	[180] = { 265,312 },
}

-- Initialisierung: Registriere Strassen für Besetzt-Meldung
for SignalId, TrackIDs in pairs (Einmuendungen) do
	for _, TrackID in pairs (TrackIDs) do
		EEPRegisterRoadTrack( TrackID )
	end
end

-- Aufruf in EEPMain
function abzweigkontrolle ()
	for SignalId, TrackIDs in pairs(Einmuendungen) do
		local besetzt = false
		for _, TrackID in pairs (TrackIDs) do
			besetzt = besetzt or select(2,EEPIsRoadTrackReserved( TrackID ))
		end
		if besetzt then
			EEPSetSignal( SignalId, 2 )	-- Halt
		else
			EEPSetSignal( SignalId, 1 )	-- Fahrt
		end
	end
end

----------------------------------- Ampeln

-- Eine sehr primitive 4-er-Ampelschaltung: Die Ampeln schalten reihum auf Grün während alle anderen Ampeln Rot zeigen.

Ampelkreuzungen = {				-- Hier können die Ampeln mehrerer 4-er Kreuzungen eingetragen werden

	{ 182, 183, 184, 185, },  	-- Die Fußgängerampeln 186, 187, 189, 188 werden gekoppelt geschaltet	 	
}

--[[
Auf der Anlage werden folgende Modelle aus dem Set V13NDH10051 oder V13NDH10053 genutzt:
Ampel_2_neutr_DH1		
	Hängende Ampel ohne Richtungspfeile mit Mast rechts neben der Fahrbahn. 
	Die Ampel wirkt auf die 2. Fahrspur von rechts.
Ampel_1_neutr_oM_DH1	aus Set V13NDH10051 oder V13NDH10053
	Stehende Ampel ohne Richtungspfeile ohne Mast rechts neben der Fahrbahn. 
	Wirkt auf die rechte Fahrspur.
								
Alternativ kann auch die Baustellenampel aus dem Set (in der Filebase) 
V100NDH1F065 DH1 - Kleines Set mit Gehwegabschlüssen und einer Baustellenampel verwendet werden.

Die Ampeln besitzen folgende Signalpositionen: 'Halt', 'Fahrt erwarten', 'Fahrt', 'Halt erwarten', 'Aus'
Zur besseren Lesbarkeit werden für die Signalpositionen Konstanten festgelegt:
--]]
local AmpelFarbe = { rot = 1, rot_gelb = 2, gruen = 3, gelb = 4, aus = 5, }

-- Initialisierung der Tipp-Texte der Ampeln
local AmpelTippTexte = {
	-- [Stellung] = formatierter Tipp-Text
	[1] = "<bgrgb=160,0,0><fgrgb=255,255,255>" .. "rot", 		-- red / white
	[2] = "<bgrgb=255,130,0>"                  .. "rot-gelb", 	-- orange
	[3] = "<bgrgb=0,160,0><fgrgb=255,255,255>" .. "grün", 		-- green / white
	[4] = "<bgrgb=255,255,0>" 				   .. "gelb", 		-- yellow
	[5] = 										  "aus",
}
for _, Ampeln in ipairs(Ampelkreuzungen) do
	for _, AmpelId in ipairs(Ampeln) do
		-- Registriere die Ampel
		EEPRegisterSignal( AmpelId )

		-- Zeige den Status der Ampel im Tipp-Text
		-- <j> linkbündig, <c> zentriert, <r> rechtsbündig, <br> Zeilenwechsel 
		-- <b>Fett</b>, <i>Kursiv</i>, <fgrgb=0,0,0> Schriftfarbe, <bgrgb=0,0,0> Hintergrundfarbe
		-- siehe https://www.eepforum.de/forum/thread/34860-7-6-3-tipp-texte-f%C3%BCr-objekte-und-kontaktpunkte/
		_ENV["EEPOnSignal_"..AmpelId] = function (Stellung) 
			if log then 
				EEPChangeInfoSignal( AmpelId, " " .. AmpelTippTexte[Stellung] .. " " .. AmpelId)
				EEPShowInfoSignal( AmpelId, true )
			else
				EEPShowInfoSignal( AmpelId, false )
			end
		end
	end
end

local AmpelPhase = 1		-- aktuelle Phase der Ampelschaltung		
local AmpelDauer = 0		-- bisherige Dauer der aktuellen Phase 
		
-- Aufruf in EEPMain (1x je Sekunde)	
function kr_ampel()
	-- lokale Konstanten zur besseren Lesbarkeit der folgenden Tabelle
	local rot, rot_gelb, gruen, gelb = AmpelFarbe.rot, AmpelFarbe.rot_gelb, AmpelFarbe.gruen, AmpelFarbe.gelb	
	
	-- Phasen einer sehr einfachen Schaltung: die Ampeln zeigen reihum Grün
	local Phasen = { 
	--    1. Ampel  2. Ampel  	3. Ampel   	4. Ampel	Dauer in Sekunden	 
		{ gruen,	rot,		rot,		rot,		Dauer = 10	},	
		{ gelb,		rot_gelb,	rot,		rot,					},	
		{ rot,		gruen,		rot,		rot,		Dauer = 10 	},
		{ rot,		gelb,		rot_gelb,	rot,					},	
		{ rot,		rot,		gruen,		rot,		Dauer = 10 	},
		{ rot,		rot,		gelb,		rot_gelb,				},	
		{ rot,		rot,		rot,		gruen,		Dauer = 10 	},
		{ rot_gelb,	rot,		rot,		gelb,					},
	}
	
	if AmpelDauer == 0 then												-- Ampeln zu Beginn einer Phase schalten
		for _, Ampeln in ipairs(Ampelkreuzungen) do						-- Alle Kreuzungen schalten synchron 
			for k, AmpelId in ipairs(Ampeln) do
					EEPSetSignal( AmpelId, Phasen[AmpelPhase][k], 1)	-- Jede Ampel schalten
			end	
		end
	end

	-- Wartezeit prüfen
	if Phasen[AmpelPhase].Dauer and Phasen[AmpelPhase].Dauer > AmpelDauer then
		AmpelDauer = AmpelDauer + 1										-- Warten
	else	
		AmpelPhase = AmpelPhase + 1										-- nächste Phase starten
		if AmpelPhase > #Phasen then
			AmpelPhase = 1												-- ggf. wieder mit ersten Phase beginnen
		end	
		AmpelDauer = 0													-- Neue Ampelphase beginnt
	end
end

----------------------------------- Stadtlampen einstellen

-- Aufruf in EEPMain
function strassenlampen()
	for ImmoIdx = 308, 480 do			-- Für Lampen Modell LgtC_TownLamp_SM2 #308 und #312 - #480 (#309 und #310 sind Stadthäuser)
		local Structure = "#"..ImmoIdx
		if EEPTimeH <= 6 or EEPTimeH >= 18 then
			EEPStructureSetLight(Structure, true)
			EEPStructureSetAxis(Structure, "Lichtintensität", 75)
		else
			EEPStructureSetLight(Structure, false)
			EEPStructureSetAxis(Structure, "Lichtintensität", 0)
		end
	end
end
