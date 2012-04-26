object PassWordForm: TPassWordForm
  Left = 434
  Top = 286
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'PassWordForm'
  ClientHeight = 447
  ClientWidth = 320
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
  object LbTitle: TLabel
    Left = 8
    Top = 8
    Width = 305
    Height = 33
    AutoSize = False
    Caption = 'Enter password for image here:'
    WordWrap = True
  end
  object LbInfo: TLabel
    Left = 8
    Top = 160
    Width = 305
    Height = 49
    AutoSize = False
    Caption = 'Info...'
    Visible = False
    WordWrap = True
  end
  object BtCancel: TButton
    Left = 160
    Top = 130
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = BtCancelClick
  end
  object BtOk: TButton
    Left = 240
    Top = 130
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 6
    OnClick = BtOkClick
  end
  object CbSavePassToSession: TCheckBox
    Left = 8
    Top = 74
    Width = 305
    Height = 17
    Caption = 'Save Password for all session'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object CbSavePassPermanent: TCheckBox
    Left = 8
    Top = 90
    Width = 305
    Height = 17
    Caption = 'Save Password for in settings (NOT recommend)'
    TabOrder = 2
  end
  object CbDoNotAskAgain: TCheckBox
    Left = 8
    Top = 105
    Width = 305
    Height = 17
    Caption = 'Do not ask again'
    TabOrder = 3
  end
  object BtCancelForFiles: TButton
    Left = 8
    Top = 130
    Width = 145
    Height = 25
    Caption = 'Cancel For:'
    TabOrder = 4
    Visible = False
    OnClick = BtCancelForFilesClick
  end
  object InfoListBox: TListBox
    Left = 8
    Top = 216
    Width = 305
    Height = 193
    Style = lbOwnerDrawVariable
    ItemHeight = 13
    PopupMenu = PmCopyFileList
    TabOrder = 7
    Visible = False
    OnDrawItem = InfoListBoxDrawItem
    OnMeasureItem = InfoListBoxMeasureItem
  end
  object BtHideDetails: TButton
    Left = 8
    Top = 416
    Width = 305
    Height = 25
    Caption = 'Hide Detailes'
    TabOrder = 8
    Visible = False
    OnClick = BtHideDetailsClick
  end
  object EdPassword: TWatermarkedEdit
    Left = 8
    Top = 42
    Width = 305
    Height = 31
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    OnKeyPress = EdPasswordKeyPress
    WatermarkText = 'Enter your password here'
  end
  object PmCopyFileList: TPopupActionBar
    Left = 120
    Top = 248
    object CopyText1: TMenuItem
      Caption = 'Copy Text'
      OnClick = CopyText1Click
    end
  end
  object PmCloseAction: TPopupActionBar
    Left = 160
    Top = 184
    object CloseDialog1: TMenuItem
      Caption = 'Close Dialog'
      OnClick = CloseDialog1Click
    end
    object Skipthisfiles1: TMenuItem
      Caption = 'Skip this files'
      OnClick = Skipthisfiles1Click
    end
  end
end
