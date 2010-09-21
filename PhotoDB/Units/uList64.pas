unit uList64;

interface

uses RTLConsts, SysUtils;

const
  MaxListSize = Maxint div 16;

type
  PInt64List = ^TInt64List;
  TInt64List = array[0..MaxListSize - 1] of Int64;
  TListSortCompare = function (Item1, Item2: Int64): Integer;
  TListNotification = (lnAdded, lnExtracted, lnDeleted);  
  // these operators are used in Assign and go beyond simply copying
  //   laCopy = dest becomes a copy of the source
  //   laAnd  = intersection of the two lists
  //   laOr   = union of the two lists
  //   laXor  = only those not in both lists
  // the last two operators can actually be thought of as binary operators but
  // their implementation has been optimized over their binary equivalent.
  //   laSrcUnique  = only those unique to source (same as laAnd followed by laXor)
  //   laDestUnique = only those unique to dest   (same as laOr followed by laXor)
  TListAssignOp = (laCopy, laAnd, laOr, laXor, laSrcUnique, laDestUnique);
                  
  EListError = class(Exception);

  TList64 = class(TObject)
  private
    FList: PInt64List;
    FCount: Integer;
    FCapacity: Integer;
    function GetMaxStatDateTime: TDateTime;
    function GetMaxStatInt64: Int64;
    function GetMaxStatInteger: Integer;    
    function GetMaxStatBoolean: Boolean;
    function GetHasVarValues: Boolean;
  protected
    function Get(Index: Integer): Int64;
    procedure Grow; virtual;
    procedure Put(Index: Integer; Item: Int64);
    procedure Notify(Ptr: Int64; Action: TListNotification); virtual;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  public
    destructor Destroy; override;
    function Add(Item: Int64): Integer; overload;
    function Add(Item: TDateTime): Integer; overload;
    function Add(Item: Integer): Integer; overload;    
    function Add(Item: Boolean): Integer; overload;
    procedure Clear; virtual;
    procedure Delete(Index: Integer);
    class procedure Error(const Msg: string; Data: Integer); overload; virtual;
    class procedure Error(Msg: PResStringRec; Data: Integer); overload;
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TList64;
    function Extract(Item: Int64): Int64;
    function First: Int64;
    function IndexOf(Item: Int64): Integer;
    procedure Insert(Index: Integer; Item: Int64);
    function Last: Int64;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Int64): Integer;
    procedure Pack;
    procedure Sort(Compare: TListSortCompare);
    procedure Assign(ListA: TList64; AOperator: TListAssignOp = laCopy; ListB: TList64 = nil);
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Int64 read Get write Put; default;
    property List: PInt64List read FList;
    property MaxStatInt64 : Int64 read GetMaxStatInt64;
    property MaxStatInteger : Integer read GetMaxStatInteger;  
    property MaxStatDateTime : TDateTime read GetMaxStatDateTime;  
    property MaxStatBoolean : Boolean read GetMaxStatBoolean;
    property HasVarValues: Boolean read GetHasVarValues;
  end;

implementation

{ TList }

destructor TList64.Destroy;
begin
  Clear;
end;

function TList64.Add(Item: Int64): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  FList^[Result] := Item;
  Inc(FCount);
  if Item <> 0 then
    Notify(Item, lnAdded);
end;

procedure TList64.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TList64.Delete(Index: Integer);
var
  Temp: Int64;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Temp := Items[Index];
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Pointer));
  if Temp <> 0 then
    Notify(Temp, lnDeleted);
end;

class procedure TList64.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

class procedure TList64.Error(Msg: PResStringRec; Data: Integer);
begin
  TList64.Error(LoadResString(Msg), Data);
end;

procedure TList64.Exchange(Index1, Index2: Integer);
var
  Item: Int64;
