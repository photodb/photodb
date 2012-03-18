inherited FrameFreeManualActivation: TFrameFreeManualActivation
  Height = 320
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitHeight = 320
  object LbManualActivationInfo: TLabel
    Left = 3
    Top = 8
    Width = 310
    Height = 41
    AutoSize = False
    Caption = 'LbManualActivationInfo'
    WordWrap = True
  end
  object MemInfo: TMemo
    Left = 3
    Top = 72
    Width = 310
    Height = 233
    Lines.Strings = (
      'MemInfo')
    TabOrder = 0
  end
  object WlMail: TWebLink
    Left = 3
    Top = 55
    Width = 126
    Height = 13
    Cursor = crHandPoint
    Text = 'photodb@illusdolphin.net'
    OnClick = WlMailClick
    ImageIndex = 0
    IconWidth = 0
    IconHeight = 0
    UseEnterColor = False
    EnterColor = clNavy
    EnterBould = False
    TopIconIncrement = 0
    UseSpecIconSize = True
    HightliteImage = False
    StretchImage = True
    CanClick = True
  end
end
