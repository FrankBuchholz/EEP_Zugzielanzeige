I=0
clearlog()
require ("ZZA_Diorama\\ZZA_Diorama")
require ("ZZA_Diorama\\Fahrstrassen_Diorama")
require ("ZZA_Diorama\\Steuerung_Diorama")
print("\nHallo,\nWillkommen auf meinem kleinen Diorama\nDeine EEP Version ist: ", EEPVer)
		
function EEPMain()
    I=I+1
	Einfkrv()
	abzweigkontrolle()
	FS_mit_Slot()
	bue1zu()
	if I%750 == 0 and EEPGetSignal(52) == 1 then
		prfDept1()
		prfDept2()
	end
	if I % 300 == 0 then
		infotext()
		strassenlampen()
	end
	if EEPGetSignal(52) == 1 then
		if I % 75 == 0 then
			EEPSetSignal(181,1)			
			EEPSetSignal(194,1)
			EEPSetSignal(195,1)
		elseif I % 75 == 30 then
			EEPSetSignal(181,2)		
			EEPSetSignal(194,2)
			EEPSetSignal(195,2)
		end
	end
	if I % 5 == 0 then
		kr_ampel()
	end
    return 1
end
--Gl1_aus ()
--[[Anzeige = "#128"
--for z = 1,28 do
	--EEPStructureSetTextureText (Anzeige, z, "")
--end
--EEPStructureSetTextureText (Anzeige, 29, "6")
--EEPStructureSetTextureText (Anzeige, 30, "6")
--EEPStructureSetTextureText (Anzeige, 33, "")]]
--EEPStructureSetTagText("#122","leer")

[EEPLuaData]
DB_1 = 0
DB_2 = 0
DB_3 = 0
DB_4 = 0
DB_5 = 0
DB_6 = 0
DB_7 = 0
DB_8 = 0
DB_9 = 0
DB_10 = 0
DB_11 = 0
DS_101 = ""
DN_102 = 0.000000
DS_103 = ""
DN_104 = 0.000000
DS_105 = ""
DS_201 = ""
DN_202 = 0.000000
DS_203 = ""
DN_204 = 0.000000
DS_205 = ""
DS_301 = ""
DN_302 = 0.000000
DS_303 = ""
DN_304 = 0.000000
DS_305 = ""
DS_401 = ""
DN_402 = 0.000000
DS_403 = ""
DN_404 = 0.000000
DS_405 = ""
DS_501 = ""
DN_502 = 0.000000
DS_503 = ""
DN_504 = 0.000000
DS_505 = ""
DS_601 = ""
DN_602 = 0.000000
DS_603 = ""
DN_604 = 0.000000
DS_605 = ""
