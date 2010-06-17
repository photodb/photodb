unit uScript;

interface

uses Windows, SysUtils, Classes, uStringUtils;

const
  VALUE_TYPE_ERROR         = 0;
  VALUE_TYPE_STRING        = 1;
  VALUE_TYPE_INTEGER       = 2;
  VALUE_TYPE_BOOLEAN       = 4;
  VALUE_TYPE_FLOAT         = 8;
  VALUE_TYPE_STRING_ARRAY  = 16;
  VALUE_TYPE_INT_ARRAY     = 32;
  VALUE_TYPE_BOOL_ARRAY    = 64;
  VALUE_TYPE_FLOAT_ARRAY   = 128;
  VALUE_TYPE_VOID          = 256;

type
  TArrayOfString = array of string;
  TArrayOfInt = array of Integer;
  TArrayOfBool = array of Boolean;
  TArrayOfFloat = array of Extended;

type
  TScript = class;

  TValue = class(TObject)
  private
    FOwner : TScript;
  public
    AName : string;
    StrValue : string;
    FloatValue : Extended;
    IntValue : Integer;
    BoolValue : Boolean;
    IntArray : TArrayOfInt;
    StrArray : TArrayOfString;
    FloatArray : TArrayOfFloat;
    BoolArray : TArrayOfBool;
    ArrayLength : Integer;
    AType :Integer;            
    constructor Create(AOwner : TScript); overload;
    constructor CreateAsError(AOwner : TScript; Name : string); overload;
    procedure Assign(Value : TValue);
    procedure FromString(Value : string);
    function GetValueType(Value : string) : Integer;
  end;

  TFunctinStringIsIntegerObject = function(s : string) : integer of object;
  TFunctionIntegerIsIntegerObject = function(int : integer) : integer of object;
  TFunctionIsIntegerObject = function : integer of object;
  TFunctionIsBoolObject = function : Boolean of object;
  TFunctionIsStringObject = function : String of object;
  TFunctionIntegerIsStringObject = function(int : integer) : string of object;
  TFunctionStringIsStringObject = function(s : string) : string of object;
  TFunctionIsArrayStringsObject = function : TArrayOfString of object;

  TScriptStringFunction = record
    FType : integer;
    FName : string;
    FArgs : TArrayOfString;
    FBody : string;
  end;

  TScriptFunction = class(TObject)
  public
    Name : string;
    aType : integer;
    aFunction : Pointer;
    aObjFunction : TNotifyEvent;
    aObjFunctinStringIsInteger : TFunctinStringIsIntegerObject;
    aObjFunctionIntegerIsInteger : TFunctionIntegerIsIntegerObject;
    aObjFunctionIsInteger : TFunctionIsIntegerObject;
    aObjFunctionIsBool : TFunctionIsBoolObject;
    aObjFunctionIsString : TFunctionIsStringObject;
    aObjFunctionIsArrayStrings : TFunctionIsArrayStringsObject;
    aObjFunctionIntegerIsString : TFunctionIntegerIsStringObject;
    aObjFunctionStringIsString : TFunctionStringIsStringObject;
    ScriptStringFunction : TScriptStringFunction;
  end;

  TNamedValues = class(TObject)
  private
    FValues : TList;
    FOwner : TScript;
    function GetValueByIndex(Index: Integer): TValue;
    procedure SetValueByName(Index: string; const Value: TValue);
    function GetCount: Integer;
  public        
    function GetValueByName(Index: string): TValue;
    constructor Create(AOwner : TScript);
    destructor Destroy; override;
    procedure Remove(Name : string);
    procedure Clear;
    function Exists(Name : string; SearchInParent : Boolean = False) : Boolean;
    function GetByNameAndType(Name : string; AType : Integer) : TValue;
    property Items[Index: Integer]: TValue read GetValueByIndex; default;
    property Count : Integer read GetCount;
  end;

  TStringFunctions = class(TObject)
  private
    FScriptFunctions : TList;
    function GetFunctionByIndex(Index: Integer): TScriptFunction;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Register(AFunction : TScriptFunction; ReplaceExisted : Boolean = False);
    property Count : Integer read GetCount;
    property Items[Index: Integer]: TScriptFunction read GetFunctionByIndex; default;
  end;

  TScriptEnviroment = class;

  TScriptEnviromentInitProcedure = procedure(Enviroment : TScriptEnviroment);

  TScriptEnviroment = class(TObject)
  private
    FFunctions : TStringFunctions;
    FName : string;
    FInitProc : TScriptEnviromentInitProcedure;
  public
    constructor Create(AName : string);
    destructor Destroy; override;
    procedure SetInitProc(InitProc : TScriptEnviromentInitProcedure);
    property Name : string read FName;
    property Functions : TStringFunctions read FFunctions;
  end;

  TScriptEnviroments = class(TObject)
  private
    FEnviroments : TList;
    constructor Create;
    destructor Destroy; override;
  public
    class function Instance : TScriptEnviroments;
    function GetEnviroment(Name : string) : TScriptEnviroment;
  end;

  TCombinedEnviromentFunctionList = class(TObject)
  private
    FEnviroment1 : TScriptEnviroment;
    FEnviroment2 : TScriptEnviroment;
    function GetCount: Integer;
    function GetFunctionByIndex(Index: Integer): TScriptFunction;
  public
    constructor Create(Enviroment1, Enviroment2 : TScriptEnviroment);
    property Count : Integer read GetCount;
    property Items[Index: Integer]: TScriptFunction read GetFunctionByIndex; default;
  end;

  TScript = class(TObject)
  private
    FDescription : string;
    FNamedValues : TNamedValues;
    FID : String;
    FParentScript : TScript;
    FEnviroment : TScriptEnviroment; 
    FPrivateEnviroment : TScriptEnviroment;
    FCombinedEnviromentFunctionList : TCombinedEnviromentFunctionList;
    function GetScriptFunctions: TCombinedEnviromentFunctionList;
    function GetEnviroment: TScriptEnviroment;
    procedure SetEnviroment(const Value: TScriptEnviroment);
  public
    constructor Create(EnviromentName : string);
    destructor Destroy; override;
    property Description : string read FDescription write FDescription;
    property NamedValues : TNamedValues read FNamedValues;
    property ParentScript : TScript read FParentScript write FParentScript;
    property ScriptFunctions : TCombinedEnviromentFunctionList read GetScriptFunctions;
    property Enviroment : TScriptEnviroment read FEnviroment write SetEnviroment;
    property PrivateEnviroment : TScriptEnviroment read FPrivateEnviroment;
    property ID : string read FID write FID;
  end;


