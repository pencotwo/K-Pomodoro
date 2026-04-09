using System.Reflection;
using System.Windows;

namespace PomodoroApp2
{
    public partial class SettingsWindow : Window
    {
        public int SelectedCycles { get; private set; }

        public SettingsWindow(int currentCycles)
        {
            InitializeComponent();
            SliderCycles.Value = currentCycles;
            TxtCycleValue.Text = currentCycles.ToString();
            var v = Assembly.GetExecutingAssembly().GetName().Version;
            TxtVersion.Text = $"v{v?.Major}.{v?.Minor}.{v?.Build}";
        }

        private void SliderCycles_ValueChanged(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (TxtCycleValue != null)
                TxtCycleValue.Text = ((int)SliderCycles.Value).ToString();
        }

        private void BtnOk_Click(object sender, RoutedEventArgs e)
        {
            SelectedCycles = (int)SliderCycles.Value;
            DialogResult = true;
        }

        private void BtnCancel_Click(object sender, RoutedEventArgs e) =>
            DialogResult = false;

        private void BtnClose_Click(object sender, RoutedEventArgs e) =>
            DialogResult = false;
    }
}
