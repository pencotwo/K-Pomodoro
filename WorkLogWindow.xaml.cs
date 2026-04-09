using System.Windows;
using System.Windows.Input;

namespace PomodoroApp2
{
    public partial class WorkLogWindow : Window
    {
        public string Comment { get; private set; } = "";
        public string NextHint { get; private set; } = "";
        public bool IsCompleted { get; private set; }

        public WorkLogWindow()
        {
            InitializeComponent();
            TxtDate.Text = DateTime.Now.ToString("yyyy-MM-dd HH:mm");
            TxtComment.Focus();
        }

        private void TitleBar_MouseDown(object sender, MouseButtonEventArgs e)
        {
            if (e.LeftButton == MouseButtonState.Pressed)
                DragMove();
        }

        private void BtnCompleted_Click(object sender, RoutedEventArgs e)
        {
            Comment = TxtComment.Text.Trim();
            NextHint = TxtNextHint.Text.Trim();
            IsCompleted = true;
            DialogResult = true;
        }

        private void BtnIncomplete_Click(object sender, RoutedEventArgs e)
        {
            Comment = TxtComment.Text.Trim();
            NextHint = TxtNextHint.Text.Trim();
            IsCompleted = false;
            DialogResult = true;
        }
    }
}
