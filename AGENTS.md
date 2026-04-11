# Brotato Project

## Project Overview

A Godot 4.6 game project using Forward Plus rendering and Jolt Physics.

## Project Structure

- Godot 4.6 project with Forward Plus rendering
- Jolt Physics for 3D physics
- D3D12 rendering on Windows

## Coding Conventions

- Follow Godot GDScript style guidelines
- Use snake_case for variable and function names
- Use PascalCase for class and enum names

## Build & Run

- Open `project.godot` in Godot 4.6 to run
- Export settings configured for Windows target

## Commands

- `/spec` - 头脑风暴与需求讨论
- `/spec:create <topic>` - 开启新 spec
- `/spec:save` - 归档当前 spec
- `/spec:implement` - 将 spec 转为实施计划
- `/spec:archive <name>` - 归档已完成的 spec
- `/spec:list` - 列出所有 spec
- `/spec:show <name>` - 查看 spec

## Spec 讨论规则

1. spec 期间只讨论设计，**不写代码**
2. **不询问**"是否开始写代码"，只提供方案推荐
3. spec 结束后由 AI 主动发起实现
4. 讨论内容需更新到 `.opencode/requirements/` 下的文档
