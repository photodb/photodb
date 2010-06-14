unit ImageHistoryUnit;

interface

uses Graphics, Classes;

type
  THistoryAct = (THA_Redo, THA_Undo, THA_Add, THA_Unknown);
  THistoryAction = set of THistoryAct;

  TArBitmap = array of TBitmap;
  TArString = array of string;
  TNotifyHistoryEvent = procedure(Sender: TObject; Action : THistoryAction) of object;

type
  TBitmapHistory = class(TObject)
  fArray : TArBitmap;
  fActionArray : TArString;
  fposition : integer;
//  fStrings : integer;
  private
    fOnChange: TNotifyHistoryEvent;
//    fCount: integer;
  procedure SetOnChange(const Value: TNotifyHistoryEvent);
    { Private declarations }
  public
  constructor Create;
  destructor Destroy; override;
  procedure Add(Image : TBitmap; Action : String);
//  procedure AddPointer(Image : TBitmap);
  Function CanBack : boolean;
  Function CanForward : boolean;
  Function GetCurrentPos : integer;
  Function DoBack : TBitmap;
  Function DoForward : TBitmap;
  Property OnHistoryChange : TNotifyHistoryEvent read fOnChange write SetOnChange;
  Function LastImage : TBitmap;
  Function GetBackHistory : TArBitmap;
  Function GetForwardHistory : TArBitmap;
  Property Actions : TArString read fActionArray;
  Procedure Clear;
    { Public declarations }
  end;

implementation

{ TStringsHistoryW }

procedure TBitmapHistory.Add(Image: TBitmap; Action : String);
var
  i : integer;
begin
 If Fposition=Length(fArray)-1 then
 begin
  SetLength(fArray,Length(fArray)+1);
  fArray[Length(fArray)-1]:=TBitmap.Create;
  fArray[Length(fArray)-1].PixelFormat:=pf24bit;
  fArray[Length(fArray)-1].Assign(Image);

  SetLength(fActionArray,Length(fActionArray)+1);
  fActionArray[Length(fActionArray)-1]:=Action;

  Fposition:=Length(fArray)-1;
 end else
 begin
  For i:=Fposition+1 to length(fArray)-1 do
  begin
   fArray[i].free;
   fActionArray[i]:='';
  end;
  SetLength(fArray,Fposition+2);
  SetLength(fActionArray,Fposition+2);
  fArray[Fposition+1]:=TBitmap.Create;
  fArray[Fposition+1].PixelFormat:=pf24bit;
  fArray[Fposition+1].Assign(Image);
  fActionArray[Fposition+1]:=Action;
  Fposition:=Fposition+1;
 end;
 If Assigned(OnHistoryChange) Then OnHistoryChange(Self,[THA_Add]);
end;

function TBitmapHistory.CanBack: boolean;
begin
 If Fposition=-1 then
 begin
  Result:=false;
 end else
 begin
  if FPosition>0 then Result:=True else Result:=false;
 end;
end;

function TBitmapHistory.CanForward: boolean;
begin
 if FPosition=-1 then
 begin
  Result:=false;
  Exit;
 end else
 begin
  if (Fposition<>Length(fArray)-1) and (Length(fArray)<>1) then
  Result:=True else Result:=false;
 end;
end;

procedure TBitmapHistory.Clear;
var
  i : integer;
begin
 Fposition:=-1;
 for i:=0 to Length(fArray)-1 do
 begin
  fArray[i].free;
  fActionArray[i]:='';
 end;
 SetLength(fArray,0);  
 SetLength(fActionArray,0);
end;

constructor TBitmapHistory.create;
begin
 Inherited;
 Fposition:=-1;
 SetLength(fArray,0);
 SetLength(fActionArray,0);
 fOnChange:=nil;
end;

destructor TBitmapHistory.Destroy;
begin
 Clear;
 SetLength(fArray,0);
 SetLength(fActionArray,0);
 inherited;
end;

function TBitmapHistory.DoBack: TBitmap;
begin
 Result:=nil;
 If FPosition=-1 then Exit;
 if FPosition=0 then Result:=fArray[0] else
 begin
  Dec(FPosition);
  Result:=fArray[FPosition];
 end;
 If Assigned(OnHistoryChange) Then OnHistoryChange(Self,[THA_Undo]);
end;

function TBitmapHistory.DoForward: TBitmap;
begin
 Result:=nil;
 If FPosition=-1 then Exit;
 if (Fposition=Length(fArray)-1) or (Length(fArray)=1) then Result:=fArray[Length(fArray)-1] else
 begin
  Inc(FPosition);
  Result:=fArray[FPosition];
 end;
 If Assigned(OnHistoryChange) Then OnHistoryChange(Self,[THA_Redo]);
end;


function TBitmapHistory.GetBackHistory: TArBitmap;
var
  i : integer;
begin
 SetLength(Result,0);
 If FPosition=-1 then Exit;
 For i:=0 to FPosition-1 do
 begin
  SetLength(Result,Length(Result)+1);
  Result[i]:=fArray[i];
//  Result[i].Tag:=i;
 end;
end;

function TBitmapHistory.GetCurrentPos: integer;
begin
 Result:=FPosition+1;
end;

function TBitmapHistory.GetForwardHistory: TArBitmap;
var
  i : integer;
begin
 SetLength(Result,0);
 If FPosition=-1 then Exit;
 For i:=FPosition+1 to Length(fArray)-1 do
 begin
  SetLength(Result,Length(Result)+1);
  Result[i-FPosition-1]:=fArray[i];
//  Result[i-FPosition-1].Tag:=i;
 end;
end;

function TBitmapHistory.LastImage: TBitmap;
begin
 Result:=nil;
 if FPosition=-1 then Exit;
 Result:=fArray[FPosition];
end;

procedure TBitmapHistory.SetOnChange(const Value: TNotifyHistoryEvent);
begin
 fOnChange:=Value;
end;

end.
