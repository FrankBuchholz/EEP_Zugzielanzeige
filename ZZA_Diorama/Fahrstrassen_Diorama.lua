--[[
Lua-Aufrufe in Kontakten (Ermittelt über https://frankbuchholz.github.io/EEP_convert_anl3_file/EEP_Inventar.html ):

auflosenwest	Eisenbahn 31
auflosenost		Eisenbahn 252

Aufruf in EEPMain:

FS_mit_Slot

--]]

if log then print("Script 'Fahrstrassen_Diorama' 1.2 wird geladen") end 

--[[
Beispiel-Parameter:

FmS_Tabelle = {
	[15] = {																-- Die Fahrstrassen-ID
		Gleis		= 1,													-- Gleisnummer
		Route 		= {"Alle", "Gleis 1", "Gleis 2", "Gleis 3", "Gleis 4"}, -- Die Routen, für die die Fahrstrasse gelten sollen. 
																			-- Mindestens eine Route muss dort stehen, notfalls "Alle".
		FW 			= {{4,3,2,1}, {1}, {2}, {3}, {4}},						-- Die Fahrwege der Fahrstrasse, wobei der bevorzugte Fahrweg stehts am Ende stehen muss.
		Ausgabe		= "Text", 
		Slot 		= 125,													-- Der Speicher-Slot
	},
}
 
Die Zuordnung ist so, dass die ersten Fahrwege zu der erstgenannten Route gehören, die zweiten Fahrwege zur 2. Route, usw.
Im obrigen Beispiel der Fahrstrasse 15 gehören also die Fahrwege {4,3,2,1} zur Route "Alle",
{1} zur Route "Gleis 1", {2} zur Route "Gleis 2" usw.

Besonderheit!!
Man kann die Fahrstrassen frühstens nach einer bestimmten Zeit stellen lassen.
Soll also zum Beispiel im Bahnhof der Zug erst 60 Sekunden stehen, bevor die Fahrstrasse gestellt werden soll,
kann man das mit einer Minus-Zahl vor dem ersten Fahrweg angeben.
Siehe dazu auch das 2. Beispiel weiter hinten {-60,1}
Der Zug wartet also mindestens 60 Sekunden.
]]

local Aufenthalt = 45 	-- Sekunden

------------------------------------ Fahrstrassentabelle
FmS_Tabelle = {
	-- [Fahrstrassensignal] = { Liste der Daten zu den Fahrstrassen }
	-- Weitere Datenfelder werden dynamisch hinzugefügt: Dauer, StatusZeitanzeige
	[28] = {	-- Zielsignale 29, 30 und 31, Schranke über Signal 61 schließen
		Route 	= { "RB_30", "RB_30_1", "RE_32", "RE_40", "Gueter" }, 
		FW 		= { {3},     {1},       {1},     {3},     {2}      },
		Ausgabe = "Einfahrt West in den Bahnhof", 
		Slot 	= 1,
	},
	[22] = {	-- Zielsignal 23, Schranke über Signal 61 schließen
		Gleis	= 6,
		Route 	= { "RB_30", "RE_41" }, 
		FW 		= { {-45,1}, {-45,1} },	--Wenn negative Zahl, dann Wartezeit
		Ausgabe = "Ausfahrt West Gleis 6", 
		Slot 	= 2,
	},
	[26] = {	-- Zielsignal 23, Schranke über Signal 61 schließen
		Gleis	= 4,
		Route 	= { "Gueter" }, 
		FW 		= { {1}      },
		Ausgabe = "Ausfahrt West Gleis 4", 
		Slot 	= 3,
	},
	[27] = {	-- Zielsignal 23, Schranke über Signal 61 schließen
		Gleis	= 2,
		Route 	= { "RE_40", "RE_47" }, 
		FW 		= { {-45,1}, {-45,1} },
		Ausgabe = "Ausfahrt West Gleis 2", 
		Slot 	= 4,
	},
	[39] = {	-- Zielsignal 41
		Gleis	= 1,
		Route 	= { "RB_30", "RE_40" }, 
		FW 		= { {-45,1}, {-45,1} },
		Ausgabe = "Ausfahrt Ost Gleis 1", 
		Slot 	= 5,
	},
	[38] = {	-- Zielsignal 40
		Gleis	= 3,
		Route 	= { "Gueter" }, 
		FW 		= { {1}     },
		Ausgabe = "Ausfahrt Ost Gleis 3", 
		Slot 	= 6,
	},
	[37] = {	-- Zielsignal 41
		Gleis	= 5,
		Route 	= { "RB_30_1", "RE_32" }, 
		FW 		= { {-45,1},   {-45,1} },
		Ausgabe = "Ausfahrt Ost Gleis 5", 
		Slot 	= 7,
	},
	[44] = {	-- Zielsignal 46
		Route 	= { "RB_30", "RB_30_1", "RE_32", "RE_40" }, 
		FW 		= { {1},     {1},       {1},     {1}     },
		Ausgabe = "Einfahrt Depot R-Züge", 
		Slot 	= 8,
	},
	[45] = {	-- Zielsignal 46
		Route 	= { "Gueter" }, 
		FW 		= { {1}      },
		Ausgabe = "Einfahrt Depot Güter", 
		Slot 	= 9,
	},
	[47] = {	-- Zielsignale 49, 51
		Route 	= { "RB_30", "RE_40", "RE_41", "RE_47" }, 
		FW 		= { {1},     {2},     {1},     {2}     },
		Ausgabe = "Einfahrt Ost Gleise 2 und 6", 
		Slot 	= 10,
	},	
	[48] = {	-- Zielsignal 50
		Route 	= { "Gueter" }, 
		FW 		= { {1}      },
		Ausgabe = "Einfahrt Ost Gleis 4 ",
		Slot 	= 11,
	},
 }

-- Initialisierung: Fahrstrassensignale in Tabelle je Gleis kopieren
local Gleis_FmS = {} -- [Gleis] = Fahrstrassensignal
for Signal, Fahrstrasse in pairs(FmS_Tabelle) do
	if Fahrstrasse.Gleis then
		Gleis_FmS[Fahrstrasse.Gleis] = Signal
	end
end

----------------------------------- Hilfsfunktion zur Zeitumrechnung

local function toTime (Zeitstring)
	-- Uhrzeit "hh:mm:ss" in Sekunden seit 0 Uhr umrechnen
	local h = tonumber(string.sub(Zeitstring, 1, 2))
	local m = tonumber(string.sub(Zeitstring, 4, 5))
	local s = tonumber(string.sub(Zeitstring, 7, 8))
	return (h or 0) * 3600 + (m or 0) * 60 + (s or 0)
end

----------------------------------- Steuerung für Schaltung der Fahrstrassen

-- Aufruf in EEPMain
function FS_mit_Slot()

	for Signal, Fahrstrasse in pairs(FmS_Tabelle) do						-- Schleife über die Fahrstrassen

		local ok, Zugname = EEPLoadData( Fahrstrasse.Slot ) 				-- Name aus dem Slot lesen
		if Zugname then														-- wenn der Slot einen Wert hat

			local ok, RouteId = EEPGetTrainRoute( Zugname )					-- Route aus Zugname ermitteln

			for FmS_R = 1, #Fahrstrasse.Route do							-- alle Routen im Tabellenfeld prüfen
				if Fahrstrasse.Route[FmS_R] == RouteId then					-- wenn Übereinstimmung
					for FmS_Fahrweg = 1, #Fahrstrasse.FW[FmS_R] do			-- Schleife durch alle Fahrwege der Route
																											
						local Wartezeit = Fahrstrasse.Dauer										-- prüfen auf Wartezeit
																											
						if Fahrstrasse.FW[FmS_R][FmS_Fahrweg] <= 0 and Wartezeit == nil then 	-- wenn Wert kleiner 0 und Wartezeit ist 0

							if     Signal == Gleis_FmS[1]										-- wenn Fahrstrasse an Gleis mit ZZA 
								or Signal == Gleis_FmS[2]
--								or Signal == Gleis_FmS[3]	-- kein Aufenthalt, Güterzug fährt durch
--								or Signal == Gleis_FmS[4]	-- kein Aufenthalt, Güterzug fährt durch
								or Signal == Gleis_FmS[5]
								or Signal == Gleis_FmS[6]
								then
							
								assert(Fahrstrasse.Gleis, "ERROR: Fahrstrasse "..Signal..": Gleis fehlt")	-- Konsistenzprüfung
								local ok, ZZA_Tag = EEPStructureGetTagText( Zugzielanzeigetafeln[Fahrstrasse.Gleis][1] )	-- In ZZA eingetragene Zeit lesen

								if ZZA_Tag ~= nil and ZZA_Tag ~= "" and ZZA_Tag ~= "leer" then				-- wenn schon Zeit im ZZA 
									local Anzwert = toTime(string.sub(ZZA_Tag, 1, 5))						-- in Sekunden seit 0 Uhr umrechnen
									--if log then print("EEPTime ",EEPTime," ZZA_Tag ",ZZA_Tag," Anzwert ",Anzwert," Differenz ",Anzwert - EEPTime) end
									if Anzwert - EEPTime > Aufenthalt then									-- mit EEP Zeit vergleichen und wenn > 45
										print("Aufenthalt an Gleis ",Fahrstrasse.Gleis,": ",Anzwert - EEPTime," Sekunden")
										Fahrstrasse.Dauer = Anzwert 										-- die Aufenthaltsdauer setzen
									else
										Fahrstrasse.Dauer = EEPTime + ( Fahrstrasse.FW[FmS_R][FmS_Fahrweg] * -1 )	-- Wartezeit zu EEP-Zeit addieren
									end
								end
							end

						elseif  Wartezeit ~= nil 
							and Wartezeit > EEPTime 
							and Wartezeit - EEPTime < 10 
							and Wartezeit - EEPTime > 7 
							then
							-- sonst wenn eine Wartezeit gespeichert ist die größer als die EEPZeit und die Differenz kleiner als 10 und größer 7
							--if log then print("Gleis " .. Fahrstrasse.Gleis .. " tuerzu() " .. Wartezeit .. " - " .. EEPTime .. " = " .. Wartezeit - EEPTime ) end
							
							assert(Fahrstrasse.Gleis, "ERROR: Fahrstrasse "..Signal..": Gleis fehlt")	-- Konsistenzprüfung
							tuerzu(Fahrstrasse.Gleis)

						elseif Wartezeit ~= nil 
							and ( Wartezeit <= EEPTime or EEPTime < 60 )						-- Züge um Mitternacht nicht festHalten
							then	
							-- sonst wenn Wartezeit ungleich 0 und EEP Zeit grösser
							if Fahrstrasse.FW[FmS_R][FmS_Fahrweg] > 0 then						-- wenn der Fahrstrassenwert > 0 
								EEPSetSignal( Signal, Fahrstrasse.FW[FmS_R][FmS_Fahrweg]+1, 1 )	-- Fahrstrasse schalten
							end

						-- Ende der Wartezeitprüfung							
						elseif Wartezeit == nil then											-- sonst wenn Wartezeit 0 
							EEPSetSignal( Signal, Fahrstrasse.FW[FmS_R][FmS_Fahrweg]+1, 1 )		-- Fahrstrasse schalten
						end
					end
				end
			end
		end
	end
end

-- Aufruf in Kontakt auf Eisenbahn 31
function auflosenwest()
	EEPSetSignal( Gleis_FmS[2], 1, 1 )	-- Fahrstrasse zu Gleis 2
	EEPSetSignal( Gleis_FmS[4], 1, 1 )	-- Fahrstrasse zu Gleis 4
	EEPSetSignal( Gleis_FmS[6], 1, 1 )	-- Fahrstrasse zu Gleis 6
end

-- Aufruf in Kontakt auf Eisenbahn 252
function auflosenost()
	EEPSetSignal( Gleis_FmS[1], 1, 1 )	-- Fahrstrasse zu Gleis 1
--	EEPSetSignal( Gleis_FmS[3], 1, 1 )	-- Fahrstrasse zu Gleis 3 (führt nicht über dieses Gleis)
	EEPSetSignal( Gleis_FmS[5], 1, 1 )	-- Fahrstrasse zu Gleis 5
end


