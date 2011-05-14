unit uFrmCreateJPEGSteno;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, ExtCtrls, StdCtrls, WatermarkedEdit;

type
  TFrmCreateJPEGSteno = class(TFrameWizardBase)
    ImJpegFile: TImage;
    LbJpegFileInfo: TLabel;
    LbJpegFileSize: TLabel;
    LbImageSize: TLabel;
    WatermarkedEdit1: TWatermarkedEdit;
    LbSelectFile: TLabel;
    BtnChooseFile: TButton;
    LbFileSize: TLabel;
    LbResultImageSize: TLabel;
    Gbptions: TGroupBox;
    CbEncryptdata: TCheckBox;
    LbPassword: TLabel;
    EdPassword: TWatermarkedEdit;
    Label1: TLabel;
    EdPasswordConfirm: TWatermarkedEdit;
    CbIncludeCRC: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
    function IsFinal: Boolean; override;
  end;

implementation

{$R *.dfm}

{ TFrmCreateJPEGSteno }

function TFrmCreateJPEGSteno.IsFinal: Boolean;
begin
  Result := True;
end;

end.
