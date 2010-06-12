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
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 305
    Height = 33
    AutoSize = False
    Caption = 'Enter password for image here:'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 8
    Top = 160
    Width = 305
    Height = 49
    AutoSize = False
    Caption = 'Info...'
    Visible = False
    WordWrap = True
  end
  object Edit1: TEdit
    Left = 8
    Top = 42
    Width = 305
    Height = 32
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    OnKeyPress = Edit1KeyPress
  end
  object Button1: TButton
    Left = 160
    Top = 130
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 240
    Top = 130
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 74
    Width = 305
    Height = 17
    Caption = 'Save Password for all session'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object CheckBox2: TCheckBox
    Left = 8
    Top = 90
    Width = 305
    Height = 17
    Caption = 'Save Password for in settings (NOT recommend)'
    TabOrder = 4
  end
  object CheckBox3: TCheckBox
    Left = 8
    Top = 105
    Width = 305
    Height = 17
    Caption = 'Do not ask again'
    TabOrder = 5
  end
  object Button3: TButton
    Left = 8
    Top = 130
    Width = 145
    Height = 25
    Caption = 'Cancel For:'
    TabOrder = 6
    Visible = False
    OnClick = Button3Click
  end
  object InfoListBox: TListBox
    Left = 8
    Top = 216
    Width = 305
    Height = 193
    Style = lbOwnerDrawVariable
    ItemHeight = 13
    PopupMenu = PopupMenu1
    TabOrder = 7
    Visible = False
    OnDrawItem = InfoListBoxDrawItem
    OnMeasureItem = InfoListBoxMeasureItem
  end
  object Button4: TButton
    Left = 8
    Top = 416
    Width = 305
    Height = 25
    Caption = 'Hide Detailes'
    TabOrder = 8
    Visible = False
    OnClick = Button4Click
  end
  object PopupMenu1: TPopupMenu
    Left = 120
    Top = 248
    object CopyText1: TMenuItem
      Caption = 'Copy Text'
      OnClick = CopyText1Click
    end
  end
  object PopupMenu2: TPopupMenu
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
