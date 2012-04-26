unit UnitDrawImageToSizeThread;

interface

uses
  Classes, Graphics;

type
  DrawImageToSizeThread = class(TThread)
  private
  FSID : String;
  Graphic : TGraphic;
    { Private declarations }
  protected
    procedure Execute; override;
    constructor Create(CreateSuspennded: Boolean; Image : TGraphic; W,H : Integer; SID : String);
  end;

implementation

{ DrawImageToSizeThread }

constructor DrawImageToSizeThread.Create(CreateSuspennded: Boolean;
  Image: TGraphic; W, H: Integer; SID: String);
begin
  inherited Create(True);
  FSID:=SID;
  Graphic.Assign(Image);
  If not CreateSuspennded then Resume;
end;

procedure DrawImageToSizeThread.Execute;
begin
 FreeOnTerminate:=True;

  { Place thread code here }
end;

end.
