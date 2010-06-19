unit uTime;

interface

uses Classes, SysUtils;

type
  TW = class(TObject)
  private
    FS : TFileStream;
    FStart : TDateTime;
    IsRuning : Boolean;
    FName : string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(Name : string);
    procedure Stop;
    class function I : TW;
  end;

implementation

var
  W : TW;

{ TW }

constructor TW.Create;
begin
  IsRuning := False;
  FS := TFileStream.Create('c:\tw.txt', fmCreate);
end;

destructor TW.Destroy;
begin
  FS.Free;
  inherited;
end;

class function TW.I: TW;
begin
  if W = nil then
    W := TW.Create;

  Result := W;
end;

procedure TW.Start(Name: string);
begin
  if IsRuning then
    Stop;

  FName := Name;
  FStart := Now;
  IsRuning := True;
end;

procedure TW.Stop;
var
  Info : string;
begin
  IsRuning := False;
  Info := Format('%s = %d ms.%s', [FName, Round((Now - FStart)*24*60*60*1000), #13#10]);
  FS.Write(Info[1], Length(Info))
end;

end.
