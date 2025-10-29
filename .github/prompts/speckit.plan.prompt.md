---
description: 使用计划模板执行实现规划流程并生成设计工件。
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入不为空，你**必须**在继续前先行考虑。

## 流程概览

1. **准备**：在仓库根目录运行 `.specify/scripts/powershell/setup-plan.ps1 -Json` 并解析 JSON，获取 FEATURE_SPEC、IMPL_PLAN、SPECS_DIR、BRANCH。若参数中存在单引号（如 "I'm Groot"），请使用转义写法 'I'\''m Groot'，或尽量使用双引号 "I'm Groot"。

2. **加载上下文**：读取 FEATURE_SPEC 与 `.specify/memory/constitution.md`，并载入已复制的 IMPL_PLAN 模板。

3. **执行计划流程**：按照 IMPL_PLAN 模板结构完成以下事项：
   - 填写技术背景（未知项标记为“NEEDS CLARIFICATION”）
   - 根据宪章填写 Constitution Check 部分
   - 评估各项门槛（若存在未经说明的违反需立即报错）
   - 阶段0：生成 research.md（解决所有 NEEDS CLARIFICATION）
   - 阶段1：生成 data-model.md、contracts/、quickstart.md
   - 阶段1：运行代理脚本更新 agent context
   - 设计完成后再次审视 Constitution Check

4. **停止并汇报**：阶段2规划完成后结束命令，报告分支、IMPL_PLAN 路径以及生成的工件。

## 阶段

### 阶段0：纲要与调研

1. **提取技术背景中的未知项**：
   - 每个 NEEDS CLARIFICATION → 建立调研任务
   - 每个依赖项 → 建立最佳实践任务
   - 每个集成点 → 建立模式研究任务

2. **生成并派发调研代理**：

   ```text
   对技术背景中的每个未知：
     任务："Research {unknown} for {feature context}"
   对每个技术选型：
     任务："Find best practices for {tech} in {domain}"
   ```

3. **整合调研成果**至 `research.md`，格式如下：
   - Decision: [最终选择]
   - Rationale: [选择原因]
   - Alternatives considered: [评估过的备选方案]

**输出**：解决所有 NEEDS CLARIFICATION 的 research.md

### 阶段1：设计与契约

**前置条件：** `research.md` 已完成

1. **从功能规格中提取实体** → `data-model.md`：
   - 实体名称、字段、关系
   - 基于需求的校验规则
   - 若适用，记录状态流转

2. **依据功能需求生成 API 契约**：
   - 每个用户动作 → 对应端点
   - 采用标准 REST/GraphQL 规范
   - 将 OpenAPI/GraphQL 描述输出到 `/contracts/`

3. **更新代理上下文**：
   - 运行 `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`
   - 脚本自动识别当前 AI 代理
   - 更新对应代理的上下文文件
   - 仅添加本次计划中新引入的技术
   - 保留标记之间的手动补充内容

**输出**：data-model.md、/contracts/*、quickstart.md 以及代理上下文文件

## 关键规则

- 始终使用绝对路径
- 若门槛检查失败或仍有未解决的澄清项，必须报错中止
