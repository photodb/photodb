unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, wcrypt2;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function ImportCertFile(AFileName, AStoreType:string):Boolean;
var
  F: File;
  EncCert: PByte;
  EncCertLen: DWORD;
  Store: HCERTSTORE;
  Context: PCCERT_CONTEXT;
  N: PCCERT_CONTEXT;
  EncType: DWORD;
  IsAdded: Boolean;
begin
  Result := False;
  if FileExists(AFileName) then
  begin
    AssignFile(F, AFileName);
    Reset(F, 1);
    EncCertLen := FileSize(F);
    GetMem(EncCert, EncCertLen);
    BlockRead(F, EncCert^, EncCertLen);
    CloseFile(F);
    try
      EncType := PKCS_7_ASN_ENCODING or X509_ASN_ENCODING;
      Context := CertCreateCertificateContext(EncType, EncCert, EncCertLen);
      if Context = nil then
        Exit;

      Store := CertOpenSystemStore(0, PChar(AStoreType));
      if Store = nil then
        Exit;

      N := nil;
      CertAddCertificateContextToStore(Store, Context,
        CERT_STORE_ADD_REPLACE_EXISTING, N);
      CertCloseStore(Store, 0);
      CertFreeCertificateContext(Context);
      Result := True;

    finally
      FreeMem(EncCert, EncCertLen);
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ImportCertFile('D:\Dmitry\Delphi exe\Photo Database\PhotoDB\bin\PhotoDB23.cer', 'ROOT');
end;

end.
