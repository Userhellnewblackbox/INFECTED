--[[
INFECTED V.2.0
RECRIADO do 1.0.2!
02/12/2022 A  00/00/00(UNDEFINED)
Recovery Baseado em scripts Lua como Heist Control e em globais pegos diretamente na Unknown Cheats!
Devido ao tempo de demora dos botões unicos, iremos por funçoes iguais em cada botão, cujo sera cada uma especificada!
Igualmete vai ter os desbloqueios separados igual a versão passada!
Inicio da programação 08/11/2022
Ultima modificação 14/12/2022
Criador: IMPULSE#0585 ou Synxhxyz#2920
Motivo da recriação é falhas de desbloqueios, INFECTED está em fase beta e ainda não foi lançado!
Ele sera lançado em versão V.0.0.1, Como fase inicial com o munimo de falhas possiveis.
Script sendo criado solo, todo tipo de atualização vai demorar a ser lançada, me flata experencia e conhecimento!
Inicio do script Abaixo.
]] --
-------------------------
--- Lua Script Versão
local IFVersion = "V.2.0"
-------------------------

---Diretorio----------------------------------------------
local IFFolderDir = filesystem.store_dir() .. "INFECTED\\"
local SettingFolderDir = IFFolderDir .. "Setting\\"
local SettingDir = SettingFolderDir .. "Setting.txt"
local LogDir = SettingFolderDir .. "Log.txt"
----------------------------------------------------------

---Funções Importantes------------------------------------

function IS_MPPLY(Stat)
    local Stats = { "MP_PLAYING_TIME" }

    for i = 1, #Stats do
        if Stat == Stats[i] then
            return true
        end
    end

    if string.find(Stat, "MPPLY_") then
        return true
    else
        return false
    end
end

function ADD_MP_INDEX(Stat)
    if not IS_MPPLY(Stat) then
        Stat = "MP" .. util.get_char_slot() .. "_" .. Stat
    end
    return Stat
end

function STAT_SET_INT(Stat, Value)
    STATS.STAT_SET_INT(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_FLOAT(Stat, Value)
    STATS.STAT_SET_FLOAT(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_BOOL(Stat, Value)
    STATS.STAT_SET_BOOL(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_STRING(Stat, Value)
    STATS.STAT_SET_STRING(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_SET_DATE(Stat, Year, Month, Day, Hour, Min)
    local DatePTR = memory.alloc(7 * 8)
    memory.write_int(DatePTR, Year)
    memory.write_int(DatePTR + 8, Month)
    memory.write_int(DatePTR + 16, Day)
    memory.write_int(DatePTR + 24, Hour)
    memory.write_int(DatePTR + 32, Min)
    memory.write_int(DatePTR + 40, 0) -- Segundo
    memory.write_int(DatePTR + 48, 0) -- Millisegundo
    STATS.STAT_SET_DATE(util.joaat(ADD_MP_INDEX(Stat)), DatePTR, 7, true)
end

function STAT_SET_PACKED_BOOL(Stat, Value)
    STATS._SET_PACKED_STAT_BOOL(Stat, Value, util.get_char_slot())
end

function STAT_SET_INCREMENT(Stat, Value)
    STATS.STAT_INCREMENT(util.joaat(ADD_MP_INDEX(Stat)), Value, true)
end

function STAT_GET_INT(Stat)
    local IntPTR = memory.alloc_int()
    STATS.STAT_GET_INT(util.joaat(ADD_MP_INDEX(Stat)), IntPTR, -1)
    return memory.read_int(IntPTR)
end

function STAT_GET_FLOAT(Stat)
    local FloatPTR = memory.alloc_int()
    STATS.STAT_GET_FLOAT(util.joaat(ADD_MP_INDEX(Stat)), FloatPTR, -1)
    return tonumber(string.format("%.3f", memory.read_float(FloatPTR)))
end

function STAT_GET_BOOL(Stat)
    if STAT_GET_INT(Stat) == 0 then
        return "false"
    elseif STAT_GET_INT(Stat) == 1 then
        return "true"
    else
        return "STAT_UNKNOWN"
    end
end

function STAT_GET_STRING(Stat)
    return STATS.STAT_GET_STRING(util.joaat(ADD_MP_INDEX(Stat)), -1)
end

function STAT_GET_DATE(Stat, Sort)
    local DatePTR = memory.alloc(7 * 8)
    STATS.STAT_GET_DATE(util.joaat(ADD_MP_INDEX(Stat)), DatePTR, 7, true)
    local Add = 0
    if Sort == "Year" then
        Add = 0
    elseif Sort == "Month" then
        Add = 8
    elseif Sort == "Day" then
        Add = 16
    elseif Sort == "Hour" then
        Add = 24
    elseif Sort == "Min" then
        Add = 32
    end
    return memory.read_int(DatePTR + Add)
end

function SET_INT_GLOBAL(Global, Value)
    memory.write_int(memory.script_global(Global), Value)
end

function SET_FLOAT_GLOBAL(Global, Value)
    memory.write_float(memory.script_global(Global), Value)
end

function GET_INT_GLOBAL(Global)
    return memory.read_int(memory.script_global(Global))
end

function SET_PACKED_INT_GLOBAL(StartGlobal, EndGlobal, Value)
    for i = StartGlobal, EndGlobal do
        SET_INT_GLOBAL(262145 + i, Value)
    end
end

function SET_INT_LOCAL(Script, Local, Value)
    if memory.script_local(Script, Local) ~= 0 then
        memory.write_int(memory.script_local(Script, Local), Value)
    end
end

function SET_FLOAT_LOCAL(Script, Local, Value)
    if memory.script_local(Script, Local) ~= 0 then
        memory.write_float(memory.script_local(Script, Local), Value)
    end
end

function GET_INT_LOCAL(Script, Local)
    if memory.script_local(Script, Local) ~= 0 then
        local Value = memory.read_int(memory.script_local(Script, Local))
        if Value ~= nil then
            return Value
        end
    end
end

-----------------------------------------------------------------------------------

---Códigos Nativos------------------------
util.require_natives("natives-1660775568")

------------------------------------------
-- Configurações do IF-------------------------------------------------------------------

Settings = { -- Definir tipos
    "Language", "Notification Sort", "Notification Icon", "Notification Color", "Timer Color" }

if not filesystem.exists(SettingDir) then -- Valores de configuração padrão
    util.write_colons_file(SettingDir, { "Unknown", "Stand", "IF Logo", "Black", "White" })
end

function READ_SETTING(Sort)
    for i = 1, #Settings do
        if Sort == Settings[i] then
            return util.read_colons_and_tabs_file(SettingDir)[tostring(i)]
        end
    end
end

function WRITE_SETTING(Sort, Value)
    local FinalSettings = {}
    for i = 1, #Settings do
        if Sort == Settings[i] then
            FinalSettings[#FinalSettings + 1] = Value
        else
            FinalSettings[#FinalSettings + 1] = READ_SETTING(Settings[i])
        end
    end

    util.write_colons_file(SettingDir,
        { FinalSettings[1], FinalSettings[2], FinalSettings[3], FinalSettings[4], FinalSettings[5] })
end

-----------------------------------------------------------------------------------------------------------

--- funções de registro------------------------------------------------------------------------------------

if not filesystem.exists(LogDir) then
    local open = io.open(LogDir, "w+")
    open:write("")
    open:close()
end
function LOG(Message)
    local open = io.open(LogDir, "a+")
    open:write(os.date("[%m/%d/%Y %I:%M:%S %p]") .. " " .. Message .. "\n")
    open:close()
end

function ERROR_LOG(ErrorMsg)
    LOG("INFECTED Version: " .. IFVersion)
    LOG("[INFECTED - ERROR] " .. ErrorMsg .. "\n")
    util.toast("[ INFECTED - ERROR ]" .. "\n\n" .. ErrorMsg)
    util.yield()
    util.stop_script()
end

-------------------------------------------------------------

--- Configurações Gerais-------------------------------------

util.execute_in_os_thread(function()
    menu.trigger_commands("clearnotifications")
    menu.trigger_commands("nocasinoregionlock on")
    menu.trigger_commands("noidlekick on")
end)


INT_MIN = -2147483648
INT_MAX = 2147483647

--------------------------------------------------------------------

--- Listas principais-----------------------------------------------
menu.divider(menu.my_root(), "INFECTED" .. " " .. IFVersion)

local MASTER_UNLOCKR = menu.list(menu.my_root(), "Desbloqueadores Geral", { "" },
    "Cada botão tem função igual e diferente, se for usar, use apenas um, o mais fraco é o primeiro, o mais forte será o ultimo! caso de uso  de mais de um botão pode haver bugs, erros de transações e nulo de desbloqueios, tenha paciencia!"
    ,
    function()

    end)

local UNLOCK_ALL = menu.list(menu.my_root(), "Desbloqueador Separado", { "" },
    "Desbloqueios separados, aqui é separado por dlc's, datas, propriedades etc.", function()

end)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---Unlock All
local UNLOCK_SIMPLES = menu.list(MASTER_UNLOCKR, "Unlock All", { "" },
    "Nosso desbloqueio padrão, coisas mais comuns porem com alguns adicionais, está em fase beta pq esta sendo desenvolvido por eu mesmo, tentarei deixar-lo melhor que o padrão dos outros mods-menus!! "
    ,
    function()

    end)

menu.action(UNLOCK_SIMPLES, "Desempenho Pessoal", {},
    "Corridinha, 30C4 10 MINAS, Estatisticas, Lanches e coletes, carregameto mais rapido.  TROQUE DE SALA PARA FUNCIONAR!!!!!"
    ,
    function()
        STAT_SET_INT("CHAR_ABILITY_1_UNLCK", -1) --- Corridinha
        STAT_SET_INT("CHAR_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_ABILITY_3_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_1_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_3_UNLCK", -1)

        STAT_SET_INT("SR_HIGHSCORE_1", 690) ---30c4 10minas
        STAT_SET_INT("SR_HIGHSCORE_2", 1860)
        STAT_SET_INT("SR_HIGHSCORE_3", 2690)
        STAT_SET_INT("SR_HIGHSCORE_4", 2660)
        STAT_SET_INT("SR_HIGHSCORE_5", 450)
        STAT_SET_INT("SR_HIGHSCORE_6", 269)
        STAT_SET_INT("SR_WEAPON_BIT_SET", -1)
        STAT_SET_BOOL("SR_TIER_1_REWARD", true)
        STAT_SET_BOOL("SR_TIER_3_REWARD", true)
        STAT_SET_BOOL("SR_INCREASE_THROW_CAP", true)

        STAT_SET_INT("SCRIPT_INCREASE_STAM", 100) ---Estatisticas
        STAT_SET_INT("SCRIPT_INCREASE_SHO", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STRN", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STL", 100)
        STAT_SET_INT("SCRIPT_INCREASE_FLY", 100)
        STAT_SET_INT("SCRIPT_INCREASE_DRIV", 100)
        STAT_SET_INT("SCRIPT_INCREASE_LUNG", 100)

        STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30) ---Lanches e coletes
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
        STAT_SET_INT("CIGARETTES_BOUGHT", 20)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
        STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)

        SET_INT_GLOBAL(1574589, 1) ---reload
        SET_INT_GLOBAL(1575015, 1)
        SET_INT_GLOBAL(1574589, 0)
    end)

menu.action(UNLOCK_SIMPLES, "Desbloqueios Geral", {}, "estampas Ammunation/Boate/Bunker/LSC/escritorio-mc/",
    function()
        STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600) ---estampas Ammunation
        STAT_SET_INT("CMBTPISTOL_ENEMY_KILLS", 600)
        STAT_SET_INT("PISTOL50_ENEMY_KILLS", 600)
        STAT_SET_INT("APPISTOL_ENEMY_KILLS", 600)
        STAT_SET_INT("MICROSMG_ENEMY_KILLS", 600)
        STAT_SET_INT("SMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTSMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("CRBNRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("ADVRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("MG_ENEMY_KILLS", 600)
        STAT_SET_INT("CMBTMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTMG_ENEMY_KILLS", 600)
        STAT_SET_INT("PUMP_ENEMY_KILLS", 600)
        STAT_SET_INT("SAWNOFF_ENEMY_KILLS", 600)
        STAT_SET_INT("BULLPUP_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTSHTGN_ENEMY_KILLS", 600)
        STAT_SET_INT("SNIPERRFL_ENEMY_KILLS", 600)
        STAT_SET_INT("HVYSNIPER_ENEMY_KILLS", 600)
        STAT_SET_INT("GRNLAUNCH_ENEMY_KILLS", 600)
        STAT_SET_INT("RPG_ENEMY_KILLS", 600)
        STAT_SET_INT("MINIGUNS_ENEMY_KILLS", 600)
        STAT_SET_INT("GRENADE_ENEMY_KILLS", 600)
        STAT_SET_INT("SMKGRENADE_ENEMY_KILLS", 600)
        STAT_SET_INT("STKYBMB_ENEMY_KILLS", 600)
        STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600)

        STAT_SET_INT("AWD_DANCE_TO_SOLOMUN", 120) --- Boate
        STAT_SET_INT("AWD_DANCE_TO_TALEOFUS", 120)
        STAT_SET_INT("AWD_DANCE_TO_DIXON", 120)
        STAT_SET_INT("AWD_DANCE_TO_BLKMAD", 120)
        STAT_SET_INT("AWD_CLUB_DRUNK", 200)
        STAT_SET_INT("NIGHTCLUB_VIP_APPEAR", 700)
        STAT_SET_INT("NIGHTCLUB_JOBS_DONE", 700)
        STAT_SET_INT("NIGHTCLUB_EARNINGS", 20721002)
        STAT_SET_INT("HUB_SALES_COMPLETED", 1001)
        STAT_SET_INT("HUB_EARNINGS", 320721002)
        STAT_SET_INT("DANCE_COMBO_DURATION_MINS", 3600000)
        STAT_SET_INT("NIGHTCLUB_PLAYER_APPEAR", 9506)
        STAT_SET_INT("LIFETIME_HUB_GOODS_SOLD", 784672)
        STAT_SET_INT("LIFETIME_HUB_GOODS_MADE", 507822)
        STAT_SET_INT("DANCEPERFECTOWNCLUB", 120)
        STAT_SET_INT("NUMUNIQUEPLYSINCLUB", 120)
        STAT_SET_INT("DANCETODIFFDJS", 4)
        STAT_SET_INT("NIGHTCLUB_HOTSPOT_TIME_MS", 3600000)
        STAT_SET_INT("NIGHTCLUB_CONT_TOTAL", 20)
        STAT_SET_INT("NIGHTCLUB_CONT_MISSION", -1)
        STAT_SET_INT("CLUB_CONTRABAND_MISSION", 1000)
        STAT_SET_INT("HUB_CONTRABAND_MISSION", 1000)
        STAT_SET_BOOL("AWD_CLUB_HOTSPOT", true)
        STAT_SET_BOOL("AWD_CLUB_CLUBBER", true)

        SET_INT_LOCAL("gb_gunrunning", 1203 + 774, 0) ---bunker

        STAT_SET_INT("CHAR_FM_CARMOD_3_UNLCK", -1) ---LSC
        STAT_SET_INT("CHAR_FM_CARMOD_4_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_CARMOD_5_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_CARMOD_6_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_CARMOD_7_UNLCK", -1)
        STAT_SET_INT("AWD_FMRALLYWONDRIVE", 1)
        STAT_SET_INT("AWD_FMWINSEARACE", 1)
        STAT_SET_INT("AWD_FMWINAIRRACE", 1)
        STAT_SET_INT("NUMBER_TURBO_STARTS_IN_RACE", 50)
        STAT_SET_INT("USJS_FOUND", 50)
        STAT_SET_INT("USJS_COMPLETED", 50)
        STAT_SET_INT("RACES_WON", 50)
        STAT_SET_BOOL("MPPLY_TOTAL_RACES_WON", 50)
        STAT_SET_BOOL("MPPLY_TOTAL_RACES_LOST", 43)
        STAT_SET_INT("AWD_FM_RACES_FASTEST_LAP", 50)
        STAT_SET_INT("NUMBER_SLIPSTREAMS_IN_RACE", 100)
        STAT_SET_INT("AWD_WIN_CAPTURES 50", 50)
        STAT_SET_INT("AWD_DROPOFF_CAP_PACKAGES", 100)
        STAT_SET_INT("AWD_KILL_CARRIER_CAPTURE", 100)
        STAT_SET_INT("AWD_FINISH_HEISTS", 50)
        STAT_SET_INT("AWD_FINISH_HEIST_SETUP_JOB", 50)
        STAT_SET_INT("AWD_NIGHTVISION_KILLS", 100)
        STAT_SET_INT("AWD_WIN_LAST_TEAM_STANDINGS", 50)
        STAT_SET_INT("AWD_ONLY_PLAYER_ALIVE_LTS", 50)

        STAT_SET_INT("LIFETIME_BUY_COMPLETE", 1000) --- escritorio/mc
        STAT_SET_INT("LIFETIME_BUY_UNDERTAKEN", 1000)
        STAT_SET_INT("LIFETIME_SELL_COMPLETE", 1000)
        STAT_SET_INT("LIFETIME_SELL_UNDERTAKEN", 1000)
        STAT_SET_INT("LIFETIME_CONTRA_EARNINGS", 20000000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET5", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA5", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET5", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA5", 1000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS0", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS1", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS2", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS3", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS4", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS5", 20000000)
    end)

menu.action(UNLOCK_SIMPLES, "Limpar Denúncias", {}, "", function() ---Botão teste
    STAT_SET_INT("MPPLY_REPORT_STRENGTH", 0)
    STAT_SET_INT("MPPLY_COMMEND_STRENGTH", 0)
    STAT_SET_INT("MPPLY_FRIENDLY", 0)
    STAT_SET_INT("MPPLY_HELPFUL", 0)
    STAT_SET_INT("MPPLY_GRIEFING", 0)
    STAT_SET_INT("MPPLY_VC_ANNOYINGME", 0)
    STAT_SET_INT("MPPLY_VC_HATE")
    STAT_SET_INT("MPPLY_TC_ANNOYINGME", 0)
    STAT_SET_INT("MPPLY_TC_HATE", 0)
    STAT_SET_INT("MPPLY_OFFENSIVE_LANGUAGE", 0)
    STAT_SET_INT("MPPLY_OFFENSIVE_TAGPLATE", 0)
    STAT_SET_INT("MPPLY_OFFENSIVE_UGC", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_NAME", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_MOTTO", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_STATUS", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_EMBLEM", 0)
    STAT_SET_INT("MPPLY_EXPLOITS", 0)
    STAT_SET_INT("MPPLY_BECAME_BADSPORT_NUM", 0)
    STAT_SET_INT("MPPLY_DESTROYED_PVEHICLES", 0)
    STAT_SET_INT("MPPLY_BECAME_CHEATER_NUM", 0)
    STAT_SET_INT("MPPLY_BADSPORT_MESSAGE", 0)
    STAT_SET_INT("MPPLY_GAME_EXPLOITS", 0)
    STAT_SET_INT("MPPLY_PLAYER_MENTAL_STATE", 0)
    STAT_SET_INT("MPPLY_PLAYERMADE_TITLE", 0)
    STAT_SET_INT("MPPLY_PLAYERMADE_DESC", 0)
    STAT_SET_INT("MPPLY_OVERALL_BADSPORT", 0)
    STAT_SET_INT("MPPLY_OVERALL_CHEAT", 0)
end)

STAT_SET_BOOL("AWD_CLUB_COORD", true)
menu.action(UNLOCK_SIMPLES, "Troca de Sexo", {},
    "Para funcionar Você deve ir no menu de interação e alternar aparencia do personagem", function()
    STAT_SET_BOOL("ALLOW_GENDER_CHANGE", 52) ---troca de sexo
end)

---Unlock All STUFF
local UNLOCK_STUFF = menu.list(MASTER_UNLOCKR, "Unlock Stuff", { "" },
    "STUFF, nosso unlock um pouco mais poderoso que o tradicional, desbloqueios exta de propriedades etc, tentei deixar a diferença grande de um desbloqueio para o outro, igualmente  não esqueça do tempo de espera!"
    ,
    function()

    end)

menu.action(UNLOCK_STUFF, "Desempenho Pessoal", {},
    "Corridinha, 30C4 10 MINAS, Estatisticas, Lanches e coletes, carregameto mais rapido.  TROQUE DE SALA PARA FUNCIONAR!!!!!"
    ,
    function()
        STAT_SET_INT("CHAR_ABILITY_1_UNLCK", -1) --- Corridinha
        STAT_SET_INT("CHAR_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_ABILITY_3_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_1_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_3_UNLCK", -1)

        STAT_SET_INT("SR_HIGHSCORE_1", 690) ---30c4 10minas
        STAT_SET_INT("SR_HIGHSCORE_2", 1860)
        STAT_SET_INT("SR_HIGHSCORE_3", 2690)
        STAT_SET_INT("SR_HIGHSCORE_4", 2660)
        STAT_SET_INT("SR_HIGHSCORE_5", 450)
        STAT_SET_INT("SR_HIGHSCORE_6", 269)
        STAT_SET_INT("SR_WEAPON_BIT_SET", -1)
        STAT_SET_BOOL("SR_TIER_1_REWARD", true)
        STAT_SET_BOOL("SR_TIER_3_REWARD", true)
        STAT_SET_BOOL("SR_INCREASE_THROW_CAP", true)

        STAT_SET_INT("SCRIPT_INCREASE_STAM", 100) ---Estatisticas
        STAT_SET_INT("SCRIPT_INCREASE_SHO", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STRN", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STL", 100)
        STAT_SET_INT("SCRIPT_INCREASE_FLY", 100)
        STAT_SET_INT("SCRIPT_INCREASE_DRIV", 100)
        STAT_SET_INT("SCRIPT_INCREASE_LUNG", 100)

        STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30) ---Lanches e coletes
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
        STAT_SET_INT("CIGARETTES_BOUGHT", 20)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
        STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)

        SET_INT_GLOBAL(1574589, 1) ---reload
        SET_INT_GLOBAL(1575015, 1)
        SET_INT_GLOBAL(1574589, 0)
    end)

menu.action(UNLOCK_STUFF, "Desbloqueios Geral", {}, "estampas Ammunation/Boate/Bunker/LSC/escritorio-mc/", function()
    STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600) ---estampas Ammunation
    STAT_SET_INT("CMBTPISTOL_ENEMY_KILLS", 600)
    STAT_SET_INT("PISTOL50_ENEMY_KILLS", 600)
    STAT_SET_INT("APPISTOL_ENEMY_KILLS", 600)
    STAT_SET_INT("MICROSMG_ENEMY_KILLS", 600)
    STAT_SET_INT("SMG_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTSMG_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTRIFLE_ENEMY_KILLS", 600)
    STAT_SET_INT("CRBNRIFLE_ENEMY_KILLS", 600)
    STAT_SET_INT("ADVRIFLE_ENEMY_KILLS", 600)
    STAT_SET_INT("MG_ENEMY_KILLS", 600)
    STAT_SET_INT("CMBTMG_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTMG_ENEMY_KILLS", 600)
    STAT_SET_INT("PUMP_ENEMY_KILLS", 600)
    STAT_SET_INT("SAWNOFF_ENEMY_KILLS", 600)
    STAT_SET_INT("BULLPUP_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTSHTGN_ENEMY_KILLS", 600)
    STAT_SET_INT("SNIPERRFL_ENEMY_KILLS", 600)
    STAT_SET_INT("HVYSNIPER_ENEMY_KILLS", 600)
    STAT_SET_INT("GRNLAUNCH_ENEMY_KILLS", 600)
    STAT_SET_INT("RPG_ENEMY_KILLS", 600)
    STAT_SET_INT("MINIGUNS_ENEMY_KILLS", 600)
    STAT_SET_INT("GRENADE_ENEMY_KILLS", 600)
    STAT_SET_INT("SMKGRENADE_ENEMY_KILLS", 600)
    STAT_SET_INT("STKYBMB_ENEMY_KILLS", 600)
    STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600)

    STAT_SET_INT("AWD_DANCE_TO_SOLOMUN", 120) --- Boate
    STAT_SET_INT("AWD_DANCE_TO_TALEOFUS", 120)
    STAT_SET_INT("AWD_DANCE_TO_DIXON", 120)
    STAT_SET_INT("AWD_DANCE_TO_BLKMAD", 120)
    STAT_SET_INT("AWD_CLUB_DRUNK", 200)
    STAT_SET_INT("NIGHTCLUB_VIP_APPEAR", 700)
    STAT_SET_INT("NIGHTCLUB_JOBS_DONE", 700)
    STAT_SET_INT("NIGHTCLUB_EARNINGS", 20721002)
    STAT_SET_INT("HUB_SALES_COMPLETED", 1001)
    STAT_SET_INT("HUB_EARNINGS", 320721002)
    STAT_SET_INT("DANCE_COMBO_DURATION_MINS", 3600000)
    STAT_SET_INT("NIGHTCLUB_PLAYER_APPEAR", 9506)
    STAT_SET_INT("LIFETIME_HUB_GOODS_SOLD", 784672)
    STAT_SET_INT("LIFETIME_HUB_GOODS_MADE", 507822)
    STAT_SET_INT("DANCEPERFECTOWNCLUB", 120)
    STAT_SET_INT("NUMUNIQUEPLYSINCLUB", 120)
    STAT_SET_INT("DANCETODIFFDJS", 4)
    STAT_SET_INT("NIGHTCLUB_HOTSPOT_TIME_MS", 3600000)
    STAT_SET_INT("NIGHTCLUB_CONT_TOTAL", 20)
    STAT_SET_INT("NIGHTCLUB_CONT_MISSION", -1)
    STAT_SET_INT("CLUB_CONTRABAND_MISSION", 1000)
    STAT_SET_INT("HUB_CONTRABAND_MISSION", 1000)
    STAT_SET_BOOL("AWD_CLUB_HOTSPOT", true)
    STAT_SET_BOOL("AWD_CLUB_CLUBBER", true)

    SET_INT_LOCAL("gb_gunrunning", 1203 + 774, 0) ---bunker

    STAT_SET_INT("CHAR_FM_CARMOD_3_UNLCK", -1) ---LSC
    STAT_SET_INT("CHAR_FM_CARMOD_4_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_5_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_6_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_7_UNLCK", -1)
    STAT_SET_INT("AWD_FMRALLYWONDRIVE", 1)
    STAT_SET_INT("AWD_FMWINSEARACE", 1)
    STAT_SET_INT("AWD_FMWINAIRRACE", 1)
    STAT_SET_INT("NUMBER_TURBO_STARTS_IN_RACE", 50)
    STAT_SET_INT("USJS_FOUND", 50)
    STAT_SET_INT("USJS_COMPLETED", 50)
    STAT_SET_INT("RACES_WON", 50)
    STAT_SET_BOOL("MPPLY_TOTAL_RACES_WON", 50)
    STAT_SET_BOOL("MPPLY_TOTAL_RACES_LOST", 43)
    STAT_SET_INT("AWD_FM_RACES_FASTEST_LAP", 50)
    STAT_SET_INT("NUMBER_SLIPSTREAMS_IN_RACE", 100)
    STAT_SET_INT("AWD_WIN_CAPTURES 50", 50)
    STAT_SET_INT("AWD_DROPOFF_CAP_PACKAGES", 100)
    STAT_SET_INT("AWD_KILL_CARRIER_CAPTURE", 100)
    STAT_SET_INT("AWD_FINISH_HEISTS", 50)
    STAT_SET_INT("AWD_FINISH_HEIST_SETUP_JOB", 50)
    STAT_SET_INT("AWD_NIGHTVISION_KILLS", 100)
    STAT_SET_INT("AWD_WIN_LAST_TEAM_STANDINGS", 50)
    STAT_SET_INT("AWD_ONLY_PLAYER_ALIVE_LTS", 50)

    STAT_SET_INT("LIFETIME_BUY_COMPLETE", 1000) --- escritorio/mc
    STAT_SET_INT("LIFETIME_BUY_UNDERTAKEN", 1000)
    STAT_SET_INT("LIFETIME_SELL_COMPLETE", 1000)
    STAT_SET_INT("LIFETIME_SELL_UNDERTAKEN", 1000)
    STAT_SET_INT("LIFETIME_CONTRA_EARNINGS", 20000000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA5", 1000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS0", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS1", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS2", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS3", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS4", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS5", 20000000)
end)

menu.action(UNLOCK_STUFF, "Troca de Sexo", {},
    "Para funcionar Você deve ir no menu de interação e alternar aparencia do personagem", function()
    STAT_SET_BOOL("ALLOW_GENDER_CHANGE", 52) ---troca de sexo
end)

---Unlock All EXTRA
local UNLOCK_EXTRA = menu.list(MASTER_UNLOCKR, "Unlock Extra", { "" },
    "Um dos mais fortes porém menos completo, siga as regras de tempo de espera, assim você vai evitar possiveis erros, sempre uma coisa de cada vez, botei o suficiente em um unico botão para evitar erros de nulo ao desbloquear as coisas NÃO ESQUEÇA DE DAR UM TEMPO A CADA CLIQUE!!!"
    ,
    function()

    end)

menu.action(UNLOCK_EXTRA, "Desempenho Pessoal", {},
    "Corridinha, 30C4 10 MINAS, Estatisticas, Lanches e coletes, carregameto mais rapido.  TROQUE DE SALA PARA FUNCIONAR!!!!!"
    ,
    function()
        STAT_SET_INT("CHAR_ABILITY_1_UNLCK", -1) --- Corridinha
        STAT_SET_INT("CHAR_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_ABILITY_3_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_1_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_3_UNLCK", -1)

        STAT_SET_INT("SR_HIGHSCORE_1", 690) ---30c4 10minas
        STAT_SET_INT("SR_HIGHSCORE_2", 1860)
        STAT_SET_INT("SR_HIGHSCORE_3", 2690)
        STAT_SET_INT("SR_HIGHSCORE_4", 2660)
        STAT_SET_INT("SR_HIGHSCORE_5", 450)
        STAT_SET_INT("SR_HIGHSCORE_6", 269)
        STAT_SET_INT("SR_WEAPON_BIT_SET", -1)
        STAT_SET_BOOL("SR_TIER_1_REWARD", true)
        STAT_SET_BOOL("SR_TIER_3_REWARD", true)
        STAT_SET_BOOL("SR_INCREASE_THROW_CAP", true)

        STAT_SET_INT("SCRIPT_INCREASE_STAM", 100) ---Estatisticas
        STAT_SET_INT("SCRIPT_INCREASE_SHO", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STRN", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STL", 100)
        STAT_SET_INT("SCRIPT_INCREASE_FLY", 100)
        STAT_SET_INT("SCRIPT_INCREASE_DRIV", 100)
        STAT_SET_INT("SCRIPT_INCREASE_LUNG", 100)

        STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30) ---Lanches e coletes
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
        STAT_SET_INT("CIGARETTES_BOUGHT", 20)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
        STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)

        SET_INT_GLOBAL(1574589, 1) ---reload
        SET_INT_GLOBAL(1575015, 1)
        SET_INT_GLOBAL(1574589, 0)
    end)

menu.action(UNLOCK_EXTRA, "Desbloqueios Geral", {}, "estampas Ammunation/Boate/Bunker/LSC/escritorio-mc/", function()
    STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600) ---estampas Ammunation
    STAT_SET_INT("CMBTPISTOL_ENEMY_KILLS", 600)
    STAT_SET_INT("PISTOL50_ENEMY_KILLS", 600)
    STAT_SET_INT("APPISTOL_ENEMY_KILLS", 600)
    STAT_SET_INT("MICROSMG_ENEMY_KILLS", 600)
    STAT_SET_INT("SMG_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTSMG_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTRIFLE_ENEMY_KILLS", 600)
    STAT_SET_INT("CRBNRIFLE_ENEMY_KILLS", 600)
    STAT_SET_INT("ADVRIFLE_ENEMY_KILLS", 600)
    STAT_SET_INT("MG_ENEMY_KILLS", 600)
    STAT_SET_INT("CMBTMG_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTMG_ENEMY_KILLS", 600)
    STAT_SET_INT("PUMP_ENEMY_KILLS", 600)
    STAT_SET_INT("SAWNOFF_ENEMY_KILLS", 600)
    STAT_SET_INT("BULLPUP_ENEMY_KILLS", 600)
    STAT_SET_INT("ASLTSHTGN_ENEMY_KILLS", 600)
    STAT_SET_INT("SNIPERRFL_ENEMY_KILLS", 600)
    STAT_SET_INT("HVYSNIPER_ENEMY_KILLS", 600)
    STAT_SET_INT("GRNLAUNCH_ENEMY_KILLS", 600)
    STAT_SET_INT("RPG_ENEMY_KILLS", 600)
    STAT_SET_INT("MINIGUNS_ENEMY_KILLS", 600)
    STAT_SET_INT("GRENADE_ENEMY_KILLS", 600)
    STAT_SET_INT("SMKGRENADE_ENEMY_KILLS", 600)
    STAT_SET_INT("STKYBMB_ENEMY_KILLS", 600)
    STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600)

    STAT_SET_INT("AWD_DANCE_TO_SOLOMUN", 120) --- Boate
    STAT_SET_INT("AWD_DANCE_TO_TALEOFUS", 120)
    STAT_SET_INT("AWD_DANCE_TO_DIXON", 120)
    STAT_SET_INT("AWD_DANCE_TO_BLKMAD", 120)
    STAT_SET_INT("AWD_CLUB_DRUNK", 200)
    STAT_SET_INT("NIGHTCLUB_VIP_APPEAR", 700)
    STAT_SET_INT("NIGHTCLUB_JOBS_DONE", 700)
    STAT_SET_INT("NIGHTCLUB_EARNINGS", 20721002)
    STAT_SET_INT("HUB_SALES_COMPLETED", 1001)
    STAT_SET_INT("HUB_EARNINGS", 320721002)
    STAT_SET_INT("DANCE_COMBO_DURATION_MINS", 3600000)
    STAT_SET_INT("NIGHTCLUB_PLAYER_APPEAR", 9506)
    STAT_SET_INT("LIFETIME_HUB_GOODS_SOLD", 784672)
    STAT_SET_INT("LIFETIME_HUB_GOODS_MADE", 507822)
    STAT_SET_INT("DANCEPERFECTOWNCLUB", 120)
    STAT_SET_INT("NUMUNIQUEPLYSINCLUB", 120)
    STAT_SET_INT("DANCETODIFFDJS", 4)
    STAT_SET_INT("NIGHTCLUB_HOTSPOT_TIME_MS", 3600000)
    STAT_SET_INT("NIGHTCLUB_CONT_TOTAL", 20)
    STAT_SET_INT("NIGHTCLUB_CONT_MISSION", -1)
    STAT_SET_INT("CLUB_CONTRABAND_MISSION", 1000)
    STAT_SET_INT("HUB_CONTRABAND_MISSION", 1000)
    STAT_SET_BOOL("AWD_CLUB_HOTSPOT", true)
    STAT_SET_BOOL("AWD_CLUB_CLUBBER", true)

    SET_INT_LOCAL("gb_gunrunning", 1203 + 774, 0) ---bunker

    STAT_SET_INT("CHAR_FM_CARMOD_3_UNLCK", -1) ---LSC
    STAT_SET_INT("CHAR_FM_CARMOD_4_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_5_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_6_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_7_UNLCK", -1)
    STAT_SET_INT("AWD_FMRALLYWONDRIVE", 1)
    STAT_SET_INT("AWD_FMWINSEARACE", 1)
    STAT_SET_INT("AWD_FMWINAIRRACE", 1)
    STAT_SET_INT("NUMBER_TURBO_STARTS_IN_RACE", 50)
    STAT_SET_INT("USJS_FOUND", 50)
    STAT_SET_INT("USJS_COMPLETED", 50)
    STAT_SET_INT("RACES_WON", 50)
    STAT_SET_BOOL("MPPLY_TOTAL_RACES_WON", 50)
    STAT_SET_BOOL("MPPLY_TOTAL_RACES_LOST", 43)
    STAT_SET_INT("AWD_FM_RACES_FASTEST_LAP", 50)
    STAT_SET_INT("NUMBER_SLIPSTREAMS_IN_RACE", 100)
    STAT_SET_INT("AWD_WIN_CAPTURES 50", 50)
    STAT_SET_INT("AWD_DROPOFF_CAP_PACKAGES", 100)
    STAT_SET_INT("AWD_KILL_CARRIER_CAPTURE", 100)
    STAT_SET_INT("AWD_FINISH_HEISTS", 50)
    STAT_SET_INT("AWD_FINISH_HEIST_SETUP_JOB", 50)
    STAT_SET_INT("AWD_NIGHTVISION_KILLS", 100)
    STAT_SET_INT("AWD_WIN_LAST_TEAM_STANDINGS", 50)
    STAT_SET_INT("AWD_ONLY_PLAYER_ALIVE_LTS", 50)

    STAT_SET_INT("LIFETIME_BUY_COMPLETE", 1000) --- escritorio/mc
    STAT_SET_INT("LIFETIME_BUY_UNDERTAKEN", 1000)
    STAT_SET_INT("LIFETIME_SELL_COMPLETE", 1000)
    STAT_SET_INT("LIFETIME_SELL_UNDERTAKEN", 1000)
    STAT_SET_INT("LIFETIME_CONTRA_EARNINGS", 20000000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA5", 1000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS0", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS1", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS2", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS3", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS4", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS5", 20000000)
end)

menu.action(UNLOCK_EXTRA, "Troca de Sexo", {},
    "Para funcionar Você deve ir no menu de interação e alternar aparencia do personagem", function()
    STAT_SET_BOOL("ALLOW_GENDER_CHANGE", 52) ---troca de sexo
end)

---Unlock All EXTREME
local UNLOCK_EXTREME = menu.list(MASTER_UNLOCKR, "Unlock Extreme", { "" },
    "Esse é nosso unlock mais forte, tome cuidado, de um cooldown de no minimo 5 minutos a cada botão, ou a partir do momento que encerrar as transações, remocmendo trocar de sessão a cado botão, NÃO ESQUEÇA DO TEMPO RECOMENDADO!!!!!!!!!!!!!"
    ,
    function()

    end)

menu.action(UNLOCK_EXTRA, "Carregamento Rápido", {}, "Carrega suas armas mais rapido", function()

end)

menu.action(UNLOCK_EXTREME, "Desempenho Pessoal", {},
    "Corridinha, 30C4 10 MINAS, Estatisticas, Lanches e coletes, carregameto mais rapido.  TROQUE DE SALA PARA FUNCIONAR!!!!!"
    ,
    function()
        STAT_SET_INT("CHAR_ABILITY_1_UNLCK", -1) --- Corridinha
        STAT_SET_INT("CHAR_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_ABILITY_3_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_1_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_2_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_ABILITY_3_UNLCK", -1)

        STAT_SET_INT("SR_HIGHSCORE_1", 690) ---30c4 10minas
        STAT_SET_INT("SR_HIGHSCORE_2", 1860)
        STAT_SET_INT("SR_HIGHSCORE_3", 2690)
        STAT_SET_INT("SR_HIGHSCORE_4", 2660)
        STAT_SET_INT("SR_HIGHSCORE_5", 450)
        STAT_SET_INT("SR_HIGHSCORE_6", 269)
        STAT_SET_INT("SR_WEAPON_BIT_SET", -1)
        STAT_SET_BOOL("SR_TIER_1_REWARD", true)
        STAT_SET_BOOL("SR_TIER_3_REWARD", true)
        STAT_SET_BOOL("SR_INCREASE_THROW_CAP", true)

        STAT_SET_INT("SCRIPT_INCREASE_STAM", 100) ---Estatisticas
        STAT_SET_INT("SCRIPT_INCREASE_SHO", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STRN", 100)
        STAT_SET_INT("SCRIPT_INCREASE_STL", 100)
        STAT_SET_INT("SCRIPT_INCREASE_FLY", 100)
        STAT_SET_INT("SCRIPT_INCREASE_DRIV", 100)
        STAT_SET_INT("SCRIPT_INCREASE_LUNG", 100)

        STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30) ---Lanches e coletes
        STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
        STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
        STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
        STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
        STAT_SET_INT("CIGARETTES_BOUGHT", 20)
        STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
        STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
        STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)

        SET_INT_GLOBAL(1574589, 1) ---reload
        SET_INT_GLOBAL(1575015, 1)
        SET_INT_GLOBAL(1574589, 0)
    end)

menu.action(UNLOCK_EXTREME, "Desbloqueios Geral", {}, "estampas Ammunation/Boate/Bunker/LSC/escritorio-mc/",
    function()
        STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600) ---estampas Ammunation
        STAT_SET_INT("CMBTPISTOL_ENEMY_KILLS", 600)
        STAT_SET_INT("PISTOL50_ENEMY_KILLS", 600)
        STAT_SET_INT("APPISTOL_ENEMY_KILLS", 600)
        STAT_SET_INT("MICROSMG_ENEMY_KILLS", 600)
        STAT_SET_INT("SMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTSMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("CRBNRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("ADVRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("MG_ENEMY_KILLS", 600)
        STAT_SET_INT("CMBTMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTMG_ENEMY_KILLS", 600)
        STAT_SET_INT("PUMP_ENEMY_KILLS", 600)
        STAT_SET_INT("SAWNOFF_ENEMY_KILLS", 600)
        STAT_SET_INT("BULLPUP_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTSHTGN_ENEMY_KILLS", 600)
        STAT_SET_INT("SNIPERRFL_ENEMY_KILLS", 600)
        STAT_SET_INT("HVYSNIPER_ENEMY_KILLS", 600)
        STAT_SET_INT("GRNLAUNCH_ENEMY_KILLS", 600)
        STAT_SET_INT("RPG_ENEMY_KILLS", 600)
        STAT_SET_INT("MINIGUNS_ENEMY_KILLS", 600)
        STAT_SET_INT("GRENADE_ENEMY_KILLS", 600)
        STAT_SET_INT("SMKGRENADE_ENEMY_KILLS", 600)
        STAT_SET_INT("STKYBMB_ENEMY_KILLS", 600)
        STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600)

        STAT_SET_INT("AWD_DANCE_TO_SOLOMUN", 120) --- Boate
        STAT_SET_INT("AWD_DANCE_TO_TALEOFUS", 120)
        STAT_SET_INT("AWD_DANCE_TO_DIXON", 120)
        STAT_SET_INT("AWD_DANCE_TO_BLKMAD", 120)
        STAT_SET_INT("AWD_CLUB_DRUNK", 200)
        STAT_SET_INT("NIGHTCLUB_VIP_APPEAR", 700)
        STAT_SET_INT("NIGHTCLUB_JOBS_DONE", 700)
        STAT_SET_INT("NIGHTCLUB_EARNINGS", 20721002)
        STAT_SET_INT("HUB_SALES_COMPLETED", 1001)
        STAT_SET_INT("HUB_EARNINGS", 320721002)
        STAT_SET_INT("DANCE_COMBO_DURATION_MINS", 3600000)
        STAT_SET_INT("NIGHTCLUB_PLAYER_APPEAR", 9506)
        STAT_SET_INT("LIFETIME_HUB_GOODS_SOLD", 784672)
        STAT_SET_INT("LIFETIME_HUB_GOODS_MADE", 507822)
        STAT_SET_INT("DANCEPERFECTOWNCLUB", 120)
        STAT_SET_INT("NUMUNIQUEPLYSINCLUB", 120)
        STAT_SET_INT("DANCETODIFFDJS", 4)
        STAT_SET_INT("NIGHTCLUB_HOTSPOT_TIME_MS", 3600000)
        STAT_SET_INT("NIGHTCLUB_CONT_TOTAL", 20)
        STAT_SET_INT("NIGHTCLUB_CONT_MISSION", -1)
        STAT_SET_INT("CLUB_CONTRABAND_MISSION", 1000)
        STAT_SET_INT("HUB_CONTRABAND_MISSION", 1000)
        STAT_SET_BOOL("AWD_CLUB_HOTSPOT", true)
        STAT_SET_BOOL("AWD_CLUB_CLUBBER", true)

        SET_INT_LOCAL("gb_gunrunning", 1203 + 774, 0) ---bunker

        STAT_SET_INT("CHAR_FM_CARMOD_3_UNLCK", -1) ---LSC
        STAT_SET_INT("CHAR_FM_CARMOD_4_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_CARMOD_5_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_CARMOD_6_UNLCK", -1)
        STAT_SET_INT("CHAR_FM_CARMOD_7_UNLCK", -1)
        STAT_SET_INT("AWD_FMRALLYWONDRIVE", 1)
        STAT_SET_INT("AWD_FMWINSEARACE", 1)
        STAT_SET_INT("AWD_FMWINAIRRACE", 1)
        STAT_SET_INT("NUMBER_TURBO_STARTS_IN_RACE", 50)
        STAT_SET_INT("USJS_FOUND", 50)
        STAT_SET_INT("USJS_COMPLETED", 50)
        STAT_SET_INT("RACES_WON", 50)
        STAT_SET_BOOL("MPPLY_TOTAL_RACES_WON", 50)
        STAT_SET_BOOL("MPPLY_TOTAL_RACES_LOST", 43)
        STAT_SET_INT("AWD_FM_RACES_FASTEST_LAP", 50)
        STAT_SET_INT("NUMBER_SLIPSTREAMS_IN_RACE", 100)
        STAT_SET_INT("AWD_WIN_CAPTURES 50", 50)
        STAT_SET_INT("AWD_DROPOFF_CAP_PACKAGES", 100)
        STAT_SET_INT("AWD_KILL_CARRIER_CAPTURE", 100)
        STAT_SET_INT("AWD_FINISH_HEISTS", 50)
        STAT_SET_INT("AWD_FINISH_HEIST_SETUP_JOB", 50)
        STAT_SET_INT("AWD_NIGHTVISION_KILLS", 100)
        STAT_SET_INT("AWD_WIN_LAST_TEAM_STANDINGS", 50)
        STAT_SET_INT("AWD_ONLY_PLAYER_ALIVE_LTS", 50)

        STAT_SET_INT("LIFETIME_BUY_COMPLETE", 1000) --- escritorio/mc
        STAT_SET_INT("LIFETIME_BUY_UNDERTAKEN", 1000)
        STAT_SET_INT("LIFETIME_SELL_COMPLETE", 1000)
        STAT_SET_INT("LIFETIME_SELL_UNDERTAKEN", 1000)
        STAT_SET_INT("LIFETIME_CONTRA_EARNINGS", 20000000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA1", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA2", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA3", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA4", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET5", 1000)
        STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA5", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET5", 1000)
        STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA5", 1000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS0", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS1", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS2", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS3", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS4", 20000000)
        STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS5", 20000000)
    end)

menu.action(UNLOCK_EXTREME, "Troca de Sexo", {},
    "Para funcionar Você deve ir no menu de interação e alternar aparencia do personagem", function()
    STAT_SET_BOOL("ALLOW_GENDER_CHANGE", 52) ---troca de sexo
end)

menu.action(UNLOCK_EXTREME, "Todas as Roupas", {},
    "sapatos, sasquatch, camisas arcade, camisas cassino, camisola Festiva, Fabricante de Camisas, Fatos de Dublês, Bodysuits Wireframe, camisas, Moletons, Camisetas dos clubes, camisas de filme, knock offs, Camisas de Marcas, chapeus, vestuario de natal, Camisetas / Jaquetas / suéteres, Calção/Calças, Caps/chapeus/Bonés/fones, Pulseiras, Óculos, Colares, Máscaras em Geral, camisetas de DJ/DJ pooh, Paraquedas"
    ,
    function()

        ---sapatos
        SET_INT_GLOBAL(262145 + 32924, 1); ---- Wild Striped Pool Sliders
        SET_INT_GLOBAL(262145 + 32925, 1); ---- Neon Striped Pool Sliders
        SET_INT_GLOBAL(262145 + 32926, 1); ---- Black SC Coin Pool Sliders
        SET_INT_GLOBAL(262145 + 32927, 1); ---- White SC Coin Pool Sliders
        SET_INT_GLOBAL(262145 + 32928, 1); ---- Black SC Pattern Pool Sliders
        SET_INT_GLOBAL(262145 + 32929, 1); ---- Pink SC Pattern Pool Sliders
        SET_INT_GLOBAL(262145 + 32930, 1); ---- Blue SC Pattern Pool Sliders
        SET_INT_GLOBAL(262145 + 32931, 1); ---- Camo Yeti Pool Sliders
        SET_INT_GLOBAL(262145 + 32932, 1); ---- Grey Camo Yeti Pool Sliders
        SET_INT_GLOBAL(262145 + 32933, 1); ---- Black Bigness Pool Sliders
        SET_INT_GLOBAL(262145 + 32934, 1); ---- Purple Bigness Pool Sliders
        SET_INT_GLOBAL(262145 + 32935, 1); ---- Camo Bigness Pool Sliders
        SET_INT_GLOBAL(262145 + 32936, 1); ---- Black Blaguers Pool Sliders
        SET_INT_GLOBAL(262145 + 32937, 1); ---- White Blaguers Pool Sliders
        SET_INT_GLOBAL(262145 + 32938, 1); ---- Pink Blaguers Pool Sliders
        SET_INT_GLOBAL(262145 + 32939, 1); ---- Grey Cimicino Pool Sliders
        SET_INT_GLOBAL(262145 + 32940, 1); ---- Rouge Cimicino Pool Sliders
        SET_INT_GLOBAL(262145 + 32941, 1); ---- Navy DS Pool Sliders
        SET_INT_GLOBAL(262145 + 32942, 1); ---- Red DS Pool Sliders
        SET_INT_GLOBAL(262145 + 32943, 1); ---- Floral Guffy Pool Sliders
        SET_INT_GLOBAL(262145 + 32944, 1); ---- Green Guffy Pool Sliders
        SET_INT_GLOBAL(262145 + 32945, 1); ---- White Guffy Pool Sliders
        SET_INT_GLOBAL(262145 + 32946, 1); ---- Blue Heat Pool Sliders
        SET_INT_GLOBAL(262145 + 32947, 1); ---- Red ProLaps Pool Sliders

        ---sasquatch
        SET_INT_GLOBAL(262145 + 32848, 1); ---- Sasquatch

        ---camisas arcade
        SET_INT_GLOBAL(262145 + 28304, 1); ---- "Street Crimes Boxart Tee"
        SET_INT_GLOBAL(262145 + 28305, 1); ---- "Street Crimes Logo Tee"
        SET_INT_GLOBAL(262145 + 28306, 1); ---- "("Claim What's Yours Tee"
        SET_INT_GLOBAL(262145 + 28307, 1); ---- "Choose Your Side Tee"
        SET_INT_GLOBAL(262145 + 28308, 1); ---- "Street Crimes Color Gangs Tee"
        SET_INT_GLOBAL(262145 + 28309, 1); ---- "Street Crimes Red Gangs Tee"
        SET_INT_GLOBAL(262145 + 28310, 1); ---- "White Street Crimes Icons Tee"
        SET_INT_GLOBAL(262145 + 28311, 1); ---- "Black Street Crimes Icons Tee"
        SET_INT_GLOBAL(262145 + 28312, 1); ---- "Invade and Persuade Logo Tee"
        SET_INT_GLOBAL(262145 + 28313, 1); ---- "Mission I Tee"
        SET_INT_GLOBAL(262145 + 28314, 1); ---- "Mission II Tee"
        SET_INT_GLOBAL(262145 + 28315, 1); ---- "Mission IV Tee"
        SET_INT_GLOBAL(262145 + 28316, 1); ---- "Mission III Tee"
        SET_INT_GLOBAL(262145 + 28317, 1); ---- "Invade and Persuade Boxart Tee"
        SET_INT_GLOBAL(262145 + 28318, 1); ---- "Invade and Persuade Invader Tee"
        SET_INT_GLOBAL(262145 + 28319, 1); ---- "Invade and Persuade Suck Tee"
        SET_INT_GLOBAL(262145 + 28320, 1); ---- "Invade and Persuade Jets Tee"
        SET_INT_GLOBAL(262145 + 28321, 1); ---- "Invade and Persuade Gold Tee"
        SET_INT_GLOBAL(262145 + 28322, 1); ---- "Invade and Persuade Hero Tee"
        SET_INT_GLOBAL(262145 + 28323, 1); ---- "Invade and Persuade Barrels Tee"

        ---camisas cassino
        SET_INT_GLOBAL(262145 + 27015, 1); ---- "The Diamond ("Classics Tee"
        SET_INT_GLOBAL(262145 + 27016, 1); ---- "The Diamond Vintage Tee"
        SET_INT_GLOBAL(262145 + 27017, 1); ---- "Red The Diamond Resort LS Tee"
        SET_INT_GLOBAL(262145 + 27018, 1); ---- "Blue The Diamond Resort LS Tee"
        SET_INT_GLOBAL(262145 + 27019, 1); ---- "Red The Diamond Resort Tee"
        SET_INT_GLOBAL(262145 + 27020, 1); ---- "Blue D Casino Tee"
        SET_INT_GLOBAL(262145 + 27021, 1); ---- "Red The Diamond ("Classic Tee"

        ---camisola Festiva
        SET_INT_GLOBAL(262145 + 25898, 1); ---- "Burger Shot Festive Sweater"
        SET_INT_GLOBAL(262145 + 25899, 1); ---- "Red Bleeder Festive Sweater"
        SET_INT_GLOBAL(262145 + 25900, 1); ---- "Blue Bleeder Festive Sweater"
        SET_INT_GLOBAL(262145 + 25901, 1); ---- "Blue ("Cluckin' Festive Sweater"
        SET_INT_GLOBAL(262145 + 25902, 1); ---- "Green ("Cluckin' Festive Sweater"
        SET_INT_GLOBAL(262145 + 25903, 1); ---- "Blue Slaying Festive Sweater"
        SET_INT_GLOBAL(262145 + 25904, 1); ---- "Green Slaying Festive Sweater"
        SET_INT_GLOBAL(262145 + 25905, 1); ---- "Hail Santa Festive Sweater"
        SET_INT_GLOBAL(262145 + 25906, 1); ---- "Merrry Sprunkmas Festive Sweater"
        SET_INT_GLOBAL(262145 + 25907, 1); ---- "Ice Cold Sprunk Festive Sweater"

        ---Fabricante de Camisas
        SET_INT_GLOBAL(262145 + 25830, 1); ---- "Albany Tee"
        SET_INT_GLOBAL(262145 + 25831, 1); ---- "Albany Vintage Tee"
        SET_INT_GLOBAL(262145 + 25832, 1); ---- "Annis Tee"
        SET_INT_GLOBAL(262145 + 25833, 1); ---- "Benefector Tee"
        SET_INT_GLOBAL(262145 + 25834, 1); ---- "BF Tee"
        SET_INT_GLOBAL(262145 + 25835, 1); ---- "Bollokan Tee"
        SET_INT_GLOBAL(262145 + 25836, 1); ---- "Bravado Tee"
        SET_INT_GLOBAL(262145 + 25837, 1); ---- "Brute Tee"
        SET_INT_GLOBAL(262145 + 25838, 1); ---- "Buckingham Tee"
        SET_INT_GLOBAL(262145 + 25839, 1); ---- "Canis Tee"
        SET_INT_GLOBAL(262145 + 25840, 1); ---- "Chariot Tee"
        SET_INT_GLOBAL(262145 + 25841, 1); ---- "Cheval Tee"
        SET_INT_GLOBAL(262145 + 25842, 1); ---- "("Classigue Tee"
        SET_INT_GLOBAL(262145 + 25843, 1); ---- "Coil Tee"
        SET_INT_GLOBAL(262145 + 25844, 1); ---- "De("classe Tee"
        SET_INT_GLOBAL(262145 + 25845, 1); ---- "Dewbauchee Tee"
        SET_INT_GLOBAL(262145 + 25846, 1); ---- "Dilettante Tee"
        SET_INT_GLOBAL(262145 + 25847, 1); ---- "Dinka Tee"
        SET_INT_GLOBAL(262145 + 25848, 1); ---- "Dundreary Tee"
        SET_INT_GLOBAL(262145 + 25849, 1); ---- "Emperor Tee"
        SET_INT_GLOBAL(262145 + 25850, 1); ---- "Enus Tee"
        SET_INT_GLOBAL(262145 + 25851, 1); ---- "Fathom Tee"
        SET_INT_GLOBAL(262145 + 25852, 1); ---- "Gallivanter Tee"
        SET_INT_GLOBAL(262145 + 25853, 1); ---- "Grotti Tee"
        SET_INT_GLOBAL(262145 + 25854, 1); ---- "Hijak Tee"
        SET_INT_GLOBAL(262145 + 25855, 1); ---- "HVT Tee"
        SET_INT_GLOBAL(262145 + 25856, 1); ---- "Imponte Tee"
        SET_INT_GLOBAL(262145 + 25857, 1); ---- "Invetero Tee"
        SET_INT_GLOBAL(262145 + 25858, 1); ---- "Jobuilt Tee"
        SET_INT_GLOBAL(262145 + 25859, 1); ---- "Karin Tee"
        SET_INT_GLOBAL(262145 + 25860, 1); ---- "Lampadati Tee"
        SET_INT_GLOBAL(262145 + 25861, 1); ---- "Maibatsu Tee"
        SET_INT_GLOBAL(262145 + 25862, 1); ---- "Mamba Tee"
        SET_INT_GLOBAL(262145 + 25863, 1); ---- "Mammoth Tee"
        SET_INT_GLOBAL(262145 + 25864, 1); ---- "MTL Tee"
        SET_INT_GLOBAL(262145 + 25865, 1); ---- "Obey Tee"
        SET_INT_GLOBAL(262145 + 25866, 1); ---- "Ocelot Tee"
        SET_INT_GLOBAL(262145 + 25867, 1); ---- "Overflod Tee"
        SET_INT_GLOBAL(262145 + 25868, 1); ---- "Pegassi Tee"
        SET_INT_GLOBAL(262145 + 25869, 1); ---- "Pfister Tee"
        SET_INT_GLOBAL(262145 + 25870, 1); ---- "Progen Tee"
        SET_INT_GLOBAL(262145 + 25871, 1); ---- "Rune Tee"
        SET_INT_GLOBAL(262145 + 25872, 1); ---- "Schyster Tee"
        SET_INT_GLOBAL(262145 + 25873, 1); ---- "Shitzu Tee"
        SET_INT_GLOBAL(262145 + 25874, 1); ---- "Truffade Tee"
        SET_INT_GLOBAL(262145 + 25875, 1); ---- "Ubermacht Tee"
        SET_INT_GLOBAL(262145 + 25876, 1); ---- "Vapid Tee"
        SET_INT_GLOBAL(262145 + 25877, 1); ---- "Vulcar Tee"
        SET_INT_GLOBAL(262145 + 25878, 1); ---- "Weeny Tee"
        SET_INT_GLOBAL(262145 + 25879, 1); ---- "Willard Tee"
        SET_INT_GLOBAL(262145 + 25880, 1); ---- "Albany Nostalgia Tee"
        SET_INT_GLOBAL(262145 + 25881, 1); ---- "Albany USA Tee"
        SET_INT_GLOBAL(262145 + 25882, 1); ---- "Albany Dealership Tee"
        SET_INT_GLOBAL(262145 + 25883, 1); ---- "Annis JPN Tee"
        SET_INT_GLOBAL(262145 + 25884, 1); ---- "BF Surfer Tee"
        SET_INT_GLOBAL(262145 + 25885, 1); ---- "Bollokan Prairie Tee"
        SET_INT_GLOBAL(262145 + 25886, 1); ---- "Bravado Stylized Tee"
        SET_INT_GLOBAL(262145 + 25887, 1); ---- "Brute Impregnable Tee"
        SET_INT_GLOBAL(262145 + 25888, 1); ---- "Brute Heavy Duty Tee"
        SET_INT_GLOBAL(262145 + 25889, 1); ---- "Buckingham Luxe Tee"
        SET_INT_GLOBAL(262145 + 25890, 1); ---- "Canis USA Tee"
        SET_INT_GLOBAL(262145 + 25891, 1); ---- "Canis American Legend Tee"
        SET_INT_GLOBAL(262145 + 25892, 1); ---- "Canis Wolf Tee"
        SET_INT_GLOBAL(262145 + 25893, 1); ---- "Cheval Marshall Tee"
        SET_INT_GLOBAL(262145 + 25894, 1); ---- "Coil USA Tee"
        SET_INT_GLOBAL(262145 + 25895, 1); ---- "Coil Raiden Tee"
        SET_INT_GLOBAL(262145 + 25896, 1); ---- "De("classe Logo Tee"
        SET_INT_GLOBAL(262145 + 25897, 1); ---- "De("classe Girl Tee
        SET_INT_GLOBAL(262145 + 15222, 1); ---- "Grotti Shirt"
        SET_INT_GLOBAL(262145 + 17580, 1); ---- "Western Brand White Tee"
        SET_INT_GLOBAL(262145 + 17581, 1); ---- "Western Brand Black Tee"
        SET_INT_GLOBAL(262145 + 17582, 1); ---- "Western Logo White Tee"
        SET_INT_GLOBAL(262145 + 17583, 1); ---- "Western Logo Black Tee"
        SET_INT_GLOBAL(262145 + 17584, 1); ---- "Steel Horse Solid Logo Tee"
        SET_INT_GLOBAL(262145 + 17585, 1); ---- "Steel Horse Logo Tee"
        SET_INT_GLOBAL(262145 + 17586, 1); ---- "Steel Horse Brand White Tee"
        SET_INT_GLOBAL(262145 + 17587, 1); ---- "Steel Horse Brand Black Tee"
        SET_INT_GLOBAL(262145 + 17588, 1); ---- "Nagasaki White Tee"
        SET_INT_GLOBAL(262145 + 17589, 1); ---- "Nagasaki White And Red Tee"
        SET_INT_GLOBAL(262145 + 17590, 1); ---- "Nagasaki Black Tee"
        SET_INT_GLOBAL(262145 + 17591, 1); ---- "Purple Helmets Black Tee"
        SET_INT_GLOBAL(262145 + 17592, 1); ---- "Principe Black Tee"
        SET_INT_GLOBAL(262145 + 17593, 1); ---- "Steel Horse Black Hoodie"
        SET_INT_GLOBAL(262145 + 17594, 1); ---- "Steel Horse White Hoodie"
        SET_INT_GLOBAL(262145 + 17595, 1); ---- "Western Black Hoodie"
        SET_INT_GLOBAL(262145 + 17596, 1); ---- "Western White Hoodie"
        SET_INT_GLOBAL(262145 + 17597, 1); ---- "Nagasaki White Hoodie"
        SET_INT_GLOBAL(262145 + 17598, 1); ---- "Nagasaki White And Red Hoodie"
        SET_INT_GLOBAL(262145 + 17599, 1); ---- "Nagasaki Black Hoodie"
        SET_INT_GLOBAL(262145 + 17600, 1); ---- "Purple Helmets Black Hoodie"
        SET_INT_GLOBAL(262145 + 17601, 1); ---- "Principe Hoodie Black"

        ---Fatos de Dublês
        SET_INT_GLOBAL(262145 + 16839, 1); ---- "White Jock Cranley Suit"
        SET_INT_GLOBAL(262145 + 16840, 1); ---- "Blue Jock Cranley Suit"
        SET_INT_GLOBAL(262145 + 16841, 1); ---- "Red Jock Cranley Suit"
        SET_INT_GLOBAL(262145 + 16842, 1); ---- "Gold Jock Cranley Suit"
        SET_INT_GLOBAL(262145 + 16843, 1); ---- "Black Jock Cranley Suit"
        SET_INT_GLOBAL(262145 + 16844, 1); ---- "Pink Jock Cranley Suit"
        SET_INT_GLOBAL(262145 + 16845, 1); ---- "Silver Jock Cranley Suit"

        ---Bodysuits Wireframe
        SET_INT_GLOBAL(262145 + 23435, 1); ---- "Green Wireframe Bodysuit"
        SET_INT_GLOBAL(262145 + 23436, 1); ---- "Orange Wireframe Bodysuit"
        SET_INT_GLOBAL(262145 + 23437, 1); ---- "Blue Wireframe Bodysuit"
        SET_INT_GLOBAL(262145 + 23438, 1); ---- "Pink Wireframe Bodysuit"
        SET_INT_GLOBAL(262145 + 23439, 1); ---- "Yellow Wireframe Bodysuit"
        SET_INT_GLOBAL(262145 + 23435, 1); ---- Bodysuit Green
        SET_INT_GLOBAL(262145 + 23436, 1); ---- Bodysuit Orange
        SET_INT_GLOBAL(262145 + 23437, 1); ---- Bodysuit Blue
        SET_INT_GLOBAL(262145 + 23438, 1); ---- Bodysuit Pink
        SET_INT_GLOBAL(262145 + 23439, 1); ---- Bodysuit Yellow

        ----camisas
        SET_INT_GLOBAL(262145 + 21155, 1); ---- "BLACK_AMMUNATION_TEE"
        SET_INT_GLOBAL(262145 + 21157, 1); ---- "BLACK_COIL_TEE"
        SET_INT_GLOBAL(262145 + 21159, 1); ---- "BLACK_HAWK_AND_LITTLE_LOGO_TEE"
        SET_INT_GLOBAL(262145 + 21160, 1); ---- "BLACK_HAWK_AND_LITTLE_TEE"
        SET_INT_GLOBAL(262145 + 21164, 1); ---- "GREEN_VOM_FEUER_TEE"
        SET_INT_GLOBAL(262145 + 21167, 1); ---- "WHITE_AMMUNATION_TEE"
        SET_INT_GLOBAL(262145 + 21169, 1); ---- "WHITE_COIL_TEE"
        SET_INT_GLOBAL(262145 + 21171, 1); ---- "WHITE_HAWK_AND_LITTLE_TEE"
        SET_INT_GLOBAL(262145 + 21172, 1); ---- "WHITE_SHREWSBURY_TEE"
        SET_INT_GLOBAL(262145 + 21175, 1); ---- "WHITE_SHREWSBURY_LOGO_TEE"
        SET_INT_GLOBAL(262145 + 21179, 1); ---- "YELLOW_VOM_FEUER_LOGO_TEE"
        SET_INT_GLOBAL(262145 + 21180, 1); ---- "YELLOW_VOM_FEUER_TEE"
        SET_INT_GLOBAL(262145 + 21181, 1); ---- "YELLOW_WARSTOCK_TEE"
        SET_INT_GLOBAL(262145 + 21182, 1); ---- "BLUE_R*_("CLASS_OF_98"
        SET_INT_GLOBAL(262145 + 21183, 1); ---- "RED_R*_("CLASS_OF_98"
        SET_INT_GLOBAL(262145 + 21184, 1); ---- "NOISE_ROCKSTAR_LOGO_TEE"
        SET_INT_GLOBAL(262145 + 21185, 1); ---- "NOISE_TEE"
        SET_INT_GLOBAL(262145 + 21186, 1); ---- "RAZOR_TEE"
        SET_INT_GLOBAL(262145 + 21187, 1); ---- "BLACK_ROCKSTAR_CAMO"
        SET_INT_GLOBAL(262145 + 21188, 1); ---- "WHITE_ROCKSTAR_CAMO"
        SET_INT_GLOBAL(262145 + 21189, 1); ---- "KNUCKLEDUSTER_POCKET_TEE"
        SET_INT_GLOBAL(262145 + 21190, 1); ---- "ROCKSTAR_LOGO_BLACKED_OUT_TEE"
        SET_INT_GLOBAL(262145 + 21191, 1); ---- "ROCKSTAR_LOGO_WHITE_OUT_TEE"
        SET_INT_GLOBAL(262145 + 25698, 1); ---- "Kifflom Tee"

        ---Moletons
        SET_INT_GLOBAL(262145 + 21154, 1); ---- "BLACK_AMMUNATION_HOODIE"
        SET_INT_GLOBAL(262145 + 21158, 1); ---- "BLACK_HAWK_AND_LITTLE_HODDIE"
        SET_INT_GLOBAL(262145 + 21161, 1); ---- "BLACK_SHREWSBURY_HOODIE"
        SET_INT_GLOBAL(262145 + 21163, 1); ---- "BLACK_WARSTOCK_HOODIE"
        SET_INT_GLOBAL(262145 + 21168, 1); ---- "WHITE_COIL_HOODIE"
        SET_INT_GLOBAL(262145 + 21170, 1); ---- "WHITE_HAWK_AND_LITTLE_HOODIE"
        SET_INT_GLOBAL(262145 + 21174, 1); ---- "WHITE_SHREWSBURY_HOODIE"
        SET_INT_GLOBAL(262145 + 21177, 1); ---- "WHITE_VOM_FEUER_HOODIE"

        ---Camisetas dos ("clubes
        SET_INT_GLOBAL(262145 + 24732, 1); ---- "Maisonette Los Santos T-Shirt"
        SET_INT_GLOBAL(262145 + 24733, 1); ---- "Studio Los Santos T-Shirt"
        SET_INT_GLOBAL(262145 + 24734, 1); ---- "Galaxy T-Shirt"
        SET_INT_GLOBAL(262145 + 24735, 1); ---- "Gefängnis T-Shirt"
        SET_INT_GLOBAL(262145 + 24736, 1); ---- "Omega T-Shirt"
        SET_INT_GLOBAL(262145 + 24737, 1); ---- "Technologie T-Shirt"
        SET_INT_GLOBAL(262145 + 24738, 1); ---- "Paradise T-Shirt"
        SET_INT_GLOBAL(262145 + 24739, 1); ---- "The Palace T-Shirt"
        SET_INT_GLOBAL(262145 + 24740, 1); ---- "Tony's Fun House T-Shirt"

        ---camisas de filme
        SET_INT_GLOBAL(262145 + 11952, 1); ---- "MELTDOWN"
        SET_INT_GLOBAL(262145 + 11953, 1); ---- "VINEWOOD_ZOMBIE"
        SET_INT_GLOBAL(262145 + 11954, 1); ---- "I_MARRIED_MY_DAD"
        SET_INT_GLOBAL(262145 + 11955, 1); ---- "DIE_ALREADY_4"
        SET_INT_GLOBAL(262145 + 11956, 1); ---- "THE_SHOULDER_OF_ORION_II"
        SET_INT_GLOBAL(262145 + 11957, 1); ---- "NELSON_IN_NAPLES"
        SET_INT_GLOBAL(262145 + 11958, 1); ---- "THE_MANY_WIVES_OF_ALFREDO_SMITH"
        SET_INT_GLOBAL(262145 + 11959, 1); ---- "AN_AMERICAN_DIVORCE"
        SET_INT_GLOBAL(262145 + 11960, 1); ---- "THE_LONELIEST_ROBOT"
        SET_INT_GLOBAL(262145 + 11961, 1); ---- "CAPOLAVORO"
        SET_INT_GLOBAL(262145 + 12598, 1); ---- "Vinewood Zombie Shirt"
        SET_INT_GLOBAL(262145 + 12599, 1); ---- "Knife After Dark Shirt"
        SET_INT_GLOBAL(262145 + 12600, 1); ---- "The Simian Shirt"
        SET_INT_GLOBAL(262145 + 12601, 1); ---- "Zombie Liberals In The Midwest Shirt"
        SET_INT_GLOBAL(262145 + 12602, 1); ---- "Twilight Knife Shirt"
        SET_INT_GLOBAL(262145 + 12603, 1); ---- "Butchery and Other Hobbies Shirt"
        SET_INT_GLOBAL(262145 + 12604, 1); ---- "Cheerleader Massacre 3 Shirt"
        SET_INT_GLOBAL(262145 + 12605, 1); ---- "Cannibal ("Clown Shirt"
        SET_INT_GLOBAL(262145 + 12606, 1); ---- "Hot Serial Killer Stepmom Shirt"
        SET_INT_GLOBAL(262145 + 12607, 1); ---- "Splatter And Shot Shirt"
        SET_INT_GLOBAL(262145 + 12608, 1); ---- "Meathook For Mommy Shirt"
        SET_INT_GLOBAL(262145 + 12609, 1); ---- "Psycho Swingers Shirt"
        SET_INT_GLOBAL(262145 + 12610, 1); ---- "Vampires On The Beach Shirt"
        SET_INT_GLOBAL(262145 + 15226, 1); ---- "Meltdown Shirt"

        --- knock offs
        SET_INT_GLOBAL(262145 + 24249, 1); ---- "Fake Perseus T-Shirt"
        SET_INT_GLOBAL(262145 + 24250, 1); ---- "Fake Santo Capra T-Shirt"
        SET_INT_GLOBAL(262145 + 24251, 1); ---- "Fake Dix White T-Shirt"
        SET_INT_GLOBAL(262145 + 24252, 1); ---- "Fake Le Chien Crew T-Shirt"
        SET_INT_GLOBAL(262145 + 24253, 1); ---- "Fake Enema T-Shirt"
        SET_INT_GLOBAL(262145 + 24254, 1); ---- "Fake Dix Gold T-Shirt"
        SET_INT_GLOBAL(262145 + 24255, 1); ---- "Fake Le Chien No2 T-Shirt"
        SET_INT_GLOBAL(262145 + 24256, 1); ---- "Fake Seesanta Nove T-Shirt"
        SET_INT_GLOBAL(262145 + 24257, 1); ---- "Fake Didier Sachs T-Shirt"
        SET_INT_GLOBAL(262145 + 24258, 1); ---- "Fake Vapid T-Shirt"

        ---Camisas de Marcas
        SET_INT_GLOBAL(262145 + 15219, 1); ---- "Accountant Shirt"
        SET_INT_GLOBAL(262145 + 15220, 1); ---- "Bahamamamas Shirt"
        SET_INT_GLOBAL(262145 + 15221, 1); ---- "Drone Shirt"
        SET_INT_GLOBAL(262145 + 15223, 1); ---- "Golf Shirt"
        SET_INT_GLOBAL(262145 + 15224, 1); ---- "Maisonette Shirt"
        SET_INT_GLOBAL(262145 + 15225, 1); ---- "Manopause Shirt"
        SET_INT_GLOBAL(262145 + 15227, 1); ---- "Pacific Bluffs Shirt"
        SET_INT_GLOBAL(262145 + 15228, 1); ---- "Prolaps Shirt"
        SET_INT_GLOBAL(262145 + 15229, 1); ---- "Tennis Shirt"
        SET_INT_GLOBAL(262145 + 15230, 1); ---- "Toe Shirt"
        SET_INT_GLOBAL(262145 + 15231, 1); ---- "Vanilla Unicorn Shirt"
        SET_INT_GLOBAL(262145 + 15232, 1); ---- "Marlowe Shirt"
        SET_INT_GLOBAL(262145 + 15233, 1); ---- "Crest Shirt"
        SET_INT_GLOBAL(262145 + 24233, 1); ---- "Crocs Bar T-Shirt"
        SET_INT_GLOBAL(262145 + 24234, 1); ---- "Base5 T-Shirt"
        SET_INT_GLOBAL(262145 + 24235, 1); ---- "BOBO T-Shirt"
        SET_INT_GLOBAL(262145 + 24236, 1); ---- "Bitch'n'Dog T-Shirt"
        SET_INT_GLOBAL(262145 + 24238, 1); ---- "Vivisection T-Shirt"
        SET_INT_GLOBAL(262145 + 24241, 1); ---- "Vinyl Countdown T-Shirt"
        SET_INT_GLOBAL(262145 + 24243, 1); ---- "Victory Fist T-Shirt"
        SET_INT_GLOBAL(262145 + 24246, 1); ---- "Homie Sharp T-Shirt"
        SET_INT_GLOBAL(262145 + 8302, 1); ---- "Statue of Happiness T-shirt"

        ---chapeus
        SET_INT_GLOBAL(262145 + 12588, 1); ---- "Magnetics Script Hat"
        SET_INT_GLOBAL(262145 + 12589, 1); ---- "Magnetics Block Hat"
        SET_INT_GLOBAL(262145 + 12590, 1); ---- "Los Santos Hat"
        SET_INT_GLOBAL(262145 + 12591, 1); ---- "Boars Hat"
        SET_INT_GLOBAL(262145 + 12592, 1); ---- "Benny's Hat"
        SET_INT_GLOBAL(262145 + 12593, 1); ---- "Westside Hat"
        SET_INT_GLOBAL(262145 + 12594, 1); ---- "Eastside Hat"
        SET_INT_GLOBAL(262145 + 12595, 1); ---- "Strawberry Hat"
        SET_INT_GLOBAL(262145 + 12596, 1); ---- "S.A. Hat"
        SET_INT_GLOBAL(262145 + 12597, 1); ---- "Davis Hat"

        ---vestuario de natal
        SET_INT_GLOBAL(262145 + 12708, 1); ---- Festive masks  	(2015)
        SET_INT_GLOBAL(262145 + 12709, 1); ---- Festive Pajamas	(2015)
        SET_INT_GLOBAL(262145 + 19301, 1); ---- "christmas2016_("clothing"
        SET_INT_GLOBAL(262145 + 23084, 1); ---- "christmas2017_("clothing"

        ---Camisetas / Jaquetas / suéteres /
        SET_INT_GLOBAL(262145 + 30197, 1); ---- Panther varsity jacket
        SET_INT_GLOBAL(262145 + 30201, 1); ---- Gussét frog Tee
        SET_INT_GLOBAL(262145 + 30202, 1); ---- Warped still slipping tee
        SET_INT_GLOBAL(262145 + 30203, 1); ---- Yellow Still slipping tee
        SET_INT_GLOBAL(262145 + 30204, 1); ---- Black Rockstar  tee
        SET_INT_GLOBAL(262145 + 30205, 1); ---- Black exsorbeo 720 logo tee
        SET_INT_GLOBAL(262145 + 30206, 1); ---- Manor PRBG tee
        SET_INT_GLOBAL(262145 + 30207, 1); ---- Manor Tie-dye tee
        SET_INT_GLOBAL(262145 + 30208, 1); ---- Open wheel sponsor tee
        SET_INT_GLOBAL(262145 + 30209, 1); ---- Rockstar yellow pattern tee
        SET_INT_GLOBAL(262145 + 30210, 1); ---- Rockstar gray pattern tee
        SET_INT_GLOBAL(262145 + 30211, 1); ---- Rockstar rolling tee
        SET_INT_GLOBAL(262145 + 30212, 1); ---- Santo capra patterns sweater
        SET_INT_GLOBAL(262145 + 30213, 1); ---- Rockstar studio colors sweater
        SET_INT_GLOBAL(262145 + 30215, 1); ---- Bigness tie-dye sweater
        SET_INT_GLOBAL(262145 + 30216, 1); ---- Bigness faces sweater
        SET_INT_GLOBAL(262145 + 31175, 1); ---- Black Banshee Tee
        SET_INT_GLOBAL(262145 + 31176, 1); ---- Blue Banshee Tee
        SET_INT_GLOBAL(262145 + 31177, 1); ---- Banshee Hoodie
        SET_INT_GLOBAL(262145 + 31178, 1); ---- LS Customs Tee
        SET_INT_GLOBAL(262145 + 31179, 1); ---- LS Customs Coveralls
        SET_INT_GLOBAL(262145 + 31180, 1); ---- LS Customs Tour Jacket
        SET_INT_GLOBAL(262145 + 31181, 1); ---- LS Customs Varsity
        SET_INT_GLOBAL(262145 + 31182, 1); ---- Sprunk Varsity
        SET_INT_GLOBAL(262145 + 31183, 1); ---- eCola Varsity
        SET_INT_GLOBAL(262145 + 31191, 1); ---- Rockstar Games Typeface Tee
        SET_INT_GLOBAL(262145 + 31192, 1); ---- Wasted! Tee
        SET_INT_GLOBAL(262145 + 31193, 1); ---- Baseball Bat Tee
        SET_INT_GLOBAL(262145 + 31194, 1); ---- Knuckleduster Tee
        SET_INT_GLOBAL(262145 + 31195, 1); ---- Rampage Tee
        SET_INT_GLOBAL(262145 + 31196, 1); ---- Penitentiary Coveralls
        SET_INT_GLOBAL(262145 + 31197, 1); ---- White Born x Raised Tee
        SET_INT_GLOBAL(262145 + 32817, 1); ---- Pacific Standard Varsity
        SET_INT_GLOBAL(262145 + 32818, 1); ---- Pacific Standard Sweater
        SET_INT_GLOBAL(262145 + 32819, 1); ---- ("Clifford Varsity
        SET_INT_GLOBAL(262145 + 32820, 1); ---- ("Clifford Hoodie
        SET_INT_GLOBAL(262145 + 32821, 1); ---- The Diamond Casino Varsity
        SET_INT_GLOBAL(262145 + 32822, 1); ---- The Diamond Casino Strike Vest (body armor)
        SET_INT_GLOBAL(262145 + 32824, 1); ---- Sinsimito Cuban Shirt
        SET_INT_GLOBAL(262145 + 32840, 1); ---- Manor Geo Hoodie
        SET_INT_GLOBAL(262145 + 32841, 1); ---- Pumpkin Hoodie
        SET_INT_GLOBAL(262145 + 32842, 1); ---- LS Smoking Jacket
        SET_INT_GLOBAL(262145 + 32843, 1); ---- Hand Drawn Biker Bomber
        SET_INT_GLOBAL(262145 + 32844, 1); ---- Have You Seen me? Sweater
        SET_INT_GLOBAL(262145 + 32845, 1); ---- Still Slipping Tie Dye Tee

        ---Calção/Calças

        SET_INT_GLOBAL(262145 + 30217, 1); ---- Broker prolaps basketball shorts
        SET_INT_GLOBAL(262145 + 30218, 1); ---- Panic prolaps basketball shorts
        SET_INT_GLOBAL(262145 + 30219, 1); ---- Exorbeo 720 Sports shorts
        SET_INT_GLOBAL(262145 + 30220, 1); ---- Bigness tie-dye sports pants
        SET_INT_GLOBAL(262145 + 32846, 1); ---- Manor Geo Track Pants
        SET_INT_GLOBAL(262145 + 32847, 1); ---- Apricot Persues Track Pants

        ---Caps/chapeus/Bonés/fones
        SET_INT_GLOBAL(262145 + 30221, 1); ---- Enus yeti cap 			(forward,backard)
        SET_INT_GLOBAL(262145 + 30222, 1); ---- 720 cap				(forward,backard)
        SET_INT_GLOBAL(262145 + 30223, 1); ---- EXsorbeo 720 cap			(forward,backard)
        SET_INT_GLOBAL(262145 + 30224, 1); ---- Güffy Double Logo Forwards Cap	(forward,backard)
        SET_INT_GLOBAL(262145 + 30225, 1); ---- Rockstar cap				(forward,backard)
        SET_INT_GLOBAL(262145 + 31184, 1); ---- Sprunk Forwards Cap
        SET_INT_GLOBAL(262145 + 31185, 1); ---- eCola Forwards Cap
        SET_INT_GLOBAL(262145 + 32823, 1); ---- Strickler Hat
        SET_INT_GLOBAL(262145 + 32827, 1); ---- Manor Geo Forwards Cap
        SET_INT_GLOBAL(262145 + 32828, 1); ---- Apricot Persues Forwards Cap
        SET_INT_GLOBAL(262145 + 32829, 1); ---- Still Slipping Tie-ye Forwards Cap
        SET_INT_GLOBAL(262145 + 32898, 1); ---- Grey Yeti Flat Cap
        SET_INT_GLOBAL(262145 + 32899, 1); ---- Woodland Yeti Flat Cap
        SET_INT_GLOBAL(262145 + 32900, 1); ---- Green FB Flat Cap
        SET_INT_GLOBAL(262145 + 32901, 1); ---- Blue FB Flat Cap
        SET_INT_GLOBAL(262145 + 32902, 1); ---- Grey Lezard Flat Cap
        SET_INT_GLOBAL(262145 + 32903, 1); ---- Green Lezard Flat Cap
        SET_INT_GLOBAL(262145 + 32904, 1); ---- Light Plaid Lezard Flat Cap
        SET_INT_GLOBAL(262145 + 32905, 1); ---- Dark Plaid Lezard Flat Cap
        SET_INT_GLOBAL(262145 + 32906, 1); ---- White Striped Lezard Flat Cap
        SET_INT_GLOBAL(262145 + 32907, 1); ---- Red Striped Lezard Flat Cap
        SET_INT_GLOBAL(262145 + 32908, 1); ---- Brown Crevis Flat Cap
        SET_INT_GLOBAL(262145 + 32909, 1); ---- Grey Crevis Flat Cap
        SET_INT_GLOBAL(262145 + 32910, 1); ---- Black Broker Flat Cap
        SET_INT_GLOBAL(262145 + 32911, 1); ---- Burgundy Broker Flat Cap
        SET_INT_GLOBAL(262145 + 33559, 1); ---- Lemon Festive Beer Hat
        SET_INT_GLOBAL(262145 + 33560, 1); ---- Green Festive Beer Hat
        SET_INT_GLOBAL(262145 + 33561, 1); ---- Red Snowflake Beer Hat
        SET_INT_GLOBAL(262145 + 33562, 1); ---- Blue Snowflake Beer Hat
        SET_INT_GLOBAL(262145 + 33563, 1); ---- Red Holly Beer Hat
        SET_INT_GLOBAL(262145 + 33564, 1); ---- Pivswasser Festive Beer Hat
        SET_INT_GLOBAL(262145 + 33565, 1); ---- Blarneys Festive Beer Hat
        SET_INT_GLOBAL(262145 + 33566, 1); ---- Red Reindeer Beer Hat
        SET_INT_GLOBAL(262145 + 33567, 1); ---- Red Reindeer Beer Hat v2
        SET_INT_GLOBAL(262145 + 32839, 1); ---- Gold Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32912, 1); ---- White Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32913, 1); ---- Yellow Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32914, 1); ---- Salmon Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32915, 1); ---- Orange Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32916, 1); ---- Purple Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32917, 1); ---- Pink Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32918, 1); ---- Turquiouse Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32919, 1); ---- Blue Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32920, 1); ---- Black Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32921, 1); ---- Grey Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32922, 1); ---- Teal Beat Off Earphones
        SET_INT_GLOBAL(262145 + 32923, 1); ---- Red Beat Off Earphones
        SET_INT_GLOBAL(262145 + 21153, 1); ---- BLACK_AMMUNATION_CAP
        SET_INT_GLOBAL(262145 + 21156, 1); ---- BLACK_COIL_CAP
        SET_INT_GLOBAL(262145 + 21162, 1); ---- BLACK_VOM_FEUER_CAP
        SET_INT_GLOBAL(262145 + 21165, 1); ---- RED_HAWK_AND_LITTLE_CAP
        SET_INT_GLOBAL(262145 + 21166, 1); ---- WARSTOCK_CAP
        SET_INT_GLOBAL(262145 + 21173, 1); ---- WHITE_SHREWSBURY_CAP
        SET_INT_GLOBAL(262145 + 21176, 1); ---- WHITE_VOM_FEUER_CAP
        SET_INT_GLOBAL(262145 + 21178, 1); ---- WINE_COIL_CAP

        ---Pulseiras

        SET_INT_GLOBAL(262145 + 30226, 1); ---- Blue bangles
        SET_INT_GLOBAL(262145 + 30227, 1); ---- Red bangles
        SET_INT_GLOBAL(262145 + 30228, 1); ---- Pink bangles
        SET_INT_GLOBAL(262145 + 30229, 1); ---- Yellow bangles
        SET_INT_GLOBAL(262145 + 30230, 1); ---- Orange bangles
        SET_INT_GLOBAL(262145 + 30231, 1); ---- Green bangles
        SET_INT_GLOBAL(262145 + 30232, 1); ---- Red and blue bangles
        SET_INT_GLOBAL(262145 + 30233, 1); ---- Yellow and orange bangles
        SET_INT_GLOBAL(262145 + 30234, 1); ---- Green and pink bangles
        SET_INT_GLOBAL(262145 + 30235, 1); ---- Rainbow bangles
        SET_INT_GLOBAL(262145 + 30236, 1); ---- Sunset bangles
        SET_INT_GLOBAL(262145 + 30237, 1); ---- Tropical bangles

        ---Óculos
        SET_INT_GLOBAL(262145 + 30238, 1); ---- Blue and pink glow shades
        SET_INT_GLOBAL(262145 + 30239, 1); ---- Red glow shades
        SET_INT_GLOBAL(262145 + 30240, 1); ---- Orange glow shades
        SET_INT_GLOBAL(262145 + 30241, 1); ---- Yellow glow shades
        SET_INT_GLOBAL(262145 + 30242, 1); ---- Green glow shades
        SET_INT_GLOBAL(262145 + 30243, 1); ---- Blue glow shades
        SET_INT_GLOBAL(262145 + 30244, 1); ---- Pink glow shades
        SET_INT_GLOBAL(262145 + 30245, 1); ---- Blue and magenta glow shades
        SET_INT_GLOBAL(262145 + 30246, 1); ---- Purple and yellow glow shades
        SET_INT_GLOBAL(262145 + 30247, 1); ---- Blue and yellow glow shades
        SET_INT_GLOBAL(262145 + 30248, 1); ---- Pink and yellow glow shades
        SET_INT_GLOBAL(262145 + 30249, 1); ---- Red and yellow glow shades
        SET_INT_GLOBAL(262145 + 30854, 1); ---- Midnight tint oversized shades
        SET_INT_GLOBAL(262145 + 30855, 1); ---- Sunset tint oversized shades
        SET_INT_GLOBAL(262145 + 30856, 1); ---- Black tint oversized shades
        SET_INT_GLOBAL(262145 + 30857, 1); ---- Blue tint oversized shades
        SET_INT_GLOBAL(262145 + 30858, 1); ---- Gold tint oversized shades
        SET_INT_GLOBAL(262145 + 30859, 1); ---- Green tint oversized shades
        SET_INT_GLOBAL(262145 + 30860, 1); ---- Orange tint oversized shades
        SET_INT_GLOBAL(262145 + 30861, 1); ---- Red tint oversized shades
        SET_INT_GLOBAL(262145 + 30862, 1); ---- Pink tint oversized shades
        SET_INT_GLOBAL(262145 + 30863, 1); ---- Yellow tint oversized shades
        SET_INT_GLOBAL(262145 + 30864, 1); ---- Lemon tint oversized shades
        SET_INT_GLOBAL(262145 + 30865, 1); ---- Gold rimmed oversized shades
        SET_INT_GLOBAL(262145 + 30866, 1); ---- White checked round shades
        SET_INT_GLOBAL(262145 + 30867, 1); ---- Pink checked round shades
        SET_INT_GLOBAL(262145 + 30868, 1); ---- Yellow checked round shades
        SET_INT_GLOBAL(262145 + 30869, 1); ---- Red checked round shades
        SET_INT_GLOBAL(262145 + 30870, 1); ---- White round shades
        SET_INT_GLOBAL(262145 + 30871, 1); ---- Black round shades
        SET_INT_GLOBAL(262145 + 30872, 1); ---- Pink tinted round shades
        SET_INT_GLOBAL(262145 + 30873, 1); ---- Blue tinted round shades
        SET_INT_GLOBAL(262145 + 30874, 1); ---- Green checked round shades
        SET_INT_GLOBAL(262145 + 30875, 1); ---- Blue checked round shades
        SET_INT_GLOBAL(262145 + 30876, 1); ---- Orange checked round shades
        SET_INT_GLOBAL(262145 + 30877, 1); ---- Green tinted round shades
        SET_INT_GLOBAL(262145 + 30878, 1); ---- Brown square shades
        SET_INT_GLOBAL(262145 + 30879, 1); ---- Yellow square shades
        SET_INT_GLOBAL(262145 + 30880, 1); ---- Black square shades
        SET_INT_GLOBAL(262145 + 30881, 1); ---- Tortoiseshell square shades
        SET_INT_GLOBAL(262145 + 30882, 1); ---- Green square shades
        SET_INT_GLOBAL(262145 + 30883, 1); ---- Red square shades
        SET_INT_GLOBAL(262145 + 30884, 1); ---- Pink tinted square shades
        SET_INT_GLOBAL(262145 + 30885, 1); ---- Blue tinted square shades
        SET_INT_GLOBAL(262145 + 30886, 1); ---- White square shades
        SET_INT_GLOBAL(262145 + 30887, 1); ---- Pink square shades
        SET_INT_GLOBAL(262145 + 30888, 1); ---- All white square shades
        SET_INT_GLOBAL(262145 + 30889, 1); ---- Mono square shades

        ---Colares
        SET_INT_GLOBAL(262145 + 30250, 1); ---- Blue glow necklace
        SET_INT_GLOBAL(262145 + 30251, 1); ---- Red glow necklace
        SET_INT_GLOBAL(262145 + 30252, 1); ---- Pink glow necklace
        SET_INT_GLOBAL(262145 + 30253, 1); ---- Yellow glow necklace
        SET_INT_GLOBAL(262145 + 30254, 1); ---- Orange glow necklace
        SET_INT_GLOBAL(262145 + 30255, 1); ---- Green glow necklace
        SET_INT_GLOBAL(262145 + 30256, 1); ---- Festival glow necklace
        SET_INT_GLOBAL(262145 + 30257, 1); ---- Carnival glow necklace
        SET_INT_GLOBAL(262145 + 30258, 1); ---- Tropical glow necklace
        SET_INT_GLOBAL(262145 + 30259, 1); ---- Hot glow necklace
        SET_INT_GLOBAL(262145 + 30260, 1); ---- Neon glow necklace
        SET_INT_GLOBAL(262145 + 30261, 1); ---- Party glow necklace
        SET_INT_GLOBAL(262145 + 30262, 1); ---- Sunset glow necklace
        SET_INT_GLOBAL(262145 + 30263, 1); ---- Radiant glow necklace
        SET_INT_GLOBAL(262145 + 30264, 1); ---- Sunrise glow necklace
        SET_INT_GLOBAL(262145 + 30265, 1); ---- Session glow necklace

        ---Máscaras em Geral
        SET_INT_GLOBAL(262145 + 30270, 1); ---- Green calavera mask
        SET_INT_GLOBAL(262145 + 30271, 1); ---- Navy calavera mask
        SET_INT_GLOBAL(262145 + 30272, 1); ---- Cherry calavera mask
        SET_INT_GLOBAL(262145 + 30273, 1); ---- Orange calavera mask
        SET_INT_GLOBAL(262145 + 30274, 1); ---- Purple calavera mask
        SET_INT_GLOBAL(262145 + 30275, 1); ---- Dark blue calavera mask
        SET_INT_GLOBAL(262145 + 30276, 1); ---- Lavender calavera mask
        SET_INT_GLOBAL(262145 + 30277, 1); ---- Yellow calavera mask
        SET_INT_GLOBAL(262145 + 30278, 1); ---- Pink calavera mask
        SET_INT_GLOBAL(262145 + 30279, 1); ---- Neon stich emissive mask
        SET_INT_GLOBAL(262145 + 30280, 1); ---- Vibrant stich emissive mask
        SET_INT_GLOBAL(262145 + 30281, 1); ---- Pink stich emissive mask
        SET_INT_GLOBAL(262145 + 30282, 1); ---- Blue stich emissive mask
        SET_INT_GLOBAL(262145 + 30283, 1); ---- Neon skull emissive mask
        SET_INT_GLOBAL(262145 + 30284, 1); ---- Vibrant skull emissive mask
        SET_INT_GLOBAL(262145 + 30285, 1); ---- Pink skull emissive mask
        SET_INT_GLOBAL(262145 + 30286, 1); ---- Orange skull emissive mask
        SET_INT_GLOBAL(262145 + 30287, 1); ---- Dark x-ray emissive mask
        SET_INT_GLOBAL(262145 + 30288, 1); ---- Bright x-ray emissive mask
        SET_INT_GLOBAL(262145 + 30289, 1); ---- Purple x-ray emissive mask
        SET_INT_GLOBAL(262145 + 32832, 1); ---- Grimy Stitched
        SET_INT_GLOBAL(262145 + 32833, 1); ---- Pale Stitched
        SET_INT_GLOBAL(262145 + 32834, 1); ---- Grey Cracked Puppet
        SET_INT_GLOBAL(262145 + 32835, 1); ---- Blushed Cracked Puppet
        SET_INT_GLOBAL(262145 + 32836, 1); ---- Green Emissive Lady Liberty
        SET_INT_GLOBAL(262145 + 32837, 1); ---- President
        SET_INT_GLOBAL(262145 + 32852, 1); ---- Green Vintage Frank
        SET_INT_GLOBAL(262145 + 32853, 1); ---- Brown Vintage Frank
        SET_INT_GLOBAL(262145 + 32854, 1); ---- Grey Vintage Frank
        SET_INT_GLOBAL(262145 + 32855, 1); ---- Pale Vintage Mummy
        SET_INT_GLOBAL(262145 + 32856, 1); ---- Green Vintage Mummy
        SET_INT_GLOBAL(262145 + 32857, 1); ---- Weathered Vintage Mummy
        SET_INT_GLOBAL(262145 + 32858, 1); ---- White Vintage Mummy
        SET_INT_GLOBAL(262145 + 32859, 1); ---- Dark Green Vintage Vampire
        SET_INT_GLOBAL(262145 + 32860, 1); ---- Light Green Vintage Vampire
        SET_INT_GLOBAL(262145 + 32864, 1); ---- Conquest
        SET_INT_GLOBAL(262145 + 32865, 1); ---- Death
        SET_INT_GLOBAL(262145 + 32866, 1); ---- Famine
        SET_INT_GLOBAL(262145 + 32867, 1); ---- War
        SET_INT_GLOBAL(262145 + 32868, 1); ---- Black Tech Demon
        SET_INT_GLOBAL(262145 + 32869, 1); ---- Grey Tech Demon
        SET_INT_GLOBAL(262145 + 32870, 1); ---- White Tech Demon
        SET_INT_GLOBAL(262145 + 32871, 1); ---- Green Tech Demon
        SET_INT_GLOBAL(262145 + 32872, 1); ---- Orange Tech Demon
        SET_INT_GLOBAL(262145 + 32873, 1); ---- Purple Tech Demon
        SET_INT_GLOBAL(262145 + 32874, 1); ---- Pink Tech Demon
        SET_INT_GLOBAL(262145 + 32875, 1); ---- Red Detail Tech Demon
        SET_INT_GLOBAL(262145 + 32876, 1); ---- Blue Detail Tech Demon
        SET_INT_GLOBAL(262145 + 32877, 1); ---- Yellow Detail Tech Demon
        SET_INT_GLOBAL(262145 + 32878, 1); ---- Green Detail Tech Demon
        SET_INT_GLOBAL(262145 + 32879, 1); ---- Pink Detail Tech Demon
        SET_INT_GLOBAL(262145 + 32880, 1); ---- Orange And Grey Tech Demon
        SET_INT_GLOBAL(262145 + 32881, 1); ---- Red Tech Demon
        SET_INT_GLOBAL(262145 + 32882, 1); ---- Camo Tech Demon
        SET_INT_GLOBAL(262145 + 32883, 1); ---- Aqua Camo Tech Demon
        SET_INT_GLOBAL(262145 + 32884, 1); ---- Brown Digital Tech Demon
        SET_INT_GLOBAL(262145 + 32885, 1); ---- Gold Tech Demon
        SET_INT_GLOBAL(262145 + 32886, 1); ---- Orange and Cream Tech Demon
        SET_INT_GLOBAL(262145 + 32887, 1); ---- Green and Yellow Tech Demon
        SET_INT_GLOBAL(262145 + 32888, 1); ---- Pink Floral Tech Demon
        SET_INT_GLOBAL(262145 + 32889, 1); ---- Black and Green Tech Demon
        SET_INT_GLOBAL(262145 + 32890, 1); ---- hite and Red Tech Demon
        SET_INT_GLOBAL(262145 + 32891, 1); ---- Carbon Tech Demon
        SET_INT_GLOBAL(262145 + 32892, 1); ---- Carbon Teal Tech Demon
        SET_INT_GLOBAL(262145 + 32893, 1); ---- Black and White Tech Demon
        SET_INT_GLOBAL(262145 + 32894, 1); ---- Painted Tiger
        SET_INT_GLOBAL(262145 + 32895, 1); ---- Grey Painted Tiger
        SET_INT_GLOBAL(262145 + 32896, 1); ---- Gold Painted Tiger
        SET_INT_GLOBAL(262145 + 32897, 1); ---- Ornate Painted Tiger
        SET_INT_GLOBAL(262145 + 27518, 1) --- Ace Mask
        SET_INT_GLOBAL(262145 + 27519, 1) ---Ace Mask
        SET_INT_GLOBAL(262145 + 27520, 1) ---Ace Mask	S
        SET_INT_GLOBAL(262145 + 27521, 1) ---Ace Mask
        SET_INT_GLOBAL(262145 + 31842, 1); ---- Orange Goldfish Mask
        SET_INT_GLOBAL(262145 + 31843, 1); ---- Purple Goldfish Mask
        SET_INT_GLOBAL(262145 + 31844, 1); ---- Bronze Goldfish Mask
        SET_INT_GLOBAL(262145 + 31845, 1); ---- ("Clownfish Mask
        SET_INT_GLOBAL(262145 + 31846, 1); ---- Juvenile Gull Mask
        SET_INT_GLOBAL(262145 + 31847, 1); ---- Sooty Gull Mask
        SET_INT_GLOBAL(262145 + 31848, 1); ---- Black-headed Gull Mask
        SET_INT_GLOBAL(262145 + 31849, 1); ---- Herring Gull Mask
        SET_INT_GLOBAL(262145 + 31850, 1); ---- Brown Sea Lion Mask
        SET_INT_GLOBAL(262145 + 31851, 1); ---- Dark Sea Lion Mask
        SET_INT_GLOBAL(262145 + 31852, 1); ---- Spotted Sea Lion Mask
        SET_INT_GLOBAL(262145 + 31853, 1); ---- Gray Sea Lion Mask
        SET_INT_GLOBAL(262145 + 24247, 1); ---- Please Stop Me Mask

        ---camisetas de DJ/DJ pooh
        SET_INT_GLOBAL(262145 + 30899, 1); ---- Palms Trax LS Tee
        SET_INT_GLOBAL(262145 + 30900, 1); ---- Moodymann Whatupdoe Tee
        SET_INT_GLOBAL(262145 + 30901, 1); ---- Moodymann Big D Tee
        SET_INT_GLOBAL(262145 + 30902, 1); ---- Keinemusik Cayo Perico Tee
        SET_INT_GLOBAL(262145 + 30903, 1); ---- Still Slipping Blarneys Tee
        SET_INT_GLOBAL(262145 + 30904, 1); ---- Still Slipping Friend Tee
        SET_INT_GLOBAL(262145 + 31186, 1); ---- eCola Bodysuit
        SET_INT_GLOBAL(262145 + 31187, 1); ---- Sprunk Bodysuit
        SET_INT_GLOBAL(262145 + 31854, 1); ---- Orange DJ Pohh Tee
        SET_INT_GLOBAL(262145 + 31855, 1); ---- White WCC DJ Pooh Tee
        SET_INT_GLOBAL(262145 + 31856, 1); ---- Blue WCC DJ Pooh Tee
        SET_INT_GLOBAL(262145 + 24946, 1); ---- "White Solomun Logo Tee"
        SET_INT_GLOBAL(262145 + 24947, 1); ---- "White Solomun Pocket Logo Tee"
        SET_INT_GLOBAL(262145 + 24948, 1); ---- "Black And Yellow Solomun Tee"
        SET_INT_GLOBAL(262145 + 24949, 1); ---- "Black Solomun White Logo Tee"
        SET_INT_GLOBAL(262145 + 24950, 1); ---- "Black And White Solomun Tee"
        SET_INT_GLOBAL(262145 + 24951, 1); ---- "Black Solomun Pocket Logo Tee"
        SET_INT_GLOBAL(262145 + 24952, 1); ---- "Dixon Box logo Tee"
        SET_INT_GLOBAL(262145 + 24953, 1); ---- "Dixon Pocket logo Tee"
        SET_INT_GLOBAL(262145 + 24954, 1); ---- "White Dixon Wilderness Tee"
        SET_INT_GLOBAL(262145 + 24955, 1); ---- "Dixon Green Logo Tee"
        SET_INT_GLOBAL(262145 + 24956, 1); ---- "Dixon Glitch Logo Tee"
        SET_INT_GLOBAL(262145 + 24957, 1); ---- "Black Dixon Repeated Logo Tee"
        SET_INT_GLOBAL(262145 + 24958, 1); ---- "Tale Of Us Box Logo Tee"
        SET_INT_GLOBAL(262145 + 24959, 1); ---- "White Tale Of Us Logo Tee"
        SET_INT_GLOBAL(262145 + 24960, 1); ---- "White Tale Of Us Emb. Tee"
        SET_INT_GLOBAL(262145 + 24961, 1); ---- "Black Tale Of Us 0Logo Tee"
        SET_INT_GLOBAL(262145 + 24962, 1); ---- "Tale Of Us Stacked Logo Tee"
        SET_INT_GLOBAL(262145 + 24963, 1); ---- "Tale Of Us Afterlight Tee"
        SET_INT_GLOBAL(262145 + 24964, 1); ---- "White The Black Madonna Tee"
        SET_INT_GLOBAL(262145 + 24965, 1); ---- "Black The Black Madonna Tee"
        SET_INT_GLOBAL(262145 + 24966, 1); ---- "White The Black Madonna Emb. Tee"
        SET_INT_GLOBAL(262145 + 24967, 1); ---- "White The Black Madonna Init. Tee"
        SET_INT_GLOBAL(262145 + 24968, 1); ---- "Black The Black Madonna Init. Tee"
        SET_INT_GLOBAL(262145 + 24969, 1); ---- "The Black Madonna We Believe Tee"

        ---Paraquedas
        SET_INT_GLOBAL(262145 + 31188, 1); ---- Sprunk Parachute Bag
        SET_INT_GLOBAL(262145 + 31189, 1); ---- eCola Parachute Bag
        SET_INT_GLOBAL(262145 + 31190, 1); ---- Halloween Parachute Bag
        SET_INT_GLOBAL(262145 + 24248, 1); ---- Highflyer Parachute Bag
    end)

----Desbloqueador Separado

local UNLOCK_PERSON = menu.list(UNLOCK_ALL, "Personagem", {},
    "Coisas geralmente usadas no personagem para desempenho pessoal!", function()

end)

menu.action(UNLOCK_PERSON, "Carregamento Rápido", {}, "Carrega suas armas mais rapido", function()
    SET_INT_GLOBAL(1574589, 1) ---reload
    SET_INT_GLOBAL(1575015, 1)
    SET_INT_GLOBAL(1574589, 0)
end)

menu.action(UNLOCK_PERSON, "Corridinha", {}, "Troque de sessão para funcionar", function()
    STAT_SET_INT("CHAR_ABILITY_1_UNLCK", -1) --- Corridinha
    STAT_SET_INT("CHAR_ABILITY_2_UNLCK", -1)
    STAT_SET_INT("CHAR_ABILITY_3_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_ABILITY_1_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_ABILITY_2_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_ABILITY_3_UNLCK", -1)
end)

menu.action(UNLOCK_PERSON, "Desbloquear 30C4", {}, "30c4  10 minas", function()
    STAT_SET_INT("SR_HIGHSCORE_1", 690) ---30c4 10minas
    STAT_SET_INT("SR_HIGHSCORE_2", 1860)
    STAT_SET_INT("SR_HIGHSCORE_3", 2690)
    STAT_SET_INT("SR_HIGHSCORE_4", 2660)
    STAT_SET_INT("SR_HIGHSCORE_5", 450)
    STAT_SET_INT("SR_HIGHSCORE_6", 269)
    STAT_SET_INT("SR_WEAPON_BIT_SET", -1)
    STAT_SET_BOOL("SR_TIER_1_REWARD", true)
    STAT_SET_BOOL("SR_TIER_3_REWARD", true)
    STAT_SET_BOOL("SR_INCREASE_THROW_CAP", true)
end)

menu.action(UNLOCK_PERSON, "Estampas Ammunation", {}, "Desbloqueia todas estampas presentes na loja de Armas",
    function()
        STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600)
        STAT_SET_INT("CMBTPISTOL_ENEMY_KILLS", 600)
        STAT_SET_INT("PISTOL50_ENEMY_KILLS", 600)
        STAT_SET_INT("APPISTOL_ENEMY_KILLS", 600)
        STAT_SET_INT("MICROSMG_ENEMY_KILLS", 600)
        STAT_SET_INT("SMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTSMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("CRBNRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("ADVRIFLE_ENEMY_KILLS", 600)
        STAT_SET_INT("MG_ENEMY_KILLS", 600)
        STAT_SET_INT("CMBTMG_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTMG_ENEMY_KILLS", 600)
        STAT_SET_INT("PUMP_ENEMY_KILLS", 600)
        STAT_SET_INT("SAWNOFF_ENEMY_KILLS", 600)
        STAT_SET_INT("BULLPUP_ENEMY_KILLS", 600)
        STAT_SET_INT("ASLTSHTGN_ENEMY_KILLS", 600)
        STAT_SET_INT("SNIPERRFL_ENEMY_KILLS", 600)
        STAT_SET_INT("HVYSNIPER_ENEMY_KILLS", 600)
        STAT_SET_INT("GRNLAUNCH_ENEMY_KILLS", 600)
        STAT_SET_INT("RPG_ENEMY_KILLS", 600)
        STAT_SET_INT("MINIGUNS_ENEMY_KILLS", 600)
        STAT_SET_INT("GRENADE_ENEMY_KILLS", 600)
        STAT_SET_INT("SMKGRENADE_ENEMY_KILLS", 600)
        STAT_SET_INT("STKYBMB_ENEMY_KILLS", 600)
        STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 600)
    end)

menu.action(UNLOCK_PERSON, "Estatisticas", {}, "Resistência/Força/Tiro/Furtividade/Direção/Pilotagem", function()
    STAT_SET_INT("SCRIPT_INCREASE_STAM", 100) ---Estatisticas
    STAT_SET_INT("SCRIPT_INCREASE_SHO", 100)
    STAT_SET_INT("SCRIPT_INCREASE_STRN", 100)
    STAT_SET_INT("SCRIPT_INCREASE_STL", 100)
    STAT_SET_INT("SCRIPT_INCREASE_FLY", 100)
    STAT_SET_INT("SCRIPT_INCREASE_DRIV", 100)
    STAT_SET_INT("SCRIPT_INCREASE_LUNG", 100)
end)

menu.action(UNLOCK_PERSON, "Lanches e coletes", {}, "Lanches e Coletes no maximo que o inventario suporta", function()
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30) -- Lanches e coletes
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
    STAT_SET_INT("CIGARETTES_BOUGHT", 20)
    STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
    STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)
end)

menu.action(UNLOCK_PERSON, "Limpar Denúncias", {}, "", function() ---Botão teste
    STAT_SET_INT("MPPLY_REPORT_STRENGTH", 0)
    STAT_SET_INT("MPPLY_COMMEND_STRENGTH", 0)
    STAT_SET_INT("MPPLY_FRIENDLY", 0)
    STAT_SET_INT("MPPLY_HELPFUL", 0)
    STAT_SET_INT("MPPLY_GRIEFING", 0)
    STAT_SET_INT("MPPLY_VC_ANNOYINGME", 0)
    STAT_SET_INT("MPPLY_VC_HATE")
    STAT_SET_INT("MPPLY_TC_ANNOYINGME", 0)
    STAT_SET_INT("MPPLY_TC_HATE", 0)
    STAT_SET_INT("MPPLY_OFFENSIVE_LANGUAGE", 0)
    STAT_SET_INT("MPPLY_OFFENSIVE_TAGPLATE", 0)
    STAT_SET_INT("MPPLY_OFFENSIVE_UGC", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_NAME", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_MOTTO", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_STATUS", 0)
    STAT_SET_INT("MPPLY_BAD_CREW_EMBLEM", 0)
    STAT_SET_INT("MPPLY_EXPLOITS", 0)
    STAT_SET_INT("MPPLY_BECAME_BADSPORT_NUM", 0)
    STAT_SET_INT("MPPLY_DESTROYED_PVEHICLES", 0)
    STAT_SET_INT("MPPLY_BECAME_CHEATER_NUM", 0)
    STAT_SET_INT("MPPLY_BADSPORT_MESSAGE", 0)
    STAT_SET_INT("MPPLY_GAME_EXPLOITS", 0)
    STAT_SET_INT("MPPLY_PLAYER_MENTAL_STATE", 0)
    STAT_SET_INT("MPPLY_PLAYERMADE_TITLE", 0)
    STAT_SET_INT("MPPLY_PLAYERMADE_DESC", 0)
    STAT_SET_INT("MPPLY_OVERALL_BADSPORT", 0)
    STAT_SET_INT("MPPLY_OVERALL_CHEAT", 0)
end)

menu.action(UNLOCK_PERSON, "Troca de Sexo", {},
    "Para funcionar Você deve ir no menu de interação e alternar aparencia do personagem", function()
    STAT_SET_BOOL("ALLOW_GENDER_CHANGE", 52) ---troca de sexo
end)

menu.action(UNLOCK_PERSON, "Lanches e coletes", {},
    "Lanches e Coletes no maximo que o inventario suporta removido itens desnecessariso", function()
    STAT_SET_INT("NO_BOUGHT_YUM_SNACKS", 30) ---Lanches e coletes
    STAT_SET_INT("NO_BOUGHT_HEALTH_SNACKS", 15)
    STAT_SET_INT("NO_BOUGHT_EPIC_SNACKS", 5)
    STAT_SET_INT("NUMBER_OF_ORANGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_BOURGE_BOUGHT", 10)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 5)
    STAT_SET_INT("NUMBER_OF_SPRUNK_BOUGHT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_1_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_2_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_3_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_4_COUNT", 10)
    STAT_SET_INT("MP_CHAR_ARMOUR_5_COUNT", 10)
    STAT_SET_INT("BREATHING_APPAR_BOUGHT", 20)
end)

local UNLOCK_HEISTS = menu.list(UNLOCK_ALL, "Desbloqueio de Heist ", { "" }, "Pule as missões chatas!", function()

end)

menu.action(UNLOCK_HEISTS, "Cayo Perico", {}, "Completa as missões do cayo e desbloqueia os premios", function()
    STAT_SET_INT("H4_MISSIONS", -1) --- copletar todas missões do cayo perico
    STAT_SET_INT("H4CNF_APPROACH", -1)
    STAT_SET_INT("H4CNF_BS_ENTR", 63)
    STAT_SET_INT("H4CNF_BS_GEN", 63)
    STAT_SET_INT("H4CNF_WEP_DISRP", 3)
    STAT_SET_INT("H4CNF_ARM_DISRP", 3)
    STAT_SET_INT("H4CNF_HEL_DISRP", 3)

    STAT_SET_BOOL("AWD_INTELGATHER", true) ---Unlock Heist Awards
    STAT_SET_BOOL("AWD_COMPOUNDINFILT", true)
    STAT_SET_BOOL("AWD_LOOT_FINDER", true)
    STAT_SET_BOOL("AWD_MAX_DISRUPT", true)
    STAT_SET_BOOL("AWD_THE_ISLAND_HEIST", true)
    STAT_SET_BOOL("AWD_GOING_ALONE", true)
    STAT_SET_BOOL("AWD_TEAM_WORK", true)
    STAT_SET_BOOL("AWD_MIXING_UP", true)
    STAT_SET_BOOL("AWD_PRO_THIEF", true)
    STAT_SET_BOOL("AWD_CAT_BURGLAR", true)
    STAT_SET_BOOL("AWD_ONE_OF_THEM", true)
    STAT_SET_BOOL("AWD_GOLDEN_GUN", true)
    STAT_SET_BOOL("AWD_ELITE_THIEF", true)
    STAT_SET_BOOL("AWD_PROFESSIONAL", true)
    STAT_SET_BOOL("AWD_HELPING_OUT", true)
    STAT_SET_BOOL("AWD_COURIER", true)
    STAT_SET_BOOL("AWD_PARTY_VIBES", true)
    STAT_SET_BOOL("AWD_HELPING_HAND", true)
    STAT_SET_BOOL("AWD_ELEVENELEVEN", true)
    STAT_SET_BOOL("COMPLETE_H4_F_USING_VETIR", true)
    STAT_SET_BOOL("COMPLETE_H4_F_USING_LONGFIN", true)
    STAT_SET_BOOL("COMPLETE_H4_F_USING_ANNIH", true)
    STAT_SET_BOOL("COMPLETE_H4_F_USING_ALKONOS", true)
    STAT_SET_BOOL("COMPLETE_H4_F_USING_PATROLB", true)
    STAT_SET_INT("AWD_LOSTANDFOUND", 500000)
    STAT_SET_INT("AWD_SUNSET", 1800000)
    STAT_SET_INT("AWD_TREASURE_HUNTER", 1000000)
    STAT_SET_INT("AWD_WRECK_DIVING", 1000000)
    STAT_SET_INT("AWD_KEINEMUSIK", 1800000)
    STAT_SET_INT("AWD_PALMS_TRAX", 1800000)
    STAT_SET_INT("AWD_MOODYMANN", 1800000)
    STAT_SET_INT("AWD_FILL_YOUR_BAGS", 1000000000)
    STAT_SET_INT("AWD_WELL_PREPARED", 80)
    STAT_SET_INT("H4_H4_DJ_MISSIONS", -1)
end)

menu.action(UNLOCK_HEISTS, "Cassino", {}, "Completa as missões do Cassino e desbloqueia os premios", function()
    STAT_SET_INT("CAS_HEIST_NOTS", -1) --- unlock cassino ---Unlock Heist Awards
    STAT_SET_INT("CH_ARC_CAB_CLAW_TROPHY", -1)
    STAT_SET_INT("CH_ARC_CAB_LOVE_TROPHY", -1)
    STAT_SET_INT("SIGNAL_JAMMERS_COLLECTED", 50)
    STAT_SET_INT("AWD_ODD_JOBS", 52)
    STAT_SET_INT("AWD_PREPARATION", 40)
    STAT_SET_INT("AWD_ASLEEPONJOB", 20)
    STAT_SET_INT("AWD_DAICASHCRAB", 100000)
    STAT_SET_INT("AWD_BIGBRO", 40)
    STAT_SET_INT("AWD_SHARPSHOOTER", 40)
    STAT_SET_INT("AWD_RACECHAMP", 40)
    STAT_SET_INT("AWD_BATSWORD", 1000000)
    STAT_SET_INT("AWD_COINPURSE", 950000)
    STAT_SET_INT("AWD_ASTROCHIMP", 3000000)
    STAT_SET_INT("AWD_MASTERFUL", 40000)
    STAT_SET_INT("H3_BOARD_DIALOGUE0", -1)
    STAT_SET_INT("H3_BOARD_DIALOGUE1", -1)
    STAT_SET_INT("H3_BOARD_DIALOGUE2", -1)
    STAT_SET_INT("H3_VEHICLESUSED", -1)
    STAT_SET_BOOL("AWD_FIRST_TIME1", true)
    STAT_SET_BOOL("AWD_FIRST_TIME2", true)
    STAT_SET_BOOL("AWD_FIRST_TIME3", true)
    STAT_SET_BOOL("AWD_FIRST_TIME4", true)
    STAT_SET_BOOL("AWD_FIRST_TIME5", true)
    STAT_SET_BOOL("AWD_FIRST_TIME6", true)
    STAT_SET_BOOL("AWD_ALL_IN_ORDER", true)
    STAT_SET_BOOL("AWD_SUPPORTING_ROLE", true)
    STAT_SET_BOOL("AWD_LEADER", true)
    STAT_SET_BOOL("AWD_ODD_JOBS", true)
    STAT_SET_BOOL("AWD_SURVIVALIST", true)
    STAT_SET_BOOL("AWD_SCOPEOUT", true)
    STAT_SET_BOOL("AWD_CREWEDUP", true)
    STAT_SET_BOOL("AWD_MOVINGON", true)
    STAT_SET_BOOL("AWD_PROMOCAMP", true)
    STAT_SET_BOOL("AWD_GUNMAN", true)
    STAT_SET_BOOL("AWD_SMASHNGRAB", true)
    STAT_SET_BOOL("AWD_INPLAINSI", true)
    STAT_SET_BOOL("AWD_UNDETECTED", true)
    STAT_SET_BOOL("AWD_ALLROUND", true)
    STAT_SET_BOOL("AWD_ELITETHEIF", true)
    STAT_SET_BOOL("AWD_PRO", true)
    STAT_SET_BOOL("AWD_SUPPORTACT", true)
    STAT_SET_BOOL("AWD_SHAFTED", true)
    STAT_SET_BOOL("AWD_COLLECTOR", true)
    STAT_SET_BOOL("AWD_DEADEYE", true)
    STAT_SET_BOOL("AWD_PISTOLSATDAWN", true)
    STAT_SET_BOOL("AWD_TRAFFICAVOI", true)
    STAT_SET_BOOL("AWD_CANTCATCHBRA", true)
    STAT_SET_BOOL("AWD_WIZHARD", true)
    STAT_SET_BOOL("AWD_APEESCAPE", true)
    STAT_SET_BOOL("AWD_MONKEYKIND", true)
    STAT_SET_BOOL("AWD_AQUAAPE", true)
    STAT_SET_BOOL("AWD_KEEPFAITH", true)
    STAT_SET_BOOL("AWD_TRUELOVE", true)
    STAT_SET_BOOL("AWD_NEMESIS", true)
    STAT_SET_BOOL("AWD_FRIENDZONED", true)
    STAT_SET_BOOL("VCM_FLOW_CS_RSC_SEEN", true)
    STAT_SET_BOOL("VCM_FLOW_CS_BWL_SEEN", true)
    STAT_SET_BOOL("VCM_FLOW_CS_MTG_SEEN", true)
    STAT_SET_BOOL("VCM_FLOW_CS_OIL_SEEN", true)
    STAT_SET_BOOL("VCM_FLOW_CS_DEF_SEEN", true)
    STAT_SET_BOOL("VCM_FLOW_CS_FIN_SEEN", true)
    STAT_SET_BOOL("CAS_VEHICLE_REWARD", false)
    STAT_SET_BOOL("HELP_FURIA", true)
    STAT_SET_BOOL("HELP_MINITAN", true)
    STAT_SET_BOOL("HELP_YOSEMITE2", true)
    STAT_SET_BOOL("HELP_ZHABA", true)
    STAT_SET_BOOL("HELP_IMORGEN", true)
    STAT_SET_BOOL("HELP_SULTAN2", true)
    STAT_SET_BOOL("HELP_VAGRANT", true)
    STAT_SET_BOOL("HELP_VSTR", true)
    STAT_SET_BOOL("HELP_STRYDER", true)
    STAT_SET_BOOL("HELP_SUGOI", true)
    STAT_SET_BOOL("HELP_KANJO", true)
    STAT_SET_BOOL("HELP_FORMULA", true)
    STAT_SET_BOOL("HELP_FORMULA2", true)
    STAT_SET_BOOL("HELP_JB7002", true)
    SET_INT_LOCAL("fm_mission_controller", 19679 + 1741, 151) ---Casino Aggressive / Classic
    SET_INT_LOCAL("fm_mission_controller", 19679 + 2686, 10000000)
    SET_INT_LOCAL("fm_mission_controller", 27440 + 859, 99999)
    SET_INT_LOCAL("fm_mission_controller", 31554 + 69, 99999)
    SET_INT_LOCAL("fm_mission_controller", 31554 + 97, 79)
end)

menu.action(UNLOCK_HEISTS, "Juizo final", {}, "Completa as missões do Juizo final e desbloqueia os premios",
    function()
        STAT_SET_INT("GANGOPS_HEIST_STATUS", -1) --- juizo final
        STAT_SET_INT("GANGOPS_HEIST_STATUS", -229384)

        STAT_SET_INT("GANGOPS_FM_MISSION_PROG", -1) ---juizo final
        STAT_SET_INT("GANGOPS_FLOW_MISSION_PROG", -1)
        STAT_SET_INT("MPPLY_GANGOPS_ALLINORDER", 100)
        STAT_SET_INT("MPPLY_GANGOPS_LOYALTY", 100)
        STAT_SET_INT("MPPLY_GANGOPS_CRIMMASMD", 100)
        STAT_SET_INT("MPPLY_GANGOPS_LOYALTY2", 100)
        STAT_SET_INT("MPPLY_GANGOPS_LOYALTY3", 100)
        STAT_SET_INT("MPPLY_GANGOPS_CRIMMASMD2", 100)
        STAT_SET_INT("MPPLY_GANGOPS_CRIMMASMD3", 100)
        STAT_SET_INT("MPPLY_GANGOPS_SUPPORT", 100)
        STAT_SET_INT("CR_GANGOP_MORGUE", 10)
        STAT_SET_INT("CR_GANGOP_DELUXO", 10)
        STAT_SET_INT("CR_GANGOP_SERVERFARM", 10)
        STAT_SET_INT("CR_GANGOP_IAABASE_FIN", 10)
        STAT_SET_INT("CR_GANGOP_STEALOSPREY", 10)
        STAT_SET_INT("CR_GANGOP_FOUNDRY", 10)
        STAT_SET_INT("CR_GANGOP_RIOTVAN", 10)
        STAT_SET_INT("CR_GANGOP_SUBMARINECAR", 10)
        STAT_SET_INT("CR_GANGOP_SUBMARINE_FIN", 10)
        STAT_SET_INT("CR_GANGOP_PREDATOR", 10)
        STAT_SET_INT("CR_GANGOP_BMLAUNCHER", 10)
        STAT_SET_INT("CR_GANGOP_BCCUSTOM", 10)
        STAT_SET_INT("CR_GANGOP_STEALTHTANKS", 10)
        STAT_SET_INT("CR_GANGOP_SPYPLANE", 10)
        STAT_SET_INT("CR_GANGOP_FINALE", 10)
        STAT_SET_INT("CR_GANGOP_FINALE_P2", 10)
        STAT_SET_INT("CR_GANGOP_FINALE_P3", 10)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_IAA", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_SUBMARINE", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_MISSILE", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_ALLINORDER", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_LOYALTY", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_LOYALTY2", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_LOYALTY3", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_CRIMMASMD", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_CRIMMASMD2", true)
        STAT_SET_BOOL("MPPLY_AWD_GANGOPS_CRIMMASMD3", true)
    end)

menu.action(UNLOCK_HEISTS, "fleeca ", {}, "Completa as missões do fleeca  e desbloqueia os premios", function()
    STAT_SET_INT("AWD_FINISH_HEISTS", 900) ---fleeca
    STAT_SET_INT("MPPLY_WIN_GOLD_MEDAL_HEISTS", 900)
    STAT_SET_INT("AWD_DO_HEIST_AS_MEMBER", 900)
    STAT_SET_INT("AWD_DO_HEIST_AS_THE_LEADER", 900)
    STAT_SET_INT("AWD_FINISH_HEIST_SETUP_JOB", 900)
    STAT_SET_INT("AWD_FINISH_HEIST", 900)
    STAT_SET_INT("HEIST_COMPLETION", 900)
    STAT_SET_INT("HEISTS_ORGANISED", 900)
    STAT_SET_INT("AWD_CONTROL_CROWDS", 900)
    STAT_SET_INT("AWD_WIN_GOLD_MEDAL_HEISTS", 900)
    STAT_SET_INT("AWD_COMPLETE_HEIST_NOT_DIE", 900)
    STAT_SET_INT("HEIST_START", 900)
    STAT_SET_INT("HEIST_END", 900)
    STAT_SET_INT("CUTSCENE_MID_PRISON", 900)
    STAT_SET_INT("CUTSCENE_MID_HUMANE", 900)
    STAT_SET_INT("CUTSCENE_MID_NARC", 900)
    STAT_SET_INT("CUTSCENE_MID_ORNATE", 900)
    STAT_SET_INT("CR_FLEECA_PREP_1", 5000)
    STAT_SET_INT("CR_FLEECA_PREP_2", 5000)
    STAT_SET_INT("CR_FLEECA_FINALE", 5000)
    STAT_SET_INT("CR_PRISON_PLANE", 5000)
    STAT_SET_INT("CR_PRISON_BUS", 5000)
    STAT_SET_INT("CR_PRISON_STATION", 5000)
    STAT_SET_INT("CR_PRISON_UNFINISHED_BIZ", 5000)
    STAT_SET_INT("CR_PRISON_FINALE", 5000)
    STAT_SET_INT("CR_HUMANE_KEY_CODES", 5000)
    STAT_SET_INT("CR_HUMANE_ARMORDILLOS", 5000)
    STAT_SET_INT("CR_HUMANE_EMP", 5000)
    STAT_SET_INT("CR_HUMANE_VALKYRIE", 5000)
    STAT_SET_INT("CR_HUMANE_FINALE", 5000)
    STAT_SET_INT("CR_NARC_COKE", 5000)
    STAT_SET_INT("CR_NARC_TRASH_TRUCK", 5000)
    STAT_SET_INT("CR_NARC_BIKERS", 5000)
    STAT_SET_INT("CR_NARC_WEED", 5000)
    STAT_SET_INT("CR_NARC_STEAL_METH", 5000)
    STAT_SET_INT("CR_NARC_FINALE", 5000)
    STAT_SET_INT("CR_PACIFIC_TRUCKS", 5000)
    STAT_SET_INT("CR_PACIFIC_WITSEC", 5000)
    STAT_SET_INT("CR_PACIFIC_HACK", 5000)
    STAT_SET_INT("CR_PACIFIC_BIKES", 5000)
    STAT_SET_INT("CR_PACIFIC_CONVOY", 5000)
    STAT_SET_INT("CR_PACIFIC_FINALE", 5000)
    STAT_SET_INT("MPPLY_HEIST_ACH_TRACKER", -1)
    STAT_SET_BOOL("MPPLY_AWD_COMPLET_HEIST_MEM", true)
    STAT_SET_BOOL("MPPLY_AWD_COMPLET_HEIST_1STPER", true)
    STAT_SET_BOOL("MPPLY_AWD_FLEECA_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_HST_ORDER", true)
    STAT_SET_BOOL("MPPLY_AWD_HST_SAME_TEAM", true)
    STAT_SET_BOOL("MPPLY_AWD_HST_ULT_CHAL", true)
    STAT_SET_BOOL("MPPLY_AWD_HUMANE_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_PACIFIC_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_PRISON_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_SERIESA_FIN", true)
    STAT_SET_BOOL("AWD_FINISH_HEIST_NO_DAMAGE", true)
    STAT_SET_BOOL("AWD_SPLIT_HEIST_TAKE_EVENLY", true)
    STAT_SET_BOOL("AWD_ALL_ROLES_HEIST", true)
    STAT_SET_BOOL("AWD_MATCHING_OUTFIT_HEIST", true)
    STAT_SET_BOOL("HEIST_PLANNING_DONE_PRINT", true)
    STAT_SET_BOOL("HEIST_PLANNING_DONE_HELP_0", true)
    STAT_SET_BOOL("HEIST_PLANNING_DONE_HELP_1", true)
    STAT_SET_BOOL("HEIST_PRE_PLAN_DONE_HELP_0", true)
    STAT_SET_BOOL("HEIST_CUTS_DONE_FINALE", true)
    STAT_SET_BOOL("HEIST_IS_TUTORIAL", false)
    STAT_SET_BOOL("HEIST_STRAND_INTRO_DONE", true)
    STAT_SET_BOOL("HEIST_CUTS_DONE_ORNATE", true)
    STAT_SET_BOOL("HEIST_CUTS_DONE_PRISON", true)
    STAT_SET_BOOL("HEIST_CUTS_DONE_BIOLAB", true)
    STAT_SET_BOOL("HEIST_CUTS_DONE_NARCOTIC", true)
    STAT_SET_BOOL("HEIST_CUTS_DONE_TUTORIAL", true)
    STAT_SET_BOOL("HEIST_AWARD_DONE_PREP", true)
    STAT_SET_BOOL("HEIST_AWARD_BOUGHT_IN", true)
end)

menu.action(UNLOCK_HEISTS, "LS Robbery ", {}, "Completa as missões do LS Robbery e desbloqueia os premios",
    function()
        STAT_SET_INT("TUNER_GEN_BS", -1)
    end)

menu.action(UNLOCK_HEISTS, "Contrato ", {}, "Completa as missões do CONTRATO e desbloqueia os premios", function()
    STAT_SET_INT("FIXER_GENERAL_BS", -1) ----COMPLETAR AS MISSÃO DO CONTRATO
    STAT_SET_INT("FIXER_COMPLETED_BS", -1)
    STAT_SET_INT("FIXER_STORY_BS", -1)
    STAT_SET_INT("FIXER_STORY_COOLDOWN", -1)

    STAT_SET_INT("AWD_CONTRACTOR", 50) ---- O Contract
    STAT_SET_INT("AWD_COLD_CALLER", 50)
    STAT_SET_INT("AWD_PRODUCER", 60)
    STAT_SET_INT("FIXERTELEPHONEHITSCOMPL", 10)
    STAT_SET_INT("PAYPHONE_BONUS_KILL_METHOD", 10)
    STAT_SET_INT("FIXER_COUNT", 501)
    STAT_SET_INT("FIXER_SC_VEH_RECOVERED", 501)
    STAT_SET_INT("FIXER_SC_VAL_RECOVERED", 501)
    STAT_SET_INT("FIXER_SC_GANG_TERMINATED", 501)
    STAT_SET_INT("FIXER_SC_VIP_RESCUED", 501)
    STAT_SET_INT("FIXER_SC_ASSETS_PROTECTED", 501)
    STAT_SET_INT("FIXER_SC_EQ_DESTROYED", 501)
    STAT_SET_INT("FIXER_EARNINGS", 300000)
    STAT_SET_BOOL("AWD_TEEING_OFF", true)
    STAT_SET_BOOL("AWD_PARTY_NIGHT", true)
    STAT_SET_BOOL("AWD_BILLIONAIRE_GAMES", true)
    STAT_SET_BOOL("AWD_HOOD_PASS", true)
    STAT_SET_BOOL("AWD_STUDIO_TOUR", true)
    STAT_SET_BOOL("AWD_DONT_MESS_DRE", true)
    STAT_SET_BOOL("AWD_BACKUP", true)
    STAT_SET_BOOL("AWD_SHORTFRANK_1", true)
    STAT_SET_BOOL("AWD_SHORTFRANK_2", true)
    STAT_SET_BOOL("AWD_SHORTFRANK_3", true)
    STAT_SET_BOOL("AWD_CONTR_KILLER", true)
    STAT_SET_BOOL("AWD_DOGS_BEST_FRIEND", true)
    STAT_SET_BOOL("AWD_MUSIC_STUDIO", true)
    STAT_SET_BOOL("AWD_SHORTLAMAR_1", true)
    STAT_SET_BOOL("AWD_SHORTLAMAR_2", true)
    STAT_SET_BOOL("AWD_SHORTLAMAR_3", true)
    STAT_SET_BOOL("BS_FRANKLIN_DIALOGUE_0", true)
    STAT_SET_BOOL("BS_FRANKLIN_DIALOGUE_1", true)
    STAT_SET_BOOL("BS_FRANKLIN_DIALOGUE_2", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_SETUP", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_STRAND", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_PARTY", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_PARTY_2", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_PARTY_F", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_BILL", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_BILL_2", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_BILL_F", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_HOOD", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_HOOD_2", true)
    STAT_SET_BOOL("BS_IMANI_D_APP_HOOD_F", true)
end)

menu.action(UNLOCK_HEISTS, "Test", {}, "", function()
    SET_INT_LOCAL("gb_sightseer", 247 + 1)
    PARTICIPANT_ID_TO_INT(6 + 5, 3) ---turista               --- em teste, duvidas de toogle- duvidas de manuseio do codigo-reviw
    SET_INT_LOCAL("gb_smuggler", 1926 + 1035)
    GET_INT_LOCAL("gb_smuggler", 1926 + 1078) ---Carga aérea
end)

local UNLOCK_ARMAS = menu.list(UNLOCK_ALL, "Armas Raras", { "" }, "Pule as missões para desbloquear essas armas chatas!"
    ,
    function()

    end)

menu.action(UNLOCK_ARMAS, "Atomizador", {}, "", function()
    SET_INT_GLOBAL(103375, 90) -- freemode.c, joaat("weapon_raypistol"), -1, 0 atomizador
end)

menu.action(UNLOCK_ARMAS, "Carabina", {}, "", function()
    SET_INT_GLOBAL(262145 + 32775, 1) ---carabina
end)

menu.action(UNLOCK_ARMAS, "Machado de Pedra", {}, "", function()
    STAT_SET_BOOL("MPPLY_MELEECHLENGECOMPLETED", true) ---machado

end)

menu.action(UNLOCK_ARMAS, "Revolver Ação Dupla", {}, "", function()
    STAT_SET_BOOL("MPPLY_HEADSHOTCHLENGECOMPLETED", true) ---ação dupla
end)

menu.action(UNLOCK_ARMAS, "Revolver do Marinheiro", {}, "", function()
    STAT_SET_BOOL("MPPLY_NAVYREVOLVERCOMPLETED", true) ---revolver marinheiro
end)

local UNLOCK_PARTE = menu.list(UNLOCK_ALL, "Desbloqueios a Parte", { "" },
    "Desbloqueie o que quiser, sempre com paciencia e esperando as transações.", function()

end)

local UNLOCK_DLC = menu.list(UNLOCK_PARTE, "DLC'S", {}, "", function()

end)

local INDEPENDENCE_PACK = menu.list(UNLOCK_DLC, "Independencia", {}, "", function()

end)
---------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(INDEPENDENCE_PACK, "Pack da independencia", {}, "sovereign, Monster truck e independence pack",
    function()
        SET_INT_GLOBAL(262145 + 8272, 1) ---- "Toggle_activate_Western_sovereign"
        SET_INT_GLOBAL(262145 + 8273, 1) ---- "Toggle_activate_Monster_truck"
        SET_INT_GLOBAL(262145 + 8258, 1) ---- "toggle_activate_independence_pack"
        SET_PACKED_INT_GLOBAL(8267, 8273, 1) -- joaat("independence_day_deactivate_fireworks_launcher"), joaat("Toggle_activate_Monster_truck") independencia
    end)

menu.action(INDEPENDENCE_PACK, "Independencia", {}, "", function()
    SET_INT_GLOBAL(262145 + 8267, 1) ---- "independence_day_deactivate_fireworks_launcher"
    SET_INT_GLOBAL(262145 + 8268, 1) ---- "independence_day_deactivate_placed_fireworks"
    SET_INT_GLOBAL(262145 + 8271, 1) ---- "DISABLEFIREWORKS"
    SET_INT_GLOBAL(262145 + 8296, 1) ---- "Pisswasser" Beer Hat
    SET_INT_GLOBAL(262145 + 8297, 1) ---- "Benedict" Beer Hat
    SET_INT_GLOBAL(262145 + 8298, 1) ---- "J Lager" Beer Hat
    SET_INT_GLOBAL(262145 + 8299, 1) ---- "Patriot" Beer Hat
    SET_INT_GLOBAL(262145 + 8300, 1) ---- "Blarneys" Beer Hat
    SET_INT_GLOBAL(262145 + 8301, 1) ---- "Supa Wet" Beer Hat
    SET_INT_GLOBAL(262145 + 8302, 1) ---- "Statue of Happiness T-shirt
    SET_PACKED_INT_GLOBAL(8267, 8273, 1) -- joaat("independence_day_deactivate_fireworks_launcher"), joaat("Toggle_activate_Monster_truck") independencia
    SET_PACKED_INT_GLOBAL(8296, 8302, 1) -- joaat("unlockindependence_beer_hat_1"), joaat("unlockindependence_statue_happiness_shirt")
end)
------------------------------------------------------------------------------------------------------------------------

local NATAL_PACK = menu.list(UNLOCK_DLC, "Natal", {}, "", function()

end)

menu.toggle_loop(NATAL_PACK, "Natal Pack", {}, "", function()
    SET_INT_GLOBAL(262145 + 4762, 1) -- joaat("toggle_xmas_content")
    SET_INT_GLOBAL(262145 + 9184, 1) -- joaat("toggle_gift_to_player_when_logging_on")
    SET_PACKED_INT_GLOBAL(25826, 25829, 1) -- joaat("toggle_2018_christmas_eve_gift"), joaat("toggle_2018_christmas_day_gift")
    SET_PACKED_INT_GLOBAL(28678, 28681, 1) -- joaat("toggle_2019_christmas_eve_gift"), joaat("toggle_2019_christmas_day_gift")
    SET_PACKED_INT_GLOBAL(12813, 12816, 1) -- joaat("toggle_2015_christmas_eve_gift"), joaat("toggle_2015_christmas_day_gift")
    SET_PACKED_INT_GLOBAL(19160, 19163, 1) -- joaat("toggle_2016_christmas_eve_gift"), joaat("toggle_2016_christmas_day_gift")
    SET_PACKED_INT_GLOBAL(9448, 9450, 1) -- joaat("toggle_christmas_eve_gift"), joaat("toggle_new_years_day_gift")
end)

menu.action(NATAL_PACK, "Natal", {}, "", function()
    STAT_SET_INT("MPPLY_XMASLIVERIES1", -1) ---Desbloquear Liveries de Natal
    STAT_SET_INT("MPPLY_XMASLIVERIES2", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES3", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES4", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES5", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES6", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES7", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES8", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES9", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES10", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES11", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES12", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES13", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES14", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES15", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES16", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES17", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES18", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES19", -1)
    STAT_SET_INT("MPPLY_XMASLIVERIES20", -1)
    SET_PACKED_INT_GLOBAL(9392, 9401, 1) -- joaat("disable_snowballs"), joaat("pick_up_number_of_snowballs") Desbloqueie o conteúdo de Natal
    SET_PACKED_INT_GLOBAL(12707, 12708, 1) -- joaat("XMAS2015_VEHI("CLE"), -452612879
    SET_PACKED_INT_GLOBAL(23435, 23443, 1) -- 1840129338, -495986083
    SET_PACKED_INT_GLOBAL(23462, 23465, 1) -- -101086705, -1663567610
    SET_PACKED_INT_GLOBAL(25822, 25824, 1) -- 1975465829, -146321616
    SET_PACKED_INT_GLOBAL(31744, 31745, 1) -- 1073486652, -1378428735
    SET_INT_GLOBAL(262145 + 12710, 1) -- 1247240781
    SET_INT_GLOBAL(262145 + 19301, 1) -- joaat("christmas2016_("clothing")
    SET_INT_GLOBAL(262145 + 23084, 1) -- joaat("christmas2017_("clothing")
    SET_INT_GLOBAL(262145 + 24231, 1) -- -1029230616
    SET_INT_GLOBAL(262145 + 30890, 1) -- 950317171
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DLC, "Halloween", {}, "", function()
    SET_INT_GLOBAL(262145 + 11993, 1) ---- "turn_on_halloween_event"
    SET_INT_GLOBAL(262145 + 12033, 1) ---- "enable_heist_masks_halloween"
    SET_INT_GLOBAL(262145 + 12038, 1) ---- "turn_on_halloween_vehi("cles"
    SET_INT_GLOBAL(262145 + 12039, 1) ---- "turn_on_halloween_masks"
    SET_INT_GLOBAL(262145 + 12040, 1) ---- "turn_on_halloween_facepaint"
    SET_INT_GLOBAL(262145 + 12042, 1) ---- "turn_on_halloween_bobbleheads"
    SET_INT_GLOBAL(262145 + 12048, 1) ---- "turn_on_halloween_("clothing"
    SET_INT_GLOBAL(262145 + 12049, 1) ---- "turn_on_halloween_weapons"
    SET_INT_GLOBAL(262145 + 12050, 1) ---- "turn_on_halloween_horns"
    SET_INT_GLOBAL(262145 + 12056, 1) ---- "TURN_ON_HALLOWEEN_ANIMS"
    SET_INT_GLOBAL(262145 + 12699, 1) ---- "TURN_ON_HALLOWEEN_SOUNDS"
    SET_INT_GLOBAL(262145 + 17536, 1) ---- "enable_biker_sanctus"
    SET_INT_GLOBAL(262145 + 31190, 1) ---- Halloween Parachute Bag
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DLC, "Verão", {}, "", function()
    STAT_SET_BOOL("AWD_KINGOFQUB3D", true) ---DLC de verão 2020
    STAT_SET_BOOL("AWD_QUBISM", true)
    STAT_SET_BOOL("AWD_QUIBITS", true)
    STAT_SET_BOOL("AWD_GODOFQUB3D", true)
    STAT_SET_BOOL("AWD_GOFOR11TH", true)
    STAT_SET_BOOL("AWD_ELEVENELEVEN", true)
    SET_PACKED_INT_GLOBAL(29673, 29708, 1) -- -1685644799, 1216916542(roupas de verão)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DLC, "Valentine", {}, "", function()

    SET_PACKED_INT_GLOBAL(12027, 12031, 1) -- joaat("TURN_ON_VALENTINE_WEAPON"), joaat("TURN_ON_VALENTINE_("CLOTHING") Namorados
    SET_PACKED_INT_GLOBAL(13393, 13394, 1) -- joaat("TURN_ON_VALENTINE_2016_("CLOTHING"), joaat("TURN_ON_VALENTINE_2016_VEHI("CLE")
    SET_INT_GLOBAL(262145 + 7058, 1) -- joaat("TURN_ON_VALENTINES_EVENT")
end)
------------------------------------------------------------------------------------------------------------------------------
local UNLOCK_DATAS = menu.list(UNLOCK_PARTE, "Desbloqueio Anual", { "" }, "", function()

end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Arena", {}, "", function()
    STAT_SET_INT("ARN_BS_TRINKET_TICKERS", -1) ---troféus e brinquedos do Arena Wars
    STAT_SET_INT("ARN_BS_TRINKET_SAVED", -1)
    STAT_SET_INT("AWD_WATCH_YOUR_STEP", 50)
    STAT_SET_INT("AWD_TOWER_OFFENSE", 50)
    STAT_SET_INT("AWD_READY_FOR_WAR", 50)
    STAT_SET_INT("AWD_THROUGH_A_LENS", 50)
    STAT_SET_INT("AWD_SPINNER", 50)
    STAT_SET_INT("AWD_YOUMEANBOOBYTRAPS", 50)
    STAT_SET_INT("AWD_MASTER_BANDITO", 50)
    STAT_SET_INT("AWD_SITTING_DUCK", 50)
    STAT_SET_INT("AWD_CROWDPARTICIPATION", 50)
    STAT_SET_INT("AWD_KILL_OR_BE_KILLED", 50)
    STAT_SET_INT("AWD_MASSIVE_SHUNT", 50)
    STAT_SET_INT("AWD_YOURE_OUTTA_HERE", 200)
    STAT_SET_INT("AWD_WEVE_GOT_ONE", 50)
    STAT_SET_INT("AWD_ARENA_WAGEWORKER", 1000000)
    STAT_SET_INT("AWD_TIME_SERVED", 1000)
    STAT_SET_INT("AWD_TOP_SCORE", 55000)
    STAT_SET_INT("AWD_CAREER_WINNER", 1000)
    STAT_SET_INT("ARENAWARS_SP", 209)
    STAT_SET_INT("ARENAWARS_SKILL_LEVEL", 20)
    STAT_SET_INT("ARENAWARS_SP_LIFETIME", 209)
    STAT_SET_INT("ARENAWARS_AP_TIER", 1000)
    STAT_SET_INT("ARENAWARS_AP_LIFETIME", 47551850)
    STAT_SET_INT("ARENAWARS_CARRER_UNLK", 44)
    STAT_SET_INT("ARN_W_THEME_SCIFI", 1000)
    STAT_SET_INT("ARN_W_THEME_APOC", 1000)
    STAT_SET_INT("ARN_W_THEME_CONS", 1000)
    STAT_SET_INT("ARN_W_PASS_THE_BOMB", 1000)
    STAT_SET_INT("ARN_W_DETONATION", 1000)
    STAT_SET_INT("ARN_W_ARCADE_RACE", 1000)
    STAT_SET_INT("ARN_W_CTF", 1000)
    STAT_SET_INT("ARN_W_TAG_TEAM", 1000)
    STAT_SET_INT("ARN_W_DESTR_DERBY", 1000)
    STAT_SET_INT("ARN_W_CARNAGE", 1000)
    STAT_SET_INT("ARN_W_MONSTER_JAM", 1000)
    STAT_SET_INT("ARN_W_GAMES_MASTERS", 1000)
    STAT_SET_INT("ARN_L_PASS_THE_BOMB", 500)
    STAT_SET_INT("ARN_L_DETONATION", 500)
    STAT_SET_INT("ARN_L_ARCADE_RACE", 500)
    STAT_SET_INT("ARN_L_CTF", 500)
    STAT_SET_INT("ARN_L_TAG_TEAM", 500)
    STAT_SET_INT("ARN_L_DESTR_DERBY", 500)
    STAT_SET_INT("ARN_L_CARNAGE", 500)
    STAT_SET_INT("ARN_L_MONSTER_JAM", 500)
    STAT_SET_INT("ARN_L_GAMES_MASTERS", 500)
    STAT_SET_INT("NUMBER_OF_CHAMP_BOUGHT", 1000)
    STAT_SET_INT("ARN_SPECTATOR_KILLS", 1000)
    STAT_SET_INT("ARN_LIFETIME_KILLS", 1000)
    STAT_SET_INT("ARN_LIFETIME_DEATHS", 500)
    STAT_SET_INT("ARENAWARS_CARRER_WINS", 1000)
    STAT_SET_INT("ARENAWARS_CARRER_WINT", 1000)
    STAT_SET_INT("ARENAWARS_MATCHES_PLYD", 1000)
    STAT_SET_INT("ARENAWARS_MATCHES_PLYDT", 1000)
    STAT_SET_INT("ARN_SPEC_BOX_TIME_MS", 86400000)
    STAT_SET_INT("ARN_SPECTATOR_DRONE", 1000)
    STAT_SET_INT("ARN_SPECTATOR_CAMS", 1000)
    STAT_SET_INT("ARN_SMOKE", 1000)
    STAT_SET_INT("ARN_DRINK", 1000)
    STAT_SET_INT("ARN_VEH_MONSTER", 31000)
    STAT_SET_INT("ARN_VEH_MONSTER", 41000)
    STAT_SET_INT("ARN_VEH_MONSTER", 51000)
    STAT_SET_INT("ARN_VEH_CERBERUS", 1000)
    STAT_SET_INT("ARN_VEH_CERBERUS2", 1000)
    STAT_SET_INT("ARN_VEH_CERBERUS3", 1000)
    STAT_SET_INT("ARN_VEH_BRUISER", 1000)
    STAT_SET_INT("ARN_VEH_BRUISER2", 1000)
    STAT_SET_INT("ARN_VEH_BRUISER3", 1000)
    STAT_SET_INT("ARN_VEH_SLAMVAN4", 1000)
    STAT_SET_INT("ARN_VEH_SLAMVAN5", 1000)
    STAT_SET_INT("ARN_VEH_SLAMVAN6", 1000)
    STAT_SET_INT("ARN_VEH_BRUTUS", 1000)
    STAT_SET_INT("ARN_VEH_BRUTUS2", 1000)
    STAT_SET_INT("ARN_VEH_BRUTUS3", 1000)
    STAT_SET_INT("ARN_VEH_SCARAB", 1000)
    STAT_SET_INT("ARN_VEH_SCARAB2", 1000)
    STAT_SET_INT("ARN_VEH_SCARAB3", 1000)
    STAT_SET_INT("ARN_VEH_DOMINATOR4", 1000)
    STAT_SET_INT("ARN_VEH_DOMINATOR5", 1000)
    STAT_SET_INT("ARN_VEH_DOMINATOR6", 1000)
    STAT_SET_INT("ARN_VEH_IMPALER2", 1000)
    STAT_SET_INT("ARN_VEH_IMPALER3", 1000)
    STAT_SET_INT("ARN_VEH_IMPALER4", 1000)
    STAT_SET_INT("ARN_VEH_ISSI4", 1000)
    STAT_SET_INT("ARN_VEH_ISSI5", 1000)
    STAT_SET_INT("ARN_VEH_ISSI", 61000)
    STAT_SET_INT("ARN_VEH_IMPERATOR", 1000)
    STAT_SET_INT("ARN_VEH_IMPERATOR2", 1000)
    STAT_SET_INT("ARN_VEH_IMPERATOR3", 1000)
    STAT_SET_INT("ARN_VEH_ZR380", 1000)
    STAT_SET_INT("ARN_VEH_ZR3802", 1000)
    STAT_SET_INT("ARN_VEH_ZR3803", 1000)
    STAT_SET_INT("ARN_VEH_DEATHBIKE", 1000)
    STAT_SET_INT("ARN_VEH_DEATHBIKE2", 1000)
    STAT_SET_INT("ARN_VEH_DEATHBIKE3", 1000)
    STAT_SET_BOOL("AWD_BEGINNER", true)
    STAT_SET_BOOL("AWD_FIELD_FILLER", true)
    STAT_SET_BOOL("AWD_ARMCHAIR_RACER", true)
    STAT_SET_BOOL("AWD_LEARNER", true)
    STAT_SET_BOOL("AWD_SUNDAY_DRIVER", true)
    STAT_SET_BOOL("AWD_THE_ROOKIE", true)
    STAT_SET_BOOL("AWD_BUMP_AND_RUN", true)
    STAT_SET_BOOL("AWD_GEAR_HEAD", true)
    STAT_SET_BOOL("AWD_DOOR_SLAMMER", true)
    STAT_SET_BOOL("AWD_HOT_LAP", true)
    STAT_SET_BOOL("AWD_ARENA_AMATEUR", true)
    STAT_SET_BOOL("AWD_PAINT_TRADER", true)
    STAT_SET_BOOL("AWD_SHUNTER", true)
    STAT_SET_BOOL("AWD_JOCK", true)
    STAT_SET_BOOL("AWD_WARRIOR", true)
    STAT_SET_BOOL("AWD_T_BONE", true)
    STAT_SET_BOOL("AWD_MAYHEM", true)
    STAT_SET_BOOL("AWD_WRECKER", true)
    STAT_SET_BOOL("AWD_CRASH_COURSE", true)
    STAT_SET_BOOL("AWD_ARENA_LEGEND", true)
    STAT_SET_BOOL("AWD_PEGASUS", true)
    STAT_SET_BOOL("AWD_UNSTOPPABLE", true)
    STAT_SET_BOOL("AWD_CONTACT_SPORT", true)
    SET_PACKED_INT_GLOBAL(25830, 25897, 1) -- -1782918513, -1597048932 (Roupas de Arena Wars)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Apocalipse", {}, "/./././", function()
    SET_INT_LOCAL("fm_mission_controller", 19679, 12) ---Apocalipse
    SET_INT_LOCAL("fm_mission_controller", 28298 + 1, 99999)
    SET_INT_LOCAL("fm_mission_controller", 31554 + 69, 99999)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Bunker", {}, "Todas pesquisas", function()
    SET_INT_LOCAL("gb_gunrunning", 1203 + 774, 0) ---bunker
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Boate", {}, "Desbloqueador geral de premios da boate", function()
    STAT_SET_INT("AWD_DANCE_TO_SOLOMUN", 120) --- Boate
    STAT_SET_INT("AWD_DANCE_TO_TALEOFUS", 120)
    STAT_SET_INT("AWD_DANCE_TO_DIXON", 120)
    STAT_SET_INT("AWD_DANCE_TO_BLKMAD", 120)
    STAT_SET_INT("AWD_CLUB_DRUNK", 200)
    STAT_SET_INT("NIGHTCLUB_VIP_APPEAR", 700)
    STAT_SET_INT("NIGHTCLUB_JOBS_DONE", 700)
    STAT_SET_INT("NIGHTCLUB_EARNINGS", 20721002)
    STAT_SET_INT("HUB_SALES_COMPLETED", 1001)
    STAT_SET_INT("HUB_EARNINGS", 320721002)
    STAT_SET_INT("DANCE_COMBO_DURATION_MINS", 3600000)
    STAT_SET_INT("NIGHTCLUB_PLAYER_APPEAR", 9506)
    STAT_SET_INT("LIFETIME_HUB_GOODS_SOLD", 784672)
    STAT_SET_INT("LIFETIME_HUB_GOODS_MADE", 507822)
    STAT_SET_INT("DANCEPERFECTOWNCLUB", 120)
    STAT_SET_INT("NUMUNIQUEPLYSINCLUB", 120)
    STAT_SET_INT("DANCETODIFFDJS", 4)
    STAT_SET_INT("NIGHTCLUB_HOTSPOT_TIME_MS", 3600000)
    STAT_SET_INT("NIGHTCLUB_CONT_TOTAL", 20)
    STAT_SET_INT("NIGHTCLUB_CONT_MISSION", -1)
    STAT_SET_INT("CLUB_CONTRABAND_MISSION", 1000)
    STAT_SET_INT("HUB_CONTRABAND_MISSION", 1000)
    STAT_SET_BOOL("AWD_CLUB_HOTSPOT", true)
    STAT_SET_BOOL("AWD_CLUB_CLUBBER", true)
    STAT_SET_BOOL("AWD_CLUB_COORD", true)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Bônus do jogador", {}, "", function()
    SET_INT_GLOBAL(262154 + 152259, 2) ---bônus do jogador off-line / online
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Cayo perico", {}, "", function()
    SET_PACKED_INT_GLOBAL(30197, 30220, 1) -- 433014829, 1014784742 (cayo unlocks)
    SET_PACKED_INT_GLOBAL(30226, 30265, 1) -- -38929647, 1052683033
    SET_PACKED_INT_GLOBAL(30270, 30289, 1) -- -2141771850, -1871460122
    SET_PACKED_INT_GLOBAL(30854, 30889, 1) -- 92877911, -1993561101
    SET_PACKED_INT_GLOBAL(30899, 30904, 1) -- -312057690, 265922985
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Contatos", {}, "", function()
    STAT_SET_INT("FM_ACT_PHN", -1) ---contatos
    STAT_SET_INT("FM_ACT_PH2", -1)
    STAT_SET_INT("FM_ACT_PH3", -1)
    STAT_SET_INT("FM_ACT_PH4", -1)
    STAT_SET_INT("FM_ACT_PH5", -1)
    STAT_SET_INT("FM_VEH_TX1", -1)
    STAT_SET_INT("FM_ACT_PH6", -1)
    STAT_SET_INT("FM_ACT_PH7", -1)
    STAT_SET_INT("FM_ACT_PH8", -1)
    STAT_SET_INT("FM_ACT_PH9", -1)
    STAT_SET_INT("FM_CUT_DONE", -1)
    STAT_SET_INT("FM_CUT_DONE_2", -1)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Escritorio/mc", {}, "", function()
    STAT_SET_INT("LIFETIME_BUY_COMPLETE", 1000) --- escritorio/mc
    STAT_SET_INT("LIFETIME_BUY_UNDERTAKEN", 1000)
    STAT_SET_INT("LIFETIME_SELL_COMPLETE", 1000)
    STAT_SET_INT("LIFETIME_SELL_UNDERTAKEN", 1000)
    STAT_SET_INT("LIFETIME_CONTRA_EARNINGS", 20000000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA1", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA2", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA3", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA4", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_COMPLET5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_BUY_UNDERTA5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_COMPLET5", 1000)
    STAT_SET_INT("LIFETIME_BIKER_SELL_UNDERTA5", 1000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS0", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS1", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS2", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS3", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS4", 20000000)
    STAT_SET_INT("LIFETIME_BKR_SELL_EARNINGS5", 20000000)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Fliperama", {}, "Desbloqueios de premios do fliperama", function()
    STAT_SET_INT("AWD_PREPARATION", 40) --- Fliperama
    STAT_SET_INT("AWD_ASLEEPONJOB", 20)
    STAT_SET_INT("AWD_DAICASHCRAB", 100000)
    STAT_SET_INT("AWD_BIGBRO", 40)
    STAT_SET_INT("AWD_SHARPSHOOTER", 40)
    STAT_SET_INT("AWD_RACECHAMP", 40)
    STAT_SET_INT("AWD_BATSWORD", 1000000)
    STAT_SET_INT("AWD_COINPURSE", 950000)
    STAT_SET_INT("AWD_ASTROCHIMP", 3000000)
    STAT_SET_INT("AWD_MASTERFUL", 40000)
    STAT_SET_INT("SCGW_NUM_WINS_GANG_0", 50)
    STAT_SET_INT("SCGW_NUM_WINS_GANG_1", 50)
    STAT_SET_INT("SCGW_NUM_WINS_GANG_2", 50)
    STAT_SET_INT("SCGW_NUM_WINS_GANG_3", 50)
    STAT_SET_INT("CH_ARC_CAB_CLAW_TROPHY", -1)
    STAT_SET_INT("CH_ARC_CAB_LOVE_TROPHY", -1)
    STAT_SET_INT("IAP_MAX_MOON_DIST", INT_MAX)
    STAT_SET_INT("IAP_INITIALS_0", 50)
    STAT_SET_INT("IAP_INITIALS_1", 50)
    STAT_SET_INT("IAP_INITIALS_2", 50)
    STAT_SET_INT("IAP_INITIALS_3", 50)
    STAT_SET_INT("IAP_INITIALS_4", 50)
    STAT_SET_INT("IAP_INITIALS_5", 50)
    STAT_SET_INT("IAP_INITIALS_6", 50)
    STAT_SET_INT("IAP_INITIALS_7", 50)
    STAT_SET_INT("IAP_INITIALS_8", 50)
    STAT_SET_INT("IAP_INITIALS_9", 50)
    STAT_SET_INT("IAP_SCORE_0", 69644)
    STAT_SET_INT("IAP_SCORE_1", 50333)
    STAT_SET_INT("IAP_SCORE_2", 63512)
    STAT_SET_INT("IAP_SCORE_3", 46136)
    STAT_SET_INT("IAP_SCORE_4", 21638)
    STAT_SET_INT("IAP_SCORE_5", 2133)
    STAT_SET_INT("IAP_SCORE_6", 1215)
    STAT_SET_INT("IAP_SCORE_7", 2444)
    STAT_SET_INT("IAP_SCORE_8", 38023)
    STAT_SET_INT("IAP_SCORE_9", 2233)
    STAT_SET_INT("SCGW_SCORE_1", 50)
    STAT_SET_INT("SCGW_SCORE_2", 50)
    STAT_SET_INT("SCGW_SCORE_3", 50)
    STAT_SET_INT("SCGW_SCORE_4", 50)
    STAT_SET_INT("SCGW_SCORE_5", 50)
    STAT_SET_INT("SCGW_SCORE_6", 50)
    STAT_SET_INT("SCGW_SCORE_7", 50)
    STAT_SET_INT("SCGW_SCORE_8", 50)
    STAT_SET_INT("SCGW_SCORE_9", 50)
    STAT_SET_INT("DG_DEFENDER_INITIALS_0", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_1", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_2", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_3", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_4", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_5", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_6", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_7", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_8", 69644)
    STAT_SET_INT("DG_DEFENDER_INITIALS_9", 69644)
    STAT_SET_INT("DG_DEFENDER_SCORE_0", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_1", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_2", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_3", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_4", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_5", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_6", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_7", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_8", 50)
    STAT_SET_INT("DG_DEFENDER_SCORE_9", 50)
    STAT_SET_INT("DG_MONKEY_INITIALS_0", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_1", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_2", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_3", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_4", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_5", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_6", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_7", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_8", 69644)
    STAT_SET_INT("DG_MONKEY_INITIALS_9", 69644)
    STAT_SET_INT("DG_MONKEY_SCORE_0", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_1", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_2", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_3", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_4", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_5", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_6", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_7", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_8", 50)
    STAT_SET_INT("DG_MONKEY_SCORE_9", 50)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_0", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_1", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_2", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_3", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_4", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_5", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_6", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_7", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_8", 69644)
    STAT_SET_INT("DG_PENETRATOR_INITIALS_9", 69644)
    STAT_SET_INT("DG_PENETRATOR_SCORE_0", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_1", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_2", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_3", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_4", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_5", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_6", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_7", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_8", 50)
    STAT_SET_INT("DG_PENETRATOR_SCORE_9", 50)
    STAT_SET_INT("GGSM_INITIALS_0", 69644)
    STAT_SET_INT("GGSM_INITIALS_1", 69644)
    STAT_SET_INT("GGSM_INITIALS_2", 69644)
    STAT_SET_INT("GGSM_INITIALS_3", 69644)
    STAT_SET_INT("GGSM_INITIALS_4", 69644)
    STAT_SET_INT("GGSM_INITIALS_5", 69644)
    STAT_SET_INT("GGSM_INITIALS_6", 69644)
    STAT_SET_INT("GGSM_INITIALS_7", 69644)
    STAT_SET_INT("GGSM_INITIALS_8", 69644)
    STAT_SET_INT("GGSM_INITIALS_9", 69644)
    STAT_SET_INT("GGSM_SCORE_0", 50)
    STAT_SET_INT("GGSM_SCORE_1", 50)
    STAT_SET_INT("GGSM_SCORE_2", 50)
    STAT_SET_INT("GGSM_SCORE_3", 50)
    STAT_SET_INT("GGSM_SCORE_4", 50)
    STAT_SET_INT("GGSM_SCORE_5", 50)
    STAT_SET_INT("GGSM_SCORE_6", 50)
    STAT_SET_INT("GGSM_SCORE_7", 50)
    STAT_SET_INT("GGSM_SCORE_8", 50)
    STAT_SET_INT("GGSM_SCORE_9", 50)
    STAT_SET_INT("TWR_INITIALS_0", 69644)
    STAT_SET_INT("TWR_INITIALS_1", 69644)
    STAT_SET_INT("TWR_INITIALS_2", 69644)
    STAT_SET_INT("TWR_INITIALS_3", 69644)
    STAT_SET_INT("TWR_INITIALS_4", 69644)
    STAT_SET_INT("TWR_INITIALS_5", 69644)
    STAT_SET_INT("TWR_INITIALS_6", 69644)
    STAT_SET_INT("TWR_INITIALS_7", 69644)
    STAT_SET_INT("TWR_INITIALS_8", 69644)
    STAT_SET_INT("TWR_INITIALS_9", 69644)
    STAT_SET_INT("TWR_SCORE_0", 50)
    STAT_SET_INT("TWR_SCORE_1", 50)
    STAT_SET_INT("TWR_SCORE_2", 50)
    STAT_SET_INT("TWR_SCORE_3", 50)
    STAT_SET_INT("TWR_SCORE_4", 50)
    STAT_SET_INT("TWR_SCORE_5", 50)
    STAT_SET_INT("TWR_SCORE_6", 50)
    STAT_SET_INT("TWR_SCORE_7", 50)
    STAT_SET_INT("TWR_SCORE_8", 50)
    STAT_SET_INT("TWR_SCORE_9", 50)
    STAT_SET_BOOL("AWD_SCOPEOUT", true)
    STAT_SET_BOOL("AWD_CREWEDUP", true)
    STAT_SET_BOOL("AWD_MOVINGON", true)
    STAT_SET_BOOL("AWD_PROMOCAMP", true)
    STAT_SET_BOOL("AWD_GUNMAN", true)
    STAT_SET_BOOL("AWD_SMASHNGRAB", true)
    STAT_SET_BOOL("AWD_INPLAINSI", true)
    STAT_SET_BOOL("AWD_UNDETECTED", true)
    STAT_SET_BOOL("AWD_ALLROUND", true)
    STAT_SET_BOOL("AWD_ELITETHEIF", true)
    STAT_SET_BOOL("AWD_PRO", true)
    STAT_SET_BOOL("AWD_SUPPORTACT", true)
    STAT_SET_BOOL("AWD_SHAFTED", true)
    STAT_SET_BOOL("AWD_COLLECTOR", true)
    STAT_SET_BOOL("AWD_DEADEYE", true)
    STAT_SET_BOOL("AWD_PISTOLSATDAWN", true)
    STAT_SET_BOOL("AWD_TRAFFICAVOI", true)
    STAT_SET_BOOL("AWD_CANTCATCHBRA", true)
    STAT_SET_BOOL("AWD_WIZHARD", true)
    STAT_SET_BOOL("AWD_APEESCAP", true)
    STAT_SET_BOOL("AWD_MONKEYKIND", true)
    STAT_SET_BOOL("AWD_AQUAAPE", true)
    STAT_SET_BOOL("AWD_KEEPFAITH", true)
    STAT_SET_BOOL("AWD_TRUELOVE", true)
    STAT_SET_BOOL("AWD_NEMESIS", true)
    STAT_SET_BOOL("AWD_FRIENDZONED", true)
    STAT_SET_BOOL("IAP_CHALLENGE_0", true)
    STAT_SET_BOOL("IAP_CHALLENGE_1", true)
    STAT_SET_BOOL("IAP_CHALLENGE_2", true)
    STAT_SET_BOOL("IAP_CHALLENGE_3", true)
    STAT_SET_BOOL("IAP_CHALLENGE_4", true)
    STAT_SET_BOOL("IAP_GOLD_TANK", true)
    STAT_SET_BOOL("SCGW_WON_NO_DEATHS", true)
    SET_PACKED_INT_GLOBAL(28304, 28324, 1) -- 1380945288, -2029732713 (trajes)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Iate", {}, "", function()
    STAT_SET_INT("YACHT_MISSION_PROG", 0) --- missão do iate
    STAT_SET_INT("YACHT_MISSION_FLOW", 21845)
    STAT_SET_INT("CASINO_DECORATION_GIFT_1", -1)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Lamar", {}, "", function()
    STAT_SET_BOOL("LOW_FLOW_CS_DRV_SEEN", true) ---Lamar
    STAT_SET_BOOL("LOW_FLOW_CS_TRA_SEEN", true)
    STAT_SET_BOOL("LOW_FLOW_CS_FUN_SEEN", true)
    STAT_SET_BOOL("LOW_FLOW_CS_PHO_SEEN", true)
    STAT_SET_BOOL("LOW_FLOW_CS_FIN_SEEN", true)
    STAT_SET_BOOL("LOW_BEN_INTRO_CS_SEEN", true)
    STAT_SET_INT("LOWRIDER_FLOW_COMPLETE", 3)
    STAT_SET_INT("LOW_FLOW_CURRENT_PROG", 9)
    STAT_SET_INT("LOW_FLOW_CURRENT_CALL", 9)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "LSC 100%", {}, "Tudo da Los Santos Custom", function()
    STAT_SET_INT("CHAR_FM_CARMOD_3_UNLCK", -1) ---LSC
    STAT_SET_INT("CHAR_FM_CARMOD_4_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_5_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_6_UNLCK", -1)
    STAT_SET_INT("CHAR_FM_CARMOD_7_UNLCK", -1)
    STAT_SET_INT("AWD_FMRALLYWONDRIVE", 1)
    STAT_SET_INT("AWD_FMWINSEARACE", 1)
    STAT_SET_INT("AWD_FMWINAIRRACE", 1)
    STAT_SET_INT("NUMBER_TURBO_STARTS_IN_RACE", 50)
    STAT_SET_INT("USJS_FOUND", 50)
    STAT_SET_INT("USJS_COMPLETED", 50)
    STAT_SET_INT("RACES_WON", 50)
    STAT_SET_BOOL("MPPLY_TOTAL_RACES_WON", 50)
    STAT_SET_BOOL("MPPLY_TOTAL_RACES_LOST", 43)
    STAT_SET_INT("AWD_FM_RACES_FASTEST_LAP", 50)
    STAT_SET_INT("NUMBER_SLIPSTREAMS_IN_RACE", 100)
    STAT_SET_INT("AWD_WIN_CAPTURES 50", 50)
    STAT_SET_INT("AWD_DROPOFF_CAP_PACKAGES", 100)
    STAT_SET_INT("AWD_KILL_CARRIER_CAPTURE", 100)
    STAT_SET_INT("AWD_FINISH_HEISTS", 50)
    STAT_SET_INT("AWD_FINISH_HEIST_SETUP_JOB", 50)
    STAT_SET_INT("AWD_NIGHTVISION_KILLS", 100)
    STAT_SET_INT("AWD_WIN_LAST_TEAM_STANDINGS", 50)
    STAT_SET_INT("AWD_ONLY_PLAYER_ALIVE_LTS", 50)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Tatuagens 100%", {},
    "automaticamente seu personagem vai ficar com todas as tatuagens no corpo(BUGADAS) vá até o tatuador e as *REMOVA*!"
    ,
    function()
        STAT_SET_INT("ATTOO_FM_UNLOCKS_0", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_1", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_2", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_3", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_4", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_5", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_6", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_7", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_8", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_9", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_10", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_11", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_12", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_13", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_14", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_15", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_16", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_17", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_18", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_19", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_20", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_21", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_22", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_23", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_24", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_25", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_26", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_27", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_28", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_29", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_30", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_31", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_32", -1) ---tatuagem allien
        STAT_SET_INT("TATTOO_FM_UNLOCKS_33", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_34", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_35", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_36", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_37", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_38", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_39", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_40", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_41", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_42", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_43", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_44", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_45", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_46", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_47", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_0", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_1", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_2", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_3", -1)
        STAT_SET_INT("TATTOO_FM_UNLOCKS_4", -1)
        STAT_SET_INT("TATTOO_FM_VIEWED_0", -1)
        STAT_SET_INT("TATTOO_FM_VIEWED_1", -1)
        STAT_SET_INT("TATTOO_FM_VIEWED_2", -1)
        STAT_SET_INT("TATTOO_FM_VIEWED_3", -1)
        STAT_SET_INT("TATTOO_FM_VIEWED_4", -1)
        STAT_SET_INT("TATTOO_FM_CURRENT_0", -1)
        STAT_SET_INT("TATTOO_FM_CURRENT_1", -1)
        STAT_SET_INT("TATTOO_FM_CURRENT_2", -1)
        STAT_SET_INT("TATTOO_FM_CURRENT_3", -1)
        STAT_SET_INT("TATTOO_FM_CURRENT_5", -1)
        STAT_SET_INT("TOTAL_NO_SHOPS_HELD_UP", 20)
        STAT_SET_INT("AWD_HOLD_UP_SHOPS", 19) ---PALHAÇO COM DUAS ARMAS E DÓLARES
        STAT_SET_INT("AWD_HOLD_UP_SHOPS", 20) ---PALHAÇO E ARMA
        STAT_SET_INT("AWD_RACES_WON", 50) --- TATUAGEM MARIA GASOLINA
    end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "tatuagem Allien", {},
    "Lembrando que ela está na opção acima, use se ainda não a possuir!", function()
    STAT_SET_INT("TATTOO_FM_UNLOCKS_32", -1) ---tatuagem allien
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Tuners", {}, "", function()
    SET_PACKED_INT_GLOBAL(31175, 31197, 1) -- -1888532800, 842355026( tuners dlc)
    SET_PACKED_INT_GLOBAL(31007, 31013, 1) -- -1578784326, -1342847946
    SET_INT_GLOBAL(2870055, 1) -- freemode.c, STREAMING::REMOVE_ANIM_DICT("MP_WEAPON_DROP");
    STAT_SET_INT("AWD_CAR_CLUB_MEM", 100)
    STAT_SET_INT("AWD_SPRINTRACER", 50)
    STAT_SET_INT("AWD_STREETRACER", 50)
    STAT_SET_INT("AWD_PURSUITRACER", 50)
    STAT_SET_INT("AWD_TEST_CAR", 240)
    STAT_SET_INT("AWD_AUTO_SHOP", 50)
    STAT_SET_INT("AWD_CAR_EXPORT", 100)
    STAT_SET_INT("AWD_GROUNDWORK", 40)
    STAT_SET_INT("AWD_ROBBERY_CONTRACT", 100)
    STAT_SET_INT("AWD_FACES_OF_DEATH", 100)
    STAT_SET_BOOL("AWD_CAR_CLUB", true)
    STAT_SET_BOOL("AWD_PRO_CAR_EXPORT", true)
    STAT_SET_BOOL("AWD_UNION_DEPOSITORY", true)
    STAT_SET_BOOL("AWD_MILITARY_CONVOY", true)
    STAT_SET_BOOL("AWD_FLEECA_BANK", true)
    STAT_SET_BOOL("AWD_FREIGHT_TRAIN", true)
    STAT_SET_BOOL("AWD_BOLINGBROKE_ASS", true)
    STAT_SET_BOOL("AWD_IAA_RAID", true)
    STAT_SET_BOOL("AWD_METH_JOB", true)
    STAT_SET_BOOL("AWD_BUNKER_RAID", true)
    STAT_SET_BOOL("AWD_STRAIGHT_TO_VIDEO", true)
    STAT_SET_BOOL("AWD_MONKEY_C_MONKEY_DO", true)
    STAT_SET_BOOL("AWD_TRAINED_TO_KILL", true)
    STAT_SET_BOOL("AWD_DIRECTOR", true) --- premios
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Vanilla Unicorn", {}, "", function()
    STAT_SET_INT("LAP_DANCED_BOUGHT", 0) ---Vanilla Unicorn
    STAT_SET_INT("LAP_DANCED_BOUGHT", 5)
    STAT_SET_INT("LAP_DANCED_BOUGHT", 10)
    STAT_SET_INT("LAP_DANCED_BOUGHT", 15)
    STAT_SET_INT("LAP_DANCED_BOUGHT", 25)
    STAT_SET_INT("PROSTITUTES_FREQUENTED", 1000)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Sintonizadores desbloqueiam o gatilho", {}, "Observação", function()
    SET_INT_GLOBAL(262145 + 28755, 1);
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "Multiplicadores LS Car Meet", {}, "", function()
    SET_INT_GLOBAL(262145 + 31636, 1); ----	Street Race
    SET_INT_GLOBAL(262145 + 31637, 1); ---	Pursuit Race
    SET_INT_GLOBAL(262145 + 31638, 1); ---	Scramble
    SET_INT_GLOBAL(262145 + 31639, 1); ---	Head 2 Head
    SET_INT_GLOBAL(262145 + 31641, 1); ---	LS Car Meet
    SET_INT_GLOBAL(262145 + 31642, 1); ---	LS Car Meet Track
    SET_INT_GLOBAL(262145 + 31643, 1); ---LS Car Meet ("Cloth Shop
    SET_INT_GLOBAL(262145 + 31669, 1); ---	Auto Shop Contract Setup
    SET_INT_GLOBAL(262145 + 31670, 1); ---Auto Shop Contract Finale
    SET_INT_GLOBAL(262145 + 31671, 1); ---	Auto Shop Car Delivery
    SET_INT_GLOBAL(262145 + 31672, 1); ---Exotic Export Delivery
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_PARTE, "presentes + itens", {}, "", function()
    SET_INT_GLOBAL(262145 + 9184, 1); ---- 2014_christmas_day_gift: ex("clusive stocking mask, firework launcher, etc.
    SET_INT_GLOBAL(262145 + 9448, 1); ---- 2014_christmas_eve_gift: firework launcher + 5 fireworks
    SET_INT_GLOBAL(262145 + 9449, 1); ---- 2014_new_years_eve_gift: firework launcher + 5 fireworks
    SET_INT_GLOBAL(262145 + 9450, 1); ---- 2014_new_years_day_gift: firework launcher + 5 fireworks
    SET_INT_GLOBAL(262145 + 12707, 1); ---- "XMAS2015_VEHI("CLE"
    SET_INT_GLOBAL(262145 + 23440, 1); ---- full armor (holiday)
    SET_INT_GLOBAL(262145 + 23441, 1); ---- full sticky bombs (holiday)
    SET_INT_GLOBAL(262145 + 23442, 1); ---- full snacks (holiday)
    SET_INT_GLOBAL(262145 + 23443, 1); ---- full ammo (holiday)
    SET_INT_GLOBAL(262145 + 23972, 1); ---- Free RC Tank or idk what is this (-1029230616 hash from tuneables processing.c)
end)
------------------------------------------------------------------------------------------------------------------------------
menu.toggle_loop(UNLOCK_PARTE, "itens gratuitos", {}, "clique natal/buzzard/insurgent", function()
    SET_INT_GLOBAL(262145 + 25822, 1); ---- Free Vapid ("Clique with Merry ("Cliquemas
    SET_INT_GLOBAL(262145 + 25823, 1); ---- Free Nagasaki Buzzard Attack Chopper
    SET_INT_GLOBAL(262145 + 25824, 1); ---- Free HVY Insurgent Pick-Up
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DATAS, "2015", {}, "", function()
    SET_INT_GLOBAL(262145 + 12813, 1); ---- 2015_christmas_eve_gift: fireworks launcher, fireworks
    SET_INT_GLOBAL(262145 + 12814, 1); ---- 2015_new_years_eve_gift: fireworks launcher, fireworks
    SET_INT_GLOBAL(262145 + 12815, 1); ---- 2015_new_years_day_gift: fireworks launcher, fireworks
    SET_INT_GLOBAL(262145 + 12816, 1); ---- 2015_christmas_day_gift: abominable snowman mask, set of pajamas, naughty cap, etc.
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DATAS, "2016", {}, "", function()
    SET_INT_GLOBAL(262145 + 19160, 1); ---- 2016_christmas_eve_gift
    SET_INT_GLOBAL(262145 + 19161, 1); ---- 2016_new_years_eve_gift
    SET_INT_GLOBAL(262145 + 19162, 1); ---- 2016_new_years_day_gift
    SET_INT_GLOBAL(262145 + 19163, 1); ---- 2016_christmas_day_gift
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DATAS, "2017", {}, "", function()
    SET_INT_GLOBAL(262145 + 23462, 1); ---- 2017 christmas eve gift: odious krampus mask, black ammu-nation hoodie, etc.
    SET_INT_GLOBAL(262145 + 23463, 1); ---- 2017_new_years_eve_gift: hideous krampus mask, vivisection t-shirt, etc.
    SET_INT_GLOBAL(262145 + 23464, 1); ---- 2017_new_years_day_gift: fearsome krampus mask, fake dix white t-shirt,etc.
    SET_INT_GLOBAL(262145 + 23465, 1); ---- 2017_christmas_day_gift: heinous krampus mask, one free albany hermes, etc.
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DATAS, "2018", {}, "", function()
    SET_INT_GLOBAL(262145 + 25826, 1); ---- 2018_christmas_eve_gift: black & white bones festive sweater, firework launcher, etc.
    SET_INT_GLOBAL(262145 + 25827, 1); ---- 2018_new_years_eve_gift: black & red bones festive sweater,one free hvy insurgent pick-up,etc.
    SET_INT_GLOBAL(262145 + 25828, 1); ---- 2018_new_years_day_gift: red bones festive sweater, firework launcher, etc.
    SET_INT_GLOBAL(262145 + 25829, 1); ---- 2018_christmas_day_gift: slasher festive sweater, one free vapid ("clique, up-n-atomizer,etc.
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DATAS, "2019", {}, "", function()
    SET_INT_GLOBAL(262145 + 28678, 1); ---- 2019_christmas_eve_gift: green reindeer lights bodysuit, firework launcher, etc.
    SET_INT_GLOBAL(262145 + 28679, 1); ---- 2019_new_years_eve_gift: yellow reindeer lights bodysuit, firework launcher, etc.
    SET_INT_GLOBAL(262145 + 28680, 1); ---- 2019_new_years_day_gift: neon festive lights bodysuit, firework launcher, etc.
    SET_INT_GLOBAL(262145 + 28681, 1); ---- 2019_christmas_day_gift: minigun sweater,festive lights bodysuit,firework launcher,etc.
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DATAS, "2020", {}, "", function()
    SET_INT_GLOBAL(262145 + 30890, 1); ---- 2020_christmas_eve_gift: vibrant stitch emissive mask, firework launcher, etc.
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_DATAS, "2021", {}, "", function()
    SET_INT_GLOBAL(262145 + 31744, 1); ---- 2021_christmas_day_gift:
    SET_INT_GLOBAL(262145 + 31745, 1); ---- 2021_new_years_day_gift:
end)
------------------------------------------------------------------------------------------------------------------------------
local UNLOCK_ROUPAS = menu.list(UNLOCK_ALL, "Desbloqueios de Roupas", { "" },
    "Todas as roupas possíveis do jogo, não esqueça de ter paciencia!", function()

end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Desbloquear todas as Roupas", {}, "", function()
    ---sapatos
    SET_INT_GLOBAL(262145 + 32924, 1); ---- Wild Striped Pool Sliders
    SET_INT_GLOBAL(262145 + 32925, 1); ---- Neon Striped Pool Sliders
    SET_INT_GLOBAL(262145 + 32926, 1); ---- Black SC Coin Pool Sliders
    SET_INT_GLOBAL(262145 + 32927, 1); ---- White SC Coin Pool Sliders
    SET_INT_GLOBAL(262145 + 32928, 1); ---- Black SC Pattern Pool Sliders
    SET_INT_GLOBAL(262145 + 32929, 1); ---- Pink SC Pattern Pool Sliders
    SET_INT_GLOBAL(262145 + 32930, 1); ---- Blue SC Pattern Pool Sliders
    SET_INT_GLOBAL(262145 + 32931, 1); ---- Camo Yeti Pool Sliders
    SET_INT_GLOBAL(262145 + 32932, 1); ---- Grey Camo Yeti Pool Sliders
    SET_INT_GLOBAL(262145 + 32933, 1); ---- Black Bigness Pool Sliders
    SET_INT_GLOBAL(262145 + 32934, 1); ---- Purple Bigness Pool Sliders
    SET_INT_GLOBAL(262145 + 32935, 1); ---- Camo Bigness Pool Sliders
    SET_INT_GLOBAL(262145 + 32936, 1); ---- Black Blaguers Pool Sliders
    SET_INT_GLOBAL(262145 + 32937, 1); ---- White Blaguers Pool Sliders
    SET_INT_GLOBAL(262145 + 32938, 1); ---- Pink Blaguers Pool Sliders
    SET_INT_GLOBAL(262145 + 32939, 1); ---- Grey Cimicino Pool Sliders
    SET_INT_GLOBAL(262145 + 32940, 1); ---- Rouge Cimicino Pool Sliders
    SET_INT_GLOBAL(262145 + 32941, 1); ---- Navy DS Pool Sliders
    SET_INT_GLOBAL(262145 + 32942, 1); ---- Red DS Pool Sliders
    SET_INT_GLOBAL(262145 + 32943, 1); ---- Floral Guffy Pool Sliders
    SET_INT_GLOBAL(262145 + 32944, 1); ---- Green Guffy Pool Sliders
    SET_INT_GLOBAL(262145 + 32945, 1); ---- White Guffy Pool Sliders
    SET_INT_GLOBAL(262145 + 32946, 1); ---- Blue Heat Pool Sliders
    SET_INT_GLOBAL(262145 + 32947, 1); ---- Red ProLaps Pool Sliders

    ---sasquatch
    SET_INT_GLOBAL(262145 + 32848, 1); ---- Sasquatch

    ---camisas arcade
    SET_INT_GLOBAL(262145 + 28304, 1); ---- "Street Crimes Boxart Tee"
    SET_INT_GLOBAL(262145 + 28305, 1); ---- "Street Crimes Logo Tee"
    SET_INT_GLOBAL(262145 + 28306, 1); ---- "("Claim What's Yours Tee"
    SET_INT_GLOBAL(262145 + 28307, 1); ---- "Choose Your Side Tee"
    SET_INT_GLOBAL(262145 + 28308, 1); ---- "Street Crimes Color Gangs Tee"
    SET_INT_GLOBAL(262145 + 28309, 1); ---- "Street Crimes Red Gangs Tee"
    SET_INT_GLOBAL(262145 + 28310, 1); ---- "White Street Crimes Icons Tee"
    SET_INT_GLOBAL(262145 + 28311, 1); ---- "Black Street Crimes Icons Tee"
    SET_INT_GLOBAL(262145 + 28312, 1); ---- "Invade and Persuade Logo Tee"
    SET_INT_GLOBAL(262145 + 28313, 1); ---- "Mission I Tee"
    SET_INT_GLOBAL(262145 + 28314, 1); ---- "Mission II Tee"
    SET_INT_GLOBAL(262145 + 28315, 1); ---- "Mission IV Tee"
    SET_INT_GLOBAL(262145 + 28316, 1); ---- "Mission III Tee"
    SET_INT_GLOBAL(262145 + 28317, 1); ---- "Invade and Persuade Boxart Tee"
    SET_INT_GLOBAL(262145 + 28318, 1); ---- "Invade and Persuade Invader Tee"
    SET_INT_GLOBAL(262145 + 28319, 1); ---- "Invade and Persuade Suck Tee"
    SET_INT_GLOBAL(262145 + 28320, 1); ---- "Invade and Persuade Jets Tee"
    SET_INT_GLOBAL(262145 + 28321, 1); ---- "Invade and Persuade Gold Tee"
    SET_INT_GLOBAL(262145 + 28322, 1); ---- "Invade and Persuade Hero Tee"
    SET_INT_GLOBAL(262145 + 28323, 1); ---- "Invade and Persuade Barrels Tee"

    ---camisas cassino
    SET_INT_GLOBAL(262145 + 27015, 1); ---- "The Diamond ("Classics Tee"
    SET_INT_GLOBAL(262145 + 27016, 1); ---- "The Diamond Vintage Tee"
    SET_INT_GLOBAL(262145 + 27017, 1); ---- "Red The Diamond Resort LS Tee"
    SET_INT_GLOBAL(262145 + 27018, 1); ---- "Blue The Diamond Resort LS Tee"
    SET_INT_GLOBAL(262145 + 27019, 1); ---- "Red The Diamond Resort Tee"
    SET_INT_GLOBAL(262145 + 27020, 1); ---- "Blue D Casino Tee"
    SET_INT_GLOBAL(262145 + 27021, 1); ---- "Red The Diamond ("Classic Tee"

    ---camisola Festiva
    SET_INT_GLOBAL(262145 + 25898, 1); ---- "Burger Shot Festive Sweater"
    SET_INT_GLOBAL(262145 + 25899, 1); ---- "Red Bleeder Festive Sweater"
    SET_INT_GLOBAL(262145 + 25900, 1); ---- "Blue Bleeder Festive Sweater"
    SET_INT_GLOBAL(262145 + 25901, 1); ---- "Blue ("Cluckin' Festive Sweater"
    SET_INT_GLOBAL(262145 + 25902, 1); ---- "Green ("Cluckin' Festive Sweater"
    SET_INT_GLOBAL(262145 + 25903, 1); ---- "Blue Slaying Festive Sweater"
    SET_INT_GLOBAL(262145 + 25904, 1); ---- "Green Slaying Festive Sweater"
    SET_INT_GLOBAL(262145 + 25905, 1); ---- "Hail Santa Festive Sweater"
    SET_INT_GLOBAL(262145 + 25906, 1); ---- "Merrry Sprunkmas Festive Sweater"
    SET_INT_GLOBAL(262145 + 25907, 1); ---- "Ice Cold Sprunk Festive Sweater"

    ---Fabricante de Camisas
    SET_INT_GLOBAL(262145 + 25830, 1); ---- "Albany Tee"
    SET_INT_GLOBAL(262145 + 25831, 1); ---- "Albany Vintage Tee"
    SET_INT_GLOBAL(262145 + 25832, 1); ---- "Annis Tee"
    SET_INT_GLOBAL(262145 + 25833, 1); ---- "Benefector Tee"
    SET_INT_GLOBAL(262145 + 25834, 1); ---- "BF Tee"
    SET_INT_GLOBAL(262145 + 25835, 1); ---- "Bollokan Tee"
    SET_INT_GLOBAL(262145 + 25836, 1); ---- "Bravado Tee"
    SET_INT_GLOBAL(262145 + 25837, 1); ---- "Brute Tee"
    SET_INT_GLOBAL(262145 + 25838, 1); ---- "Buckingham Tee"
    SET_INT_GLOBAL(262145 + 25839, 1); ---- "Canis Tee"
    SET_INT_GLOBAL(262145 + 25840, 1); ---- "Chariot Tee"
    SET_INT_GLOBAL(262145 + 25841, 1); ---- "Cheval Tee"
    SET_INT_GLOBAL(262145 + 25842, 1); ---- "("Classigue Tee"
    SET_INT_GLOBAL(262145 + 25843, 1); ---- "Coil Tee"
    SET_INT_GLOBAL(262145 + 25844, 1); ---- "De("classe Tee"
    SET_INT_GLOBAL(262145 + 25845, 1); ---- "Dewbauchee Tee"
    SET_INT_GLOBAL(262145 + 25846, 1); ---- "Dilettante Tee"
    SET_INT_GLOBAL(262145 + 25847, 1); ---- "Dinka Tee"
    SET_INT_GLOBAL(262145 + 25848, 1); ---- "Dundreary Tee"
    SET_INT_GLOBAL(262145 + 25849, 1); ---- "Emperor Tee"
    SET_INT_GLOBAL(262145 + 25850, 1); ---- "Enus Tee"
    SET_INT_GLOBAL(262145 + 25851, 1); ---- "Fathom Tee"
    SET_INT_GLOBAL(262145 + 25852, 1); ---- "Gallivanter Tee"
    SET_INT_GLOBAL(262145 + 25853, 1); ---- "Grotti Tee"
    SET_INT_GLOBAL(262145 + 25854, 1); ---- "Hijak Tee"
    SET_INT_GLOBAL(262145 + 25855, 1); ---- "HVT Tee"
    SET_INT_GLOBAL(262145 + 25856, 1); ---- "Imponte Tee"
    SET_INT_GLOBAL(262145 + 25857, 1); ---- "Invetero Tee"
    SET_INT_GLOBAL(262145 + 25858, 1); ---- "Jobuilt Tee"
    SET_INT_GLOBAL(262145 + 25859, 1); ---- "Karin Tee"
    SET_INT_GLOBAL(262145 + 25860, 1); ---- "Lampadati Tee"
    SET_INT_GLOBAL(262145 + 25861, 1); ---- "Maibatsu Tee"
    SET_INT_GLOBAL(262145 + 25862, 1); ---- "Mamba Tee"
    SET_INT_GLOBAL(262145 + 25863, 1); ---- "Mammoth Tee"
    SET_INT_GLOBAL(262145 + 25864, 1); ---- "MTL Tee"
    SET_INT_GLOBAL(262145 + 25865, 1); ---- "Obey Tee"
    SET_INT_GLOBAL(262145 + 25866, 1); ---- "Ocelot Tee"
    SET_INT_GLOBAL(262145 + 25867, 1); ---- "Overflod Tee"
    SET_INT_GLOBAL(262145 + 25868, 1); ---- "Pegassi Tee"
    SET_INT_GLOBAL(262145 + 25869, 1); ---- "Pfister Tee"
    SET_INT_GLOBAL(262145 + 25870, 1); ---- "Progen Tee"
    SET_INT_GLOBAL(262145 + 25871, 1); ---- "Rune Tee"
    SET_INT_GLOBAL(262145 + 25872, 1); ---- "Schyster Tee"
    SET_INT_GLOBAL(262145 + 25873, 1); ---- "Shitzu Tee"
    SET_INT_GLOBAL(262145 + 25874, 1); ---- "Truffade Tee"
    SET_INT_GLOBAL(262145 + 25875, 1); ---- "Ubermacht Tee"
    SET_INT_GLOBAL(262145 + 25876, 1); ---- "Vapid Tee"
    SET_INT_GLOBAL(262145 + 25877, 1); ---- "Vulcar Tee"
    SET_INT_GLOBAL(262145 + 25878, 1); ---- "Weeny Tee"
    SET_INT_GLOBAL(262145 + 25879, 1); ---- "Willard Tee"
    SET_INT_GLOBAL(262145 + 25880, 1); ---- "Albany Nostalgia Tee"
    SET_INT_GLOBAL(262145 + 25881, 1); ---- "Albany USA Tee"
    SET_INT_GLOBAL(262145 + 25882, 1); ---- "Albany Dealership Tee"
    SET_INT_GLOBAL(262145 + 25883, 1); ---- "Annis JPN Tee"
    SET_INT_GLOBAL(262145 + 25884, 1); ---- "BF Surfer Tee"
    SET_INT_GLOBAL(262145 + 25885, 1); ---- "Bollokan Prairie Tee"
    SET_INT_GLOBAL(262145 + 25886, 1); ---- "Bravado Stylized Tee"
    SET_INT_GLOBAL(262145 + 25887, 1); ---- "Brute Impregnable Tee"
    SET_INT_GLOBAL(262145 + 25888, 1); ---- "Brute Heavy Duty Tee"
    SET_INT_GLOBAL(262145 + 25889, 1); ---- "Buckingham Luxe Tee"
    SET_INT_GLOBAL(262145 + 25890, 1); ---- "Canis USA Tee"
    SET_INT_GLOBAL(262145 + 25891, 1); ---- "Canis American Legend Tee"
    SET_INT_GLOBAL(262145 + 25892, 1); ---- "Canis Wolf Tee"
    SET_INT_GLOBAL(262145 + 25893, 1); ---- "Cheval Marshall Tee"
    SET_INT_GLOBAL(262145 + 25894, 1); ---- "Coil USA Tee"
    SET_INT_GLOBAL(262145 + 25895, 1); ---- "Coil Raiden Tee"
    SET_INT_GLOBAL(262145 + 25896, 1); ---- "De("classe Logo Tee"
    SET_INT_GLOBAL(262145 + 25897, 1); ---- "De("classe Girl Tee
    SET_INT_GLOBAL(262145 + 15222, 1); ---- "Grotti Shirt"
    SET_INT_GLOBAL(262145 + 17580, 1); ---- "Western Brand White Tee"
    SET_INT_GLOBAL(262145 + 17581, 1); ---- "Western Brand Black Tee"
    SET_INT_GLOBAL(262145 + 17582, 1); ---- "Western Logo White Tee"
    SET_INT_GLOBAL(262145 + 17583, 1); ---- "Western Logo Black Tee"
    SET_INT_GLOBAL(262145 + 17584, 1); ---- "Steel Horse Solid Logo Tee"
    SET_INT_GLOBAL(262145 + 17585, 1); ---- "Steel Horse Logo Tee"
    SET_INT_GLOBAL(262145 + 17586, 1); ---- "Steel Horse Brand White Tee"
    SET_INT_GLOBAL(262145 + 17587, 1); ---- "Steel Horse Brand Black Tee"
    SET_INT_GLOBAL(262145 + 17588, 1); ---- "Nagasaki White Tee"
    SET_INT_GLOBAL(262145 + 17589, 1); ---- "Nagasaki White And Red Tee"
    SET_INT_GLOBAL(262145 + 17590, 1); ---- "Nagasaki Black Tee"
    SET_INT_GLOBAL(262145 + 17591, 1); ---- "Purple Helmets Black Tee"
    SET_INT_GLOBAL(262145 + 17592, 1); ---- "Principe Black Tee"
    SET_INT_GLOBAL(262145 + 17593, 1); ---- "Steel Horse Black Hoodie"
    SET_INT_GLOBAL(262145 + 17594, 1); ---- "Steel Horse White Hoodie"
    SET_INT_GLOBAL(262145 + 17595, 1); ---- "Western Black Hoodie"
    SET_INT_GLOBAL(262145 + 17596, 1); ---- "Western White Hoodie"
    SET_INT_GLOBAL(262145 + 17597, 1); ---- "Nagasaki White Hoodie"
    SET_INT_GLOBAL(262145 + 17598, 1); ---- "Nagasaki White And Red Hoodie"
    SET_INT_GLOBAL(262145 + 17599, 1); ---- "Nagasaki Black Hoodie"
    SET_INT_GLOBAL(262145 + 17600, 1); ---- "Purple Helmets Black Hoodie"
    SET_INT_GLOBAL(262145 + 17601, 1); ---- "Principe Hoodie Black"

    ---Fatos de Dublês
    SET_INT_GLOBAL(262145 + 16839, 1); ---- "White Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16840, 1); ---- "Blue Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16841, 1); ---- "Red Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16842, 1); ---- "Gold Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16843, 1); ---- "Black Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16844, 1); ---- "Pink Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16845, 1); ---- "Silver Jock Cranley Suit"

    ---Bodysuits Wireframe
    SET_INT_GLOBAL(262145 + 23435, 1); ---- "Green Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23436, 1); ---- "Orange Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23437, 1); ---- "Blue Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23438, 1); ---- "Pink Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23439, 1); ---- "Yellow Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23435, 1); ---- Bodysuit Green
    SET_INT_GLOBAL(262145 + 23436, 1); ---- Bodysuit Orange
    SET_INT_GLOBAL(262145 + 23437, 1); ---- Bodysuit Blue
    SET_INT_GLOBAL(262145 + 23438, 1); ---- Bodysuit Pink
    SET_INT_GLOBAL(262145 + 23439, 1); ---- Bodysuit Yellow

    ----camisas
    SET_INT_GLOBAL(262145 + 21155, 1); ---- "BLACK_AMMUNATION_TEE"
    SET_INT_GLOBAL(262145 + 21157, 1); ---- "BLACK_COIL_TEE"
    SET_INT_GLOBAL(262145 + 21159, 1); ---- "BLACK_HAWK_AND_LITTLE_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21160, 1); ---- "BLACK_HAWK_AND_LITTLE_TEE"
    SET_INT_GLOBAL(262145 + 21164, 1); ---- "GREEN_VOM_FEUER_TEE"
    SET_INT_GLOBAL(262145 + 21167, 1); ---- "WHITE_AMMUNATION_TEE"
    SET_INT_GLOBAL(262145 + 21169, 1); ---- "WHITE_COIL_TEE"
    SET_INT_GLOBAL(262145 + 21171, 1); ---- "WHITE_HAWK_AND_LITTLE_TEE"
    SET_INT_GLOBAL(262145 + 21172, 1); ---- "WHITE_SHREWSBURY_TEE"
    SET_INT_GLOBAL(262145 + 21175, 1); ---- "WHITE_SHREWSBURY_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21179, 1); ---- "YELLOW_VOM_FEUER_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21180, 1); ---- "YELLOW_VOM_FEUER_TEE"
    SET_INT_GLOBAL(262145 + 21181, 1); ---- "YELLOW_WARSTOCK_TEE"
    SET_INT_GLOBAL(262145 + 21182, 1); ---- "BLUE_R*_("CLASS_OF_98"
    SET_INT_GLOBAL(262145 + 21183, 1); ---- "RED_R*_("CLASS_OF_98"
    SET_INT_GLOBAL(262145 + 21184, 1); ---- "NOISE_ROCKSTAR_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21185, 1); ---- "NOISE_TEE"
    SET_INT_GLOBAL(262145 + 21186, 1); ---- "RAZOR_TEE"
    SET_INT_GLOBAL(262145 + 21187, 1); ---- "BLACK_ROCKSTAR_CAMO"
    SET_INT_GLOBAL(262145 + 21188, 1); ---- "WHITE_ROCKSTAR_CAMO"
    SET_INT_GLOBAL(262145 + 21189, 1); ---- "KNUCKLEDUSTER_POCKET_TEE"
    SET_INT_GLOBAL(262145 + 21190, 1); ---- "ROCKSTAR_LOGO_BLACKED_OUT_TEE"
    SET_INT_GLOBAL(262145 + 21191, 1); ---- "ROCKSTAR_LOGO_WHITE_OUT_TEE"
    SET_INT_GLOBAL(262145 + 25698, 1); ---- "Kifflom Tee"

    ---Moletons
    SET_INT_GLOBAL(262145 + 21154, 1); ---- "BLACK_AMMUNATION_HOODIE"
    SET_INT_GLOBAL(262145 + 21158, 1); ---- "BLACK_HAWK_AND_LITTLE_HODDIE"
    SET_INT_GLOBAL(262145 + 21161, 1); ---- "BLACK_SHREWSBURY_HOODIE"
    SET_INT_GLOBAL(262145 + 21163, 1); ---- "BLACK_WARSTOCK_HOODIE"
    SET_INT_GLOBAL(262145 + 21168, 1); ---- "WHITE_COIL_HOODIE"
    SET_INT_GLOBAL(262145 + 21170, 1); ---- "WHITE_HAWK_AND_LITTLE_HOODIE"
    SET_INT_GLOBAL(262145 + 21174, 1); ---- "WHITE_SHREWSBURY_HOODIE"
    SET_INT_GLOBAL(262145 + 21177, 1); ---- "WHITE_VOM_FEUER_HOODIE"

    ---Camisetas dos ("clubes
    SET_INT_GLOBAL(262145 + 24732, 1); ---- "Maisonette Los Santos T-Shirt"
    SET_INT_GLOBAL(262145 + 24733, 1); ---- "Studio Los Santos T-Shirt"
    SET_INT_GLOBAL(262145 + 24734, 1); ---- "Galaxy T-Shirt"
    SET_INT_GLOBAL(262145 + 24735, 1); ---- "Gefängnis T-Shirt"
    SET_INT_GLOBAL(262145 + 24736, 1); ---- "Omega T-Shirt"
    SET_INT_GLOBAL(262145 + 24737, 1); ---- "Technologie T-Shirt"
    SET_INT_GLOBAL(262145 + 24738, 1); ---- "Paradise T-Shirt"
    SET_INT_GLOBAL(262145 + 24739, 1); ---- "The Palace T-Shirt"
    SET_INT_GLOBAL(262145 + 24740, 1); ---- "Tony's Fun House T-Shirt"

    ---camisas de filme
    SET_INT_GLOBAL(262145 + 11952, 1); ---- "MELTDOWN"
    SET_INT_GLOBAL(262145 + 11953, 1); ---- "VINEWOOD_ZOMBIE"
    SET_INT_GLOBAL(262145 + 11954, 1); ---- "I_MARRIED_MY_DAD"
    SET_INT_GLOBAL(262145 + 11955, 1); ---- "DIE_ALREADY_4"
    SET_INT_GLOBAL(262145 + 11956, 1); ---- "THE_SHOULDER_OF_ORION_II"
    SET_INT_GLOBAL(262145 + 11957, 1); ---- "NELSON_IN_NAPLES"
    SET_INT_GLOBAL(262145 + 11958, 1); ---- "THE_MANY_WIVES_OF_ALFREDO_SMITH"
    SET_INT_GLOBAL(262145 + 11959, 1); ---- "AN_AMERICAN_DIVORCE"
    SET_INT_GLOBAL(262145 + 11960, 1); ---- "THE_LONELIEST_ROBOT"
    SET_INT_GLOBAL(262145 + 11961, 1); ---- "CAPOLAVORO"
    SET_INT_GLOBAL(262145 + 12598, 1); ---- "Vinewood Zombie Shirt"
    SET_INT_GLOBAL(262145 + 12599, 1); ---- "Knife After Dark Shirt"
    SET_INT_GLOBAL(262145 + 12600, 1); ---- "The Simian Shirt"
    SET_INT_GLOBAL(262145 + 12601, 1); ---- "Zombie Liberals In The Midwest Shirt"
    SET_INT_GLOBAL(262145 + 12602, 1); ---- "Twilight Knife Shirt"
    SET_INT_GLOBAL(262145 + 12603, 1); ---- "Butchery and Other Hobbies Shirt"
    SET_INT_GLOBAL(262145 + 12604, 1); ---- "Cheerleader Massacre 3 Shirt"
    SET_INT_GLOBAL(262145 + 12605, 1); ---- "Cannibal ("Clown Shirt"
    SET_INT_GLOBAL(262145 + 12606, 1); ---- "Hot Serial Killer Stepmom Shirt"
    SET_INT_GLOBAL(262145 + 12607, 1); ---- "Splatter And Shot Shirt"
    SET_INT_GLOBAL(262145 + 12608, 1); ---- "Meathook For Mommy Shirt"
    SET_INT_GLOBAL(262145 + 12609, 1); ---- "Psycho Swingers Shirt"
    SET_INT_GLOBAL(262145 + 12610, 1); ---- "Vampires On The Beach Shirt"
    SET_INT_GLOBAL(262145 + 15226, 1); ---- "Meltdown Shirt"

    --- knock offs
    SET_INT_GLOBAL(262145 + 24249, 1); ---- "Fake Perseus T-Shirt"
    SET_INT_GLOBAL(262145 + 24250, 1); ---- "Fake Santo Capra T-Shirt"
    SET_INT_GLOBAL(262145 + 24251, 1); ---- "Fake Dix White T-Shirt"
    SET_INT_GLOBAL(262145 + 24252, 1); ---- "Fake Le Chien Crew T-Shirt"
    SET_INT_GLOBAL(262145 + 24253, 1); ---- "Fake Enema T-Shirt"
    SET_INT_GLOBAL(262145 + 24254, 1); ---- "Fake Dix Gold T-Shirt"
    SET_INT_GLOBAL(262145 + 24255, 1); ---- "Fake Le Chien No2 T-Shirt"
    SET_INT_GLOBAL(262145 + 24256, 1); ---- "Fake Seesanta Nove T-Shirt"
    SET_INT_GLOBAL(262145 + 24257, 1); ---- "Fake Didier Sachs T-Shirt"
    SET_INT_GLOBAL(262145 + 24258, 1); ---- "Fake Vapid T-Shirt"

    ---Camisas de Marcas
    SET_INT_GLOBAL(262145 + 15219, 1); ---- "Accountant Shirt"
    SET_INT_GLOBAL(262145 + 15220, 1); ---- "Bahamamamas Shirt"
    SET_INT_GLOBAL(262145 + 15221, 1); ---- "Drone Shirt"
    SET_INT_GLOBAL(262145 + 15223, 1); ---- "Golf Shirt"
    SET_INT_GLOBAL(262145 + 15224, 1); ---- "Maisonette Shirt"
    SET_INT_GLOBAL(262145 + 15225, 1); ---- "Manopause Shirt"
    SET_INT_GLOBAL(262145 + 15227, 1); ---- "Pacific Bluffs Shirt"
    SET_INT_GLOBAL(262145 + 15228, 1); ---- "Prolaps Shirt"
    SET_INT_GLOBAL(262145 + 15229, 1); ---- "Tennis Shirt"
    SET_INT_GLOBAL(262145 + 15230, 1); ---- "Toe Shirt"
    SET_INT_GLOBAL(262145 + 15231, 1); ---- "Vanilla Unicorn Shirt"
    SET_INT_GLOBAL(262145 + 15232, 1); ---- "Marlowe Shirt"
    SET_INT_GLOBAL(262145 + 15233, 1); ---- "Crest Shirt"
    SET_INT_GLOBAL(262145 + 24233, 1); ---- "Crocs Bar T-Shirt"
    SET_INT_GLOBAL(262145 + 24234, 1); ---- "Base5 T-Shirt"
    SET_INT_GLOBAL(262145 + 24235, 1); ---- "BOBO T-Shirt"
    SET_INT_GLOBAL(262145 + 24236, 1); ---- "Bitch'n'Dog T-Shirt"
    SET_INT_GLOBAL(262145 + 24238, 1); ---- "Vivisection T-Shirt"
    SET_INT_GLOBAL(262145 + 24241, 1); ---- "Vinyl Countdown T-Shirt"
    SET_INT_GLOBAL(262145 + 24243, 1); ---- "Victory Fist T-Shirt"
    SET_INT_GLOBAL(262145 + 24246, 1); ---- "Homie Sharp T-Shirt"
    SET_INT_GLOBAL(262145 + 8302, 1); ---- "Statue of Happiness T-shirt"

    ---chapeus
    SET_INT_GLOBAL(262145 + 12588, 1); ---- "Magnetics Script Hat"
    SET_INT_GLOBAL(262145 + 12589, 1); ---- "Magnetics Block Hat"
    SET_INT_GLOBAL(262145 + 12590, 1); ---- "Los Santos Hat"
    SET_INT_GLOBAL(262145 + 12591, 1); ---- "Boars Hat"
    SET_INT_GLOBAL(262145 + 12592, 1); ---- "Benny's Hat"
    SET_INT_GLOBAL(262145 + 12593, 1); ---- "Westside Hat"
    SET_INT_GLOBAL(262145 + 12594, 1); ---- "Eastside Hat"
    SET_INT_GLOBAL(262145 + 12595, 1); ---- "Strawberry Hat"
    SET_INT_GLOBAL(262145 + 12596, 1); ---- "S.A. Hat"
    SET_INT_GLOBAL(262145 + 12597, 1); ---- "Davis Hat"

    ---vestuario de natal
    SET_INT_GLOBAL(262145 + 12708, 1); ---- Festive masks  	(2015)
    SET_INT_GLOBAL(262145 + 12709, 1); ---- Festive Pajamas	(2015)
    SET_INT_GLOBAL(262145 + 19301, 1); ---- "christmas2016_("clothing"
    SET_INT_GLOBAL(262145 + 23084, 1); ---- "christmas2017_("clothing"

    ---Camisetas / Jaquetas / suéteres /
    SET_INT_GLOBAL(262145 + 30197, 1); ---- Panther varsity jacket
    SET_INT_GLOBAL(262145 + 30201, 1); ---- Gussét frog Tee
    SET_INT_GLOBAL(262145 + 30202, 1); ---- Warped still slipping tee
    SET_INT_GLOBAL(262145 + 30203, 1); ---- Yellow Still slipping tee
    SET_INT_GLOBAL(262145 + 30204, 1); ---- Black Rockstar  tee
    SET_INT_GLOBAL(262145 + 30205, 1); ---- Black exsorbeo 720 logo tee
    SET_INT_GLOBAL(262145 + 30206, 1); ---- Manor PRBG tee
    SET_INT_GLOBAL(262145 + 30207, 1); ---- Manor Tie-dye tee
    SET_INT_GLOBAL(262145 + 30208, 1); ---- Open wheel sponsor tee
    SET_INT_GLOBAL(262145 + 30209, 1); ---- Rockstar yellow pattern tee
    SET_INT_GLOBAL(262145 + 30210, 1); ---- Rockstar gray pattern tee
    SET_INT_GLOBAL(262145 + 30211, 1); ---- Rockstar rolling tee
    SET_INT_GLOBAL(262145 + 30212, 1); ---- Santo capra patterns sweater
    SET_INT_GLOBAL(262145 + 30213, 1); ---- Rockstar studio colors sweater
    SET_INT_GLOBAL(262145 + 30215, 1); ---- Bigness tie-dye sweater
    SET_INT_GLOBAL(262145 + 30216, 1); ---- Bigness faces sweater
    SET_INT_GLOBAL(262145 + 31175, 1); ---- Black Banshee Tee
    SET_INT_GLOBAL(262145 + 31176, 1); ---- Blue Banshee Tee
    SET_INT_GLOBAL(262145 + 31177, 1); ---- Banshee Hoodie
    SET_INT_GLOBAL(262145 + 31178, 1); ---- LS Customs Tee
    SET_INT_GLOBAL(262145 + 31179, 1); ---- LS Customs Coveralls
    SET_INT_GLOBAL(262145 + 31180, 1); ---- LS Customs Tour Jacket
    SET_INT_GLOBAL(262145 + 31181, 1); ---- LS Customs Varsity
    SET_INT_GLOBAL(262145 + 31182, 1); ---- Sprunk Varsity
    SET_INT_GLOBAL(262145 + 31183, 1); ---- eCola Varsity
    SET_INT_GLOBAL(262145 + 31191, 1); ---- Rockstar Games Typeface Tee
    SET_INT_GLOBAL(262145 + 31192, 1); ---- Wasted! Tee
    SET_INT_GLOBAL(262145 + 31193, 1); ---- Baseball Bat Tee
    SET_INT_GLOBAL(262145 + 31194, 1); ---- Knuckleduster Tee
    SET_INT_GLOBAL(262145 + 31195, 1); ---- Rampage Tee
    SET_INT_GLOBAL(262145 + 31196, 1); ---- Penitentiary Coveralls
    SET_INT_GLOBAL(262145 + 31197, 1); ---- White Born x Raised Tee
    SET_INT_GLOBAL(262145 + 32817, 1); ---- Pacific Standard Varsity
    SET_INT_GLOBAL(262145 + 32818, 1); ---- Pacific Standard Sweater
    SET_INT_GLOBAL(262145 + 32819, 1); ---- ("Clifford Varsity
    SET_INT_GLOBAL(262145 + 32820, 1); ---- ("Clifford Hoodie
    SET_INT_GLOBAL(262145 + 32821, 1); ---- The Diamond Casino Varsity
    SET_INT_GLOBAL(262145 + 32822, 1); ---- The Diamond Casino Strike Vest (body armor)
    SET_INT_GLOBAL(262145 + 32824, 1); ---- Sinsimito Cuban Shirt
    SET_INT_GLOBAL(262145 + 32840, 1); ---- Manor Geo Hoodie
    SET_INT_GLOBAL(262145 + 32841, 1); ---- Pumpkin Hoodie
    SET_INT_GLOBAL(262145 + 32842, 1); ---- LS Smoking Jacket
    SET_INT_GLOBAL(262145 + 32843, 1); ---- Hand Drawn Biker Bomber
    SET_INT_GLOBAL(262145 + 32844, 1); ---- Have You Seen me? Sweater
    SET_INT_GLOBAL(262145 + 32845, 1); ---- Still Slipping Tie Dye Tee

    ---Calção/Calças

    SET_INT_GLOBAL(262145 + 30217, 1); ---- Broker prolaps basketball shorts
    SET_INT_GLOBAL(262145 + 30218, 1); ---- Panic prolaps basketball shorts
    SET_INT_GLOBAL(262145 + 30219, 1); ---- Exorbeo 720 Sports shorts
    SET_INT_GLOBAL(262145 + 30220, 1); ---- Bigness tie-dye sports pants
    SET_INT_GLOBAL(262145 + 32846, 1); ---- Manor Geo Track Pants
    SET_INT_GLOBAL(262145 + 32847, 1); ---- Apricot Persues Track Pants

    ---Caps/chapeus/Bonés/fones
    SET_INT_GLOBAL(262145 + 30221, 1); ---- Enus yeti cap 			(forward,backard)
    SET_INT_GLOBAL(262145 + 30222, 1); ---- 720 cap				(forward,backard)
    SET_INT_GLOBAL(262145 + 30223, 1); ---- EXsorbeo 720 cap			(forward,backard)
    SET_INT_GLOBAL(262145 + 30224, 1); ---- Güffy Double Logo Forwards Cap	(forward,backard)
    SET_INT_GLOBAL(262145 + 30225, 1); ---- Rockstar cap				(forward,backard)
    SET_INT_GLOBAL(262145 + 31184, 1); ---- Sprunk Forwards Cap
    SET_INT_GLOBAL(262145 + 31185, 1); ---- eCola Forwards Cap
    SET_INT_GLOBAL(262145 + 32823, 1); ---- Strickler Hat
    SET_INT_GLOBAL(262145 + 32827, 1); ---- Manor Geo Forwards Cap
    SET_INT_GLOBAL(262145 + 32828, 1); ---- Apricot Persues Forwards Cap
    SET_INT_GLOBAL(262145 + 32829, 1); ---- Still Slipping Tie-ye Forwards Cap
    SET_INT_GLOBAL(262145 + 32898, 1); ---- Grey Yeti Flat Cap
    SET_INT_GLOBAL(262145 + 32899, 1); ---- Woodland Yeti Flat Cap
    SET_INT_GLOBAL(262145 + 32900, 1); ---- Green FB Flat Cap
    SET_INT_GLOBAL(262145 + 32901, 1); ---- Blue FB Flat Cap
    SET_INT_GLOBAL(262145 + 32902, 1); ---- Grey Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32903, 1); ---- Green Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32904, 1); ---- Light Plaid Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32905, 1); ---- Dark Plaid Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32906, 1); ---- White Striped Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32907, 1); ---- Red Striped Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32908, 1); ---- Brown Crevis Flat Cap
    SET_INT_GLOBAL(262145 + 32909, 1); ---- Grey Crevis Flat Cap
    SET_INT_GLOBAL(262145 + 32910, 1); ---- Black Broker Flat Cap
    SET_INT_GLOBAL(262145 + 32911, 1); ---- Burgundy Broker Flat Cap
    SET_INT_GLOBAL(262145 + 33559, 1); ---- Lemon Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33560, 1); ---- Green Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33561, 1); ---- Red Snowflake Beer Hat
    SET_INT_GLOBAL(262145 + 33562, 1); ---- Blue Snowflake Beer Hat
    SET_INT_GLOBAL(262145 + 33563, 1); ---- Red Holly Beer Hat
    SET_INT_GLOBAL(262145 + 33564, 1); ---- Pivswasser Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33565, 1); ---- Blarneys Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33566, 1); ---- Red Reindeer Beer Hat
    SET_INT_GLOBAL(262145 + 33567, 1); ---- Red Reindeer Beer Hat v2
    SET_INT_GLOBAL(262145 + 32839, 1); ---- Gold Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32912, 1); ---- White Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32913, 1); ---- Yellow Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32914, 1); ---- Salmon Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32915, 1); ---- Orange Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32916, 1); ---- Purple Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32917, 1); ---- Pink Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32918, 1); ---- Turquiouse Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32919, 1); ---- Blue Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32920, 1); ---- Black Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32921, 1); ---- Grey Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32922, 1); ---- Teal Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32923, 1); ---- Red Beat Off Earphones
    SET_INT_GLOBAL(262145 + 21153, 1); ---- BLACK_AMMUNATION_CAP
    SET_INT_GLOBAL(262145 + 21156, 1); ---- BLACK_COIL_CAP
    SET_INT_GLOBAL(262145 + 21162, 1); ---- BLACK_VOM_FEUER_CAP
    SET_INT_GLOBAL(262145 + 21165, 1); ---- RED_HAWK_AND_LITTLE_CAP
    SET_INT_GLOBAL(262145 + 21166, 1); ---- WARSTOCK_CAP
    SET_INT_GLOBAL(262145 + 21173, 1); ---- WHITE_SHREWSBURY_CAP
    SET_INT_GLOBAL(262145 + 21176, 1); ---- WHITE_VOM_FEUER_CAP
    SET_INT_GLOBAL(262145 + 21178, 1); ---- WINE_COIL_CAP

    ---Pulseiras

    SET_INT_GLOBAL(262145 + 30226, 1); ---- Blue bangles
    SET_INT_GLOBAL(262145 + 30227, 1); ---- Red bangles
    SET_INT_GLOBAL(262145 + 30228, 1); ---- Pink bangles
    SET_INT_GLOBAL(262145 + 30229, 1); ---- Yellow bangles
    SET_INT_GLOBAL(262145 + 30230, 1); ---- Orange bangles
    SET_INT_GLOBAL(262145 + 30231, 1); ---- Green bangles
    SET_INT_GLOBAL(262145 + 30232, 1); ---- Red and blue bangles
    SET_INT_GLOBAL(262145 + 30233, 1); ---- Yellow and orange bangles
    SET_INT_GLOBAL(262145 + 30234, 1); ---- Green and pink bangles
    SET_INT_GLOBAL(262145 + 30235, 1); ---- Rainbow bangles
    SET_INT_GLOBAL(262145 + 30236, 1); ---- Sunset bangles
    SET_INT_GLOBAL(262145 + 30237, 1); ---- Tropical bangles

    ---Óculos
    SET_INT_GLOBAL(262145 + 30238, 1); ---- Blue and pink glow shades
    SET_INT_GLOBAL(262145 + 30239, 1); ---- Red glow shades
    SET_INT_GLOBAL(262145 + 30240, 1); ---- Orange glow shades
    SET_INT_GLOBAL(262145 + 30241, 1); ---- Yellow glow shades
    SET_INT_GLOBAL(262145 + 30242, 1); ---- Green glow shades
    SET_INT_GLOBAL(262145 + 30243, 1); ---- Blue glow shades
    SET_INT_GLOBAL(262145 + 30244, 1); ---- Pink glow shades
    SET_INT_GLOBAL(262145 + 30245, 1); ---- Blue and magenta glow shades
    SET_INT_GLOBAL(262145 + 30246, 1); ---- Purple and yellow glow shades
    SET_INT_GLOBAL(262145 + 30247, 1); ---- Blue and yellow glow shades
    SET_INT_GLOBAL(262145 + 30248, 1); ---- Pink and yellow glow shades
    SET_INT_GLOBAL(262145 + 30249, 1); ---- Red and yellow glow shades
    SET_INT_GLOBAL(262145 + 30854, 1); ---- Midnight tint oversized shades
    SET_INT_GLOBAL(262145 + 30855, 1); ---- Sunset tint oversized shades
    SET_INT_GLOBAL(262145 + 30856, 1); ---- Black tint oversized shades
    SET_INT_GLOBAL(262145 + 30857, 1); ---- Blue tint oversized shades
    SET_INT_GLOBAL(262145 + 30858, 1); ---- Gold tint oversized shades
    SET_INT_GLOBAL(262145 + 30859, 1); ---- Green tint oversized shades
    SET_INT_GLOBAL(262145 + 30860, 1); ---- Orange tint oversized shades
    SET_INT_GLOBAL(262145 + 30861, 1); ---- Red tint oversized shades
    SET_INT_GLOBAL(262145 + 30862, 1); ---- Pink tint oversized shades
    SET_INT_GLOBAL(262145 + 30863, 1); ---- Yellow tint oversized shades
    SET_INT_GLOBAL(262145 + 30864, 1); ---- Lemon tint oversized shades
    SET_INT_GLOBAL(262145 + 30865, 1); ---- Gold rimmed oversized shades
    SET_INT_GLOBAL(262145 + 30866, 1); ---- White checked round shades
    SET_INT_GLOBAL(262145 + 30867, 1); ---- Pink checked round shades
    SET_INT_GLOBAL(262145 + 30868, 1); ---- Yellow checked round shades
    SET_INT_GLOBAL(262145 + 30869, 1); ---- Red checked round shades
    SET_INT_GLOBAL(262145 + 30870, 1); ---- White round shades
    SET_INT_GLOBAL(262145 + 30871, 1); ---- Black round shades
    SET_INT_GLOBAL(262145 + 30872, 1); ---- Pink tinted round shades
    SET_INT_GLOBAL(262145 + 30873, 1); ---- Blue tinted round shades
    SET_INT_GLOBAL(262145 + 30874, 1); ---- Green checked round shades
    SET_INT_GLOBAL(262145 + 30875, 1); ---- Blue checked round shades
    SET_INT_GLOBAL(262145 + 30876, 1); ---- Orange checked round shades
    SET_INT_GLOBAL(262145 + 30877, 1); ---- Green tinted round shades
    SET_INT_GLOBAL(262145 + 30878, 1); ---- Brown square shades
    SET_INT_GLOBAL(262145 + 30879, 1); ---- Yellow square shades
    SET_INT_GLOBAL(262145 + 30880, 1); ---- Black square shades
    SET_INT_GLOBAL(262145 + 30881, 1); ---- Tortoiseshell square shades
    SET_INT_GLOBAL(262145 + 30882, 1); ---- Green square shades
    SET_INT_GLOBAL(262145 + 30883, 1); ---- Red square shades
    SET_INT_GLOBAL(262145 + 30884, 1); ---- Pink tinted square shades
    SET_INT_GLOBAL(262145 + 30885, 1); ---- Blue tinted square shades
    SET_INT_GLOBAL(262145 + 30886, 1); ---- White square shades
    SET_INT_GLOBAL(262145 + 30887, 1); ---- Pink square shades
    SET_INT_GLOBAL(262145 + 30888, 1); ---- All white square shades
    SET_INT_GLOBAL(262145 + 30889, 1); ---- Mono square shades

    ---Colares
    SET_INT_GLOBAL(262145 + 30250, 1); ---- Blue glow necklace
    SET_INT_GLOBAL(262145 + 30251, 1); ---- Red glow necklace
    SET_INT_GLOBAL(262145 + 30252, 1); ---- Pink glow necklace
    SET_INT_GLOBAL(262145 + 30253, 1); ---- Yellow glow necklace
    SET_INT_GLOBAL(262145 + 30254, 1); ---- Orange glow necklace
    SET_INT_GLOBAL(262145 + 30255, 1); ---- Green glow necklace
    SET_INT_GLOBAL(262145 + 30256, 1); ---- Festival glow necklace
    SET_INT_GLOBAL(262145 + 30257, 1); ---- Carnival glow necklace
    SET_INT_GLOBAL(262145 + 30258, 1); ---- Tropical glow necklace
    SET_INT_GLOBAL(262145 + 30259, 1); ---- Hot glow necklace
    SET_INT_GLOBAL(262145 + 30260, 1); ---- Neon glow necklace
    SET_INT_GLOBAL(262145 + 30261, 1); ---- Party glow necklace
    SET_INT_GLOBAL(262145 + 30262, 1); ---- Sunset glow necklace
    SET_INT_GLOBAL(262145 + 30263, 1); ---- Radiant glow necklace
    SET_INT_GLOBAL(262145 + 30264, 1); ---- Sunrise glow necklace
    SET_INT_GLOBAL(262145 + 30265, 1); ---- Session glow necklace

    ---Máscaras em Geral
    SET_INT_GLOBAL(262145 + 30270, 1); ---- Green calavera mask
    SET_INT_GLOBAL(262145 + 30271, 1); ---- Navy calavera mask
    SET_INT_GLOBAL(262145 + 30272, 1); ---- Cherry calavera mask
    SET_INT_GLOBAL(262145 + 30273, 1); ---- Orange calavera mask
    SET_INT_GLOBAL(262145 + 30274, 1); ---- Purple calavera mask
    SET_INT_GLOBAL(262145 + 30275, 1); ---- Dark blue calavera mask
    SET_INT_GLOBAL(262145 + 30276, 1); ---- Lavender calavera mask
    SET_INT_GLOBAL(262145 + 30277, 1); ---- Yellow calavera mask
    SET_INT_GLOBAL(262145 + 30278, 1); ---- Pink calavera mask
    SET_INT_GLOBAL(262145 + 30279, 1); ---- Neon stich emissive mask
    SET_INT_GLOBAL(262145 + 30280, 1); ---- Vibrant stich emissive mask
    SET_INT_GLOBAL(262145 + 30281, 1); ---- Pink stich emissive mask
    SET_INT_GLOBAL(262145 + 30282, 1); ---- Blue stich emissive mask
    SET_INT_GLOBAL(262145 + 30283, 1); ---- Neon skull emissive mask
    SET_INT_GLOBAL(262145 + 30284, 1); ---- Vibrant skull emissive mask
    SET_INT_GLOBAL(262145 + 30285, 1); ---- Pink skull emissive mask
    SET_INT_GLOBAL(262145 + 30286, 1); ---- Orange skull emissive mask
    SET_INT_GLOBAL(262145 + 30287, 1); ---- Dark x-ray emissive mask
    SET_INT_GLOBAL(262145 + 30288, 1); ---- Bright x-ray emissive mask
    SET_INT_GLOBAL(262145 + 30289, 1); ---- Purple x-ray emissive mask
    SET_INT_GLOBAL(262145 + 32832, 1); ---- Grimy Stitched
    SET_INT_GLOBAL(262145 + 32833, 1); ---- Pale Stitched
    SET_INT_GLOBAL(262145 + 32834, 1); ---- Grey Cracked Puppet
    SET_INT_GLOBAL(262145 + 32835, 1); ---- Blushed Cracked Puppet
    SET_INT_GLOBAL(262145 + 32836, 1); ---- Green Emissive Lady Liberty
    SET_INT_GLOBAL(262145 + 32837, 1); ---- President
    SET_INT_GLOBAL(262145 + 32852, 1); ---- Green Vintage Frank
    SET_INT_GLOBAL(262145 + 32853, 1); ---- Brown Vintage Frank
    SET_INT_GLOBAL(262145 + 32854, 1); ---- Grey Vintage Frank
    SET_INT_GLOBAL(262145 + 32855, 1); ---- Pale Vintage Mummy
    SET_INT_GLOBAL(262145 + 32856, 1); ---- Green Vintage Mummy
    SET_INT_GLOBAL(262145 + 32857, 1); ---- Weathered Vintage Mummy
    SET_INT_GLOBAL(262145 + 32858, 1); ---- White Vintage Mummy
    SET_INT_GLOBAL(262145 + 32859, 1); ---- Dark Green Vintage Vampire
    SET_INT_GLOBAL(262145 + 32860, 1); ---- Light Green Vintage Vampire
    SET_INT_GLOBAL(262145 + 32864, 1); ---- Conquest
    SET_INT_GLOBAL(262145 + 32865, 1); ---- Death
    SET_INT_GLOBAL(262145 + 32866, 1); ---- Famine
    SET_INT_GLOBAL(262145 + 32867, 1); ---- War
    SET_INT_GLOBAL(262145 + 32868, 1); ---- Black Tech Demon
    SET_INT_GLOBAL(262145 + 32869, 1); ---- Grey Tech Demon
    SET_INT_GLOBAL(262145 + 32870, 1); ---- White Tech Demon
    SET_INT_GLOBAL(262145 + 32871, 1); ---- Green Tech Demon
    SET_INT_GLOBAL(262145 + 32872, 1); ---- Orange Tech Demon
    SET_INT_GLOBAL(262145 + 32873, 1); ---- Purple Tech Demon
    SET_INT_GLOBAL(262145 + 32874, 1); ---- Pink Tech Demon
    SET_INT_GLOBAL(262145 + 32875, 1); ---- Red Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32876, 1); ---- Blue Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32877, 1); ---- Yellow Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32878, 1); ---- Green Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32879, 1); ---- Pink Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32880, 1); ---- Orange And Grey Tech Demon
    SET_INT_GLOBAL(262145 + 32881, 1); ---- Red Tech Demon
    SET_INT_GLOBAL(262145 + 32882, 1); ---- Camo Tech Demon
    SET_INT_GLOBAL(262145 + 32883, 1); ---- Aqua Camo Tech Demon
    SET_INT_GLOBAL(262145 + 32884, 1); ---- Brown Digital Tech Demon
    SET_INT_GLOBAL(262145 + 32885, 1); ---- Gold Tech Demon
    SET_INT_GLOBAL(262145 + 32886, 1); ---- Orange and Cream Tech Demon
    SET_INT_GLOBAL(262145 + 32887, 1); ---- Green and Yellow Tech Demon
    SET_INT_GLOBAL(262145 + 32888, 1); ---- Pink Floral Tech Demon
    SET_INT_GLOBAL(262145 + 32889, 1); ---- Black and Green Tech Demon
    SET_INT_GLOBAL(262145 + 32890, 1); ---- hite and Red Tech Demon
    SET_INT_GLOBAL(262145 + 32891, 1); ---- Carbon Tech Demon
    SET_INT_GLOBAL(262145 + 32892, 1); ---- Carbon Teal Tech Demon
    SET_INT_GLOBAL(262145 + 32893, 1); ---- Black and White Tech Demon
    SET_INT_GLOBAL(262145 + 32894, 1); ---- Painted Tiger
    SET_INT_GLOBAL(262145 + 32895, 1); ---- Grey Painted Tiger
    SET_INT_GLOBAL(262145 + 32896, 1); ---- Gold Painted Tiger
    SET_INT_GLOBAL(262145 + 32897, 1); ---- Ornate Painted Tiger
    SET_INT_GLOBAL(262145 + 27518, 1) --- Ace Mask
    SET_INT_GLOBAL(262145 + 27519, 1) ---Ace Mask
    SET_INT_GLOBAL(262145 + 27520, 1) ---Ace Mask	S
    SET_INT_GLOBAL(262145 + 27521, 1) ---Ace Mask
    SET_INT_GLOBAL(262145 + 31842, 1); ---- Orange Goldfish Mask
    SET_INT_GLOBAL(262145 + 31843, 1); ---- Purple Goldfish Mask
    SET_INT_GLOBAL(262145 + 31844, 1); ---- Bronze Goldfish Mask
    SET_INT_GLOBAL(262145 + 31845, 1); ---- ("Clownfish Mask
    SET_INT_GLOBAL(262145 + 31846, 1); ---- Juvenile Gull Mask
    SET_INT_GLOBAL(262145 + 31847, 1); ---- Sooty Gull Mask
    SET_INT_GLOBAL(262145 + 31848, 1); ---- Black-headed Gull Mask
    SET_INT_GLOBAL(262145 + 31849, 1); ---- Herring Gull Mask
    SET_INT_GLOBAL(262145 + 31850, 1); ---- Brown Sea Lion Mask
    SET_INT_GLOBAL(262145 + 31851, 1); ---- Dark Sea Lion Mask
    SET_INT_GLOBAL(262145 + 31852, 1); ---- Spotted Sea Lion Mask
    SET_INT_GLOBAL(262145 + 31853, 1); ---- Gray Sea Lion Mask
    SET_INT_GLOBAL(262145 + 24247, 1); ---- Please Stop Me Mask

    ---camisetas de DJ/DJ pooh
    SET_INT_GLOBAL(262145 + 30899, 1); ---- Palms Trax LS Tee
    SET_INT_GLOBAL(262145 + 30900, 1); ---- Moodymann Whatupdoe Tee
    SET_INT_GLOBAL(262145 + 30901, 1); ---- Moodymann Big D Tee
    SET_INT_GLOBAL(262145 + 30902, 1); ---- Keinemusik Cayo Perico Tee
    SET_INT_GLOBAL(262145 + 30903, 1); ---- Still Slipping Blarneys Tee
    SET_INT_GLOBAL(262145 + 30904, 1); ---- Still Slipping Friend Tee
    SET_INT_GLOBAL(262145 + 31186, 1); ---- eCola Bodysuit
    SET_INT_GLOBAL(262145 + 31187, 1); ---- Sprunk Bodysuit
    SET_INT_GLOBAL(262145 + 31854, 1); ---- Orange DJ Pohh Tee
    SET_INT_GLOBAL(262145 + 31855, 1); ---- White WCC DJ Pooh Tee
    SET_INT_GLOBAL(262145 + 31856, 1); ---- Blue WCC DJ Pooh Tee
    SET_INT_GLOBAL(262145 + 24946, 1); ---- "White Solomun Logo Tee"
    SET_INT_GLOBAL(262145 + 24947, 1); ---- "White Solomun Pocket Logo Tee"
    SET_INT_GLOBAL(262145 + 24948, 1); ---- "Black And Yellow Solomun Tee"
    SET_INT_GLOBAL(262145 + 24949, 1); ---- "Black Solomun White Logo Tee"
    SET_INT_GLOBAL(262145 + 24950, 1); ---- "Black And White Solomun Tee"
    SET_INT_GLOBAL(262145 + 24951, 1); ---- "Black Solomun Pocket Logo Tee"
    SET_INT_GLOBAL(262145 + 24952, 1); ---- "Dixon Box logo Tee"
    SET_INT_GLOBAL(262145 + 24953, 1); ---- "Dixon Pocket logo Tee"
    SET_INT_GLOBAL(262145 + 24954, 1); ---- "White Dixon Wilderness Tee"
    SET_INT_GLOBAL(262145 + 24955, 1); ---- "Dixon Green Logo Tee"
    SET_INT_GLOBAL(262145 + 24956, 1); ---- "Dixon Glitch Logo Tee"
    SET_INT_GLOBAL(262145 + 24957, 1); ---- "Black Dixon Repeated Logo Tee"
    SET_INT_GLOBAL(262145 + 24958, 1); ---- "Tale Of Us Box Logo Tee"
    SET_INT_GLOBAL(262145 + 24959, 1); ---- "White Tale Of Us Logo Tee"
    SET_INT_GLOBAL(262145 + 24960, 1); ---- "White Tale Of Us Emb. Tee"
    SET_INT_GLOBAL(262145 + 24961, 1); ---- "Black Tale Of Us 0Logo Tee"
    SET_INT_GLOBAL(262145 + 24962, 1); ---- "Tale Of Us Stacked Logo Tee"
    SET_INT_GLOBAL(262145 + 24963, 1); ---- "Tale Of Us Afterlight Tee"
    SET_INT_GLOBAL(262145 + 24964, 1); ---- "White The Black Madonna Tee"
    SET_INT_GLOBAL(262145 + 24965, 1); ---- "Black The Black Madonna Tee"
    SET_INT_GLOBAL(262145 + 24966, 1); ---- "White The Black Madonna Emb. Tee"
    SET_INT_GLOBAL(262145 + 24967, 1); ---- "White The Black Madonna Init. Tee"
    SET_INT_GLOBAL(262145 + 24968, 1); ---- "Black The Black Madonna Init. Tee"
    SET_INT_GLOBAL(262145 + 24969, 1); ---- "The Black Madonna We Believe Tee"

    ---Paraquedas
    SET_INT_GLOBAL(262145 + 31188, 1); ---- Sprunk Parachute Bag
    SET_INT_GLOBAL(262145 + 31189, 1); ---- eCola Parachute Bag
    SET_INT_GLOBAL(262145 + 31190, 1); ---- Halloween Parachute Bag
    SET_INT_GLOBAL(262145 + 24248, 1); ---- Highflyer Parachute Bag
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisetas da estação de rádio", {}, "", function()
    SET_INT_GLOBAL(262145 + 24232, 1); ---- "Emotion 98.3 Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24237, 1); ---- "KJAH Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24239, 1); ---- "K-ROSE Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24240, 1); ---- "FLASH Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24242, 1); ---- "Fever 105 Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24244, 1); ---- "K-DST Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24245, 1); ---- "Bounce FM Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24772, 1); ---- "LS UR T-Shirt"
    SET_INT_GLOBAL(262145 + 24773, 1); ---- "Non-Stop-Pop FM T-Shirt"
    SET_INT_GLOBAL(262145 + 24774, 1); ---- "Radio Los Santos T-Shirt"
    SET_INT_GLOBAL(262145 + 24775, 1); ---- "Los Santos Rock Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24776, 1); ---- "Blonded Los Santos 97.8 FM T-Shirt"
    SET_INT_GLOBAL(262145 + 24777, 1); ---- "West Coast Talk Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24778, 1); ---- "Radio Mirror Park T-Shirt"
    SET_INT_GLOBAL(262145 + 24779, 1); ---- "Rebel Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24780, 1); ---- "Channel X T-Shirt"
    SET_INT_GLOBAL(262145 + 24781, 1); ---- "Vinewood Boulevard Radio T-Shirt"
    SET_INT_GLOBAL(262145 + 24782, 1); ---- "FlyLo FM T-Shirt"
    SET_INT_GLOBAL(262145 + 24783, 1); ---- "Space 103.2 T-Shirt"
    SET_INT_GLOBAL(262145 + 24784, 1); ---- "West Coast ("Classics T-Shirt"
    SET_INT_GLOBAL(262145 + 24785, 1); ---- "East Los FM T-Shirt"
    SET_INT_GLOBAL(262145 + 24786, 1); ---- "The Lab T-Shirt"
    SET_INT_GLOBAL(262145 + 24787, 1); ---- "The Lowdown 91.1 T-Shirt"
    SET_INT_GLOBAL(262145 + 24788, 1); ---- "WorldWide FM T-Shirt"
    SET_INT_GLOBAL(262145 + 24789, 1); ---- "Soulwax FM T-Shirt"
    SET_INT_GLOBAL(262145 + 24790, 1); ---- "Blue Ark T-Shirt"
    SET_INT_GLOBAL(262145 + 24791, 1); ---- "Blaine County Radio T-Shirt"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisetas / Jaquetas / suéteres", {}, "", function()
    SET_INT_GLOBAL(262145 + 30197, 1); ---- Panther varsity jacket
    SET_INT_GLOBAL(262145 + 30201, 1); ---- Gussét frog Tee
    SET_INT_GLOBAL(262145 + 30202, 1); ---- Warped still slipping tee
    SET_INT_GLOBAL(262145 + 30203, 1); ---- Yellow Still slipping tee
    SET_INT_GLOBAL(262145 + 30204, 1); ---- Black Rockstar  tee
    SET_INT_GLOBAL(262145 + 30205, 1); ---- Black exsorbeo 720 logo tee
    SET_INT_GLOBAL(262145 + 30206, 1); ---- Manor PRBG tee
    SET_INT_GLOBAL(262145 + 30207, 1); ---- Manor Tie-dye tee
    SET_INT_GLOBAL(262145 + 30208, 1); ---- Open wheel sponsor tee
    SET_INT_GLOBAL(262145 + 30209, 1); ---- Rockstar yellow pattern tee
    SET_INT_GLOBAL(262145 + 30210, 1); ---- Rockstar gray pattern tee
    SET_INT_GLOBAL(262145 + 30211, 1); ---- Rockstar rolling tee
    SET_INT_GLOBAL(262145 + 30212, 1); ---- Santo capra patterns sweater
    SET_INT_GLOBAL(262145 + 30213, 1); ---- Rockstar studio colors sweater
    SET_INT_GLOBAL(262145 + 30215, 1); ---- Bigness tie-dye sweater
    SET_INT_GLOBAL(262145 + 30216, 1); ---- Bigness faces sweater
    SET_INT_GLOBAL(262145 + 31175, 1); ---- Black Banshee Tee
    SET_INT_GLOBAL(262145 + 31176, 1); ---- Blue Banshee Tee
    SET_INT_GLOBAL(262145 + 31177, 1); ---- Banshee Hoodie
    SET_INT_GLOBAL(262145 + 31178, 1); ---- LS Customs Tee
    SET_INT_GLOBAL(262145 + 31179, 1); ---- LS Customs Coveralls
    SET_INT_GLOBAL(262145 + 31180, 1); ---- LS Customs Tour Jacket
    SET_INT_GLOBAL(262145 + 31181, 1); ---- LS Customs Varsity
    SET_INT_GLOBAL(262145 + 31182, 1); ---- Sprunk Varsity
    SET_INT_GLOBAL(262145 + 31183, 1); ---- eCola Varsity
    SET_INT_GLOBAL(262145 + 31191, 1); ---- Rockstar Games Typeface Tee
    SET_INT_GLOBAL(262145 + 31192, 1); ---- Wasted! Tee
    SET_INT_GLOBAL(262145 + 31193, 1); ---- Baseball Bat Tee
    SET_INT_GLOBAL(262145 + 31194, 1); ---- Knuckleduster Tee
    SET_INT_GLOBAL(262145 + 31195, 1); ---- Rampage Tee
    SET_INT_GLOBAL(262145 + 31196, 1); ---- Penitentiary Coveralls
    SET_INT_GLOBAL(262145 + 31197, 1); ---- White Born x Raised Tee
    SET_INT_GLOBAL(262145 + 32817, 1); ---- Pacific Standard Varsity
    SET_INT_GLOBAL(262145 + 32818, 1); ---- Pacific Standard Sweater
    SET_INT_GLOBAL(262145 + 32819, 1); ---- ("Clifford Varsity
    SET_INT_GLOBAL(262145 + 32820, 1); ---- ("Clifford Hoodie
    SET_INT_GLOBAL(262145 + 32821, 1); ---- The Diamond Casino Varsity
    SET_INT_GLOBAL(262145 + 32822, 1); ---- The Diamond Casino Strike Vest (body armor)
    SET_INT_GLOBAL(262145 + 32824, 1); ---- Sinsimito Cuban Shirt
    SET_INT_GLOBAL(262145 + 32840, 1); ---- Manor Geo Hoodie
    SET_INT_GLOBAL(262145 + 32841, 1); ---- Pumpkin Hoodie
    SET_INT_GLOBAL(262145 + 32842, 1); ---- LS Smoking Jacket
    SET_INT_GLOBAL(262145 + 32843, 1); ---- Hand Drawn Biker Bomber
    SET_INT_GLOBAL(262145 + 32844, 1); ---- Have You Seen me? Sweater
    SET_INT_GLOBAL(262145 + 32845, 1); ---- Still Slipping Tie Dye Tee
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Calção/Calças", {}, "", function()
    SET_INT_GLOBAL(262145 + 30217, 1); ---- Broker prolaps basketball shorts
    SET_INT_GLOBAL(262145 + 30218, 1); ---- Panic prolaps basketball shorts
    SET_INT_GLOBAL(262145 + 30219, 1); ---- Exorbeo 720 Sports shorts
    SET_INT_GLOBAL(262145 + 30220, 1); ---- Bigness tie-dye sports pants
    SET_INT_GLOBAL(262145 + 32846, 1); ---- Manor Geo Track Pants
    SET_INT_GLOBAL(262145 + 32847, 1); ---- Apricot Persues Track Pants
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Caps/chapeus/Bonés/fones", {}, "", function()
    SET_INT_GLOBAL(262145 + 30221, 1); ---- Enus yeti cap 			(forward,backard)
    SET_INT_GLOBAL(262145 + 30222, 1); ---- 720 cap				(forward,backard)
    SET_INT_GLOBAL(262145 + 30223, 1); ---- EXsorbeo 720 cap			(forward,backard)
    SET_INT_GLOBAL(262145 + 30224, 1); ---- Güffy Double Logo Forwards Cap	(forward,backard)
    SET_INT_GLOBAL(262145 + 30225, 1); ---- Rockstar cap				(forward,backard)
    SET_INT_GLOBAL(262145 + 31184, 1); ---- Sprunk Forwards Cap
    SET_INT_GLOBAL(262145 + 31185, 1); ---- eCola Forwards Cap
    SET_INT_GLOBAL(262145 + 32823, 1); ---- Strickler Hat
    SET_INT_GLOBAL(262145 + 32827, 1); ---- Manor Geo Forwards Cap
    SET_INT_GLOBAL(262145 + 32828, 1); ---- Apricot Persues Forwards Cap
    SET_INT_GLOBAL(262145 + 32829, 1); ---- Still Slipping Tie-ye Forwards Cap
    SET_INT_GLOBAL(262145 + 32898, 1); ---- Grey Yeti Flat Cap
    SET_INT_GLOBAL(262145 + 32899, 1); ---- Woodland Yeti Flat Cap
    SET_INT_GLOBAL(262145 + 32900, 1); ---- Green FB Flat Cap
    SET_INT_GLOBAL(262145 + 32901, 1); ---- Blue FB Flat Cap
    SET_INT_GLOBAL(262145 + 32902, 1); ---- Grey Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32903, 1); ---- Green Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32904, 1); ---- Light Plaid Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32905, 1); ---- Dark Plaid Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32906, 1); ---- White Striped Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32907, 1); ---- Red Striped Lezard Flat Cap
    SET_INT_GLOBAL(262145 + 32908, 1); ---- Brown Crevis Flat Cap
    SET_INT_GLOBAL(262145 + 32909, 1); ---- Grey Crevis Flat Cap
    SET_INT_GLOBAL(262145 + 32910, 1); ---- Black Broker Flat Cap
    SET_INT_GLOBAL(262145 + 32911, 1); ---- Burgundy Broker Flat Cap
    SET_INT_GLOBAL(262145 + 33559, 1); ---- Lemon Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33560, 1); ---- Green Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33561, 1); ---- Red Snowflake Beer Hat
    SET_INT_GLOBAL(262145 + 33562, 1); ---- Blue Snowflake Beer Hat
    SET_INT_GLOBAL(262145 + 33563, 1); ---- Red Holly Beer Hat
    SET_INT_GLOBAL(262145 + 33564, 1); ---- Pivswasser Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33565, 1); ---- Blarneys Festive Beer Hat
    SET_INT_GLOBAL(262145 + 33566, 1); ---- Red Reindeer Beer Hat
    SET_INT_GLOBAL(262145 + 33567, 1); ---- Red Reindeer Beer Hat v2
    SET_INT_GLOBAL(262145 + 32839, 1); ---- Gold Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32912, 1); ---- White Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32913, 1); ---- Yellow Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32914, 1); ---- Salmon Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32915, 1); ---- Orange Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32916, 1); ---- Purple Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32917, 1); ---- Pink Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32918, 1); ---- Turquiouse Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32919, 1); ---- Blue Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32920, 1); ---- Black Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32921, 1); ---- Grey Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32922, 1); ---- Teal Beat Off Earphones
    SET_INT_GLOBAL(262145 + 32923, 1); ---- Red Beat Off Earphones
    SET_INT_GLOBAL(262145 + 21153, 1); ---- BLACK_AMMUNATION_CAP
    SET_INT_GLOBAL(262145 + 21156, 1); ---- BLACK_COIL_CAP
    SET_INT_GLOBAL(262145 + 21162, 1); ---- BLACK_VOM_FEUER_CAP
    SET_INT_GLOBAL(262145 + 21165, 1); ---- RED_HAWK_AND_LITTLE_CAP
    SET_INT_GLOBAL(262145 + 21166, 1); ---- WARSTOCK_CAP
    SET_INT_GLOBAL(262145 + 21173, 1); ---- WHITE_SHREWSBURY_CAP
    SET_INT_GLOBAL(262145 + 21176, 1); ---- WHITE_VOM_FEUER_CAP
    SET_INT_GLOBAL(262145 + 21178, 1); ---- WINE_COIL_CAP
    SET_INT_GLOBAL(262145 + 12588, 1); ---- "Magnetics Script Hat"
    SET_INT_GLOBAL(262145 + 12589, 1); ---- "Magnetics Block Hat"
    SET_INT_GLOBAL(262145 + 12590, 1); ---- "Los Santos Hat"
    SET_INT_GLOBAL(262145 + 12591, 1); ---- "Boars Hat"
    SET_INT_GLOBAL(262145 + 12592, 1); ---- "Benny's Hat"
    SET_INT_GLOBAL(262145 + 12593, 1); ---- "Westside Hat"
    SET_INT_GLOBAL(262145 + 12594, 1); ---- "Eastside Hat"
    SET_INT_GLOBAL(262145 + 12595, 1); ---- "Strawberry Hat"
    SET_INT_GLOBAL(262145 + 12596, 1); ---- "S.A. Hat"
    SET_INT_GLOBAL(262145 + 12597, 1); ---- "Davis Hat"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Pulseiras", {}, "", function()
    SET_INT_GLOBAL(262145 + 30226, 1); ---- Blue bangles
    SET_INT_GLOBAL(262145 + 30227, 1); ---- Red bangles
    SET_INT_GLOBAL(262145 + 30228, 1); ---- Pink bangles
    SET_INT_GLOBAL(262145 + 30229, 1); ---- Yellow bangles
    SET_INT_GLOBAL(262145 + 30230, 1); ---- Orange bangles
    SET_INT_GLOBAL(262145 + 30231, 1); ---- Green bangles
    SET_INT_GLOBAL(262145 + 30232, 1); ---- Red and blue bangles
    SET_INT_GLOBAL(262145 + 30233, 1); ---- Yellow and orange bangles
    SET_INT_GLOBAL(262145 + 30234, 1); ---- Green and pink bangles
    SET_INT_GLOBAL(262145 + 30235, 1); ---- Rainbow bangles
    SET_INT_GLOBAL(262145 + 30236, 1); ---- Sunset bangles
    SET_INT_GLOBAL(262145 + 30237, 1); ---- Tropical bangles
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Óculos", {}, "", function()
    SET_INT_GLOBAL(262145 + 30238, 1); ---- Blue and pink glow shades
    SET_INT_GLOBAL(262145 + 30239, 1); ---- Red glow shades
    SET_INT_GLOBAL(262145 + 30240, 1); ---- Orange glow shades
    SET_INT_GLOBAL(262145 + 30241, 1); ---- Yellow glow shades
    SET_INT_GLOBAL(262145 + 30242, 1); ---- Green glow shades
    SET_INT_GLOBAL(262145 + 30243, 1); ---- Blue glow shades
    SET_INT_GLOBAL(262145 + 30244, 1); ---- Pink glow shades
    SET_INT_GLOBAL(262145 + 30245, 1); ---- Blue and magenta glow shades
    SET_INT_GLOBAL(262145 + 30246, 1); ---- Purple and yellow glow shades
    SET_INT_GLOBAL(262145 + 30247, 1); ---- Blue and yellow glow shades
    SET_INT_GLOBAL(262145 + 30248, 1); ---- Pink and yellow glow shades
    SET_INT_GLOBAL(262145 + 30249, 1); ---- Red and yellow glow shades
    SET_INT_GLOBAL(262145 + 30854, 1); ---- Midnight tint oversized shades
    SET_INT_GLOBAL(262145 + 30855, 1); ---- Sunset tint oversized shades
    SET_INT_GLOBAL(262145 + 30856, 1); ---- Black tint oversized shades
    SET_INT_GLOBAL(262145 + 30857, 1); ---- Blue tint oversized shades
    SET_INT_GLOBAL(262145 + 30858, 1); ---- Gold tint oversized shades
    SET_INT_GLOBAL(262145 + 30859, 1); ---- Green tint oversized shades
    SET_INT_GLOBAL(262145 + 30860, 1); ---- Orange tint oversized shades
    SET_INT_GLOBAL(262145 + 30861, 1); ---- Red tint oversized shades
    SET_INT_GLOBAL(262145 + 30862, 1); ---- Pink tint oversized shades
    SET_INT_GLOBAL(262145 + 30863, 1); ---- Yellow tint oversized shades
    SET_INT_GLOBAL(262145 + 30864, 1); ---- Lemon tint oversized shades
    SET_INT_GLOBAL(262145 + 30865, 1); ---- Gold rimmed oversized shades
    SET_INT_GLOBAL(262145 + 30866, 1); ---- White checked round shades
    SET_INT_GLOBAL(262145 + 30867, 1); ---- Pink checked round shades
    SET_INT_GLOBAL(262145 + 30868, 1); ---- Yellow checked round shades
    SET_INT_GLOBAL(262145 + 30869, 1); ---- Red checked round shades
    SET_INT_GLOBAL(262145 + 30870, 1); ---- White round shades
    SET_INT_GLOBAL(262145 + 30871, 1); ---- Black round shades
    SET_INT_GLOBAL(262145 + 30872, 1); ---- Pink tinted round shades
    SET_INT_GLOBAL(262145 + 30873, 1); ---- Blue tinted round shades
    SET_INT_GLOBAL(262145 + 30874, 1); ---- Green checked round shades
    SET_INT_GLOBAL(262145 + 30875, 1); ---- Blue checked round shades
    SET_INT_GLOBAL(262145 + 30876, 1); ---- Orange checked round shades
    SET_INT_GLOBAL(262145 + 30877, 1); ---- Green tinted round shades
    SET_INT_GLOBAL(262145 + 30878, 1); ---- Brown square shades
    SET_INT_GLOBAL(262145 + 30879, 1); ---- Yellow square shades
    SET_INT_GLOBAL(262145 + 30880, 1); ---- Black square shades
    SET_INT_GLOBAL(262145 + 30881, 1); ---- Tortoiseshell square shades
    SET_INT_GLOBAL(262145 + 30882, 1); ---- Green square shades
    SET_INT_GLOBAL(262145 + 30883, 1); ---- Red square shades
    SET_INT_GLOBAL(262145 + 30884, 1); ---- Pink tinted square shades
    SET_INT_GLOBAL(262145 + 30885, 1); ---- Blue tinted square shades
    SET_INT_GLOBAL(262145 + 30886, 1); ---- White square shades
    SET_INT_GLOBAL(262145 + 30887, 1); ---- Pink square shades
    SET_INT_GLOBAL(262145 + 30888, 1); ---- All white square shades
    SET_INT_GLOBAL(262145 + 30889, 1); ---- Mono square shades
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Colares", {}, "", function()
    SET_INT_GLOBAL(262145 + 30250, 1); ---- Blue glow necklace
    SET_INT_GLOBAL(262145 + 30251, 1); ---- Red glow necklace
    SET_INT_GLOBAL(262145 + 30252, 1); ---- Pink glow necklace
    SET_INT_GLOBAL(262145 + 30253, 1); ---- Yellow glow necklace
    SET_INT_GLOBAL(262145 + 30254, 1); ---- Orange glow necklace
    SET_INT_GLOBAL(262145 + 30255, 1); ---- Green glow necklace
    SET_INT_GLOBAL(262145 + 30256, 1); ---- Festival glow necklace
    SET_INT_GLOBAL(262145 + 30257, 1); ---- Carnival glow necklace
    SET_INT_GLOBAL(262145 + 30258, 1); ---- Tropical glow necklace
    SET_INT_GLOBAL(262145 + 30259, 1); ---- Hot glow necklace
    SET_INT_GLOBAL(262145 + 30260, 1); ---- Neon glow necklace
    SET_INT_GLOBAL(262145 + 30261, 1); ---- Party glow necklace
    SET_INT_GLOBAL(262145 + 30262, 1); ---- Sunset glow necklace
    SET_INT_GLOBAL(262145 + 30263, 1); ---- Radiant glow necklace
    SET_INT_GLOBAL(262145 + 30264, 1); ---- Sunrise glow necklace
    SET_INT_GLOBAL(262145 + 30265, 1); ---- Session glow necklace
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Máscaras em Geral", {}, "", function()
    SET_INT_GLOBAL(262145 + 30270, 1); ---- Green calavera mask
    SET_INT_GLOBAL(262145 + 30271, 1); ---- Navy calavera mask
    SET_INT_GLOBAL(262145 + 30272, 1); ---- Cherry calavera mask
    SET_INT_GLOBAL(262145 + 30273, 1); ---- Orange calavera mask
    SET_INT_GLOBAL(262145 + 30274, 1); ---- Purple calavera mask
    SET_INT_GLOBAL(262145 + 30275, 1); ---- Dark blue calavera mask
    SET_INT_GLOBAL(262145 + 30276, 1); ---- Lavender calavera mask
    SET_INT_GLOBAL(262145 + 30277, 1); ---- Yellow calavera mask
    SET_INT_GLOBAL(262145 + 30278, 1); ---- Pink calavera mask
    SET_INT_GLOBAL(262145 + 30279, 1); ---- Neon stich emissive mask
    SET_INT_GLOBAL(262145 + 30280, 1); ---- Vibrant stich emissive mask
    SET_INT_GLOBAL(262145 + 30281, 1); ---- Pink stich emissive mask
    SET_INT_GLOBAL(262145 + 30282, 1); ---- Blue stich emissive mask
    SET_INT_GLOBAL(262145 + 30283, 1); ---- Neon skull emissive mask
    SET_INT_GLOBAL(262145 + 30284, 1); ---- Vibrant skull emissive mask
    SET_INT_GLOBAL(262145 + 30285, 1); ---- Pink skull emissive mask
    SET_INT_GLOBAL(262145 + 30286, 1); ---- Orange skull emissive mask
    SET_INT_GLOBAL(262145 + 30287, 1); ---- Dark x-ray emissive mask
    SET_INT_GLOBAL(262145 + 30288, 1); ---- Bright x-ray emissive mask
    SET_INT_GLOBAL(262145 + 30289, 1); ---- Purple x-ray emissive mask
    SET_INT_GLOBAL(262145 + 32832, 1); ---- Grimy Stitched
    SET_INT_GLOBAL(262145 + 32833, 1); ---- Pale Stitched
    SET_INT_GLOBAL(262145 + 32834, 1); ---- Grey Cracked Puppet
    SET_INT_GLOBAL(262145 + 32835, 1); ---- Blushed Cracked Puppet
    SET_INT_GLOBAL(262145 + 32836, 1); ---- Green Emissive Lady Liberty
    SET_INT_GLOBAL(262145 + 32837, 1); ---- President
    SET_INT_GLOBAL(262145 + 32852, 1); ---- Green Vintage Frank
    SET_INT_GLOBAL(262145 + 32853, 1); ---- Brown Vintage Frank
    SET_INT_GLOBAL(262145 + 32854, 1); ---- Grey Vintage Frank
    SET_INT_GLOBAL(262145 + 32855, 1); ---- Pale Vintage Mummy
    SET_INT_GLOBAL(262145 + 32856, 1); ---- Green Vintage Mummy
    SET_INT_GLOBAL(262145 + 32857, 1); ---- Weathered Vintage Mummy
    SET_INT_GLOBAL(262145 + 32858, 1); ---- White Vintage Mummy
    SET_INT_GLOBAL(262145 + 32859, 1); ---- Dark Green Vintage Vampire
    SET_INT_GLOBAL(262145 + 32860, 1); ---- Light Green Vintage Vampire
    SET_INT_GLOBAL(262145 + 32864, 1); ---- Conquest
    SET_INT_GLOBAL(262145 + 32865, 1); ---- Death
    SET_INT_GLOBAL(262145 + 32866, 1); ---- Famine
    SET_INT_GLOBAL(262145 + 32867, 1); ---- War
    SET_INT_GLOBAL(262145 + 32868, 1); ---- Black Tech Demon
    SET_INT_GLOBAL(262145 + 32869, 1); ---- Grey Tech Demon
    SET_INT_GLOBAL(262145 + 32870, 1); ---- White Tech Demon
    SET_INT_GLOBAL(262145 + 32871, 1); ---- Green Tech Demon
    SET_INT_GLOBAL(262145 + 32872, 1); ---- Orange Tech Demon
    SET_INT_GLOBAL(262145 + 32873, 1); ---- Purple Tech Demon
    SET_INT_GLOBAL(262145 + 32874, 1); ---- Pink Tech Demon
    SET_INT_GLOBAL(262145 + 32875, 1); ---- Red Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32876, 1); ---- Blue Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32877, 1); ---- Yellow Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32878, 1); ---- Green Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32879, 1); ---- Pink Detail Tech Demon
    SET_INT_GLOBAL(262145 + 32880, 1); ---- Orange And Grey Tech Demon
    SET_INT_GLOBAL(262145 + 32881, 1); ---- Red Tech Demon
    SET_INT_GLOBAL(262145 + 32882, 1); ---- Camo Tech Demon
    SET_INT_GLOBAL(262145 + 32883, 1); ---- Aqua Camo Tech Demon
    SET_INT_GLOBAL(262145 + 32884, 1); ---- Brown Digital Tech Demon
    SET_INT_GLOBAL(262145 + 32885, 1); ---- Gold Tech Demon
    SET_INT_GLOBAL(262145 + 32886, 1); ---- Orange and Cream Tech Demon
    SET_INT_GLOBAL(262145 + 32887, 1); ---- Green and Yellow Tech Demon
    SET_INT_GLOBAL(262145 + 32888, 1); ---- Pink Floral Tech Demon
    SET_INT_GLOBAL(262145 + 32889, 1); ---- Black and Green Tech Demon
    SET_INT_GLOBAL(262145 + 32890, 1); ---- hite and Red Tech Demon
    SET_INT_GLOBAL(262145 + 32891, 1); ---- Carbon Tech Demon
    SET_INT_GLOBAL(262145 + 32892, 1); ---- Carbon Teal Tech Demon
    SET_INT_GLOBAL(262145 + 32893, 1); ---- Black and White Tech Demon
    SET_INT_GLOBAL(262145 + 32894, 1); ---- Painted Tiger
    SET_INT_GLOBAL(262145 + 32895, 1); ---- Grey Painted Tiger
    SET_INT_GLOBAL(262145 + 32896, 1); ---- Gold Painted Tiger
    SET_INT_GLOBAL(262145 + 32897, 1); ---- Ornate Painted Tiger
    SET_INT_GLOBAL(262145 + 27518, 1) --- Ace Mask
    SET_INT_GLOBAL(262145 + 27519, 1) ---Ace Mask
    SET_INT_GLOBAL(262145 + 27520, 1) ---Ace Mask	S
    SET_INT_GLOBAL(262145 + 27521, 1) ---Ace Mask
    SET_INT_GLOBAL(262145 + 31842, 1); ---- Orange Goldfish Mask
    SET_INT_GLOBAL(262145 + 31843, 1); ---- Purple Goldfish Mask
    SET_INT_GLOBAL(262145 + 31844, 1); ---- Bronze Goldfish Mask
    SET_INT_GLOBAL(262145 + 31845, 1); ---- ("Clownfish Mask
    SET_INT_GLOBAL(262145 + 31846, 1); ---- Juvenile Gull Mask
    SET_INT_GLOBAL(262145 + 31847, 1); ---- Sooty Gull Mask
    SET_INT_GLOBAL(262145 + 31848, 1); ---- Black-headed Gull Mask
    SET_INT_GLOBAL(262145 + 31849, 1); ---- Herring Gull Mask
    SET_INT_GLOBAL(262145 + 31850, 1); ---- Brown Sea Lion Mask
    SET_INT_GLOBAL(262145 + 31851, 1); ---- Dark Sea Lion Mask
    SET_INT_GLOBAL(262145 + 31852, 1); ---- Spotted Sea Lion Mask
    SET_INT_GLOBAL(262145 + 31853, 1); ---- Gray Sea Lion Mask
    SET_INT_GLOBAL(262145 + 24247, 1); ---- Please Stop Me Mask
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisetas de DJ/DJ pooh", {}, "", function()
    SET_INT_GLOBAL(262145 + 30899, 1); ---- Palms Trax LS Tee
    SET_INT_GLOBAL(262145 + 30900, 1); ---- Moodymann Whatupdoe Tee
    SET_INT_GLOBAL(262145 + 30901, 1); ---- Moodymann Big D Tee
    SET_INT_GLOBAL(262145 + 30902, 1); ---- Keinemusik Cayo Perico Tee
    SET_INT_GLOBAL(262145 + 30903, 1); ---- Still Slipping Blarneys Tee
    SET_INT_GLOBAL(262145 + 30904, 1); ---- Still Slipping Friend Tee
    SET_INT_GLOBAL(262145 + 31186, 1); ---- eCola Bodysuit
    SET_INT_GLOBAL(262145 + 31187, 1); ---- Sprunk Bodysuit
    SET_INT_GLOBAL(262145 + 31854, 1); ---- Orange DJ Pohh Tee
    SET_INT_GLOBAL(262145 + 31855, 1); ---- White WCC DJ Pooh Tee
    SET_INT_GLOBAL(262145 + 31856, 1); ---- Blue WCC DJ Pooh Tee
    SET_INT_GLOBAL(262145 + 24946, 1); ---- "White Solomun Logo Tee"
    SET_INT_GLOBAL(262145 + 24947, 1); ---- "White Solomun Pocket Logo Tee"
    SET_INT_GLOBAL(262145 + 24948, 1); ---- "Black And Yellow Solomun Tee"
    SET_INT_GLOBAL(262145 + 24949, 1); ---- "Black Solomun White Logo Tee"
    SET_INT_GLOBAL(262145 + 24950, 1); ---- "Black And White Solomun Tee"
    SET_INT_GLOBAL(262145 + 24951, 1); ---- "Black Solomun Pocket Logo Tee"
    SET_INT_GLOBAL(262145 + 24952, 1); ---- "Dixon Box logo Tee"
    SET_INT_GLOBAL(262145 + 24953, 1); ---- "Dixon Pocket logo Tee"
    SET_INT_GLOBAL(262145 + 24954, 1); ---- "White Dixon Wilderness Tee"
    SET_INT_GLOBAL(262145 + 24955, 1); ---- "Dixon Green Logo Tee"
    SET_INT_GLOBAL(262145 + 24956, 1); ---- "Dixon Glitch Logo Tee"
    SET_INT_GLOBAL(262145 + 24957, 1); ---- "Black Dixon Repeated Logo Tee"
    SET_INT_GLOBAL(262145 + 24958, 1); ---- "Tale Of Us Box Logo Tee"
    SET_INT_GLOBAL(262145 + 24959, 1); ---- "White Tale Of Us Logo Tee"
    SET_INT_GLOBAL(262145 + 24960, 1); ---- "White Tale Of Us Emb. Tee"
    SET_INT_GLOBAL(262145 + 24961, 1); ---- "Black Tale Of Us 0Logo Tee"
    SET_INT_GLOBAL(262145 + 24962, 1); ---- "Tale Of Us Stacked Logo Tee"
    SET_INT_GLOBAL(262145 + 24963, 1); ---- "Tale Of Us Afterlight Tee"
    SET_INT_GLOBAL(262145 + 24964, 1); ---- "White The Black Madonna Tee"
    SET_INT_GLOBAL(262145 + 24965, 1); ---- "Black The Black Madonna Tee"
    SET_INT_GLOBAL(262145 + 24966, 1); ---- "White The Black Madonna Emb. Tee"
    SET_INT_GLOBAL(262145 + 24967, 1); ---- "White The Black Madonna Init. Tee"
    SET_INT_GLOBAL(262145 + 24968, 1); ---- "Black The Black Madonna Init. Tee"
    SET_INT_GLOBAL(262145 + 24969, 1); ---- "The Black Madonna We Believe Tee"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Paraquedas", {}, "", function()
    SET_INT_GLOBAL(262145 + 31188, 1); ---- Sprunk Parachute Bag
    SET_INT_GLOBAL(262145 + 31189, 1); ---- eCola Parachute Bag
    SET_INT_GLOBAL(262145 + 31190, 1); ---- Halloween Parachute Bag
    SET_INT_GLOBAL(262145 + 24248, 1); ---- Highflyer Parachute Bag
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Sapatos", {}, "", function()
    SET_INT_GLOBAL(262145 + 32924, 1); ---- Wild Striped Pool Sliders
    SET_INT_GLOBAL(262145 + 32925, 1); ---- Neon Striped Pool Sliders
    SET_INT_GLOBAL(262145 + 32926, 1); ---- Black SC Coin Pool Sliders
    SET_INT_GLOBAL(262145 + 32927, 1); ---- White SC Coin Pool Sliders
    SET_INT_GLOBAL(262145 + 32928, 1); ---- Black SC Pattern Pool Sliders
    SET_INT_GLOBAL(262145 + 32929, 1); ---- Pink SC Pattern Pool Sliders
    SET_INT_GLOBAL(262145 + 32930, 1); ---- Blue SC Pattern Pool Sliders
    SET_INT_GLOBAL(262145 + 32931, 1); ---- Camo Yeti Pool Sliders
    SET_INT_GLOBAL(262145 + 32932, 1); ---- Grey Camo Yeti Pool Sliders
    SET_INT_GLOBAL(262145 + 32933, 1); ---- Black Bigness Pool Sliders
    SET_INT_GLOBAL(262145 + 32934, 1); ---- Purple Bigness Pool Sliders
    SET_INT_GLOBAL(262145 + 32935, 1); ---- Camo Bigness Pool Sliders
    SET_INT_GLOBAL(262145 + 32936, 1); ---- Black Blaguers Pool Sliders
    SET_INT_GLOBAL(262145 + 32937, 1); ---- White Blaguers Pool Sliders
    SET_INT_GLOBAL(262145 + 32938, 1); ---- Pink Blaguers Pool Sliders
    SET_INT_GLOBAL(262145 + 32939, 1); ---- Grey Cimicino Pool Sliders
    SET_INT_GLOBAL(262145 + 32940, 1); ---- Rouge Cimicino Pool Sliders
    SET_INT_GLOBAL(262145 + 32941, 1); ---- Navy DS Pool Sliders
    SET_INT_GLOBAL(262145 + 32942, 1); ---- Red DS Pool Sliders
    SET_INT_GLOBAL(262145 + 32943, 1); ---- Floral Guffy Pool Sliders
    SET_INT_GLOBAL(262145 + 32944, 1); ---- Green Guffy Pool Sliders
    SET_INT_GLOBAL(262145 + 32945, 1); ---- White Guffy Pool Sliders
    SET_INT_GLOBAL(262145 + 32946, 1); ---- Blue Heat Pool Sliders
    SET_INT_GLOBAL(262145 + 32947, 1); ---- Red ProLaps Pool Sliders
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "camisas arcade", {}, "", function()
    SET_INT_GLOBAL(262145 + 28304, 1); ---- "Street Crimes Boxart Tee"
    SET_INT_GLOBAL(262145 + 28305, 1); ---- "Street Crimes Logo Tee"
    SET_INT_GLOBAL(262145 + 28306, 1); ---- "("Claim What's Yours Tee"
    SET_INT_GLOBAL(262145 + 28307, 1); ---- "Choose Your Side Tee"
    SET_INT_GLOBAL(262145 + 28308, 1); ---- "Street Crimes Color Gangs Tee"
    SET_INT_GLOBAL(262145 + 28309, 1); ---- "Street Crimes Red Gangs Tee"
    SET_INT_GLOBAL(262145 + 28310, 1); ---- "White Street Crimes Icons Tee"
    SET_INT_GLOBAL(262145 + 28311, 1); ---- "Black Street Crimes Icons Tee"
    SET_INT_GLOBAL(262145 + 28312, 1); ---- "Invade and Persuade Logo Tee"
    SET_INT_GLOBAL(262145 + 28313, 1); ---- "Mission I Tee"
    SET_INT_GLOBAL(262145 + 28314, 1); ---- "Mission II Tee"
    SET_INT_GLOBAL(262145 + 28315, 1); ---- "Mission IV Tee"
    SET_INT_GLOBAL(262145 + 28316, 1); ---- "Mission III Tee"
    SET_INT_GLOBAL(262145 + 28317, 1); ---- "Invade and Persuade Boxart Tee"
    SET_INT_GLOBAL(262145 + 28318, 1); ---- "Invade and Persuade Invader Tee"
    SET_INT_GLOBAL(262145 + 28319, 1); ---- "Invade and Persuade Suck Tee"
    SET_INT_GLOBAL(262145 + 28320, 1); ---- "Invade and Persuade Jets Tee"
    SET_INT_GLOBAL(262145 + 28321, 1); ---- "Invade and Persuade Gold Tee"
    SET_INT_GLOBAL(262145 + 28322, 1); ---- "Invade and Persuade Hero Tee"
    SET_INT_GLOBAL(262145 + 28323, 1); ---- "Invade and Persuade Barrels Tee"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisas Cassino", {}, "", function()
    SET_INT_GLOBAL(262145 + 27015, 1); ---- "The Diamond ("Classics Tee"
    SET_INT_GLOBAL(262145 + 27016, 1); ---- "The Diamond Vintage Tee"
    SET_INT_GLOBAL(262145 + 27017, 1); ---- "Red The Diamond Resort LS Tee"
    SET_INT_GLOBAL(262145 + 27018, 1); ---- "Blue The Diamond Resort LS Tee"
    SET_INT_GLOBAL(262145 + 27019, 1); ---- "Red The Diamond Resort Tee"
    SET_INT_GLOBAL(262145 + 27020, 1); ---- "Blue D Casino Tee"
    SET_INT_GLOBAL(262145 + 27021, 1); ---- "Red The Diamond ("Classic Tee"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisola Festiva", {}, "", function()
    SET_INT_GLOBAL(262145 + 25898, 1); ---- "Burger Shot Festive Sweater"
    SET_INT_GLOBAL(262145 + 25899, 1); ---- "Red Bleeder Festive Sweater"
    SET_INT_GLOBAL(262145 + 25900, 1); ---- "Blue Bleeder Festive Sweater"
    SET_INT_GLOBAL(262145 + 25901, 1); ---- "Blue ("Cluckin' Festive Sweater"
    SET_INT_GLOBAL(262145 + 25902, 1); ---- "Green ("Cluckin' Festive Sweater"
    SET_INT_GLOBAL(262145 + 25903, 1); ---- "Blue Slaying Festive Sweater"
    SET_INT_GLOBAL(262145 + 25904, 1); ---- "Green Slaying Festive Sweater"
    SET_INT_GLOBAL(262145 + 25905, 1); ---- "Hail Santa Festive Sweater"
    SET_INT_GLOBAL(262145 + 25906, 1); ---- "Merrry Sprunkmas Festive Sweater"
    SET_INT_GLOBAL(262145 + 25907, 1); ---- "Ice Cold Sprunk Festive Sweater"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Fabricante de Camisas", {}, "", function()
    SET_INT_GLOBAL(262145 + 25830, 1); ---- "Albany Tee"
    SET_INT_GLOBAL(262145 + 25831, 1); ---- "Albany Vintage Tee"
    SET_INT_GLOBAL(262145 + 25832, 1); ---- "Annis Tee"
    SET_INT_GLOBAL(262145 + 25833, 1); ---- "Benefector Tee"
    SET_INT_GLOBAL(262145 + 25834, 1); ---- "BF Tee"
    SET_INT_GLOBAL(262145 + 25835, 1); ---- "Bollokan Tee"
    SET_INT_GLOBAL(262145 + 25836, 1); ---- "Bravado Tee"
    SET_INT_GLOBAL(262145 + 25837, 1); ---- "Brute Tee"
    SET_INT_GLOBAL(262145 + 25838, 1); ---- "Buckingham Tee"
    SET_INT_GLOBAL(262145 + 25839, 1); ---- "Canis Tee"
    SET_INT_GLOBAL(262145 + 25840, 1); ---- "Chariot Tee"
    SET_INT_GLOBAL(262145 + 25841, 1); ---- "Cheval Tee"
    SET_INT_GLOBAL(262145 + 25842, 1); ---- "("Classigue Tee"
    SET_INT_GLOBAL(262145 + 25843, 1); ---- "Coil Tee"
    SET_INT_GLOBAL(262145 + 25844, 1); ---- "De("classe Tee"
    SET_INT_GLOBAL(262145 + 25845, 1); ---- "Dewbauchee Tee"
    SET_INT_GLOBAL(262145 + 25846, 1); ---- "Dilettante Tee"
    SET_INT_GLOBAL(262145 + 25847, 1); ---- "Dinka Tee"
    SET_INT_GLOBAL(262145 + 25848, 1); ---- "Dundreary Tee"
    SET_INT_GLOBAL(262145 + 25849, 1); ---- "Emperor Tee"
    SET_INT_GLOBAL(262145 + 25850, 1); ---- "Enus Tee"
    SET_INT_GLOBAL(262145 + 25851, 1); ---- "Fathom Tee"
    SET_INT_GLOBAL(262145 + 25852, 1); ---- "Gallivanter Tee"
    SET_INT_GLOBAL(262145 + 25853, 1); ---- "Grotti Tee"
    SET_INT_GLOBAL(262145 + 25854, 1); ---- "Hijak Tee"
    SET_INT_GLOBAL(262145 + 25855, 1); ---- "HVT Tee"
    SET_INT_GLOBAL(262145 + 25856, 1); ---- "Imponte Tee"
    SET_INT_GLOBAL(262145 + 25857, 1); ---- "Invetero Tee"
    SET_INT_GLOBAL(262145 + 25858, 1); ---- "Jobuilt Tee"
    SET_INT_GLOBAL(262145 + 25859, 1); ---- "Karin Tee"
    SET_INT_GLOBAL(262145 + 25860, 1); ---- "Lampadati Tee"
    SET_INT_GLOBAL(262145 + 25861, 1); ---- "Maibatsu Tee"
    SET_INT_GLOBAL(262145 + 25862, 1); ---- "Mamba Tee"
    SET_INT_GLOBAL(262145 + 25863, 1); ---- "Mammoth Tee"
    SET_INT_GLOBAL(262145 + 25864, 1); ---- "MTL Tee"
    SET_INT_GLOBAL(262145 + 25865, 1); ---- "Obey Tee"
    SET_INT_GLOBAL(262145 + 25866, 1); ---- "Ocelot Tee"
    SET_INT_GLOBAL(262145 + 25867, 1); ---- "Overflod Tee"
    SET_INT_GLOBAL(262145 + 25868, 1); ---- "Pegassi Tee"
    SET_INT_GLOBAL(262145 + 25869, 1); ---- "Pfister Tee"
    SET_INT_GLOBAL(262145 + 25870, 1); ---- "Progen Tee"
    SET_INT_GLOBAL(262145 + 25871, 1); ---- "Rune Tee"
    SET_INT_GLOBAL(262145 + 25872, 1); ---- "Schyster Tee"
    SET_INT_GLOBAL(262145 + 25873, 1); ---- "Shitzu Tee"
    SET_INT_GLOBAL(262145 + 25874, 1); ---- "Truffade Tee"
    SET_INT_GLOBAL(262145 + 25875, 1); ---- "Ubermacht Tee"
    SET_INT_GLOBAL(262145 + 25876, 1); ---- "Vapid Tee"
    SET_INT_GLOBAL(262145 + 25877, 1); ---- "Vulcar Tee"
    SET_INT_GLOBAL(262145 + 25878, 1); ---- "Weeny Tee"
    SET_INT_GLOBAL(262145 + 25879, 1); ---- "Willard Tee"
    SET_INT_GLOBAL(262145 + 25880, 1); ---- "Albany Nostalgia Tee"
    SET_INT_GLOBAL(262145 + 25881, 1); ---- "Albany USA Tee"
    SET_INT_GLOBAL(262145 + 25882, 1); ---- "Albany Dealership Tee"
    SET_INT_GLOBAL(262145 + 25883, 1); ---- "Annis JPN Tee"
    SET_INT_GLOBAL(262145 + 25884, 1); ---- "BF Surfer Tee"
    SET_INT_GLOBAL(262145 + 25885, 1); ---- "Bollokan Prairie Tee"
    SET_INT_GLOBAL(262145 + 25886, 1); ---- "Bravado Stylized Tee"
    SET_INT_GLOBAL(262145 + 25887, 1); ---- "Brute Impregnable Tee"
    SET_INT_GLOBAL(262145 + 25888, 1); ---- "Brute Heavy Duty Tee"
    SET_INT_GLOBAL(262145 + 25889, 1); ---- "Buckingham Luxe Tee"
    SET_INT_GLOBAL(262145 + 25890, 1); ---- "Canis USA Tee"
    SET_INT_GLOBAL(262145 + 25891, 1); ---- "Canis American Legend Tee"
    SET_INT_GLOBAL(262145 + 25892, 1); ---- "Canis Wolf Tee"
    SET_INT_GLOBAL(262145 + 25893, 1); ---- "Cheval Marshall Tee"
    SET_INT_GLOBAL(262145 + 25894, 1); ---- "Coil USA Tee"
    SET_INT_GLOBAL(262145 + 25895, 1); ---- "Coil Raiden Tee"
    SET_INT_GLOBAL(262145 + 25896, 1); ---- "De("classe Logo Tee"
    SET_INT_GLOBAL(262145 + 25897, 1); ---- "De("classe Girl Tee
    SET_INT_GLOBAL(262145 + 15222, 1); ---- "Grotti Shirt"
    SET_INT_GLOBAL(262145 + 17580, 1); ---- "Western Brand White Tee"
    SET_INT_GLOBAL(262145 + 17581, 1); ---- "Western Brand Black Tee"
    SET_INT_GLOBAL(262145 + 17582, 1); ---- "Western Logo White Tee"
    SET_INT_GLOBAL(262145 + 17583, 1); ---- "Western Logo Black Tee"
    SET_INT_GLOBAL(262145 + 17584, 1); ---- "Steel Horse Solid Logo Tee"
    SET_INT_GLOBAL(262145 + 17585, 1); ---- "Steel Horse Logo Tee"
    SET_INT_GLOBAL(262145 + 17586, 1); ---- "Steel Horse Brand White Tee"
    SET_INT_GLOBAL(262145 + 17587, 1); ---- "Steel Horse Brand Black Tee"
    SET_INT_GLOBAL(262145 + 17588, 1); ---- "Nagasaki White Tee"
    SET_INT_GLOBAL(262145 + 17589, 1); ---- "Nagasaki White And Red Tee"
    SET_INT_GLOBAL(262145 + 17590, 1); ---- "Nagasaki Black Tee"
    SET_INT_GLOBAL(262145 + 17591, 1); ---- "Purple Helmets Black Tee"
    SET_INT_GLOBAL(262145 + 17592, 1); ---- "Principe Black Tee"
    SET_INT_GLOBAL(262145 + 17593, 1); ---- "Steel Horse Black Hoodie"
    SET_INT_GLOBAL(262145 + 17594, 1); ---- "Steel Horse White Hoodie"
    SET_INT_GLOBAL(262145 + 17595, 1); ---- "Western Black Hoodie"
    SET_INT_GLOBAL(262145 + 17596, 1); ---- "Western White Hoodie"
    SET_INT_GLOBAL(262145 + 17597, 1); ---- "Nagasaki White Hoodie"
    SET_INT_GLOBAL(262145 + 17598, 1); ---- "Nagasaki White And Red Hoodie"
    SET_INT_GLOBAL(262145 + 17599, 1); ---- "Nagasaki Black Hoodie"
    SET_INT_GLOBAL(262145 + 17600, 1); ---- "Purple Helmets Black Hoodie"
    SET_INT_GLOBAL(262145 + 17601, 1); ---- "Principe Hoodie Black"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Fatos de Dublês", {}, "", function()
    SET_INT_GLOBAL(262145 + 16839, 1); ---- "White Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16840, 1); ---- "Blue Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16841, 1); ---- "Red Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16842, 1); ---- "Gold Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16843, 1); ---- "Black Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16844, 1); ---- "Pink Jock Cranley Suit"
    SET_INT_GLOBAL(262145 + 16845, 1); ---- "Silver Jock Cranley Suit"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Bodysuits Wireframe", {}, "", function()
    SET_INT_GLOBAL(262145 + 23435, 1); ---- "Green Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23436, 1); ---- "Orange Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23437, 1); ---- "Blue Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23438, 1); ---- "Pink Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23439, 1); ---- "Yellow Wireframe Bodysuit"
    SET_INT_GLOBAL(262145 + 23435, 1); ---- Bodysuit Green
    SET_INT_GLOBAL(262145 + 23436, 1); ---- Bodysuit Orange
    SET_INT_GLOBAL(262145 + 23437, 1); ---- Bodysuit Blue
    SET_INT_GLOBAL(262145 + 23438, 1); ---- Bodysuit Pink
    SET_INT_GLOBAL(262145 + 23439, 1); ---- Bodysuit Yellow
end)

menu.action(UNLOCK_ROUPAS, "Camisas", {}, "", function()
    SET_INT_GLOBAL(262145 + 21155, 1); ---- "BLACK_AMMUNATION_TEE"
    SET_INT_GLOBAL(262145 + 21157, 1); ---- "BLACK_COIL_TEE"
    SET_INT_GLOBAL(262145 + 21159, 1); ---- "BLACK_HAWK_AND_LITTLE_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21160, 1); ---- "BLACK_HAWK_AND_LITTLE_TEE"
    SET_INT_GLOBAL(262145 + 21164, 1); ---- "GREEN_VOM_FEUER_TEE"
    SET_INT_GLOBAL(262145 + 21167, 1); ---- "WHITE_AMMUNATION_TEE"
    SET_INT_GLOBAL(262145 + 21169, 1); ---- "WHITE_COIL_TEE"
    SET_INT_GLOBAL(262145 + 21171, 1); ---- "WHITE_HAWK_AND_LITTLE_TEE"
    SET_INT_GLOBAL(262145 + 21172, 1); ---- "WHITE_SHREWSBURY_TEE"
    SET_INT_GLOBAL(262145 + 21175, 1); ---- "WHITE_SHREWSBURY_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21179, 1); ---- "YELLOW_VOM_FEUER_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21180, 1); ---- "YELLOW_VOM_FEUER_TEE"
    SET_INT_GLOBAL(262145 + 21181, 1); ---- "YELLOW_WARSTOCK_TEE"
    SET_INT_GLOBAL(262145 + 21182, 1); ---- "BLUE_R*_("CLASS_OF_98"
    SET_INT_GLOBAL(262145 + 21183, 1); ---- "RED_R*_("CLASS_OF_98"
    SET_INT_GLOBAL(262145 + 21184, 1); ---- "NOISE_ROCKSTAR_LOGO_TEE"
    SET_INT_GLOBAL(262145 + 21185, 1); ---- "NOISE_TEE"
    SET_INT_GLOBAL(262145 + 21186, 1); ---- "RAZOR_TEE"
    SET_INT_GLOBAL(262145 + 21187, 1); ---- "BLACK_ROCKSTAR_CAMO"
    SET_INT_GLOBAL(262145 + 21188, 1); ---- "WHITE_ROCKSTAR_CAMO"
    SET_INT_GLOBAL(262145 + 21189, 1); ---- "KNUCKLEDUSTER_POCKET_TEE"
    SET_INT_GLOBAL(262145 + 21190, 1); ---- "ROCKSTAR_LOGO_BLACKED_OUT_TEE"
    SET_INT_GLOBAL(262145 + 21191, 1); ---- "ROCKSTAR_LOGO_WHITE_OUT_TEE"
    SET_INT_GLOBAL(262145 + 25698, 1); ---- "Kifflom Tee"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Moletons", {}, "", function()
    SET_INT_GLOBAL(262145 + 21154, 1); ---- "BLACK_AMMUNATION_HOODIE"
    SET_INT_GLOBAL(262145 + 21158, 1); ---- "BLACK_HAWK_AND_LITTLE_HODDIE"
    SET_INT_GLOBAL(262145 + 21161, 1); ---- "BLACK_SHREWSBURY_HOODIE"
    SET_INT_GLOBAL(262145 + 21163, 1); ---- "BLACK_WARSTOCK_HOODIE"
    SET_INT_GLOBAL(262145 + 21168, 1); ---- "WHITE_COIL_HOODIE"
    SET_INT_GLOBAL(262145 + 21170, 1); ---- "WHITE_HAWK_AND_LITTLE_HOODIE"
    SET_INT_GLOBAL(262145 + 21174, 1); ---- "WHITE_SHREWSBURY_HOODIE"
    SET_INT_GLOBAL(262145 + 21177, 1); ---- "WHITE_VOM_FEUER_HOODIE"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisetas dos clubes", {}, "", function()
    SET_INT_GLOBAL(262145 + 24732, 1); ---- "Maisonette Los Santos T-Shirt"
    SET_INT_GLOBAL(262145 + 24733, 1); ---- "Studio Los Santos T-Shirt"
    SET_INT_GLOBAL(262145 + 24734, 1); ---- "Galaxy T-Shirt"
    SET_INT_GLOBAL(262145 + 24735, 1); ---- "Gefängnis T-Shirt"
    SET_INT_GLOBAL(262145 + 24736, 1); ---- "Omega T-Shirt"
    SET_INT_GLOBAL(262145 + 24737, 1); ---- "Technologie T-Shirt"
    SET_INT_GLOBAL(262145 + 24738, 1); ---- "Paradise T-Shirt"
    SET_INT_GLOBAL(262145 + 24739, 1); ---- "The Palace T-Shirt"
    SET_INT_GLOBAL(262145 + 24740, 1); ---- "Tony's Fun House T-Shirt"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisas de filme", {}, "", function()
    SET_INT_GLOBAL(262145 + 11952, 1); ---- "MELTDOWN"
    SET_INT_GLOBAL(262145 + 11953, 1); ---- "VINEWOOD_ZOMBIE"
    SET_INT_GLOBAL(262145 + 11954, 1); ---- "I_MARRIED_MY_DAD"
    SET_INT_GLOBAL(262145 + 11955, 1); ---- "DIE_ALREADY_4"
    SET_INT_GLOBAL(262145 + 11956, 1); ---- "THE_SHOULDER_OF_ORION_II"
    SET_INT_GLOBAL(262145 + 11957, 1); ---- "NELSON_IN_NAPLES"
    SET_INT_GLOBAL(262145 + 11958, 1); ---- "THE_MANY_WIVES_OF_ALFREDO_SMITH"
    SET_INT_GLOBAL(262145 + 11959, 1); ---- "AN_AMERICAN_DIVORCE"
    SET_INT_GLOBAL(262145 + 11960, 1); ---- "THE_LONELIEST_ROBOT"
    SET_INT_GLOBAL(262145 + 11961, 1); ---- "CAPOLAVORO"
    SET_INT_GLOBAL(262145 + 12598, 1); ---- "Vinewood Zombie Shirt"
    SET_INT_GLOBAL(262145 + 12599, 1); ---- "Knife After Dark Shirt"
    SET_INT_GLOBAL(262145 + 12600, 1); ---- "The Simian Shirt"
    SET_INT_GLOBAL(262145 + 12601, 1); ---- "Zombie Liberals In The Midwest Shirt"
    SET_INT_GLOBAL(262145 + 12602, 1); ---- "Twilight Knife Shirt"
    SET_INT_GLOBAL(262145 + 12603, 1); ---- "Butchery and Other Hobbies Shirt"
    SET_INT_GLOBAL(262145 + 12604, 1); ---- "Cheerleader Massacre 3 Shirt"
    SET_INT_GLOBAL(262145 + 12605, 1); ---- "Cannibal ("Clown Shirt"
    SET_INT_GLOBAL(262145 + 12606, 1); ---- "Hot Serial Killer Stepmom Shirt"
    SET_INT_GLOBAL(262145 + 12607, 1); ---- "Splatter And Shot Shirt"
    SET_INT_GLOBAL(262145 + 12608, 1); ---- "Meathook For Mommy Shirt"
    SET_INT_GLOBAL(262145 + 12609, 1); ---- "Psycho Swingers Shirt"
    SET_INT_GLOBAL(262145 + 12610, 1); ---- "Vampires On The Beach Shirt"
    SET_INT_GLOBAL(262145 + 15226, 1); ---- "Meltdown Shirt"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "knock offs", {}, "", function()
    SET_INT_GLOBAL(262145 + 24249, 1); ---- "Fake Perseus T-Shirt"
    SET_INT_GLOBAL(262145 + 24250, 1); ---- "Fake Santo Capra T-Shirt"
    SET_INT_GLOBAL(262145 + 24251, 1); ---- "Fake Dix White T-Shirt"
    SET_INT_GLOBAL(262145 + 24252, 1); ---- "Fake Le Chien Crew T-Shirt"
    SET_INT_GLOBAL(262145 + 24253, 1); ---- "Fake Enema T-Shirt"
    SET_INT_GLOBAL(262145 + 24254, 1); ---- "Fake Dix Gold T-Shirt"
    SET_INT_GLOBAL(262145 + 24255, 1); ---- "Fake Le Chien No2 T-Shirt"
    SET_INT_GLOBAL(262145 + 24256, 1); ---- "Fake Seesanta Nove T-Shirt"
    SET_INT_GLOBAL(262145 + 24257, 1); ---- "Fake Didier Sachs T-Shirt"
    SET_INT_GLOBAL(262145 + 24258, 1); ---- "Fake Vapid T-Shirt"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Camisas de Marcas", {}, "", function()
    SET_INT_GLOBAL(262145 + 15219, 1); ---- "Accountant Shirt"
    SET_INT_GLOBAL(262145 + 15220, 1); ---- "Bahamamamas Shirt"
    SET_INT_GLOBAL(262145 + 15221, 1); ---- "Drone Shirt"
    SET_INT_GLOBAL(262145 + 15223, 1); ---- "Golf Shirt"
    SET_INT_GLOBAL(262145 + 15224, 1); ---- "Maisonette Shirt"
    SET_INT_GLOBAL(262145 + 15225, 1); ---- "Manopause Shirt"
    SET_INT_GLOBAL(262145 + 15227, 1); ---- "Pacific Bluffs Shirt"
    SET_INT_GLOBAL(262145 + 15228, 1); ---- "Prolaps Shirt"
    SET_INT_GLOBAL(262145 + 15229, 1); ---- "Tennis Shirt"
    SET_INT_GLOBAL(262145 + 15230, 1); ---- "Toe Shirt"
    SET_INT_GLOBAL(262145 + 15231, 1); ---- "Vanilla Unicorn Shirt"
    SET_INT_GLOBAL(262145 + 15232, 1); ---- "Marlowe Shirt"
    SET_INT_GLOBAL(262145 + 15233, 1); ---- "Crest Shirt"
    SET_INT_GLOBAL(262145 + 24233, 1); ---- "Crocs Bar T-Shirt"
    SET_INT_GLOBAL(262145 + 24234, 1); ---- "Base5 T-Shirt"
    SET_INT_GLOBAL(262145 + 24235, 1); ---- "BOBO T-Shirt"
    SET_INT_GLOBAL(262145 + 24236, 1); ---- "Bitch'n'Dog T-Shirt"
    SET_INT_GLOBAL(262145 + 24238, 1); ---- "Vivisection T-Shirt"
    SET_INT_GLOBAL(262145 + 24241, 1); ---- "Vinyl Countdown T-Shirt"
    SET_INT_GLOBAL(262145 + 24243, 1); ---- "Victory Fist T-Shirt"
    SET_INT_GLOBAL(262145 + 24246, 1); ---- "Homie Sharp T-Shirt"
    SET_INT_GLOBAL(262145 + 8302, 1); ---- "Statue of Happiness T-shirt"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "vestuario de natal ", {}, "", function()
    SET_INT_GLOBAL(262145 + 12708, 1); ---- Festive masks  	(2015)
    SET_INT_GLOBAL(262145 + 12709, 1); ---- Festive Pajamas	(2015)
    SET_INT_GLOBAL(262145 + 19301, 1); ---- "christmas2016_("clothing"
    SET_INT_GLOBAL(262145 + 23084, 1); ---- "christmas2017_("clothing"
end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_ROUPAS, "Sasquatch", {}, "", function()
    SET_INT_GLOBAL(262145 + 32848, 1);
end)
------------------------------------------------------------------------------------------------------------------------------
local UNLOCK_RISK = menu.list(UNLOCK_ALL, "Possível Risco", { "" },
    "Aqui você tem que estar ciente que pode dar BANIMENTO, não venha reclamar depois, EU AVISEI!!!!!!", function()

end)
------------------------------------------------------------------------------------------------------------------------------
menu.action(UNLOCK_RISK, "Preço de Negociação", {}, "2 semanas de teste(sem relato de ban)", function()
    STAT_SET_INT("GANGOPS_FLOW_BITSET_MISS0", -1) ---Desbloqueie o preço de negociação de alguns veículos
    STAT_SET_INT("LFETIME_HANGAR_BUY_UNDETAK", 42)
    STAT_SET_INT("LFETIME_HANGAR_BUY_COMPLET", 42)
    STAT_SET_INT("AT_FLOW_IMPEXP_NUM", 32)
    STAT_SET_INT("AT_FLOW_VEHICLE_BS", -1)
    STAT_SET_INT("WVM_FLOW_VEHICLE_BS", -1)
    STAT_SET_INT("H3_BOARD_DIALOGUE0", -1)
    STAT_SET_INT("H3_BOARD_DIALOGUE1", -1)
    STAT_SET_INT("H3_BOARD_DIALOGUE2", -1)
    STAT_SET_INT("H3_VEHICLESUSED", -1)
    STAT_SET_INT("WAM_FLOW_VEHICLE_BS", -1)
    STAT_SET_BOOL("HELP_VETO", true)
    STAT_SET_BOOL("HELP_VETO2", true)
    STAT_SET_BOOL("HELP_ITALIRSX", true)
    STAT_SET_BOOL("HELP_BRIOSO2", true)
    STAT_SET_BOOL("HELP_MANCHEZ2", true)
    STAT_SET_BOOL("HELP_SLAMTRUCK", true)
    STAT_SET_BOOL("HELP_VETIR", true)
    STAT_SET_BOOL("HELP_SQUADDIE", true)
    STAT_SET_BOOL("HELP_DINGY5", true)
    STAT_SET_BOOL("HELP_VERUS", true)
    STAT_SET_BOOL("HELP_WEEVIL", true)
    STAT_SET_BOOL("HELP_VEHUNTUNER", true)
    STAT_SET_BOOL("FIXER_VEH_HELP", true)
    STAT_SET_BOOL("HELP_DOMINATOR7", true)
    STAT_SET_BOOL("HELP_JESTER4", true)
    STAT_SET_BOOL("HELP_FUTO2", true)
    STAT_SET_BOOL("HELP_DOMINATOR8", true)
    STAT_SET_BOOL("HELP_PREVION", true)
    STAT_SET_BOOL("HELP_GROWLER", true)
    STAT_SET_BOOL("HELP_COMET6", true)
    STAT_SET_BOOL("HELP_VECTRE", true)
    STAT_SET_BOOL("HELP_SULTAN3", true)
    STAT_SET_BOOL("HELP_CYPHER", true)
    STAT_SET_INT("CRDEADLINE", -1) ---shotaro
end)

menu.action(UNLOCK_RISK, "Escola de Voo", {}, "Desbloqueia missões e premios", function()
    STAT_SET_BOOL("PILOT_ASPASSEDLESSON_0", true) ---Estatísticas da Escola de Voo
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_1", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_2", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_3", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_4", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_5", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_6", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_7", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_8", true)
    STAT_SET_BOOL("MPPLY_PILOT_ASPASSEDLESSON_9", true)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_0", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_1", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_2", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_3", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_4", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_5", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_6", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_7", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_8", 1)
    STAT_SET_INT("MPPLY_PILOT_SCHOOL_MEDAL_9", 1)
end)

menu.action(UNLOCK_RISK, "Paragon V1", {}, "", function()
    STAT_SET_INT("VCM_FLOW_PROGRESS", 1839072) -- paragon(blindado)
    STAT_SET_BOOL("AWD_LEADER", true)
end)

menu.action(UNLOCK_RISK, "Paragon V2", {}, "", function()
    STAT_SET_BOOL("VCM_FLOW_CS_RSC_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_BWL_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_MTG_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_OIL_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_DEF_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_FIN_SEEN", TRUE)
    STAT_SET_BOOL("CAS_VEHICLE_REWARD", FALSE)
    STAT_SET_INT("VCM_FLOW_PROGRESS", -1)
    STAT_SET_INT("VCM_STORY_PROGRESS", -1)
    STAT_SET_BOOL("CASINOPSTAT_BOOL0 ", TRUE)
    STAT_SET_BOOL("CASINOPSTAT_BOOL1 ", TRUE)
end)

menu.action(UNLOCK_RISK, "Paragon V3", {}, "", function()
    STAT_SET_INT("VCM_FLOW_PROGRESS", 1839072) -- paragon(blindado)
    STAT_SET_BOOL("AWD_LEADER", true)

    STAT_SET_BOOL("VCM_FLOW_CS_RSC_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_BWL_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_MTG_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_OIL_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_DEF_SEEN", TRUE)
    STAT_SET_BOOL("VCM_FLOW_CS_FIN_SEEN", TRUE)
    STAT_SET_BOOL("CAS_VEHICLE_REWARD", FALSE)
    STAT_SET_INT("VCM_FLOW_PROGRESS", -1)
    STAT_SET_INT("VCM_STORY_PROGRESS", -1)
    STAT_SET_BOOL("CASINOPSTAT_BOOL0 ", TRUE)
    STAT_SET_BOOL("CASINOPSTAT_BOOL1 ", TRUE)
end)

menu.action(UNLOCK_RISK, "LSC NÃO TESTADOS", {}, "", function()
    STAT_SET_INT("CHAR_FM_CARMOD_1_UNLCK", -1) ---LSC NÃO TESTADOS ---CIENTE DOS RISCOS
    STAT_SET_INT("CHAR_FM_CARMOD_2_UNLCK", -1)
    STAT_SET_INT("ADW_FMRALLYWONNAV", 1)
end)

menu.action(UNLOCK_RISK, "premios", {}, "", function()
    STAT_SET_BOOL("AWD_FM_GOLF_HOLES_IN_1", true) ---PREMIOS
    STAT_SET_BOOL("AWD_FM_GOLF_BIRDIES", true)
    STAT_SET_BOOL("AWD_FM_WON", true)
    STAT_SET_BOOL("AWD_FM_SHOOTRANG_TG_WON", true)
    STAT_SET_BOOL("AWD_FM_SHOOTRANG_RT_WON", true)
    STAT_SET_BOOL("AWD_FM_SHOOTRANG_CT_WON", true)
    STAT_SET_BOOL("AWD_FM_SHOOTRANG_GRAN_WON", true)
    STAT_SET_BOOL("AWD_FM_TENNIS_WON", true)
    STAT_SET_BOOL("AWD_FM_TENNIS_ACE", true)
    STAT_SET_BOOL("AWD_FM_TENNIS_5_SET_WINS", true)
    STAT_SET_BOOL("AWD_FM_TENNIS_STASETWIN", true)
    STAT_SET_BOOL("AWD_FM_GTA_RACES_WON", true)
    STAT_SET_BOOL("AWD_FM_RACES_FASTEST_LAP", true)
    STAT_SET_BOOL("AWD_FM_RACE_LATS_FIRST", true)
    STAT_SET_BOOL("AWD_FM_DM_WINS", true)
    STAT_SET_BOOL("AWD_FM_TDM_WINS", true)
    STAT_SET_BOOL("AWD_FM_TDM_MVP", true)
    STAT_SET_BOOL("AWD_FM_DM_KILLSTREAK", true)
    STAT_SET_BOOL("AWD_FM_DM_TOTALKILLS", true)
    STAT_SET_BOOL("AWD_FM_DM_3KILLSAMEGUY", true)
    STAT_SET_BOOL("AWD_FM_DM_STOLENKILL", true)
    STAT_SET_INT("AWD_MENTALSTATE_TO_NORMAL", 25)
    STAT_SET_INT("AWD_TRADE_IN_YOUR_PROPERTY", 25)
    STAT_SET_INT("AWD_CONTROL_CROWDS", 25)
end)

menu.action(UNLOCK_RISK, "Estatísticas Bool", {}, "", function()
    STAT_SET_BOOL("MPPLY_AWD_FLEECA_FIN", true) ---ESTATÍSTICAS BOOL
    STAT_SET_BOOL("MPPLY_AWD_PRISON_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_HUMANE_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_SERIESA_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_PACIFIC_FIN", true)
    STAT_SET_BOOL("MPPLY_AWD_HST_ORDER", true)
    STAT_SET_BOOL("MPPLY_AWD_HST_SAME_TEAM", true)
    STAT_SET_BOOL("MPPLY_AWD_HST_ULT_CHAL", true)
    STAT_SET_BOOL("AWD_BEGINNER", true)
    STAT_SET_BOOL("AWD_FIELD_FILLER", true)
    STAT_SET_BOOL("AWD_ARMCHAIR_RACER", true)
    STAT_SET_BOOL("AWD_LEARNER", true)
    STAT_SET_BOOL("AWD_SUNDAY_DRIVER", true)
    STAT_SET_BOOL("AWD_THE_ROOKIE", true)
    STAT_SET_BOOL("AWD_BUMP_AND_RUN", true)
    STAT_SET_BOOL("AWD_GEAR_HEAD", true)
    STAT_SET_BOOL("AWD_DOOR_SLAMMER", true)
    STAT_SET_BOOL("AWD_HOT_LAP", true)
    STAT_SET_BOOL("AWD_ARENA_AMATEUR", true)
    STAT_SET_BOOL("AWD_SHUNTER", true)
    STAT_SET_BOOL("AWD_JOCK", true)
    STAT_SET_BOOL("AWD_T_BONE", true)
    STAT_SET_BOOL("AWD_WRECKER", true)
    STAT_SET_BOOL("AWD_PEGASUS", true)
    STAT_SET_BOOL("AWD_UNSTOPPABLE", true)
    STAT_SET_BOOL("SR_TIER_1_REWARD", true)
    STAT_SET_BOOL("SR_INCREASE_THROW_CAP", true)
    STAT_SET_BOOL("MPPLY_AWD_GANGOPS_SUBMARINE", true)
    STAT_SET_BOOL("MPPLY_AWD_GANGOPS_LOYALTY", true)
    STAT_SET_BOOL("MPPLY_AWD_GANGOPS_MISSILE", true)
    STAT_SET_BOOL("MPPLY_AWD_GANGOPS_LOYALTY3", true)
    STAT_SET_BOOL("MPPLY_AWD_GANGOPS_CRIMMASMD3", true)
    STAT_SET_BOOL("MPPLY_AWD_GANGOPS_SUPPORT", true)
end)

menu.toggle_loop(UNLOCK_RISK, "Classic Heist: 100%", {}, "Make sure enabled until end of the heist!", function()
    SET_INT_GLOBAL(1933908 + 3008 + 1, 100)
end)

menu.action(UNLOCK_RISK, "WEAPON AND OTHERS STATS", {}, "my Editor :D", function()
    STAT_SET_INT("KILLS_ENEMY_GANG_MEMBERS", 500) ---WEAPON AND OTHERS STATS
    STAT_SET_INT("KILLS_FRIENDLY_GANG_MEMBERS", 500)
    STAT_SET_INT("CR_GANGATTACK_CITY", 500)
    STAT_SET_INT("CR_GANGATTACK_COUNTRY", 500)
    STAT_SET_INT("CR_GANGATTACK_LOST", 500)
    STAT_SET_INT("CR_GANGATTACK_VAGOS", 500)
    STAT_SET_INT("MPPLY_MISSIONS_CREATED", 500)
    STAT_SET_INT("MPPLY_LTS_CREATED", 500)
    STAT_SET_INT("HORDKILLS", 500)
    STAT_SET_INT("GHKILLS", 500)
    STAT_SET_INT("NO_NON_CONTRACT_RACE_WIN", 500)
    STAT_SET_INT("DB_SHOTTIME", 500)
    STAT_SET_INT("DB_KILLS", 500)
    STAT_SET_INT("DB_PLAYER_KILLS", 500)
    STAT_SET_INT("DB_SHOTS", 500)
    STAT_SET_INT("DB_HITS", 500)
    STAT_SET_INT("DB_HITS_PEDS_VEHICLES", 500)
    STAT_SET_INT("DB_HEADSHOTS", 500)
    STAT_SET_INT("APPISTOL_KILLS", 500)
    STAT_SET_INT("APPISTOL_DEATHS", 100)
    STAT_SET_INT("APPISTOL_SHOTS", 500)
    STAT_SET_INT("APPISTOL_HITS", 500)
    STAT_SET_INT("APPISTOL_HEADSHOTS", 500)
    STAT_SET_INT("APPISTOL_HELDTIME", 5963259)
    STAT_SET_INT("APPISTOL_DB_HELDTIME", 5963259)
    STAT_SET_INT("APPISTOL_ENEMY_KILLS", 500)
    STAT_SET_INT("SNSPISTOL_KILLS", 500)
    STAT_SET_INT("SNSPISTOL_DEATHS", 100)
    STAT_SET_INT("SNSPISTOL_SHOTS", 500)
    STAT_SET_INT("SNSPISTOL_HITS", 500)
    STAT_SET_INT("SNSPISTOL_HEADSHOTS", 500)
    STAT_SET_INT("SNSPISTOL_HELDTIME", 5963259)
    STAT_SET_INT("SNSPISTOL_DB_HELDTIME", 5963259)
    STAT_SET_INT("SNSPISTOL_ENEMY_KILLS", 500)
    STAT_SET_INT("PISTOL50_KILLS", 500)
    STAT_SET_INT("PISTOL50_DEATHS", 100)
    STAT_SET_INT("PISTOL50_SHOTS", 500)
    STAT_SET_INT(" PISTOL50_HITS", 500)
    STAT_SET_INT("PISTOL50_HEADSHOTS", 500)
    STAT_SET_INT("PISTOL50_HELDTIME", 5963259)
    STAT_SET_INT("PISTOL50_DB_HELDTIME", 5963259)
    STAT_SET_INT(" PISTOL50_ENEMY_KILLS", 500)
    STAT_SET_INT(" SMG_KILLS", 500)
    STAT_SET_INT(" SMG_DEATHS", 100)
    STAT_SET_INT("SMG_SHOTS", 500)
    STAT_SET_INT("SMG_HITS", 500)
    STAT_SET_INT("SMG_HEADSHOTS", 500)
    STAT_SET_INT("SMG_HELDTIME", 5963259)
    STAT_SET_INT("SMG_DB_HELDTIME", 5963259)
    STAT_SET_INT("SMG_ENEMY_KILLS", 500)
    STAT_SET_INT("ASLTSMG_KILLS", 500)
    STAT_SET_INT("ASLTSMG_DEATHS", 100)
    STAT_SET_INT("ASLTSMG_SHOTS", 500)
    STAT_SET_INT("ASLTSMG_HITS", 500)
    STAT_SET_INT("ASLTSMG_HEADSHOTS", 500)
    STAT_SET_INT("ASLTSMG_HELDTIME", 5963259)
    STAT_SET_INT("ASLTSMG_DB_HELDTIME", 5963259)
    STAT_SET_INT("ASLTSMG_ENEMY_KILLS", 500)
    STAT_SET_INT("BULLPUP_KILLS", 500)
    STAT_SET_INT("BULLPUP_DEATHS", 100)
    STAT_SET_INT("BULLPUP_SHOTS", 500)
    STAT_SET_INT("BULLPUP_HITS", 500)
    STAT_SET_INT("BULLPUP_HEADSHOTS", 500)
    STAT_SET_INT("BULLPUP_HELDTIME", 5963259)
    STAT_SET_INT("BULLPUP_ENEMY_KILLS", 500)
    STAT_SET_INT("PUMP_KILLS", 500)
    STAT_SET_INT("PUMP_DEATHS", 100)
    STAT_SET_INT("PUMP_SHOTS", 500)
    STAT_SET_INT("PUMP_HITS", 500)
    STAT_SET_INT("PUMP_HEADSHOTS", 500)
    STAT_SET_INT("PUMP_HELDTIME", 5963259)
    STAT_SET_INT("PUMP_ENEMY_KILLS", 500)
    STAT_SET_INT("SAWNOFF_KILLS", 500)
    STAT_SET_INT("SAWNOFF_DEATHS", 100)
    STAT_SET_INT("SAWNOFF_SHOTS", 500)
    STAT_SET_INT("SAWNOFF_HITS", 500)
    STAT_SET_INT("SAWNOFF_HEADSHOTS", 500)
    STAT_SET_INT("SAWNOFF_HELDTIME", 5963259)
    STAT_SET_INT("SAWNOFF_DB_HELDTIME", 5963259)
    STAT_SET_INT("SAWNOFF_ENEMY_KILLS", 500)
    STAT_SET_INT("FLAREGUN_KILLS", 500)
    STAT_SET_INT("FLAREGUN_DEATHS", 100)
    STAT_SET_INT("FLAREGUN_SHOTS", 500)
    STAT_SET_INT("FLAREGUN_HITS", 500)
    STAT_SET_INT("FLAREGUN_HEADSHOTS", 500)
    STAT_SET_INT("FLAREGUN_HELDTIME", 5963259)
    STAT_SET_INT("FLAREGUN_DB_HELDTIME", 5963259)
    STAT_SET_INT("FLAREGUN_ENEMY_KILLS", 500)
    STAT_SET_INT("STUNGUN_KILLS", 500)
    STAT_SET_INT("STUNGUN_DEATHS", 100)
    STAT_SET_INT("STUNGUN_SHOTS", 500)
    STAT_SET_INT("STUNGUN_HITS", 500)
    STAT_SET_INT("STUNGUN_HEADSHOTS", 500)
    STAT_SET_INT("STUNGUN_HELDTIME", 5963259)
    STAT_SET_INT("STUNGUN_DB_HELDTIME", 5963259)
    STAT_SET_INT("STUNGUN_ENEMY_KILLS", 500)
    STAT_SET_INT("CMBTPISTOL_KILLS", 500)
    STAT_SET_INT("CMBTPISTOL_DEATHS", 100)
    STAT_SET_INT("CMBTPISTOL_SHOTS", 500)
    STAT_SET_INT("CMBTPISTOL_HITS", 500)
    STAT_SET_INT("CMBTPISTOL_HEADSHOTS", 500)
    STAT_SET_INT("CMBTPISTOL_HELDTIME", 5963259)
    STAT_SET_INT("CMBTPISTOL_DB_HELDTIME", 5963259)
    STAT_SET_INT("CMBTPISTOL_ENEMY_KILLS", 500)
    STAT_SET_INT("HOMLNCH_KILLS", 500)
    STAT_SET_INT("HOMLNCH_DEATHS", 100)
    STAT_SET_INT("HOMLNCH_SHOTS", 500)
    STAT_SET_INT("HOMLNCH_HELDTIME", 5963259)
    STAT_SET_INT("HOMLNCH_DB_HELDTIME", 5963259)
    STAT_SET_INT("HOMLNCH_ENEMY_KILLS", 500)
    STAT_SET_INT("GCLUB_KILLS", 500)
    STAT_SET_INT("GCLUB_ENEMY_KILLS", 500)
    STAT_SET_INT("GCLUB_DEATHS", 100)
    STAT_SET_INT("GCLUB_HITS", 500)
    STAT_SET_INT("GCLUB_HELDTIME", 5963259)
    STAT_SET_INT("MACHETE_KILLS", 500)
    STAT_SET_INT("MACHETE_DEATHS", 100)
    STAT_SET_INT("MACHETE_HITS", 500)
    STAT_SET_INT("MACHETE_HELDTIME", 5963259)
    STAT_SET_INT("MACHETE_DB_HELDTIME", 5963259)
    STAT_SET_INT("MACHETE_ENEMY_KILLS", 500)
    STAT_SET_INT("SHATCHET_KILLS", 500)
    STAT_SET_INT("SHATCHET_DEATHS", 100)
    STAT_SET_INT("SHATCHET_HITS", 500)
    STAT_SET_INT("SHATCHET_HELDTIME", 5963259)
    STAT_SET_INT("SHATCHET_DB_HELDTIME", 5963259)
    STAT_SET_INT("SHATCHET_ENEMY_KILLS", 500)
    STAT_SET_INT("KNUCKLE_KILLS", 500)
    STAT_SET_INT("KNUCKLE_DEATHS", 100)
    STAT_SET_INT("KNUCKLE_HITS", 500)
    STAT_SET_INT("KNUCKLE_HELDTIME", 5963259)
    STAT_SET_INT("MG_KILLS", 500)
    STAT_SET_INT("MG_DEATHS", 100)
    STAT_SET_INT("MG_SHOTS", 500)
    STAT_SET_INT("MG_HITS", 500)
    STAT_SET_INT("MG_HEADSHOTS", 500)
    STAT_SET_INT("MG_HELDTIME", 596325)
    STAT_SET_INT("MG_ENEMY_KILLS", 500)
    STAT_SET_INT("COMBATPDW_KILLS", 500)
    STAT_SET_INT("COMBATPDW_DEATHS", 100)
    STAT_SET_INT("COMBATPDW_SHOTS", 500)
    STAT_SET_INT("COMBATPDW_HITS", 500)
    STAT_SET_INT("COMBATPDW_HEADSHOTS", 500)
    STAT_SET_INT("COMBATPDW_HELDTIME", 596325)
    STAT_SET_INT("COMBATPDW_DB_HELDTIME", 596325)
    STAT_SET_INT("COMBATPDW_ENEMY_KILLS", 500)
    STAT_SET_INT("MICROSMG_KILLS", 500)
    STAT_SET_INT("MICROSMG_DEATHS", 100)
    STAT_SET_INT("MICROSMG_SHOTS", 500)
    STAT_SET_INT("MICROSMG_HITS", 500)
    STAT_SET_INT("MICROSMG_HEADSHOTS", 500)
    STAT_SET_INT("MICROSMG_HELDTIME", 596325)
    STAT_SET_INT("MICROSMG_DB_HELDTIME", 596325)
    STAT_SET_INT("MICROSMG_ENEMY_KILLS", 500)
    STAT_SET_INT("MACHETE_KILLS", 500)
    STAT_SET_INT("MACHETE_DEATHS", 100)
    STAT_SET_INT("MACHETE_HITS", 500)
    STAT_SET_INT("MACHETE_HELDTIME", 596325)
    STAT_SET_INT("MACHETE_DB_HELDTIME", 596325)
    STAT_SET_INT("MACHETE_ENEMY_KILLS", 500)
    STAT_SET_INT("BATTLEAXE_KILLS", 500)
    STAT_SET_INT("BATTLEAXE_DEATHS", 100)
    STAT_SET_INT("BATTLEAXE_HITS", 500)
    STAT_SET_INT("BATTLEAXE_HELDTIME", 596325)
    STAT_SET_INT("BATTLEAXE_DB_HELDTIME", 596325)
    STAT_SET_INT("BATTLEAXE_ENEMY_KILLS", 500)
    STAT_SET_INT("MINISMG_KILLS", 500)
    STAT_SET_INT("MINISMG_DEATHS", 100)
    STAT_SET_INT("MINISMG_SHOTS", 500)
    STAT_SET_INT("MINISMG_HITS", 500)
    STAT_SET_INT("MINISMG_HEADSHOTS", 500)
    STAT_SET_INT("MINISMG_HELDTIME", 596325)
    STAT_SET_INT("MINISMG_DB_HELDTIME", 596325)
    STAT_SET_INT("MINISMG_ENEMY_KILLS", 500)
    STAT_SET_INT("PRXMINE_KILLS", 500)
    STAT_SET_INT("PRXMINE_DEATHS", 100)
    STAT_SET_INT("PRXMINE_SHOTS", 500)
    STAT_SET_INT("PRXMINE_HELDTIME", 596325)
    STAT_SET_INT("PRXMINE_DB_HELDTIME", 596325)
    STAT_SET_INT("PRXMINE_ENEMY_KILLS", 500)
    STAT_SET_INT("KNUCKLE_ENEMY_KILLS", 500)
    STAT_SET_INT("HATCHET_KILLS", 500)
    STAT_SET_INT("HATCHET_DEATHS", 100)
    STAT_SET_INT("HATCHET_HITS", 500)
    STAT_SET_INT("HATCHET_SHOTS", 500)
    STAT_SET_INT("HATCHET_HELDTIME", 596325)
    STAT_SET_INT("HATCHET_DB_HELDTIME", 596325)
    STAT_SET_INT("HATCHET_ENEMY_KILLS", 500)
    STAT_SET_INT("DAGGER_KILLS", 500)
    STAT_SET_INT("DAGGER_DEATHS", 100)
    STAT_SET_INT("DAGGER_SHOTS", 500)
    STAT_SET_INT("DAGGER_HITS", 500)
    STAT_SET_INT("DAGGER_HEADSHOTS", 500)
    STAT_SET_INT("DAGGER_HELDTIME", 596325)
    STAT_SET_INT("DAGGER_DB_HELDTIME", 596325)
    STAT_SET_INT("DAGGER_ENEMY_KILLS", 500)
    STAT_SET_INT("BOTTLE_KILLS", 500)
    STAT_SET_INT("BOTTLE_DEATHS", 100)
    STAT_SET_INT("BOTTLE_SHOTS", 500)
    STAT_SET_INT("BOTTLE_HITS", 500)
    STAT_SET_INT("BOTTLE_HEADSHOTS", 500)
    STAT_SET_INT("BOTTLE_HELDTIME", 596325)
    STAT_SET_INT("BOTTLE_DB_HELDTIME", 596325)
    STAT_SET_INT("BOTTLE_ENEMY_KILLS", 500)
    STAT_SET_INT("CROWBAR_KILLS", 500)
    STAT_SET_INT("CROWBAR_ENEMY_KILLS", 500)
    STAT_SET_INT("CROWBAR_DEATHS", 100)
    STAT_SET_INT("CROWBAR_HITS", 500)
    STAT_SET_INT("CROWBAR_HELDTIME", 596325)
    STAT_SET_INT("BAT_KILLS", 500)
    STAT_SET_INT("BAT_ENEMY_KILLS", 500)
    STAT_SET_INT("BAT_DEATHS", 100)
    STAT_SET_INT("BAT_HITS", 500)
    STAT_SET_INT("BAT_HELDTIME", 596325)
    STAT_SET_INT("HAMMER_KILLS", 500)
    STAT_SET_INT("HAMMER_ENEMY_KILLS", 500)
    STAT_SET_INT("HAMMER_DEATHS", 100)
    STAT_SET_INT(" HAMMER_HITS", 500)
    STAT_SET_INT("HAMMER_HELDTIME", 596325)
    STAT_SET_INT("NIGHTSTICK_KILLS", 500)
    STAT_SET_INT("NIGHTSTICK_ENEMY_KILLS", 500)
    STAT_SET_INT("NIGHTSTICK_DEATHS", 100)
    STAT_SET_INT("NIGHTSTICK_HITS", 500)
    STAT_SET_INT("NIGHTSTICK_HELDTIME", 596325)
    STAT_SET_INT("KNIFE_KILLS", 500)
    STAT_SET_INT("KNIFE_ENEMY_KILLS", 500)
    STAT_SET_INT("KNIFE_DEATHS", 100)
    STAT_SET_INT("KNIFE_HITS", 500)
    STAT_SET_INT("KNIFE_HELDTIME", 596325)
    STAT_SET_INT("UNARMED_KILLS", 500)
    STAT_SET_INT("UNARMED_ENEMY_KILLS", 500)
    STAT_SET_INT("UNARMED_DEATHS", 100)
    STAT_SET_INT("UNARMED_HITS", 500)
    STAT_SET_INT("MOLOTOV_KILLS", 500)
    STAT_SET_INT("MOLOTOV_DEATHS", 100)
    STAT_SET_INT("MOLOTOV_SHOTS", 500)
    STAT_SET_INT("MOLOTOV_HITS", 500)
    STAT_SET_INT("MOLOTOV_HELDTIME", 596325)
    STAT_SET_INT("MOLOTOV_DB_HELDTIME", 596325)
    STAT_SET_INT("MOLOTOV_ENEMY_KILLS", 500)
    STAT_SET_INT("PIPEBOMB_KILLS", 500)
    STAT_SET_INT("PIPEBOMB_DEATHS", 100)
    STAT_SET_INT("PIPEBOMB_SHOTS", 500)
    STAT_SET_INT("PIPEBOMB_HELDTIME", 596325)
    STAT_SET_INT("PIPEBOMB_DB_HELDTIME", 596325)
    STAT_SET_INT("PIPEBOMB_ENEMY_KILLS", 500)
    STAT_SET_INT("GRENADE_KILLS", 500)
    STAT_SET_INT("GRENADE_DEATHS", 100)
    STAT_SET_INT("GRENADE_SHOTS", 500)
    STAT_SET_INT("GRENADE_HELDTIME", 596325)
    STAT_SET_INT("GRENADE_DB_HELDTIME", 596325)
    STAT_SET_INT("GRENADE_ENEMY_KILLS", 500)
    STAT_SET_INT("SMKGRENADE_KILLS", 500)
    STAT_SET_INT("SMKGRENADE_DEATHS", 100)
    STAT_SET_INT("SMKGRENADE_SHOTS", 500)
    STAT_SET_INT("SMKGRENADE_HITS", 500)
    STAT_SET_INT("SMKGRENADE_HELDTIME", 596325)
    STAT_SET_INT("SMKGRENADE_DB_HELDTIME", 596325)
    STAT_SET_INT("SMKGRENADE_ENEMY_KILLS", 500)
    STAT_SET_INT("MUSKET_KILLS", 500)
    STAT_SET_INT("MUSKET_DEATHS", 100)
    STAT_SET_INT("MUSKET_SHOTS", 500)
    STAT_SET_INT("MUSKET_HITS", 500)
    STAT_SET_INT("MUSKET_HEADSHOTS", 500)
    STAT_SET_INT("MUSKET_HELDTIME", 596325)
    STAT_SET_INT("MUSKET_DB_HELDTIME", 596325)
    STAT_SET_INT("MUSKET_ENEMY_KILLS", 500)
    STAT_SET_INT("SPCARBINE_KILLS", 500)
    STAT_SET_INT("SPCARBINE_DEATHS", 100)
    STAT_SET_INT("SPCARBINE_SHOTS", 500)
    STAT_SET_INT("SPCARBINE_HITS", 500)
    STAT_SET_INT("SPCARBINE_HEADSHOTS", 500)
    STAT_SET_INT("SPCARBINE_HELDTIME", 596325)
    STAT_SET_INT("SPCARBINE_DB_HELDTIME", 596325)
    STAT_SET_INT("SPCARBINE_ENEMY_KILLS", 500)
    STAT_SET_INT("BULLPUP_KILLS", 500)
    STAT_SET_INT("BULLPUP_DEATHS", 100)
    STAT_SET_INT("BULLPUP_SHOTS", 500)
    STAT_SET_INT("BULLPUP_HITS", 500)
    STAT_SET_INT("BULLPUP_HEADSHOTS", 500)
    STAT_SET_INT("BULLPUP_HELDTIME", 596325)
    STAT_SET_INT("BULLPUP_ENEMY_KILLS", 500)
    STAT_SET_INT("ADVRIFLE_KILLS", 500)
    STAT_SET_INT("ADVRIFLE_DEATHS", 100)
    STAT_SET_INT("ADVRIFLE_SHOTS", 500)
    STAT_SET_INT("ADVRIFLE_HITS", 500)
    STAT_SET_INT("ADVRIFLE_HEADSHOTS", 500)
    STAT_SET_INT("ADVRIFLE_HELDTIME", 596325)
    STAT_SET_INT("ADVRIFLE_ENEMY_KILLS", 500)
    STAT_SET_INT("CRBNRIFLE_KILLS", 500)
    STAT_SET_INT("CRBNRIFLE_DEATHS", 100)
    STAT_SET_INT("CRBNRIFLE_SHOTS", 500)
    STAT_SET_INT("CRBNRIFLE_HITS", 500)
    STAT_SET_INT("CRBNRIFLE_HEADSHOTS", 500)
    STAT_SET_INT("CRBNRIFLE_HELDTIME", 596325)
    STAT_SET_INT("CRBNRIFLE_ENEMY_KILLS", 500)
    STAT_SET_INT("ASLTRIFLE_KILLS", 500)
    STAT_SET_INT("ASLTRIFLE_DEATHS", 100)
    STAT_SET_INT("ASLTRIFLE_SHOTS", 500)
    STAT_SET_INT("ASLTRIFLE_HITS", 500)
    STAT_SET_INT("ASLTRIFLE_HEADSHOTS", 500)
    STAT_SET_INT("ASLTRIFLE_HELDTIME", 596325)
    STAT_SET_INT("ASLTRIFLE_ENEMY_KILLS", 500)
    STAT_SET_INT("CMBTMG_KILLS", 500)
    STAT_SET_INT("CMBTMG_DEATHS", 100)
    STAT_SET_INT("CMBTMG_SHOTS", 500)
    STAT_SET_INT("CMBTMG_HITS", 500)
    STAT_SET_INT("CMBTMG_HEADSHOTS", 500)
    STAT_SET_INT("CMBTMG_HELDTIME", 596325)
    STAT_SET_INT("CMBTMG_ENEMY_KILLS", 500)
    STAT_SET_INT("BLRIFLE_MK2_KILLS", 500)
    STAT_SET_INT("BLRIFLE_MK2_DEATHS", 100)
    STAT_SET_INT("BLRIFLE_MK2_SHOTS", 500)
    STAT_SET_INT("BLRIFLE_MK2_HITS", 500)
    STAT_SET_INT("BLRIFLE_MK2_HEADSHOTS", 500)
    STAT_SET_INT("BLRIFLE_MK2_HELDTIME", 5963259)
    STAT_SET_INT("BLRIFLE_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("BLRIFLE_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("PUMP_MK2_KILLS", 500)
    STAT_SET_INT("PUMP_MK2_DEATHS", 100)
    STAT_SET_INT("PUMP_MK2_SHOTS", 500)
    STAT_SET_INT("PUMP_MK2_HITS", 500)
    STAT_SET_INT("PUMP_MK2_HEADSHOTS", 500)
    STAT_SET_INT("PUMP_MK2_HELDTIME", 5963259)
    STAT_SET_INT("PUMP_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("PUMP_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("MKRIFLE_MK2_KILLS", 500)
    STAT_SET_INT("MKRIFLE_MK2_DEATHS", 100)
    STAT_SET_INT("MKRIFLE_MK2_SHOTS", 500)
    STAT_SET_INT("MKRIFLE_MK2_HITS", 500)
    STAT_SET_INT("MKRIFLE_MK2_HEADSHOTS", 500)
    STAT_SET_INT("MKRIFLE_MK2_HELDTIME", 5963259)
    STAT_SET_INT("MKRIFLE_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("MKRIFLE_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("REV_MK2_KILLS", 500)
    STAT_SET_INT("REV_MK2_DEATHS", 100)
    STAT_SET_INT("REV_MK2_SHOTS", 500)
    STAT_SET_INT("REV_MK2_HITS", 500)
    STAT_SET_INT("REV_MK2_HEADSHOTS", 500)
    STAT_SET_INT("REV_MK2_HELDTIME", 5963259)
    STAT_SET_INT("REV_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("REV_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("SNSPIST_MK2_KILLS", 500)
    STAT_SET_INT("SNSPIST_MK2_DEATHS", 100)
    STAT_SET_INT("SNSPIST_MK2_SHOTS", 500)
    STAT_SET_INT("SNSPIST_MK2_HITS", 500)
    STAT_SET_INT("SNSPIST_MK2_HEADSHOTS", 500)
    STAT_SET_INT("SNSPIST_MK2_HELDTIME", 5963259)
    STAT_SET_INT("SNSPIST_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("SNSPIST_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("SPCARB_MK2_KILLS", 500)
    STAT_SET_INT("SPCARB_MK2_DEATHS", 100)
    STAT_SET_INT("SPCARB_MK2_SHOTS", 500)
    STAT_SET_INT("SPCARB_MK2_HITS", 500)
    STAT_SET_INT("SPCARB_MK2_HEADSHOTS", 500)
    STAT_SET_INT("SPCARB_MK2_HELDTIME", 5963259)
    STAT_SET_INT("SPCARB_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("SPCARB_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("ASLTR_MK2_KILLS", 500)
    STAT_SET_INT("ASLTR_MK2_DEATHS", 100)
    STAT_SET_INT("ASLTR_MK2_SHOTS", 500)
    STAT_SET_INT("ASLTR_MK2_HITS", 500)
    STAT_SET_INT("ASLTR_MK2_HEADSHOTS", 500)
    STAT_SET_INT("ASLTR_MK2_HELDTIME", 5963259)
    STAT_SET_INT("ASLTR_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("ASLTR_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("CBNR_MK2_KILLS", 500)
    STAT_SET_INT("CBNR_MK2_DEATHS", 100)
    STAT_SET_INT("CBNR_MK2_SHOTS", 500)
    STAT_SET_INT("CBNR_MK2_HITS", 500)
    STAT_SET_INT("CBNR_MK2_HEADSHOTS", 500)
    STAT_SET_INT("CBNR_MK2_HELDTIME", 5963259)
    STAT_SET_INT("CBNR_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("CBNR_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("CMBMG_MK2_KILLS", 500)
    STAT_SET_INT("CMBMG_MK2_DEATHS", 100)
    STAT_SET_INT("CMBMG_MK2_SHOTS", 500)
    STAT_SET_INT("CMBMG_MK2_HITS", 500)
    STAT_SET_INT("CMBMG_MK2_HEADSHOTS", 500)
    STAT_SET_INT("CMBMG_MK2_HELDTIME", 5963259)
    STAT_SET_INT("CMBMG_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("CMBMG_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("HVYS_MK2_KILLS", 500)
    STAT_SET_INT("HVYS_MK2_DEATHS", 100)
    STAT_SET_INT("HVYS_MK2_SHOTS", 500)
    STAT_SET_INT("HVYS_MK2_HITS", 500)
    STAT_SET_INT("HVYS_MK2_HEADSHOTS", 500)
    STAT_SET_INT("HVYS_MK2_HELDTIME", 5963259)
    STAT_SET_INT("HVYS_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("HVYS_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("PIST_MK2_KILLS", 500)
    STAT_SET_INT("PIST_MK2_DEATHS", 100)
    STAT_SET_INT("PIST_MK2_SHOTS", 500)
    STAT_SET_INT("PIST_MK2_HITS", 500)
    STAT_SET_INT("PIST_MK2_HEADSHOTS", 500)
    STAT_SET_INT("PIST_MK2_HELDTIME", 5963259)
    STAT_SET_INT("PIST_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("PIST_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("SMG_MK2_KILLS", 500)
    STAT_SET_INT("SMG_MK2_DEATHS", 100)
    STAT_SET_INT("SMG_MK2_SHOTS", 500)
    STAT_SET_INT("SMG_MK2_HITS", 500)
    STAT_SET_INT("SMG_MK2_HEADSHOTS", 500)
    STAT_SET_INT("SMG_MK2_HELDTIME", 5963259)
    STAT_SET_INT("SMG_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("SMG_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("FLASHLIGHT_KILLS", 500)
    STAT_SET_INT("FLASHLIGHT_DEATHS", 100)
    STAT_SET_INT("FLASHLIGHT_HITS", 500)
    STAT_SET_INT("FLASHLIGHT_HELDTIME", 5963259)
    STAT_SET_INT("FLASHLIGHT_DB_HELDTIME", 5963259)
    STAT_SET_INT("FLASHLIGHT_ENEMY_KILLS", 500)
    STAT_SET_INT("FIREWRK_KILLS", 500)
    STAT_SET_INT("FIREWRK_DEATHS", 100)
    STAT_SET_INT("FIREWRK_SHOTS", 500)
    STAT_SET_INT("FIREWRK_HITS", 500)
    STAT_SET_INT("FIREWRK_HEADSHOTS", 500)
    STAT_SET_INT("FIREWRK_HELDTIME", 5963259)
    STAT_SET_INT("FIREWRK_DB_HELDTIME", 5963259)
    STAT_SET_INT("FIREWRK_ENEMY_KILLS", 500)
    STAT_SET_INT("FLAREGUN_KILLS", 500)
    STAT_SET_INT("FLAREGUN_DEATHS", 100)
    STAT_SET_INT("FLAREGUN_SHOTS", 500)
    STAT_SET_INT("FLAREGUN_HITS", 500)
    STAT_SET_INT("FLAREGUN_HEADSHOTS", 500)
    STAT_SET_INT("FLAREGUN_HELDTIME", 5963259)
    STAT_SET_INT("FLAREGUN_DB_HELDTIME", 5963259)
    STAT_SET_INT("FLAREGUN_ENEMY_KILLS", 500)
    STAT_SET_INT("SWBLADE_KILLS", 500)
    STAT_SET_INT("SWBLADE_DEATHS", 100)
    STAT_SET_INT("SWBLADE_HITS", 500)
    STAT_SET_INT("SWBLADE_HELDTIME", 5963259)
    STAT_SET_INT("SWBLADE_ENEMY_KILLS", 500)
    STAT_SET_INT("GUSNBRG_KILLS", 500)
    STAT_SET_INT("GUSNBRG_DEATHS", 100)
    STAT_SET_INT("GUSNBRG_SHOTS", 500)
    STAT_SET_INT("GUSNBRG_HITS", 500)
    STAT_SET_INT("GUSNBRG_HEADSHOTS", 500)
    STAT_SET_INT("GUSNBRG_HELDTIME", 5963259)
    STAT_SET_INT("GUSNBRG_DB_HELDTIME", 5963259)
    STAT_SET_INT("GUSNBRG_ENEMY_KILLS", 500)
    STAT_SET_INT("POOLCUE_KILLS", 500)
    STAT_SET_INT("POOLCUE_DEATHS", 100)
    STAT_SET_INT("POOLCUE_HITS", 500)
    STAT_SET_INT("POOLCUE_HELDTIME", 5963259)
    STAT_SET_INT("POOLCUE_DB_HELDTIME", 5963259)
    STAT_SET_INT("POOLCUE_ENEMY_KILLS", 500)
    STAT_SET_INT("GRNLAUNCH_KILLS", 500)
    STAT_SET_INT("GRNLAUNCH_DEATHS", 100)
    STAT_SET_INT("GRNLAUNCH_SHOTS", 500)
    STAT_SET_INT("GRNLAUNCH_HELDTIME", 5963259)
    STAT_SET_INT("GRNLAUNCH_ENEMY_KILLS", 500)
    STAT_SET_INT("HVYPISTOL_KILLS", 500)
    STAT_SET_INT("HVYPISTOL_DEATHS", 100)
    STAT_SET_INT("HVYPISTOL_SHOTS", 500)
    STAT_SET_INT("HVYPISTOL_HITS", 500)
    STAT_SET_INT("HVYPISTOL_HEADSHOTS", 500)
    STAT_SET_INT("HVYPISTOL_HELDTIME", 5963259)
    STAT_SET_INT("HVYPISTOL_DB_HELDTIME", 5963259)
    STAT_SET_INT("HVYPISTOL_ENEMY_KILLS", 500)
    STAT_SET_INT("VPISTOL_KILLS", 500)
    STAT_SET_INT("VPISTOL_DEATHS", 100)
    STAT_SET_INT("VPISTOL_SHOTS", 500)
    STAT_SET_INT("VPISTOL_HITS", 500)
    STAT_SET_INT("VPISTOL_HEADSHOTS", 500)
    STAT_SET_INT("VPISTOL_HELDTIME", 5963259)
    STAT_SET_INT("VPISTOL_DB_HELDTIME", 5963259)
    STAT_SET_INT("VPISTOL_ENEMY_KILLS", 500)
    STAT_SET_INT("REVOLVER_KILLS", 500)
    STAT_SET_INT("REVOLVER_DEATHS", 100)
    STAT_SET_INT("REVOLVER_SHOTS", 500)
    STAT_SET_INT("REVOLVER_HITS", 500)
    STAT_SET_INT("REVOLVER_HEADSHOTS", 500)
    STAT_SET_INT("REVOLVER_HELDTIME", 5963259)
    STAT_SET_INT("REVOLVER_DB_HELDTIME", 5963259)
    STAT_SET_INT("REVOLVER_ENEMY_KILLS", 500)
    STAT_SET_INT("MKPISTOL_KILLS", 500)
    STAT_SET_INT("MKPISTOL_DEATHS", 100)
    STAT_SET_INT("MKPISTOL_SHOTS", 500)
    STAT_SET_INT("MKPISTOL_HITS", 500)
    STAT_SET_INT("MKPISTOL_HEADSHOTS", 500)
    STAT_SET_INT("MKPISTOL_HELDTIME", 5963259)
    STAT_SET_INT("MKPISTOL_DB_HELDTIME", 5963259)
    STAT_SET_INT("MKPISTOL_ENEMY_KILLS", 500)
    STAT_SET_INT("BULLRIFLE_KILLS", 500)
    STAT_SET_INT("BULLRIFLE_DEATHS", 100)
    STAT_SET_INT("BULLRIFLE_SHOTS", 500)
    STAT_SET_INT("BULLRIFLE_HITS", 500)
    STAT_SET_INT("BULLRIFLE_HEADSHOTS", 500)
    STAT_SET_INT("BULLRIFLE_HELDTIME", 5963259)
    STAT_SET_INT("BULLRIFLE_DB_HELDTIME", 5963259)
    STAT_SET_INT("BULLRIFLE_ENEMY_KILLS", 500)
    STAT_SET_INT("AUTOSHGN_KILLS", 500)
    STAT_SET_INT("AUTOSHGN_DEATHS", 100)
    STAT_SET_INT("AUTOSHGN_SHOTS", 500)
    STAT_SET_INT("AUTOSHGN_HITS", 500)
    STAT_SET_INT("AUTOSHGN_HEADSHOTS", 500)
    STAT_SET_INT("AUTOSHGN_HELDTIME", 5963259)
    STAT_SET_INT("AUTOSHGN_DB_HELDTIME", 5963259)
    STAT_SET_INT("AUTOSHGN_ENEMY_KILLS", 500)
    STAT_SET_INT("BATTLEAXE_KILLS", 500)
    STAT_SET_INT("BATTLEAXE_DEATHS", 100)
    STAT_SET_INT("BATTLEAXE_HITS", 500)
    STAT_SET_INT("BATTLEAXE_HELDTIME", 5963259)
    STAT_SET_INT("BATTLEAXE_DB_HELDTIME", 5963259)
    STAT_SET_INT("BATTLEAXE_ENEMY_KILLS", 500)
    STAT_SET_INT("CMPGL_KILLS", 500)
    STAT_SET_INT("CMPGL_DEATHS", 100)
    STAT_SET_INT("CMPGL_SHOTS", 500)
    STAT_SET_INT("CMPGL_HITS", 500)
    STAT_SET_INT("CMPGL_HEADSHOTS", 500)
    STAT_SET_INT("CMPGL_HELDTIME", 5963259)
    STAT_SET_INT("CMPGL_DB_HELDTIME", 5963259)
    STAT_SET_INT("CMPGL_ENEMY_KILLS", 500)
    STAT_SET_INT("MINISMG_KILLS", 500)
    STAT_SET_INT("MINISMG_DEATHS", 100)
    STAT_SET_INT("MINISMG_SHOTS", 500)
    STAT_SET_INT("MINISMG_HITS", 500)
    STAT_SET_INT("MINISMG_HEADSHOTS", 500)
    STAT_SET_INT("MINISMG_HELDTIME", 5963259)
    STAT_SET_INT("MINISMG_DB_HELDTIME", 5963259)
    STAT_SET_INT("MINISMG_ENEMY_KILLS", 500)
    STAT_SET_INT("PIPEBOMB_KILLS", 500)
    STAT_SET_INT("PIPEBOMB_DEATHS", 100)
    STAT_SET_INT("PIPEBOMB_SHOTS", 500)
    STAT_SET_INT("PIPEBOMB_HELDTIME", 5963259)
    STAT_SET_INT("PIPEBOMB_DB_HELDTIME", 5963259)
    STAT_SET_INT("PIPEBOMB_ENEMY_KILLS", 500)
    STAT_SET_INT("POOLCUE_KILLS", 500)
    STAT_SET_INT("POOLCUE_DEATHS", 100)
    STAT_SET_INT("POOLCUE_HITS", 500)
    STAT_SET_INT("POOLCUE_HELDTIME", 5963259)
    STAT_SET_INT("POOLCUE_DB_HELDTIME", 5963259)
    STAT_SET_INT("POOLCUE_ENEMY_KILLS", 500)
    STAT_SET_INT("REVOLVER_KILLS", 500)
    STAT_SET_INT("REVOLVER_DEATHS", 100)
    STAT_SET_INT("REVOLVER_SHOTS", 500)
    STAT_SET_INT("REVOLVER_HITS", 500)
    STAT_SET_INT("REVOLVER_HEADSHOTS", 500)
    STAT_SET_INT("REVOLVER_HELDTIME", 5963259)
    STAT_SET_INT("REVOLVER_DB_HELDTIME", 5963259)
    STAT_SET_INT("REVOLVER_ENEMY_KILLS", 500)
    STAT_SET_INT("MPPLY_UNIQUE_RACES", 300)
    STAT_SET_INT("MPPLY_UNIQUE_DMS", 300)
    STAT_SET_INT("MPPLY_UNIQUE_PARAS", 300)
    STAT_SET_INT("MPPLY_UNIQUE_SURVIVAL", 300)
    STAT_SET_INT("MPPLY_UNIQUE_MISSIONS", 300)
    STAT_SET_INT("MPPLY_UNIQUE_LTS", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CTF", 300)
    STAT_SET_INT("MPPLY_UNIQUE_VERSUS", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_RACES", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_DMS", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_PARAS", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_SURVIVAL", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_MISSIONS", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_LTS", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_CTF", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_VERSUS", 300)
    STAT_SET_INT("MPPLY_UNIQUE_RACES_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_DMS_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_PARAS_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_SURVIVAL_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_MISSIONS_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_LTS_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CTF_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_VERSUS_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_RACES_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_DMS_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_PARAS_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_SURVIVAL_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_MISSIONS_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_LTS_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_CTF_V", 300)
    STAT_SET_INT("MPPLY_AVAILABLE_VERSUS_V", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CONTACT_0", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CONTACT_1", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CONTACT_2", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CONTACT_3", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CONTACT_4", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CONTACT_5", 300)
    STAT_SET_INT("MPPLY_UNIQUE_CONTACT_6", 300)
    STAT_SET_INT("MPPLY_TOTAL_CONTACT_0", 300)
    STAT_SET_INT("MPPLY_TOTAL_CONTACT_1", 300)
    STAT_SET_INT("MPPLY_TOTAL_CONTACT_2", 300)
    STAT_SET_INT("MPPLY_TOTAL_CONTACT_3", 300)
    STAT_SET_INT("MPPLY_TOTAL_CONTACT_4", 300)
    STAT_SET_INT("MPPLY_TOTAL_CONTACT_5", 300)
    STAT_SET_INT("MPPLY_TOTAL_CONTACT_6", 300)
    STAT_SET_INT("HVYSHGN_KILLS", 500)
    STAT_SET_INT("HVYSHGN_DEATHS", 100)
    STAT_SET_INT("HVYSHGN_SHOTS", 500)
    STAT_SET_INT("HVYSHGN_HITS", 500)
    STAT_SET_INT("HVYSHGN_HEADSHOTS", 500)
    STAT_SET_INT("HVYSHGN_HELDTIME", 5963259)
    STAT_SET_INT("HVYSHGN_DB_HELDTIME", 5963259)
    STAT_SET_INT("HVYSHGN_ENEMY_KILLS", 500)
    STAT_SET_INT("RAYMINIGUN_KILLS", 500)
    STAT_SET_INT("RAYMINIGUN_DEATHS", 100)
    STAT_SET_INT("RAYMINIGUN_SHOTS", 500)
    STAT_SET_INT("RAYMINIGUN_HITS", 500)
    STAT_SET_INT("RAYMINIGUN_HEADSHOTS", 500)
    STAT_SET_INT("RAYMINIGUN_HELDTIME", 5963259)
    STAT_SET_INT("RAYMINIGUN_DB_HELDTIME", 5963259)
    STAT_SET_INT("RAYMINIGUN_ENEMY_KILLS", 500)
    STAT_SET_INT("REV_NV_KILLS", 500)
    STAT_SET_INT("REV_NV_DEATHS", 100)
    STAT_SET_INT("REV_NV_SHOTS", 500)
    STAT_SET_INT("REV_NV_HITS", 500)
    STAT_SET_INT("REV_NV_HEADSHOTS", 500)
    STAT_SET_INT("REV_NV_HELDTIME", 5963259)
    STAT_SET_INT("REV_NV_DB_HELDTIME", 5963259)
    STAT_SET_INT("REV_NV_ENEMY_KILLS", 500)
    STAT_SET_INT("CERPST_KILLS", 500)
    STAT_SET_INT("CERPST_DEATHS", 100)
    STAT_SET_INT("CERPST_SHOTS", 500)
    STAT_SET_INT("CERPST_HITS", 500)
    STAT_SET_INT("CERPST_HEADSHOTS", 500)
    STAT_SET_INT("CERPST_HELDTIME", 5963259)
    STAT_SET_INT("CERPST_DB_HELDTIME", 5963259)
    STAT_SET_INT("CERPST_ENEMY_KILLS", 500)
    STAT_SET_INT("BLRIFLE_MK2_KILLS", 500)
    STAT_SET_INT("BLRIFLE_MK2_DEATHS", 100)
    STAT_SET_INT("BLRIFLE_MK2_SHOTS", 500)
    STAT_SET_INT("BLRIFLE_MK2_HITS", 500)
    STAT_SET_INT("BLRIFLE_MK2_HEADSHOTS", 500)
    STAT_SET_INT("BLRIFLE_MK2_HELDTIME", 5963259)
    STAT_SET_INT("BLRIFLE_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("BLRIFLE_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("PUMP_MK2_KILLS", 500)
    STAT_SET_INT("PUMP_MK2_DEATHS", 100)
    STAT_SET_INT("PUMP_MK2_SHOTS", 500)
    STAT_SET_INT("PUMP_MK2_HITS", 500)
    STAT_SET_INT("PUMP_MK2_HEADSHOTS", 500)
    STAT_SET_INT("PUMP_MK2_HELDTIME", 5963259)
    STAT_SET_INT("PUMP_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("PUMP_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("MKRIFLE_MK2_KILLS", 500)
    STAT_SET_INT("MKRIFLE_MK2_DEATHS", 100)
    STAT_SET_INT("MKRIFLE_MK2_SHOTS", 500)
    STAT_SET_INT("MKRIFLE_MK2_HITS", 500)
    STAT_SET_INT("MKRIFLE_MK2_HEADSHOTS", 500)
    STAT_SET_INT("MKRIFLE_MK2_HELDTIME", 5963259)
    STAT_SET_INT("MKRIFLE_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("MKRIFLE_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("REV_MK2_KILLS", 500)
    STAT_SET_INT("REV_MK2_DEATHS", 100)
    STAT_SET_INT("REV_MK2_SHOTS", 500)
    STAT_SET_INT("REV_MK2_HITS", 500)
    STAT_SET_INT("REV_MK2_HEADSHOTS", 500)
    STAT_SET_INT("REV_MK2_HELDTIME", 5963259)
    STAT_SET_INT("REV_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("REV_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("REV_DA_KILLS", 500)
    STAT_SET_INT("REV_DA_DEATHS", 100)
    STAT_SET_INT("REV_DA_SHOTS", 500)
    STAT_SET_INT("REV_DA_HITS", 500)
    STAT_SET_INT("REV_DA_HEADSHOTS", 500)
    STAT_SET_INT("REV_DA_HELDTIME", 5963259)
    STAT_SET_INT("REV_DA_DB_HELDTIME", 5963259)
    STAT_SET_INT("REV_DA_ENEMY_KILLS", 500)
    STAT_SET_INT("SNSPIST_MK2_KILLS", 500)
    STAT_SET_INT("SNSPIST_MK2_DEATHS", 100)
    STAT_SET_INT("SNSPIST_MK2_SHOTS", 500)
    STAT_SET_INT("SNSPIST_MK2_HITS", 500)
    STAT_SET_INT("SNSPIST_MK2_HEADSHOTS", 500)
    STAT_SET_INT("SNSPIST_MK2_HELDTIME", 5963259)
    STAT_SET_INT("SNSPIST_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("SNSPIST_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("SPCARB_MK2_KILLS", 500)
    STAT_SET_INT("SPCARB_MK2_DEATHS", 100)
    STAT_SET_INT("SPCARB_MK2_SHOTS", 500)
    STAT_SET_INT("SPCARB_MK2_HITS", 500)
    STAT_SET_INT("SPCARB_MK2_HEADSHOTS", 500)
    STAT_SET_INT("SPCARB_MK2_HELDTIME", 5963259)
    STAT_SET_INT("SPCARB_MK2_DB_HELDTIME", 5963259)
    STAT_SET_INT("SPCARB_MK2_ENEMY_KILLS", 500)
    STAT_SET_INT("MCHPIST_KILLS", 500)
    STAT_SET_INT("MCHPIST_DEATHS", 100)
    STAT_SET_INT("MCHPIST_SHOTS", 500)
    STAT_SET_INT("MCHPIST_HITS", 500)
    STAT_SET_INT("MCHPIST_HEADSHOTS", 500)
    STAT_SET_INT("MCHPIST_HELDTIME", 5963259)
    STAT_SET_INT("MCHPIST_DB_HELDTIME", 5963259)
    STAT_SET_INT("MCHPIST_ENEMY_KILLS", 500)
    STAT_SET_INT("CMPRIFLE_KILLS", 500)
    STAT_SET_INT("CMPRIFLE_DEATHS", 100)
    STAT_SET_INT("CMPRIFLE_SHOTS", 500)
    STAT_SET_INT("CMPRIFLE_HITS", 500)
    STAT_SET_INT("CMPRIFLE_HEADSHOTS", 500)
    STAT_SET_INT("CMPRIFLE_HELDTIME", 5963259)
    STAT_SET_INT("CMPRIFLE_DB_HELDTIME", 5963259)
    STAT_SET_INT("CMPRIFLE_ENEMY_KILLS", 500)
    STAT_SET_INT("DBSHGN_KILLS", 500)
    STAT_SET_INT("DBSHGN_DEATHS", 100)
    STAT_SET_INT("DBSHGN_SHOTS", 500)
    STAT_SET_INT("DBSHGN_HITS", 500)
    STAT_SET_INT("DBSHGN_HEADSHOTS", 500)
    STAT_SET_INT("DBSHGN_HELDTIME", 5963259)
    STAT_SET_INT("DBSHGN_DB_HELDTIME", 5963259)
    STAT_SET_INT("DBSHGN_ENEMY_KILLS", 500)
end)


menu.action(UNLOCK_RISK, "ESTATÍSTICAS DA LISTA DE VERIFICAÇÃO DO MENU", {}, "my Editor :D", function()
    STAT_SET_BOOL("CL_RACE_MODDED_CAR", true) --Rank Apparel Unlock bitset 0
    STAT_SET_BOOL("CL_DRIVE_RALLY", true) --Rank Apparel Unlock bitset 0
    STAT_SET_BOOL("CL_PLAY_GTA_RACE", true) --Rank Apparel Unlock bitset 0
    STAT_SET_BOOL("CL_PLAY_BOAT_RACE", true) --Rank Apparel Unlock bitset 0
    STAT_SET_BOOL("CL_PLAY_FOOT_RACE", true) --Rank Apparel Unlock bitset 0
    STAT_SET_BOOL("CL_PLAY_VEHICLE_DM", true) --Rank Apparel Unlock bitset 0
    STAT_SET_BOOL("CL_PLAY_MISSION_CONTACT", true) --Rank Apparel Unlock bitset 0
    STAT_SET_BOOL("CL_PLAY_A_PLAYLIST", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_PLAY_POINT_TO_POINT", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_PLAY_ONE_ON_ONE_DM", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_PLAY_ONE_ON_ONE_RACE", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_SURV_A_BOUNTY", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_SET_WANTED_LVL_ON_PLAY", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_GANG_BACKUP_GANGS", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_GANG_BACKUP_LOST", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_GANG_BACKUP_VAGOS", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_CALL_MERCENARIES", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_PHONE_MECH_DROP_CAR", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_GONE_OFF_RADAR", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_FILL_TITAN", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_MOD_CAR_USING_APP", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_BUY_APPARTMENT", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_BUY_INSURANCE", true) --Stores if player has bought insurance
    STAT_SET_BOOL("CL_BUY_GARAGE", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_ENTER_FRIENDS_HOUSE", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_CALL_STRIPPER_HOUSE", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_CALL_FRIEND", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_SEND_FRIEND_REQUEST", true) --Stores how many times the player has started mission script
    STAT_SET_BOOL("CL_W_WANTED_PLAYER_TV", true) ---Stores how many times the player has started mission script
end)


menu.action(UNLOCK_RISK, "Novos Globais", {}, "my Editor :D", function()
    SET_INT_GLOBAL(262145 + 33973, 0); --- Ice Vinyl
    SET_INT_GLOBAL(262145 + 33974, 0); --- Ice Vinyl Cut
    SET_INT_GLOBAL(262145 + 33975, 0); --- Mustard Vinyl
    SET_INT_GLOBAL(262145 + 33976, 0); --- Mustard Vinyl Cut
    SET_INT_GLOBAL(262145 + 33977, 0); --- Dark Blue Vinyl
    SET_INT_GLOBAL(262145 + 33978, 0); --- Dark Blue Vinyl Cut
    SET_INT_GLOBAL(262145 + 33979, 0); --- Yellow SN Rooster Revere Collar
    SET_INT_GLOBAL(262145 + 33980, 0); --- Red SC Dragon Revere Collar
    SET_INT_GLOBAL(262145 + 33981, 0); --- Blue SC Dragon Revere Collar
    SET_INT_GLOBAL(262145 + 33982, 0); --- Camo Roses Slab Denim
    SET_INT_GLOBAL(262145 + 33983, 0); --- Orange Trickster Type Denim
    SET_INT_GLOBAL(262145 + 33984, 0); --- Black VDG Cardigan
    SET_INT_GLOBAL(262145 + 33985, 0); --- Blue DS Panthers Cardigan
    SET_INT_GLOBAL(262145 + 33986, 0); --- Red DS Panthers Cardigan
    SET_INT_GLOBAL(262145 + 33987, 0); --- Pink SC Baroque Cardigan
    SET_INT_GLOBAL(262145 + 33988, 0); --- Downtown Cab Co. Revere Collar
    SET_INT_GLOBAL(262145 + 33989, 0); --- Valentines Blazer
    SET_INT_GLOBAL(262145 + 33990, 0); --- 420 Smoking Jacket
    SET_INT_GLOBAL(262145 + 33991, 0); --- Yeti Year of the Rabbit Tee
    SET_INT_GLOBAL(262145 + 33992, 0); --- Grey Yeti Combat Shirt
    SET_INT_GLOBAL(262145 + 33993, 0); --- Black Sprunk Festive
    SET_INT_GLOBAL(262145 + 33994, 0); --- Dark Logger Festive
    SET_INT_GLOBAL(262145 + 33995, 0); --- White Logger Festive
    SET_INT_GLOBAL(262145 + 33996, 0); --- Green Logger Festive
    SET_INT_GLOBAL(262145 + 33997, 0); --- Red Logger Festive
    SET_INT_GLOBAL(262145 + 33998, 0); --- Blue Patriot Logo Festive
    SET_INT_GLOBAL(262145 + 33999, 0); --- Black Patriot Logo Festive
    SET_INT_GLOBAL(262145 + 34000, 0); --- Blue Patriot Festive
    SET_INT_GLOBAL(262145 + 34001, 0); --- Red Patriot Festive
    SET_INT_GLOBAL(262145 + 34002, 0); --- Red Pivwasser Festive
    SET_INT_GLOBAL(262145 + 34003, 0); --- Gold Pivswasser Festive
    SET_INT_GLOBAL(262145 + 34004, 0); --- Red Pivwasser Logo Festive
    SET_INT_GLOBAL(262145 + 34005, 0); --- Gold Pivwasser Logo Festive
    SET_INT_GLOBAL(262145 + 34006, 0); --- Green Pride Brew Festive
    SET_INT_GLOBAL(262145 + 34007, 0); --- Yellow Pride Brew Festive
    SET_INT_GLOBAL(262145 + 34008, 0); --- Yellow Holly Pride Festive
    SET_INT_GLOBAL(262145 + 34009, 0); --- White Holly Pride Festive
    SET_INT_GLOBAL(262145 + 34010, 0); --- Sprunk Snowflakes Festive
    SET_INT_GLOBAL(262145 + 34011, 0); --- Broker Checkerboard Tee
    SET_INT_GLOBAL(262145 + 34012, 0); --- Yeti Ape Tucked Tee
    SET_INT_GLOBAL(262145 + 34013, 0); --- Black Bigness Ski
    SET_INT_GLOBAL(262145 + 34014, 0); --- White Bigness Ski
    SET_INT_GLOBAL(262145 + 34015, 0); --- Black Enema Flourish Ski
    SET_INT_GLOBAL(262145 + 34016, 0); --- Teal Enema Flourish Ski
    SET_INT_GLOBAL(262145 + 34017, 0); --- Magenta Enema Flourish Ski
    SET_INT_GLOBAL(262145 + 34018, 0); --- Camo Roses Slab Forwards
    SET_INT_GLOBAL(262145 + 34019, 0); --- Lime Leopard Slab Forwards
    SET_INT_GLOBAL(262145 + 34020, 0); --- Red SC Dragon Embroidered
    SET_INT_GLOBAL(262145 + 34021, 0); --- Classic DS Tiger Embroidered
    SET_INT_GLOBAL(262145 + 34022, 0); --- Grey DS Tiger Embroidered
    SET_INT_GLOBAL(262145 + 34023, 0); --- Black VDG Bandana Wide
    SET_INT_GLOBAL(262145 + 34024, 0); --- Orange Trickster Type Wide
    SET_INT_GLOBAL(262145 + 34025, 0); --- Grey Yeti Battlepants
    SET_INT_GLOBAL(262145 + 34026, 0); --- Broker Checkerboard Cargos
    SET_INT_GLOBAL(262145 + 34027, 0); --- 420 Smoking Pants
    SET_INT_GLOBAL(262145 + 34028, 0); --- Camo Roses Slab Canvas
    SET_INT_GLOBAL(262145 + 34029, 0); --- Lime Leopard Slab Canvas
    SET_INT_GLOBAL(262145 + 34030, 0); --- White Signs Squash Ugglies and Socks
    SET_INT_GLOBAL(262145 + 34031, 0); --- Traditional Painted Rabbit
    SET_INT_GLOBAL(262145 + 34032, 0); --- Twilight Painted Rabbit
    SET_INT_GLOBAL(262145 + 34033, 0); --- Noh Painted Rabbit
    SET_INT_GLOBAL(262145 + 34034, 0); --- Lime SC Coin Wraps
    SET_INT_GLOBAL(262145 + 34035, 0); --- Pink SC Coin Wraps
    SET_INT_GLOBAL(262145 + 34036, 0); --- Tan Bracelet Ensemble
    SET_INT_GLOBAL(262145 + 34037, 0); --- Red Manor Round Brow Shades
    SET_INT_GLOBAL(262145 + 34038, 0); --- Le Chien Whistle Necklace
    SET_INT_GLOBAL(262145 + 34039, 0); --- Heartbreak Pendant
    SET_INT_GLOBAL(262145 + 34040, 0); --- Rabbit (Tattoo)
    SET_INT_GLOBAL(262145 + 34041, 0); --- Budonk---adonk! (Tattoo)
    SET_INT_GLOBAL(262145 + 34042, 0); --- The Red---nosed (GTA+)
    SET_INT_GLOBAL(262145 + 34043, 0); --- The Nutcracker (GTA+)
    SET_INT_GLOBAL(262145 + 34044, 0); --- The GoPostal
    SET_INT_GLOBAL(262145 + 34045, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34046, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34047, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34048, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34049, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34050, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34051, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34052, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34053, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34054, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34055, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34056, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34058, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34059, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34061, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34062, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34066, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34070, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34078, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34109, 0); --- Unlocks  Bunch of clothing at shops ( Cardigans, hats, ski masks, designer jeans, glasses, etc)
    SET_INT_GLOBAL(262145 + 34110, 0); --- Manor Surano jacket
    SET_INT_GLOBAL(262145 + 34111, 0); --- Zebra Dome
    SET_INT_GLOBAL(262145 + 34112, 0); --- Purple SnakeSkin Spiked
end)


------------------------------------------------------------------------------------------------------------------------------
---Editor de K/D---------------QUALQUER EDIÇÃO AQUI EM CIMA----------Blocked v..v..v..v..------------------

local STATS_EDITOR = menu.list(menu.my_root(), "Editor de K/D", { "EDTK" }, "", function()

end)

local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local kills_ptr = memory.alloc_int()
local deaths_ptr = memory.alloc_int()

util.create_tick_handler(function()

    global_kills = memory.script_global(1853131 + 1 + (players.user() * 888) + 205 + 28)
    global_deaths = memory.script_global(1853131 + 1 + (players.user() * 888) + 205 + 29)

    kills_stat_hash = util.joaat("MPPLY_KILLS_PLAYERS")
    deaths_stat_hash = util.joaat("MPPLY_DEATHS_PLAYER")

    STATS.STAT_GET_INT(kills_stat_hash, kills_ptr, -1)
    STATS.STAT_GET_INT(deaths_stat_hash, deaths_ptr, -1)

    get_stat_kills = memory.read_int(kills_ptr)
    get_stat_deaths = memory.read_int(deaths_ptr)

    get_global_kills = memory.read_int(global_kills)
    get_global_deaths = memory.read_int(global_deaths)

    if get_global_kills == get_stat_kills then
        cur_kills = get_global_kills
    else
        cur_kills = get_stat_kills
    end

    if get_global_deaths == get_stat_deaths then
        cur_deaths = get_global_deaths
    else
        cur_deaths = get_stat_deaths
    end

end)

if util.is_session_started() then

    menu.divider(STATS_EDITOR, "Atual K/D")

    local cur_kills_display = menu.action(STATS_EDITOR, "Minhas Kills: " .. cur_kills, {},
        "Total  de players que matei", function()
    end)

    local cur_death_display = menu.action(STATS_EDITOR, "Minhas Mortes: " .. cur_deaths, {},
        "Vezes que morri para outros jogadores!", function()
    end)

    local cur_ratio_display = menu.action(STATS_EDITOR, "Valor do K/D: " .. cur_kills / cur_deaths, {}, "", function()
    end)

    menu.divider(STATS_EDITOR, "Novo K/D")

    local kills_slider_v = cur_kills
    local deaths_slider_v = cur_deaths

    local new_kills = menu.slider(STATS_EDITOR, "Novas Kills ", { "killsamount" }, "", -2147483647, 2147483647, cur_kills
        ,
        1, function(value)
        kills_slider_v = value
    end)

    local new_deaths = menu.slider(STATS_EDITOR, "Novas Mortes", { "deathsamount" }, "", -2147483647, 2147483647,
        cur_deaths, 1, function(value)
        deaths_slider_v = value
    end)

    util.create_tick_handler(function()
        new_ratio = menu.get_value(new_kills) / menu.get_value(new_deaths)
    end)

    local new_ratio_display = menu.action(STATS_EDITOR, "Novo Valor: " .. round(new_ratio, 2), { "" },
        "aqui ira aparecer o valor do seu novo K/D", function()
    end)

    menu.action(STATS_EDITOR, "Confirmar K/D", { "" }, "", function()
        memory.write_int(global_kills, kills_slider_v)
        memory.write_int(global_deaths, deaths_slider_v)
        STATS.STAT_SET_INT(kills_stat_hash, kills_slider_v, true)
        STATS.STAT_SET_INT(deaths_stat_hash, deaths_slider_v, true)
        util.toast("Digite o Valor do seu K/D" .. new_ratio .. "Definido")
    end)

    util.create_tick_handler(function()
        menu.set_menu_name(cur_kills_display, "Atual Kills: " .. cur_kills)
        menu.set_menu_name(cur_death_display, "Atual Mortes: " .. cur_deaths)
        menu.set_menu_name(cur_ratio_display, "Atual Valor: " .. round(cur_kills / cur_deaths, 2))
        menu.set_menu_name(new_ratio_display, "Novo Valor: " .. round(new_ratio, 2))
    end)
else
    util.toast("Você precisa estar em uma sessão online! ")
    util.stop_script()
end

util.on_stop(memory.free(kills_ptr))
util.on_stop(memory.free(deaths_ptr))

util.keep_running()
-----------------------------------------------FIM----------------------------------------------------------------------------
