inherited FrameFreeActivation: TFrameFreeActivation
  Height = 320
  Color = clWhite
  Font.Color = clBlack
  ParentBackground = False
  ParentColor = False
  ParentFont = False
  ExplicitHeight = 320
  DesignSize = (
    320
    320)
  object LbInternetQuery: TLabel
    Left = 40
    Top = 288
    Width = 278
    Height = 32
    AutoSize = False
    Caption = 'LbInternetQuery'
    Visible = False
    WordWrap = True
  end
  object EdFirstName: TLabeledEdit
    Left = 3
    Top = 16
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 11206655
    EditLabel.Width = 55
    EditLabel.Height = 13
    EditLabel.Caption = 'First Name:'
    TabOrder = 0
  end
  object EdLastName: TLabeledEdit
    Left = 3
    Top = 56
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 11206655
    EditLabel.Width = 54
    EditLabel.Height = 13
    EditLabel.Caption = 'Last Name:'
    TabOrder = 1
  end
  object EdEmail: TLabeledEdit
    Left = 3
    Top = 96
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = 11206655
    EditLabel.Width = 28
    EditLabel.Height = 13
    EditLabel.Caption = 'Email:'
    TabOrder = 2
  end
  object EdPhone: TLabeledEdit
    Left = 3
    Top = 136
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    EditLabel.Width = 34
    EditLabel.Height = 13
    EditLabel.Caption = 'Phone:'
    TabOrder = 3
  end
  object EdCountry: TLabeledEdit
    Left = 3
    Top = 176
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    EditLabel.Width = 43
    EditLabel.Height = 13
    EditLabel.Caption = 'Country:'
    TabOrder = 4
  end
  object EdCity: TLabeledEdit
    Left = 3
    Top = 219
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    EditLabel.Width = 23
    EditLabel.Height = 13
    EditLabel.Caption = 'City:'
    TabOrder = 5
  end
  object EdAddress: TLabeledEdit
    Left = 3
    Top = 259
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    EditLabel.Width = 43
    EditLabel.Height = 13
    EditLabel.Caption = 'Address:'
    TabOrder = 6
  end
  object LsQuery: TLoadingSign
    Left = 0
    Top = 286
    Width = 32
    Height = 32
    Visible = False
    Active = True
    FillPercent = 65
    SignColor = clBlack
  end
end
