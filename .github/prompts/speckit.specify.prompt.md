---
description: 根据自然语言特性描述创建或更新功能规格说明
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入不为空，你**必须**在继续前先行考虑。

## 执行大纲

触发消息中 `/speckit.specify` 之后的文本**就是**功能描述。即便下方显示为 `$ARGUMENTS` 字面值，也要假设对话里始终可以取得该描述。除非用户的命令为空，否则不要要求对方重复。

基于该功能描述，执行以下步骤：

1. **为分支生成简洁短名**（2-4 个词）：
    - 分析功能描述并提炼最有意义的关键词
    - 创建 2-4 个词的短名，精准概括功能核心
    - 尽量采用“动作-名词”格式（如 `add-user-auth`、`fix-payment-bug`）
    - 保留技术术语与缩写（OAuth2、API、JWT 等）
    - 保持简洁，同时让人一眼理解职责
    - 示例：
       - “我想添加用户登录” → `user-auth`
       - “为 API 实现 OAuth2 集成” → `oauth2-api-integration`
       - “打造一个分析仪表盘” → `analytics-dashboard`
       - “修复支付流程超时漏洞” → `fix-payment-timeout`

2. **在创建新分支前先检查现有分支**：

   a. 首先获取所有远程分支以确保信息最新：
      ```bash
      git fetch --all --prune
      ```

   b. 在所有来源中查找该短名对应的最大特性编号：
      - 远程分支：`git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`
      - 本地分支：`git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`
      - 规格目录：查找匹配 `specs/[0-9]+-<short-name>` 的目录

   c. 确定下一个可用编号：
      - 汇总上述来源中的所有编号
      - 找出最大值 N
      - 新分支编号使用 N+1

   d. 使用计算出的编号与短名运行脚本 `.specify/scripts/powershell/create-new-feature.ps1 -Json "$ARGUMENTS"`：
      - 传入 `--number N+1` 与 `--short-name "your-short-name"` 以及功能描述
      - Bash 示例：`.specify/scripts/powershell/create-new-feature.ps1 -Json "$ARGUMENTS" --json --number 5 --short-name "user-auth" "Add user authentication"`
      - PowerShell 示例：`.specify/scripts/powershell/create-new-feature.ps1 -Json "$ARGUMENTS" -Json -Number 5 -ShortName "user-auth" "Add user authentication"`

   **重要事项**：
   - 必须同时检查三处来源（远程分支、本地分支、规格目录）以找到最大编号
   - 仅匹配短名完全一致的分支/目录
   - 若未找到该短名的现有分支/目录，从编号 1 开始
   - 每个功能只允许运行该脚本一次
   - 终端输出的 JSON 是权威数据来源，务必据此获取所需内容
   - JSON 输出会包含 BRANCH_NAME 与 SPEC_FILE 路径
   - 若参数中含单引号（如 "I'm Groot"），使用转义 `'I'\''m Groot'` 或优先采用双引号

3. 打开 `.specify/templates/spec-template.md` 了解所需各章节。

4. 按以下执行流程开展工作：

    1. 从输入解析功能描述；若为空则报错 “No feature description provided”。
    2. 从描述中提炼关键概念：识别参与者、动作、数据、约束。
    3. 对不明确的内容：
       - 结合上下文与行业惯例给出合理推断。
       - 仅在以下情况添加 `[NEEDS CLARIFICATION: 具体问题]` 标记：
         - 该决策会显著影响功能范围或用户体验；
         - 存在多种合理解释且后果不同；
         - 不存在合理默认值。
       - **限制：最多保留 3 个 `[NEEDS CLARIFICATION]` 标记**。
       - 按影响度排序：范围 > 安全/隐私 > 用户体验 > 技术细节。
    4. 填写 “用户场景与测试” 部分；如无法确定用户流程则报错 “Cannot determine user scenarios”。
    5. 生成功能性需求：确保可测试；对未指明细节使用合理默认值，并在“假设”部分记录。
    6. 定义成功标准：制定可量化且与技术无关的结果；兼顾定量指标（时间、性能、吞吐）与定性指标（用户满意度、任务完成率）；每条标准都必须无需实现细节即可验证。
    7. 若涉及数据，识别关键实体。
    8. 返回：SUCCESS（规格可进入规划阶段）。

5. 按模板结构将规格写入 SPEC_FILE，用功能描述（参数）推导出的具体细节替换占位符，保持章节顺序与标题不变。

