inherited FrmSteganographyLanding: TFrmSteganographyLanding
  Width = 447
  Height = 304
  Anchors = [akLeft, akTop, akRight]
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 447
  ExplicitHeight = 304
  object LbHideDataInImageInfo: TLabel
    Left = 3
    Top = 87
    Width = 429
    Height = 50
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbHideDataInImageInfo'
    WordWrap = True
    ExplicitWidth = 454
  end
  object LbHideDataInJPEGFileInfo: TLabel
    Left = 3
    Top = 175
    Width = 429
    Height = 50
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbHideDataInJPEGFileInfo'
    WordWrap = True
    ExplicitWidth = 454
  end
  object LbStepInfo: TLabel
    Left = 3
    Top = 3
    Width = 429
    Height = 41
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'LbStepInfo'
    WordWrap = True
    ExplicitWidth = 454
  end
  object RbHideDataInImage: TRadioButton
    Left = 3
    Top = 64
    Width = 429
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'RbHideDataInImage'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = RbHideDataInImageClick
    ExplicitWidth = 454
  end
  object RbHideDataInJPEGFile: TRadioButton
    Left = 3
    Top = 152
    Width = 429
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'CbHideDataInJPEGFile'
    TabOrder = 1
    OnClick = RbHideDataInImageClick
    ExplicitWidth = 454
  end
  object RbExtractDataFromImage: TRadioButton
    Left = 3
    Top = 240
    Width = 429
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'RbExtractDataFromImage'
    TabOrder = 2
    OnClick = RbHideDataInImageClick
    ExplicitWidth = 454
  end
end
