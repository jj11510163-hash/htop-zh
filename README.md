# htop 中文化（htop-zh）

给 [htop](https://github.com/htop-dev/htop) 3.4.1 的界面加上简体中文，并解决中文宽字符（一个汉字占 2 个终端列）导致的表格错位问题。

> 上游 htop 没有 gettext / 多语言机制（[htop-dev/htop#966](https://github.com/htop-dev/htop/issues/966) 至今 open），界面文字全部硬编码在 C 源码里，所以只能通过补丁实现。

## 效果

主界面：

```
    0[     0.0%]   4[     0.0%]  8[     0.0%] 12[     0.0%]  16[     0.0%]
  内存[||||                                     250M/15.4G] 任务: 10, 2 线程, 0 内核线程；1 运行中
  交换[                                           0K/4.00G] 负载均值: 1.70 0.72 0.27
                                                             运行: 00:04:49

  [Main] [I/O]
  PID 用户名     PRI  NI  虚拟  常驻  共享 S  CPU%▽MEM%  时间+  命令
    1 root        20   0  1804  1180  1104 S   0.0  0.0  0:00:01 /init

F1帮助  F2设置  F3搜索  F4筛选  F5树形  F6排序  F7升优先F8降优先F9结束  F10退出
```

F2 设置页：

```
  [Setup]
分类             显示选项
显示选项         当前屏幕标签: Main
顶部布局         [ ]    树视图
仪表             [ ]    - 树视图始终按 PID 排序(htop 2 行为)
屏幕             [ ]    - 默认折叠树视图
配色             全局选项:
                 [x]    显示屏幕标签
                 [ ]    淡化其他用户的进程
                 [x]    隐藏内核线程
```

F1 帮助页也已整页中文化，更多截图见 [`docs/screenshots/`](docs/screenshots/)。

## 汉化范围

| 已汉化 | 说明 |
|---|---|
| 顶部仪表 | 内存 / 交换 / 任务 / 负载 / 运行时间 / 主机名 / 网络 / 磁盘 IO 等 |
| 进程列表表头 | `PID 用户名 PRI NI 虚拟 常驻 共享 S CPU% MEM% 时间+ 命令` |
| 底部功能键栏 | `F1帮助 … F7升优先 F8降优先 … F10退出` |
| 搜索 / 筛选 | `搜索:`、`筛选:`、`下一个`、`上一个`、`取消`、`完成`、`清除` |
| F1 帮助页 | 整页：图例、进程状态说明、全部快捷键 |
| F2 设置页 | 分类、面板标题、显示选项、顶部布局预设、配色方案、仪表名与样式 |
| 对话框 | 结束进程、优先级/调度策略、CPU 亲和性、用户过滤、排序 |
| 信息页 | 进程跟踪、打开文件、文件锁的标题与提示 |

仍为英文的部分：

- 多核 CPU 仪表的自动名称（如 `CPUs (1-4/8)`，按 CPU 编号动态生成）
- 屏幕标签名 `Main` / `I/O`（用户可改的配置数据）
- 进程命令行、用户名、信号名（`SIGTERM`）、打开文件列表表头 —— 系统数据或通用缩写
- 列名 `PRI`、`NI`、`S`、`CPU%`、`MEM%`：这些字段只有 3~5 列宽，一个汉字占 2 列，塞不下

## 快速开始

### 方式一：直接用编译好的二进制（x86_64 Linux）

从 [Releases](../../releases) 下载静态二进制，然后：

```bash
chmod +x htop-zh-3.4.1-x86_64-static
sudo install -m 755 htop-zh-3.4.1-x86_64-static /usr/local/bin/htop-zh

HTOP_LANG=zh htop-zh          # 中文
HTOP_LANG=en htop-zh          # 英文（原版行为）
```

静态链接（musl），不依赖目标机的 glibc 和 ncurses，拷到任何 x86_64 Linux 都能跑。

### 方式二：从源码编译

```bash
git clone https://github.com/<你的用户名>/htop-zh.git
cd htop-zh
./scripts/build.sh            # 编译动态链接版本
./scripts/build.sh --static   # 编译静态二进制
```

脚本会自动下载 htop 3.4.1 源码、打补丁、执行 `./configure --enable-unicode && make`。
需要 `gcc`、`make`、`ncursesw` 开发包、`autoconf`/`automake`：

```bash
# Debian / Ubuntu
sudo apt install build-essential libncursesw5-dev autoconf automake
# RHEL / CentOS / Fedora
sudo dnf install gcc make ncurses-devel autoconf automake
# Alpine
sudo apk add build-base ncurses-dev autoconf automake
```

也可以手动构建：

```bash
tar xzf htop-3.4.1.tar.gz && cd htop-3.4.1
patch -p1 < ../patch/htop-3.4.1-zh.patch
./autogen.sh && ./configure --enable-unicode && make -j"$(nproc)"
```

## 语言开关

优先级从高到低：

1. `HTOP_LANG=zh` / `HTOP_LANG=en` —— 强制中文或英文；设为 `zh` 时若当前 locale 不是 UTF-8，会自动切到 `C.UTF-8`
2. `LC_ALL` / `LC_CTYPE` / `LANG` 以 `zh` 开头 —— 自动中文
3. 其他情况 —— 保持原版英文界面

## 中文显示要求

- 终端 locale 必须是 UTF-8（`LANG=zh_CN.UTF-8` 或 `C.UTF-8`）
- 终端字体需包含中文字形（Noto Sans Mono CJK、Sarasa Mono SC、文泉驿等），否则显示方块
- SSH 客户端编码也要设成 UTF-8（PuTTY / Xshell / MobaXterm）

## 实现要点

中文是双宽字符，直接把英文替换成中文会让整张表错位，因此补丁不是简单的字符串替换：

- `CRT_strWidth()`：用 `mbrtowc` + `wcwidth` 计算终端**列数**而不是字节数
- `CRT_trans()` / `CRT_transTrim()` / `CRT_transClip()` / `CRT_transPad()`：查表翻译、按列裁剪、按原宽度补空格
- `FunctionBar.c`：功能键栏的 x 推进由 `strlen` 改为 `CRT_strWidth`
- `Meter.c`：仪表标题由固定 3 列改为按译文宽度推进，四种渲染模式都处理
- `Row.c`：列标题保持原宽度，表头点击定位也按列宽计算
- `OptionItem.c` / `Panel.c` / `CategoriesPanel.c` 等：设置页条目在构造时统一翻译
- 全部翻译由 `CRT_isChinese()` 门控，英文环境下行为与原版一致

详细说明见 [`docs/实现说明.md`](docs/实现说明.md)。

## 兼容性

- 补丁针对 **htop 3.4.1**，其他版本上下文可能不匹配
- 预编译二进制为 **x86_64 Linux** 静态链接；ARM 机器请用 `scripts/build.sh` 自行编译
- 已在 Alpine 3.20 (musl) / gcc 13 / ncursesw 6.4 下编译验证，并通过 tmux 抓屏做逐列对齐检查

## 许可

补丁基于 htop 源码修改，遵循 **GNU GPL v2 或更高版本**（与 htop 一致），见 [LICENSE](LICENSE)。
htop 版权归 Hisham Muhammad 与 htop dev team 所有。