begin
  if (Index1 < 0) or (Index1 >= FCount) then
    Error(@SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then
    Error(@SListIndexError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TList64.Expand: TList64;
begin
  if FCount = FCapacity then
    Grow;
  Result := Self;
end;

function TList64.First: Int64;
begin
  Result := Get(0);
end;

function TList64.Get(Index: Integer): Int64;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  Result := FList^[Index];
end;

function TList64.GetHasVarValues: Boolean;
var
  FirstValue: Int64;
  I: Integer;
begin
  Result := False;
  if Count = 0 then
    Exit;
  FirstValue := Get(0);
  for I := 1 to Count - 1 do
    if FirstValue <> Get(I) then
    begin
      Result := True;
      Break;
    end;
end;

procedure TList64.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then
    Delta := FCapacity div 4
  else
    if FCapacity > 8 then
      Delta := 16
    else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TList64.IndexOf(Item: Int64): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do
    Inc(Result);
  if Result = FCount then
    Result := -1;
end;

procedure TList64.Insert(Index: Integer; Item: Int64);
begin
  if (Index < 0) or (Index > FCount) then
    Error(@SListIndexError, Index);
  if FCount = FCapacity then
    Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Pointer));
  FList^[Index] := Item;
  Inc(FCount);
  if Item <> 0 then
    Notify(Item, lnAdded);
end;

function TList64.Last: Int64;
begin
  Result := Get(FCount - 1);
end;

procedure TList64.Move(CurIndex, NewIndex: Integer);
var
  Item: Int64;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then
      Error(@SListIndexError, NewIndex);
    Item := Get(CurIndex);
    FList^[CurIndex] := 0;
    Delete(CurIndex);
    Insert(NewIndex, 0);
    FList^[NewIndex] := Item;
  end;
end;

procedure TList64.Put(Index: Integer; Item: Int64);
var
  Temp: Int64;
begin
  if (Index < 0) or (Index >= FCount) then
    Error(@SListIndexError, Index);
  if Item <> FList^[Index] then
  begin
    Temp := FList^[Index];
    FList^[Index] := Item;
    if Temp <> 0 then
      Notify(Temp, lnDeleted);
    if Item <> 0 then
      Notify(Item, lnAdded);
  end;
end;

function TList64.Remove(Item: Int64): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

procedure TList64.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if Items[I] = 0 then
      Delete(I);
end;

procedure TList64.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(@SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Pointer));
    FCapacity := NewCapacity;
  end;
end;

procedure TList64.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(@SListCountError, NewCount);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Pointer), 0)
  else
    for I := FCount - 1 downto NewCount do
      Delete(I);
  FCount := NewCount;
end;

procedure QuickSort(SortList: PInt64List; L, R: Integer;
  SCompare: TListSortCompare);
