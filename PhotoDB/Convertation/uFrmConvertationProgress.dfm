inherited FrmConvertationProgress: TFrmConvertationProgress
  Width = 433
  Height = 361
  ExplicitWidth = 433
  ExplicitHeight = 361
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 417
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Step info'
    WordWrap = True
  end
  object LbCurrentAction: TLabel
    Left = 8
    Top = 72
    Width = 74
    Height = 13
    Caption = 'Current Action:'
  end
  object LbAction: TLabel
    Left = 8
    Top = 91
    Width = 65
    Height = 13
    Caption = 'Creating DB..'
  end
  object Label5: TLabel
    Left = 8
    Top = 136
    Width = 45
    Height = 13
    Caption = 'Time left:'
    Visible = False
  end
  object Progress: TDmProgress
    Left = 8
    Top = 112
    Width = 417
    Height = 18
    Anchors = [akLeft, akTop, akRight]
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
  object InfoListBox: TListBox
    Left = 8
    Top = 152
    Width = 417
    Height = 201
    Style = lbOwnerDrawVariable
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    OnDrawItem = InfoListBoxDrawItem
  end
  object TempProgress: TDmProgress
    Left = 24
    Top = 328
    Width = 100
    Height = 18
    Visible = False
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 304
    Top = 8
  end
  object PasswordTimer: TTimer
    Interval = 100
    OnTimer = PasswordTimerTimer
    Left = 391
    Top = 8
  end
end
