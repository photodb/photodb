object FormMoveFilesProgress: TFormMoveFilesProgress
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'FormMoveFilesProgress'
  ClientHeight = 122
  ClientWidth = 446
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    446
    122)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 152
    Top = 87
    Width = 50
    Height = 1
  end
  object BtnCancel: TButton
    Left = 363
    Top = 89
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 0
    OnClick = BtnCancelClick
  end
  object BtnPause: TButton
    Left = 16
    Top = 89
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'BtnPause'
    TabOrder = 1
    Visible = False
  end
  object PnInfo: TPanel
    Left = 0
    Top = 41
    Width = 446
    Height = 40
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelEdges = [beBottom]
    BevelOuter = bvNone
    BiDiMode = bdLeftToRight
    Color = clWhite
    Ctl3D = False
    ParentBiDiMode = False
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 2
    DesignSize = (
      446
      40)
    object PbMain: TProgressBar
      Left = 16
      Top = 10
      Width = 415
      Height = 17
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 0
    end
  end
  object PnCaption: TPanel
    Left = 0
    Top = 0
    Width = 446
    Height = 41
    Align = alTop
    BevelEdges = [beBottom]
    BevelOuter = bvNone
    Color = clGradientActiveCaption
    ParentBackground = False
    TabOrder = 3
    object LbTitle: TLabel
      Left = 16
      Top = 9
      Width = 194
      Height = 19
      Caption = 'Copying 20 items (450 Mb)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LoadingSign1: TLoadingSign
      Left = 8
      Top = 8
      Width = 20
      Height = 20
      Visible = False
      Active = True
      FillPercent = 50
      SignColor = clBlack
      MaxTransparencity = 255
    end
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 408
    Top = 8
  end
  object TmUpdate: TTimer
    OnTimer = TmUpdateTimer
    Left = 360
    Top = 8
  end
end
