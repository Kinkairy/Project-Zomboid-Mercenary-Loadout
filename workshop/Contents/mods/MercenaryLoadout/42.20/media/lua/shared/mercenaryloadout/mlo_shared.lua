MercenaryLoadout = MercenaryLoadout or {}
MercenaryAcceptItemFunction = MercenaryAcceptItemFunction or {}

require "NPCs/BodyLocations"

local M = MercenaryLoadout
M.VERSION = "RC1.3.2"
M.BUILD = 24
M.MODULE = "MercenaryLoadout"

M.TYPE = {
    BELT = { ["Base.Belt2"] = true },

    RIG = {
        ["Base.Bag_ALICE_BeltSus"] = true,
        ["Base.Bag_ALICE_BeltSus_Green"] = true,
        ["Base.Bag_ALICE_BeltSus_Camo"] = true,
    },

    PACK = {
        ["Base.Bag_BigHikingBag"] = true,
        ["Base.Bag_BigHikingBag_Travel"] = true,
        ["Base.Bag_Military"] = true,
        ["Base.Bag_SurvivorBag"] = true,
        ["Base.Bag_ALICEpack"] = true,
        ["Base.Bag_ALICEpack_Army"] = true,
        ["Base.Bag_ALICEpack_DesertCamo"] = true,
    },

    THIGH_L = {
        ["Base.Thigh_ArticMetal_L"] = true,
        ["Base.ThighBodyArmour_L"] = true,
        ["Base.ThighBodyArmour_L_Army"] = true,
        ["Base.ThighBodyArmour_L_Civ"] = true,
        ["Base.ThighBodyArmour_L_Desert"] = true,
        ["Base.ThighBodyArmour_L_Police"] = true,
        ["Base.ThighBodyArmour_L_SWAT"] = true,
        ["Base.ThighBone_L"] = true,
        ["Base.ThighMagazine_L"] = true,
        ["Base.ThighMetal_L"] = true,
        ["Base.ThighMetalSpike_L"] = true,
        ["Base.ThighProtective_L"] = true,
        ["Base.ThighScrapMetal_L"] = true,
        ["Base.ThighScrapMetalSpike_L"] = true,
        ["Base.ThighTire_L"] = true,
        ["Base.ThighWood_L"] = true,
    },
    THIGH_R = {
        ["Base.Thigh_ArticMetal_R"] = true,
        ["Base.ThighBodyArmour_R"] = true,
        ["Base.ThighBodyArmour_R_Army"] = true,
        ["Base.ThighBodyArmour_R_Civ"] = true,
        ["Base.ThighBodyArmour_R_Desert"] = true,
        ["Base.ThighBodyArmour_R_Police"] = true,
        ["Base.ThighBodyArmour_R_SWAT"] = true,
        ["Base.ThighBone_R"] = true,
        ["Base.ThighMagazine_R"] = true,
        ["Base.ThighMetal_R"] = true,
        ["Base.ThighMetalSpike_R"] = true,
        ["Base.ThighProtective_R"] = true,
        ["Base.ThighScrapMetal_R"] = true,
        ["Base.ThighScrapMetalSpike_R"] = true,
        ["Base.ThighTire_R"] = true,
        ["Base.ThighWood_R"] = true,
    },

    FANNY = {
        ["Base.Bag_FannyPackFront"] = true,
        ["Base.Bag_FannyPackBack"] = true,
        ["Base.Bag_FannyPackFront_Hide"] = true,
        ["Base.Bag_FannyPackBack_Hide"] = true,
        ["Base.Bag_FannyPackFront_Tarp"] = true,
        ["Base.Bag_FannyPackBack_Tarp"] = true,
    },

    SATCHEL = {
        ["Base.Bag_Satchel"] = true,
        ["Base.Bag_SatchelPhoto"] = true,
        ["Base.Bag_Satchel_Fishing"] = true,
        ["Base.Bag_Satchel_Leather"] = true,
        ["Base.Bag_Satchel_Military"] = true,
        ["Base.Bag_Satchel_Medical"] = true,
        ["Base.Bag_Satchel_Mail"] = true,
        ["Base.Bag_TarpSlingBag"] = true,
        ["Base.Bag_HideSlingBag"] = true,
        ["Base.Bag_SheetSlingBag"] = true,
    },

    BULLET_STRAP = {
        ["Base.AmmoStrap_Bullets"] = true,
        ["Base.AmmoStrap_Brown_Bullets"] = true,
        ["Base.AmmoStrap_Bullets_223"] = true,
        ["Base.AmmoStrap_Bullets_308"] = true,
    },

    SHELL_STRAP = {
        ["Base.AmmoStrap_Shells"] = true,
        ["Base.AmmoStrap_Brown_Shells"] = true,
    },

    FIRST_AID = {
        ["Base.FirstAidKit"] = true,
        ["Base.FirstAidKit_New"] = true,
        ["Base.FirstAidKit_NewPro"] = true,
        ["Base.FirstAidKit_Camping"] = true,
        ["Base.FirstAidKit_Camping_New"] = true,
        ["Base.FirstAidKit_Military"] = true,
    },

    TOOLBOX = {
        ["Base.Toolbox"] = true,
        ["Base.Toolbox_Farming"] = true,
        ["Base.Toolbox_Fishing"] = true,
        ["Base.Toolbox_Gardening"] = true,
        ["Base.Toolbox_Wooden"] = true,
        ["Base.Toolbox_Mechanic"] = true,
        ["Base.Bag_JanitorToolbox"] = true,
    },

    CANTEEN = {
        ["Base.WaterBottle"] = true,
        ["Base.CanteenMilitary"] = true,
        ["Base.CanteenMilitaryFull"] = true,
        ["Base.Canteen"] = true,
        ["Base.CanteenClay"] = true,
        ["Base.CanteenCowboy"] = true,
        ["Base.Flask"] = true,
        ["Base.Sportsbottle"] = true,
    },

    MASK = {
        ["Base.WeldingMask"] = true,
        ["Base.Hat_BuildersRespirator"] = true,
        ["Base.Hat_BuildersRespirator_nofilter"] = true,
        ["Base.Hat_GasMask"] = true,
        ["Base.Hat_GasMask_nofilter"] = true,
        ["Base.Hat_ImprovisedGasMask"] = true,
        ["Base.Hat_ImprovisedGasMask_nofilter"] = true,
        ["Base.Hat_NBCmask"] = true,
        ["Base.Hat_NBCmask_nofilter"] = true,
        ["Base.Hat_HalloweenMaskDevil"] = true,
        ["Base.Hat_HalloweenMaskMonster"] = true,
        ["Base.Hat_HalloweenMaskPumpkin"] = true,
        ["Base.Hat_HalloweenMaskSkeleton"] = true,
        ["Base.Hat_HalloweenMaskVampire"] = true,
        ["Base.Hat_HalloweenMaskWitch"] = true,
        ["Base.Hat_HockeyMask"] = true,
        ["Base.Hat_HockeyMask_Hide"] = true,
        ["Base.Hat_BoneMask"] = true,
        ["Base.Hat_HockeyMask_Wood"] = true,
        ["Base.Hat_HockeyMask_Metal"] = true,
        ["Base.Hat_HockeyMask_Copper"] = true,
        ["Base.Hat_HockeyMask_Gold"] = true,
        ["Base.Hat_HockeyMask_Silver"] = true,
        ["Base.Hat_HockeyMask_MetalScrap"] = true,
    },

    DEVICE = {
        ["Base.CDplayer"] = true,
        ["Base.RadioBlack"] = true,
        ["Base.RadioRed"] = true,
        ["Base.RadioMakeShift"] = true,
        ["Base.WalkieTalkie1"] = true,
        ["Base.WalkieTalkie2"] = true,
        ["Base.WalkieTalkie3"] = true,
        ["Base.WalkieTalkie4"] = true,
        ["Base.WalkieTalkie5"] = true,
        ["Base.WalkieTalkieMakeShift"] = true,
    },

    PLUSH = {
        ["Base.BorisBadger"] = true,
        ["Base.EyeOfCthulhu"] = true,
        ["Base.FluffyfootBunny"] = true,
        ["Base.FreddyFox"] = true,
        ["Base.FurbertSquirrel"] = true,
        ["Base.JacquesBeaver"] = true,
        ["Base.MoleyMole"] = true,
        ["Base.PancakeHedgehog"] = true,
        ["Base.PanchoDog"] = true,
        ["Base.Plushabug"] = true,
        ["Base.Spiffo"] = true,
        ["Base.TrashGoblin"] = true,
    },

    PHONE = {
        ["Base.CordlessPhone"] = true,
    },

    LANTERN = {
        ["Base.Lantern_HurricaneLit"] = true,
        ["Base.Lantern_Hurricane"] = true,
        ["Base.Lantern_Hurricane_CopperLit"] = true,
        ["Base.Lantern_Hurricane_Copper"] = true,
        ["Base.Lantern_Hurricane_ForgedLit"] = true,
        ["Base.Lantern_Hurricane_Forged"] = true,
        ["Base.Lantern_Hurricane_GoldLit"] = true,
        ["Base.Lantern_Hurricane_Gold"] = true,
        ["Base.Lantern_Hurricane_SilverLit"] = true,
        ["Base.Lantern_Hurricane_Silver"] = true,
        ["Base.Lantern_Propane"] = true,
        ["Base.Lantern_CraftedElectric"] = true,
    },
}

-- Do not redeclare Base items merely to add AttachmentType. Build 42 resets an
-- existing item script before applying a later declaration, which strips the
-- original container capacity, MaxItemSize, sounds and other vanilla fields.
-- Assign the one missing per-instance Hotbar field instead and leave every
-- vanilla script definition intact.
M.DETACHABLE_ATTACHMENT_TYPE = {
    CANTEEN = "MLOPackSportBottle",
    FIRST_AID = "MLOPackMedBox",
    TOOLBOX = "MLOPackToolbox",
    MASK = "MLOPackWeldingMask",
    LANTERN = "MLOPackLantern",
    DEVICE = "MLOPackCDPlayer",
    PHONE = "MLOPackCDPlayer",
    PLUSH = "MLOPackPlushToy",
}

-- Exact values from Build 42.20's generated Base container definitions.  They
-- are used only by the one-time legacy-save repair/audit below.  Healthy items
-- are never converted and steady-state attachment sync never edits a container.
M.VANILLA_CONTAINER_STATE = {
    ["Base.FirstAidKit"] = { capacity = 4, weightReduction = 50, maxItemSize = 1.0, openSound = "OpenSmallMetalBox", closeSound = "CloseSmallMetalBox", putSound = "StoreItemSmallMetalBox" },
    ["Base.FirstAidKit_New"] = { capacity = 4, weightReduction = 50, maxItemSize = 1.0, openSound = "OpenSmallMetalBox", closeSound = "CloseSmallMetalBox", putSound = "StoreItemSmallMetalBox" },
    ["Base.FirstAidKit_NewPro"] = { capacity = 4, weightReduction = 50, maxItemSize = 1.0, openSound = "OpenSmallMetalBox", closeSound = "CloseSmallMetalBox", putSound = "StoreItemSmallMetalBox" },
    ["Base.FirstAidKit_Camping"] = { capacity = 2, weightReduction = 50, maxItemSize = 0.3, openSound = "OpenFirstAidKitCamping", closeSound = "CloseFirstAidKitCamping", putSound = "StoreItemFirstAidKitCamping" },
    ["Base.FirstAidKit_Camping_New"] = { capacity = 2, weightReduction = 50, maxItemSize = 0.3, openSound = "OpenFirstAidKitCamping", closeSound = "CloseFirstAidKitCamping", putSound = "StoreItemFirstAidKitCamping" },
    ["Base.FirstAidKit_Military"] = { capacity = 2, weightReduction = 50, maxItemSize = 0.3, openSound = "OpenFirstAidKitMilitary", closeSound = "CloseFirstAidKitMilitary", putSound = "StoreItemFirstAidKitMilitary" },
    ["Base.Toolbox"] = { capacity = 8, weightReduction = 50, maxItemSize = 2.0, openSound = "OpenMetalToolbox", closeSound = "CloseMetalToolbox", putSound = "StoreItemMetalToolbox" },
    ["Base.Toolbox_Farming"] = { capacity = 8, weightReduction = 50, maxItemSize = 2.0, openSound = "OpenMetalToolbox", closeSound = "CloseMetalToolbox", putSound = "StoreItemMetalToolbox" },
    ["Base.Toolbox_Fishing"] = { capacity = 8, weightReduction = 50, maxItemSize = 2.0, openSound = "OpenMetalToolbox", closeSound = "CloseMetalToolbox", putSound = "StoreItemMetalToolbox" },
    ["Base.Toolbox_Gardening"] = { capacity = 8, weightReduction = 50, maxItemSize = 2.0, openSound = "OpenMetalToolbox", closeSound = "CloseMetalToolbox", putSound = "StoreItemMetalToolbox" },
    ["Base.Toolbox_Wooden"] = { capacity = 6, weightReduction = 50, maxItemSize = 2.0, openSound = "OpenSmallWoodenBox", closeSound = "CloseSmallWoodenBox", putSound = "StoreItemSmallWoodenBox" },
    ["Base.Toolbox_Mechanic"] = { capacity = 8, weightReduction = 50, maxItemSize = 2.0, openSound = "OpenMetalToolbox", closeSound = "CloseMetalToolbox", putSound = "StoreItemMetalToolbox" },
    ["Base.Bag_JanitorToolbox"] = { capacity = 8, weightReduction = 50, maxItemSize = 2.0, openSound = "OpenMetalToolbox", closeSound = "CloseMetalToolbox", putSound = "StoreItemMetalToolbox" },
}

M.MODULE_ITEM_TYPES = {
    ["MercenaryLoadout.MLO_KeyClip"] = true,
    ["MercenaryLoadout.MLO_Pouch2"] = true,
    ["MercenaryLoadout.MLO_Pouch3"] = true,
    ["MercenaryLoadout.MLO_SidePouch"] = true,
    ["MercenaryLoadout.MLO_BulletPouch"] = true,
    ["MercenaryLoadout.MLO_ShellPouch"] = true,
    ["MercenaryLoadout.MLO_PackTopPouch"] = true,
    ["MercenaryLoadout.MLO_PackSidePouchL"] = true,
    ["MercenaryLoadout.MLO_PackSidePouchR"] = true,
    ["MercenaryLoadout.MLO_MagPanel"] = true,
    ["MercenaryLoadout.MLO_FirstAidModule"] = true,
    ["MercenaryLoadout.MLO_ToolboxModule"] = true,
}

M.LEGACY_POUCH_TYPES = {
    ["MercenaryLoadout.MLO_Pouch2"] = true,
    ["MercenaryLoadout.MLO_Pouch3"] = true,
    ["MercenaryLoadout.MLO_SidePouch"] = true,
    ["MercenaryLoadout.MLO_PackTopPouch"] = true,
    ["MercenaryLoadout.MLO_PackSidePouchL"] = true,
    ["MercenaryLoadout.MLO_PackSidePouchR"] = true,
}

-- Fixed pockets are hidden linked containers owned by the upgraded parent.
-- The source bag is consumed; only these non-separable module containers
-- remain. Vanilla inventory UI hides them from item rows; the client exposes
-- their container buttons only while the authoritative parent is equipped.
M.FIXED_POUCH = {
    beltKeyClip = { fullType = "MercenaryLoadout.MLO_KeyClip", capacity = 10, preserveContents = true },
    beltPouch1 = { fullType = "MercenaryLoadout.MLO_Pouch2", capacity = 3 },
    beltPouch2 = { fullType = "MercenaryLoadout.MLO_Pouch2", capacity = 3 },
    rigPouchL = { fullType = "MercenaryLoadout.MLO_BulletPouch", capacity = 5 },
    rigPouchR = { fullType = "MercenaryLoadout.MLO_ShellPouch", capacity = 5 },
    packTopPouch = { fullType = "MercenaryLoadout.MLO_PackTopPouch", capacity = 5 },
    packSideL = { fullType = "MercenaryLoadout.MLO_PackSidePouchL", capacity = 15 },
    packSideR = { fullType = "MercenaryLoadout.MLO_PackSidePouchR", capacity = 15 },
}

M.CONTAINER_PROXY_TYPE = {
    packMedBox = "MercenaryLoadout.MLO_FirstAidModule",
    packToolbox = "MercenaryLoadout.MLO_ToolboxModule",
}

-- dev.15 deliberately keeps this slot retired. It is registered only so an old
-- Java AttachedItem mapping can be cleared transactionally; it is never an
-- active Hotbar definition, upgrade, slot-order entry, or allowlist member.
local RETIRED_BLOWTORCH_SLOT = "MLO_Pack_BlowTorch"
local RETIRED_BLOWTORCH_TYPE = "MLOPackBlowTorch"
local RETIRED_RIG_SLOT_MAP = {
    MLO_Rig_RifleL = { activeSlot = "MLO_Rig_PistolL", retiredUpgrade = "rig_rifleL", activeUpgrade = "rig_shoulderL" },
    MLO_Rig_RifleR = { activeSlot = "MLO_Rig_PistolR", retiredUpgrade = "rig_rifleR", activeUpgrade = "rig_shoulderR" },
}
local RETIRED_RIG_MODULE_UPGRADE = {
    rigBullets = "rig_bullets",
    rigShells = "rig_shells",
    rigMagPanel = "rig_magpanel",
}
local RETIRED_BELT_POUCH = "beltPouch3"
M.RETIRED_ATTACHED = {
    [RETIRED_BLOWTORCH_SLOT] = "Shovel Back with Bag",
    MLO_Rig_RifleL = "Rifle On Back",
    MLO_Rig_RifleR = "Rifle On Back with Bag",
}
M.ATTACHED = {
    -- custom slot id -> stable vanilla location, except the one explicitly
    -- routed through M.CUSTOM_ATTACHED_NAME below
    MLO_Belt_HolsterL  = "mlo_belt_holster_left",
    MLO_Belt_HolsterR  = "mlo_belt_holster_right",
    MLO_Belt_ToolL     = "mlo_belt_tool_left",
    MLO_Belt_ToolR     = "mlo_belt_tool_right",

    -- Same custom attachment registration as backpack hardpoints.
    MLO_Rig_PistolL    = "mlo_rig_shoulder_left",
    MLO_Rig_PistolR    = "mlo_rig_shoulder_right",


    MLO_Pack_SportBottle = "mlo_pack_water_left",

    -- model4 keeps the remaining backpack cargo on proven-visible vanilla
    -- Bip01_BackPack "with bag" transforms.  model5-water1 moves the bottle,
    -- model11-layout4 keeps the accepted vanilla lifecycle and moves only
    -- character-model attachment transforms and visual model scale.
    MLO_Pack_MedBox      = "mlo_pack_medbox_side",
    MLO_Pack_Toolbox     = "mlo_pack_toolbox_left_pocket",
    MLO_Pack_WeldingMask = "mlo_pack_mask_right_upper",
    MLO_Pack_Lantern     = "mlo_pack_lantern_right",
    MLO_Pack_CDPlayer    = "mlo_pack_device_left_upper",
    MLO_Pack_PlushToy    = "mlo_pack_plush_right",
}

-- Direct character-model attachment names.  These do not clone a vanilla
-- AttachedLocation: the matching parent attachment is added to Base FemaleBody
-- and MaleBody by mlo_character_attachments.txt.  Keep this separate from
-- M.ATTACHED so every other slot retains its exact vanilla transform.
M.CUSTOM_ATTACHED_NAME = {
    MLO_Belt_HolsterL = "mlo_belt_holster_left",
    MLO_Belt_HolsterR = "mlo_belt_holster_right",
    MLO_Belt_ToolL = "mlo_belt_tool_left",
    MLO_Belt_ToolR = "mlo_belt_tool_right",
    MLO_Rig_PistolL = "mlo_rig_shoulder_left",
    MLO_Rig_PistolR = "mlo_rig_shoulder_right",
    MLO_Pack_SportBottle = "mlo_pack_water_left",
    MLO_Pack_MedBox = "mlo_pack_medbox_side",
    MLO_Pack_Toolbox = "mlo_pack_toolbox_left_pocket",
    MLO_Pack_WeldingMask = "mlo_pack_mask_right_upper",
    MLO_Pack_Lantern = "mlo_pack_lantern_right",
    MLO_Pack_CDPlayer = "mlo_pack_device_left_upper",
    MLO_Pack_PlushToy = "mlo_pack_plush_right",
}

-- One logical Hotbar slot may select a different character-model transform for
-- an exact item FullType.  These are additional AttachedLocations only: they
-- never become Hotbar definitions, persisted slot types or AttachmentTypes.
-- Only explicitly configured FullTypes use dedicated transforms; every other
-- compatible item uses its slot default. CD player and welding mask stay isolated.
M.ATTACHED_LOCATION_PROFILE = {
    MLO_Pack_PlushToy = {
        default = { location = "MLO_Pack_PlushToy", attachment = "mlo_pack_plush_right" },
        byFullType = {
            ["Base.Spiffo"] = { location = "MLO_Pack_PlushToy_Spiffo", attachment = "mlo_pack_plush_right_spiffo" },
            ["Base.PanchoDog"] = { location = "MLO_Pack_PlushToy_PanchoDog", attachment = "mlo_pack_plush_right_pancho_dog" },
        },
    },
    MLO_Pack_CDPlayer = {
        default = { location = "MLO_Pack_CDPlayer", attachment = "mlo_pack_device_left_upper" },
        byFullType = {
            ["Base.CDplayer"] = { location = "MLO_Pack_CDPlayer_Base_CDplayer", attachment = "mlo_pack_device_left_upper_cdplayer" },
            ["Base.RadioBlack"] = { location = "MLO_Pack_CDPlayer_Radio", attachment = "mlo_pack_device_left_upper_radio" },
            ["Base.RadioRed"] = { location = "MLO_Pack_CDPlayer_Radio", attachment = "mlo_pack_device_left_upper_radio" },
            ["Base.RadioMakeShift"] = { location = "MLO_Pack_CDPlayer_Radio", attachment = "mlo_pack_device_left_upper_radio" },
        },
    },
    MLO_Pack_WeldingMask = {
        default = { location = "MLO_Pack_WeldingMask", attachment = "mlo_pack_mask_right_upper" },
        byFullType = {
            ["Base.WeldingMask"] = { location = "MLO_Pack_WeldingMask_Base_WeldingMask", attachment = "mlo_pack_mask_right_upper_welding_mask" },
            ["Base.Hat_GasMask"] = { location = "MLO_Pack_WeldingMask_GasHockey", attachment = "mlo_pack_mask_right_upper_gas_hockey" },
            ["Base.Hat_GasMask_nofilter"] = { location = "MLO_Pack_WeldingMask_GasHockey", attachment = "mlo_pack_mask_right_upper_gas_hockey" },
            ["Base.Hat_BuildersRespirator"] = { location = "MLO_Pack_WeldingMask_GasHockey", attachment = "mlo_pack_mask_right_upper_gas_hockey" },
            ["Base.Hat_BuildersRespirator_nofilter"] = { location = "MLO_Pack_WeldingMask_GasHockey", attachment = "mlo_pack_mask_right_upper_gas_hockey" },
            ["Base.Hat_HockeyMask_MetalScrap"] = { location = "MLO_Pack_WeldingMask_GasHockey", attachment = "mlo_pack_mask_right_upper_gas_hockey" },
            ["Base.Hat_HockeyMask"] = { location = "MLO_Pack_WeldingMask_GasHockey", attachment = "mlo_pack_mask_right_upper_gas_hockey" },
            ["Base.Hat_NBCmask"] = { location = "MLO_Pack_WeldingMask_NBC", attachment = "mlo_pack_mask_right_upper_nbc" },
            ["Base.Hat_NBCmask_nofilter"] = { location = "MLO_Pack_WeldingMask_NBC", attachment = "mlo_pack_mask_right_upper_nbc" },
        },
    },
}

function M.resolveAttachedLocation(slotId, item, fallback)
    local profile = slotId and M.ATTACHED_LOCATION_PROFILE[slotId] or nil
    if not profile then return fallback end
    local fullType = ""
    if item then
        local ok, value = pcall(function() return item:getFullType() end)
        if ok and value then fullType = tostring(value) end
    end
    local specific = profile.byFullType and profile.byFullType[fullType] or nil
    if specific and specific.location then return specific.location end
    return profile.default and profile.default.location or fallback
end

-- Every detachable mount uses the vanilla Hotbar/AttachedItem lifecycle.
-- Fixed sewn pouches are separate hidden worn containers and are not listed
-- here; medical kits and toolboxes are Hotbar items plus a container-button
-- extension on the client.
M.HOTBAR_TEMPLATE = {
    MLO_Belt_HolsterL = "HolsterLeft",
    MLO_Belt_HolsterR = "HolsterRight",
    MLO_Belt_ToolL = "SmallBeltLeft",
    MLO_Belt_ToolR = "SmallBeltRight",
    MLO_Rig_PistolL = "HolsterLeft",
    MLO_Rig_PistolR = "HolsterRight",
    MLO_Pack_SportBottle = "WebbingLeft",
    MLO_Pack_MedBox = "Back",
    MLO_Pack_Toolbox = "Back",
    MLO_Pack_WeldingMask = "WebbingRight",
    MLO_Pack_Lantern = "WebbingRight",
    MLO_Pack_CDPlayer = "WebbingLeft",
    MLO_Pack_PlushToy = "WebbingRight",
}

