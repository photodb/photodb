inherited FrLicense: TFrLicense
  Width = 430
  Height = 330
  ParentFont = False
  ExplicitWidth = 430
  ExplicitHeight = 330
  object MemLicense: TMemo
    Left = 3
    Top = 3
    Width = 424
    Height = 301
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object CbAcceptLicenseAgreement: TCheckBox
    Left = 3
    Top = 310
    Width = 424
    Height = 17
    Caption = 'Accept license agreement'
    TabOrder = 1
    OnClick = CbAcceptLicenseAgreementClick
  end
end
