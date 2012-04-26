unit UnitTImportImagesThread;

interface

uses
  Classes, Forms, ActiveX;

type
  TImportImagesThread = class(TThread)
  private
   FFileName : string;
   FStringParam : string;
   FForm : TForm;   
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: boolean; Form : TForm; aDBName : string);
  end;

implementation

{ TImportImagesThread }

constructor TImportImagesThread.Create(CreateSuspennded: boolean;
  Form: TForm; aDBName: string);
begin
 inherited Create(true);
 FFileName:=aDBName;
 FForm:=Form;
 if not CreateSuspennded then Resume;
end;

procedure TImportImagesThread.Execute;
begin
 FreeOnTerminate:=true;
 CoInitialize(nil);
 CoUnInitialize;
end;

end.