-- Preserve the dedicated physical upgrades, while allowing each upgraded
-- mount to accept the vanilla item family that physically fits it.
M.SLOT_ALLOWED_ATTACHMENT_TYPES = {
    MLO_Belt_HolsterL = {
        Holster = "MLO_Belt_HolsterL", HolsterSmall = "MLO_Belt_HolsterL",
        Rifle = "MLO_Belt_HolsterL", BigWeapon = "MLO_Belt_HolsterL",
    },
    MLO_Belt_HolsterR = {
        Holster = "MLO_Belt_HolsterR", HolsterSmall = "MLO_Belt_HolsterR",
        Rifle = "MLO_Belt_HolsterR", BigWeapon = "MLO_Belt_HolsterR",
    },
    MLO_Belt_ToolL = {
        Knife = "MLO_Belt_ToolL",
        NotKnife = "MLO_Belt_ToolL",
        Hammer = "MLO_Belt_ToolL",
        HammerRotated = "MLO_Belt_ToolL",
        Nightstick = "MLO_Belt_ToolL",
        Screwdriver = "MLO_Belt_ToolL",
        Wrench = "MLO_Belt_ToolL",
        MeatCleaver = "MLO_Belt_ToolL",
        Walkie = "MLO_Belt_ToolL",
        Sword = "MLO_Belt_ToolL",
        MLOPackCDPlayer = "MLO_Belt_ToolL",
    },
    MLO_Belt_ToolR = {
        Knife = "MLO_Belt_ToolR",
        NotKnife = "MLO_Belt_ToolR",
        Hammer = "MLO_Belt_ToolR",
        HammerRotated = "MLO_Belt_ToolR",
        Nightstick = "MLO_Belt_ToolR",
        Screwdriver = "MLO_Belt_ToolR",
        Wrench = "MLO_Belt_ToolR",
        MeatCleaver = "MLO_Belt_ToolR",
        Walkie = "MLO_Belt_ToolR",
        Sword = "MLO_Belt_ToolR",
        MLOPackCDPlayer = "MLO_Belt_ToolR",
    },
    MLO_Rig_PistolL = {
        Holster = "MLO_Rig_PistolL",
        HolsterSmall = "MLO_Rig_PistolL",
    },
    MLO_Rig_PistolR = {
        Holster = "MLO_Rig_PistolR",
        HolsterSmall = "MLO_Rig_PistolR",
    },
    MLO_Pack_SportBottle = {
        MLOPackSportBottle = "MLO_Pack_SportBottle",
        Walkie = "MLO_Pack_SportBottle",
    },
    MLO_Pack_MedBox = { MLOPackMedBox = "MLO_Pack_MedBox" },
    MLO_Pack_Toolbox = { MLOPackToolbox = "MLO_Pack_Toolbox" },
    MLO_Pack_WeldingMask = { MLOPackWeldingMask = "MLO_Pack_WeldingMask" },
    MLO_Pack_Lantern = { MLOPackLantern = "MLO_Pack_Lantern" },
    MLO_Pack_PlushToy = { MLOPackPlushToy = "MLO_Pack_PlushToy" },
    MLO_Pack_CDPlayer = {
        MLOPackCDPlayer = "MLO_Pack_CDPlayer",
        Walkie = "MLO_Pack_CDPlayer",
    },
}

-- Several vanilla containers only define a ground model. The original item
-- instance remains the attachment/container; while mounted we give that same
-- instance its matching vanilla static model so AttachedItems can render it.
M.ATTACHED_MODEL = {
    -- Retired decorations: keep mappings only for restoring saved visual overrides.
    ["Base.ToyBear"] = "Base.ToyBear",
    ["Base.ToyBear_Crafted_Cotton"] = "Base.ToyBear_Crafted_Cotton",
    ["Base.ToyBear_Crafted_Burlap"] = "Base.ToyBear_Crafted_Denim",
    ["Base.Rubberducky"] = "Base.RubberduckyTINTED",
    ["Base.Frog"] = "Base.Frog_Ground",
    ["Base.BorisBadger"] = "Base.PlushieBadger_Ground",
    ["Base.EyeOfCthulhu"] = "Base.PlushieEyeOfChulhu_Ground",
    ["Base.FluffyfootBunny"] = "Base.PlushieRabbit_Ground",
    ["Base.FreddyFox"] = "Base.PlushieFox_Ground",
    ["Base.FurbertSquirrel"] = "Base.PlushieSquirrel_Ground",
    ["Base.JacquesBeaver"] = "Base.PlushieBeaver_Ground",
    ["Base.MoleyMole"] = "Base.PlushieMole_Ground",
    ["Base.PancakeHedgehog"] = "Base.PlushieHedgehog_Ground",
    ["Base.PanchoDog"] = "Base.Pancho",
    ["Base.Plushabug"] = "Base.Plushabug",
    ["Base.Spiffo"] = "Base.SpiffoPlushie",
    ["Base.TrashGoblin"] = "Base.PlushieTrashGoblin_Ground",
    -- Retained only to restore old saved visual overrides; Doll is not mountable.
    ["Base.Doll"] = "Base.Doll",
    ["Base.Sportsbottle"] = "MercenaryLoadout.MLO_SportsBottle_Attached",
    ["Base.FirstAidKit"] = "MercenaryLoadout.MLO_FirstAidBox_Attached",
    ["Base.FirstAidKit_New"] = "MercenaryLoadout.MLO_FirstAidBox_Attached",
    ["Base.FirstAidKit_NewPro"] = "MercenaryLoadout.MLO_FirstAidBox_Attached",
    ["Base.FirstAidKit_Camping"] = "MercenaryLoadout.MLO_FirstAidCamping_Attached",
    ["Base.FirstAidKit_Camping_New"] = "MercenaryLoadout.MLO_FirstAidCamping_Attached",
    ["Base.FirstAidKit_Military"] = "MercenaryLoadout.MLO_FirstAidMilitary_Attached",
    ["Base.Toolbox"] = "MercenaryLoadout.MLO_Toolbox_Attached",
    ["Base.Toolbox_Farming"] = "MercenaryLoadout.MLO_Toolbox_Attached",
    ["Base.Toolbox_Fishing"] = "MercenaryLoadout.MLO_Toolbox_Attached",
    ["Base.Toolbox_Gardening"] = "MercenaryLoadout.MLO_Toolbox_Attached",
    ["Base.Toolbox_Mechanic"] = "MercenaryLoadout.MLO_Toolbox_Attached",
    ["Base.Bag_JanitorToolbox"] = "MercenaryLoadout.MLO_Toolbox_Attached",
    ["Base.Toolbox_Wooden"] = "MercenaryLoadout.MLO_ToolboxWooden_Attached",
    ["Base.WeldingMask"] = "MercenaryLoadout.MLO_WeldingMask_Attached",
    ["Base.Lantern_Propane"] = "MercenaryLoadout.MLO_PropaneLantern_Attached",
    ["Base.CDplayer"] = "MercenaryLoadout.MLO_CDPlayer_Attached",
    ["Base.RadioBlack"] = "MercenaryLoadout.MLO_RadioBlack_Attached",
    ["Base.RadioRed"] = "MercenaryLoadout.MLO_RadioRed_Attached",
    ["Base.RadioMakeShift"] = "MercenaryLoadout.MLO_RadioBlue_Attached",
    ["Base.Hat_BuildersRespirator"] = "MercenaryLoadout.MLO_BuildersRespirator_Attached",
    ["Base.Hat_BuildersRespirator_nofilter"] = "MercenaryLoadout.MLO_BuildersRespiratorNoFilter_Attached",
    ["Base.Hat_GasMask"] = "MercenaryLoadout.MLO_GasMask_Attached",
    ["Base.Hat_GasMask_nofilter"] = "MercenaryLoadout.MLO_GasMask_Attached",
    ["Base.Hat_NBCmask"] = "MercenaryLoadout.MLO_NBCMask_Attached",
    ["Base.Hat_NBCmask_nofilter"] = "MercenaryLoadout.MLO_NBCMask_Attached",
    ["Base.Hat_HockeyMask"] = "MercenaryLoadout.MLO_HockeyMask_Attached",
    ["Base.Hat_HockeyMask_MetalScrap"] = "MercenaryLoadout.MLO_Mask_Hat_HockeyMask_MetalScrap",
    -- Container overrides are visual-only and are restored by the existing
    -- mounted-instance model lifecycle.  Container ownership and transfer do
    -- not depend on these entries.
    ["Base.Hat_ImprovisedGasMask"] = "MercenaryLoadout.MLO_Mask_Hat_ImprovisedGasMask",
    ["Base.Hat_ImprovisedGasMask_nofilter"] = "MercenaryLoadout.MLO_Mask_Hat_ImprovisedGasMask_nofilter",
    ["Base.Hat_HalloweenMaskDevil"] = "MercenaryLoadout.MLO_Mask_Hat_HalloweenMaskDevil",
    ["Base.Hat_HalloweenMaskMonster"] = "MercenaryLoadout.MLO_Mask_Hat_HalloweenMaskMonster",
    ["Base.Hat_HalloweenMaskPumpkin"] = "MercenaryLoadout.MLO_Mask_Hat_HalloweenMaskPumpkin",
    ["Base.Hat_HalloweenMaskSkeleton"] = "MercenaryLoadout.MLO_Mask_Hat_HalloweenMaskSkeleton",
    ["Base.Hat_HalloweenMaskVampire"] = "MercenaryLoadout.MLO_Mask_Hat_HalloweenMaskVampire",
    ["Base.Hat_HalloweenMaskWitch"] = "MercenaryLoadout.MLO_Mask_Hat_HalloweenMaskWitch",
    ["Base.Hat_HockeyMask_Hide"] = "MercenaryLoadout.MLO_Mask_Hat_HockeyMask_Hide",
    ["Base.Hat_BoneMask"] = "MercenaryLoadout.MLO_Mask_Hat_BoneMask",
    ["Base.Hat_HockeyMask_Wood"] = "MercenaryLoadout.MLO_Mask_Hat_HockeyMask_Wood",
    ["Base.Hat_HockeyMask_Metal"] = "MercenaryLoadout.MLO_Mask_Hat_HockeyMask_Metal",
    ["Base.Hat_HockeyMask_Copper"] = "MercenaryLoadout.MLO_Mask_Hat_HockeyMask_Copper",
    ["Base.Hat_HockeyMask_Gold"] = "MercenaryLoadout.MLO_Mask_Hat_HockeyMask_Gold",
    ["Base.Hat_HockeyMask_Silver"] = "MercenaryLoadout.MLO_Mask_Hat_HockeyMask_Silver",
}

M.SLOT_ORDER = {
    "MLO_Belt_HolsterL", "MLO_Belt_HolsterR",
    "MLO_Belt_ToolL", "MLO_Belt_ToolR",
    "MLO_Rig_PistolL", "MLO_Rig_PistolR",
    "MLO_Pack_SportBottle", "MLO_Pack_MedBox", "MLO_Pack_Toolbox",
    "MLO_Pack_WeldingMask", "MLO_Pack_Lantern",
    "MLO_Pack_CDPlayer", "MLO_Pack_PlushToy",
}

M.SLOT_LABEL_KEY = {
    MLO_Belt_HolsterL = "IGUI_MLO_Slot_BeltHolsterL",
    MLO_Belt_HolsterR = "IGUI_MLO_Slot_BeltHolsterR",
    MLO_Belt_ToolL = "IGUI_MLO_Slot_BeltToolL",
    MLO_Belt_ToolR = "IGUI_MLO_Slot_BeltToolR",
    MLO_Rig_PistolL = "IGUI_MLO_Slot_RigPistolL",
    MLO_Rig_PistolR = "IGUI_MLO_Slot_RigPistolR",
    MLO_Pack_SportBottle = "IGUI_MLO_Slot_PackSportBottle",
    MLO_Pack_MedBox = "IGUI_MLO_Slot_PackMedBox",
    MLO_Pack_Toolbox = "IGUI_MLO_Slot_PackToolbox",
    MLO_Pack_WeldingMask = "IGUI_MLO_Slot_PackWeldingMask",
    MLO_Pack_Lantern = "IGUI_MLO_Slot_PackLantern",
    MLO_Pack_CDPlayer = "IGUI_MLO_Slot_PackCDPlayer",
    MLO_Pack_PlushToy = "IGUI_MLO_Slot_PackPlushToy",
}

M.PARENT_NAME_KEY = {
    belt = "IGUI_MLO_Name_TacticalBelt",
    rig = "IGUI_MLO_Name_TacticalRig",
    pack = "IGUI_MLO_Name_TacticalPack",
    thighL = "IGUI_MLO_Name_ThighGuardL",
    thighR = "IGUI_MLO_Name_ThighGuardR",
}

M.MODULE_NAME_KEY = {
    beltPouch1 = "IGUI_MLO_Name_BeltPouch1",
    beltPouch2 = "IGUI_MLO_Name_BeltPouch2",
    beltPouch3 = "IGUI_MLO_Name_BeltPouch3",
    beltKeyClip = "IGUI_MLO_Name_KeyClip",
    rigPouchL = "IGUI_MLO_Name_RigPouchL",
    rigPouchR = "IGUI_MLO_Name_RigPouchR",
    packTopPouch = "IGUI_MLO_Name_PackTopPouch",
    packSideL = "IGUI_MLO_Name_PackSideL",
    packSideR = "IGUI_MLO_Name_PackSideR",
    -- Mounted medical kits and toolboxes keep the source item's vanilla name.
}

M.MODULE_SLOT = {
    packMedBox = "MLO_Pack_MedBox",
    packToolbox = "MLO_Pack_Toolbox",
}

M.MODULE_BODY_LOCATION = {
    beltPouch1 = MercenaryLoadoutRegistry.ItemBodyLocation.BeltPouch1,
    beltPouch2 = MercenaryLoadoutRegistry.ItemBodyLocation.BeltPouch2,
    beltPouch3 = MercenaryLoadoutRegistry.ItemBodyLocation.BeltPouch3,
    rigPouchL = MercenaryLoadoutRegistry.ItemBodyLocation.RigPouchL,
    rigPouchR = MercenaryLoadoutRegistry.ItemBodyLocation.RigPouchR,
    rigMagPanel = MercenaryLoadoutRegistry.ItemBodyLocation.RigMagPanel,
    packTopPouch = MercenaryLoadoutRegistry.ItemBodyLocation.PackTopPouch,
    packSideL = MercenaryLoadoutRegistry.ItemBodyLocation.PackSidePouchL,
    packSideR = MercenaryLoadoutRegistry.ItemBodyLocation.PackSidePouchR,
}

function M.registerBodyLocations()
    local group = BodyLocations and BodyLocations.getGroup("Human") or nil
    if not group then return false end
    for _, location in pairs(M.MODULE_BODY_LOCATION) do
        group:getOrCreateLocation(location)
    end
    return true
end

M.UPGRADE_GROUP = {
    -- Belt
    belt_pouch1 = "belt", belt_pouch2 = "belt",
    belt_keyclip = "belt",
    belt_doubleholster = "belt",
    belt_toolL = "belt", belt_toolR = "belt",

    -- Rig
    rig_pouchL = "rig", rig_pouchR = "rig",
    rig_shoulderL = "rig", rig_shoulderR = "rig",

    -- Pack
    pack_topPouch = "pack",
    pack_sidePouchL = "pack",
    pack_sidePouchR = "pack",
    pack_sportBottle = "pack",
    pack_medBox = "pack",
    pack_toolbox = "pack",
    pack_weldingMask = "pack",
    pack_lantern = "pack",
    pack_cdplayer = "pack",
    pack_plushToy = "pack",

}

-- Keep every historical thigh type recognizable so an already-upgraded RC1.2
-- item retains its slot and dynamic name. New tactical-thigh upgrades are
-- intentionally limited to the two vanilla military body-armour variants.
M.UPGRADE_PARENT_TYPES = {
}

