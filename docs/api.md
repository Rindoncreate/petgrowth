# 核心库使用说明

模块为 `Rindoncreate/petgrowth`，根包不依赖 DOM 或浏览器存储。网页应用是该核心的一个使用示例。发布后可通过 `moon add Rindoncreate/petgrowth@0.1.0` 安装，并在调用包的 `moon.pkg` 导入 `"Rindoncreate/petgrowth"`。

| API | 约定 |
| --- | --- |
| `empty_journal()` | 创建空手帐，首个记录编号为 1 |
| `try_set_pet(journal, name, birthday, arrival_day)` | 名字不能为空；日期可留空，否则须为有效 ISO 日期；到家日不能早于生日。失败返回 `None` |
| `set_pet(...)` | 底层档案赋值，裁剪名字两端空白；用户输入应优先使用 `try_set_pet` |
| `set_avatar` / `set_reminders` | 返回更新后的手帐 |
| `add_diary(journal, date, text, photo)` | 日期须有效，文字与照片至少有一项；失败返回 `None` |
| `parse_weight_kg(text)` | 解析 0.001–200 kg，最多三位小数，返回整数克；拒绝符号、指数记法和无效值 |
| `add_weight(journal, date, grams, photo)` | 接收 1–200000 克和有效日期，照片可留空 |
| `diaries_newest_first` | 日期倒序，同日按数字编号倒序，不改变原数组 |
| `weights_oldest_first` | 日期正序，同日按数字编号正序，不改变原数组 |
| `remove_diary` / `remove_weight` | 删除指定编号；不存在的编号不改变内容；后续编号不复用 |
| `format_grams_kg` | 生成不丢失克精度的 kg 显示文本 |
| `encode_journal` / `try_decode_journal` | 完整 JSON 往返；导入时检查记录有效性与编号一致性，错误返回 `None` |
| `decode_journal` | 无效数据回退为空手帐；需要保留错误信息的导入流程请使用 `try_decode_journal` |
| `day_number` | 将公历 `YYYY-MM-DD` 转成连续日编号，日期无效时返回 `None`；不是 Unix 时间戳 |
| `latest_diary_gap` | 相对指定日期计算最近已发生的日记间隔，忽略未来日记 |
| `reminder_text` | 根据档案、提醒开关与日记间隔生成可选文案；当日已记录、无名字或日期无效时不提醒 |

所有编辑函数返回新状态。记录 ID 为共享计数器，跨日记与体重唯一；达到安全上限时拒绝新增。公开结构体方便其他 MoonBit 应用组合，但外部直接构造的状态仍应通过 `try_decode_journal` 校验后导入。

运行完整示例：

```sh
moon update
moon run examples/journal --target js
```

预期输出与逐步操作见 [示例说明](../examples/journal/README.md)。核心负责数据和问候文案；文件选择、照片压缩、持久化及通知投递由宿主应用处理。
