object DebugScriptForm: TDebugScriptForm
  Left = 258
  Top = 273
  Caption = 'Debug Scripts'
  ClientHeight = 452
  ClientWidth = 619
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 401
    Top = 41
    Height = 411
    ExplicitHeight = 413
  end
  object ListBox1: TListBox
    Left = 0
    Top = 41
    Width = 401
    Height = 411
    Style = lbOwnerDrawVariable
    Align = alLeft
    ItemHeight = 13
    TabOrder = 0
    OnDrawItem = ListBox1DrawItem
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 619
    Height = 41
    Align = alTop
    TabOrder = 1
    object Button1: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Step over'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Trace into'
      TabOrder = 1
      Visible = False
    end
    object Button3: TButton
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Run'
      TabOrder = 2
      Visible = False
    end
  end
  object Panel2: TPanel
    Left = 404
    Top = 41
    Width = 215
    Height = 411
    Align = alClient
    TabOrder = 2
    OnResize = Panel2Resize
    object Panel3: TPanel
      Left = 1
      Top = 369
      Width = 213
      Height = 41
      Align = alBottom
      TabOrder = 0
      object Panel4: TPanel
        Left = 27
        Top = 1
        Width = 185
        Height = 39
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object Button4: TButton
          Left = 104
          Top = 8
          Width = 75
          Height = 25
          Caption = 'Close'
          TabOrder = 0
        end
      end
    end
    object ValueListEditor1: TStringGrid
      Left = 1
      Top = 1
      Width = 213
      Height = 368
      Align = alClient
      ColCount = 2
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
      TabOrder = 1
      OnDblClick = ValueListEditor1DblClick
      OnSelectCell = ValueListEditor1SelectCell
      OnSetEditText = ValueListEditor1SetEditText
      ColWidths = (
        109
        103)
      RowHeights = (
        24
        24)
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 272
    Top = 8
  end
end
