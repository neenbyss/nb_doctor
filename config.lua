Config = {}

-- Configuración general
Config.CheckEMS = true -- Si está en true, solo funciona cuando no hay EMS activos
Config.RequiredEMSCount = 0 -- Número mínimo de EMS para desactivar el NPC
Config.HealPrice = 500 -- Precio por curación
Config.HealTime = 5000 -- Tiempo de curación en milisegundos
Config.UseProgressBar = true -- Usar barra de progreso (requiere progressbar)
Config.UseTarget = true -- Usar qb-target o drawtext3D

Config.Locations = {
    {
        id = 1,
        coords = vector4(-678.3743, 319.2318, 83.0831, 158.8327),
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