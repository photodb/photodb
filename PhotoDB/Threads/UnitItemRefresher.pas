unit UnitItemRefresher;

interface

uses
  Windows, dolphin_db, Classes, Graphics;

Type
  TRefreshItemEvent = procedure(Image : TBitmap; Info : TOneRecordInfo) of Object;
  TRefreshParams = Record
  end;
  
type
  TItemRefresher = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspennded: Boolean; FileNames  : TArStrings; ItemIds : TArInteger; Params : TRefreshParams; OnDone : TRefreshItemEvent);
  end;

implementation

{ TItemRefresher }

constructor TItemRefresher.Create(CreateSuspennded: Boolean;
  FileNames: TArStrings; ItemIds: TArInteger; Params : TRefreshParams; OnDone: TRefreshItemEvent);
begin
//
end;

procedure TItemRefresher.Execute;
begin
  { Place thread code here }
end;

end.
