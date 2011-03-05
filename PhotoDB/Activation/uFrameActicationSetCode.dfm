inherited FrameActicationSetCode: TFrameActicationSetCode
  Height = 320
  Color = clWhite
  ParentBackground = False
  ParentColor = False
  ExplicitHeight = 320
  object EdActivationName: TLabeledEdit
    Left = 3
    Top = 56
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    EditLabel.Width = 81
    EditLabel.Height = 13
    EditLabel.Caption = 'Activation name:'
    TabOrder = 0
  end
  object EdActivationCode: TLabeledEdit
    Left = 3
    Top = 96
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    EditLabel.Width = 78
    EditLabel.Height = 13
    EditLabel.Caption = 'Activation code:'
    TabOrder = 1
  end
  object EdApplicationCode: TLabeledEdit
    Left = 3
    Top = 16
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    EditLabel.Width = 82
    EditLabel.Height = 13
    EditLabel.Caption = 'Application code:'
    ReadOnly = True
    TabOrder = 2
  end
end