implementation

var
  ScriptEnviroments : TScriptEnviroments = nil;

{ TScript }

constructor TScript.Create(EnviromentName : string);
begin
  FID := '';  
  FParentScript := nil;
  FNamedValues := TNamedValues.Create(Self);
  FPrivateEnviroment := TScriptEnviroment.Create(''); //CREATE PRIVATE UNNAMED ENVIROMENT
  FEnviroment := TScriptEnviroments.Instance.GetEnviroment(EnviromentName);
  FCombinedEnviromentFunctionList := TCombinedEnviromentFunctionList.Create(FEnviroment, FPrivateEnviroment);

  FNamedValues.GetValueByName('$MB_OK').IntValue := MB_OK;
  FNamedValues.GetValueByName('$MB_OKCANCEL').IntValue := MB_OKCANCEL;
  FNamedValues.GetValueByName('$ID_OK').IntValue := ID_OK;
  FNamedValues.GetValueByName('$ID_CANCEL').IntValue := ID_CANCEL;
  FNamedValues.GetValueByName('$MB_ICONERROR').IntValue := MB_ICONERROR;
  FNamedValues.GetValueByName('$MB_ICONWARNING').IntValue := MB_ICONWARNING;  
  FNamedValues.GetValueByName('$MB_ICONINFORMATION').IntValue := MB_ICONINFORMATION;

  FNamedValues.GetValueByName('$LINK_TYPE_ID').IntValue := 0;
  FNamedValues.GetValueByName('$LINK_TYPE_ID_EXT').IntValue := 1;
  FNamedValues.GetValueByName('$LINK_TYPE_IMAGE').IntValue := 2;
  FNamedValues.GetValueByName('$LINK_TYPE_FILE').IntValue := 3;
  FNamedValues.GetValueByName('$LINK_TYPE_FOLDER').IntValue := 4;
  FNamedValues.GetValueByName('$LINK_TYPE_TXT').IntValue := 5;   
  FNamedValues.GetValueByName('$InvalidQuery').StrValue := #8;

end;

destructor TScript.Destroy;
begin
  FPrivateEnviroment.Free;
  FCombinedEnviromentFunctionList.Free;
  FNamedValues.Free;
  inherited;
end;

function TScript.GetEnviroment: TScriptEnviroment;
begin
  Result := FEnviroment;
end;

function TScript.GetScriptFunctions: TCombinedEnviromentFunctionList;
begin
  Result := FCombinedEnviromentFunctionList;
end;

procedure TScript.SetEnviroment(const Value: TScriptEnviroment);
begin
  FEnviroment := Value;
  FCombinedEnviromentFunctionList.FEnviroment1 := Value;
