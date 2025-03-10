# effects/instant_damage_effect.gd
class_name InstantDamageEffect
extends AbilityEffect

func execute(context: AbilityEffectContext) -> bool:
    if not super.execute(context):
        return false
        
    var damage = effect_params.get("damage", 0.0)
    var damage_type = effect_params.get("damage_type", "physical")
    
    # 直接应用伤害
    if target.has_method("take_damage"):
        target.take_damage(damage, damage_type)
    
    return true
