unit UnitDBRedeclare;

interface

{$DEFINE DEBUG}

uses Graphics, uGOM;

type
  TDBBitmap = class(TBitmap)
  private
   FInfo : string;
  public
   constructor Create(Info : string); reintroduce;
   destructor Destroy; override;
  end;

implementation

{ TDBBitmap }

constructor TDBBitmap.Create(Info: string);
begin
 inherited Create;
 {$IFDEF DEBUG}
 GOM.AddObj(self);
 {$ENDIF}
 fInfo:=Info;
end;

destructor TDBBitmap.Destroy;
begin
 {$IFDEF DEBUG}
 GOM.RemoveObj(self);
 {$ENDIF}
  inherited;
end;

end.
