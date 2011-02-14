object DBCleaningForm: TDBCleaningForm
  Left = 297
  Top = 198
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Cleaning'
  ClientHeight = 184
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PbMain: TDmProgress
    Left = 8
    Top = 8
    Width = 209
    Height = 18
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
  object CheckBox1: TCheckBox
    Left = 8
    Top = 32
    Width = 209
    Height = 17
    Caption = 'Delete not valid records'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = CbAutoCleaningClick
    OnMouseUp = CbAutoCleaningMouseUp
  end
  object CbDuplicated: TCheckBox
    Left = 8
    Top = 48
    Width = 209
    Height = 17
    Caption = 'Verify dublicates'
    TabOrder = 2
    OnClick = CbAutoCleaningClick
    OnMouseUp = CbAutoCleaningMouseUp
  end
  object CbDeleted: TCheckBox
    Left = 8
    Top = 64
    Width = 209
    Height = 17
    Caption = 'Mark Deleted Files'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = CbAutoCleaningClick
    OnMouseUp = CbAutoCleaningMouseUp
  end
  object CbAutoCleaning: TCheckBox
    Left = 8
    Top = 80
    Width = 209
    Height = 17
    Caption = 'Allow Auto Cleaning'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = CbAutoCleaningClick
    OnMouseUp = CbAutoCleaningMouseUp
  end
  object BtnSave: TButton
    Left = 8
    Top = 136
    Width = 105
    Height = 17
    Caption = 'Save'
    Enabled = False
    TabOrder = 5
    OnClick = BtnSaveClick
  end
  object BntClose: TButton
    Left = 120
    Top = 136
    Width = 99
    Height = 17
    Caption = 'Close'
    TabOrder = 6
    OnClick = BntCloseClick
  end
  object BtnStart: TButton
    Left = 120
    Top = 160
    Width = 99
    Height = 17
    Caption = 'Start Now'
    TabOrder = 7
    OnClick = BtnStartClick
  end
  object BtnStop: TButton
    Left = 8
    Top = 160
    Width = 105
    Height = 17
    Caption = 'Stop Now'
    TabOrder = 8
    OnClick = BtnStopClick
  end
  object CbFastCleaning: TCheckBox
    Left = 8
    Top = 96
    Width = 209
    Height = 17
    Caption = 'Fast Cleaning'
    TabOrder = 9
    OnClick = CbAutoCleaningClick
    OnMouseUp = CbAutoCleaningMouseUp
  end
  object CbFixExifDate: TCheckBox
    Left = 8
    Top = 113
    Width = 209
    Height = 17
    Caption = 'Fix Date and Time'
    Checked = True
    State = cbChecked
    TabOrder = 10
    OnClick = CbAutoCleaningClick
    OnMouseUp = CbAutoCleaningMouseUp
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = True
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 8
    Top = 8
  end
end