6. **规格质量校验**：在完成初稿后，按质量标准进行验证：

   a. **创建规格质量核对单**：使用核对单模板结构，在 `FEATURE_DIR/checklists/requirements.md` 生成文件，并填入以下检查项：

      ```markdown
   # Specification Quality Checklist: [FEATURE NAME]

   **Purpose**: Validate specification completeness and quality before proceeding to planning
   **Created**: [DATE]
   **Feature**: [Link to spec.md]

   ## Content Quality

   - [ ] No implementation details (languages, frameworks, APIs)
   - [ ] Focused on user value and business needs
   - [ ] Written for non-technical stakeholders
   - [ ] All mandatory sections completed

   ## Requirement Completeness

   - [ ] No [NEEDS CLARIFICATION] markers remain
   - [ ] Requirements are testable and unambiguous
   - [ ] Success criteria are measurable
   - [ ] Success criteria are technology-agnostic (no implementation details)
   - [ ] All acceptance scenarios are defined
   - [ ] Edge cases are identified
   - [ ] Scope is clearly bounded
   - [ ] Dependencies and assumptions identified

   ## Feature Readiness

   - [ ] All functional requirements have clear acceptance criteria
   - [ ] User scenarios cover primary flows
   - [ ] Feature meets measurable outcomes defined in Success Criteria
   - [ ] No implementation details leak into specification

   ## Notes

   - Items marked incomplete require spec updates before `/speckit.clarify` or `/speckit.plan`
      ```

   b. **执行校验检查**：逐项比对核对单：
      - 判定每个条目是否通过
      - 记录发现的具体问题（引用规格相关段落）

   c. **处理校验结果**：

      - **若全部通过**：将核对单标记为完成，继续步骤 6。

      - **若存在未通过项（不含 `[NEEDS CLARIFICATION]`）**：
        1. 列出失败条目与对应问题；
        2. 更新规格以逐项修复；
        3. 重新运行校验直至全部通过（最多 3 轮）；
        4. 若 3 轮后仍未通过，将剩余问题记录于核对单备注并告知用户。

      - **若仍存在 `[NEEDS CLARIFICATION]` 标记**：
        1. 从规格中提取所有 `[NEEDS CLARIFICATION: ...]`；
        2. **数量限制**：若超过 3 个，仅保留影响最大的 3 个（按范围/安全或隐私/用户体验排序），其余给出合理推断；
        3. 对每个需澄清的问题（最多 3 个），按以下格式向用户呈现选项：

           ```markdown
           ## Question [N]: [Topic]

           **Context**: [Quote relevant spec section]

           **What we need to know**: [Specific question from NEEDS CLARIFICATION marker]

           **Suggested Answers**:

           | Option | Answer | Implications |
           |--------|--------|--------------|
           | A      | [First suggested answer] | [What this means for the feature] |
           | B      | [Second suggested answer] | [What this means for the feature] |
           | C      | [Third suggested answer] | [What this means for the feature] |
           | Custom | Provide your own answer | [Explain how to provide custom input] |

           **Your choice**: _[Wait for user response]_
           ```

        4. **关键 - 表格格式**：确保 Markdown 表格格式正确：
           - 竖线间距统一；
           - 单元格内容两侧留空格，如 `| Content |`；
           - 表头分隔至少 3 个连字符，如 `|--------|`；
           - 在 Markdown 预览中确认渲染正常。
        5. 问题按顺序编号（Q1、Q2、Q3，最多 3 个）。
        6. 在等待回复前一次性展示全部问题。
        7. 等待用户针对所有问题给出选择（例如 “Q1: A, Q2: Custom - [details], Q3: B”）。
        8. 根据用户选择或自定义答案，替换规格中的 `[NEEDS CLARIFICATION]` 标记。
        9. 所有澄清完成后重新执行校验。

   d. **更新核对单**：每轮校验后，将最新的通过/失败状态写回核对单文件。

7. 汇报完成情况：包含分支名、规格文件路径、核对单结果，以及进入下一阶段（`/speckit.clarify` 或 `/speckit.plan`）的准备情况。

**注意**：脚本会负责创建并切换到新分支，并在写入前初始化规格文件。

## 通用指南

## 快速指南

- 聚焦用户需要**什么**以及**为什么**。
- 避免描述如何实现（不要涉及技术栈、API、代码结构）。
- 面向业务干系人撰写，而非开发人员。
- 不要在规格内嵌入任何核对单，相关生成由其他命令负责。

### 章节要求

- **必填章节**：每个功能都必须完成。
- **可选章节**：仅在与该功能相关时加入。
- 若某章节不适用，直接删除，不要保留 “N/A”。

### 面向 AI 生成

在根据用户提示生成此规格时：

1. **做出合理推断**：结合上下文、行业标准与常见模式弥补空白。
2. **记录假设**：将合理默认值写入“假设”部分。
3. **限制澄清项**：最多保留 3 个 `[NEEDS CLARIFICATION]` 标记，仅用于以下关键决策：
   - 结果显著影响功能范围或用户体验；
   - 存在多种合理解释且影响各异；
   - 无法给出合理默认值。
4. **澄清项优先级**：范围 > 安全/隐私 > 用户体验 > 技术细节。
5. **以测试者思维审视**：凡是模糊需求都会在“可测试且明确”核对项下标失败。
6. **常见需澄清领域**（仅在无合理默认值时询问）：
   - 功能范围与边界（是否包含特定用例）；
   - 用户类型与权限（存在多种可能解释时）；
   - 安全/合规要求（涉及法律或财务风险）。

**合理默认值示例**（无需提问）：

- 数据保留：遵循该领域行业标准。
- 性能目标：除非另有说明，沿用常见的 Web/移动应用期望。
- 错误处理：提供友好的提示及合适的回退方案。
- 认证方式：Web 应用默认使用会话或 OAuth2。
- 集成模式：除非说明，默认采用 RESTful API。

### 成功标准指南

成功标准必须满足：

1. **可度量**：包含具体指标（时间、百分比、数量、比率）。
2. **与技术无关**：避免提及框架、语言、数据库或工具。
3. **面向用户**：从用户/业务视角描述结果，而非系统内部实现。
4. **可验证**：无需了解实现细节即可测试或验证。

**良好示例**：

- “用户可在 3 分钟内完成结账”；
- “系统支持 10,000 个并发用户”；
- “95% 的搜索在 1 秒内返回结果”；
- “任务完成率提升 40%”。

**不佳示例**（聚焦实现）：

- “API 响应时间小于 200ms”（过于技术化，可改写为“用户几乎即时看到结果”）；
- “数据库可处理 1000 TPS”（属于实现细节，可改为面向用户的指标）；
- “React 组件渲染高效”（特定框架）；
- “Redis 缓存命中率超过 80%”（特定技术）。
