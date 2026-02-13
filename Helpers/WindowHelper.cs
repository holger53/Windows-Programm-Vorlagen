using System.Windows;
using System.Windows.Input;

namespace PtoP_Windows_Urversion.Helpers;

public static class WindowHelper
{
    public static readonly DependencyProperty EnableCustomChromeProperty =
        DependencyProperty.RegisterAttached(
            "EnableCustomChrome",
            typeof(bool),
            typeof(WindowHelper),
            new PropertyMetadata(false, OnEnableChanged));

    public static bool GetEnableCustomChrome(DependencyObject obj) =>
        (bool)obj.GetValue(EnableCustomChromeProperty);

    public static void SetEnableCustomChrome(DependencyObject obj, bool value) =>
        obj.SetValue(EnableCustomChromeProperty, value);

    private static void OnEnableChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
    {
        if (d is Window w && (bool)e.NewValue)
        {
            w.CommandBindings.Add(new CommandBinding(
                SystemCommands.CloseWindowCommand, (_, _) => SystemCommands.CloseWindow(w)));
            w.CommandBindings.Add(new CommandBinding(
                SystemCommands.MinimizeWindowCommand, (_, _) => SystemCommands.MinimizeWindow(w)));
            w.CommandBindings.Add(new CommandBinding(
                SystemCommands.MaximizeWindowCommand, (_, _) => SystemCommands.MaximizeWindow(w)));
            w.CommandBindings.Add(new CommandBinding(
                SystemCommands.RestoreWindowCommand, (_, _) => SystemCommands.RestoreWindow(w)));
        }
    }
}