end;

{ TNamedValues }

procedure TNamedValues.Clear;
begin
  FValues.Free;
end;

constructor TNamedValues.Create(AOwner : TScript);
begin
  FOwner := AOwner;
  FValues := TList.Create;
end;

destructor TNamedValues.Destroy;
var
  I  : Integer;
begin      
  for I := 0 to FValues.Count - 1 do
    TValue(FValues[I]).Free;
  FValues.Free;
  inherited;
end;

function TNamedValues.Exists(Name: string; SearchInParent : Boolean = False): Boolean;
var
  I  : Integer;
begin
  Result := False;
  for I := 0 to FValues.Count - 1 do
    if TValue(FValues[I]).AName = Name then
    begin
      Result := True;
      Exit;
    end;

  if SearchInParent and (FOwner.ParentScript <> nil) then
    Result := FOwner.FParentScript.NamedValues.Exists(Name, SearchInParent);
end;

function TNamedValues.GetByNameAndType(Name: string;
  AType: Integer): TValue;
var
  I  : Integer;
begin
  Result := nil;
  for I := 0 to FValues.Count - 1 do
    if (TValue(FValues[I]).AName = Name) and (TValue(FValues[I]).AType and AType > 0) then
    begin
      Result := FValues[I];
      Exit;
    end;

  if FOwner.ParentScript <> nil then
    Result := FOwner.ParentScript.FNamedValues.GetByNameAndType(Name, AType);
end;

function TNamedValues.GetCount: Integer;
begin
  Result := FValues.Count;
end;

function TNamedValues.GetValueByIndex(Index: Integer): TValue;
begin
  if (Index > -1) and (Index < FValues.Count) then
    Result := FValues[Index]
  else
    Result := TValue.CreateAsError(FOwner, '');
end;

function TNamedValues.GetValueByName(Index: string): TValue;
var
  I  : Integer;
begin
  for I := 0 to FValues.Count - 1 do
    if TValue(FValues[I]).AName = Index then
    begin
      Result := FValues[I];
      Exit;
    end;

  if FOwner.ParentScript <> nil then
    Result := FOwner.ParentScript.NamedValues.GetValueByName(Index)
  else
    Result := FValues[FValues.Add(TValue.CreateAsError(FOwner, Index))];
end;

procedure TNamedValues.Remove(Name: string);
var
  I  : Integer;
begin
  for I := 0 to FValues.Count - 1 do
    if TValue(FValues[I]).AName = Name then
    begin
      TValue(FValues[I]).Free;
      FValues.Delete(I);
      Exit;
    end; 
end;

procedure TNamedValues.SetValueByName(Index: string; const Value: TValue);
begin

end;

{ TValue }

procedure TValue.Assign(Value: TValue);
begin
  StrValue := Value.StrValue;
  FloatValue := Value.FloatValue;
  IntValue := Value.IntValue;
  BoolValue := Value.BoolValue;
  IntArray := Copy(Value.IntArray);
  StrArray := Copy(Value.StrArray);
  FloatArray := Copy(Value.FloatArray);
  BoolArray := Copy(Value.BoolArray);
  ArrayLength := Value.ArrayLength;
  AType := Value.AType;
end;

constructor TValue.Create(AOwner: TScript);
begin
  FOwner := AOwner;
end;

constructor TValue.CreateAsError(AOwner : TScript; Name : string);
begin
  FOwner := AOwner;
  AName := Name;
  AType := VALUE_TYPE_ERROR;
end;

procedure TValue.FromString(Value: string);
begin
 case GetValueType(Value) of
  VALUE_TYPE_INTEGER:
   begin
    aType := VALUE_TYPE_INTEGER;
    IntValue := StrToIntDef(Value,0);
   end;
  VALUE_TYPE_FLOAT:    
   begin
    aType := VALUE_TYPE_FLOAT;
    FloatValue := StrToFloatDef(ConvertUniversalFloatToLocal(Value), 0);
   end;
  VALUE_TYPE_STRING:
   begin
    aType := VALUE_TYPE_STRING;
    if Value <> '""' then
      StrValue := AnsiDequotedStr(Value, '"')
    else
      StrValue:='';
   end;
  VALUE_TYPE_BOOLEAN:
   begin
    aType:=VALUE_TYPE_BOOLEAN;
    BoolValue := Value = 'true';
   end;
 end;
end;

