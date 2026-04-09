using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Effects;
using System.Windows.Threading;

namespace PomodoroApp2
{
    // ── 設定資料模型 ─────────────────────────────────────
    public class WorkLogEntry
    {
        [JsonPropertyName("date")]
        public DateTime Date { get; set; }

        [JsonPropertyName("cycles")]
        public int Cycles { get; set; }

        [JsonPropertyName("comment")]
        public string Comment { get; set; } = "";

        [JsonPropertyName("nextHint")]
        public string NextHint { get; set; } = "";

        [JsonPropertyName("completed")]
        public bool Completed { get; set; }
    }

    public class AppSettings
    {
        [JsonPropertyName("cycles")]
        public int Cycles { get; set; } = 5;

        [JsonPropertyName("logs")]
        public List<WorkLogEntry> Logs { get; set; } = new();
    }

    public partial class MainWindow : Window
    {
        private readonly DispatcherTimer _timer;
        private int _secondsRemaining;
        private int _currentCycle = 1;
        private bool _isBreak = false;
        private int _totalCycles = 5;

        private static readonly string SettingsPath =
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                         "PomodoroApp2", "settings.json");

        private const int WorkTime  = 25 * 60;
        private const int BreakTime =  5 * 60;

        // 主題色彩
        private static readonly Color WorkColor    = Color.FromRgb(0xE8, 0x5D, 0x50);
        private static readonly Color BreakColor   = Color.FromRgb(0x4E, 0xCD, 0xC4);
        private static readonly Color WorkBadge    = Color.FromRgb(0x2A, 0x15, 0x15);
        private static readonly Color BreakBadge   = Color.FromRgb(0x0F, 0x22, 0x20);
        private static readonly Color DisabledColor = Color.FromRgb(0x22, 0x22, 0x38);

        private bool _testMode = false;

        private readonly DropShadowEffect _timerGlow = new()
        {
            BlurRadius = 24,
            ShadowDepth = 0,
            Color = WorkColor,
            Opacity = 0.45
        };

        public MainWindow()
        {
            InitializeComponent();
            TxtTimer.Effect = _timerGlow;

            _timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
            _timer.Tick += Timer_Tick;
            _totalCycles = LoadSettings().Cycles;
            ApplyCycleCount();
            ResetTimer();
        }

        // ── 視窗拖曳 / 關閉 ─────────────────────────────────

