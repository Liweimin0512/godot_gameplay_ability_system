# GodotGameplayAbilitySystem

[English](README.md) | [简体中文](README.zh-CN.md)

[![Godot v4.3](https://img.shields.io/badge/Godot-v4.3-%23478cbf)](https://godotengine.org/)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black?logo=github)](https://github.com/Liweimin0512/GodotGameplayAbilitySystem)
[![Gitee](https://img.shields.io/badge/Gitee-Repository-red?logo=gitee)](https://gitee.com/Giab/GodotGameplayAbilitySystem)

## 💡 Introduction

An AbilitySystem developed based on Godot 4.x, designed to provide a powerful, modular, extensible, data-driven, and reusable capability system plugin based on an effect tree structure for various types of games.

## ✨ Features

- [ ] Composable skill effect system (based on effect_node_tree)
- [ ] Flexible resource management mechanism
- [ ] Complete Buff system
- [ ] Extensible damage calculation system
- [ ] Diverse target selection methods
- [ ] Event-driven skill triggering mechanism
- [ ] Editing functionality for effect_node_tree based on scene node tree
- [ ] Configuring skill effect trees through JSON files

## 🚀 Quick Start

1. Clone or download this project.
2. Place the project into the `addons` directory of your project to use it as a plugin.
3. Refer to the example code in the `examples` directory to implement your own combat system.

## 📁 Project Structure

- docs/                                 Plugin documentation
- examples/                             Example code for the plugin
- icons/                                Custom node icons for the plugin
- source/
  - core/                             Core code, including content such as ability, ability_effect, and ability_resource
  - common/                           Implementation of classes like auto and factory
  - ability/                          Implementations of skill and buff derived from ability
  - ability_cost/                     Related to ability costs, you can inherit from AbilityCost to implement your own cost logic
  - ability_cost_resource/            Skill cost resources, derived into health, mana, rage, etc.
  - ability_effect_node/              Implementations related to effect_node
  - scene/                            Scenes and common widget implementations required by the plugin
  - editor/                           Editor functionality for the plugin's effect_node_tree
  - utils/                            General utilities, including constants, log processing, etc.
  ability_component.gd                Core component of the skill system, added to scenes that require the skill system (e.g., Character)
  ability_attribute_component.gd      Skill attribute component, providing attribute support for the skill system
  ability_resource_component.gd       Skill resource component, providing cost resource support for the skill system, depends on ability_component


## 📄 License

This project is open-sourced under the [MIT License](LICENSE).

### Code License

- All code in this project is open-sourced under the MIT License
- You are free to use, modify, and distribute the code
- You can use the code in both commercial and non-commercial projects
- When using the code, you must retain the original license and copyright notices

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](docs/CONTRIBUTING.en.md) for details on how to submit issues, pull requests, and contribute to the project.