function TValue.GetValueType(Value: string): Integer;
begin
  Result:=VALUE_TYPE_ERROR;
  if StrToIntDef(Value,-1) = StrToIntDef(Value,1) then
    Result := VALUE_TYPE_INTEGER
  else if (Value='true') or (Value='false') then
    Result := VALUE_TYPE_BOOLEAN
  //else if (Length(Value)>1) and (Value[1]=Value[Length(Value)]) and (Value[1]='"') and (PosExS('+',Value) = 0) then
  else if StrToFloatDef(ConvertUniversalFloatToLocal(Value), -1) = StrToFloatDef(ConvertUniversalFloatToLocal(Value), 1) then
    Result := VALUE_TYPE_FLOAT
  else
    Result := VALUE_TYPE_STRING
end;

{ TScriptEnviroments }

constructor TScriptEnviroments.Create;
begin
  FEnviroments := TList.Create;
end;

destructor TScriptEnviroments.Destroy;
var
  I : integer;
begin
  for I := 0 to FEnviroments.Count - 1 do
    TScriptEnviroment(FEnviroments[I]).Free;

  FEnviroments.Free;
  inherited;
end;

function TScriptEnviroments.GetEnviroment(Name: string): TScriptEnviroment;
var
  I : integer;
begin
  for I := 0 to FEnviroments.Count - 1 do
    if TScriptEnviroment(FEnviroments[I]).Name = Name then
    begin
      Result := FEnviroments[I];
      if Assigned(Result.FInitProc) then
      begin
        Result.FInitProc(Result);
        Result.FInitProc := nil;
      end;
      Exit;
    end;

  Result := FEnviroments[FEnviroments.Add(TScriptEnviroment.Create(Name))];
end;

class function TScriptEnviroments.Instance: TScriptEnviroments;
begin
  if ScriptEnviroments = nil then
    ScriptEnviroments := TScriptEnviroments.Create;

  Result := ScriptEnviroments;
end;

{ TScriptEnviroment }

constructor TScriptEnviroment.Create(AName: string);
begin
  FInitProc := nil;
  Fname := AName;
  FFunctions := TStringFunctions.Create;
end;

destructor TScriptEnviroment.Destroy;
begin
  FFunctions.Free;
  inherited;
end;

procedure TScriptEnviroment.SetInitProc(
  InitProc: TScriptEnviromentInitProcedure);
begin
  FInitProc := InitProc;
end;

{ TStringFunctions }

constructor TStringFunctions.Create;
begin
  FScriptFunctions := TList.Create;
end;

destructor TStringFunctions.Destroy;
var
  I : Integer;
begin
  for I := 0 to FScriptFunctions.Count - 1 do
    FreeMem(FScriptFunctions[I]);
  FScriptFunctions.Free;
  inherited;
end;

function TStringFunctions.GetCount: Integer;
begin
  Result := FScriptFunctions.Count;
end;

function TStringFunctions.GetFunctionByIndex(Index: Integer): TScriptFunction;
begin
  if (Index > -1) and (Index < FScriptFunctions.Count) then
    Result := TScriptFunction(FScriptFunctions[Index])
  else
    raise EListError.CreateFmt('Invalid Index: %d', [Index]);
end;

procedure TStringFunctions.Register(AFunction: TScriptFunction; ReplaceExisted : Boolean = False);
var
  I : Integer;
begin
  for I := 0 to FScriptFunctions.Count - 1 do
    if TScriptFunction(FScriptFunctions[I]).Name = AFunction.Name then
    begin
      if ReplaceExisted then
      begin
        TScriptFunction(FScriptFunctions[I]).Free;
        FScriptFunctions.Delete(I);
        Break;
      end else
        raise Exception.CreateFmt('Function with name "%s" already exists!', [AFunction.Name]);
    end;

  FScriptFunctions.Add(AFunction);
end;

{ TCombinedEnviromentFunctionList }

constructor TCombinedEnviromentFunctionList.Create(Enviroment1,
  Enviroment2: TScriptEnviroment);
begin
  FEnviroment1 := Enviroment1;
  FEnviroment2 := Enviroment2;
end;

function TCombinedEnviromentFunctionList.GetCount: Integer;
begin
  Result := FEnviroment1.Functions.Count + FEnviroment2.Functions.Count;
end;

function TCombinedEnviromentFunctionList.GetFunctionByIndex(
  Index: Integer): TScriptFunction;
begin
  if (Index > -1) and (Index < Count) then
  begin
    if Index < FEnviroment1.FFunctions.Count then
      Result := FEnviroment1.FFunctions[Index]
    else         
      Result := FEnviroment2.FFunctions[Index - FEnviroment1.FFunctions.Count]
  end else
    Exception.CreateFmt('Index out of range : %d', [Index]);
end;

end.
