# FLUFFY羊羊乐 — 项目状态

> 最后更新：2026-11-16 · 版本 **v1.0.0**

## 项目信息

- **仓库**：https://github.com/shizixian/FLUFFY
- **官网**：https://fluffy-idj.pages.dev （Cloudflare Pages 项目 `fluffy`，直传、不连 Git，生产分支 `main`）
  部署时只上传网站用到的文件，**不要上传整个仓库**（仓库里的 `export_presets.cfg` 含签名密码）：
  ```bash
  rm -rf build/site && mkdir -p build/site/assets/tiles
  cp index.html icon.svg screenshot_*_small.png build/site/
  cp assets/tiles/{apple,carrot,grapes,sheep,sun}.svg build/site/assets/tiles/
  wrangler pages deploy build/site --project-name fluffy --branch main
  ```
- **引擎**：Godot 4.6.3 / GDScript
- **分辨率**：720×1280 竖屏基准，`canvas_items` + `expand`，长屏/平板/桌面自动适配
- **渲染**：Compatibility（GLES3）+ `low_processor_mode`，画面不动时不重绘
- **包名**：`com.shizixian.fluffy`（Android）

## v1.0 相对 v0.4 的变化

v1.0 是整体重写，旧版 3000 行的单文件 `main.gd` 拆成了下面的模块结构。

### 玩法
- **真正的叠层**：上层牌错开半格摆放，只要有上层牌和它重叠，这张牌就被压住（旧版只判断正上方同一格）。被压住的牌会变暗；清掉上层后它会轻轻跳一下，提示现在可以点了。
- **11 种布局**，最大 78 张、4 层；牌面从 6 种扩到 12 种，关卡越往后种类越多。第 12 关起，最大的 4 种布局轮换出现（部分镜像）。
- **生成必有解**：从完整棋盘出发模拟一遍通关——每次取两张"此刻可点"的牌赋予同一图案后移除；把这个移除顺序倒过来，就是一条合法的通关路线。洗牌用同一算法，暂存区里的单张也会被考虑进去。
- **道具**：提示 3 / 撤销 3 / 移出 3 / 洗牌 2（旧版洗牌不限次）。没有可配对的牌、道具也用完时，弹出「无路可走」面板（旧版不会失败）。
- 撤销会把「移出后自动配对」连同那次移出一起撤回。
- 星级：平均每对 ≤4 秒三星，≤8 秒两星（旧版是 3.5 / 7 秒）。
- 前两关玩家停顿 9 秒会自动闪一下可消的对子；前三关显示操作提示。

### 表现
- 牌面改为矢量 SVG（`assets/tiles/`，128px 视框，2 倍分辨率导入），UI 图标在 `assets/ui/`。
- 牌在代码里绘制：投影、侧面厚度、选中时抬起并加金边、被压时加暗层。
- 动画：开局发牌、配对的两张牌飞到一起后爆开、得分飘字、连击大字和倒计时条、通关彩带、星星逐个落下、分数滚动增加。
- 音效全部在运行时合成（`scripts/autoload/sound.gd`），不依赖音频文件；分成 Music / SFX 两条总线。手机上配对成功会震动。
- 主菜单沿用原封面图，去掉了重复的标题框；头像缩成圆形，不再遮挡封面上的 Logo。

### 修复的旧问题
- 每日挑战的「今日最佳」以前跨天不清零，现在按日期分开记录（`daily.best_date`）。
- 弹窗不再硬编码 720×1280 坐标，横屏/平板不会错位。
- 只修复了这一个记录 bug，存档本身完全兼容：v0.4 的 `user://player_data.cfg` 键名全部保留，新增 `sfx_volume / sfx_enabled / vibrate / level_best / best_date`，schema 升到 3。

## 真机测试（2026-11-16，华为 P40 / ANA-AN00，Android 10，1080×2340）