var
  I, J: Integer;
  P, T: Int64;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1];
    repeat
      while SCompare(SortList^[I], P) < 0 do
        Inc(I);
      while SCompare(SortList^[J], P) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TList64.Sort(Compare: TListSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSort(FList, 0, Count - 1, Compare);
end;

function TList64.Extract(Item: Int64): Int64;
var
  I: Integer;
begin
  Result := 0;
  I := IndexOf(Item);
  if I >= 0 then
  begin
    Result := Item;
    FList^[I] := 0;
    Delete(I);
    Notify(Result, lnExtracted);
  end;
end;

procedure TList64.Notify(Ptr: Int64; Action: TListNotification);
begin
end;

procedure TList64.Assign(ListA: TList64; AOperator: TListAssignOp; ListB: TList64);
var
  I: Integer;
  LTemp, LSource: TList64;
begin
  // ListB given?
  if ListB <> nil then
  begin
    LSource := ListB;
    Assign(ListA);
  end
  else
    LSource := ListA;

  // on with the show
  case AOperator of

    // 12345, 346 = 346 : only those in the new list
    laCopy:
      begin
        Clear;
        Capacity := LSource.Capacity;
        for I := 0 to LSource.Count - 1 do
          Add(LSource[I]);
      end;

    // 12345, 346 = 34 : intersection of the two lists
    laAnd:
      for I := Count - 1 downto 0 do
        if LSource.IndexOf(Items[I]) = -1 then
          Delete(I);

    // 12345, 346 = 123456 : union of the two lists
    laOr:
      for I := 0 to LSource.Count - 1 do
        if IndexOf(LSource[I]) = -1 then
          Add(LSource[I]);

    // 12345, 346 = 1256 : only those not in both lists
    laXor:
      begin
        LTemp := TList64.Create; // Temp holder of 4 byte values
        try
          LTemp.Capacity := LSource.Count;
          for I := 0 to LSource.Count - 1 do
            if IndexOf(LSource[I]) = -1 then
              LTemp.Add(LSource[I]);
          for I := Count - 1 downto 0 do
            if LSource.IndexOf(Items[I]) <> -1 then
              Delete(I);
          I := Count + LTemp.Count;
          if Capacity < I then
            Capacity := I;
          for I := 0 to LTemp.Count - 1 do
            Add(LTemp[I]);
        finally
          LTemp.Free;
        end;
      end;

    // 12345, 346 = 125 : only those unique to source
    laSrcUnique:
      for I := Count - 1 downto 0 do
        if LSource.IndexOf(Items[I]) <> -1 then
          Delete(I);

    // 12345, 346 = 6 : only those unique to dest
    laDestUnique:
      begin
        LTemp := TList64.Create;
        try
          LTemp.Capacity := LSource.Count;
          for I := LSource.Count - 1 downto 0 do
            if IndexOf(LSource[I]) = -1 then
              LTemp.Add(LSource[I]);
          Assign(LTemp);
        finally
          LTemp.Free;
        end;
      end;
  end;
end;

function TList64.Add(Item: TDateTime): Integer;
var
  Value : Int64;
begin
  System.Move(Item, Value, SizeOf(TDateTime));
  Add(Value);
end;

function TList64.Add(Item: Integer): Integer;   
var
  Value : Int64;
begin
  Value := Item;
  Add(Value);
end;      

function TList64.Add(Item: Boolean): Integer;
var
  Value : Int64;
begin
  if Item then
    Value := 1
  else
    Value := 0;
  Add(Value);
end;

function TList64.GetMaxStatInt64: Int64;

type
  TDateStat = record
    Value : Int64;
    Count : Integer;
  end;
  TCompareArray = array of TDateStat;

var
  I : Integer;
  Stat : TCompareArray;
  MaxC, MaxN : Integer;
  
  procedure AddStat(Value : Int64);
  var
    J : Integer;
    C : Integer;
  begin
    for J := 0 to Length(Stat) - 1 do
    if Stat[J].Value = Value then
    begin
      Stat[J].Count := Stat[J].Count + 1;
      Exit;
    end;
    C := Length(Stat);
    SetLength(Stat, C + 1);
    Stat[C - 1].Value := Value;
    Stat[C - 1].Count := 0;
  end;
  
begin    
  Result := 0;
  if Count = 0 then
    Exit;
    
  SetLength(Stat, 0);
  for I := 0 to Count - 1 do
    AddStat(Self[i]);

  MaxC := Stat[0].Count;
  MaxN := 0;
  for I := 0 to Length(Stat) - 1 do
  if MaxC < Stat[I].Count then
  begin
    MaxC := Stat[I].Count;
    MaxN := I;
  end;
  Result := Stat[MaxN].Value;
end; 

function TList64.GetMaxStatDateTime: TDateTime;
var
  MaxValue : Int64;
begin
  MaxValue := MaxStatInt64;
  System.Move(MaxValue, Result, SizeOf(TDateTime));
end;

function TList64.GetMaxStatInteger: Integer;
begin
  Result := Integer(MaxStatInt64);
end;

function TList64.GetMaxStatBoolean: Boolean;
begin
  Result := MaxStatInt64 <> 0;
end;

end.
