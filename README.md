# EEP Zugzielanzeige

Das Repository enthält die Steuerung der kleinen [Dioramaanlage](https://www.eepforum.de/forum/thread/35836-weil-ihr-in-der-weihnachtszeit-nichts-von-mir-gesehen-habt-hier-ein-kleines-gesc/) von [DH1](https://www.eepforum.de/user/2414-dh1/) bei der mit Lua-Sktipten die Fahrstraßen, die Zugzielanzeige und die Türen an den Zügen geschaltet werden.

Die Züge werden auf dieser Anlage automatisch alle 2:30 Minuten aus den Depots abgerufen und über je nach ihren Routen über Fahrstraßen in und aus dem Bahnhof geleitet. Die Zugzielanzeige im Bahnhof zeigt auf den jeweiligen Gleisen den aktuellen und bis zu 2 Folgezüge korrekt an. Bei Verspätunmgen wird automatisch die Anzeige um eine Laufschrift-Meldung erweitert. Die Türen der Züge auf der Bahnsteigseite werden kurz nach dem Halt geöffnet und kurz vor der Abfahrt wieder geschlossen.

Außerdem wird ein Bahnübergang, die Straßen-Einmündungen, ein Kreisverker und eine (sehr einfache) Ampel mit Lua geschaltet.

## Version 1.1

Die Version [v1.1](https://github.com/FrankBuchholz/EEP_Zugzielanzeige/releases/tag/v1.1) zeigt die Originalversion der Lua-Skripte so wie sie von [DH1](https://www.eepforum.de/user/2414-dh1/) in der [EEP Filebase](https://www.eepforum.de/filebase/file/2248-kleine-dioramaanlage-mit-lua-steuerung-der-fahrstra%C3%9Fen-der-zza-und-der-t%C3%BCren-an/) veröffentlicht wurden.

## Version 1.2

Version v1.2 enthält die von mir überarbeiteten Lua-Skripte für die Orginal-Anlage von [DH1](https://www.eepforum.de/user/2414-dh1/).

Das wesentliche Ziel dabei war die Erhöhung der Lesbarkeit und die Erleicherung für weitere Anpassungen - Die Funktionalität der Original-Version wurde dabei nicht geändert:

- Vereinheitlichung von Variablennamen
- Umfassendere Dokumentation imn den Skripten
- Ersatz von globalen Variablen und Funktionen durch lokale Variablen und Funktionen soweit das möglich war
- Ersatz von generierten globalen Funktionen durch parametriesierte lokale Funktionen
- Einführung von Konstanten und Variablem, um Referenzen auf Objekte in der Anlage nur einmaling in Tabellen definieren zu können
- Beschriftung der Bahnhofschilder
- Auslagerung der Strassensteuerung in ein separates Skript
- Erweiterete Protokollierung im Ereignisprotokoll und in Tipp-Texten zur einfacheren Analyse der Anlage und der Skripte

Zur Analyse der Anlage wurde das [Gleisplan-](https://frankbuchholz.github.io/EEP_convert_anl3_file/EEP_Gleisplan.html) und das [Inventar-Programm](https://frankbuchholz.github.io/EEP_convert_anl3_file/EEP_Inventar.html) aus dem GitHub-Repositoty [`EEP_convert_anl3_file`](https://github.com/FrankBuchholz/EEP_convert_anl3_file) verwendet.

### Betrieb

Mit dem Start/Stop-Signal wird der Fahrbetrieb gestartet. Nach 'Stop' fahren die Züge und Fahrzeuge wieder in die Depots.

### Installation

Nach der Installation der Anlage aus der [EEP Filebase](https://www.eepforum.de/filebase/file/2248-kleine-dioramaanlage-mit-lua-steuerung-der-fahrstra%C3%9Fen-der-zza-und-der-t%C3%BCren-an/) werden die Lua-Skripte im Ordner `\LUA\ZZA_Diorama` durch die Dateien aus diesem Repository ersetzt. 

Da die Änderungen auch das Hauptskript umfassen, ist dieses Skript ebenfalls ausgelagert. In der Anlage selber wird damit nur ein einziger Befehl in das Lua-Skript eingetragen:  
`require ("ZZA_Diorama\\ZZA_Demo")`  
Optional kann man davor oder dahinter die erweiterte Protokollausgabe aktivieren:  
`log = true`

### Anpassungsmöglichkeiten

Die Zugzielanzeigetafeln, Modell `ZZA6CDB2` aus Set [`V15NDB20015`](https://eepshopping.de/?view=search_program&search_string=V15NDB20015&Abschicken.x=-465&Abschicken.y=-180), und die Bahnsteigschilder aus dem gleichen Set werden unbedingt benötigt.

Fehlende Straßen können mit dem Tauschmanager durch anderen Einspurstraßen aus dem Grundbestand, z.B. "Einweg Asphaltstrasse Gehweg ohne", ersetzt werden.

Statt den Ampeln aus dem Set [`V13NDH10051`](https://eepshopping.de/?view=program_detail&ID_NODE_AKTIV=&ID_PROGRAM=7984&search_status=1&search_string=V13NDH10051&search_artikelnummer=&search_bezeichung=&search_autor=&search_text=) oder [`V13NDH10053`](https://eepshopping.de/index.php?view=program_detail&ID_NODE_AKTIV=&ID_PROGRAM=7982&search_status=1&search_string=V13NDH10053&search_artikelnummer=&search_bezeichung=&search_autor=&search_text=) kann auch die mehrbegriffige Baustellenampel aus dem Freemodell-Set [`V100NDH1F065`](https://www.eepforum.de/filebase/file/334-dh1-kleines-set-mit-gehwegabschl%C3%BCssen-und-einer-baustellenampel/) verwendet werden.

Die KFZ-Ampel wird dann in den Objekteigenschaften nach rechts (-2.75) und unten (-0.78) versetzt, so dass der Fuß unter dem Gehsteig verschwindet.
Die Fußgänger-Ampel kann ebenfalls durch die Baustellenampel ersetzt und geeignet versteckt werden.

Die Züge in den Depots können durch andere Züge mit geeigneter Routenzuordnung ersetzt oder ergänzt werden. Damit die Türen automatisch betätigt werden können müssen die Achsgruppen zugeordnet werden: 1 geschlossen, 2 links offen, 3 rechts offen (Bahnsteigseite).

Die Zugnummern, Zwischenziele, Ziele und die Info (Laufschrift) können im Skript `ZZA_Diorama.lua` in Tabelle `Routen` frei geändert werden. (Die Routen und Gleise sind eng mit den Fahrstraßen verknüft und können nicht geändert werden.)

Die Züge aus den Depots 1 (West) und 2 (Ost) werden gleichzeitig alle 2:30 Minuten abgerufen. Wenn ihr die Frequenz ändern möchtet, dann könnt ihr das bei stehender Anlage tun, indem ihr den Wert der Variablen `ZugAbstand` (in nicht allzugroßer Weise) verändert (750 / 5 = 150 Sekunden = 2:30 Minuten):  
`local ZugAbstand = 750`

Das Gleisbildstellpult `ZZA_Demo - Bahnhof` kann in ein neues Stellpult auf der Anlage geladen werden. Damit wird die 