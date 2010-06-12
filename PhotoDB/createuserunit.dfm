object NewSingleUserForm: TNewSingleUserForm
  Left = 187
  Top = 176
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'NewSingleUserForm'
  ClientHeight = 215
  ClientWidth = 194
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 48
    Height = 48
    Center = True
    Picture.Data = {
      0A544A504547496D616765A7040000FFD8FFE000104A46494600010101004800
      480000FFDB004300080606070605080707070909080A0C140D0C0B0B0C191213
      0F141D1A1F1E1D1A1C1C20242E2720222C231C1C2837292C30313434341F2739
      3D38323C2E333432FFDB0043010909090C0B0C180D0D1832211C213232323232
      3232323232323232323232323232323232323232323232323232323232323232
      32323232323232323232323232FFC0001108002D002D03012200021101031101
      FFC4001F0000010501010101010100000000000000000102030405060708090A
      0BFFC400B5100002010303020403050504040000017D01020300041105122131
      410613516107227114328191A1082342B1C11552D1F02433627282090A161718
      191A25262728292A3435363738393A434445464748494A535455565758595A63
      6465666768696A737475767778797A838485868788898A92939495969798999A
      A2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6
      D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F01000301
      01010101010101010000000000000102030405060708090A0BFFC400B5110002
      0102040403040705040400010277000102031104052131061241510761711322
      328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728
      292A35363738393A434445464748494A535455565758595A636465666768696A
      737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7
      A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3
      E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F00F1CB
      7B579987079E831D6BA2D33C3F3DDB6C860795875118E07D4D68787F427BEBA8
      6045EA732301F757BD7ABD9D9C1616C96F6D1848D7B0EFEE7D4D79B8AC672691
      3CCC462B93447016FE03BF6404ADBC0C0630ED93F9806A59FC0D7823040B7971
      FC2ADCFF00E3C00AF41A2BCF78BAB7B9C5F59A97B9E317FA0B412346F13C6E3A
      AB0FE87AD73B3D879721072BF8706BDE2F6D6CF5BB274592394A921644607637
      D47EA2BCE2F74F682E9E27F95D5883DF3838AEEC3E2DBD19DB4310E4B53B0F05
      C016D6E66DA396080FD0671FA8AD5B0D20D96A175766F2697CF39F2DBEEAF39F
      CFF2ACDF06CC1ACAE60C1CA481F3EBB863FF0065AE96BCEAB26A6D1C1564D4DA
      0A42030208041E083DE968AC4C4ABA7E9D6BA640D05A46523672E4162793F5FA
      0AE53C531ADBEAA1B1912A06DB81C1E87B1F4AED6B8CF18C8ADA8411839658F2
      47A64D6F41B73D4E8A127CF7323C35AC2D95EC7233FEE5C6D938EDD8FE15E8F1
      4A9344B2C4E1D1865587422BC1EC6E9E36403A3118E7A66BACD2B5DBED3F3E4C
      9F2646636E54E7DBB7E15D989C2DDDD1D388C3F33BA3B8BBD3B56B895CC5AD79
      1113F2A2DB29C0CF1CE734DD3748D42C6EBCD9F599AEA2C106274EBF89271596
      9E3470803D8866EE565C0FCB06AB5E78E6E170B6F651A37526472C3F4C572AA7
      59FBB6FC8E754EABF76DF91D7DE5E41616AF7170E12341C93DFD87BD792EADAB
      0BCBF92E276DAD21C85EB814DD6759BDBDFDF5CCA6439C2AF454FA0FC2B99BAB
      A712E480491926BBF0B84E5D5EE7661F0FC9ABDCFFD9}
    PopupMenu = PopupMenu1
    OnClick = Image1Click
  end
  object Edit1: TEdit
    Left = 64
    Top = 8
    Width = 121
    Height = 35
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentColor = True
    ParentFont = False
    TabOrder = 0
    Text = 'User'
    OnChange = Edit2Change
  end
  object RadioButton1: TRadioButton
    Left = 120
    Top = 48
    Width = 57
    Height = 17
    Caption = 'Admin'
    Enabled = False
    TabOrder = 1
  end
  object RadioButton2: TRadioButton
    Left = 64
    Top = 48
    Width = 49
    Height = 17
    Caption = 'User'
    Checked = True
    Enabled = False
    TabOrder = 2
    TabStop = True
  end
  object Panel1: TPanel
    Left = 8
    Top = 112
    Width = 185
    Height = 97
    BevelOuter = bvNone
    TabOrder = 3
    object Label2: TLabel
      Left = 0
      Top = 52
      Width = 35
      Height = 13
      Caption = 'Confirm'
    end
    object Label1: TLabel
      Left = 0
      Top = 8
      Width = 46
      Height = 13
      Caption = 'Password'
    end
    object Button1: TButton
      Left = 128
      Top = 64
      Width = 49
      Height = 25
      Caption = 'Ok'
      Enabled = False
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 128
      Top = 32
      Width = 49
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Edit2: TEdit
      Left = 0
      Top = 24
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
      Text = 'Password'
      OnChange = Edit2Change
      OnKeyPress = Edit5KeyPress
    end
    object Edit3: TEdit
      Left = 0
      Top = 68
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
      Text = 'Password'
      OnChange = Edit2Change
      OnKeyPress = Edit5KeyPress
    end
  end
  object Panel2: TPanel
    Left = 8
    Top = 72
    Width = 185
    Height = 41
    BevelOuter = bvNone
    TabOrder = 4
    object Label3: TLabel
      Left = 0
      Top = 0
      Width = 65
      Height = 13
      Caption = 'Old Password'
    end
    object Edit5: TEdit
      Left = 0
      Top = 20
      Width = 121
      Height = 21
      PasswordChar = '*'
      TabOrder = 0
      Text = 'Password'
      OnChange = Edit2Change
      OnKeyPress = Edit5KeyPress
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 88
    Top = 8
    object LoadFromFile1: TMenuItem
      Caption = 'Load From File'
      OnClick = LoadFromFile1Click
    end
  end
  object HelpTimer1: TTimer
    Enabled = False
    OnTimer = HelpTimer1Timer
    Left = 152
    Top = 40
  end
  object GraphicSelect1: TGraphicSelectEx
    ThWidth = 48
    ThHeight = 48
    WidthCount = 5
    HeightCount = 5
    Color = clWhite
    SelCanMoveColor = 8926122
    SelColor = 16724787
    OnImageSelect = GraphicSelect1ImageSelect
    ShowGaleries = False
    TextColor = clBlack
    GaleryNumber = 1
    RealSizes = True
    AutoSizeGaleries = False
    Left = 56
    Top = 8
  end
end
