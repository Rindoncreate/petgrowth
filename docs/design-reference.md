# 视觉参考与素材说明

## 本轮还原范围

参考 BoopLog 官网公开展示的三个 App 页面，独立实现网页界面与交互：

- [日记截图](https://booplog.cn/assets/shots/zh-journal.jpg)：米白背景、灰橄榄色文字、五层纸卡、右侧贴胶带的照片、底部浮动工具栏。
- [成长时光轴截图](https://booplog.cn/assets/shots/zh-timeline.jpg)：弯曲纵轴、左右交错照片、日期与体重、悬浮记录按钮。
- [体重图截图](https://booplog.cn/assets/shots/zh-weight.jpg)：细折线与空心圆点、成长照片、日期及体重标签。

没有取得或查看 BoopLog 的源代码，也没有在 iPhone 上直接操作其原生 App。还原依据为公开截图，因此不承诺未公开页面或原生交互与其完全一致。本项目名称为「爪记」，不使用 BoopLog 标志或其宠物照片。

## 字体

使用 [Yozai](https://github.com/lxgw/yozai-font) v0.868 Regular，来源为上游正式发布，许可为 SIL Open Font License 1.1。将原始 TTF 转换为 WOFF2 以减少网页加载体积，保留完整字符集。许可证：`web/assets/Yozai-OFL.txt`。

## 示例宠物图片

文件：`web/assets/puppy-growth-v2.png`，透明背景，1280 × 1280，三列两行的六个金毛幼犬姿态。仅用于内置示例。真实照片来自用户主动选择，并保存在当前浏览器。

使用 imagegen 生成并编辑，最终采用第二版。提示词核心约束：

> Photorealistic six growth poses of the same golden retriever puppy in a 3-column, 2-row transparent sprite atlas. Consistent golden fur, soft natural light, no text, no UI, no background and no cast shadows. Each puppy fits inside the central 60% of its own cell with at least 20% transparent padding on every side. No animal crosses a cell boundary; no adjacent puppy fragments. Preserve six distinct sitting, standing and lying poses.

第二版对第一版进行重新构图，扩大透明留白，避免 CSS 分格显示时露出相邻宠物。此图片已带透明背景，不代表应用已实现自动抠图。

## 当前页面截图

- [日记](screenshots/journal.png)
- [成长时光轴](screenshots/growth-timeline.png)
- [体重折线图](screenshots/growth-chart.png)
