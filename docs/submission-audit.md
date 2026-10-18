# MoonBit 十月赛提交审查

审查日期：2026-10-18。状态是工程自查，不代表赛事审核通过或报名成功。

## 官方依据

- [赛事官网](https://moonbitlang.github.io/Hackathon2026/)
- [正式章程](https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd)，重点为阶段一项目申报、阶段三验收和第七章开源要求。
- [十月报名表](https://bxup9uklfcb.feishu.cn/share/base/form/shrcnWUMlgpbwHaXgzV7HmNhNhg)

官网明确写十月报名与验收截至 10 月 31 日；章程正文仍含 9 月日期，时间表写 10 月 24 日。存在口径不一致，应以赛事群最新通知确认。本项目按提前完成准备执行，不将其中任一日期解释为可以延迟提交的依据。

## 工程交付核对

| 官方要求 | 当前证据与状态 |
| --- | --- |
| 以 MoonBit 为主要实现语言 | 核心、页面与状态均为 `.mbt`；JS 负责宿主浏览器文件接口和构建脚本 |
| 公开仓库和完整源码 | [Rindoncreate/petgrowth](https://github.com/Rindoncreate/petgrowth)，公开 |
| 不少于 10 个有效提交 | 已有超过 10 条真实开发提交，包含基线、缺陷修复、回归测试、示例和 CI；是否符合“有效”由赛方判断 |
| 开发记录可追溯 | 首轮本地开发后公开推送，此后修复与 CI 持续公开；不伪造历史日期 |
| README 与可复现步骤 | 根 README、`docs/demo.md`、`docs/api.md`、`examples/journal/README.md` |
| 可运行示例 | `moon run examples/journal --target js`，实际输出与文档一致 |
| 核心功能测试 | JS 20 项；Wasm 和 Wasm GC 各 18 项；日期、增删、排序、体重、档案、备份、问候、保存失败均覆盖 |
| CI 覆盖检查、构建、测试 | [远端成功记录](https://github.com/Rindoncreate/petgrowth/actions/runs/39096226806)，提交 `90cee57`；后续提交继续运行同一流程 |
| 发布到 Mooncakes | 源码包已通过本地验证，发布状态待注册表确认后更新 |
| OSI 开源许可证 | 项目 MIT；第三方许可见 `web/licenses/NOTICE.txt` 和字体 OFL 文件 |
| 参考范围与 AI 可解释 | `docs/design-reference.md`、`docs/ai-usage.md`；明确公开界面参考、AI 图片和未实现能力 |

## 报名仍需本人完成

参赛者已确认：未参加 8、9 月赛，已经加入本次赛事群。群昵称应为 `Rindoncreate`。

一页 Markdown 申报书必须人工撰写，报名表还要求姓名、联系邮箱、电话、银行卡账号、所属分行以及《参赛诚信承诺书》。个人和银行信息请直接填入官方表单，不写进公开仓库；承诺书由本人阅读和确认。未取得提交成功回执前，不将项目标记为“已报名”。

申报书需要包括项目名称、简介、方向与通用性、至少三个完整预期场景、核心功能、原创或参考情况、来源许可及公开仓库链接。不能以 AI 生成的技术说明替代。

## 明确边界

交付首版为单宠物的日记、照片、体重趋势、本地备份与应用内问候，以及可复用的 MoonBit 核心。多宠物、结构化用药、家人共享、iCloud、自动抠图、后台通知和 App Store 发布仍未实现。Vercel 当前团队访问返回 403，未声称线上部署成功；命令行示例和本地网页不依赖 Vercel。
