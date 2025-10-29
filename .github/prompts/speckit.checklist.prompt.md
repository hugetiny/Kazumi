---
description: 根据用户需求为当前功能生成自定义检查清单。
---

## 检查清单的目的：“英语版单元测试”

**核心概念**：检查清单是**需求写作的单元测试**——用于验证特定领域内需求的质量、清晰度与完整度。

**不用于验证/测试实现**：

- ❌ 不是“验证按钮能否正确点击”
- ❌ 不是“测试错误处理是否正常”
- ❌ 不是“确认 API 返回 200”
- ❌ 不是核对代码/实现是否符合规格

**用于审视需求质量**：

- ✅ “是否为所有卡片类型定义了视觉层级需求？”（完整性）
- ✅ “‘Prominent display’ 是否通过尺寸/位置明确量化？”（清晰度）
- ✅ “是否对所有交互元素的悬停状态给出了统一要求？”（一致性）
- ✅ “是否定义了键盘导航的可访问性要求？”（覆盖性）
- ✅ “规格是否说明 Logo 图片加载失败时的处理？”（边界情况）

**类比**：如果规格文档是用英语写成的代码，那么检查清单就是它的单元测试套件。我们测试的是需求是否写得好、是否完整、是否无歧义、是否已做好实施准备——而不是实现本身是否可用。

## 用户输入

```text
$ARGUMENTS
```

若用户输入不为空，你**必须**在继续前先行考虑。

## 执行步骤

1. **准备**：在仓库根目录运行 `.specify/scripts/powershell/check-prerequisites.ps1 -Json` 并解析 JSON，获取 FEATURE_DIR 与 AVAILABLE_DOCS 列表。
   - 所有路径必须为绝对路径。
   - 若参数中包含单引号（如 "I'm Groot"），请使用转义写法 'I'\''m Groot'，或尽量改用双引号 "I'm Groot"。

2. **澄清意图（动态）**：生成最多三条初始澄清问题（禁止使用预制题库）。问题必须：
   - 根据用户表述以及从 spec/plan/tasks 中提取的信号生成
   - 仅询问会显著影响检查清单内容的信息
   - 若 `$ARGUMENTS` 已无歧义，则跳过对应问题
   - 更偏向精准而非全面

   生成算法：
   1. 提取信号：功能领域关键词（如 auth、latency、UX、API），风险指示词（“critical”、“must”、“compliance”），干系人信息（“QA”、“review”、“security team”），以及明确交付物（“a11y”、“rollback”、“contracts”）。
   2. 将信号聚类为最多 4 个候选关注区域，并按相关度排序。
   3. 如未明确，推断可能的受众与时间点（作者、自审、评审、发布）。
   4. 识别缺失维度：范围广度、深度/严谨度、风险侧重点、排除边界、可量化验收标准。
   5. 根据以下原型构造问题：
      - 范围细化（例：“是否需要覆盖 X/Y 的集成触点，还是仅限模块本身？”）
      - 风险优先级（例：“这些风险领域中哪些必须设定必过检查？”）
      - 深度校准（例：“这是轻量的提交前自检还是正式的发布闸门？”）
      - 受众定位（例：“这份清单仅供作者使用，还是要用于 PR 评审？”）
      - 边界排除（例：“本轮是否明确排除性能调优相关项？”）
      - 场景类型缺口（例：“未检测到恢复流程——回滚/部分失败是否在范围内？”）

   问题格式规则：
   - 若需给出选项，请生成简洁表格，列为：Option | Candidate | Why It Matters
   - 选项数量最多 A–E；若自由回答更清晰，可不使用表格
   - 不要让用户重复已提供的信息
   - 避免凭空假设（不允许幻觉）。如不确定，直接询问：“请确认 X 是否在范围内。”

   当无法互动时的默认值：
   - 深度：Standard
   - 受众：与代码相关则默认 Reviewer（PR），否则为 Author
   - 聚焦：相关度最高的两个聚类

   输出问题并标记为 Q1/Q2/Q3。若在获得回答后仍有 ≥2 类场景（备用 / 异常 / 恢复 / 非功能领域）不明确，可再追问最多两条（Q4/Q5），每条附一句理由（如：“恢复路径风险未解”）。总问题数不得超过五条。若用户明确拒绝追加问题，则停止追问。

