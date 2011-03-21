object SplitExportForm: TSplitExportForm
  Left = 203
  Top = 157
  Caption = 'SplitExportForm'
  ClientHeight = 389
  ClientWidth = 470
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 470
    Height = 113
    Align = alTop
    TabOrder = 0
    object Image1: TImage
      Left = 8
      Top = 8
      Width = 17
      Height = 17
      Picture.Data = {
        055449636F6E0000010001001010000001002000680400001600000028000000
        1000000020000000010020000000000040040000000000000000000000000000
        0000000000000000000000000000000000000000449C9D0142555510433D3B01
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000BDE47225A8E5FF00405BA7
        0000001500000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000025BFE9D960F0FFFF
        085B82C800000011000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000414519007CA6AC6AF1FFFF
        58E6FFFF0E6C96D10444649C0016256000000016000000000000000000000000
        000000000000000000000000007D7F0C0A86B3AA2DB5EFFF4BDFFFFF54E7FDFF
        56E7FFFF55EBFFFF50E7FFFF3BD2FFFF188CC4F0001B2D7D0000000A00000000
        0000000000000000008E961E1290D9F32FD2FFFF35D9FEFF33D9FDFF34D9FDFF
        33D9FDFF34D9FDFF33D9FDFF35D9FEFF33D9FFFF21BEFFFF043659AF0000000B
        00000000000000000085D2E313C1FFFF16C8FCFF15C9FCFF15C8FCFF15C8FCFF
        15C8FCFF15C8FCFF15C9FCFF15C9FCFF16C7FCFF15C5FDFF0CACFFFF00132680
        000000004EBFDC56009BF7FF06BAFCFF06C0FFFF06BDFDFF07C0FFFF09BCFBFF
        0BBCFAFF0BBCFBFF0BBBFBFF0BBFFDFF0BBDFCFF0BBDFCFF08B4FFFF0163AEE9
        433C360B2FA1D49116ABFDFF42C4F9FF4985B7FF4BAADCFF3979B0FF19BCFDFF
        07B4FBFF0DB8FDFF0A8ED3FF0A97DCFF0A7DC3FF0CA7EBFF0BB2FDFF0286E9FF
        44403C1C659ED59070CBFEFF71D2FDFF6FA5CEFF70C3EDFF6DABD5FF79D6FFFF
        41C2FAFF03B3FEFF077FC7FF0975BDFF076DB5FF0B89CFFF0BB0FFFF0283E7FF
        44403D1082A2C2556BC0FBFF85D8FEFF83C3E7FF83D2F7FF80BADFFF84D8FDFF
        8ADAFDFF66D0FEFF2598D9FF1896DAFF188ACEFF0C9BE4FF05A9FFFF015FB3DD
        00000000000000002F82CDE19DDFFFFF97DEFEFF96DFFDFF93DFFFFF97DEFDFF
        97DEFDFF9ADFFDFF9BE1FFFF9EE3FFFF9FE3FFFFA9E6FFFF32A7FEFF000F2346
        0000000000000000E4EEF71A2C81CAECA5DEFFFFAEE6FFFFA7E2FDFFA7E3FDFF
        A8E3FDFFA8E3FDFFA7E2FDFFABE4FEFFB1E5FFFF7EBFF2FF0B37637500000000
        000000000000000000000000F9FBFE094F91CC9C4C9BDDFF93D1FCFFBBE7FFFF
        BDE7FFFFBEE8FFFFAEE2FFFF7DBDEFFF5094D2D9B4CFE93E0000000000000000
        0000000000000000000000000000000000000000858A8F09749DC45E5392CC8A
        64A0D49D5E9AD094649BCD76768A9F2E00000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000F1FF0000F0FF0000F87F0000F00F0000C00300008001000080010000
        000000000000000000000000000100008001000080030000C0070000F01F0000
        FFFF0000}
    end
    object Label1: TLabel
      Left = 32
      Top = 8
      Width = 377
      Height = 33
      AutoSize = False
      Caption = 'Label1'
      WordWrap = True
    end
    object Label2: TLabel
      Left = 8
      Top = 112
      Width = 44
      Height = 13
      Caption = 'FileName'
    end
    object Panel4: TPanel
      Left = 1
      Top = 94
      Width = 468
      Height = 18
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object Label3: TLabel
        Left = 8
        Top = 2
        Width = 82
        Height = 13
        Caption = 'Folders and Files:'
      end
    end
    object Panel5: TPanel
      Left = 1
      Top = 71
      Width = 468
      Height = 23
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object CheckBox1: TCheckBox
        Left = 8
        Top = 3
        Width = 281
        Height = 17
        Caption = 'Delete this Records after finishing'
        TabOrder = 0
      end
    end
    object Panel6: TPanel
      Left = 1
      Top = 47
      Width = 468
      Height = 24
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object Panel7: TPanel
        Left = 391
        Top = 0
        Width = 77
        Height = 24
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object Button1: TButton
          Left = 4
          Top = 4
          Width = 17
          Height = 20
          Caption = '...'
          TabOrder = 0
          OnClick = Button1Click
        end
        object BtnNew: TButton
          Left = 24
          Top = 4
          Width = 51
          Height = 19
          Caption = 'New'
          TabOrder = 1
          OnClick = BtnNewClick
        end
      end
      object Panel8: TPanel
        Left = 0
        Top = 0
        Width = 391
        Height = 24
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object EdDBName: TWatermarkedEdit
          Left = 8
          Top = 0
          Width = 1200
          Height = 21
          ReadOnly = True
          TabOrder = 0
          WatermarkText = 'Select a file to split the database'
        end
      end
    end
  end
  object ListView1: TListView
    Left = 0
    Top = 113
    Width = 470
    Height = 235
    Align = alClient
    Columns = <
      item
        Caption = 'Method'
        Width = 60
      end
      item
        Alignment = taCenter
        AutoSize = True
        Caption = 'Path'
      end>
    SmallImages = MethodImageList
    TabOrder = 1
    ViewStyle = vsReport
    OnAdvancedCustomDrawSubItem = ListView1AdvancedCustomDrawSubItem
    OnContextPopup = ListView1ContextPopup
    OnKeyDown = ListView1KeyDown
    OnMouseDown = ListView1MouseDown
    OnResize = ListView1Resize
  end
  object Panel2: TPanel
    Left = 0
    Top = 348
    Width = 470
    Height = 41
    Align = alBottom
    TabOrder = 2
    object Panel3: TPanel
      Left = 301
      Top = 1
      Width = 168
      Height = 39
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BtnOk: TButton
        Left = 88
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Ok'
        TabOrder = 0
        OnClick = BtnOkClick
      end
      object BtnCancel: TButton
        Left = 7
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Cancel'
        TabOrder = 1
        OnClick = BtnCancelClick
      end
    end
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = [dtCopy, dtLink]
    OnDrop = DropFileTarget1Drop
    OptimizedMove = True
    Left = 8
    Top = 280
  end
  object ImageList1: TImageList
    Left = 296
    Top = 72
  end
  object MethodImageList: TImageList
    Left = 336
    Top = 72
  end
  object PmMethod: TPopupMenu
    Left = 176
    Top = 152
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Cut1: TMenuItem
      Tag = 1
      Caption = 'Cut'
      OnClick = Copy1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
  end
end
