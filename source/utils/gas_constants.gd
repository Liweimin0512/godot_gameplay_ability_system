class_name GASConstants
extends Object

## 常量

## 修改器类型
enum ModifierType {
    ADD,        # 加法修改
    MULTIPLY,   # 乘法修改
    OVERRIDE    # 覆盖修改
}

## 效果类型
enum EffectType {
    INSTANT,    # 即时效果
    DURATION,   # 持续效果
    PERMANENT   # 永久效果
}

## 目标类型
enum TargetType {
    SELF,       # 自身
    SINGLE,     # 单体目标
    MULTIPLE,   # 多个目标
    AREA        # 区域目标
}

## 常用资源类型
const RESOURCE_TYPES = {
    "HEALTH": "生命值",
    "MANA": "魔法值",
    "ENERGY": "能量值",
    "RAGE": "怒气值"
}

## 常用属性类型
const ATTRIBUTE_TYPES = {
    "STRENGTH": "力量",
    "AGILITY": "敏捷",
    "INTELLIGENCE": "智力",
    "VITALITY": "体力",
    "CRITICAL_CHANCE": "暴击几率",
    "CRITICAL_DAMAGE": "暴击伤害",
    "DODGE_CHANCE": "闪避几率",
    "DODGE_REDUCTION": "闪避减免",
    "BLOCK_CHANCE": "格挡几率",
    "BLOCK_REDUCTION": "格挡减免",
    "HEALTH_REGENERATION": "生命恢复",
    "MANA_REGENERATION": "魔法恢复",
    "ENERGY_REGENERATION": "能量恢复",
    "SPEED": "速度",
    "ARMOR": "护甲",
    "RESISTANCE": "抗性",
    "ATTACK_POWER": "攻击力",
    "MAGIC_POWER": "魔法强度",
    "CRIT_RESISTANCE": "暴击抵抗",
    "DODGE_RESISTANCE": "闪避抵抗",
    "BLOCK_RESISTANCE": "格挡抵抗",
    "HEALTH_REGEN_RESISTANCE": "生命恢复抵抗",
    "MANA_REGEN_RESISTANCE": "魔法恢复抵抗",
    "ENERGY_REGEN_RESISTANCE": "能量恢复抵抗",
    "HEALTH_MAX": "生命值",
    "MANA_MAX": "魔法值",
    "ENERGY_MAX": "能量值",
    "HEALTH_REGEN": "生命恢复",
    "MANA_REGEN": "魔法恢复",
    "ENERGY_REGEN": "能量恢复",
    "HEALTH_REGEN_RATE": "生命恢复速率",
    "MANA_REGEN_RATE": "魔法恢复速率",
    "ENERGY_REGEN_RATE": "能量恢复速率",
}