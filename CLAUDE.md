# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PomodoroApp2 is a lightweight WPF desktop application implementing the Pomodoro technique — 4 cycles of 25-minute work sessions alternating with 5-minute breaks, tracked via a visual progress bar grid.

**Stack:** C#, WPF, .NET 8.0-Windows. Zero external NuGet packages.

## Build & Run Commands

```bash
# Build
dotnet build

# Run
dotnet run

# Clean build artifacts
dotnet clean

# Publish
dotnet publish
```

Build output goes to `bin/Debug/net8.0-windows/PomodoroApp2.exe`.

No test framework is configured. Testing is manual via the GUI.

## Architecture

The app uses a single-window, code-behind pattern (not formal MVVM).

- **`App.xaml` / `App.xaml.cs`** — Standard WPF app host; `StartupUri` points to `MainWindow.xaml`. No custom initialization.
- **`MainWindow.xaml`** — 400×350 px window with: a large MM:SS timer display, a status label, Start/Reset buttons, and a 4-bar progress grid (one bar per Pomodoro cycle).
- **`MainWindow.xaml.cs`** — All business logic lives here:
  - `_timer` (`DispatcherTimer`, 1-second interval) drives the countdown
  - `_secondsRemaining` holds the current countdown value
  - `_currentCycle` (1–4) and `_isBreak` track where in the sequence the app is
  - `WorkTime = 1500` (25 min), `BreakTime = 300` (5 min)
  - Progress bars are only updated during work periods (not breaks)
  - After 4 complete cycles the timer stops and displays "All Cycles Completed!"

**Session flow:**
```
Work (25m) → Break (5m) → Work (25m) → Break (5m) → Work (25m) → Break (5m) → Work (25m) → Done
  Cycle 1                   Cycle 2                   Cycle 3                   Cycle 4
```

## Key Conventions

- Nullable reference types are enabled — avoid suppressing nullability warnings without good reason.
- Implicit usings are enabled; standard namespaces (`System`, `System.Windows`, etc.) don't need explicit `using` statements.
- Comments in the source may appear in Chinese (Traditional); this is intentional.