3. **理解用户诉求**：结合 `$ARGUMENTS` 与澄清回答：
   - 提炼检查清单主题（如 security、review、deploy、ux）
   - 汇总用户明确要求纳入的项目
   - 将关注点映射到分类骨架
   - 从 spec/plan/tasks 中推断缺失上下文（禁止凭空捏造）

4. **加载功能上下文**：从 FEATURE_DIR 读取：
   - spec.md：功能需求与范围
   - plan.md（若存在）：技术细节与依赖
   - tasks.md（若存在）：实现任务

   **上下文加载策略**：
   - 仅加载与当前关注领域相关的必要片段（避免整份文档倾倒）
   - 长篇幅内容优先总结为简明的场景/需求要点
   - 采用渐进式披露：只有在发现缺口时才继续检索
   - 若源文档庞大，可生成中间摘要而非嵌入原文

5. **生成检查清单**——打造“需求的单元测试”：
    - 若 `FEATURE_DIR/checklists/` 不存在，先创建该目录
    - 生成唯一的清单文件名：
       - 根据领域使用简短、具描述性的名称（如 `ux.md`、`api.md`、`security.md`）
       - 格式：`[domain].md`
       - 若文件已存在，则在原文件末尾追加
    - 项目编号自 CHK001 起顺序递增
    - 每次运行 `/speckit.checklist` 必须创建一个新文件（不得覆盖既有清单）

    **核心原则——测试需求，而非实现**：
    每条清单项都必须评估需求本身是否满足以下维度：
    - **完整性**：所需需求是否齐全？
    - **清晰度**：需求是否明确且无歧义？
    - **一致性**：需求之间是否相互协调？
    - **可量化性**：需求能否被客观验证？
    - **覆盖性**：是否覆盖所有场景/边界情况？

    **分类结构**——按需求质量维度分组：
    - **Requirement Completeness**（是否记录了全部必要需求？）
    - **Requirement Clarity**（需求是否具体、无歧义？）
    - **Requirement Consistency**（是否不存在相互矛盾？）
    - **Acceptance Criteria Quality**（成功标准是否可量化？）
    - **Scenario Coverage**（是否涵盖所有流程/情境？）
    - **Edge Case Coverage**（是否定义边界条件？）
    - **Non-Functional Requirements**（性能、安全、可访问性等是否明确？）
    - **Dependencies & Assumptions**（依赖与假设是否记录并验证？）
    - **Ambiguities & Conflicts**（哪些内容需要澄清？）

    **如何撰写清单项——“英语版单元测试”**：

    ❌ **错误示范**（测试实现）：
    - “验证登陆页是否展示 3 个剧集卡片”
    - “测试桌面端悬停状态是否生效”
    - “确认点击 Logo 是否返回首页”

    ✅ **正确示范**（测试需求质量）：
    - “是否明确规定了推荐剧集的数量与布局？”【Completeness】
    - “‘Prominent display’ 是否提供具体尺寸/位置的量化指标？”【Clarity】
    - “是否对所有交互元素的悬停状态做了统一规定？”【Consistency】
    - “是否为所有交互界面定义了键盘导航需求？”【Coverage】
    - “Logo 加载失败时的回退行为是否写明？”【Edge Cases】
    - “是否定义了异步剧集数据的加载状态需求？”【Completeness】
   - “规格是否说明多个 UI 元素竞争时的视觉层级？”【Clarity】

    **条目结构**：
    每条目应遵循以下模式：
    - 以问题形式询问需求质量
    - 聚焦于规格/计划中已写明或缺失的内容
    - 在方括号中标注质量维度【Completeness/Clarity/Consistency/…】
    - 检查既有需求时引用规格章节 `[Spec §X.Y]`
    - 检查缺失项时使用 `[Gap]` 标记

    **按质量维度举例**：

    Completeness：
    - “是否为所有 API 失败模式定义了错误处理需求？[Gap]”
    - “是否为所有交互元素指定了可访问性需求？[Completeness]”
    - “是否定义了响应式布局的移动断点需求？[Gap]”

    Clarity：
    - “‘Fast loading’ 是否以具体时限量化？[Clarity, Spec §NFR-2]”
    - “‘Related episodes’ 的筛选标准是否明确？[Clarity, Spec §FR-5]”
    - “‘Prominent’ 是否有可度量的视觉属性定义？[Ambiguity, Spec §FR-4]”

    Consistency：
    - “所有页面的导航需求是否保持一致？[Consistency, Spec §FR-10]”
    - “卡片组件在首页与详情页的需求是否一致？[Consistency]”

    Coverage：
    - “是否定义了零数据场景（无剧集）的需求？[Coverage, Edge Case]”
    - “是否覆盖并发用户交互的场景？[Coverage, Gap]”
    - “是否定义了部分数据加载失败时的需求？[Coverage, Exception Flow]”

    Measurability：
    - “视觉层级需求是否可量化/可验证？[Acceptance Criteria, Spec §FR-1]”
    - “‘Balanced visual weight’ 能否客观验证？[Measurability, Spec §FR-2]”

    **场景分类与覆盖**（聚焦需求质量）：
    - 检查是否覆盖：主流程、备用流程、异常/错误、恢复、非功能场景
    - 对每类场景提问：“该场景的需求是否完整、清晰、一致？”
    - 若缺失某类场景：“该场景的需求是刻意排除还是缺失？[Gap]”
    - 涉及状态变更时加入韧性/回滚：“是否定义迁移失败的回滚需求？[Gap]”

    **可追溯性要求**：
    - 至少 80% 条目必须包含可追溯引用
    - 每条应引用规格章节 `[Spec §X.Y]`，或使用 `[Gap]`、`[Ambiguity]`、`[Conflict]`、`[Assumption]`
    - 若不存在 ID 体系：“是否已建立需求与验收标准的编号方案？[Traceability]”

    **暴露并解决问题**（需求质量缺陷）：
    围绕需求本身提问：
    - 歧义：“‘Fast’ 是否以具体指标量化？[Ambiguity, Spec §NFR-1]”
    - 冲突：“§FR-10 与 §FR-10a 的导航需求是否冲突？[Conflict]”
    - 假设：“‘Podcast API 始终可用’ 的假设是否得到验证？[Assumption]”
    - 依赖：“外部 Podcast API 的需求是否记录？[Dependency, Gap]”
    - 缺少定义：“‘Visual hierarchy’ 是否具备量化标准？[Gap]”

    **内容整合**：
    - 软上限：候选条目超过 40 条时，按风险/影响优先级筛选
    - 合并针对同一需求面的近似重复项
    - 若存在 5 条以上影响较小的边界情况，可合并为“需求是否涵盖边界情况 X/Y/Z？[Coverage]”

    **🚫 严禁事项**——这些会变成实现测试而非需求测试：
    - ❌ 以 “Verify/Test/Confirm/Check + 行为” 开头的实现验证
    - ❌ 提及代码执行、用户操作、系统行为
    - ❌ “显示正确”、“运行正常”、“按预期工作”
    - ❌ “Click”、“navigate”、“render”、“load”、“execute” 等操作词
    - ❌ 测试用例、测试计划、QA 流程
    - ❌ 实现细节（框架、API、算法）

    **✅ 必须遵循的模式**——用于检验需求质量：
    - ✅ “是否为 [场景] 定义/记录了 [需求类型]？”
    - ✅ “是否用具体标准量化/澄清了 [模糊术语]？”
    - ✅ “需求在 [章节 A] 与 [章节 B] 中是否保持一致？”
    - ✅ “[需求] 能否被客观测量/验证？”
    - ✅ “需求是否覆盖了 [边界情况/场景]？”
    - ✅ “规格是否定义了 [缺失的方面]？”

