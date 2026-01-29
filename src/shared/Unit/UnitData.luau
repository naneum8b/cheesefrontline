local UnitData = {}

UnitData.Stats = {
    ["mouse"] = {
        MaxHealth = 40,
        Damage = 5,
        Armor = 0,
        Range = 2,    
        AttackSpeed = 0.67,
        WalkSpeed = 4,
        ViewRadius = 8,
    },

    ["cheese"] = {
        MaxHealth = 9999,
        Damage = 100,
        Armor = 0,
        Range = 8,
        AttackSpeed = 1,
        WalkSpeed = 0,
        ViewRadius = 8,
    },
    
    ["Occupier"] = {
        MaxHealth = 9999,
        Damage = 0,
        Armor = 250,
        Range = 0,
        AttackSpeed = 0,
        WalkSpeed = 4,
        ViewRadius = 8,
    }
}

function UnitData.GetStats(unitKey)
    return UnitData.Stats[unitKey]
end

return UnitData