unit uFrLicence;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls;

type
  TFrmLicence = class(TFrame)
    Memo1: TMemo;
    CbAcceptLicenseAgreement: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

//    CbAcceptLicenseAgreement.Caption := L('I accept licence agreement');

{$R *.dfm}

end.
