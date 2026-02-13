using System.Windows;
using System.Windows.Input;

namespace PtoP_Windows_Urversion.Base;

/// <summary>
/// Basis-Fenster mit konfigurierbarer Button-Leiste.
/// Neue Fenster erben von BaseWindow und setzen per XAML die gewünschten Buttons.
/// </summary>
public class BaseWindow : Window
{
    static BaseWindow()
    {
        DefaultStyleKeyProperty.OverrideMetadata(
            typeof(BaseWindow),
            new FrameworkPropertyMetadata(typeof(BaseWindow)));
    }

    public BaseWindow()
    {
        // Style explizit aus Application.Resources laden –
        // DefaultStyleKey allein findet ihn ohne Themes/Generic.xaml nicht.
        SetResourceReference(StyleProperty, typeof(BaseWindow));

        // Chrome-CommandBindings direkt registrieren
        CommandBindings.Add(new CommandBinding(
            SystemCommands.CloseWindowCommand, (_, _) => SystemCommands.CloseWindow(this)));
        CommandBindings.Add(new CommandBinding(
            SystemCommands.MinimizeWindowCommand, (_, _) => SystemCommands.MinimizeWindow(this)));
        CommandBindings.Add(new CommandBinding(
            SystemCommands.MaximizeWindowCommand, (_, _) => SystemCommands.MaximizeWindow(this)));
        CommandBindings.Add(new CommandBinding(
            SystemCommands.RestoreWindowCommand, (_, _) => SystemCommands.RestoreWindow(this)));
    }

    // ───── OK Button ─────

    public static readonly DependencyProperty ShowOkButtonProperty =
        DependencyProperty.Register(nameof(ShowOkButton), typeof(bool), typeof(BaseWindow),
            new PropertyMetadata(true));

    public bool ShowOkButton
    {
        get => (bool)GetValue(ShowOkButtonProperty);
        set => SetValue(ShowOkButtonProperty, value);
    }

    public static readonly DependencyProperty OkButtonTextProperty =
        DependencyProperty.Register(nameof(OkButtonText), typeof(string), typeof(BaseWindow),
            new PropertyMetadata("OK"));

    public string OkButtonText
    {
        get => (string)GetValue(OkButtonTextProperty);
        set => SetValue(OkButtonTextProperty, value);
    }

    public static readonly DependencyProperty OkCommandProperty =
        DependencyProperty.Register(nameof(OkCommand), typeof(ICommand), typeof(BaseWindow));

    public ICommand? OkCommand
    {
        get => (ICommand?)GetValue(OkCommandProperty);
        set => SetValue(OkCommandProperty, value);
    }

    public static readonly DependencyProperty OkButtonToolTipProperty =
        DependencyProperty.Register(nameof(OkButtonToolTip), typeof(object), typeof(BaseWindow));

    public object? OkButtonToolTip
    {
        get => GetValue(OkButtonToolTipProperty);
        set => SetValue(OkButtonToolTipProperty, value);
    }

    // ───── Cancel Button ─────

    public static readonly DependencyProperty ShowCancelButtonProperty =
        DependencyProperty.Register(nameof(ShowCancelButton), typeof(bool), typeof(BaseWindow),
            new PropertyMetadata(true));

    public bool ShowCancelButton
    {
        get => (bool)GetValue(ShowCancelButtonProperty);
        set => SetValue(ShowCancelButtonProperty, value);
    }

    public static readonly DependencyProperty CancelButtonTextProperty =
        DependencyProperty.Register(nameof(CancelButtonText), typeof(string), typeof(BaseWindow),
            new PropertyMetadata("Abbrechen"));

    public string CancelButtonText
    {
        get => (string)GetValue(CancelButtonTextProperty);
        set => SetValue(CancelButtonTextProperty, value);
    }

    public static readonly DependencyProperty CancelCommandProperty =
        DependencyProperty.Register(nameof(CancelCommand), typeof(ICommand), typeof(BaseWindow));

    public ICommand? CancelCommand
    {
        get => (ICommand?)GetValue(CancelCommandProperty);
        set => SetValue(CancelCommandProperty, value);
    }

    public static readonly DependencyProperty CancelButtonToolTipProperty =
        DependencyProperty.Register(nameof(CancelButtonToolTip), typeof(object), typeof(BaseWindow));

    public object? CancelButtonToolTip
    {
        get => GetValue(CancelButtonToolTipProperty);
        set => SetValue(CancelButtonToolTipProperty, value);
    }

    // ───── Delete Button ─────

    public static readonly DependencyProperty ShowDeleteButtonProperty =
        DependencyProperty.Register(nameof(ShowDeleteButton), typeof(bool), typeof(BaseWindow),
            new PropertyMetadata(false));

    public bool ShowDeleteButton
    {
        get => (bool)GetValue(ShowDeleteButtonProperty);
        set => SetValue(ShowDeleteButtonProperty, value);
    }

    public static readonly DependencyProperty DeleteButtonTextProperty =
        DependencyProperty.Register(nameof(DeleteButtonText), typeof(string), typeof(BaseWindow),
            new PropertyMetadata("Löschen"));

    public string DeleteButtonText
    {
        get => (string)GetValue(DeleteButtonTextProperty);
        set => SetValue(DeleteButtonTextProperty, value);
    }

    public static readonly DependencyProperty DeleteCommandProperty =
        DependencyProperty.Register(nameof(DeleteCommand), typeof(ICommand), typeof(BaseWindow));

    public ICommand? DeleteCommand
    {
        get => (ICommand?)GetValue(DeleteCommandProperty);
        set => SetValue(DeleteCommandProperty, value);
    }

    public static readonly DependencyProperty DeleteButtonToolTipProperty =
        DependencyProperty.Register(nameof(DeleteButtonToolTip), typeof(object), typeof(BaseWindow));

    public object? DeleteButtonToolTip
    {
        get => GetValue(DeleteButtonToolTipProperty);
        set => SetValue(DeleteButtonToolTipProperty, value);
    }

    // ───── Footer / Button-Leiste ─────

    public static readonly DependencyProperty ShowButtonBarProperty =
        DependencyProperty.Register(nameof(ShowButtonBar), typeof(bool), typeof(BaseWindow),
            new PropertyMetadata(true));

    public bool ShowButtonBar
    {
        get => (bool)GetValue(ShowButtonBarProperty);
        set => SetValue(ShowButtonBarProperty, value);
    }
}