        private void TitleBar_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.ClickCount == 2) {
                //ToggleTestMode();
            }
            else if (e.LeftButton == MouseButtonState.Pressed)
                DragMove();
        }

        private void ToggleTestMode()
        {
            _testMode = !_testMode;
            _timer.Interval = _testMode
                ? TimeSpan.FromSeconds(1.0 / 60)
                : TimeSpan.FromSeconds(1);
            TxtTitle.Text      = _testMode ? "K-POMODORO  ⚡ TEST" : "K-POMODORO";
            TxtTitle.Foreground = _testMode
                ? new SolidColorBrush(Color.FromRgb(0xFF, 0xC0, 0x40))
                : new SolidColorBrush(Color.FromRgb(0x70, 0x70, 0xA0));
        }

        // ── 循環數套用 ───────────────────────────────────────

        private void ApplyCycleCount()
        {
            _currentCycle = 1;
            _isBreak = false;
            BtnStart.IsEnabled = true;
            BtnStart.Background = new SolidColorBrush(WorkColor);

            var bars = new[] { Bar1, Bar2, Bar3, Bar4, Bar5, Bar6, Bar7, Bar8 };
            for (int i = 0; i < bars.Length; i++)
            {
                bars[i].Value = 0;
                bars[i].Visibility = i < _totalCycles ? Visibility.Visible : Visibility.Collapsed;
            }
            CyclesGrid.Columns = _totalCycles;
        }

        private void BtnClose_Click(object sender, RoutedEventArgs e) =>
            Application.Current.Shutdown();

        private void BtnSettings_Click(object sender, RoutedEventArgs e)
        {
            if (_timer.IsEnabled) return;
            var dlg = new SettingsWindow(_totalCycles) { Owner = this };
            if (dlg.ShowDialog() == true)
            {
                _totalCycles = dlg.SelectedCycles;
                var s = LoadSettings();
                s.Cycles = _totalCycles;
                SaveSettings(s);
                ApplyCycleCount();
                ResetTimer();
                ApplyTheme(isBreak: false);
            }
        }

        // ── 計時器邏輯 ───────────────────────────────────────

        private void Timer_Tick(object? sender, EventArgs e)
        {
            if (_secondsRemaining > 0)
            {
                _secondsRemaining--;
                UpdateDisplay();
                UpdateProgressBar();
            }
            else
            {
                SwitchSession();
            }
        }

        private void SwitchSession()
        {
            if (!_isBreak)
            {
                if (_currentCycle >= _totalCycles)
                {
                    _timer.Stop();
                    TxtStatus.Text = "All Cycles Completed!";
                    ShowWorkLogDialog();
                    return;
                }
                _isBreak = true;
                _secondsRemaining = BreakTime;
                TxtStatus.Text = $"Break Time  (Cycle {_currentCycle})";
                ApplyTheme(isBreak: true);
            }
            else
            {
                _isBreak = false;
                _currentCycle++;
                _secondsRemaining = WorkTime;
                TxtStatus.Text = $"Work Time  (Cycle {_currentCycle})";
                ApplyTheme(isBreak: false);
            }
        }

        private void UpdateDisplay()
        {
            TxtTimer.Text = TimeSpan.FromSeconds(_secondsRemaining).ToString(@"mm\:ss");
        }

        private void UpdateProgressBar()
        {
            if (_isBreak) return;
            double progress = (1 - (double)_secondsRemaining / WorkTime) * 100;
            var bars = new[] { Bar1, Bar2, Bar3, Bar4, Bar5, Bar6, Bar7, Bar8 };
            if (_currentCycle >= 1 && _currentCycle <= bars.Length)
                bars[_currentCycle - 1].Value = progress;
        }

        private void BtnStart_Click(object sender, RoutedEventArgs e)
        {
            _timer.Start();
            TxtStatus.Text = _isBreak ? "Resting..." : "Focusing...";
            BtnStart.IsEnabled  = false;
            BtnStart.Background = new SolidColorBrush(DisabledColor);
        }

        private void BtnReset_Click(object sender, RoutedEventArgs e)
        {
            _timer.Stop();
            _currentCycle = 1;
            _isBreak = false;
            _testMode = false;
            _timer.Interval    = TimeSpan.FromSeconds(1);
            TxtTitle.Text      = "K-POMODORO";
            TxtTitle.Foreground = new SolidColorBrush(Color.FromRgb(0x70, 0x70, 0xA0));
            BtnStart.IsEnabled = true;
            ResetTimer();
            Bar1.Value = Bar2.Value = Bar3.Value = Bar4.Value = Bar5.Value =
            Bar6.Value = Bar7.Value = Bar8.Value = 0;
            ApplyTheme(isBreak: false);
        }

        private void ResetTimer()
        {
            _secondsRemaining = WorkTime;
            UpdateDisplay();
            TxtStatus.Text = "Ready to Work";
        }

        // ── 設定檔讀寫 ───────────────────────────────────────

        private static readonly JsonSerializerOptions JsonOpts =
            new() { WriteIndented = true };

        private static AppSettings LoadSettings()
        {
            try
            {
                if (File.Exists(SettingsPath))
                {
                    var s = JsonSerializer.Deserialize<AppSettings>(
                                File.ReadAllText(SettingsPath), JsonOpts);
                    if (s != null)
                    {
                        s.Cycles = Math.Clamp(s.Cycles, 2, 8);
                        return s;
                    }
                }
            }
            catch { }
            return new AppSettings();
        }

        private static void SaveSettings(AppSettings settings)
        {
            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(SettingsPath)!);
                File.WriteAllText(SettingsPath, JsonSerializer.Serialize(settings, JsonOpts));
            }
            catch { }
        }

        // ── 工作日誌 ─────────────────────────────────────────

        private void BtnWorkLog_Click(object sender, RoutedEventArgs e)
        {
            var logs = LoadSettings().Logs;
            new WorkLogListWindow(logs) { Owner = this }.ShowDialog();
        }

        private void ShowWorkLogDialog()
        {
            var dlg = new WorkLogWindow { Owner = this };
            if (dlg.ShowDialog() == true)
            {
                var s = LoadSettings();
                s.Logs.Add(new WorkLogEntry
                {
                    Date = DateTime.Now,
                    Cycles = _totalCycles,
                    Comment = dlg.Comment,
                    NextHint = dlg.NextHint,
                    Completed = dlg.IsCompleted
                });
                SaveSettings(s);
            }
        }

        // ── 主題切換 ─────────────────────────────────────────

        private void ApplyTheme(bool isBreak)
        {
            var accent = isBreak ? BreakColor : WorkColor;
            BadgeBorder.Background = new SolidColorBrush(isBreak ? BreakBadge : WorkBadge);
            TxtStatus.Foreground   = new SolidColorBrush(accent);
            _timerGlow.Color       = accent;
            if (BtnStart.IsEnabled)
                BtnStart.Background = new SolidColorBrush(accent);
        }
    }
}