M.UPGRADES = {
    -- materials are all vanilla.  No ripped sheets are used anywhere.
    belt_pouch1 = {
        labelKey = "IGUI_MLO_Upgrade_BeltPouch1",
        time = 600, tailoring = 1, sourceSet = "FANNY", sourceEmpty = true,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1 },
        tools = { "Base.Needle" },
    },
    belt_pouch2 = {
        labelKey = "IGUI_MLO_Upgrade_BeltPouch2",
        time = 650, tailoring = 2, sourceSet = "FANNY", sourceEmpty = true,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    belt_keyclip = {
        labelKey = "IGUI_MLO_Upgrade_BeltKeyClip",
        time = 650, tailoring = 2,
        sources = {
            { sourceTag = "KEY_RING", missingKey = "IGUI_MLO_Error_SourceKeyRing" },
            { sourceTag = "KEY_RING", sourceEmpty = true, missingKey = "IGUI_MLO_Error_SourceKeyRing" },
            { sourceTag = "KEY_RING", sourceEmpty = true, missingKey = "IGUI_MLO_Error_SourceKeyRing" },
        },
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Wire"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Pliers" },
    },
    belt_doubleholster = {
        labelKey = "IGUI_MLO_Upgrade_BeltDoubleHolster",
        time = 900, tailoring = 4, sourceTypes = {["Base.HolsterDouble"]=true},
        materials = { ["Base.LeatherStrips"] = 2, ["Base.Thread"] = 2, ["Base.Buckle"] = 2 },
        tools = { "Base.Needle" },
    },
    belt_toolL = {
        labelKey = "IGUI_MLO_Upgrade_BeltToolL",
        time = 450, tailoring = 1,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    belt_toolR = {
        labelKey = "IGUI_MLO_Upgrade_BeltToolR",
        time = 450, tailoring = 1,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },

    rig_pouchL = {
        labelKey = "IGUI_MLO_Upgrade_RigPouchL",
        time = 650, tailoring = 2,
        sources = {
            { sourceSet = "FANNY", sourceEmpty = true },
            { sourceSet = "BULLET_STRAP", missingKey = "IGUI_MLO_Error_SourceBulletStrap" },
        },
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    rig_pouchR = {
        labelKey = "IGUI_MLO_Upgrade_RigPouchR",
        time = 650, tailoring = 2,
        sources = {
            { sourceSet = "FANNY", sourceEmpty = true },
            { sourceSet = "SHELL_STRAP", missingKey = "IGUI_MLO_Error_SourceShellStrap" },
        },
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    rig_shoulderL = {
        labelKey = "IGUI_MLO_Upgrade_RigShoulderL",
        time = 850, tailoring = 4, sourceTypes = {["Base.HolsterShoulder"]=true}, sourceEmpty = true,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    rig_shoulderR = {
        labelKey = "IGUI_MLO_Upgrade_RigShoulderR",
        time = 850, tailoring = 4, sourceTypes = {["Base.HolsterShoulder"]=true}, sourceEmpty = true,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    pack_topPouch = {
        labelKey = "IGUI_MLO_Upgrade_PackTopPouch",
        time = 650, tailoring = 2, sourceSet = "FANNY", sourceEmpty = true,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    pack_sidePouchL = {
        labelKey = "IGUI_MLO_Upgrade_PackSidePouchL",
        time = 700, tailoring = 3, sourceSet = "SATCHEL", sourceEmpty = true,
        materials = { ["Base.LeatherStrips"] = 2, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle", "Base.Scissors" },
    },
    pack_sidePouchR = {
        labelKey = "IGUI_MLO_Upgrade_PackSidePouchR",
        time = 700, tailoring = 3, sourceSet = "SATCHEL", sourceEmpty = true,
        materials = { ["Base.LeatherStrips"] = 2, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle", "Base.Scissors" },
    },
    pack_sportBottle = {
        labelKey = "IGUI_MLO_Upgrade_PackSportBottle",
        time = 500, tailoring = 2,
        materials = { ["Base.LeatherStrips"] = 2, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    pack_medBox = {
        labelKey = "IGUI_MLO_Upgrade_PackMedBox",
        time = 850, tailoring = 3,
        materials = { ["Base.LeatherStrips"] = 2, ["Base.Thread"] = 1, ["Base.Buckle"] = 2 },
        tools = { "Base.Needle" },
    },
    pack_toolbox = {
        labelKey = "IGUI_MLO_Upgrade_PackToolbox",
        time = 900, tailoring = 4,
        materials = { ["Base.LeatherStrips"] = 3, ["Base.Wire"] = 1, ["Base.Buckle"] = 2 },
        tools = { "Base.Pliers" },
    },
    pack_weldingMask = {
        labelKey = "IGUI_MLO_Upgrade_PackWeldingMask",
        time = 500, tailoring = 2,
        materials = { ["Base.LeatherStrips"] = 2, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    pack_lantern = {
        labelKey = "IGUI_MLO_Upgrade_PackLantern",
        time = 700, tailoring = 4,
        materials = { ["Base.LeatherStrips"] = 3, ["Base.Wire"] = 1, ["Base.Buckle"] = 2 },
        tools = { "Base.Pliers" },
    },
    pack_cdplayer = {
        labelKey = "IGUI_MLO_Upgrade_PackCDPlayer",
        time = 500, tailoring = 1,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },
    pack_plushToy = {
        labelKey = "IGUI_MLO_Upgrade_PackPlushToy",
        time = 500, tailoring = 1,
        materials = { ["Base.LeatherStrips"] = 1, ["Base.Thread"] = 1, ["Base.Buckle"] = 1 },
        tools = { "Base.Needle" },
    },

}

M.UPGRADE_ORDER = {
    belt = {"belt_pouch1","belt_pouch2","belt_keyclip","belt_doubleholster","belt_toolL","belt_toolR"},
    rig = {"rig_pouchL","rig_pouchR","rig_shoulderL","rig_shoulderR"},
    pack = {"pack_topPouch","pack_sidePouchL","pack_sidePouchR","pack_sportBottle","pack_medBox","pack_toolbox","pack_weldingMask","pack_lantern","pack_cdplayer","pack_plushToy"},
}

-- Armor is data over the same fixed-pocket and native hardpoint lifecycle.
-- Each module key belongs to one exact side/space, even when its item type is shared.
M.ARMOR_EQUIPMENT = {
    { fullType="Base.Vambrace_BodyArmour_Left_Army", group="armL", opposite="armR", name="ArmGuardL",
      pockets={{"arm_pouchL","armPouchL","ArmPouchL"}} },
    { fullType="Base.Vambrace_BodyArmour_Right_Army", group="armR", opposite="armL", name="ArmGuardR",
      pockets={{"arm_pouchR","armPouchR","ArmPouchR"}} },
    { fullType="Base.ThighBodyArmour_L_Army", group="thighL", opposite="thighR", name="ThighGuardL",
      pockets={{"thigh_pouchL1","thighPouchL1","ThighPouchL1"},{"thigh_pouchL2","thighPouchL2","ThighPouchL2"}},
      mount={ key="thigh_pistolL", slot="MLO_Thigh_PistolL", kind="pistol", label="ThighPistolL", template="HolsterLeft", model="mlo_thigh_pistol_left" } },
    { fullType="Base.ThighBodyArmour_R_Army", group="thighR", opposite="thighL", name="ThighGuardR",
      pockets={{"thigh_pouchR1","thighPouchR1","ThighPouchR1"},{"thigh_pouchR2","thighPouchR2","ThighPouchR2"}},
      mount={ key="thigh_pistolR", slot="MLO_Thigh_PistolR", kind="pistol", label="ThighPistolR", template="HolsterRight", model="mlo_thigh_pistol_right" } },
    { fullType="Base.GreaveBodyArmour_Left_Army", group="greaveL", opposite="greaveR", name="GreaveGuardL", pockets={},
      mount={ key="greave_knifeL", slot="MLO_Greave_KnifeL", kind="knife", label="GreaveKnifeL", template="SmallBeltLeft", model="mlo_greave_knife_left" } },
    { fullType="Base.GreaveBodyArmour_Right_Army", group="greaveR", opposite="greaveL", name="GreaveGuardR", pockets={},
      mount={ key="greave_knifeR", slot="MLO_Greave_KnifeR", kind="knife", label="GreaveKnifeR", template="SmallBeltRight", model="mlo_greave_knife_right" } },
}
M.ARMOR_PARENT_GROUP = {}
M.ARMOR_POUCH_UPGRADE = {}
M.ARMOR_MOUNTS = {}
local function addArmorUpgrade(equipment, key, label, template)
    local def = {}
    -- Nested requirement tables are read-only inputs to the shared transaction.
    for field, value in pairs(template) do def[field] = value end
    def.labelKey = "IGUI_MLO_Upgrade_" .. label
    M.UPGRADES[key] = def
    M.UPGRADE_GROUP[key] = equipment.group
    M.UPGRADE_PARENT_TYPES[key] = { [equipment.fullType] = true }
    table.insert(M.UPGRADE_ORDER[equipment.group], key)
    return def
end
for _, equipment in ipairs(M.ARMOR_EQUIPMENT) do
    M.ARMOR_PARENT_GROUP[equipment.fullType] = equipment.group
    M.PARENT_NAME_KEY[equipment.group] = "IGUI_MLO_Name_" .. equipment.name
    M.UPGRADE_ORDER[equipment.group] = {}
    for _, pocket in ipairs(equipment.pockets) do
        local key, moduleKey, label = pocket[1], pocket[2], pocket[3]
        addArmorUpgrade(equipment, key, label, M.UPGRADES.pack_topPouch)
        M.ARMOR_POUCH_UPGRADE[key] = moduleKey
        M.FIXED_POUCH[moduleKey] = {
            fullType=M.FIXED_POUCH.packTopPouch.fullType, capacity=M.FIXED_POUCH.packTopPouch.capacity,
        }
        M.MODULE_NAME_KEY[moduleKey] = "IGUI_MLO_Name_" .. label
    end
    local mount = equipment.mount
    if mount then
        local def
        if mount.kind == "pistol" then
            def = addArmorUpgrade(equipment, mount.key, mount.label, M.UPGRADES.rig_shoulderL)
            def.sourceTypes = {
                ["Base.HolsterSimple"]=true, ["Base.HolsterSimple_Black"]=true,
                ["Base.HolsterSimple_Brown"]=true, ["Base.HolsterSimple_Green"]=true,
            }
        else
            def = addArmorUpgrade(equipment, mount.key, mount.label, {
                time=750, tailoring=3, sourceTypes={["Base.HolsterAnkle"]=true},
                materials={["Base.LeatherStrips"]=2,["Base.Thread"]=2,["Base.Buckle"]=1}, tools={"Base.Needle"},
            })
        end
        def.sourceEmpty = true
        mount.group = equipment.group
        M.ARMOR_MOUNTS[mount.slot] = mount
        M.ATTACHED[mount.slot] = mount.model
        M.CUSTOM_ATTACHED_NAME[mount.slot] = mount.model
        M.HOTBAR_TEMPLATE[mount.slot] = mount.template
        M.SLOT_LABEL_KEY[mount.slot] = "IGUI_MLO_Slot_" .. mount.label
        M.SLOT_ALLOWED_ATTACHMENT_TYPES[mount.slot] = mount.kind == "pistol"
            and { Holster=mount.slot, HolsterSmall=mount.slot } or { Knife=mount.slot }
        table.insert(M.SLOT_ORDER, mount.slot)
    end
end

local function safeCall(fn, fallback)
    local ok, value = pcall(fn)
    if ok then return value end
    return fallback
end

function M.itemArgument(fullType)
    return { kind = "item", value = tostring(fullType or "") }
end

function M.textArgument(key)
    return { kind = "text", value = tostring(key or "") }
end

function M.message(key, ...)
    return { key = tostring(key or "IGUI_MLO_Error_Generic"), args = {...} }
end

function M.localizeArgument(argument)
    if type(argument) == "table" and argument.kind == "item" then
        return safeCall(function() return getItemNameFromFullType(argument.value) end, argument.value)
    end
    if type(argument) == "table" and argument.kind == "text" then return M.text(argument.value) end
    return tostring(argument == nil and "" or argument)
end

function M.text(key, args)
    local values = {}
    for index, argument in ipairs(args or {}) do values[index] = M.localizeArgument(argument) end
    return safeCall(function()
        if #values == 0 then return getText(key) end
        if #values == 1 then return getText(key, values[1]) end
        if #values == 2 then return getText(key, values[1], values[2]) end
        if #values == 3 then return getText(key, values[1], values[2], values[3]) end
        return getText(key, values[1], values[2], values[3], values[4])
    end, tostring(key))
end

function M.localize(message)
    if type(message) == "table" and message.key then return M.text(message.key, message.args) end
    if type(message) == "string" then return M.text(message) end
    return M.text("IGUI_MLO_Error_Generic")
end

function M.writeMessagePayload(payload, message)
    payload = payload or {}
    if type(message) ~= "table" or not message.key then return payload end
    payload.messageKey = message.key
    for index, argument in ipairs(message.args or {}) do
        if index > 4 then break end
        if type(argument) == "table" and argument.kind == "item" then
            payload["messageArg" .. index] = argument.value
            payload["messageArg" .. index .. "Kind"] = "item"
        elseif type(argument) == "table" and argument.kind == "text" then
            payload["messageArg" .. index] = argument.value
            payload["messageArg" .. index .. "Kind"] = "text"
        else
            payload["messageArg" .. index] = tostring(argument == nil and "" or argument)
        end
    end
    return payload
end

function M.readMessagePayload(payload)
    if not payload or not payload.messageKey then return nil end
    local args = {}
    for index = 1, 4 do
        local value = payload["messageArg" .. index]
        if value == nil then break end
        if payload["messageArg" .. index .. "Kind"] == "item" then
            args[index] = M.itemArgument(value)
        elseif payload["messageArg" .. index .. "Kind"] == "text" then
            args[index] = M.textArgument(value)
        else
            args[index] = value
        end
    end
    return { key = payload.messageKey, args = args }
end

function M.upgradeDurationTicks(player, baseTime)
    local duration = tonumber(baseTime) or 1
    if duration <= 1 or not player then return duration end
    local moodles = safeCall(function() return player:getMoodles() end, nil)
    if moodles and MoodleType then
        local unhappy = safeCall(function() return moodles:getMoodleLevel(MoodleType.UNHAPPY) end, 0) or 0
        local drunk = safeCall(function() return moodles:getMoodleLevel(MoodleType.DRUNK) end, 0) or 0
        duration = duration * (1 + unhappy / 4) * (1 + drunk / 4)
    end
    if BodyPartType then
        local damage = safeCall(function() return player:getBodyDamage() end, nil)
        local first = safeCall(function() return BodyPartType.ToIndex(BodyPartType.Hand_L) end, nil)
        local last = safeCall(function() return BodyPartType.ToIndex(BodyPartType.ForeArm_R) end, nil)
        if damage and first and last then
            local pain = 0
            for index = first, last do
                pain = pain + (safeCall(function()
                    return damage:getBodyPart(BodyPartType.FromIndex(index)):getPain()
                end, 0) or 0)
            end
            duration = duration * (1 + pain / 300)
        end
    end
    duration = duration * (safeCall(function() return player:getTimedActionTimeModifier() end, 1) or 1)
    return math.max(1, duration)
end

M._loggedFailures = M._loggedFailures or {}
function M.logOnce(key, message)
    if M._loggedFailures[key] then return end
    M._loggedFailures[key] = true
    print("[MercenaryLoadout] " .. tostring(message))
end

local function itemId(item)
    return safeCall(function() return tostring(item:getID()) end, "?")
end

local function playerId(player)
    return safeCall(function() return tostring(player:getOnlineID()) end, "local")
end

function M.fullType(item)
    if not item then return "" end
    return safeCall(function() return tostring(item:getFullType()) end, "")
end

function M.detachableAttachmentType(item)
    local fullType = M.fullType(item)
    for family, attachmentType in pairs(M.DETACHABLE_ATTACHMENT_TYPE) do
        if M.TYPE[family] and M.TYPE[family][fullType] then
            -- Walkie is already a vanilla ALICE/webbing attachment family and
            -- both universal canteen/device hooks explicitly accept it.
            local current = safeCall(function() return item:getAttachmentType() end, nil)
            if current == "Walkie" and (family == "CANTEEN" or family == "DEVICE") then
                return current
            end
            return attachmentType
        end
    end
    return nil
end

function M.ensureDetachableItemState(item, player)
    if not item then return true end
    local desired = M.detachableAttachmentType(item)
    if desired then
        local current = safeCall(function() return item:getAttachmentType() end, nil)
        if current ~= desired then
            local wrote = pcall(function() item:setAttachmentType(desired) end)
            if not wrote or safeCall(function() return item:getAttachmentType() end, nil) ~= desired then
                return false
            end
        end
    end
    return true
end

M.CONTAINER_REPAIR_SCHEMA = 3

-- A factory item is a read-only template, never a replacement for the saved
-- item.  The repair below only copies scalar vanilla fields to the existing
-- object and its existing ItemContainer, preserving item ID and all contents.
local function pristineVanillaContainerState(item)
    local fullType=M.fullType(item)
    local fallback=M.VANILLA_CONTAINER_STATE[fullType]
    local template=safeCall(function()
        return InventoryItemFactory and InventoryItemFactory.CreateItem(fullType) or nil
    end,nil)
    local templateInventory=template and safeCall(function() return template:getInventory() end,nil) or nil
    if templateInventory and safeCall(function() return template:IsInventoryContainer() end,false)
        and safeCall(function() return templateInventory:getContainingItem() end,nil)==template then
        local state={
            outerCapacity=safeCall(function() return tonumber(template:getCapacity()) end,nil),
            innerCapacity=safeCall(function() return tonumber(templateInventory:getCapacity()) end,nil),
            outerWeightReduction=safeCall(function() return tonumber(template:getWeightReduction()) end,nil),
            innerWeightReduction=safeCall(function() return tonumber(templateInventory:getWeightReduction()) end,nil),
            maxItemSize=safeCall(function() return tonumber(template:getMaxItemSize()) end,nil),
            openSound=safeCall(function() return templateInventory:getOpenSound() end,nil),
            closeSound=safeCall(function() return templateInventory:getCloseSound() end,nil),
            putSound=safeCall(function() return templateInventory:getPutSound() end,nil),
            onlyAcceptCategory=safeCall(function() return templateInventory:getOnlyAcceptCategory() end,nil),
            acceptItemFunction=safeCall(function() return templateInventory:getAcceptItemFunction() end,nil),
            innerType=safeCall(function() return templateInventory:getType() end,nil),
        }
        if state.outerCapacity~=nil and state.innerCapacity~=nil
            and state.outerWeightReduction~=nil and state.innerWeightReduction~=nil then
            return state, "factory"
        end
    end
    if not fallback then return nil, "missing-template" end
    return {
        outerCapacity=tonumber(fallback.capacity), innerCapacity=tonumber(fallback.capacity),
        outerWeightReduction=tonumber(fallback.weightReduction), innerWeightReduction=tonumber(fallback.weightReduction),
        maxItemSize=tonumber(fallback.maxItemSize), openSound=fallback.openSound,
        closeSound=fallback.closeSound, putSound=fallback.putSound,
        onlyAcceptCategory=nil, acceptItemFunction=nil,
        innerType=safeCall(function() return item:getType() end,nil),
    }, "fallback"
end

-- dev.5 temporarily re-declared Base containers and could persist incomplete
-- outer/inner container fields in an existing save.  Repair those fields once,
-- on the same vanilla item, then leave the container entirely to Base logic.
-- This function never participates in ordinary attach/detach synchronization.
function M.repairLegacyVanillaContainerState(item, player, tx, forceCurrentSchema)
    if not item then return false, false, "missing-item" end
    if not M.VANILLA_CONTAINER_STATE[M.fullType(item)] then return true, false, nil end
    local md = item:getModData()
    local repairSchema=tonumber(md.MLO_containerRepairSchema)
    local repairPending=md.MLO_legacyContainerRepairPending==true
    if not repairPending and repairSchema and repairSchema >= M.CONTAINER_REPAIR_SCHEMA then
        return true, false, nil
    end

    -- Only an old repair schema or the explicit direct-migration marker proves
    -- that this exact saved Base item used the retired proxy/equipment route.
    -- Current mount, visual, AttachmentType and schema markers are ordinary
    -- runtime state and must never make a healthy container eligible.
    local legacyEvidence = repairSchema==2 or repairPending
    if not legacyEvidence then return true, false, nil end

    if not safeCall(function() return item:IsInventoryContainer() end, false) then
        return false, false, "not-inventory-container"
    end
    local inventory = safeCall(function() return item:getInventory() end, nil)
    if not inventory then return false, false, "missing-inner-container" end
    local containing = safeCall(function() return inventory:getContainingItem() end, nil)
    if containing ~= item then return false, false, "containing-item-mismatch" end

    -- Validate the live Base script before touching persisted state.  A
    -- mismatch means another script still owns this type; fail closed instead
    -- of partially rewriting the instance and discovering the conflict later.
    local vanilla, templateSource = pristineVanillaContainerState(item)
    if not vanilla then return false, false, templateSource end
    local maxItemSize = safeCall(function() return tonumber(item:getMaxItemSize()) end, nil)
    if maxItemSize and vanilla.maxItemSize
        and math.abs(maxItemSize - vanilla.maxItemSize) > 0.0001 then
        return false, false, "base-script-max-item-size-mismatch"
    end

    local snapshot = {
        outerCapacity = safeCall(function() return tonumber(item:getCapacity()) end, nil),
        innerCapacity = safeCall(function() return tonumber(inventory:getCapacity()) end, nil),
        outerWeightReduction = safeCall(function() return tonumber(item:getWeightReduction()) end, nil),
        innerWeightReduction = safeCall(function() return tonumber(inventory:getWeightReduction()) end, nil),
        openSound = safeCall(function() return inventory:getOpenSound() end, nil),
        closeSound = safeCall(function() return inventory:getCloseSound() end, nil),
        putSound = safeCall(function() return inventory:getPutSound() end, nil),
        onlyAcceptCategory = safeCall(function() return inventory:getOnlyAcceptCategory() end, nil),
        acceptItemFunction = safeCall(function() return inventory:getAcceptItemFunction() end, nil),
        repairSchema = md.MLO_containerRepairSchema,
        repairPending = md.MLO_legacyContainerRepairPending,
    }
    if snapshot.outerCapacity == nil or snapshot.innerCapacity == nil
        or snapshot.outerWeightReduction == nil or snapshot.innerWeightReduction == nil then
        return false, false, "unreadable-container-state"
    end

    local function restoreSnapshot()
        local restored = pcall(function()
            item:setCapacity(snapshot.outerCapacity)
            inventory:setCapacity(snapshot.innerCapacity)
            item:setWeightReduction(snapshot.outerWeightReduction)
            inventory:setWeightReduction(snapshot.innerWeightReduction)
            inventory:setOpenSound(snapshot.openSound)
            inventory:setCloseSound(snapshot.closeSound)
            inventory:setPutSound(snapshot.putSound)
            inventory:setOnlyAcceptCategory(snapshot.onlyAcceptCategory)
            inventory:setAcceptItemFunction(snapshot.acceptItemFunction)
            md.MLO_containerRepairSchema = snapshot.repairSchema
            md.MLO_legacyContainerRepairPending = snapshot.repairPending
        end)
        return restored
    end

    local changed = false
    local repaired = pcall(function()
        if snapshot.outerCapacity ~= vanilla.outerCapacity then
            item:setCapacity(vanilla.outerCapacity)
            changed = true
        end
        if snapshot.innerCapacity ~= vanilla.innerCapacity then
            inventory:setCapacity(vanilla.innerCapacity)
            changed = true
        end
        if snapshot.outerWeightReduction ~= vanilla.outerWeightReduction then
            item:setWeightReduction(vanilla.outerWeightReduction)
            changed = true
        end
        if snapshot.innerWeightReduction ~= vanilla.innerWeightReduction then
            inventory:setWeightReduction(vanilla.innerWeightReduction)
            changed = true
        end
        if snapshot.openSound ~= vanilla.openSound then
            inventory:setOpenSound(vanilla.openSound)
            changed = true
        end
        if snapshot.closeSound ~= vanilla.closeSound then
            inventory:setCloseSound(vanilla.closeSound)
            changed = true
        end
        if snapshot.putSound ~= vanilla.putSound then
            inventory:setPutSound(vanilla.putSound)
            changed = true
        end
        if snapshot.onlyAcceptCategory ~= vanilla.onlyAcceptCategory then
            inventory:setOnlyAcceptCategory(vanilla.onlyAcceptCategory)
            changed = true
        end
        if snapshot.acceptItemFunction ~= vanilla.acceptItemFunction then
            inventory:setAcceptItemFunction(vanilla.acceptItemFunction)
            changed = true
        end
        md.MLO_legacyContainerRepairPending = nil
        md.MLO_containerRepairSchema = M.CONTAINER_REPAIR_SCHEMA
        if snapshot.repairSchema ~= M.CONTAINER_REPAIR_SCHEMA or snapshot.repairPending==true then changed = true end
    end)
    if not repaired then
        if not restoreSnapshot() then return false, true, "legacy-field-repair-rollback-failed" end
        return false, false, "legacy-field-repair-failed"
    end
    if changed and tx then M.addUndo(tx, restoreSnapshot) end
    return true, changed, nil
end

function M.repairLegacyVanillaContainers(player, forceCurrentSchema, localOnly)
    if not player then return false, 0, M.message("IGUI_MLO_Error_InvalidPlayer") end
    local tx = M.newTransaction(player)
    local changedCount = 0
    for _, item in ipairs(M.allRecursiveItems(player)) do
        local repaired, changed, reason = M.repairLegacyVanillaContainerState(item, player, tx, forceCurrentSchema)
        if not repaired then
            M.logOnce("container-repair:" .. itemId(item),
                "legacy vanilla container audit failed for " .. itemId(item) .. ": " .. tostring(reason))
            local _, abortReason = M.abortTransaction(tx, M.message("IGUI_MLO_Error_InvalidContainer"))
            return false, 0, abortReason
        end
        if changed then
            changedCount = changedCount + 1
            if not localOnly then M.markItemDirty(tx, item) end
            M.logOnce("container-repair:done:" .. itemId(item),
                "repaired legacy vanilla container fields once for " .. itemId(item))
        end
    end
    if localOnly then return true, changedCount, nil end
    local committed, reason = M.commitTransaction(tx)
    if not committed then return false, changedCount, reason end
    return true, changedCount, nil
end

-- Build 42's ContainerID treats an ItemContainer whose parent is the player as
-- PlayerInventory.  A held InventoryContainer instead keeps the outer item in
-- the player's root inventory while its inner container has no world/player
-- parent and points back through containingItem.  Preserve that exact vanilla
-- ownership chain for mounted medical kits/toolboxes without occupying a hand.
function M.ensureMountedContainerTransport(player, item, tx, snapshot)
    if not player or not item then return false, false, "missing-item" end
    local parent, slotId=M.findPersistentMountParent(player,item,snapshot)
    if not parent or (slotId~=M.MODULE_SLOT.packMedBox and slotId~=M.MODULE_SLOT.packToolbox) then
        return true, false, nil
    end
    if not M.VANILLA_CONTAINER_STATE[M.fullType(item)]
        or not safeCall(function() return item:IsInventoryContainer() end,false) then
        return false, false, "not-vanilla-inventory-container"
    end
    if safeCall(function() return item:getContainer() end,nil)~=player:getInventory()
        or M.getPersistentMountId(parent,slotId)~=tonumber(item:getID()) then
        return false, false, "mounted-container-not-in-root"
    end
    local inventory=safeCall(function() return item:getInventory() end,nil)
    if not inventory then return false, false, "missing-inner-container" end
    if safeCall(function() return inventory:getContainingItem() end,nil)~=item then
        return false, false, "containing-item-mismatch"
    end
    local previousParent=safeCall(function() return inventory:getParent() end,nil)
    if previousParent==nil then return true, false, nil end

    if tx then
        M.addUndo(tx,function()
            local restored=pcall(function() inventory:setParent(previousParent) end)
            return restored and safeCall(function() return inventory:getParent() end,false)==previousParent
        end)
    end
    local cleared=pcall(function() inventory:setParent(nil) end)
    if not cleared or safeCall(function() return inventory:getParent() end,false)~=nil then
        return false, false, "inner-parent-clear-failed"
    end
    return true, true, nil
end

function M.dynamicNameKey(item)
    if not item then return nil end
    local md = item:getModData()
    local group = M.groupOf and M.groupOf(item) or nil
    if md and group and M.PARENT_NAME_KEY[group] then
        local upgraded = false
        for _, key in ipairs(M.UPGRADE_ORDER[group] or {}) do
            if md["MLO_up_" .. key] == true then
                upgraded = true
                break
            end
        end
        if upgraded then
            md.MLO_nameKey = M.PARENT_NAME_KEY[group]
        elseif md.MLO_nameKey == M.PARENT_NAME_KEY[group] then
            md.MLO_nameKey = nil
        end
    end
    if md and md.MLO_nameKey then return tostring(md.MLO_nameKey) end
    if md and md.MLO_moduleKey and M.MODULE_NAME_KEY[md.MLO_moduleKey] then
        md.MLO_nameKey = M.MODULE_NAME_KEY[md.MLO_moduleKey]
        return md.MLO_nameKey
    end
    return nil
end

function M.displayName(item)
    if not item then return "" end
    local key = M.dynamicNameKey(item)
    if key then return M.text(key) end
    return safeCall(function() return tostring(item:getDisplayName()) end, M.fullType(item))
end

function M.setDynamicName(item, key)
    if not item or not key then return false end
    local md = item:getModData()
    md.MLO_nameKey = key
    return true
end

function M.refreshDynamicName(item)
    local key = M.dynamicNameKey(item)
    if not key then return true end
    local translated = M.text(key)
    local current = safeCall(function() return tostring(item:getDisplayName()) end, nil)
    local custom = safeCall(function() return item:isCustomName() end, false)
    if current == translated and custom == true then return true end
    return safeCall(function()
        item:setName(translated)
        item:setCustomName(true)
        return true
    end, false)
end

function M.inSet(item, set)
    return item and set and set[M.fullType(item)] == true
end

function M.groupOf(item)
    if not item then return nil end
    local ft = M.fullType(item)
    if M.TYPE.BELT[ft] then return "belt" end
    if M.TYPE.RIG[ft] then return "rig" end
    if M.TYPE.PACK[ft] then return "pack" end
    if M.ARMOR_PARENT_GROUP[ft] then return M.ARMOR_PARENT_GROUP[ft] end
    if M.TYPE.THIGH_L[ft] then return "thighL" end
    if M.TYPE.THIGH_R[ft] then return "thighR" end
    return nil
end

function M.isParent(item)
    return M.groupOf(item) ~= nil
end

-- Component policy is shared by menus, authoritative upgrades and projections.
-- Missing options preserve the existing default-on behavior.
M.COMPONENT_OPTIONS = {"Backpack", "ALICE", "Belt", "Arm", "Thigh", "Greave"}
M.COMPONENT_GROUP = {pack="Backpack", rig="ALICE", belt="Belt",
    armL="Arm", armR="Arm", thighL="Thigh", thighR="Thigh", greaveL="Greave", greaveR="Greave"}
function M.componentOptionEnabled(name)
    local options = SandboxVars and SandboxVars.MercenaryLoadout
    return not options or options[name] ~= false
end
function M.componentEnabled(parent)
    local name = M.COMPONENT_GROUP[M.groupOf(parent)]
    return not name or M.componentOptionEnabled(name)
end
function M.componentGeneration(parent)
    local name = M.COMPONENT_GROUP[M.groupOf(parent)]
    return tonumber(M.componentGenerations and M.componentGenerations[name]) or 0
end
function M.isDetachedPouch(item)
    if not item or not M.isFixedPouchItem(item) then return false end
    local md = item:getModData()
    return md.MLO_detachedPouch == true and md.MLO_parentId == nil and md.MLO_moduleKey == nil
end

function M.isModuleItem(item)
    if not item then return false end
    local md = item:getModData()
    return M.MODULE_ITEM_TYPES[M.fullType(item)] == true
        or (md and md.MLO_parentId ~= nil)
end

function M.isFixedPouchItem(item)
    if not item then return false end
    local fullType = M.fullType(item)
    for _, fixed in pairs(M.FIXED_POUCH) do
        if fixed.fullType == fullType then return true end
    end
    return false
end

function M.allRecursiveItems(player)
    local out = {}
    if not player or not player:getInventory() then return out end

    -- Walk the raw ItemContainer lists. Build 42's evaluated recursive query
    -- omits hidden script items, which made sewn fixed pouches impossible to
    -- discover even though the parent retained their exact item IDs.
    local pending = { player:getInventory() }
    local seenContainers = {}
    while #pending > 0 do
        local container = table.remove(pending)
        if container and not seenContainers[container] then
            seenContainers[container] = true
            local items = safeCall(function() return container:getItems() end, nil)
            if items then
                for i = 0, items:size() - 1 do
                    local item = items:get(i)
                    if item then
                        out[#out + 1] = item
                        if safeCall(function() return item:IsInventoryContainer() end, false) then
                            local inner = safeCall(function() return item:getInventory() end, nil)
                            if inner then pending[#pending + 1] = inner end
                        end
                    end
                end
            end
        end
    end
    return out
end

-- Build one immutable view for a single reconciliation/projection pass.  The
-- old hot paths repeatedly called allRecursiveItems() from findById() and
-- mountedSlotForItem(), turning one inventory check into quadratic work.  A
-- snapshot is deliberately short-lived: callers rebuild it only after a real
-- inventory/equipment/server-state event, so it never becomes persistent game
-- state or competes with vanilla's ItemContainer ownership.
function M.inventorySnapshot(player)
    local items = M.allRecursiveItems(player)
    local byId = {}
    local parents = {}
    local mountByItemId = {}
    for _, item in ipairs(items) do
        local id = safeCall(function() return tonumber(item:getID()) end, nil)
        if id then byId[id] = item end
        if M.isParent(item) then
            parents[#parents + 1] = item
            for _, slotId in ipairs(M.SLOT_ORDER) do
                local mountedId = M.getPersistentMountId(item, slotId)
                if mountedId then
                    mountByItemId[mountedId] = { parent = item, slotId = slotId }
                end
            end
        end
    end
    return {
        items = items,
        byId = byId,
        parents = parents,
        mountByItemId = mountByItemId,
    }
end

function M.findById(player, id, snapshot)
    if not player or not id then return nil end
    local numeric = tonumber(id)
    if not numeric then return nil end
    if snapshot and snapshot.byId then return snapshot.byId[numeric] end
    for _, item in ipairs(M.allRecursiveItems(player)) do
        if safeCall(function() return tonumber(item:getID()) end, nil) == numeric then return item end
    end
    return nil
end

function M.itemUses(item)
    if not item then return 0 end
    if safeCall(function() return item:IsDrainable() end, false) then
        local uses = safeCall(function() return tonumber(item:getCurrentUses()) end, 0) or 0
        return math.max(0, uses)
    end
    return 1
end

function M.countUnits(player, ft)
    local total = 0
    for _, item in ipairs(M.allRecursiveItems(player)) do
        if M.fullType(item) == ft and not M.isModuleItem(item) then
            total = total + M.itemUses(item)
        end
    end
    return total
end

function M.findFirst(player, typeSet, predicate)
    for _, item in ipairs(M.allRecursiveItems(player)) do
        if (not typeSet or typeSet[M.fullType(item)]) and not M.isModuleItem(item) then
            if not predicate or predicate(item) then
                return item
            end
        end
    end
    return nil
end

function M.containerEmpty(item)
    if not item or not safeCall(function() return item:IsInventoryContainer() end, false) then return true end
    local inv = item:getInventory()
    return not inv or inv:isEmpty()
end

function M.isMagazine(item)
    if not item then return false end
    if safeCall(function() return item:IsWeapon() end, false) then return false end
    local maxAmmo = safeCall(function() return tonumber(item:getMaxAmmo()) end, 0) or 0
    local ammoType = safeCall(function() return item:getAmmoType() end, nil)
    if maxAmmo > 0 and ammoType and tostring(ammoType) ~= "" then return true end

    local ft = string.lower(M.fullType(item))
    -- Vanilla fallback for clip/magazine items; avoids literature magazines.
    if (string.find(ft, "clip", 1, true) or string.find(ft, "_mag", 1, true))
        and safeCall(function() return item:getCategory() == "Ammo" end, false) then
        return true
    end
    return false
end

function MercenaryAcceptItemFunction.Magazines(container, item)
    return MercenaryLoadout.isMagazine(item)
end

function M.sourceValidForMagazinePanel(item)
    if not item or not safeCall(function() return item:IsInventoryContainer() end, false) then return true end
    local inv = item:getInventory()
    if not inv then return true end
    local items = inv:getItems()
    for i=0,items:size()-1 do
        if not M.isMagazine(items:get(i)) then return false end
    end
    return true
end

function M.sourceRequirements(def)
    if not def then return {} end
    if def.sources then return def.sources end
    if def.sourceSet or def.sourceTypes or def.sourceTag then return { def } end
    return {}
end

function M.getSourceForRequirement(player, requirement, excluded)
    local def = requirement or {}
    local set = nil
    if def.sourceSet then set = M.TYPE[def.sourceSet] end
    if def.sourceTypes then set = def.sourceTypes end
    if not set and not def.sourceTag then return nil end

    return M.findFirst(player, set, function(item)
        if def.sourceTag and not safeCall(function()
            return item:hasTag(ItemTag[def.sourceTag])
        end, false) then return false end
        if excluded and excluded[item] then return false end
        -- Never consume/convert a vanilla component while it is currently worn,
        -- held or otherwise equipped.  This prevents ghost worn-item references.
        if safeCall(function() return item:isEquipped() end, false) then return false end
        if def.sourceEmpty and not M.containerEmpty(item) then return false end
        if def.sourceMagazineOnly and not M.sourceValidForMagazinePanel(item) then return false end
        return true
    end)
end

function M.getSourcesForUpgrade(player, def)
    local sources, excluded = {}, {}
    for _, requirement in ipairs(M.sourceRequirements(def)) do
        local source = M.getSourceForRequirement(player, requirement, excluded)
        if not source then return nil, requirement, sources end
        sources[#sources + 1] = source
        excluded[source] = true
    end
    return sources, nil, sources
end

function M.getSourceForUpgrade(player, def)
    local sources = M.getSourcesForUpgrade(player, def)
    return sources and sources[1] or nil
end

function M.isInstalled(parent, key)
    if not parent then return false end
    return parent:getModData()["MLO_up_"..tostring(key)] == true
end

function M.upgradeParentEligible(parent, key)
    if not parent or not M.componentEnabled(parent) then return false end
    local allowed = M.UPGRADE_PARENT_TYPES[key]
    return not allowed or allowed[M.fullType(parent)] == true
end

function M.checkUpgrade(player, parent, key)
    local def = M.UPGRADES[key]
    if not def then return false, M.message("IGUI_MLO_Error_UnknownUpgrade") end
    if not player or not parent then return false, M.message("IGUI_MLO_Error_EquipmentMissing") end
    if M.UPGRADE_GROUP[key] ~= M.groupOf(parent) then return false, M.message("IGUI_MLO_Error_WrongEquipment") end
    if not M.upgradeParentEligible(parent, key) then
        return false, M.message("IGUI_MLO_Error_WrongEquipment")
    end
    if M.isInstalled(parent, key) then return false, M.message("IGUI_MLO_Error_AlreadyInstalled") end

    local requiredTailoring = tonumber(def.tailoring) or 0
    local tailoringLevel = safeCall(function()
        return tonumber(player:getPerkLevel(Perks.Tailoring)) or 0
    end, 0)
    if tailoringLevel < requiredTailoring then
        return false, M.message("IGUI_MLO_Error_SkillLevel",
            M.textArgument("IGUI_perks_Tailoring"), requiredTailoring)
    end

    for ft, amount in pairs(def.materials or {}) do
        if M.countUnits(player, ft) < amount then
            return false, M.message("IGUI_MLO_Error_MissingMaterial", M.itemArgument(ft), amount)
        end
    end

    for _, ft in ipairs(def.tools or {}) do
        local found = M.findFirst(player, {[ft]=true}, function(item)
            return not safeCall(function() return item:isBroken() end, false)
        end)
        if not found then return false, M.message("IGUI_MLO_Error_MissingTool", M.itemArgument(ft)) end
    end

    local sourceRequirements = M.sourceRequirements(def)
    if #sourceRequirements > 0 then
        local sources, missingRequirement = M.getSourcesForUpgrade(player, def)
        if not sources then
            local missing = missingRequirement or def
            if missing.missingKey then
                return false, M.message(missing.missingKey)
            elseif missing.sourceMagazineOnly then
                return false, M.message("IGUI_MLO_Error_MagazineChestRig")
            elseif missing.sourceEmpty then
                return false, M.message("IGUI_MLO_Error_EmptyPartRequired")
            else
                return false, M.message("IGUI_MLO_Error_PartRequired")
            end
        end
    end

    return true, nil
end

function M.newTransaction(player)
    return {
        undos = {},
        materialSnapshots = {},
        player = player,
        networkOps = {},
        dirtyItems = {},
        newItems = {},
        equipDirty = false,
    }
end

function M.addUndo(tx, undo)
    if tx and undo then tx.undos[#tx.undos + 1] = undo end
end

local function networkRole()
    if type(isClient) == "function" and isClient() == true then return "client" end
    if type(isServer) == "function" and isServer() == true then return "server" end
    return nil
end

local function queueNetworkOp(tx, kind, container, item)
    if not tx or not item then return end
    tx.networkOps[#tx.networkOps + 1] = { kind = kind, container = container, item = item }
end

function M.markItemDirty(tx, item)
    if tx and item then tx.dirtyItems[item] = true end
end

function M.markEquipDirty(tx)
    if tx then tx.equipDirty = true end
end

local function flushNetwork(tx)
    if not tx then return true end
    local role = networkRole()
    if not role then return true end
    local ok = true
    for _, op in ipairs(tx.networkOps) do
        local sent = pcall(function()
            if op.kind == "remove" then
                sendRemoveItemFromContainer(op.container, op.item)
            elseif op.kind == "add" then
                sendAddItemToContainer(op.container, op.item)
            end
        end)
        if not sent then ok = false end
    end
    for item in pairs(tx.dirtyItems) do
        local container = safeCall(function() return item:getContainer() end, nil)
        if not tx.newItems[item] and container ~= nil then
            local synced
            synced = pcall(function() item:syncItemFields() end)
            if not synced then ok = false end
        end
    end
    if tx.equipDirty then
        local synced = pcall(function() sendEquip(tx.player) end)
        if not synced then ok = false end
    end
    if not ok then
        M.logOnce("network-sync:" .. tostring(tx), "one or more vanilla inventory/equipment sync calls failed")
    end
    return ok
end

function M.rollbackTransaction(tx)
    if not tx then return true end
    local restored = true
    for i = #tx.undos, 1, -1 do
        local ok, result = pcall(tx.undos[i])
        if not ok or result ~= true then
            restored = false
            M.logOnce("rollback:" .. tostring(tx) .. ":" .. tostring(i),
                "rollback failed at step " .. tostring(i) .. "; inventory state requires reconciliation")
        end
    end
    tx.undos = {}
    tx.networkOps = {}
    tx.dirtyItems = {}
    tx.newItems = {}
    tx.equipDirty = false
    return restored
end

function M.commitTransaction(tx)
    if not tx then return true end
    local synced = flushNetwork(tx)
    if not synced then
        if M.rollbackTransaction(tx) then
            return false, M.message("IGUI_MLO_Error_SyncState")
        end
        return false, M.message("IGUI_MLO_Error_RollbackFailed")
    end
    tx.undos = {}
    tx.networkOps = {}
    tx.dirtyItems = {}
    tx.newItems = {}
    tx.equipDirty = false
    return synced
end

function M.abortTransaction(tx, reason)
    if M.rollbackTransaction(tx) then return false, reason end
    return false, M.message("IGUI_MLO_Error_RollbackFailed")
end

local function itemContainer(item)
    return safeCall(function() return item:getContainer() end, nil)
end

local function addExistingItem(container, item)
    if not container or not item then return false end
    local ok = pcall(function() container:AddItem(item) end)
    return ok and itemContainer(item) == container
end

local function removeExistingItem(container, item)
    if not container or not item then return false end
    local ok = pcall(function() container:Remove(item) end)
    return ok and itemContainer(item) ~= container
end

local function restoreItemContainer(item, destination)
    local current = itemContainer(item)
    if current and current ~= destination and not removeExistingItem(current, item) then return false end
    if destination and itemContainer(item) ~= destination and not addExistingItem(destination, item) then return false end
    return itemContainer(item) == destination
end

function M.moveToRootTx(tx, player, item)
    if not tx or not player or not item then return false, M.message("IGUI_MLO_Error_InvalidItem") end
    tx.player = tx.player or player
    local root = player:getInventory()
    local original = itemContainer(item)
    if original == root then return true, nil end
    if not original then return false, M.message("IGUI_MLO_Error_ItemNotInInventory") end

    if not removeExistingItem(original, item) then
        if itemContainer(item) ~= original then addExistingItem(original, item) end
        return false, M.message("IGUI_MLO_Error_RemoveFromContainer")
    end
    if not addExistingItem(root, item) then
        addExistingItem(original, item)
        return false, M.message("IGUI_MLO_Error_MoveToInventory")
    end

    M.addUndo(tx, function()
        return restoreItemContainer(item, original)
    end)
    queueNetworkOp(tx, "remove", original, item)
    queueNetworkOp(tx, "add", root, item)
    return true, nil
end

function M.removeItemTx(tx, item)
    if not tx or not item then return false, M.message("IGUI_MLO_Error_InvalidItem") end
    local original = itemContainer(item)
    if not original then return false, M.message("IGUI_MLO_Error_SourceNotInInventory") end
    if not removeExistingItem(original, item) then
        if itemContainer(item) ~= original then addExistingItem(original, item) end
        return false, M.message("IGUI_MLO_Error_RemoveSource")
    end
    M.addUndo(tx, function()
        return restoreItemContainer(item, original)
    end)
    queueNetworkOp(tx, "remove", original, item)
    return true, nil
end

function M.setCapacityTx(tx, item, capacity)
    if not tx or not item then return false, M.message("IGUI_MLO_Error_InvalidContainer") end
    local previous = safeCall(function() return tonumber(item:getCapacity()) end, nil)
    local previousInner = safeCall(function() return tonumber(item:getInventory():getCapacity()) end, nil)
    local requested = tonumber(capacity)
    if not requested then return false, M.message("IGUI_MLO_Error_InvalidCapacity") end
    if previous and requested < previous and safeCall(function() return item:IsInventoryContainer() end, false) then
        local inventory = item:getInventory()
        local load = safeCall(function() return tonumber(inventory:getContentsWeight()) end, nil)
        if load == nil then load = safeCall(function() return tonumber(inventory:getCapacityWeight()) end, nil) end
        local empty = safeCall(function() return inventory:isEmpty() end, false)
        if not empty and (load == nil or load > requested) then
            return false, M.message("IGUI_MLO_Error_ContainerTooFull")
        end
    end
    M.addUndo(tx, function()
        if previous == nil then return true end
        local restored = pcall(function()
            item:setCapacity(previous)
            if previousInner ~= nil and item:IsInventoryContainer() then item:getInventory():setCapacity(previousInner) end
        end)
        return restored and safeCall(function() return tonumber(item:getCapacity()) end, nil) == previous
    end)
    local ok = pcall(function()
        item:setCapacity(capacity)
        if item:IsInventoryContainer() then item:getInventory():setCapacity(capacity) end
    end)
    if not ok
        or safeCall(function() return tonumber(item:getCapacity()) end, nil) ~= requested
        or (safeCall(function() return item:IsInventoryContainer() end, false)
            and safeCall(function() return tonumber(item:getInventory():getCapacity()) end, nil) ~= requested) then
        return false, M.message("IGUI_MLO_Error_SetCapacity")
    end
    M.markItemDirty(tx, item)
    return true, nil
end

function M.linkModuleTx(tx, player, parent, item, moduleKey, nameKey)
    if not tx or not player or not parent or not item then return false, M.message("IGUI_MLO_Error_InvalidModule") end
    local moved, moveReason = M.moveToRootTx(tx, player, item)
    if not moved then return false, moveReason end

    local itemMd = item:getModData()
    local parentMd = parent:getModData()
    local oldParentId = itemMd.MLO_parentId
    local oldModuleKey = itemMd.MLO_moduleKey
    local oldVersion = itemMd.MLO_version
    local oldModuleId = parentMd["MLO_module_" .. moduleKey]
    local oldOriginalName = itemMd.MLO_originalName
    local oldOriginalCustomName = itemMd.MLO_originalCustomName
    local oldOriginalFavorite = itemMd.MLO_originalFavorite
    local oldOriginalNameKey = itemMd.MLO_originalNameKey
    local oldNameKey = itemMd.MLO_nameKey
    local oldName = safeCall(function() return tostring(item:getDisplayName()) end, M.fullType(item))
    local oldCustom = safeCall(function() return item:isCustomName() end, false)
    local oldFavorite = safeCall(function() return item:isFavorite() end, false)

    M.addUndo(tx, function()
        itemMd.MLO_parentId = oldParentId
        itemMd.MLO_moduleKey = oldModuleKey
        itemMd.MLO_version = oldVersion
        itemMd.MLO_originalName = oldOriginalName
        itemMd.MLO_originalCustomName = oldOriginalCustomName
        itemMd.MLO_originalFavorite = oldOriginalFavorite
        itemMd.MLO_originalNameKey = oldOriginalNameKey
        itemMd.MLO_nameKey = oldNameKey
        parentMd["MLO_module_" .. moduleKey] = oldModuleId
        local ok = pcall(function()
            item:setName(oldName)
            item:setCustomName(oldCustom)
            item:setFavorite(oldFavorite)
        end)
        return ok and itemMd.MLO_parentId == oldParentId and itemMd.MLO_moduleKey == oldModuleKey
            and parentMd["MLO_module_" .. moduleKey] == oldModuleId
    end)

    local ok = pcall(function()
        itemMd.MLO_parentId = parent:getID()
        itemMd.MLO_moduleKey = moduleKey
        itemMd.MLO_version = M.VERSION
        itemMd.MLO_originalName = oldName
        itemMd.MLO_originalCustomName = oldCustom
        itemMd.MLO_originalFavorite = oldFavorite
        itemMd.MLO_originalNameKey = oldNameKey
        if nameKey then
            itemMd.MLO_nameKey = nameKey
        end
        parentMd["MLO_module_" .. moduleKey] = item:getID()
    end)
    if not ok then return false, M.message("IGUI_MLO_Error_LinkModule") end
    M.markItemDirty(tx, item)
    M.markItemDirty(tx, parent)
    return true, nil
end

local function unlinkModuleStateTx(tx, parent, item, moduleKey)
    local md = item:getModData()
    local parentMd = parent and parent:getModData() or nil
    local linkedParent, linkedKey, linkedVersion = md.MLO_parentId, md.MLO_moduleKey, md.MLO_version
    local originalName = md.MLO_originalName
    local originalCustom = md.MLO_originalCustomName
    local originalFavorite = md.MLO_originalFavorite
    local originalNameKey = md.MLO_originalNameKey
    local linkedNameKey = md.MLO_nameKey
    local linkedName = M.displayName(item)
    local linkedCustom = safeCall(function() return item:isCustomName() end, false)
    local linkedFavorite = safeCall(function() return item:isFavorite() end, false)
    local linkedModule = parentMd and parentMd["MLO_module_" .. tostring(moduleKey)] or nil

    M.addUndo(tx, function()
        md.MLO_parentId, md.MLO_moduleKey, md.MLO_version = linkedParent, linkedKey, linkedVersion
        md.MLO_originalName = originalName
        md.MLO_originalCustomName = originalCustom
        md.MLO_originalFavorite = originalFavorite
        md.MLO_originalNameKey = originalNameKey
        md.MLO_nameKey = linkedNameKey
        if parentMd then parentMd["MLO_module_" .. tostring(moduleKey)] = linkedModule end
        local ok = pcall(function()
            item:setName(linkedName)
            item:setCustomName(linkedCustom)
            item:setFavorite(linkedFavorite)
        end)
        return ok and md.MLO_parentId == linkedParent
            and (not parentMd or parentMd["MLO_module_" .. tostring(moduleKey)] == linkedModule)
    end)

    md.MLO_parentId, md.MLO_moduleKey, md.MLO_version = nil, nil, nil
    md.MLO_originalName, md.MLO_originalCustomName, md.MLO_originalFavorite = nil, nil, nil
    md.MLO_originalNameKey = nil
    md.MLO_nameKey = originalNameKey
    if parentMd and tonumber(linkedModule) == tonumber(item:getID()) then
        parentMd["MLO_module_" .. tostring(moduleKey)] = nil
    end
    if originalName ~= nil then
        local restored = pcall(function()
            item:setName(originalName)
            item:setCustomName(originalCustom == true)
            item:setFavorite(originalFavorite == true)
        end)
        if not restored then return false, M.message("IGUI_MLO_Error_RestoreModuleState") end
    end
    M.markItemDirty(tx, item)
    M.markItemDirty(tx, parent)
    return true, nil
end

function M.createModuleTx(tx, player, parent, fullType, moduleKey, name, weightReduction, capacity)
    if not tx or not player then return nil, M.message("IGUI_MLO_Error_InvalidPlayer") end
    local root = player:getInventory()
    local item = safeCall(function() return root:AddItem(fullType) end, nil)
    if not item then return nil, M.message("IGUI_MLO_Error_CreateModule", M.itemArgument(fullType)) end

    M.addUndo(tx, function()
        local current = itemContainer(item)
        if current and not removeExistingItem(current, item) then return false end
        return itemContainer(item) == nil
    end)
    tx.player = tx.player or player
    tx.newItems[item] = true
    queueNetworkOp(tx, "add", root, item)

    if weightReduction and safeCall(function() return item:IsInventoryContainer() end, false) then
        local ok = pcall(function()
            item:setWeightReduction(weightReduction)
            item:getInventory():setWeightReduction(weightReduction)
        end)
        if not ok then return nil, M.message("IGUI_MLO_Error_SetWeightReduction") end
    end
    if capacity then
        local ok = pcall(function()
            item:setCapacity(capacity)
            if item:IsInventoryContainer() then item:getInventory():setCapacity(capacity) end
        end)
        if not ok then return nil, M.message("IGUI_MLO_Error_SetModuleCapacity") end
    end

    local linked, reason = M.linkModuleTx(tx, player, parent, item, moduleKey, name)
    if not linked then return nil, reason end
    return item, nil
end

function M.transferContentsTx(tx, source, target)
    if not tx or not source or not target then return false, M.message("IGUI_MLO_Error_InvalidContainer") end
    if not safeCall(function() return source:IsInventoryContainer() end, false)
        or not safeCall(function() return target:IsInventoryContainer() end, false) then
        return false, M.message("IGUI_MLO_Error_NotContainer")
    end
    local src = source:getInventory()
    local dst = target:getInventory()
    if not src or not dst then return false, M.message("IGUI_MLO_Error_ReadContainer") end

    local toMove = {}
    local items = src:getItems()
    for i = 0, items:size() - 1 do toMove[#toMove + 1] = items:get(i) end
    for _, item in ipairs(toMove) do
        if not removeExistingItem(src, item) then
            if itemContainer(item) ~= src then addExistingItem(src, item) end
            return false, M.message("IGUI_MLO_Error_RemoveContent")
        end
        if not addExistingItem(dst, item) then
            addExistingItem(src, item)
            return false, M.message("IGUI_MLO_Error_TransferContent")
        end
        M.addUndo(tx, function()
            return restoreItemContainer(item, src)
        end)
        queueNetworkOp(tx, "remove", src, item)
        queueNetworkOp(tx, "add", dst, item)
    end
    return true, nil
end

function M.moveContentsToRootTx(tx, player, source)
    if not tx or not player or not source
        or not safeCall(function() return source:IsInventoryContainer() end, false) then
        return false, M.message("IGUI_MLO_Error_InvalidContainer")
    end
    local src = source:getInventory()
    local root = player:getInventory()
    if not src or not root then return false, M.message("IGUI_MLO_Error_ReadContainer") end

    local toMove = {}
    local items = src:getItems()
    for i = 0, items:size() - 1 do toMove[#toMove + 1] = items:get(i) end
    for _, item in ipairs(toMove) do
        if not removeExistingItem(src, item) then
            if itemContainer(item) ~= src then addExistingItem(src, item) end
            return false, M.message("IGUI_MLO_Error_RemoveContent")
        end
        if not addExistingItem(root, item) then
            addExistingItem(src, item)
            return false, M.message("IGUI_MLO_Error_MoveToInventory")
        end
        M.addUndo(tx, function() return restoreItemContainer(item, src) end)
        queueNetworkOp(tx, "remove", src, item)
        queueNetworkOp(tx, "add", root, item)
    end
    return true, nil
end

function M.isContainerProxy(item)
    local fullType = M.fullType(item)
    return fullType == M.CONTAINER_PROXY_TYPE.packMedBox
        or fullType == M.CONTAINER_PROXY_TYPE.packToolbox
end

local function sourceIdentity(item)
    local md = item:getModData()
    local mounted = md.MLO_parentId ~= nil
    local name = mounted and md.MLO_originalName or nil
    local custom = mounted and md.MLO_originalCustomName or nil
    local favorite = mounted and md.MLO_originalFavorite or nil
    local staticModel = mounted and md.MLO_attachmentOriginalStaticModel or nil
    if name == nil then name = M.displayName(item) end
    if custom == nil then custom = safeCall(function() return item:isCustomName() end, false) end
    if favorite == nil then favorite = safeCall(function() return item:isFavorite() end, false) end
    if staticModel == "" then staticModel = nil end
    if not mounted then staticModel = safeCall(function() return item:getStaticModel() end, nil) end
    return name, custom == true, favorite == true, staticModel
end

function M.createContainerProxyTx(tx, player, parent, source, moduleKey)
    local proxyType = M.CONTAINER_PROXY_TYPE[moduleKey]
    if not tx or not player or not parent or not source or not proxyType then
        return nil, M.message("IGUI_MLO_Error_InvalidContainer")
    end

    local sourceType = M.fullType(source)
    local validSource = moduleKey == "packMedBox" and M.TYPE.FIRST_AID[sourceType]
        or moduleKey == "packToolbox" and M.TYPE.TOOLBOX[sourceType]
    if not validSource then return nil, M.message("IGUI_MLO_Error_Incompatible") end

    local capacity = safeCall(function() return tonumber(source:getCapacity()) end, nil)
    local weightReduction = safeCall(function() return tonumber(source:getWeightReduction()) end, nil)
    local sourceName, sourceCustom, sourceFavorite, sourceStaticModel = sourceIdentity(source)
    local proxy, createReason = M.createModuleTx(
        tx, player, parent, proxyType, moduleKey, M.MODULE_NAME_KEY[moduleKey], weightReduction, capacity
    )
    if not proxy then return nil, createReason end

    local proxyMd = proxy:getModData()
    proxyMd.MLO_sourceFullType = sourceType
    proxyMd.MLO_sourceName = sourceName
    proxyMd.MLO_sourceCustomName = sourceCustom
    proxyMd.MLO_sourceFavorite = sourceFavorite
    proxyMd.MLO_sourceCapacity = capacity
    proxyMd.MLO_sourceWeightReduction = weightReduction
    proxyMd.MLO_sourceStaticModel = sourceStaticModel or ""
    local sourceWeight = safeCall(function() return tonumber(source:getActualWeight()) end,
        safeCall(function() return tonumber(source:getWeight()) end, nil))
    if sourceWeight then
        proxyMd.MLO_sourceWeight = sourceWeight
        pcall(function() proxy:setActualWeight(sourceWeight) end)
        pcall(function() proxy:setWeight(sourceWeight) end)
    end
    M.markItemDirty(tx, proxy)

    local transferred, transferReason = M.transferContentsTx(tx, source, proxy)
    if not transferred then return nil, transferReason end
    local removed, removeReason = M.removeItemTx(tx, source)
    if not removed then return nil, removeReason end
    return proxy, nil
end

function M.restoreContainerSourceTx(tx, player, proxy)
    if not tx or not player or not M.isContainerProxy(proxy) then
        return nil, M.message("IGUI_MLO_Error_InvalidContainer")
    end
    local md = proxy:getModData()
    local sourceType = md.MLO_sourceFullType and tostring(md.MLO_sourceFullType) or nil
    if not sourceType or sourceType == "" then return nil, M.message("IGUI_MLO_Error_InvalidContainer") end

    local root = player:getInventory()
    local restored = safeCall(function() return root:AddItem(sourceType) end, nil)
    if not restored then return nil, M.message("IGUI_MLO_Error_CreateModule", M.itemArgument(sourceType)) end
    M.addUndo(tx, function()
        local current = itemContainer(restored)
        if current and not removeExistingItem(current, restored) then return false end
        return itemContainer(restored) == nil
    end)
    tx.player = tx.player or player
    tx.newItems[restored] = true
    queueNetworkOp(tx, "add", root, restored)

    local configured = pcall(function()
        if md.MLO_sourceCapacity ~= nil then restored:setCapacity(tonumber(md.MLO_sourceCapacity)) end
        if md.MLO_sourceWeightReduction ~= nil then
            local wr = tonumber(md.MLO_sourceWeightReduction)
            restored:setWeightReduction(wr)
            restored:getInventory():setWeightReduction(wr)
        end
        if md.MLO_sourceName ~= nil then restored:setName(tostring(md.MLO_sourceName)) end
        restored:setCustomName(md.MLO_sourceCustomName == true)
        restored:setFavorite(md.MLO_sourceFavorite == true)
        local staticModel = md.MLO_sourceStaticModel
        if staticModel == "" then staticModel = nil end
        if staticModel == nil then
            restored:getModData().staticModel = nil
        else
            restored:setStaticModel(tostring(staticModel))
        end
    end)
    if not configured then return nil, M.message("IGUI_MLO_Error_RestoreModuleState") end

    local transferred, transferReason = M.transferContentsTx(tx, proxy, restored)
    if not transferred then return nil, transferReason end
    local removed, removeReason = M.removeItemTx(tx, proxy)
    if not removed then return nil, removeReason end
    return restored, nil
end

function M.setSlotItemTx(tx, parent, slotId, item)
    if not tx or not parent then return false, M.message("IGUI_MLO_Error_InvalidEquipment") end
    local md = parent:getModData()
    local key = "MLO_slot_" .. slotId
    local previous = md[key]
    M.addUndo(tx, function() md[key] = previous return md[key] == previous end)
    md[key] = item and item:getID() or nil
    M.markItemDirty(tx, parent)
    return true, nil
end

-- Persistent ownership is deliberately separate from vanilla Hotbar fields.
-- The parent relation survives taking the equipment off; the client projects
-- it into the original Hotbar only while that exact parent is worn.
function M.mountField(slotId)
    return "MLO_mount_" .. tostring(slotId or "")
end

function M.getPersistentMountId(parent, slotId)
    if not parent or not M.HOTBAR_TEMPLATE[slotId] then return nil end
    return tonumber(parent:getModData()[M.mountField(slotId)])
end

function M.findPersistentMountParent(player, item, snapshot)
    if not player or not item then return nil, nil end
    local id = safeCall(function() return tonumber(item:getID()) end, nil)
    if not id then return nil, nil end
    if snapshot and snapshot.mountByItemId then
        local mounted = snapshot.mountByItemId[id]
        return mounted and mounted.parent or nil, mounted and mounted.slotId or nil
    end
    local parents = snapshot and snapshot.parents or M.allRecursiveItems(player)
    for _, parent in ipairs(parents) do
        if M.isParent(parent) then
            for _, slotId in ipairs(M.SLOT_ORDER) do
                if M.getPersistentMountId(parent, slotId) == id then
                    return parent, slotId
                end
            end
        end
    end
    return nil, nil
end

function M.validatePersistentMount(player, parent, slotId, item)
    if not player or not parent or not item then
        return false, M.message("IGUI_MLO_Error_AttachmentMissing")
    end
    if M.findById(player, parent:getID()) ~= parent or M.findById(player, item:getID()) ~= item then
        return false, M.message("IGUI_MLO_Error_AttachmentMissing")
    end
    if not M.parentEquipped(player, parent) then
        return false, M.message("IGUI_MLO_Error_InvalidEquipment")
    end
    -- Vanilla ISAttachItemHotbar validates the exact item in the character's
    -- root inventory.  Nested/floor/loot items must first complete the vanilla
    -- ISInventoryTransferAction; the relationship layer never moves them.
    if itemContainer(item) ~= player:getInventory() then
        return false, M.message("IGUI_MLO_Error_ItemNotInInventory")
    end
    if not M.isParent(parent) or not M.HOTBAR_TEMPLATE[slotId]
        or not M.slotBelongsToGroup(slotId, M.groupOf(parent)) then
        return false, M.message("IGUI_MLO_Error_WrongSlotGroup")
    end
    if not M.slotEnabled(parent, slotId) then
        return false, M.message("IGUI_MLO_Error_SlotNotEnabled")
    end
    if M.isFixedPouchItem(item) or not M.isCompatible(slotId, item) then
        return false, M.message("IGUI_MLO_Error_Incompatible")
    end
    local existing = M.getPersistentMountId(parent, slotId)
    if existing and existing ~= tonumber(item:getID()) then
        return false, M.message("IGUI_MLO_Error_SlotOccupied")
    end
    local oldParent, oldSlot = M.findPersistentMountParent(player, item)
    if oldParent and (oldParent ~= parent or oldSlot ~= slotId) then
        return false, M.message("IGUI_MLO_Error_AlreadyMounted",
            M.textArgument(M.SLOT_LABEL_KEY[oldSlot] or "IGUI_MLO_Slot_Unknown"))
    end
    return true, nil
end

local function writePersistentMountTx(tx, parent, slotId, item)
    local parentMd = parent:getModData()
    local field = M.mountField(slotId)
    local previousId = parentMd[field]
    local itemMd = item and item:getModData() or nil
    local previousParentId = itemMd and itemMd.MLO_mountParentId or nil
    local previousSlotId = itemMd and itemMd.MLO_mountSlotId or nil
    local previousSchema = itemMd and itemMd.MLO_mountSchema or nil

    M.addUndo(tx, function()
        parentMd[field] = previousId
        if itemMd then
            itemMd.MLO_mountParentId = previousParentId
            itemMd.MLO_mountSlotId = previousSlotId
            itemMd.MLO_mountSchema = previousSchema
        end
        return parentMd[field] == previousId
    end)

    parentMd[field] = item and item:getID() or nil
    if itemMd then
        itemMd.MLO_mountParentId = parent:getID()
        itemMd.MLO_mountSlotId = slotId
        itemMd.MLO_mountSchema = 1
    end
    M.markItemDirty(tx, parent)
    M.markItemDirty(tx, item)
    return true, nil
end

local function clearChildMountTx(tx, item, parent, slotId)
    if not item then return true, nil end
    local md = item:getModData()
    local oldParentId, oldSlotId, oldSchema = md.MLO_mountParentId, md.MLO_mountSlotId, md.MLO_mountSchema
    M.addUndo(tx, function()
        md.MLO_mountParentId, md.MLO_mountSlotId, md.MLO_mountSchema = oldParentId, oldSlotId, oldSchema
        return md.MLO_mountParentId == oldParentId and md.MLO_mountSlotId == oldSlotId
    end)
    if (not parent or tonumber(md.MLO_mountParentId) == tonumber(parent:getID()))
        and (not slotId or tostring(md.MLO_mountSlotId or "") == tostring(slotId)) then
        md.MLO_mountParentId, md.MLO_mountSlotId, md.MLO_mountSchema = nil, nil, nil
        M.markItemDirty(tx, item)
    end
    return true, nil
end

function M.setPersistentMountTx(tx, player, parent, slotId, item)
    if not tx then return false, M.message("IGUI_MLO_Error_Generic") end
    local valid, reason = M.validatePersistentMount(player, parent, slotId, item)
    if not valid then return false, reason end
    if not M.ensureDetachableItemState(item, player) then
        return false, M.message("IGUI_MLO_Error_SyncAttachments")
    end
    local linked,linkReason=writePersistentMountTx(tx,parent,slotId,item)
    if not linked then return false,linkReason end
    local transported,_,transportReason=M.ensureMountedContainerTransport(player,item,tx)
    if not transported then
        M.logOnce("container-transport:mount:"..itemId(item),
            "mounted container transport rejected: "..tostring(transportReason))
        return false,M.message("IGUI_MLO_Error_InvalidContainer")
    end
    return true,nil
end

function M.clearPersistentMountTx(tx, player, parent, slotId, expectedItem, expectedItemId, clearChild)
    if not tx or not player or not parent or not M.HOTBAR_TEMPLATE[slotId] then
        return false, M.message("IGUI_MLO_Error_InvalidEquipment")
    end
    local linkedId = M.getPersistentMountId(parent, slotId)
    if not linkedId then return false, M.message("IGUI_MLO_Error_EmptySlot") end
    local expectedId = expectedItem and tonumber(expectedItem:getID()) or tonumber(expectedItemId)
    if expectedId and linkedId ~= expectedId then
        return false, M.message("IGUI_MLO_Error_SlotMismatch")
    end
    local linkedItem = nil
    if clearChild~=false then linkedItem = expectedItem or M.findById(player, linkedId) end
    local parentMd = parent:getModData()
    local field = M.mountField(slotId)
    local previous = parentMd[field]
    M.addUndo(tx, function() parentMd[field] = previous return parentMd[field] == previous end)
    parentMd[field] = nil
    M.markItemDirty(tx, parent)
    return clearChildMountTx(tx, linkedItem, parent, slotId)
end

function M.mountItem(player, parent, slotId, item)
    if not M.reconcileComponents(player) then return false, M.message("IGUI_MLO_Error_SyncState") end
    local tx = M.newTransaction(player)
    local linked, reason = M.setPersistentMountTx(tx, player, parent, slotId, item)
    if not linked then return M.abortTransaction(tx, reason) end
    return M.commitTransaction(tx)
end

function M.unmountItem(player, parent, slotId, expectedItem)
    local tx = M.newTransaction(player)
    local cleared, reason = M.clearPersistentMountTx(tx, player, parent, slotId, expectedItem)
    if not cleared then return M.abortTransaction(tx, reason) end
    return M.commitTransaction(tx)
end

-- Interactive detach keeps the child in root inventory, while drop/place may
-- remove it before the server command arrives. Validate the exact child id in
-- both cases; clear the redundant child fields only when the same item is
-- still present in the player's root inventory.
function M.unmountItemById(player, parent, slotId, expectedItemId)
    if not player or not parent or not M.isParent(parent)
        or not M.slotBelongsToGroup(slotId, M.groupOf(parent)) then
        return false, M.message("IGUI_MLO_Error_InvalidEquipment")
    end
    local linkedId=M.getPersistentMountId(parent,slotId)
    if not linkedId then return true, nil end
    local expectedId=tonumber(expectedItemId)
    if not expectedId or linkedId~=expectedId then
        return false, M.message("IGUI_MLO_Error_SlotMismatch")
    end
    local linkedItem=M.findById(player,linkedId)
    if linkedItem and linkedItem:getContainer()~=player:getInventory() then linkedItem=nil end
    local tx = M.newTransaction(player)
    local cleared, reason = M.clearPersistentMountTx(tx, player, parent, slotId,
        linkedItem, expectedItemId, linkedItem~=nil)
    if not cleared then return M.abortTransaction(tx, reason) end
    return M.commitTransaction(tx)
end

function M.unmountParent(player, parent)
    if not player or not parent or not M.isParent(parent) then
        return false, 0, M.message("IGUI_MLO_Error_InvalidEquipment")
    end
    local tx = M.newTransaction(player)
    local clearedCount = 0
    for _, slotId in ipairs(M.SLOT_ORDER) do
        local linkedId = M.getPersistentMountId(parent, slotId)
        if linkedId then
            local linkedItem = M.findById(player, linkedId)
            local cleared, reason = M.clearPersistentMountTx(
                tx, player, parent, slotId, linkedItem, linkedId, linkedItem ~= nil)
            if not cleared then return M.abortTransaction(tx, reason), clearedCount, reason end
            clearedCount = clearedCount + 1
        end
    end
    if clearedCount == 0 then return true, 0, nil end
    local committed, reason = M.commitTransaction(tx)
    if not committed then return false, clearedCount, reason end
    return true, clearedCount, nil
end

function M.availableMountTargets(player, item, includeEquipped)
    local out = {}
    if not player or not item or M.findPersistentMountParent(player, item) then return out end
    for _, parent in ipairs(M.allRecursiveItems(player)) do
        if M.isParent(parent) and M.parentEquipped(player, parent) then
            for _, slotId in ipairs(M.SLOT_ORDER) do
                if M.slotBelongsToGroup(slotId, M.groupOf(parent)) and M.slotEnabled(parent, slotId)
                    and not M.getPersistentMountId(parent, slotId) and M.isCompatible(slotId, item) then
                    out[#out + 1] = { parent = parent, slotId = slotId }
                end
            end
        end
    end
    return out
end

-- The parent id is authoritative after save/load.  This repair only restores
-- the redundant child index or removes a relation whose item left the root
-- inventory through a normal vanilla transfer/drop.
function M.reconcilePersistentMounts(player)
    if not player then return false, {}, M.message("IGUI_MLO_Error_InvalidPlayer") end
    local tx = M.newTransaction(player)
    local changedParents = {}
    local root = player:getInventory()
    local seen = {}
    for _, parent in ipairs(M.allRecursiveItems(player)) do
        if M.isParent(parent) then
            for _, slotId in ipairs(M.SLOT_ORDER) do
                local linkedId = M.getPersistentMountId(parent, slotId)
                if linkedId then
                    local item = M.findById(player, linkedId)
                    local valid = M.parentEquipped(player, parent)
                        and item and itemContainer(item) == root and not seen[linkedId]
                        and M.slotBelongsToGroup(slotId, M.groupOf(parent))
                        and M.slotEnabled(parent, slotId) and M.isCompatible(slotId, item)
                        and not M.isFixedPouchItem(item)
                    if valid then
                        seen[linkedId] = true
                        local md = item:getModData()
                        if tonumber(md.MLO_mountParentId) ~= tonumber(parent:getID())
                            or tostring(md.MLO_mountSlotId or "") ~= slotId
                            or tonumber(md.MLO_mountSchema) ~= 1 then
                            writePersistentMountTx(tx, parent, slotId, item)
                            changedParents[parent] = true
                        end
                        local transported,transportChanged,transportReason=
                            M.ensureMountedContainerTransport(player,item,tx)
                        if not transported then
                            return M.abortTransaction(tx,M.message("IGUI_MLO_Error_InvalidContainer")),changedParents,transportReason
                        end
                        if transportChanged then changedParents[parent]=true end
                    else
                        local cleared, reason = M.clearPersistentMountTx(tx, player, parent, slotId, item)
                        if not cleared then return M.abortTransaction(tx, reason), changedParents, reason end
                        changedParents[parent] = true
                    end
                end
            end
        end
    end
    for _, item in ipairs(M.allRecursiveItems(player)) do
        local md = item:getModData()
        if md and (md.MLO_mountParentId ~= nil or md.MLO_mountSlotId ~= nil) then
            local parent, slotId = M.findPersistentMountParent(player, item)
            if not parent or tonumber(md.MLO_mountParentId) ~= tonumber(parent:getID())
                or tostring(md.MLO_mountSlotId or "") ~= tostring(slotId or "") then
                clearChildMountTx(tx, item, nil, nil)
            end
        end
    end
    local committed, reason = M.commitTransaction(tx)
    if not committed then return false, changedParents, reason end
    return true, changedParents, nil
end

-- dev.9 had only the live vanilla Hotbar fields.  Adopt that exact original
-- item once so an already-mounted test-save attachment gains the new durable
-- parent relation without conversion or content movement.
function M.adoptLegacyHotbarMounts(player)
    if not player then return false, {}, M.message("IGUI_MLO_Error_InvalidPlayer") end
    local tx = M.newTransaction(player)
    local changedParents = {}
    for _, item in ipairs(M.allRecursiveItems(player)) do
        local slotId = safeCall(function() return item:getAttachedSlotType() end, nil)
        if slotId and M.HOTBAR_TEMPLATE[slotId] and not M.findPersistentMountParent(player, item) then
            local parent = M.parentForSlot(player, slotId, true)
            if parent and not M.getPersistentMountId(parent, slotId) then
                local linked, reason = M.setPersistentMountTx(tx, player, parent, slotId, item)
                if not linked then return M.abortTransaction(tx, reason), changedParents, reason end
                changedParents[parent] = true
            end
        end
    end
    local committed, reason = M.commitTransaction(tx)
    if not committed then return false, changedParents, reason end
    return true, changedParents, nil
end

function M.collectMaterialPlan(player, materials)
    local plan = {}
    local types = {}
    for ft in pairs(materials or {}) do types[#types + 1] = ft end
    table.sort(types)

    for _, ft in ipairs(types) do
        local remaining = tonumber(materials[ft]) or 0
        for _, item in ipairs(M.allRecursiveItems(player)) do
            if remaining > 0 and M.fullType(item) == ft and not M.isModuleItem(item) then
                local units = math.min(M.itemUses(item), remaining)
                plan[#plan + 1] = { item = item, units = units, fullType = ft }
                remaining = remaining - units
            end
        end
        if remaining > 0 then return nil, ft end
    end
    return plan, nil
end

local function snapshotMaterialItem(tx, item)
    if tx.materialSnapshots[item] then return end
    tx.materialSnapshots[item] = true
    local original = itemContainer(item)
    local drainable = safeCall(function() return item:IsDrainable() end, false)
    local currentUses = drainable and safeCall(function() return item:getCurrentUsesFloat() end, nil) or nil

    M.addUndo(tx, function()
        if original and not restoreItemContainer(item, original) then return false end
        local ok = true
        if currentUses ~= nil then ok = pcall(function() item:setCurrentUsesFloat(currentUses) end) and ok end
        return ok
    end)
end

function M.consumeMaterialPlan(tx, plan)
    if not tx or not plan then return false, M.message("IGUI_MLO_Error_MaterialPlan") end
    for _, entry in ipairs(plan) do
        local item = entry.item
        snapshotMaterialItem(tx, item)
        for _ = 1, entry.units do
            local beforeContainer = itemContainer(item)
            local drainable = safeCall(function() return item:IsDrainable() end, false)
            local beforeUses = drainable and safeCall(function() return item:getCurrentUsesFloat() end, nil) or nil
            local ok = pcall(function() item:Use() end)
            if not ok then return false, entry.fullType end

            local afterContainer = itemContainer(item)
            local afterUses = drainable and afterContainer
                and safeCall(function() return item:getCurrentUsesFloat() end, nil) or nil
            local changed = afterContainer ~= beforeContainer
            if beforeUses ~= nil and afterUses ~= nil and afterUses < beforeUses then changed = true end
            if not changed then return false, entry.fullType end
            if beforeContainer and afterContainer ~= beforeContainer then
                queueNetworkOp(tx, "remove", beforeContainer, item)
            elseif afterContainer then
                M.markItemDirty(tx, item)
            end
        end
    end
    return true, nil
end

function M.sourceWeightReduction(source, fallback)
    if not source then return fallback end
    local wr = safeCall(function() return source:getWeightReduction() end, nil)
    if wr == nil then return fallback end
    return tonumber(wr) or fallback
end

function M.renameParent(parent)
    local group = M.groupOf(parent)
    local md = parent:getModData()
    md.MLO_version = M.VERSION
    md.MLO_group = group
    local nameKey = group and M.PARENT_NAME_KEY[group] or nil
    if not nameKey then return false end
    for _, key in ipairs(M.UPGRADE_ORDER[group] or {}) do
        if md["MLO_up_" .. key] == true then
            return M.setDynamicName(parent, nameKey)
        end
    end
    return true
end

function M.installFlag(parent, key)
    parent:getModData()["MLO_up_"..key] = true
    M.renameParent(parent)
end

M.SLOT_UPGRADE_KEY = {
    MLO_Belt_HolsterL="belt_doubleholster", MLO_Belt_HolsterR="belt_doubleholster",
    MLO_Belt_ToolL="belt_toolL", MLO_Belt_ToolR="belt_toolR",
    MLO_Rig_PistolL="rig_shoulderL", MLO_Rig_PistolR="rig_shoulderR",
    MLO_Pack_SportBottle="pack_sportBottle",
    MLO_Pack_MedBox="pack_medBox", MLO_Pack_Toolbox="pack_toolbox",
    MLO_Pack_WeldingMask="pack_weldingMask",
    MLO_Pack_Lantern="pack_lantern", MLO_Pack_CDPlayer="pack_cdplayer",
    MLO_Pack_PlushToy="pack_plushToy",
}

for slotId, mount in pairs(M.ARMOR_MOUNTS) do M.SLOT_UPGRADE_KEY[slotId] = mount.key end

function M.slotEnabled(parent, slotId)
    if not parent or not M.componentEnabled(parent) then return false end
    local key = M.SLOT_UPGRADE_KEY[slotId]
    return key and M.slotBelongsToGroup(slotId, M.groupOf(parent))
        and M.isInstalled(parent, key) or false
end

function M.slotBelongsToGroup(slotId, group)
    if string.find(slotId, "MLO_Belt_", 1, true) == 1 then return group=="belt" end
    if string.find(slotId, "MLO_Rig_", 1, true) == 1 then return group=="rig" end
    if M.ARMOR_MOUNTS[slotId] then return group==M.ARMOR_MOUNTS[slotId].group end
    if string.find(slotId, "MLO_Pack_", 1, true) == 1 then return group=="pack" end
    return false
end

function M.isPistol(item)
    if not item or not safeCall(function() return item:IsWeapon() end, false) then return false end
    local ammo = safeCall(function() return item:getAmmoType() end, nil)
    if not ammo or tostring(ammo)=="" then return false end
    if safeCall(function() return item:isTwoHandWeapon() end, false) then return false end
    return true
end

function M.isKnife(item)
    if not item or not safeCall(function() return item:IsWeapon() end, false) then return false end
    local ft = string.lower(M.fullType(item))
    if string.find(ft, "machete", 1, true) or string.find(ft, "katana", 1, true)
        or string.find(ft, "sword", 1, true) then return false end
    local weight = safeCall(function() return tonumber(item:getWeight()) end, 99) or 99
    local subCategory = string.lower(safeCall(function() return tostring(item:getSubCategory()) end, ""))
    if subCategory == "stab" and weight <= 1.5 then return true end
    if ItemTag and ItemTag.SHARP_KNIFE
        and safeCall(function() return item:hasTag(ItemTag.SHARP_KNIFE) end, false)
        and weight <= 1.5 then return true end
    local keys = {"knife","dagger","shiv"}
    for _, k in ipairs(keys) do
        if string.find(ft,k,1,true) and weight <= 1.5 then return true end
    end
    return false
end

function M.isRifle(item)
    if not item or not safeCall(function() return item:IsWeapon() end, false) then return false end
    local ammo = safeCall(function() return item:getAmmoType() end, nil)
    if not ammo or tostring(ammo)=="" then return false end
    local attachment = safeCall(function() return item:getAttachmentType() end, nil)
    return attachment=="Rifle" or attachment=="BigWeapon"
        or safeCall(function() return item:isTwoHandWeapon() end, false)
end

function M.isCompatible(slotId, item)
    if slotId=="MLO_Belt_HolsterL" or slotId=="MLO_Belt_HolsterR" then
        return M.isPistol(item) or M.isRifle(item)
    end
    if slotId=="MLO_Rig_PistolL" or slotId=="MLO_Rig_PistolR" then
        return M.isPistol(item)
    end
    local armorMount = M.ARMOR_MOUNTS[slotId]
    if armorMount then
        if armorMount.kind == "pistol" then return M.isPistol(item) end
        return M.isKnife(item)
    end
    if slotId=="MLO_Belt_ToolL" or slotId=="MLO_Belt_ToolR" then
        -- Same family map as the native Hotbar definition, shared by both
        -- client and server. Do not narrow vanilla families by item name.
        -- The existing phone exception must not admit every MLO radio/device.
        if M.TYPE.PHONE[M.fullType(item)] == true then return true end
        local attachment = safeCall(function() return item:getAttachmentType() end, nil)
        return attachment ~= nil and attachment ~= "MLOPackCDPlayer"
            and M.SLOT_ALLOWED_ATTACHMENT_TYPES[slotId][attachment] ~= nil
    end
    if slotId=="MLO_Pack_SportBottle" then return M.TYPE.CANTEEN[M.fullType(item)]==true end
    if slotId=="MLO_Pack_MedBox" then return M.TYPE.FIRST_AID[M.fullType(item)]==true end
    if slotId=="MLO_Pack_Toolbox" then return M.TYPE.TOOLBOX[M.fullType(item)]==true end
    if slotId=="MLO_Pack_WeldingMask" then return M.TYPE.MASK[M.fullType(item)]==true end
    if slotId=="MLO_Pack_Lantern" then return M.TYPE.LANTERN[M.fullType(item)]==true end
    if slotId=="MLO_Pack_CDPlayer" then return M.TYPE.DEVICE[M.fullType(item)]==true end
    if slotId=="MLO_Pack_PlushToy" then return M.TYPE.PLUSH[M.fullType(item)]==true end
    return false
end

function M.parentEquipped(player, parent)
    if not player or not parent then return false end
    return safeCall(function() return player:isEquipped(parent) end, false)
end

function M.parentForSlot(player, slotId, equippedOnly, snapshot, enabledByParent)
    if not player or not M.HOTBAR_TEMPLATE[slotId] then return nil end
    for _, parent in ipairs(snapshot and snapshot.parents or M.allRecursiveItems(player)) do
        local hints=enabledByParent and enabledByParent[tonumber(parent:getID())] or nil
        if M.isParent(parent) and M.componentEnabled(parent) and M.slotBelongsToGroup(slotId, M.groupOf(parent))
            and (M.slotEnabled(parent, slotId) or (hints and hints[slotId]==true))
            and (not equippedOnly or M.parentEquipped(player, parent)) then
            return parent
        end
    end
    return nil
end

function M.activeModuleContainer(player, item, snapshot)
    if not player or not item then return false end
    if not safeCall(function() return item:IsInventoryContainer() end, false) then return false end
    local parent, slotId = M.mountedSlotForItem(player, item, snapshot)
    if not parent or (slotId ~= "MLO_Pack_MedBox" and slotId ~= "MLO_Pack_Toolbox") then
        return false
    end
    -- The durable parent relation and the original root-inventory item are
    -- authoritative for sidebar activity. AttachedItem is only a transient
    -- client projection and may be absent during login replication.
    return M.parentEquipped(player, parent)
        and itemContainer(item) == player:getInventory()
        and M.getPersistentMountId(parent, slotId) == tonumber(item:getID())
end

function M.activeFixedModuleContainer(player, item)
    if not player or not item or not M.isModuleItem(item) then return false end
    if not safeCall(function() return item:IsInventoryContainer() end, false) then return false end
    local itemId = safeCall(function() return tonumber(item:getID()) end, nil)
    if not itemId then return false end

    -- The equipped parent is authoritative. Build 42 may replicate/save a
    -- newly-added InventoryContainer without the child's ModData even though
    -- the parent's module ID is intact. Resolve from that durable parent link
    -- instead of requiring duplicated child metadata.
    for _, parent in ipairs(M.allRecursiveItems(player)) do
        if M.isParent(parent) and M.parentEquipped(player, parent) then
            local parentMd = parent:getModData()
            for moduleKey in pairs(M.FIXED_POUCH) do
                if tonumber(parentMd["MLO_module_" .. moduleKey]) == itemId then
                    return true
                end
            end
        end
    end
    return false
end

-- Parent-side module ID and the declared pouch FullType are authoritative.
-- Child ModData is a replicated convenience index: absent fields are valid,
-- but fields that arrive with a conflicting value must never claim the pouch.
function M.fixedModuleContainerForParent(player, parent, moduleKey, snapshot)
    if not player or not parent or not M.isParent(parent) then return nil end
    local fixed = M.FIXED_POUCH[moduleKey]
    local moduleId = fixed and tonumber(parent:getModData()["MLO_module_" .. moduleKey]) or nil
    if not moduleId then return nil end
    local item = M.findById(player, moduleId, snapshot)
    if not item or M.fullType(item) ~= fixed.fullType
        or not safeCall(function() return item:IsInventoryContainer() end, false) then
        return nil
    end
    local childMd, parentId = item:getModData(), tonumber(parent:getID())
    if childMd.MLO_parentId ~= nil and tonumber(childMd.MLO_parentId) ~= parentId then return nil end
    if childMd.MLO_moduleKey ~= nil and childMd.MLO_moduleKey ~= moduleKey then return nil end
    return item
end

function M.fixedModuleContainersForParent(player, parent, snapshot)
    local out = {}
    local seen = {}
    if not player or not parent or not M.isParent(parent) then return out end
    for moduleKey in pairs(M.FIXED_POUCH) do
        local item = M.fixedModuleContainerForParent(player, parent, moduleKey, snapshot)
        local moduleId = item and tonumber(item:getID()) or nil
        if moduleId and not seen[moduleId] then
            out[#out + 1] = item
            seen[moduleId] = true
        end
    end
    return out
end

function M.activeFixedModuleContainers(player, snapshot)
    local out = {}
    local owners = {}
    local seen = {}
    if not player then return out, owners end
    -- Resolve from the equipped parent's durable ID fields. The child is a
    -- hidden implementation item and may have no replicated MLO ModData.
    local parents = snapshot and snapshot.parents or M.allRecursiveItems(player)
    for _, parent in ipairs(parents) do
        if M.isParent(parent) and M.parentEquipped(player, parent) then
            for _, item in ipairs(M.fixedModuleContainersForParent(player, parent, snapshot)) do
                local moduleId = tonumber(item:getID())
                if moduleId and not seen[moduleId] then
                    out[#out + 1] = item
                    owners[item] = parent
                    seen[moduleId] = true
                end
            end
        end
    end
    return out, owners
end

function M.mountedSlotForItem(player, item, snapshot)
    return M.findPersistentMountParent(player, item, snapshot)
end

function M.isMounted(player, item)
    return M.mountedSlotForItem(player, item) ~= nil
end

function M.registerAttachedLocations()
    local group = AttachedLocations.getGroup("Human")
    if not group then
        M.logOnce("attached-location:group", "attached-location registration failed: Human group is unavailable")
        return false
    end
    local registered = true
    for slotId, vanillaLocation in pairs(M.ATTACHED) do
        local customAttachmentName = M.CUSTOM_ATTACHED_NAME[slotId]
        local vanilla = not customAttachmentName and group:getLocation(vanillaLocation) or nil
        local attachmentName = customAttachmentName or (vanilla and vanilla:getAttachmentName() or nil)
        if attachmentName then
            local ok = pcall(function() group:getOrCreateLocation(slotId):setAttachmentName(attachmentName) end)
            if not ok then
                M.logOnce("attached-location:" .. slotId, "attached-location registration failed for " .. slotId)
                registered = false
            end
        else
            M.logOnce("attached-location:vanilla:" .. slotId,
                "attached-location registration failed for " .. slotId .. ": missing vanilla location " .. vanillaLocation)
            registered = false
        end
    end
    local profileLocations = {}
    local function registerProfileLocation(spec)
        if not spec or not spec.location or not spec.attachment then
            registered = false
            return
        end
        if profileLocations[spec.location] then
            if profileLocations[spec.location] ~= spec.attachment then registered = false end
            return
        end
        profileLocations[spec.location] = spec.attachment
        local ok = pcall(function()
            group:getOrCreateLocation(spec.location):setAttachmentName(spec.attachment)
        end)
        if not ok then
            M.logOnce("attached-location-profile:" .. spec.location,
                "attached-location registration failed for " .. spec.location)
            registered = false
        end
    end
    for _, profile in pairs(M.ATTACHED_LOCATION_PROFILE) do
        registerProfileLocation(profile.default)
        for _, spec in pairs(profile.byFullType or {}) do registerProfileLocation(spec) end
    end
    -- Isolated retired location: only clearRetiredBlowTorchState consumes it.
    for slotId, vanillaLocation in pairs(M.RETIRED_ATTACHED) do
        local vanilla = group:getLocation(vanillaLocation)
        local attachmentName = vanilla and vanilla:getAttachmentName() or nil
        if attachmentName then
            local ok = pcall(function() group:getOrCreateLocation(slotId):setAttachmentName(attachmentName) end)
            if not ok then registered = false end
        else
            registered = false
        end
    end
    return registered
end

local function expectedAttachmentIds(parent, current, enabledSlotOverrides)
    local expected = {}
    local present = {}
    for i = 0, current:size() - 1 do
        local value = current:get(i)
        -- Retired MLO slots (for example the old BlowTorch slot) are not
        -- present in M.ATTACHED any more. Strip the namespace while keeping
        -- every Base-provided attachment id and its original order verbatim.
        if type(value) ~= "string" or string.sub(value,1,4) ~= "MLO_" then
            expected[#expected + 1] = value
            present[value] = true
        end
    end
    local group = M.groupOf(parent)
    for _, slotId in ipairs(M.SLOT_ORDER) do
        if M.componentEnabled(parent) and M.HOTBAR_TEMPLATE[slotId] and M.slotBelongsToGroup(slotId, group)
            and (M.slotEnabled(parent, slotId) or (enabledSlotOverrides and enabledSlotOverrides[slotId]))
            and not present[slotId] then
            expected[#expected + 1] = slotId
            present[slotId] = true
        end
    end
    return expected
end

local function attachmentIdsMatch(current, expected)
    if current:size() ~= #expected then return false end
    for index = 1, #expected do
        if current:get(index - 1) ~= expected[index] then return false end
    end
    return true
end

local function attachmentListFromIds(expected)
    local updated = ArrayList.new()
    for _, value in ipairs(expected) do updated:add(value) end
    return updated
end

function M.ensureAttachmentsProvided(parent, enabledSlotOverrides)
    if not parent then return false, false end
    local current = safeCall(function() return parent:getAttachmentsProvided() end, nil)
    local hadCurrent = current ~= nil
    if not current then
        current = safeCall(function() return ArrayList.new() end, nil)
        if not current then
            M.logOnce("attachmentsProvided:" .. itemId(parent), "attachmentsProvided unavailable for parent " .. itemId(parent))
            return false, false
        end
    end

    local expected = safeCall(function() return expectedAttachmentIds(parent, current, enabledSlotOverrides) end, nil)
    if not expected then return false, false end
    if hadCurrent and attachmentIdsMatch(current, expected) then return true, false end

    local updated = safeCall(function() return attachmentListFromIds(expected) end, nil)
    if not updated then return false, false end
    local ok = pcall(function() parent:setAttachmentsProvided(updated) end)
    if not ok then
        M.logOnce("attachmentsProvided:set:" .. itemId(parent), "attachmentsProvided write failed for parent " .. itemId(parent))
        return false, false
    end
    return true, true
end

local function ensureAttachmentsProvidedTx(tx, parent)
    local read, previous = pcall(function() return parent:getAttachmentsProvided() end)
    if not read then return false, M.message("IGUI_MLO_Error_ReadAttachments") end
    -- Stock clothing with no AttachmentsProvided starts at nil, not an empty
    -- Java list. Preserve that original value for rollback, but build the
    -- first upgrade's projection from an empty list just like the stock adapter.
    local current = previous or safeCall(function() return ArrayList.new() end, nil)
    if not current then return false, M.message("IGUI_MLO_Error_BuildAttachments") end
    local expected = safeCall(function() return expectedAttachmentIds(parent, current) end, nil)
    if not expected then return false, M.message("IGUI_MLO_Error_BuildAttachments") end
    if previous and attachmentIdsMatch(previous, expected) then return true, nil end
    local updated = safeCall(function() return attachmentListFromIds(expected) end, nil)
    if not updated then return false, M.message("IGUI_MLO_Error_BuildAttachments") end
    M.addUndo(tx, function()
        local restored = pcall(function() parent:setAttachmentsProvided(previous) end)
        return restored and safeCall(function() return parent:getAttachmentsProvided() end, nil) == previous
    end)
    local wrote = pcall(function() parent:setAttachmentsProvided(updated) end)
    if not wrote or safeCall(function() return parent:getAttachmentsProvided() end, nil) ~= updated then
        M.logOnce("attachmentsProvided:tx:" .. itemId(parent), "attachmentsProvided transactional write failed for parent " .. itemId(parent))
        return false, M.message("IGUI_MLO_Error_SyncAttachments")
    end
    M.markItemDirty(tx, parent)
    return true, nil
end

local function setEquipParentTx(tx, item, expected)
    local previous = safeCall(function() return item:getEquipParent() end, nil)
    M.addUndo(tx, function()
        local restored = pcall(function() item:setEquipParent(previous) end)
        return restored and safeCall(function() return item:getEquipParent() end, nil) == previous
    end)
    local ok = pcall(function() item:setEquipParent(expected) end)
    if not ok or safeCall(function() return item:getEquipParent() end, nil) ~= expected then
        M.logOnce("EquipParent:" .. itemId(item), "EquipParent write failed for item " .. itemId(item))
        return false, M.message("IGUI_MLO_Error_SyncEquipParent")
    end
    M.markItemDirty(tx, item)
    return true, nil
end

local function setModuleWornTx(tx, player, item, moduleKey, worn)
    local location = M.MODULE_BODY_LOCATION[moduleKey]
    if not location then
        if safeCall(function() return item:getEquipParent() end, nil) ~= nil then
            return setEquipParentTx(tx, item, nil)
        end
        return true, nil
    end

    -- Build 42's clothing packet assumes every worn item has ItemVisual. Hidden
    -- InventoryContainer modules do not, so treating them as clothing causes a
    -- SyncClothing null dereference. Fixed pouches are activated by their
    -- authoritative parent link and the inventory-sidebar extension instead.
    -- This path now exists only to clean dev.5 worn-module state transactionally.
    local previous = safeCall(function() return player:getWornItem(location) end, nil)
    if previous ~= item then return true, nil end
    M.addUndo(tx, function()
        local restored = pcall(function() player:setWornItem(location, item) end)
        return restored and safeCall(function() return player:getWornItem(location) end, nil) == item
    end)
    local cleared = pcall(function() player:removeWornItem(item, false) end)
    if not cleared or safeCall(function() return player:getWornItem(location) end, nil) ~= nil then
        return false, M.message("IGUI_MLO_Error_SyncEquipParent")
    end
    M.markEquipDirty(tx)
    M.markItemDirty(tx, item)
    return true, nil
end

local function attachmentModelFor(item)
    if not item then return nil end
    local fullType = safeCall(function() return item:getFullType() end, "")
    local md = safeCall(function() return item:getModData() end, nil)
    local sourceType = md and md.MLO_sourceFullType and tostring(md.MLO_sourceFullType) or nil
    return M.ATTACHED_MODEL[sourceType or fullType]
end

-- InventoryItem:setStaticModel(nil) is not a nullable-string reset in Build
-- 42. Lua selects the ModelKey overload, whose implementation dereferences the
-- null argument. The string override is stored in ModData.staticModel, so the
-- engine-correct reset is to remove that override and let getStaticModel()
-- fall back to the script item.
local function writeStaticModelOverride(item, model)
    if not item then return false end
    if model == nil or model == "" then
        local md = safeCall(function() return item:getModData() end, nil)
        if not md then return false end
        md.staticModel = nil
        return md.staticModel == nil
    end
    local value = tostring(model)
    local wrote = pcall(function() item:setStaticModel(value) end)
    return wrote and safeCall(function() return item:getStaticModel() end, nil) == value
end

function M.ensureAttachmentVisual(item, mounted)
    local model = attachmentModelFor(item)
    if not model then return true end

    local md = item:getModData()
    local applied = md.MLO_attachmentVisualApplied == true
    if mounted then
        local previous = safeCall(function() return item:getStaticModel() end, nil)
        if not writeStaticModelOverride(item, model) then
            writeStaticModelOverride(item, previous)
            return false
        end
        if not applied then
            md.MLO_attachmentOriginalStaticModel = previous or ""
            md.MLO_attachmentVisualApplied = true
        end
        return true
    end

    if not applied then return true end
    local original = md.MLO_attachmentOriginalStaticModel
    if original == "" then original = nil end
    if not writeStaticModelOverride(item, original) then return false end
    md.MLO_attachmentVisualApplied = nil
    md.MLO_attachmentOriginalStaticModel = nil
    return true
end

function M.syncDetachableItems(player, snapshot)
    if not player then return false end
    -- Own one view for this read/instance-field pass even at server call sites.
    -- Without it, every item's persistent-parent lookup walks the inventory.
    snapshot = snapshot or M.inventorySnapshot(player)
    local ok = true
    local items = snapshot and snapshot.items or M.allRecursiveItems(player)
    for _, item in ipairs(items) do
        if not M.ensureDetachableItemState(item, player) then ok = false end
        local slotType = safeCall(function() return item:getAttachedSlotType() end, nil)
        local mounted = slotType and M.HOTBAR_TEMPLATE[slotType] ~= nil or false
        if not mounted then
            -- On multiplayer login the durable parent relation arrives before
            -- vanilla rebuilds AttachedSlotType.  Apply the instance model now
            -- so ISHotbar's later non-animated projection creates the correct
            -- character model on its first pass instead of caching the item's
            -- larger script model (or no model at all).
            local parent, persistentSlot = M.mountedSlotForItem(player, item, snapshot)
            mounted = parent ~= nil
                and M.HOTBAR_TEMPLATE[persistentSlot] ~= nil
                and M.parentEquipped(player, parent)
                and safeCall(function() return item:getContainer() end, nil) == player:getInventory()
                and M.getPersistentMountId(parent, persistentSlot) == tonumber(item:getID())
                and M.isCompatible(persistentSlot, item)
        end
        if not M.ensureAttachmentVisual(item, mounted) then ok = false end
    end
    return ok
end

local function setAttachmentVisualTx(tx, item, mounted)
    local model = attachmentModelFor(item)
    if not model then return true, nil end

    local md = item:getModData()
    local previousModel = safeCall(function() return item:getStaticModel() end, nil)
    local previousApplied = md.MLO_attachmentVisualApplied
    local previousOriginal = md.MLO_attachmentOriginalStaticModel
    if not M.ensureAttachmentVisual(item, mounted) then
        M.logOnce("attachment-model:" .. itemId(item), "attachment model write failed for item " .. itemId(item))
        return false, M.message("IGUI_MLO_Error_SyncAttachmentModel")
    end
    M.addUndo(tx, function()
        local restored = writeStaticModelOverride(item, previousModel)
        md.MLO_attachmentVisualApplied = previousApplied
        md.MLO_attachmentOriginalStaticModel = previousOriginal
        return restored
    end)
    M.markItemDirty(tx, item)
    return true, nil
end

local function setAttachedItemTx(tx, player, slotId, expected, requiredPrevious)
    local previous = safeCall(function() return player:getAttachedItem(slotId) end, nil)
    if requiredPrevious and previous ~= requiredPrevious then
        return false, M.message("IGUI_MLO_Error_SlotMismatch")
    end
    if expected and previous and previous ~= expected then
        return false, M.message("IGUI_MLO_Error_SlotConflict")
    end
    M.addUndo(tx, function()
        local restored = pcall(function() player:setAttachedItem(slotId, previous) end)
        return restored and safeCall(function() return player:getAttachedItem(slotId) end, nil) == previous
    end)
    local ok = pcall(function() player:setAttachedItem(slotId, expected) end)
    if not ok or safeCall(function() return player:getAttachedItem(slotId) end, nil) ~= expected then
        M.logOnce("attached-item:" .. playerId(player) .. ":" .. slotId,
            "attached item write failed for slot " .. slotId .. " (player " .. playerId(player) .. ")")
        return false, M.message("IGUI_MLO_Error_SyncSlot")
    end
    -- Match the vanilla hotbar persistence fields.  setAttachedItem() alone only
    -- changes the live character model and is not enough for multiplayer reloads.
    local fieldItem = expected or previous
    if fieldItem then
        local oldSlot = safeCall(function() return fieldItem:getAttachedSlot() end, -1)
        local oldType = safeCall(function() return fieldItem:getAttachedSlotType() end, nil)
        local oldModel = safeCall(function() return fieldItem:getAttachedToModel() end, nil)
        M.addUndo(tx, function()
            local restored = pcall(function()
                fieldItem:setAttachedSlot(oldSlot)
                fieldItem:setAttachedSlotType(oldType)
                fieldItem:setAttachedToModel(oldModel)
            end)
            return restored
        end)
        local wrote = pcall(function()
            if expected then
                -- The owning client assigns the live hotbar index for slots
                -- backed by a vanilla hotbar definition. Preserve that index.
                fieldItem:setAttachedSlotType(slotId)
                fieldItem:setAttachedToModel(slotId)
            else
                fieldItem:setAttachedSlot(-1)
                fieldItem:setAttachedSlotType(nil)
                fieldItem:setAttachedToModel(nil)
            end
        end)
        if not wrote then return false, M.message("IGUI_MLO_Error_SyncSlot") end
    end
    M.markEquipDirty(tx)
    if expected then M.markItemDirty(tx, expected) end
    if previous then M.markItemDirty(tx, previous) end
    return true, nil
end

-- dev.15 deliberately has no BlowTorch slot. Clear only this retired
-- namespace state; current MLO slots and all Base attachment ids are untouched.
function M.clearRetiredBlowTorchState(player)
    if not player then return false, M.message("IGUI_MLO_Error_InvalidPlayer") end
    local tx = M.newTransaction(player)
    local changed, targets, hasTargets = false, {}, false
    -- B42 validates location ids on both getAttachedItem and setAttachedItem.
    -- Register the retired location before the first read so rollback retains
    -- the exact old Java mapping instead of silently snapshotting nil.
    local registered, registrationResult = pcall(M.registerAttachedLocations)
    if not registered or registrationResult ~= true then
        return M.abortTransaction(tx, M.message("IGUI_MLO_Error_SyncAttachments"))
    end
    local mappingRead, mapped = pcall(function() return player:getAttachedItem(RETIRED_BLOWTORCH_SLOT) end)
    if not mappingRead then
        return M.abortTransaction(tx, M.message("IGUI_MLO_Error_SyncAttachments"))
    end
    if mapped then
        targets[mapped] = true
        hasTargets = true
    end

    for _, item in ipairs(M.allRecursiveItems(player)) do
        local md = item:getModData()
        if M.isParent(item) then
            local keys = { "MLO_slot_" .. RETIRED_BLOWTORCH_SLOT,
                "MLO_mount_" .. RETIRED_BLOWTORCH_SLOT,
                "MLO_up_pack_blowTorch", "MLO_up_blowTorch" }
            local old, stale = {}, false
            for _, key in ipairs(keys) do old[key] = md[key]; if md[key] ~= nil then stale = true end end
            if stale then
                M.addUndo(tx, function()
                    for _, key in ipairs(keys) do md[key] = old[key] end
                    return true
                end)
                for _, key in ipairs(keys) do md[key] = nil end
                M.markItemDirty(tx, item)
                changed = true
            end
        end
        local staleSlot = safeCall(function() return item:getAttachedSlotType() end, nil) == RETIRED_BLOWTORCH_SLOT
            or safeCall(function() return item:getAttachedToModel() end, nil) == RETIRED_BLOWTORCH_SLOT
            or safeCall(function() return item:getAttachmentType() end, nil) == RETIRED_BLOWTORCH_TYPE
        if staleSlot then
            targets[item] = true
            hasTargets = true
        end
        -- Clear only a child index that explicitly names the retired slot.
        -- Current durable mount relations on an otherwise old item stay intact.
        if md.MLO_mountSlotId == RETIRED_BLOWTORCH_SLOT then
            local oldParentId, oldSlotId, oldSchema = md.MLO_mountParentId, md.MLO_mountSlotId, md.MLO_mountSchema
            M.addUndo(tx, function()
                md.MLO_mountParentId, md.MLO_mountSlotId, md.MLO_mountSchema = oldParentId, oldSlotId, oldSchema
                return true
            end)
            md.MLO_mountParentId, md.MLO_mountSlotId, md.MLO_mountSchema = nil, nil, nil
            M.markItemDirty(tx, item)
            changed = true
        end
    end

    -- Kahlua mod environments do not consistently expose the global next().
    -- Track this explicitly so retired-state cleanup cannot abort every player
    -- update and every server-authoritative upgrade command.
    if hasTargets then
        local mappingPrevious = mapped
        M.addUndo(tx, function()
            local restored = pcall(function() player:setAttachedItem(RETIRED_BLOWTORCH_SLOT, mappingPrevious) end)
            return restored and safeCall(function() return player:getAttachedItem(RETIRED_BLOWTORCH_SLOT) end, nil) == mappingPrevious
        end)
        local cleared = pcall(function() player:setAttachedItem(RETIRED_BLOWTORCH_SLOT, nil) end)
        if not cleared or safeCall(function() return player:getAttachedItem(RETIRED_BLOWTORCH_SLOT) end, nil) ~= nil then
            return M.abortTransaction(tx, M.message("IGUI_MLO_Error_SyncAttachments"))
        end
        M.markEquipDirty(tx)
        for item in pairs(targets) do
            local oldSlot = safeCall(function() return item:getAttachedSlot() end, -1)
            local oldType = safeCall(function() return item:getAttachedSlotType() end, nil)
            local oldModel = safeCall(function() return item:getAttachedToModel() end, nil)
            local oldAttachmentType = safeCall(function() return item:getAttachmentType() end, nil)
            M.addUndo(tx, function()
                return pcall(function()
                    item:setAttachedSlot(oldSlot)
                    item:setAttachedSlotType(oldType)
                    item:setAttachedToModel(oldModel)
                    item:setAttachmentType(oldAttachmentType)
                end)
            end)
            local cleared = pcall(function()
                item:setAttachedSlot(-1)
                item:setAttachedSlotType(nil)
                item:setAttachedToModel(nil)
                if oldAttachmentType == RETIRED_BLOWTORCH_TYPE then item:setAttachmentType(nil) end
            end)
            if not cleared then return M.abortTransaction(tx, M.message("IGUI_MLO_Error_SyncAttachments")) end
            M.markItemDirty(tx, item)
            changed = true
        end
    end
    if not changed then return true, nil end
    return M.commitTransaction(tx)
end

local function stageParentEquipmentTx(tx, player, parent)
    local equipped = M.parentEquipped(player, parent)
    local parentId = tonumber(parent:getID())
    for _, item in ipairs(M.allRecursiveItems(player)) do
        local md = item:getModData()
        if md and tonumber(md.MLO_parentId) == parentId then
            local moduleKey = md.MLO_moduleKey and tostring(md.MLO_moduleKey) or nil
            local set, reason = setModuleWornTx(
                tx, player, item, moduleKey,
                equipped and M.MODULE_BODY_LOCATION[moduleKey] ~= nil
            )
            if not set then return false, reason end
        end
    end

    return true, nil
end

local function clearParentReferencesTx(tx, parent, item)
    if not parent then return true end
    local md = parent:getModData()
    local id = tonumber(item:getID())
    local fields = {}
    for moduleKey in pairs(M.MODULE_NAME_KEY) do fields[#fields + 1] = "MLO_module_" .. moduleKey end
    for _, slotId in ipairs(M.SLOT_ORDER) do fields[#fields + 1] = "MLO_slot_" .. slotId end
    for _, field in ipairs(fields) do
        if tonumber(md[field]) == id then
            local previous = md[field]
            M.addUndo(tx, function() md[field] = previous return md[field] == previous end)
            md[field] = nil
        end
    end
    return true
end

function M.restoreOrphanModule(player, item, parent)
    if not player or not item or not M.isModuleItem(item) then return false, M.message("IGUI_MLO_Error_InvalidModule") end
    local tx = M.newTransaction(player)
    clearParentReferencesTx(tx, parent, item)
    for _, slotId in ipairs(M.SLOT_ORDER) do
        local current = safeCall(function() return player:getAttachedItem(slotId) end, nil)
        if current == item then
            local cleared, clearReason = setAttachedItemTx(tx, player, slotId, nil, item)
            if not cleared then return M.abortTransaction(tx, clearReason) end
        end
    end
    local moduleKey = item:getModData().MLO_moduleKey
    local equipCleared, equipReason = setModuleWornTx(tx, player, item, moduleKey, false)
    if not equipCleared then return M.abortTransaction(tx, equipReason) end
    local visualCleared, visualReason = setAttachmentVisualTx(tx, item, false)
    if not visualCleared then return M.abortTransaction(tx, visualReason) end
    local unlinked, unlinkReason = unlinkModuleStateTx(tx, nil, item, moduleKey)
    if not unlinked then return M.abortTransaction(tx, unlinkReason) end
    if M.isContainerProxy(item) then
        local restored, restoreReason = M.restoreContainerSourceTx(tx, player, item)
        if not restored then return M.abortTransaction(tx, restoreReason) end
    end
    return M.commitTransaction(tx)
end

function M.reconcileOrphanModules(player)
    if not player then return false, 0 end
    local items = M.allRecursiveItems(player)
    local parents = {}
    for _, item in ipairs(items) do
        if M.isParent(item) then
            local id = safeCall(function() return tonumber(item:getID()) end, nil)
            if id then parents[id] = item end
        end
    end
    local changed = 0
    for _, item in ipairs(items) do
        local md = item:getModData()
        local parentId = md and tonumber(md.MLO_parentId) or nil
        if parentId then
            local parent = parents[parentId]
            local moduleKey = md.MLO_moduleKey and tostring(md.MLO_moduleKey) or nil
            -- A sewn pocket remains in the character root while its owning
            -- backpack is a world item. Absence from this inventory walk is
            -- therefore not proof of orphaning; preserve user contents until
            -- the same parent is picked up and can be verified again.
            local deferredWorldParent = not parent and M.FIXED_POUCH[moduleKey] ~= nil
                and M.isFixedPouchItem(item)
            local itemId = safeCall(function() return tonumber(item:getID()) end, nil)
            local linked = false
            if parent and moduleKey and itemId then
                local parentMd = parent:getModData()
                linked = tonumber(parentMd["MLO_module_" .. moduleKey]) == itemId
                local slotId = M.MODULE_SLOT[moduleKey]
                if not linked and slotId then linked = tonumber(parentMd["MLO_slot_" .. slotId]) == itemId end
            end
            if not linked and not deferredWorldParent then
                local restored, reason = M.restoreOrphanModule(player, item, parent)
                if not restored then return false, changed, reason end
                changed = changed + 1
            end
        end
    end
    return true, changed, nil
end

local function setParentFieldTx(tx, parent, field, value)
    local md = parent:getModData()
    local previous = md[field]
    M.addUndo(tx, function() md[field] = previous return md[field] == previous end)
    md[field] = value
    M.markItemDirty(tx, parent)
    return true
end

local function restoreRetiredRigModuleTx(tx, player, parent, item, moduleKey)
    local upgradeKey = RETIRED_RIG_MODULE_UPGRADE[moduleKey]
    if not upgradeKey then return false, M.message("IGUI_MLO_Error_InvalidModule") end

    local unequipped, equipReason = setModuleWornTx(tx, player, item, moduleKey, false)
    if not unequipped then return false, equipReason end
    local unlinked, unlinkReason = unlinkModuleStateTx(tx, parent, item, moduleKey)
    if not unlinked then return false, unlinkReason end

    if moduleKey == "rigBullets" or moduleKey == "rigShells" then
        local emptied, emptyReason = M.moveContentsToRootTx(tx, player, item)
        if not emptied then return false, emptyReason end
        local resized, resizeReason = M.setCapacityTx(tx, item, 1)
        if not resized then return false, resizeReason end
    else
        local root = player:getInventory()
        local restored = safeCall(function() return root:AddItem("Base.Bag_ChestRig") end, nil)
        if not restored then
            return false, M.message("IGUI_MLO_Error_CreateModule", M.itemArgument("Base.Bag_ChestRig"))
        end
        M.addUndo(tx, function()
            local current = itemContainer(restored)
            if current and not removeExistingItem(current, restored) then return false end
            return itemContainer(restored) == nil
        end)
        tx.newItems[restored] = true
        queueNetworkOp(tx, "add", root, restored)
        local transferred, transferReason = M.transferContentsTx(tx, item, restored)
        if not transferred then return false, transferReason end
        local removed, removeReason = M.removeItemTx(tx, item)
        if not removed then return false, removeReason end
    end

    setParentFieldTx(tx, parent, "MLO_up_" .. upgradeKey, nil)
    return true, nil
end

local function retireThirdBeltPouchTx(tx, player, parent, item)
    local moduleKey = RETIRED_BELT_POUCH
    local unequipped, equipReason = setModuleWornTx(tx, player, item, moduleKey, false)
    if not unequipped then return false, equipReason end
    local unlinked, unlinkReason = unlinkModuleStateTx(tx, parent, item, moduleKey)
    if not unlinked then return false, unlinkReason end
    local emptied, emptyReason = M.moveContentsToRootTx(tx, player, item)
    if not emptied then return false, emptyReason end
    local removed, removeReason = M.removeItemTx(tx, item)
    if not removed then return false, removeReason end
    setParentFieldTx(tx, parent, "MLO_up_belt_pouch3", nil)
    return true, nil
end

local function migrateRetiredRigSlots(player, changedParents)
    local root = player:getInventory()
    for _, parent in ipairs(M.allRecursiveItems(player)) do
        if M.groupOf(parent) == "rig" then
            local tx = M.newTransaction(player)
            local changed = false
            local md = parent:getModData()
            for retiredSlot, mapping in pairs(RETIRED_RIG_SLOT_MAP) do
                local retiredField = M.mountField(retiredSlot)
                local legacyField = "MLO_slot_" .. retiredSlot
                local itemId = tonumber(md[retiredField]) or tonumber(md[legacyField])
                local retiredFlag = md["MLO_up_" .. mapping.retiredUpgrade] == true
                if retiredFlag or itemId then
                    if md["MLO_up_" .. mapping.activeUpgrade] ~= true then
                        setParentFieldTx(tx, parent, "MLO_up_" .. mapping.activeUpgrade, true)
                    end
                    setParentFieldTx(tx, parent, "MLO_up_" .. mapping.retiredUpgrade, nil)
                    setParentFieldTx(tx, parent, retiredField, nil)
                    setParentFieldTx(tx, parent, legacyField, nil)

                    local item = itemId and M.findById(player, itemId) or nil
                    local attached = safeCall(function() return player:getAttachedItem(retiredSlot) end, nil)
                    if attached then
                        local cleared, clearReason = setAttachedItemTx(tx, player, retiredSlot, nil, attached)
                        if not cleared then return M.abortTransaction(tx, clearReason), clearReason end
                    end

                    local activeField = M.mountField(mapping.activeSlot)
                    if item and itemContainer(item) == root and md[activeField] == nil
                        and M.isCompatible(mapping.activeSlot, item) then
                        local linked, linkReason = writePersistentMountTx(tx, parent, mapping.activeSlot, item)
                        if not linked then return M.abortTransaction(tx, linkReason), linkReason end
                    elseif item then
                        local cleared, clearReason = clearChildMountTx(tx, item, parent, retiredSlot)
                        if not cleared then return M.abortTransaction(tx, clearReason), clearReason end
                    end
                    changed = true
                end
            end
            if changed then
                local committed, commitReason = M.commitTransaction(tx)
                if not committed then return false, commitReason end
                M.renameParent(parent)
                changedParents[parent] = true
            end
        end
    end
    return true, nil
end

function M.migrateLegacyContainerModules(player)
    if not player then return false, {}, M.message("IGUI_MLO_Error_InvalidPlayer") end
    local changedParents = {}
    local items = M.allRecursiveItems(player)
    for _, item in ipairs(items) do
        local md = item:getModData()
        local moduleKey = md and md.MLO_moduleKey and tostring(md.MLO_moduleKey) or nil
        local parent = moduleKey and M.findById(player, tonumber(md.MLO_parentId)) or nil
        -- Keyclips are created by new upgrades only; old rings are not converted.
        local fixedPouch = moduleKey and moduleKey ~= "beltKeyClip" and M.FIXED_POUCH[moduleKey] or nil
        local linked = parent and tonumber(parent:getModData()["MLO_module_" .. moduleKey]) == tonumber(item:getID())
        local retiredRigModule = linked and RETIRED_RIG_MODULE_UPGRADE[moduleKey] ~= nil
        local retiredBeltPouch = linked and moduleKey == RETIRED_BELT_POUCH
        local needsFixedPouch = linked and fixedPouch and M.fullType(item) ~= fixedPouch.fullType
        local needsFixedCapacityRepair = linked and fixedPouch
            and (moduleKey == "rigPouchL" or moduleKey == "rigPouchR"
                or moduleKey == "beltPouch1" or moduleKey == "beltPouch2")
            and M.fullType(item) == fixedPouch.fullType
            and safeCall(function() return tonumber(item:getCapacity()) end, nil) ~= fixedPouch.capacity

        if retiredRigModule then
            local tx = M.newTransaction(player)
            local restored, restoreReason = restoreRetiredRigModuleTx(tx, player, parent, item, moduleKey)
            if not restored then return M.abortTransaction(tx, restoreReason), changedParents, restoreReason end
            local committed, commitReason = M.commitTransaction(tx)
            if not committed then return false, changedParents, commitReason end
            changedParents[parent] = true
        elseif retiredBeltPouch then
            local tx = M.newTransaction(player)
            local retired, retireReason = retireThirdBeltPouchTx(tx, player, parent, item)
            if not retired then return M.abortTransaction(tx, retireReason), changedParents, retireReason end
            local committed, commitReason = M.commitTransaction(tx)
            if not committed then return false, changedParents, commitReason end
            changedParents[parent] = true
        elseif needsFixedPouch then
            local tx = M.newTransaction(player)
            local unlinked, unlinkReason = unlinkModuleStateTx(tx, parent, item, moduleKey)
            if not unlinked then return M.abortTransaction(tx, unlinkReason), changedParents, unlinkReason end
            local replacement, createReason = M.createModuleTx(
                tx, player, parent, fixedPouch.fullType, moduleKey,
                M.MODULE_NAME_KEY[moduleKey], M.sourceWeightReduction(item, 65), fixedPouch.capacity
            )
            if not replacement then return M.abortTransaction(tx, createReason), changedParents, createReason end
            local transferred, transferReason = M.transferContentsTx(tx, item, replacement)
            if not transferred then return M.abortTransaction(tx, transferReason), changedParents, transferReason end
            local removed, removeReason = M.removeItemTx(tx, item)
            if not removed then return M.abortTransaction(tx, removeReason), changedParents, removeReason end
            local worn, wornReason = setModuleWornTx(
                tx, player, replacement, moduleKey, M.parentEquipped(player, parent)
            )
            if not worn then return M.abortTransaction(tx, wornReason), changedParents, wornReason end
            local committed, commitReason = M.commitTransaction(tx)
            if not committed then return false, changedParents, commitReason end
            changedParents[parent] = true
        elseif needsFixedCapacityRepair then
            local tx = M.newTransaction(player)
            local resized, resizeReason = M.setCapacityTx(tx, item, fixedPouch.capacity)
            if not resized then return M.abortTransaction(tx, resizeReason), changedParents, resizeReason end
            local committed, commitReason = M.commitTransaction(tx)
            if not committed then return false, changedParents, commitReason end
            changedParents[parent] = true
        elseif M.isContainerProxy(item) and (moduleKey == "packMedBox" or moduleKey == "packToolbox") then
            local parent = M.findById(player, tonumber(md.MLO_parentId))
            local slotId = M.MODULE_SLOT[moduleKey]
            local parentMd = parent and parent:getModData() or nil
            local linkedByModule = parentMd
                and tonumber(parentMd["MLO_module_" .. moduleKey]) == tonumber(item:getID())
            local linkedBySlot = parentMd
                and tonumber(parentMd["MLO_slot_" .. slotId]) == tonumber(item:getID())
            if parent and (linkedByModule or linkedBySlot) then
                local tx = M.newTransaction(player)
                local currentAttached = safeCall(function() return player:getAttachedItem(slotId) end, nil)
                if currentAttached == item then
                    local cleared, clearReason = setAttachedItemTx(tx, player, slotId, nil, item)
                    if not cleared then return M.abortTransaction(tx, clearReason), changedParents, clearReason end
                end
                local visual, visualReason = setAttachmentVisualTx(tx, item, false)
                if not visual then return M.abortTransaction(tx, visualReason), changedParents, visualReason end
                local unequipped, equipReason = setEquipParentTx(tx, item, nil)
                if not unequipped then return M.abortTransaction(tx, equipReason), changedParents, equipReason end
                local unlinked, unlinkReason = unlinkModuleStateTx(tx, parent, item, moduleKey)
                if not unlinked then return M.abortTransaction(tx, unlinkReason), changedParents, unlinkReason end
                local restored, restoreReason = M.restoreContainerSourceTx(tx, player, item)
                if not restored then return M.abortTransaction(tx, restoreReason), changedParents, restoreReason end
                local slotted, slotReason = M.setSlotItemTx(tx, parent, slotId, nil)
                if not slotted then return M.abortTransaction(tx, slotReason), changedParents, slotReason end
                local committed, commitReason = M.commitTransaction(tx)
                if not committed then return false, changedParents, commitReason end
                changedParents[parent] = true
            end
        elseif moduleKey == "packMedBox" or moduleKey == "packToolbox" then
            local sourceType = M.fullType(item)
            local validDirect = moduleKey == "packMedBox" and M.TYPE.FIRST_AID[sourceType]
                or moduleKey == "packToolbox" and M.TYPE.TOOLBOX[sourceType]
            local parent = validDirect and M.findById(player, tonumber(md.MLO_parentId)) or nil
            local slotId = parent and M.MODULE_SLOT[moduleKey] or nil
            if slotId and tonumber(parent:getModData()["MLO_slot_" .. slotId]) == tonumber(item:getID()) then
                local tx = M.newTransaction(player)
                -- Convert the old parallel link in place.  If vanilla already
                -- has this exact root-inventory item attached, keep that live
                -- state; the client may otherwise project the durable relation
                -- on the next worn-parent refresh.
                local modeled, modelReason = setAttachmentVisualTx(tx, item, false)
                if not modeled then return M.abortTransaction(tx, modelReason), changedParents, modelReason end
                if safeCall(function() return item:getEquipParent() end, nil) ~= nil then
                    local cleared, clearReason = setEquipParentTx(tx, item, nil)
                    if not cleared then return M.abortTransaction(tx, clearReason), changedParents, clearReason end
                end
                local unlinked, unlinkReason = unlinkModuleStateTx(tx, parent, item, moduleKey)
                if not unlinked then return M.abortTransaction(tx, unlinkReason), changedParents, unlinkReason end
                local previousRepairPending=md.MLO_legacyContainerRepairPending
                M.addUndo(tx,function()
                    md.MLO_legacyContainerRepairPending=previousRepairPending
                    return md.MLO_legacyContainerRepairPending==previousRepairPending
                end)
                md.MLO_legacyContainerRepairPending=true
                M.markItemDirty(tx,item)
                local slotted, slotReason = M.setSlotItemTx(tx, parent, slotId, nil)
                if not slotted then return M.abortTransaction(tx, slotReason), changedParents, slotReason end
                local mounted, mountReason = M.setPersistentMountTx(tx, player, parent, slotId, item)
                if not mounted then return M.abortTransaction(tx, mountReason), changedParents, mountReason end
                local committed, commitReason = M.commitTransaction(tx)
                if not committed then return false, changedParents, commitReason end
                changedParents[parent] = true
            end
        end
    end
    local slotsMigrated, slotsReason = migrateRetiredRigSlots(player, changedParents)
    if not slotsMigrated then return false, changedParents, slotsReason end
    return true, changedParents, nil
end

function M.syncInstalledModules(player, refreshPresentation, snapshot, migrateLegacy)
    if not player then return false end
    M.registerBodyLocations()
    local ok = true
    local items = snapshot and snapshot.items or M.allRecursiveItems(player)
    for _, item in ipairs(items) do
        local md = item:getModData()
        local pid = md and tonumber(md.MLO_parentId) or nil
        if refreshPresentation and (pid or M.isParent(item)) then M.refreshDynamicName(item) end
        if migrateLegacy and pid then
            if md.MLO_version ~= M.VERSION and md.MLO_originalFavorite ~= nil then
                local repaired = pcall(function() item:setFavorite(md.MLO_originalFavorite == true) end)
                if not repaired then ok = false end
                md.MLO_version = M.VERSION
            end
            local moduleKey = md.MLO_moduleKey and tostring(md.MLO_moduleKey) or nil
            local location = moduleKey and M.MODULE_BODY_LOCATION[moduleKey] or nil
            local cleared = pcall(function()
                if location then
                    local current = player:getWornItem(location)
                    if current == item then player:removeWornItem(item, false) end
                elseif item:getEquipParent() ~= nil then
                    item:setEquipParent(nil)
                end
            end)
            if not cleared then
                ok = false
                M.logOnce("ModulePresentation:clear:" .. itemId(item),
                    "legacy worn-module cleanup failed for module " .. itemId(item))
            end
        end
    end
    return ok
end

function M.syncAttachedItems(player, snapshot, migrateRetired, attachmentHintsByParent)
    if not player then return false end
    if migrateRetired then
        local retired, retiredReason = M.clearRetiredBlowTorchState(player)
        if not retired then
            M.logOnce("retired-blowtorch:" .. itemId(player), "retired BlowTorch cleanup failed: " .. tostring(retiredReason))
            return false
        end
    end
    -- Retired-item migration above may change inventory/relations. Build the
    -- view only after that mutation boundary, then share it within this pass.
    snapshot = snapshot or M.inventorySnapshot(player)
    local ok = M.syncDetachableItems(player, snapshot)
    local parents = snapshot and snapshot.parents or M.allRecursiveItems(player)
    for _, parent in ipairs(parents) do
        if M.isParent(parent) then
            local parentId = safeCall(function() return tonumber(parent:getID()) end, nil)
            local hints = parentId and attachmentHintsByParent and attachmentHintsByParent[parentId] or nil
            if not M.ensureAttachmentsProvided(parent, hints) then ok = false end
        end
    end
    return ok
end

local function installFixedPouchTx(tx, player, parent, source, moduleKey, name, missingKey)
    if not source then return false, M.message(missingKey or "IGUI_MLO_Error_SourcePouch") end
    if not safeCall(function() return source:IsInventoryContainer() end, false) then
        return false, M.message("IGUI_MLO_Error_NotContainer")
    end
    local fixed = M.FIXED_POUCH[moduleKey]
    if not fixed then return false, M.message("IGUI_MLO_Error_InvalidModule") end
    local module, createReason = M.createModuleTx(
        tx, player, parent, fixed.fullType, moduleKey, name,
        M.sourceWeightReduction(source, 65), fixed.capacity
    )
    if not module then return false, createReason end
    if fixed.preserveContents then
        local transferred, transferReason = M.transferContentsTx(tx, source, module)
        if not transferred then return false, transferReason end
    end
    return M.removeItemTx(tx, source)
end

local function installFlagTx(tx, parent, key)
    local md = parent:getModData()
    local flagKey = "MLO_up_" .. key
    local oldFlag = md[flagKey]
    local oldVersion = md.MLO_version
    local oldGroup = md.MLO_group
    local oldName = safeCall(function() return tostring(parent:getDisplayName()) end, M.fullType(parent))
    local oldNameKey = md.MLO_nameKey
    local oldCustom = safeCall(function() return parent:isCustomName() end, false)
    local oldGeneration = md.MLO_componentGeneration

    M.addUndo(tx, function()
        md[flagKey] = oldFlag
        md.MLO_version = oldVersion
        md.MLO_group = oldGroup
        md.MLO_nameKey = oldNameKey
        md.MLO_componentGeneration = oldGeneration
        local ok = pcall(function()
            parent:setName(oldName)
            parent:setCustomName(oldCustom)
        end)
        return ok and md[flagKey] == oldFlag and md.MLO_version == oldVersion
    end)

    local ok = pcall(function() M.installFlag(parent, key) end)
    if not ok then return false, M.message("IGUI_MLO_Error_SaveUpgrade") end
    md.MLO_componentGeneration = M.componentGeneration(parent)
    return true, nil
end

local function applyUpgradeBranch(tx, player, parent, key, source)
    local armorModule = M.ARMOR_POUCH_UPGRADE[key]
    if armorModule then
        return installFixedPouchTx(tx,player,parent,source,armorModule,M.MODULE_NAME_KEY[armorModule])
    end
    if key=="belt_pouch1" then
        return installFixedPouchTx(tx,player,parent,source,"beltPouch1",M.MODULE_NAME_KEY.beltPouch1)
    elseif key=="belt_pouch2" then
        return installFixedPouchTx(tx,player,parent,source,"beltPouch2",M.MODULE_NAME_KEY.beltPouch2)
    elseif key=="belt_keyclip" then
        return installFixedPouchTx(tx,player,parent,source,"beltKeyClip",
            M.MODULE_NAME_KEY.beltKeyClip,"IGUI_MLO_Error_SourceKeyRing")

    elseif key=="rig_pouchL" then
        return installFixedPouchTx(tx,player,parent,source,"rigPouchL",M.MODULE_NAME_KEY.rigPouchL)
    elseif key=="rig_pouchR" then
        return installFixedPouchTx(tx,player,parent,source,"rigPouchR",M.MODULE_NAME_KEY.rigPouchR)

    elseif key=="pack_topPouch" then
        return installFixedPouchTx(
            tx,player,parent,source,"packTopPouch",M.MODULE_NAME_KEY.packTopPouch,"IGUI_MLO_Error_SourcePouch"
        )

    elseif key=="pack_sidePouchL" then
        return installFixedPouchTx(
            tx,player,parent,source,"packSideL",M.MODULE_NAME_KEY.packSideL,"IGUI_MLO_Error_SourceSideBag"
        )

    elseif key=="pack_sidePouchR" then
        return installFixedPouchTx(
            tx,player,parent,source,"packSideR",M.MODULE_NAME_KEY.packSideR,"IGUI_MLO_Error_SourceSideBag"
        )

    end

    -- All non-container hardpoints share the same source-consumption path.
    -- The caller owns materials, completion flags and native slot publication.
    if source then return M.removeItemTx(tx, source) end
    return true, nil
end

function M.applyUpgrade(player, parent, key)
    local ready = M.reconcileComponents(player)
    if not ready then return false, M.message("IGUI_MLO_Error_SyncState") end
    local ok, reason = M.checkUpgrade(player, parent, key)
    if not ok then return false, reason end
    local def = M.UPGRADES[key]
    local sources, missingRequirement = M.getSourcesForUpgrade(player, def)
    if not sources then
        return false, M.message((missingRequirement and missingRequirement.missingKey)
            or "IGUI_MLO_Error_PartRequired")
    end
    local source = sources[1]
    local materialPlan, missing = M.collectMaterialPlan(player, def.materials)
    if not materialPlan then return false, M.message("IGUI_MLO_Error_MissingMaterial", M.itemArgument(missing), 1) end

    local tx = M.newTransaction(player)
    local branchOk, branchReason = applyUpgradeBranch(tx, player, parent, key, source)
    if not branchOk then
        return M.abortTransaction(tx, branchReason or M.message("IGUI_MLO_Error_PrepareOutput"))
    end

    for index = 2, #sources do
        local removed, removeReason = M.removeItemTx(tx, sources[index])
        if not removed then return M.abortTransaction(tx, removeReason) end
    end

    local consumed, consumeReason = M.consumeMaterialPlan(tx, materialPlan)
    if not consumed then
        return M.abortTransaction(tx, M.message("IGUI_MLO_Error_ConsumeMaterial", M.itemArgument(consumeReason)))
    end

    local flagged, flagReason = installFlagTx(tx, parent, key)
    if not flagged then
        return M.abortTransaction(tx, flagReason)
    end

    local provided, providedReason = ensureAttachmentsProvidedTx(tx, parent)
    if not provided then
        return M.abortTransaction(tx, providedReason)
    end

    M.markItemDirty(tx, parent)

    local staged, stageReason = stageParentEquipmentTx(tx, player, parent)
    if not staged then return M.abortTransaction(tx, stageReason) end

    local committed, commitReason = M.commitTransaction(tx)
    if not committed then return false, commitReason end
    local providedOk, provided = pcall(function() return M.ensureAttachmentsProvided(parent) end)
    if not providedOk or not provided then
        M.logOnce("post-commit:attachments:" .. itemId(parent),
            "post-commit attachment definition sync failed for parent " .. itemId(parent))
    end
    return true, nil
end

function M.describeRequirements(def)
    local parts = {}
    if tonumber(def.tailoring) and tonumber(def.tailoring) > 0 then
        parts[#parts+1] = M.text("IGUI_MLO_Requirement_Skill", {
            M.textArgument("IGUI_perks_Tailoring"), tonumber(def.tailoring)
        })
    end
    for ft, amount in pairs(def.materials or {}) do
        parts[#parts+1] = M.text("IGUI_MLO_Requirement_Material", {M.itemArgument(ft), amount})
    end
    for _, requirement in ipairs(M.sourceRequirements(def)) do
        if requirement.sourceTag then
            parts[#parts+1] = M.text("IGUI_MLO_Requirement_SourceSet", {
                M.textArgument("IGUI_MLO_SourceTag_" .. tostring(requirement.sourceTag))
            })
        end
        if requirement.sourceSet then
            parts[#parts+1] = M.text("IGUI_MLO_Requirement_SourceSet", {
                M.textArgument("IGUI_MLO_SourceSet_" .. tostring(requirement.sourceSet))
            })
        end
        if requirement.sourceTypes then
            for ft in pairs(requirement.sourceTypes) do
                parts[#parts+1] = M.text("IGUI_MLO_Requirement_Source", {M.itemArgument(ft)})
                break
            end
        end
    end
    if #def.tools > 0 then
        for _,ft in ipairs(def.tools) do
            parts[#parts+1] = M.text("IGUI_MLO_Requirement_Tool", {M.itemArgument(ft)})
        end
    end
    return table.concat(parts, "\n")
end

-- Native extra-actions replace the instance for both paired side changes and
-- same-side wear of these Army armor types. This is an identity handover, not
-- an old-save migration.
function M.armorSideSwapEquipment(item, extra)
    local source
    for _, equipment in ipairs(M.ARMOR_EQUIPMENT) do
        if equipment.fullType == M.fullType(item) then source = equipment break end
    end
    if not source then return nil end
    for _, target in ipairs(M.ARMOR_EQUIPMENT) do
        if target.fullType == extra and (target.group == source.opposite or target == source) then
            return source, target
        end
    end
    return nil
end

function M.validateArmorSideSwap(player, parent, source, target)
    if not player or not parent or parent:getContainer() ~= player:getInventory() then
        return nil, "parent-not-in-root"
    end
    if not M.reconcileComponents(player) then return nil, "component-reset-pending" end
    local snapshot = M.inventorySnapshot(player)
    if M.findById(player, parent:getID(), snapshot) ~= parent then return nil, "parent-not-in-root" end
    local sameSide = source == target
    local md, plan = parent:getModData(), {source=source,target=target,pockets={},sameSide=sameSide}
    local expectedChildren = {}
    local parentId = tonumber(parent:getID())

    -- Recovery is deliberately limited to a user-triggered same-side native
    -- replacement.  A saved child may still name the removed predecessor, but
    -- only when its current parent has the sole exact forward declaration.
    local function isPositiveInteger(id)
        return id and id > 0 and id == math.floor(id)
    end

    local function hasOneExactId(item, id)
        local matches = 0
        for _, candidate in ipairs(snapshot.items) do
            if tonumber(candidate:getID()) == id then matches = matches + 1 end
        end
        return matches == 1
    end

    local function hasOnlyCurrentForwardClaim(child, field)
        local childId = tonumber(child:getID())
        local claims, expected = 0, false
        for _, candidate in ipairs(snapshot.items) do
            local candidateMd = candidate:getModData()
            for moduleKey in pairs(M.FIXED_POUCH) do
                if tonumber(candidateMd["MLO_module_" .. moduleKey]) == childId then
                    claims = claims + 1
                    if candidate == parent and field == "MLO_module_" .. moduleKey then expected = true end
                end
            end
            for _, slotId in ipairs(M.SLOT_ORDER) do
                if M.getPersistentMountId(candidate, slotId) == childId then
                    claims = claims + 1
                    if candidate == parent and field == M.mountField(slotId) then expected = true end
                end
            end
        end
        return claims == 1 and expected
    end

    local function acceptsStaleParent(child, reverseField, relationField)
        if not sameSide or not child or itemContainer(child) ~= player:getInventory() then return false end
        local childId = tonumber(child:getID())
        local staleId = tonumber(child:getModData()[reverseField])
        if not isPositiveInteger(parentId) or not isPositiveInteger(childId)
            or not isPositiveInteger(staleId) or staleId == parentId
            or not hasOneExactId(parent, parentId) or not hasOneExactId(child, childId)
            or M.findById(player, staleId, snapshot) then return false end
        if not hasOnlyCurrentForwardClaim(child, relationField) then return false end
        if plan.staleParentId and plan.staleParentId ~= staleId then return false end
        plan.staleParentId = staleId
        return true
    end
    for index, pocket in ipairs(source.pockets) do
        local other = target.pockets[index]
        local childId = tonumber(md["MLO_module_" .. pocket[2]])
        local child = childId and M.findById(player, childId, snapshot) or nil
        if not sameSide and (md["MLO_up_" .. other[1]] ~= nil or md["MLO_module_" .. other[2]] ~= nil) then
            return nil, "opposite-pocket-state-conflict"
        end
        local resolved = child and M.fixedModuleContainerForParent(player, parent, pocket[2], snapshot) == child
        local recovered = child and not resolved
            and M.fullType(child) == M.FIXED_POUCH[pocket[2]].fullType
            and safeCall(function() return child:IsInventoryContainer() end, false)
            and safeCall(function()
                local inventory = child:getInventory()
                return inventory and inventory:getContainingItem() == child
            end, false)
            and child:getModData().MLO_detachedPouch ~= true
            and child:getModData().MLO_moduleKey == pocket[2]
            and child:getModData().MLO_mountParentId == nil
            and child:getModData().MLO_mountSlotId == nil
            and child:getModData().MLO_mountSchema == nil
            and acceptsStaleParent(child, "MLO_parentId", "MLO_module_" .. pocket[2])
        if (md["MLO_module_" .. pocket[2]] ~= nil and not childId)
            or (md["MLO_up_" .. pocket[1]] == true) ~= (childId ~= nil)
            or (childId and not (resolved or recovered)) then
            return nil, "pocket-relation-conflict"
        end
        plan.pockets[#plan.pockets+1] = {source=pocket,target=other,item=child}
        if child then expectedChildren[child] = true end
    end
    if source.mount then
        local mount, other = source.mount, target.mount
        local childId = M.getPersistentMountId(parent, mount.slot)
        local child = childId and M.findById(player, childId, snapshot) or nil
        if not sameSide and (md["MLO_up_" .. other.key] ~= nil or md[M.mountField(other.slot)] ~= nil
            or md["MLO_slot_" .. other.slot] ~= nil) then return nil, "opposite-mount-state-conflict" end
        if md[M.mountField(mount.slot)] ~= nil and not childId then return nil, "invalid-mount-id" end
        local mountValid = childId and child and child:getContainer() == player:getInventory()
            and M.isCompatible(other.slot, child)
            and child:getModData().MLO_mountSlotId == mount.slot
            and tonumber(child:getModData().MLO_mountSchema) == 1
        local resolvedMount = mountValid
            and tonumber(child:getModData().MLO_mountParentId) == parentId
        local recoveredMount = mountValid and not resolvedMount
            and child:getModData().MLO_parentId == nil
            and child:getModData().MLO_moduleKey == nil
            and acceptsStaleParent(child, "MLO_mountParentId", M.mountField(mount.slot))
        if childId and (md["MLO_up_" .. mount.key] ~= true or not (resolvedMount or recoveredMount)) then
            return nil, "mount-relation-conflict"
        end
        if md["MLO_slot_" .. mount.slot] ~= nil
            and (not childId or tonumber(md["MLO_slot_" .. mount.slot]) ~= childId) then
            return nil, "slot-relation-conflict"
        end
        plan.mount = {source=mount,target=other,item=child}
        if child then expectedChildren[child] = true end
    end
    -- A reverse-only link is unresolved data, not permission to orphan it.
    -- Once a legacy predecessor is accepted, it has the same exclusivity rule.
    for _, child in ipairs(snapshot.items) do
        local childMd = child:getModData()
        local pouchParent = tonumber(childMd.MLO_parentId)
        local mountParent = tonumber(childMd.MLO_mountParentId)
        if (pouchParent == parentId or mountParent == parentId
            or (plan.staleParentId and (pouchParent == plan.staleParentId or mountParent == plan.staleParentId)))
            and not expectedChildren[child] then return nil, "unresolved-child-relation" end
    end
    return plan
end

function M.prepareArmorSideSwap(tx, player, oldItem, newItem, plan)
    if not newItem or newItem == oldItem or newItem:getID() == oldItem:getID()
        or M.fullType(newItem) ~= plan.target.fullType or newItem:getContainer() ~= nil then
        return false, "invalid-native-replacement"
    end
    local md, oldMd = newItem:getModData(), oldItem:getModData()
    local function write(item, field, value)
        local data, previous = item:getModData(), item:getModData()[field]
        M.addUndo(tx, function() data[field] = previous return data[field] == previous end)
        data[field] = value
        M.markItemDirty(tx, item)
    end
    local function move(field, other)
        write(newItem, other, oldMd[field])
        if field ~= other then write(newItem, field, nil) end
    end
    local function rename(item, key)
        local name, custom = item:getDisplayName(), item:isCustomName()
        M.addUndo(tx, function()
            item:setName(name)
            item:setCustomName(custom)
            return item:getDisplayName() == name and item:isCustomName() == custom
        end)
        write(item, "MLO_nameKey", key)
        return M.refreshDynamicName(item)
    end
    if oldMd.MLO_group ~= nil then write(newItem, "MLO_group", plan.target.group) end
    for _, pocket in ipairs(plan.pockets) do
        move("MLO_up_" .. pocket.source[1], "MLO_up_" .. pocket.target[1])
        move("MLO_module_" .. pocket.source[2], "MLO_module_" .. pocket.target[2])
        local child = pocket.item
        if child then
            write(child, "MLO_parentId", newItem:getID())
            write(child, "MLO_moduleKey", pocket.target[2])
            if not rename(child, M.MODULE_NAME_KEY[pocket.target[2]]) then return false, "pocket-name-failed" end
        end
    end
    local mount = plan.mount
    if mount then
        move("MLO_up_" .. mount.source.key, "MLO_up_" .. mount.target.key)
        move(M.mountField(mount.source.slot), M.mountField(mount.target.slot))
        move("MLO_slot_" .. mount.source.slot, "MLO_slot_" .. mount.target.slot)
        if mount.item then writePersistentMountTx(tx, newItem, mount.target.slot, mount.item) end
    end
    local provided = ensureAttachmentsProvidedTx(tx, newItem)
    if not provided then return false, "replacement-attachments-failed" end
    local upgraded = false
    for _, key in ipairs(M.UPGRADE_ORDER[plan.target.group]) do
        if md["MLO_up_" .. key] == true then upgraded = true break end
    end
    if upgraded and not rename(newItem, M.PARENT_NAME_KEY[plan.target.group]) then
        return false, "replacement-name-failed"
    end
    return true
end

function M.finishArmorSideSwap(tx)
    -- Vanilla has already replaced the parent and emitted its packets/event.
    -- A failed child sync must never roll ownership back to the removed ID.
    local synced = flushNetwork(tx)
    tx.undos, tx.networkOps, tx.dirtyItems, tx.newItems = {}, {}, {}, {}
    tx.equipDirty = false
    return synced
end

-- Component shutdown is a metadata-only operation. No source bag is recreated,
-- no inventory item is added/removed, and no contents cross a container boundary.
local componentPublications = {}
function M.observeComponentOptions()
    if networkRole() == "client" then return false end
    local history = safeCall(function() return ModData.getOrCreate("MLO_ComponentOptions") end, nil)
    if not history then
        for _, name in ipairs(M.COMPONENT_OPTIONS) do
            if not M.componentOptionEnabled(name) then return false, "history-unavailable" end
        end
        return false
    end
    local changed = false
    M.componentGenerations = M.componentGenerations or {}
    M.hasComponentDisableHistory = false
    for _, name in ipairs(M.COMPONENT_OPTIONS) do
        local enabled = M.componentOptionEnabled(name)
        local entry = history[name]
        if type(entry) ~= "table" then entry = {enabled=true, generation=0} history[name] = entry end
        if entry.enabled ~= enabled then
            if not enabled then entry.generation = (tonumber(entry.generation) or 0) + 1 end
            entry.enabled = enabled
            changed = true
        end
        M.componentGenerations[name] = tonumber(entry.generation) or 0
        if M.componentGenerations[name] > 0 then M.hasComponentDisableHistory = true end
    end
    if changed then M.componentOptionsPending = true end
    return changed
end

-- An individual player's interaction must not consume the notification that
-- still needs to reach all other online players at the next native minute.
function M.takeComponentOptionsChange()
    M.observeComponentOptions()
    local changed = M.componentOptionsPending == true
    M.componentOptionsPending = false
    return changed
end

function M.flushComponentPublications(player, retry)
    local pending = componentPublications[player]
    if not pending then return true end
    if retry then pending.attempts = 0 end
    if pending.attempts >= 3 then return false end
    pending.attempts = pending.attempts + 1
    if flushNetwork(pending) then
        local notified = pcall(function()
            if networkRole() == "server" then
                sendServerCommand(player, M.MODULE, "componentsChanged", {})
            elseif type(M.clientComponentsChanged) == "function" then M.clientComponentsChanged(player) end
        end)
        if notified then componentPublications[player] = nil return true end
    end
    M.logOnce("component-publish:" .. playerId(player),
        "component reset committed; field publication pending (bounded retries, no item deletion)")
    return false
end

local function clearComponentNativeMountTx(tx, player, slot, item)
    local oldType, oldIndex, oldModel = item:getAttachedSlotType(), item:getAttachedSlot(), item:getAttachedToModel()
    if oldType == slot then
        -- Clear the exact native visual mapping, including per-item profiles.
        -- A newer vanilla attachment in an unrelated slot is never touched.
        local location = oldModel or M.resolveAttachedLocation(slot, item)
        local mapped = location and player:getAttachedItem(location) or nil
        if mapped == item then
            local ok, reason = setAttachedItemTx(tx, player, location, nil, item)
            if not ok then return false, reason end
        else
            M.addUndo(tx, function()
                item:setAttachedSlot(oldIndex); item:setAttachedSlotType(oldType); item:setAttachedToModel(oldModel)
                return true
            end)
            item:setAttachedSlot(-1); item:setAttachedSlotType(nil); item:setAttachedToModel(nil)
            M.markItemDirty(tx, item)
        end
    end
    return setAttachmentVisualTx(tx, item, false)
end

local function commitComponentReset(tx)
    -- The reversible phase ends BEFORE the first packet. Failed publication
    -- retries current authoritative fields, never rolls back a published link.
    if #tx.networkOps ~= 0 then return M.abortTransaction(tx, "unexpected-item-move") end
    tx.undos = {}
    local pending = componentPublications[tx.player]
    if not pending then
        pending = M.newTransaction(tx.player)
        pending.attempts = 0
        componentPublications[tx.player] = pending
    end
    for item in pairs(tx.dirtyItems) do pending.dirtyItems[item] = true end
    pending.equipDirty = pending.equipDirty or tx.equipDirty
    pending.attempts = 0
    return true
end

function M.resetComponentParent(player, parent, snapshot)
    if networkRole() == "client" then return false, "not-authoritative" end
    if not player or not parent or not M.isParent(parent) then return false, "invalid-parent" end
    snapshot = snapshot or M.inventorySnapshot(player)
    if M.findById(player, parent:getID(), snapshot) ~= parent then return false, "parent-not-present" end
    local md, pouches, mounts = parent:getModData(), {}, {}
    local used = {}
    for key, fixed in pairs(M.FIXED_POUCH) do
        local id = tonumber(md["MLO_module_" .. key])
        if md["MLO_module_" .. key] ~= nil and not id then return false, "invalid-pocket-id" end
        if id then
            local item = M.findById(player, id, snapshot)
            if not item or used[id] or M.fullType(item) ~= fixed.fullType
                or not item:IsInventoryContainer() or item:getInventory():getContainingItem() ~= item then
                return false, "pocket-missing-or-conflicting"
            end
            local child = item:getModData()
            if tonumber(child.MLO_parentId) ~= tonumber(parent:getID()) or child.MLO_moduleKey ~= key then
                return false, "pocket-owner-conflict"
            end
            used[id] = true
            pouches[#pouches+1] = {item=item, key=key}
        end
    end
    for _, slot in ipairs(M.SLOT_ORDER) do
        local id = M.getPersistentMountId(parent, slot)
        if md[M.mountField(slot)] ~= nil and not id then return false, "invalid-mount-id" end
        if id then
            local item = M.findById(player, id, snapshot)
            if not item or used[id] then return false, "mount-missing-or-conflicting" end
            local child = item:getModData()
            if tonumber(child.MLO_mountParentId) ~= tonumber(parent:getID()) or child.MLO_mountSlotId ~= slot then
                return false, "mount-owner-conflict"
            end
            used[id] = true
            mounts[#mounts+1] = {item=item, slot=slot}
        end
    end
    for _, item in ipairs(snapshot.items) do
        local child = item:getModData()
        if (tonumber(child.MLO_parentId) == tonumber(parent:getID())
            or tonumber(child.MLO_mountParentId) == tonumber(parent:getID())) and not used[tonumber(item:getID())] then
            return false, "unresolved-child-relation"
        end
    end
    local tx = M.newTransaction(player)
    local staged, failure = pcall(function()
        for _, pouch in ipairs(pouches) do
            local ok, reason = setModuleWornTx(tx, player, pouch.item, pouch.key, false)
            if not ok then error(M.localize(reason)) end
            ok, reason = unlinkModuleStateTx(tx, parent, pouch.item, pouch.key)
            if not ok then error(M.localize(reason)) end
            setParentFieldTx(tx, pouch.item, "MLO_detachedPouch", true)
            setParentFieldTx(tx, pouch.item, "MLO_nameKey", M.MODULE_NAME_KEY[pouch.key])
        end
        for _, mount in ipairs(mounts) do
            local cleared, clearReason = clearComponentNativeMountTx(tx, player, mount.slot, mount.item)
            if not cleared then error(M.localize(clearReason)) end
            local ok, reason = M.clearPersistentMountTx(tx, player, parent, mount.slot, mount.item)
            if not ok then error(M.localize(reason)) end
        end
        for _, key in ipairs(M.UPGRADE_ORDER[M.groupOf(parent)] or {}) do
            setParentFieldTx(tx, parent, "MLO_up_" .. key, nil)
        end
        setParentFieldTx(tx, parent, "MLO_nameKey", nil)
        setParentFieldTx(tx, parent, "MLO_group", nil)
        setParentFieldTx(tx, parent, "MLO_version", nil)
        setParentFieldTx(tx, parent, "MLO_componentGeneration", M.componentGeneration(parent))
        local name, custom = parent:getDisplayName(), parent:isCustomName()
        M.addUndo(tx, function() parent:setName(name) parent:setCustomName(custom) return true end)
        parent:setName(safeCall(function() return parent:getScriptItem():getDisplayName() end, M.fullType(parent)))
        parent:setCustomName(false)
        local ok, reason = ensureAttachmentsProvidedTx(tx, parent)
        if not ok then error(M.localize(reason)) end
    end)
    if not staged then return M.abortTransaction(tx, tostring(failure)) end
    return commitComponentReset(tx)
end

local function parentHasComponentState(parent)
    local md = parent:getModData()
    for _, key in ipairs(M.UPGRADE_ORDER[M.groupOf(parent)] or {}) do
        if md["MLO_up_" .. key] ~= nil then return true end
    end
    for key in pairs(M.FIXED_POUCH) do if md["MLO_module_" .. key] ~= nil then return true end end
    for _, slot in ipairs(M.SLOT_ORDER) do if M.getPersistentMountId(parent, slot) then return true end end
    return false
end

function M.reconcileComponents(player, snapshot)
    if networkRole() == "client" then return true, false end
    if not player then return false, false end
    local _, errorReason = M.observeComponentOptions()
    if errorReason then return false, false end
    if not M.hasComponentDisableHistory then return true, false end
    snapshot = snapshot or M.inventorySnapshot(player)
    local changed, complete = false, true
    for _, parent in ipairs(snapshot.parents or {}) do
        local outdated = (tonumber(parent:getModData().MLO_componentGeneration) or 0) < M.componentGeneration(parent)
        if (not M.componentEnabled(parent) or outdated) and parentHasComponentState(parent) then
            local ok, reason = M.resetComponentParent(player, parent, snapshot)
            if ok then changed = true else
                complete = false
                M.logOnce("component-reset:" .. itemId(parent) .. ":" .. tostring(reason),
                    "component reset deferred: " .. tostring(reason) .. "; exact items retained")
            end
        end
    end
    if not M.flushComponentPublications(player, true) then complete = false end
    return complete, changed
end

function M.clearComponentPlayerState(player)
    componentPublications[player] = nil
end

print("[MercenaryLoadout] shared loaded "..M.VERSION.." build "..tostring(M.BUILD))
