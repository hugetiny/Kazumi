---
description: 执行 tasks.md 中定义的所有任务，落实实现计划
---

## 用户输入

```text
$ARGUMENTS
```

若用户输入不为空，你**必须**在继续前先行考虑。

## 执行大纲

1. 在仓库根目录运行 `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks`，解析输出中的 FEATURE_DIR 与 AVAILABLE_DOCS 列表。所有路径必须为绝对路径。若参数含单引号（如 "I'm Groot"），需使用转义写法 `'I'\''m Groot'`，或尽量改用双引号（"I'm Groot"）。

2. **检查核对单状态**（若存在 `FEATURE_DIR/checklists/`）：
    - 扫描 checklists/ 目录中的所有核对单文件
    - 对每份核对单统计：
       - 全部条目：匹配 `- [ ]`、`- [X]` 或 `- [x]` 的行
       - 已完成条目：匹配 `- [X]` 或 `- [x]` 的行
       - 未完成条目：匹配 `- [ ]` 的行
    - 构造状态表：

     ```text
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```

    - 计算整体状态：
       - **PASS**：所有核对单的未完成项为 0
       - **FAIL**：至少一份核对单存在未完成项

    - **若存在未完成条目**：
       - 展示包含未完成数量的表格
       - **立即停止**并询问：“部分核对单仍未完成。是否仍要继续实施？(yes/no)”
       - 等待用户回应
       - 若用户回答 "no"、"wait" 或 "stop"，终止执行
       - 若用户回答 "yes"、"proceed" 或 "continue"，继续执行步骤 3

    - **若所有核对单均已完成**：
       - 展示全部通过的表格
       - 自动进入步骤 3

3. 加载并分析实现上下文：
   - **必读**：`tasks.md`（完整任务列表与执行计划）
   - **必读**：`plan.md`（技术栈、架构、文件结构）
   - **若存在**：`data-model.md`（实体及关系）
   - **若存在**：`contracts/`（API 规范与测试要求）
   - **若存在**：`research.md`（技术决策与约束）
   - **若存在**：`quickstart.md`（集成场景）

4. **项目初始化校验**：
   - **必做**：根据实际项目情况创建或校验忽略文件：

   **检测与创建逻辑**：
   - 运行以下命令判断仓库是否为 git 仓库（若是则创建/校验 `.gitignore`）：

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - 若存在 Dockerfile* 或 plan.md 中声明使用 Docker → 创建/校验 `.dockerignore`
   - 若存在 `.eslintrc*` 或 `eslint.config.*` → 创建/校验 `.eslintignore`
   - 若存在 `.prettierrc*` → 创建/校验 `.prettierignore`
   - 若存在 `.npmrc` 或 `package.json` → 若需发布则创建/校验 `.npmignore`
   - 若存在 Terraform 文件（*.tf）→ 创建/校验 `.terraformignore`
   - 若需要 `.helmignore`（存在 Helm chart）→ 创建/校验 `.helmignore`

   - **若忽略文件已存在**：确认包含关键模式，仅补足缺失的关键项
   - **若忽略文件缺失**：依据检测到的技术栈创建并写入完整模式集

   **按技术分类的常见忽略模式**（依据 plan.md 中的技术栈）：
   - **Node.js/JavaScript/TypeScript**：`node_modules/`、`dist/`、`build/`、`*.log`、`.env*`
   - **Python**：`__pycache__/`、`*.pyc`、`.venv/`、`venv/`、`dist/`、`*.egg-info/`
   - **Java**：`target/`、`*.class`、`*.jar`、`.gradle/`、`build/`
   - **C# / .NET**：`bin/`、`obj/`、`*.user`、`*.suo`、`packages/`
   - **Go**：`*.exe`、`*.test`、`vendor/`、`*.out`
   - **Ruby**：`.bundle/`、`log/`、`tmp/`、`*.gem`、`vendor/bundle/`
   - **PHP**：`vendor/`、`*.log`、`*.cache`、`*.env`
   - **Rust**：`target/`、`debug/`、`release/`、`*.rs.bk`、`*.rlib`、`*.prof*`、`.idea/`、`*.log`、`.env*`
   - **Kotlin**：`build/`、`out/`、`.gradle/`、`.idea/`、`*.class`、`*.jar`、`*.iml`、`*.log`、`.env*`
   - **C++**：`build/`、`bin/`、`obj/`、`out/`、`*.o`、`*.so`、`*.a`、`*.exe`、`*.dll`、`.idea/`、`*.log`、`.env*`
   - **C**：`build/`、`bin/`、`obj/`、`out/`、`*.o`、`*.a`、`*.so`、`*.exe`、`Makefile`、`config.log`、`.idea/`、`*.log`、`.env*`
   - **Swift**：`.build/`、`DerivedData/`、`*.swiftpm/`、`Packages/`
   - **R**：`.Rproj.user/`、`.Rhistory`、`.RData`、`.Ruserdata`、`*.Rproj`、`packrat/`、`renv/`
   - **通用**：`.DS_Store`、`Thumbs.db`、`*.tmp`、`*.swp`、`.vscode/`、`.idea/`

   **工具特定模式**：
   - **Docker**：`node_modules/`、`.git/`、`Dockerfile*`、`.dockerignore`、`*.log*`、`.env*`、`coverage/`
   - **ESLint**：`node_modules/`、`dist/`、`build/`、`coverage/`、`*.min.js`
   - **Prettier**：`node_modules/`、`dist/`、`build/`、`coverage/`、`package-lock.json`、`yarn.lock`、`pnpm-lock.yaml`
   - **Terraform**：`.terraform/`、`*.tfstate*`、`*.tfvars`、`.terraform.lock.hcl`
   - **Kubernetes/k8s**：`*.secret.yaml`、`secrets/`、`.kube/`、`kubeconfig*`、`*.key`、`*.crt`

5. 解析 `tasks.md` 结构并提取：
   - **任务阶段**：Setup、Tests、Core、Integration、Polish
   - **任务依赖**：顺序与并行执行规则
   - **任务详情**：ID、描述、文件路径、并行标记 [P]
   - **执行流程**：顺序与依赖要求

6. 依照任务计划执行实现：
   - **逐阶段执行**：完成当前阶段后再进入下一阶段
   - **遵循依赖**：顺序任务按既定顺序执行，带 [P] 的任务可并行
   - **按照 TDD**：测试任务需先于对应实现任务
   - **文件协调**：作用于同一文件的任务必须顺序执行
   - **设置验收点**：每个阶段结束前进行验证

7. 实施执行规则：
   - **先做 Setup**：初始化项目结构、依赖与配置
   - **测试优先**：需为契约、实体、集成场景编写测试时，先完成测试
   - **核心开发**：实现模型、服务、CLI 命令、接口等
   - **集成工作**：数据库连接、中间件、日志、外部服务
   - **打磨验证**：单元测试、性能优化、文档

8. 进度追踪与错误处理：
   - 每完成一项任务就汇报一次进度
   - 若任一非并行任务失败，则停止执行
   - 并行任务 [P] 中，成功的继续，失败的需报告
   - 提供明确的错误信息与上下文，便于调试
   - 若无法继续实施，给出后续建议
   - **重要**：完成的任务必须在任务文件中标记为 `[X]`

9. 完成度校验：
   - 确认所有必需任务均已完成
   - 检查已实现功能是否符合原始规格
   - 验证测试通过且覆盖率达标
   - 确认实现遵循技术计划
   - 汇报最终状态并总结已完成工作

注意：此命令假设 `tasks.md` 已包含完整任务拆解。若任务缺失或不完整，请先运行 `/speckit.tasks` 重新生成任务列表。