已验证：安装和首次启动、个人档案、触摸选牌、配对、点被压住的牌、返回键暂停、切后台后暂停、完整通关、震动、刘海和挖孔避让，日志里没有游戏报错。

真机上发现并修复的问题：
- **震动无效**：导出配置缺少 VIBRATE 权限（日志报 SecurityException）。
- **待机耗电高**：游戏内待机 CPU 约 75%，降到约 14%。做法是换成 Compatibility 渲染器、开启低功耗模式，并把背景云朵改为静止——在 Godot 里画面上有任何一处在动都会触发整屏重绘，仅云朵漂移一项就占了约 20%。
- **长屏封面被放大裁切**：比 9:16 更长的屏幕改为按宽度贴顶显示。
- **长屏棋盘偏小**：最大放大倍数从 1.3 提到 1.6。
- **切后台不暂停**：增加了对 `NOTIFICATION_APPLICATION_PAUSED` 的处理。

## 代码结构

```
scripts/main.gd                 根节点：背景、切换界面、全局弹窗、返回键
scripts/core/layouts.gd         布局定义 + 关卡难度曲线（纯数据）
scripts/core/game_state.gd      规则：可点判定、配对、暂存区、道具、连击、撤销、洗牌、生成器（无节点）
scripts/autoload/save.gd        存档（兼容 v0.4）
scripts/autoload/i18n.gd        三语文案
scripts/autoload/sound.gd       BGM + 合成音效 + 震动
scripts/game/game_screen.gd     一局游戏：HUD、棋盘、点击、动画、通关/卡死弹窗
scripts/game/tile_view.gd       单张牌的绘制
scripts/game/burst.gd           粒子（星星、彩带）
scripts/ui/kit.gd               配色、字体、糖果按钮、通用样式
scripts/ui/modal.gd             弹窗基类
scripts/ui/dialogs.gd           设置 / 关于 / 个人档案
scripts/ui/main_menu.gd         主菜单
scripts/ui/level_select.gd      关卡选择
scripts/ui/{background,bar,star_row,switch}.gd  小组件
tests/run_tests.gd              逻辑测试（headless）
tests/ui_smoke.tscn             UI 冒烟测试（headless，驱动真实界面）
tests/shot_runner.tscn          全界面截图
```

规则逻辑和界面完全分离：`GameState` 不依赖任何节点，测试直接驱动它；`GameScreen` 只负责把状态变化做成动画。

## 开发与测试

```bash
godot --path .                                                  # 运行
godot --headless --path . --import                              # 新克隆后先导入一次
godot --headless --path . --script res://tests/run_tests.gd     # 2235 项检查
godot --headless --path . res://tests/ui_smoke.tscn             # UI 全流程
godot --path . --resolution 360x640 res://tests/shot_runner.tscn -- out=/tmp/fluffy_shots vp=720x1280
```

逻辑测试覆盖：布局无同层重叠且数量为偶数、40 关 × 25 种子共 1000 局全部可解、每日牌面确定性、部分遮挡判定、非法配对、连击倍率与上限、移出/自动配对/撤销联动、槽位配对、洗牌保持牌型且仍可解、卡死判定、星级、v0.4 存档迁移、每日连续天数跨月跨年。

UI 测试和截图脚本都使用独立的存档文件，不会动到真实存档。

## 已知问题 / 后续可做

- 退出时 Godot 会报一条 `ObjectDB instances leaked at exit`（一个音效对象），只出现在关闭程序时，不影响游戏。
- 发布 APK 仍需手动导出。`export_presets.cfg` 含签名密码，在 .gitignore 里，不进仓库；换电脑导出时注意：v1.0 的配置是 1.0.0 / versionCode 6、`permissions/vibrate=true`、只打 arm64，签名证书和 v0.4 相同，可以覆盖升级。
- 官网已于 2026-11-20 部署 v1.0 版本。
- 每日挑战没有排行榜和分享图。
- 背景音乐 `assets/bgm.ogg` 沿用旧版。
