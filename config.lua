Config = {}

-- Configuración general
Config.CheckEMS = true -- Si está en true, solo funciona cuando no hay EMS activos
Config.RequiredEMSCount = 0 -- Número mínimo de EMS para desactivar el NPC
Config.OnlyWhenInjured = true -- Si está en true, solo se puede solicitar tratamiento cuando tienes vida baja o estás muerto
Config.HealPrice = 500 -- Precio por curación
Config.HealTime = 5000 -- Tiempo de curación en milisegundos
Config.UseProgressBar = true -- Usar barra de progreso (soporta ox_lib o espera simple)
Config.UseTarget = true -- Usar sistema de target (ox_target, qtarget) o drawtext3D

Config.Locations = {
    {
        id = 1,
        coords = vector4(1145.1332, -1529.9188, 35.3805, 169.6073),
        model = 's_m_m_doctor_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        blip = {
            enabled = true,
            sprite = 61,
            color = 2,
            scale = 0.8,
            label = 'Doctor NPC'
        }
    }
}

Config.Animations = {
    doctor = {
        dict = 'mini@cpr@char_a@cpr_str',
        anim = 'cpr_pumpchest',
        duration = Config.HealTime
    },
    player = {
        dict = 'mini@cpr@char_b@cpr_str',
        anim = 'cpr_pumpchest_idle',
        duration = Config.HealTime
    }
}

Config.Notifications = {
    noMoney = 'No tienes suficiente dinero',
    noNeedHeal = 'No necesitas tratamiento médico',
    healing = 'El doctor te está curando...',
    healed = 'Has sido curado completamente',
    emsActive = 'Hay paramédicos disponibles, contacta con ellos',
    cancelled = 'Tratamiento cancelado'
}

Config.NPCDialog = {
    greeting = '¿Necesitas atención médica? Te cobraré $' .. Config.HealPrice,
    accept = '[E] Aceptar tratamiento',
    decline = '[X] Rechazar'
}