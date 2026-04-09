# K-Pomodoro

A lightweight desktop Pomodoro timer with a clean, minimalist dark UI — built with WPF / .NET 8.

![Platform](https://img.shields.io/badge/platform-Windows-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.0.0-informational)

---

## 中文介紹

K-Pomodoro 是一款輕量級的桌面番茄鐘應用程式，採用極簡深色介面設計。
透過 5 個完整循環（共約 2.5 小時）的番茄工作法，幫助你維持專注、提升生產力。

番茄工作法是一種時間管理技術，將工作切割成固定的專注時段，
並在每段結束後安排短暫休息，讓大腦保持最佳工作狀態。

### 功能特色

- 25 分鐘工作時段 + 5 分鐘休息時段，共 5 個循環
- 大型倒數計時顯示（MM:SS 格式），一目了然
- 每個循環有獨立的進度條，即時顯示完成進度
- 狀態徽章顯示目前模式（工作中 / 休息中 / 已完成）
- 無邊框浮動視窗，可拖曳至螢幕任意位置
- 零依賴安裝，輕量執行不佔資源

### 工作階段流程

```
循環 1：工作 25 分鐘 → 休息 5 分鐘
循環 2：工作 25 分鐘 → 休息 5 分鐘
循環 3：工作 25 分鐘 → 休息 5 分鐘
循環 4：工作 25 分鐘 → 休息 5 分鐘
循環 5：工作 25 分鐘 → 完成！
```

5 個循環全部完成後，畫面顯示「All Cycles Completed!」。

### 使用方法

1. 啟動應用程式後，畫面顯示「Ready to Work」及 25:00 倒數。
2. 按下「▶ Start」按鈕，開始第一個工作時段。
3. 25 分鐘結束後，自動切換為休息模式（5:00）。
4. 休息 5 分鐘結束後，自動進入下一個工作時段。
5. 按下「↺ Reset」按鈕可隨時重置，回到初始狀態。
6. 點擊右上角「✕」關閉應用程式。
7. 拖曳視窗頂部標題列，可將視窗移動至螢幕任意位置。

### 系統需求

- 作業系統：Windows 10 1809（組建 17763）或更新版本
- 架構：x64
- 磁碟空間：約 70 MB

---

## English Description

K-Pomodoro is a lightweight desktop Pomodoro timer with a clean, minimalist dark UI.
It guides you through 5 complete Pomodoro cycles (approximately 2.5 hours total),
helping you stay focused and productive throughout your workday.

The Pomodoro Technique is a time management method that breaks work into focused
intervals separated by short breaks, keeping your mind sharp and energized.

### Features

- 25-minute work sessions + 5-minute breaks, across 5 full cycles
- Large MM:SS countdown display for at-a-glance timing
- Per-cycle progress bars showing real-time completion status
- Status badge indicating the current mode (Working / Break / Completed)
- Borderless floating window — drag anywhere on screen
- Zero dependencies, lightweight and resource-friendly

### Session Flow

```
Cycle 1: Work 25 min  →  Break 5 min
Cycle 2: Work 25 min  →  Break 5 min
Cycle 3: Work 25 min  →  Break 5 min
Cycle 4: Work 25 min  →  Break 5 min
Cycle 5: Work 25 min  →  Done!
```

Once all 5 cycles are complete, the display shows "All Cycles Completed!".

### How to Use

1. Launch the app. The display shows "Ready to Work" with a 25:00 countdown.
2. Click "▶ Start" to begin the first work session.
3. When 25 minutes are up, the app automatically switches to break mode (5:00).
4. After the 5-minute break, the next work session starts automatically.
5. Click "↺ Reset" at any time to reset back to the initial state.
6. Click "✕" in the top-right corner to close the app.
7. Drag the title bar at the top to reposition the window anywhere on screen.

### System Requirements

- OS: Windows 10 version 1809 (Build 17763) or later
- Architecture: x64
- Disk space: ~70 MB

---

## Download

Get the latest installer from the [Files section](https://sourceforge.net/projects/k-pomodoro/files/).

## License

[MIT License](LICENSE.txt) — Copyright (c) 2026 penco

## Tech Stack

- C# / WPF / .NET 8.0-Windows
- Zero external NuGet packages
