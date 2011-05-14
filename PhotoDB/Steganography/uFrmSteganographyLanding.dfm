inherited FrmSteganographyLanding: TFrmSteganographyLanding
  Width = 472
  Height = 301
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 472
  ExplicitHeight = 301
  object LbHideDataInImageInfo: TLabel
    Left = 3
    Top = 87
    Width = 454
    Height = 50
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbHideDataInImageInfo'
    WordWrap = True
  end
  object LbHideDataInJPEGFileInfo: TLabel
    Left = 3
    Top = 175
    Width = 454
    Height = 50
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbHideDataInJPEGFileInfo'
    WordWrap = True
  end
  object LbStepInfo: TLabel
    Left = 3
    Top = 3
    Width = 454
    Height = 41
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbStepInfo'
    WordWrap = True
  end
  object RbHideDataInImage: TRadioButton
    Left = 3
    Top = 64
    Width = 454
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'RbHideDataInImage'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = RbHideDataInImageClick
  end
  object RbHideDataInJPEGFile: TRadioButton
    Left = 3
    Top = 152
    Width = 454
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'CbHideDataInJPEGFile'
    TabOrder = 1
    OnClick = RbHideDataInImageClick
  end
  object RbExtractDataFromImage: TRadioButton
    Left = 3
    Top = 240
    Width = 454
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'RbExtractDataFromImage'
    TabOrder = 2
    OnClick = RbHideDataInImageClick
  end
end
