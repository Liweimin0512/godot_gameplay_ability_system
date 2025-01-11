# GodotGameplayAbilitySystem

[English](README.md) | [简体中文](README.zh-CN.md)

[![Godot v4.4](https://img.shields.io/badge/Godot-v4.3-%23478cbf)](https://godotengine.org/)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-仓库-black?logo=github)](https://github.com/Liweimin0512/GodotGameplayAbilitySystem)
[![Gitee](https://img.shields.io/badge/Gitee-仓库-red?logo=gitee)](https://gitee.com/Giab/GodotGameplayAbilitySystem)

## 💡 简介

基于godot4.x开发的AbilitySystem，旨在提供基于effect树结构的模块化、可扩展、数据驱动且在不同品类游戏中复用的强大能力系统插件.

## ✨ 特性

- [ ] 可组合的技能效果系统(基于effect_node_tree)
- [ ] 灵活的资源管理机制
- [ ] 完整的Buff系统
- [ ] 可扩展的伤害计算系统
- [ ] 多样化的目标选择方式
- [ ] 事件驱动的技能触发机制
- [ ] 基于场景节点树的effect_node_tree编辑功能
- [ ] 通过json文件配置技能效果树

## 🚀 快速开始

1. 克隆或下载本项目
2. 将项目放入你的项目的`addons`目录下作为插件使用
3. 参考`examples`目录下的示例代码来实现你自己的战斗系统

## 📁 项目结构

- docs/                                 插件说明文档
- examples/                             插件示例代码
- icons/                                插件自定义节点图标
- source/
  - core/                             核心代码，包括ability、ability_effect、ability_resource等内容
  - common/                           auto和factory等类实现
  - ability/                          ability派生的skill和buff实现
  - ability_cost/                     bility的消耗相关，你可以继承AbilityCost来实现自己的消耗逻辑
  - ability_cost_resource/            技能消耗资源，派生出生命值、魔法值、怒气值等
  - ability_effect_node/              effect_node相关实现
  - scene/                            插件所需的场景及通用widget实现
  - editor/                           插件effect_node_tree编辑器功能
  - utils/                            通用工具，包括常量、日志处理等
  ability_component.gd                技能系统核心组件，添加在需要技能系统的场景下（比如Character）
  ability_attribute_component.gd      技能属性组件，为技能系统提供属性支持
  ability_resource_component.gd       技能资源组件，为技能系统提供消耗资源支持，依赖ability_component

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE) 进行开源。

### 代码许可

- 本项目的所有代码均基于 MIT 许可证开源
- 你可以自由地使用、修改和分发代码
- 你可以将代码用于商业和非商业项目
- 使用代码时，需要保留原始许可证声明和版权声明

## 🤝 贡献

欢迎贡献！请查看我们的[贡献指南](docs/CONTRIBUTING.cn.md)了解如何提交问题、拉取请求以及参与项目贡献。