6. **结构参考**：生成检查清单时遵循 `.specify/templates/checklist-template.md` 里的标准模板，包括标题、元信息、分类标题与 ID 格式。若模板不可用，则使用：一级标题、用途/创建说明、二级分类标题（如 “## 分类名称”），并在分类下以 `- [ ] CHK### <requirement item>` 列出条目，ID 从 CHK001 全局递增。

7. **汇报**：输出新建检查清单的完整路径与条目数量，并提醒用户每次运行都会生成新的文件。摘要说明：
   - 所选关注领域
   - 深度等级
   - 目标角色/时间点
   - 已纳入的用户明确诉求

**重要提示**：每次调用 `/speckit.checklist` 都会创建一个使用简短描述性名称的新清单文件（若同名文件已存在则附加内容）。这样可以：

- 维护多份不同类型的清单（例如 `ux.md`、`test.md`、`security.md`）
- 通过易记文件名明确清单用途
- 在 `checklists/` 目录中快速定位

为避免目录杂乱，请使用具描述性的类型名称，并在完成后清理过期清单。

## 示例清单类型与样例条目

**UX 需求质量：** `ux.md`

示例条目（测试需求，而非实现）：

- “视觉层级需求是否具有可度量准则？[Clarity, Spec §FR-1]”
- “UI 元素的数量及位置是否明确规定？[Completeness, Spec §FR-1]”
- “交互状态（悬停、焦点、激活）需求是否一致？[Consistency]”
- “是否为全部交互元素定义可访问性要求？[Coverage, Gap]”
- “图片加载失败时的回退行为是否写明？[Edge Case, Gap]”
- “‘Prominent display’ 能否客观测量？[Measurability, Spec §FR-4]”

