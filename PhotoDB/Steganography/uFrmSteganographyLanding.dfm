inherited FrmSteganographyLanding: TFrmSteganographyLanding
  Width = 487
  Height = 304
  Anchors = [akLeft, akTop, akRight]
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitWidth = 487
  ExplicitHeight = 304
  object LbHideDataInImageInfo: TLabel
    Left = 3
    Top = 87
    Width = 469
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
    Width = 469
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
    Width = 469
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
    Width = 469
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
    Width = 469
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'CbHideDataInJPEGFile'
    TabOrder = 1
    OnClick = RbHideDataInImageClick
  end
  object RbExtractDataFromImage: TRadioButton
    Left = 3
    Top = 240
    Width = 469
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'RbExtractDataFromImage'
    TabOrder = 2
    OnClick = RbHideDataInImageClick
  end
  object CbUseAnotherImage: TCheckBox
    Left = 3
    Top = 276
    Width = 469
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Use another image'
    TabOrder = 3
  end
end
