object ActivateForm: TActivateForm
  Left = 439
  Top = 230
  BorderStyle = bsSingle
  Caption = 'Activation'
  ClientHeight = 377
  ClientWidth = 515
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    515
    377)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 211
    Top = 149
    Width = 103
    Height = 13
    Caption = 'Your program code is:'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label2: TLabel
    Left = 211
    Top = 229
    Width = 144
    Height = 13
    Caption = 'Enter here your activation key:'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label3: TLabel
    Left = 211
    Top = 189
    Width = 79
    Height = 13
    Caption = 'Activation name:'
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 8
    Top = 341
    Width = 499
    Height = 1
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
    ExplicitTop = 330
    ExplicitWidth = 524
  end
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 169
    Height = 153
  end
  object LbInfo: TLabel
    Left = 8
    Top = 168
    Width = 169
    Height = 167
    Anchors = [akLeft, akTop, akBottom]
    AutoSize = False
    Caption = 'LbInfo'
    WordWrap = True
    ExplicitHeight = 223
  end
  object EdProgramCode: TEdit
    Left = 211
    Top = 168
    Width = 161
    Height = 21
    BorderStyle = bsNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    Text = '<data>'
  end
  object EdActicationCode: TEdit
    Left = 211
    Top = 245
    Width = 161
    Height = 21
    BorderStyle = bsNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = '0000000000000000'
  end
  object Button2: TButton
    Left = 274
    Top = 278
    Width = 97
    Height = 17
    Caption = 'Set code'
    TabOrder = 2
    OnClick = Button2Click
  end
  object EdUserName: TEdit
    Left = 211
    Top = 205
    Width = 161
    Height = 21
    BorderStyle = bsNone
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Text = 'User'
  end
  object Button3: TButton
    Left = 377
    Top = 278
    Width = 97
    Height = 17
    Caption = 'Get Code'
    TabOrder = 4
    OnClick = Button3Click
  end
  object BtnNext: TButton
    Left = 377
    Top = 347
    Width = 52
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'BtnNext'
    TabOrder = 5
    ExplicitTop = 360
    ExplicitWidth = 77
  end
  object BtnCancel: TButton
    Left = 271
    Top = 347
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 6
    OnClick = BtnCancelClick
    ExplicitLeft = 191
    ExplicitTop = 360
  end
  object BtnFinish: TButton
    Left = 433
    Top = 347
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnFinish'
    TabOrder = 7
    OnClick = BtnFinishClick
    ExplicitLeft = 353
    ExplicitTop = 360
  end
  object BtnPrevious: TButton
    Left = 352
    Top = 347
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Previous'
    TabOrder = 8
    ExplicitLeft = 272
    ExplicitTop = 360
  end
  object HelpTimer: TTimer
    OnTimer = HelpTimerTimer
    Left = 307
    Top = 173
  end
  object HelpTimer2: TTimer
    Enabled = False
    OnTimer = HelpTimer2Timer
    Left = 275
    Top = 173
  end
end