**API 需求质量：** `api.md`

示例条目：

- “是否为所有失败场景规定错误响应格式？[Completeness]”
- “限流需求是否以明确阈值量化？[Clarity]”
- “所有端点的认证需求是否一致？[Consistency]”
- “外部依赖的重试/超时需求是否定义？[Coverage, Gap]”
- “需求中是否记录版本策略？[Gap]”

**性能需求质量：** `performance.md`

示例条目：

- “性能需求是否以具体指标量化？[Clarity]”
- “是否为关键用户路径设定性能目标？[Coverage]”
- “不同负载下的性能需求是否明确？[Completeness]”
- “性能需求能否被客观测量？[Measurability]”
- “高负载场景的降级需求是否定义？[Edge Case, Gap]”

**安全需求质量：** `security.md`

示例条目：

- “是否为所有受保护资源定义认证需求？[Coverage]”
- “敏感信息的数据保护需求是否明确？[Completeness]”
- “威胁模型是否记录，并与需求对齐？[Traceability]”
- “安全需求是否符合合规义务？[Consistency]”
- “是否定义安全故障/泄露的响应需求？[Gap, Exception Flow]”

## 反例：不该做什么

**❌ 错误示例——这些在测试实现而非需求：**

```markdown
- [ ] CHK001 - Verify landing page displays 3 episode cards [Spec §FR-001]
- [ ] CHK002 - Test hover states work correctly on desktop [Spec §FR-003]
- [ ] CHK003 - Confirm logo click navigates to home page [Spec §FR-010]
- [ ] CHK004 - Check that related episodes section shows 3-5 items [Spec §FR-005]
```

**✅ 正确示例——这些在检验需求质量：**

```markdown
- [ ] CHK001 - Are the number and layout of featured episodes explicitly specified? [Completeness, Spec §FR-001]
- [ ] CHK002 - Are hover state requirements consistently defined for all interactive elements? [Consistency, Spec §FR-003]
- [ ] CHK003 - Are navigation requirements clear for all clickable brand elements? [Clarity, Spec §FR-010]
- [ ] CHK004 - Is the selection criteria for related episodes documented? [Gap, Spec §FR-005]
- [ ] CHK005 - Are loading state requirements defined for asynchronous episode data? [Gap]
- [ ] CHK006 - Can "visual hierarchy" requirements be objectively measured? [Measurability, Spec §FR-001]
```

**关键差异：**

- 错误：验证系统是否正常运行
- 正确：验证需求是否写得正确
- 错误：检查行为
- 正确：审视需求质量
- 错误： “是否做到了 X？”
- 正确： “是否清晰地规定了 X？”
