using System.Windows;

namespace PtoP_Windows_Urversion.Vorlagen;

public partial class VorlageHauptfenster : Window
{
    public VorlageHauptfenster()
    {
        InitializeComponent();
    }

    private void Beenden_Click(object sender, RoutedEventArgs e)
    {
        Close();
    }
}
