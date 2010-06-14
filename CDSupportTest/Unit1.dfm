object Form1: TForm1
  Left = 57
  Top = 195
  Width = 870
  Height = 600
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 200
    Width = 20
    Height = 13
    Caption = 'Size'
  end
  object Button1: TButton
    Left = 48
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 224
    Top = 8
    Width = 441
    Height = 193
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 48
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Write'
    TabOrder = 2
    OnClick = Button2Click
  end
  object ComboBoxExDB1: TComboBoxExDB
    Left = 224
    Top = 256
    Width = 441
    Height = 22
    ItemsEx = <
      item
        Caption = '\'
      end>
    Style = csExDropDownList
    ItemHeight = 16
    TabOrder = 3
    DropDownCount = 8
    ShowDropDownMenu = True
  end
  object Button3: TButton
    Left = 672
    Top = 256
    Width = 75
    Height = 25
    Caption = 'New folder'
    TabOrder = 4
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 672
    Top = 224
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'Edit1'
  end
  object Button4: TButton
    Left = 224
    Top = 232
    Width = 75
    Height = 25
    Caption = 'UP'
    TabOrder = 6
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 696
    Top = 520
    Width = 75
    Height = 25
    Caption = 'Do Export!'
    TabOrder = 7
  end
  object Edit2: TEdit
    Left = 224
    Top = 208
    Width = 121
    Height = 21
    TabOrder = 8
    Text = 'Edit2'
  end
  object Button6: TButton
    Left = 672
    Top = 352
    Width = 75
    Height = 25
    Caption = 'Delete'
    TabOrder = 9
    OnClick = Button6Click
  end
  object Edit3: TEdit
    Left = 32
    Top = 216
    Width = 121
    Height = 21
    TabOrder = 10
    Text = 'Edit3'
  end
  object Button7: TButton
    Left = 32
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Button7'
    TabOrder = 11
    OnClick = Button7Click
  end
  object Edit4: TEdit
    Left = 16
    Top = 296
    Width = 121
    Height = 21
    TabOrder = 12
    Text = 'c:\'
  end
  object Button8: TButton
    Left = 16
    Top = 272
    Width = 75
    Height = 25
    Caption = 'Save disk!'
    TabOrder = 13
    OnClick = Button8Click
  end
  object ListView1: TListView
    Left = 144
    Top = 288
    Width = 521
    Height = 265
    Columns = <
      item
        Caption = 'FileName'
        Width = 400
      end
      item
        Caption = 'Size'
        Width = 100
      end>
    GridLines = True
    MultiSelect = True
    RowSelect = True
    SmallImages = ImageList1
    TabOrder = 14
    ViewStyle = vsReport
    OnDblClick = ListView1DblClick
  end
  object DropFileTarget1: TDropFileTarget
    Dragtypes = [dtCopy, dtLink]
    GetDataOnEnter = False
    OnDrop = DropFileTarget1Drop
    ShowImage = True
    OptimizedMove = True
    AllowAsyncTransfer = False
    Left = 640
    Top = 128
  end
  object ImageList1: TImageList
    Left = 152
    Top = 312
  end
  object XPManifest1: TXPManifest
    Left = 8
    Top = 8
  end
end
