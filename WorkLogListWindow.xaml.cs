using System.Windows;
using System.Windows.Input;
using System.Windows.Media;

namespace PomodoroApp2
{
    public class WorkLogViewModel
    {
        public string DateText { get; set; } = "";
        public string CyclesText { get; set; } = "";
        public string Comment { get; set; } = "";
        public string NextHint { get; set; } = "";
        public bool HasNextHint { get; set; }
        public string StatusText { get; set; } = "";
        public Brush StatusColor { get; set; } = Brushes.Transparent;
        public Brush StatusFg { get; set; } = Brushes.White;
    }

    public partial class WorkLogListWindow : Window
    {
        public WorkLogListWindow(List<WorkLogEntry> logs)
        {
            InitializeComponent();

            if (logs.Count == 0)
            {
                TxtEmpty.Visibility = Visibility.Visible;
                LogList.Visibility  = Visibility.Collapsed;
                return;
            }

            // newest first
            var items = logs
                .OrderByDescending(l => l.Date)
                .Select(l => new WorkLogViewModel
                {
                    DateText   = l.Date.ToString("MM/dd HH:mm"),
                    CyclesText = $"{l.Cycles} cycles",
                    Comment    = string.IsNullOrWhiteSpace(l.Comment) ? "(no notes)" : l.Comment,
                    NextHint   = l.NextHint,
                    HasNextHint = !string.IsNullOrWhiteSpace(l.NextHint),
                    StatusText = l.Completed ? "✔ Done" : "✘ Incomplete",
                    StatusColor = l.Completed
                        ? new SolidColorBrush(Color.FromRgb(0x0F, 0x2A, 0x25))
                        : new SolidColorBrush(Color.FromRgb(0x2A, 0x10, 0x10)),
                    StatusFg = l.Completed
                        ? new SolidColorBrush(Color.FromRgb(0x4E, 0xCD, 0xC4))
                        : new SolidColorBrush(Color.FromRgb(0xE8, 0x5D, 0x50))
                })
                .ToList();

            LogList.ItemsSource = items;
        }

        private void TitleBar_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
                DragMove();
        }

        private void BtnClose_Click(object sender, RoutedEventArgs e) =>
            Close();
    }
}
