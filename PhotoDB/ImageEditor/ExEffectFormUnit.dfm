object ExEffectForm: TExEffectForm
  Left = 325
  Top = 189
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'ExEffectForm'
  ClientHeight = 340
  ClientWidth = 422
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object BottomPanel: TPanel
    Left = 0
    Top = 299
    Width = 422
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object ButtonPanel: TPanel
      Left = 245
      Top = 0
      Width = 177
      Height = 41
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BtnCancel: TButton
        Left = 6
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Cancel'
        TabOrder = 0
        OnClick = BtnCancelClick
      end
      object BtnOk: TButton
        Left = 94
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Ok'
        TabOrder = 1
        OnClick = BtnOkClick
      end
    end
  end
  object ExEffectPanel: TPanel
    Left = 0
    Top = 0
    Width = 422
    Height = 299
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object SpeedButton1: TSpeedButton
      Left = 8
      Top = 141
      Width = 17
      Height = 17
      Caption = '+'
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 32
      Top = 141
      Width = 17
      Height = 17
      Caption = '-'
      OnClick = SpeedButton2Click
    end
    object Label1: TLabel
      Left = 58
      Top = 146
      Width = 29
      Height = 13
      Caption = '100%'
    end
    object EffectPanel: TGroupBox
      Left = 146
      Top = 6
      Width = 270
      Height = 233
      Caption = 'Effect Name'
      TabOrder = 0
    end
    object CbPreview: TCheckBox
      Left = 146
      Top = 244
      Width = 268
      Height = 17
      Caption = 'Show Prewiew'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = CbPreviewClick
    end
    object OriginalImage: TFastScrollingImage
      Left = 8
      Top = 8
      Width = 129
      Height = 129
      Zoom = 100.000000000000000000
      OnChangePos = OriginalImageChangePos
    end
    object NewImage: TFastScrollingImage
      Left = 8
      Top = 168
      Width = 129
      Height = 129
      Zoom = 100.000000000000000000
      OnChangePos = NewImageChangePos
    end
    object CbTransparent: TCheckBox
      Left = 146
      Top = 262
      Width = 268
      Height = 17
      Caption = 'Layered:'
      TabOrder = 4
      OnClick = CbTransparentClick
    end
    object TbTransparent: TTrackBar
      Left = 144
      Top = 279
      Width = 273
      Height = 17
      Max = 20
      Min = 2
      Position = 2
      TabOrder = 5
      ThumbLength = 10
      OnChange = TbTransparentChange
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 40
    Top = 8
  end
end
