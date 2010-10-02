unit UnitScripts;

interface

{$DEFINE USEDEBUG}

{$DEFINE USEDLL}
//{$DEFINE EXT}

{$IFDEF USEDLL}

//{$IFNDEF USEDLL}

{$ELSE}

{$ENDIF}

uses Windows, Menus, SysUtils, Graphics, ShellAPI, StrUtils, Dialogs,
     Classes, Controls, Registry, ShlObj, Forms, StdCtrls, uScript, uStringUtils,
     uMemory, uGOM;

type
  TMenuItemW = class(TMenuItem)
  private
    { Private declarations }
  public
    Script : string;
    TopItem : TMenuItem;
    constructor Create(aOwner : TComponent); override;
    { Public declarations }
  end;


  type
  TSDriveState =(DSS_NO_DISK, DSS_UNFORMATTED_DISK, DSS_EMPTY_DISK,
    DSS_DISK_WITH_FILES);

  TScriptFunctionArray = array of TScriptFunction;

  TInitScriptFunction = function(Script : String) : string;
  TSimpleProcedure = procedure;
  TProcedureInteger = procedure(int : Integer);
  TProcedureIntegerInteger = procedure(int1, int2 : Integer);
  TProcedureStringString = procedure(A,B : string);
  TFunctionString = function : string;
  TFunctionStringIsString = function(S : String) : string;
  TFunctionIntegerIsInteger = function(int : integer) : integer;
  TFunctionInteger = function : integer;
  TProcedureObject = procedure(Sender : TObject) of object;
  TProcedureString = procedure(S : String);
  TProcedureIntegerString = procedure(int : Integer; S : String);
  TProcedureWriteString = function(S : String) : string;
  TFunctionIntegerIntegerIsInteger = function(int1, int2 : integer) : integer;
  TFunctionStringStringIsString = function(S1,S2 : String) : String;
  TFunctionStringStringIsInteger = function(S1,S2 : String) : integer;
  TFunctionStringStringIsBool = function(S1,S2 : String) : Boolean;
  TFunctionStringStringIsArrayString = function(S1,S2 : String) : TArrayOfString;
  TFunctionStringIsArrayString = function(S : String) : TArrayOfString;
  TFunctionIsArrayString = function : TArrayOfString;
  TFunctionArrayStringIsInteger = function(aArray : TArrayOfString) : integer;
  TProcedureArrayString = procedure(aArray : TArrayOfString);
  TFunctionArrayStringIntegerIsString = function(aArray : TArrayOfString; int : integer) : string;
  TFunctionCreateItem = function (aOwner: TMenuItem; Caption, Icon, Script: string; Default : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
  TFunctionCreateItemDef = function (aOwner: TMenuItem; Caption, Icon, Script: string; Default, Enabled : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
  TFunctionCreateItemDefChecked = function (aOwner: TMenuItem; Caption, Icon, Script: string; Default, Enabled, Checked : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
  TFunctionIntegerIsString = function(int : integer) : string;
  TFunctionBooleanIsBoolean = function(Bool : Boolean) : Boolean;
  TFunctionIsBoolean = function : Boolean;
  TFunctionStringIsBoolean = function(S : String) : Boolean;
  TFunctionAddIcon = function(Path : string; ImageList : TImageList; var IconsCount : integer) : integer;
  TProcedureScript = procedure(var Script : TScript);
  TProcedureBoolean = procedure(Bool : Boolean);
  TFunctionStringIsInteger = function(S : String) : integer;
  TProcedureClear = procedure(aOwner: TMenuItem);
  TFunctionArrayIntegerIsInteger = function(aArray : TArrayOfInt) : integer;
  TFunctionArrayIntegerIntegerIsInteger = function(aArray : TArrayOfInt; int : integer) : integer;
  TProcedureArrayIntegerIntegerInteger = procedure(aArray : TArrayOfInt; index, value : integer);
  TProcedureVarArrayIntegerInteger = procedure(var aArray : TArrayOfInt; int : integer);
  TFunctionIntegerIsArrayInteger = function(int : integer) : TArrayOfInt;
  TProcedureVarArrayStringString = procedure(var aArray : TArrayOfString; S : string);
  TFunctionStringIntegerIntegerIsInteger = function(s : string; int1, int2 : integer) : string;

  TFunctionFloatIsFloat = function(x : Extended) : Extended;

  TProcedureScriptStringW = procedure(Sender : TMenuItemW; var aScript : TScript; AlternativeCommand : string; var ImagesCount : integer; ImageList : TImageList; OnClick : TNotifyEvent = nil; s : string = '');
  TFunctionStringStringIntegerIsInteger = function(s1, s2 : string; int : integer) : integer;

  TProcedureStringStringString = procedure(s1, s2, s3 : string);
  TProcedureStringStringInteger = procedure(s1, s2 : string; int : integer);
  TProcedureStringStringBoolean = procedure(s1, s2 : string; b : boolean);

  TFunctionStringStringStringIsString = function(s1, s2, s3 : string) : string;
  const
    F_TYPE_FUNCTION_OF_SCRIPT = -1;
    F_TYPE_PROCEDURE_NO_PARAMS = 0;
    F_TYPE_FUNCTION_IS_STRING = 1;
    F_TYPE_PROCEDURE_STRING_STRING = 2;
    F_TYPE_PROCEDURE_INTEGER = 3;
    F_TYPE_FUNCTION_IS_INTEGER =  4;
    F_TYPE_OBJ_PROCEDURE_TOBJECT = 5;
    F_TYPE_PROCEDURE_INTEGER_INTEGER = 6;
    F_TYPE_PROCEDURE_STRING = 7;
    F_TYPE_PROCEDURE_INTEGER_STRING = 8;
    F_TYPE_FUNCTION_STRING_IS_STRING = 9;
    F_TYPE_FUNCTION_INTEGER_IS_INTEGER = 10;
    F_TYPE_PROCEDURE_WRITE_STRING = 11;
    F_TYPE_FUNCTION_INTEGER_INTEGER_IS_INTEGER = 12;
    F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING = 13;
    F_TYPE_FUNCTION_ARRAYSTRING_INTEGER_IS_STRING = 14;
    F_TYPE_FUNCTION_ARRAYSTRING_IS_INTEGER = 15;
    F_TYPE_FUNCTION_CREATE_ITEM = 16;
    F_TYPE_FUNCTION_INTEGER_IS_STRING = 17;
    F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING = 18;
    F_TYPE_FUNCTION_STRING_IS_INTEGER_OBJECT = 19;
    F_TYPE_FUNCTION_CREATE_PARENT_ITEM = 20;
    F_TYPE_FUNCTION_BOOLEAN_IS_BOOLEAN = 21;
    F_TYPE_FUNCTION_IS_BOOLEAN = 22;
    F_TYPE_FUNCTION_STRING_IS_BOOLEAN = 23;
    F_TYPE_FUNCTION_STRING_STRING_IS_STRING = 24;
    F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER = 25;
    F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN = 26;
    F_TYPE_FUNCTION_ADD_ICON = 27;
    F_TYPE_PROCEDURE_TSCRIPT = 28;
    F_TYPE_PROCEDURE_BOOLEAN = 29;
    F_TYPE_FUNCTION_STRING_IS_INTEGER = 30;
    F_TYPE_FUNCTION_IS_ARRAYSTRING = 31;
    F_TYPE_FUNCTION_ARRAYINTEGER_INTEGER_IS_INTEGER = 32;
    F_TYPE_FUNCTION_ARRAYINTEGER_IS_INTEGER = 33;
    F_TYPE_PROCEDURE_ARRAYINTEGER_INTEGER_INTEGER = 34;
    F_TYPE_PROCEDURE_VAR_ARRAYINTEGER_INTEGER = 35;
    F_TYPE_FUNCTION_INTEGER_IS_ARRAYINTEGER = 36;
    F_TYPE_PROCEDURE_VAR_ARRAYSTRING_STRING = 37;
    F_TYPE_PROCEDURE_CLEAR = 38;
    F_TYPE_FUNCTION_CREATE_ITEM_DEF = 39;
    F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED = 40;
    F_TYPE_FUNCTION_IS_INTEGER_OBJECT = 41;
    F_TYPE_FUNCTION_INTEGER_IS_INTEGER_OBJECT = 42;
    F_TYPE_FUNCTION_INTEGER_IS_STRING_OBJECT = 44;
    F_TYPE_FUNCTION_STRING_IS_STRING_OBJECT = 45;
    F_TYPE_FUNCTION_IS_ARRAY_STRING_OBJECT = 46;
    F_TYPE_FUNCTION_IS_BOOL_OBJECT = 47;
    F_TYPE_FUNCTION_IS_STRING_OBJECT = 48;
    F_TYPE_PROCEDURE_ARRAYSTRING = 49;
    F_TYPE_FUNCTION_FLOAT_IS_FLOAT = 50;
    F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING = 51;
    F_TYPE_PROCEDURE_TSCRIPT_STRING_W = 52;
    F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER = 53;
    F_TYPE_PROCEDURE_STRING_STRING_STRING  = 54;
    F_TYPE_PROCEDURE_STRING_STRING_INTEGER  = 55;
    F_TYPE_PROCEDURE_STRING_STRING_BOOLEAN = 56;

    F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING = 57;
    F_TYPE_FUNCTION_DEBUG_START = 58;
    F_TYPE_FUNCTION_DEBUG_END = 59;
    F_TYPE_FUNCTION_REGISTER_SCRIPT = 60;
    F_TYPE_FUNCTION_LOAD_VARS = 61;
    F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED_SUBTAG = 62;
    F_TYPE_FUNCTION_SAVE_VAR = 63;
    F_TYPE_FUNCTION_DELETE_VAR = 64;


//MessageBox
   procedure ExecuteScript(Sender : TMenuItemW; aScript : TScript; AlternativeCommand : string; var ImagesCount : integer; ImageList : TImageList; OnClick : TNotifyEvent = nil);
   procedure LoadItemVariables(aScript : TScript; Sender : TMenuItem);
   procedure LoadMenuFromScript(MenuItem : TMenuItem; ImageList : TImageList; Script : string; var aScript : TScript; OnClick : TNotifyEvent; var ImagesCount : integer; initialize : boolean);
   procedure SetNamedValue(const aScript : TScript; const ValueName, AValue : string);
   procedure SetNamedValueStr(const aScript : TScript; const ValueName, AValue : string);
   procedure SetNamedValueFloat(const aScript : TScript; const ValueName : string; const Value : Extended);
   procedure SetNamedValueArrayStrings(const aScript : TScript; const ValueName: string; const AValue : TArrayOfString);
   function CalcExpression(aScript : TScript; const Expression : string) : string;
   function GetNamedValueString(const aScript : TScript; const ValueName : string) : string;
   function GetNamedValueInt(const aScript : TScript; const ValueName : string; const Default : integer = 0) : integer;
   function GetNamedValueFloat(const aScript : TScript; const ValueName : string) : extended;

   procedure SetBoolAttr(aScript : TScript; Name : String; Value : boolean);
   procedure SetIntAttr(aScript : TScript; Name : String; Value :Integer);
   function Include(FileName : string) : string;
   function aFileExists(FileName : string) : boolean;
   procedure ExecuteScriptFile(Sender : TMenuItemW; var aScript : TScript; AlternativeCommand : string; var ImagesCount : integer; ImageList : TImageList; OnClick : TNotifyEvent = nil; FileName : string = '');

   function ReadScriptFile(FileName : string) : string;

   procedure AddScriptTextFunction(Enviroment : TScriptEnviroment; AFunction : TScriptStringFunction);
   procedure AddScriptFunction(Enviroment : TScriptEnviroment; const FunctionName : String; FunctionType : integer; FunctionPointer : Pointer);
   procedure AddScriptObjFunction(Enviroment : TScriptEnviroment; const FunctionName : String; FunctionType : integer; aFunction : TNotifyEvent);
   procedure AddScriptObjFunctionIsInteger(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctionIsIntegerObject);
   procedure AddScriptObjFunctionIsString(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctionIsStringObject);
   procedure AddScriptObjFunctionIsBool(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctionIsBoolObject);
   procedure AddScriptObjFunctionStringIsInteger(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctinStringIsIntegerObject);
   procedure AddScriptObjFunctionIntegerIsInteger(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctionIntegerIsIntegerObject);
   procedure AddScriptObjFunctionIntegerIsString(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctionIntegerIsStringObject);
   procedure AddScriptObjFunctionStringIsString(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctionStringIsStringObject);
   procedure AddScriptObjFunctionIsArrayStrings(Enviroment : TScriptEnviroment; const FunctionName : String; aFunction : TFunctionIsArrayStringsObject);

   function VarValue(aScript : TScript; const Variable : string; List : TListBox = nil) : string;
   procedure LoadBaseFunctions(Enviroment : TScriptEnviroment);
   procedure LoadFileFunctions(Enviroment : TScriptEnviroment);

   const
   //TODO: пиздец!
  DROPEFFECT_COPY   = 1;
  DROPEFFECT_MOVE   = 2;

  EndSymbol = '};';

  SHELL_FOLDERS_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\Explorer';
  QUICK_LAUNCH_ROOT = 'Software\MicroSoft\Windows\CurrentVersion\GrpConv';
//for debuging
const
   FTypesLength : integer = 63;
   FTypes : array[1..63] of string = (
     'F_TYPE_FUNCTION_OF_SCRIPT'
     ,'F_TYPE_PROCEDURE_NO_PARAMS'
     ,'F_TYPE_FUNCTION_IS_STRING'
     ,'F_TYPE_PROCEDURE_STRING_STRING'
     ,'F_TYPE_PROCEDURE_INTEGER'
     ,'F_TYPE_FUNCTION_IS_INTEGER'
     ,'F_TYPE_OBJ_PROCEDURE_TOBJECT'
     ,'F_TYPE_PROCEDURE_INTEGER_INTEGER'
     ,'F_TYPE_PROCEDURE_STRING'
     ,'F_TYPE_PROCEDURE_INTEGER_STRING'
     ,'F_TYPE_FUNCTION_STRING_IS_STRING'
     ,'F_TYPE_FUNCTION_INTEGER_IS_INTEGER'
     ,'F_TYPE_PROCEDURE_WRITE_STRING'
     ,'F_TYPE_FUNCTION_INTEGER_INTEGER_IS_INTEGER'
     ,'F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING'
     ,'F_TYPE_FUNCTION_ARRAYSTRING_INTEGER_IS_STRING'
     ,'F_TYPE_FUNCTION_ARRAYSTRING_IS_INTEGER'
     ,'F_TYPE_FUNCTION_CREATE_ITEM'
     ,'F_TYPE_FUNCTION_INTEGER_IS_STRING'
     ,'F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING'
     ,'F_TYPE_FUNCTION_STRING_IS_INTEGER_OBJECT'
     ,'F_TYPE_FUNCTION_CREATE_PARENT_ITEM'
     ,'F_TYPE_FUNCTION_BOOLEAN_IS_BOOLEAN'
     ,'F_TYPE_FUNCTION_IS_BOOLEAN'
     ,'F_TYPE_FUNCTION_STRING_IS_BOOLEAN'
     ,'F_TYPE_FUNCTION_STRING_STRING_IS_STRING'
     ,'F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER'
     ,'F_TYPE_FUNCTION_STRING_STRING_IS_BOOL'
     ,'F_TYPE_FUNCTION_ADD_ICON'
     ,'F_TYPE_PROCEDURE_TSCRIPT'
     ,'F_TYPE_PROCEDURE_BOOLEAN'
     ,'F_TYPE_FUNCTION_STRING_IS_INTEGER'
     ,'F_TYPE_FUNCTION_IS_ARRAYSTRING'
     ,'F_TYPE_FUNCTION_ARRAYINTEGER_INTEGER_IS_INTEGER'
     ,'F_TYPE_FUNCTION_ARRAYINTEGER_IS_INTEGER'
     ,'F_TYPE_PROCEDURE_ARRAYINTEGER_INTEGER_INTEGER'
     ,'F_TYPE_PROCEDURE_VAR_ARRAYINTEGER_INTEGER'
     ,'F_TYPE_FUNCTION_INTEGER_IS_ARRAYINTEGER'
     ,'F_TYPE_PROCEDURE_VAR_ARRAYSTRING_STRING'
     ,'F_TYPE_PROCEDURE_CLEAR'
     ,'F_TYPE_FUNCTION_CREATE_ITEM_DEF'
     ,'F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED'
     ,'F_TYPE_FUNCTION_IS_INTEGER_OBJECT'
     ,'F_TYPE_FUNCTION_INTEGER_IS_INTEGER_OBJECT'
     ,'F_TYPE_FUNCTION_INTEGER_IS_STRING_OBJECT'
     ,'F_TYPE_FUNCTION_STRING_IS_STRING_OBJECT'
     ,'F_TYPE_FUNCTION_IS_ARRAY_STRING_OBJECT'
     ,'F_TYPE_FUNCTION_IS_BOOL_OBJECT'
     ,'F_TYPE_FUNCTION_IS_STRING_OBJECT'
     ,'F_TYPE_PROCEDURE_ARRAYSTRING'
     ,'F_TYPE_FUNCTION_FLOAT_IS_FLOAT'
     ,'F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING'
     ,'F_TYPE_PROCEDURE_TSCRIPT_STRING_W '
     ,'F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER'
     ,'F_TYPE_PROCEDURE_STRING_STRING_STRING'
     ,'F_TYPE_PROCEDURE_STRING_STRING_INTEGER'
     ,'F_TYPE_PROCEDURE_STRING_STRING_BOOLEAN'
     ,'F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING'
     ,'F_TYPE_FUNCTION_DEBUG_START'
     ,'F_TYPE_FUNCTION_DEBUG_END'
     ,'F_TYPE_FUNCTION_REGISTER_SCRIPT'
     ,'F_TYPE_FUNCTION_LOAD_VARS'
     ,'F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED_SUBTAG'
);
const
   FTypesInt : array[1..63] of integer = (
-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45
     ,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62
);

type
   TScriptsManager = class(TObject)
   private
   public
     FScripts: TList;
     constructor Create;
     destructor Destroy; override;
     function AddScript(Script: TScript): string;
     procedure RemoveScript(ID: string);
     function ScriptExists(ID: string): Boolean;
     function GetScriptByID(ID: string): TScript;
   end;

{$EXTERNALSYM CoCreateGuid}
function CoCreateGuid(out guid: TGUID): HResult; stdcall;

const
  ole32    = 'ole32.dll';

   var
     InitScriptFunction : Pointer = nil;
     ScriptsManager : TScriptsManager = nil;

function CoCreateGuid; external ole32 name 'CoCreateGuid';
function ReadFile(FileName : string) : string;
function IsVariable(const s : string) : Boolean;

implementation

 uses UnitScriptsMath, UnitScriptsFunctions, DBScriptFunctions

 {$IFDEF USEDEBUG}
   ,UnitDebugScriptForm
 {$ENDIF}
 ;

/////////////////////////////////////////////////////////////////////////

function IsVariable(const s : string) : Boolean;
begin
  Result := (s <> '') and (s[1] = '$');
end;

function GetCID : string;
var
  CID : TGUID;
begin
 CoCreateGuid(CID);
 Result:=GUIDToString(CID);
end;

function GetValueType(const aScript : TScript; const Value : string) : integer;
var
  i : integer;

begin
 Result:=VALUE_TYPE_ERROR;
 if IsVariable(Value) then
 begin
  for i:=0 to aScript.NamedValues.Count - 1 do
  if aScript.NamedValues[i].aName=Value then
  begin
   Result:=aScript.NamedValues[i].aType;
   exit;
  end;
  if aScript.ParentScript<>nil then
  begin
   Result:=GetValueType(aScript.ParentScript, Value);
  end;
  exit;
 end;
 if StrToIntDef(Value,-1)=StrToIntDef(Value,1) then
 begin
  Result:=VALUE_TYPE_INTEGER;
  exit;
 end;
 if (Value='true') or (Value='false') then
 begin
  Result:=VALUE_TYPE_BOOLEAN;
  exit;
 end;
 if Length(Value)>1 then
 if (Value[1]=Value[Length(Value)]) and (Value[1]='"') then
 if PosExS('+',Value)=0 then
 begin
  Result:=VALUE_TYPE_STRING;
 end;
 ;
 if StrToFloatDef(ConvertUniversalFloatToLocal(Value),-1)=StrToFloatDef(ConvertUniversalFloatToLocal(Value),1) then
 begin
  Result:=VALUE_TYPE_FLOAT;
  exit;
 end;

end;

procedure SetNamedValueArrayStrings(const aScript : TScript; const ValueName: string; const AValue : TArrayOfString);
var
  Value : TValue;
begin
  if Trim(ValueName) = '' then
    Exit;

  Value := aScript.NamedValues.GetValueByName(ValueName);
  Value.aType := VALUE_TYPE_STRING_ARRAY;
  Value.StrArray := AValue;
end;

procedure SetNamedValueArrayInt(const aScript : TScript; const ValueName: string; const AValue : TArrayOfInt);
var
  Value : TValue;
begin
  if Trim(ValueName) = '' then
    Exit;

  Value := aScript.NamedValues.GetValueByName(ValueName);
  Value.aType := VALUE_TYPE_INT_ARRAY;
  Value.IntArray := AValue;
end;

procedure SetNamedValueArrayBool(const aScript : TScript; const ValueName: string; const AValue : TArrayOfBool);
var
  Value : TValue;
begin
  if Trim(ValueName) = '' then
    Exit;

  Value := aScript.NamedValues.GetValueByName(ValueName);
  Value.aType := VALUE_TYPE_BOOL_ARRAY;
  Value.BoolArray := AValue;
end;

procedure SetNamedValueArrayFloat(const aScript : TScript; const ValueName: string; const AValue : TArrayOfFloat);
var
  Value : TValue;
begin
  if Trim(ValueName) = '' then
    Exit;

  Value := aScript.NamedValues.GetValueByName(ValueName);
  Value.aType := VALUE_TYPE_FLOAT_ARRAY;
  Value.FloatArray := AValue;
end;

procedure SetNamedValueStr(const aScript : TScript; const ValueName, AValue : string);
begin
 {$IFNDEF EXT}
 SetNamedValue(aScript,ValueName,'"'+AnsiQuotedStr(AValue)+'"');
 {$ENDIF EXT}
end;

  procedure UnMakeFloat(var s : string);
  var
    j : integer;
    b : boolean;
  begin
   b:=true;
   for j:=1 to Length(s) do
   if s[j]=DecimalSeparator then
   begin
    s[j]:='.';
    b:=false;
   end;
   if b then s:=s+'.0';
  end;

procedure SetNamedValueFloat(const aScript : TScript; const ValueName : string; const Value : Extended);
var
  s : string;

begin
 s := FloatToStr(Value);
 UnMakeFloat(s);
 SetNamedValue(aScript,ValueName,s);
end;

procedure SetNamedValue(const aScript : TScript; const ValueName, AValue : string);
var
  Value, TmpValue : TValue;
begin
  if Trim(ValueName) = '' then
    Exit;

 Value := aScript.NamedValues.GetValueByName(ValueName);

 if IsVariable(AValue) then
 begin
   TmpValue := aScript.NamedValues.GetValueByName(AValue);
   Value.Assign(TmpValue);
 end else
   Value.FromString(AValue);
end;

procedure CopyVar(const ToScript : TScript; const FromScript : TScript; const ValueFrom, ValueTo : string);
var
  SValue, DValue : TValue;
begin
  SValue := FromScript.NamedValues.GetValueByName(ValueFrom);
  DValue := ToScript.NamedValues.GetValueByName(ValueTo);
  DValue.Assign(SValue);
end;

procedure SetNamedValueEx(const aScript : TScript; const FromScript : TScript; const ValueName, Value : string);
begin
  if Trim(ValueName) = '' then
    Exit;

 if IsVariable(Value) then
   CopyVar(aScript, FromScript, Value, ValueName)
 else
   aScript.NamedValues.GetValueByName(ValueName).FromString(Value);
end;

function GetNamedValueInt(const aScript : TScript; const ValueName : string; const Default : Integer = 0) : integer;
var
  Value : TValue;
begin
  Value := aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_INTEGER);
  if Value <> nil then
    Result := Value.IntValue
  else
    Result := StrToIntDef(ValueName, Default);
end;

function GetNamedValueFloat(const aScript : TScript; const ValueName : string) : Extended;
var
  Value : TValue;
begin
  Value := aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_INTEGER or VALUE_TYPE_FLOAT);
  if Value <> nil then
    Result := Value.IntValue
  else
    Result := StrToFloatDef(ConvertUniversalFloatToLocal(ValueName), 0);
end;

function GetNamedValueBool(const aScript : TScript; const ValueName : string) : boolean;
var
  Value : TValue;
begin
  Value := aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_BOOLEAN);
  if Value <> nil then
    Result := Value.BoolValue
  else
    Result := ValueName = 'true';
end;

function GetNamedValueArrayString(const aScript : TScript; const ValueName : string) : TArrayOfString;
begin
  if aScript.NamedValues.Exists(ValueName) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_STRING_ARRAY).StrArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueArrayInt(const aScript : TScript; const ValueName : string) : TArrayOfInt;
begin
  if aScript.NamedValues.Exists(ValueName) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_INT_ARRAY).IntArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueArrayBool(const aScript : TScript; const ValueName : string) : TArrayOfBool;
begin
  if aScript.NamedValues.Exists(ValueName) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_BOOL_ARRAY).BoolArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueArrayFloat(const aScript : TScript; const ValueName : string) : TArrayOfFloat;
begin
  if aScript.NamedValues.Exists(ValueName) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_FLOAT_ARRAY).FloatArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueString(const aScript : TScript; const ValueName : string) : string;
var
  Value : TValue;
begin
  Result:='';
  if not IsVariable(ValueName) and (ValueName <> '') and (ValueName[1]='"') and (ValueName[Length(ValueName)]='"') then
    Result:=AnsiDequotedStr(ValueName, '"')
  else
  begin
    Value := aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_STRING);
    if Value <> nil then
      Result := Value.StrValue;
  end;
end;

function PosExR(const SubStr: Char; const Str: string; const index: Integer = 1): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := index to Length(Str) do
  begin
    if not CharInSet(Str[I], ['0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_', ' ', '$', '=']) then
      Exit;
    if Str[I] = SubStr then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function PosNext(const SubStr : string; const Str : string; const index : integer = 1) : integer;
var
  i : integer;
  s : string;
begin
 Result:=0;
 for i:=index to Length(Str)-1 do
 begin
  if Str[i]=';' then continue;
  if (Str[i]=#32) and (Str[i+1]<>#32) then
  begin
   s:=Copy(Str,i+1,Length(SubStr));
   if s=SubStr then Result:=i;
  end else exit;
 end;
end;

function PosExK(const SubStr : string; const Str : string; index : integer = 1) : integer;
var
  i : integer;
  n : boolean;
  ls : integer;
  TmpS : string;
begin
 n:=false;
 Result:=0;
 ls:=Length(SubStr);
 if index<1 then index:=1;
 for i:=index to Length(Str) do
 begin
   TmpS := Copy(Str,i,Ls);
  if (TmpS=SubStr) and (not n) then
  begin
   Result:=i;
   exit;
  end;
  if i=index then continue;
  if (Str[i]='"') and not n then
  begin
   n:=true;
   continue;
  end;
  if (Str[i]='"') and n then
  begin
   n:=false;
   continue;
  end;
  if (TmpS=SubStr) and (not n) then
  begin
   Result:=i;
   exit;
  end;
 end;
end;




/////////////////////////////////////////////////////////////////////////


function GetFunctionName(aFunction : string) : string;
var
  fb, fe, i, r, p : integer;
begin
 p:=0;
 r:=PosExR('=',aFunction,1);
 if r<>0 then
 Delete(aFunction,1,r);
 for i:=1 to Length(aFunction) do
 if aFunction[i]=' ' then p:=i else break;
 Delete(aFunction,1,p);
 fb:=1;
 fe:=0;
 if aFunction<>'' then
 if aFunction[1]<>'#' then
 fe:=PosExS('(',aFunction);
 if fe=0 then
 fe:=PosExS(';',aFunction,fe);
 if fe<>0 then Result:=Copy(aFunction,fb,fe-fb);
 for i:=Length(Result) downto 1 do
 if Result[i]=' ' then Delete(Result,i,1) else break;
end;

function OneParam(const aFunction : string) : string;
var
  fb, fe : integer;
begin
 fb:=Pos('(',aFunction);
 fe:=PosExK(')',aFunction,fb);
 Result:=Copy(aFunction,fb+1,fe-fb-1);
end;

function FirstParam(const aFunction : string) : string;
var
  fb, fe, p : integer;
begin
 fb:=Pos('(',aFunction);
 fe:=PosExS(');',aFunction,fb);
 p:=PosExS(',',aFunction,fb);
 if p>fe then p:=fe;
 Result:=Copy(aFunction,fb+1,p-fb-1);
end;

function SecondParam(const aFunction : string) : string;
var
  fb, fe, p : integer;
begin
 fb:=Pos('(',aFunction);
 fe:=PosExS(');',aFunction,fb);
 p:=PosExS(',',aFunction,fb);
 Result:=Copy(aFunction,p+1,fe-p-1);
end;

function ParamNO(const aFunction : string; const N : integer) : string;
var
  fb, {fe,} i, p, px, pold : integer;
begin
 fb:=Pos('(',aFunction);
 //fe:=PosExK(')',aFunction,fb);
 p:=fb-1;
 pold:=p;
 for i:=1 to N do
 begin
  pold:=p;
  p:=PosEx(',',aFunction,p+1);
  px:=PosEx(')',aFunction,p+1);
  if (px<p) or (p=0) then p:=px;
 end;
 if N=1 then inc(pold);
 Result:=Copy(aFunction,pold+1,p-pold-1);
end;

function RightEvalution(const aScript : TScript; Evalution : string) : boolean;
var
 _as, _bs : string;
 _ai, _bi : integer;
 _af, _bf : extended;
 _ab, _bb : boolean;

  function LeftOperand(const S : string) : string;
  var
    i : integer;
  begin
   Result:='';
   for i:=1 to Length(S) do
   if (S[i]='=') or ((S[i]='!') and (S[i+1]='=') and (i<=Length(S))) or (S[i]='<') or (S[i]='>') then
   begin
    Result:=Copy(S,1,i-1);
    exit;
   end;
  end;

  function RightOperand(const S : string) : string;
  var
    i : integer;
  begin
   Result:='';
   for i:=1 to Length(S) do
   if (S[i]='=') or ((S[i]='!') and (S[i+1]='=') and (i<=Length(S))) or (S[i]='<') or (S[i]='>') then
   begin
    if (S[i]='!') then Result:=Copy(S,i+2,Length(s)-i-2) else
    Result:=Copy(S,i+1,Length(s)-i);
    exit;
   end;
  end;

  function GetOperand(const S : string) : integer;
  var
    i : integer;
  begin
   Result:=0;
   for i:=1 to Length(S)-1 do
   if (S[i]='=') or ((S[i]='!') and (S[i+1]='=')) or (S[i]='<') or (S[i]='>') then
   begin
    if (S[i]='=') then Result:=1
    else if ((S[i]='!') and (S[i+1]='=')) then Result:=2
    else if (S[i]='<') then Result:=3
    else if (S[i]='>') then Result:=4;
   end;
  end;

begin
  Result:=False;
  if Evalution<>'' then
  if Evalution[1]='#' then
  begin
   Delete(Evalution,1,1);
   Result:=StringToFloatScript(Evalution,aScript)=1;
   exit;
  end;
  _as:=LeftOperand(Evalution);
  _bs:=RightOperand(Evalution);
  Case GetValueType(aScript,_as) of
   VALUE_TYPE_STRING  :
    begin
     _as:=GetNamedValueString(aScript,_as);
     _bs:=GetNamedValueString(aScript,_bs);
     Case GetOperand(Evalution) of
      1 : Result:=_as=_bs;
      2 : Result:=_as<>_bs;
      3 : Result:=CompareStr(_as,_bs)<0;
      4 : Result:=CompareStr(_as,_bs)>0;
     end;
    end;
   VALUE_TYPE_INTEGER :
    begin
     _ai:=GetNamedValueInt(aScript,_as);
     _bi:=GetNamedValueInt(aScript,_bs);
     Case GetOperand(Evalution) of
      1 : Result:=_ai=_bi;
      2 : Result:=_ai<>_bi;
      3 : Result:=_ai<_bi;
      4 : Result:=_ai>_bi;
     end;
    end;
   VALUE_TYPE_FLOAT   :
    begin
     _af:=GetNamedValueFloat(aScript,_as);
     _bf:=GetNamedValueFloat(aScript,_bs);
     Case GetOperand(Evalution) of
      1 : Result:=_af=_bf;
      2 : Result:=_af<>_bf;
      3 : Result:=_af<_bf;
      4 : Result:=_af>_bf;
     end;
    end;
   VALUE_TYPE_BOOLEAN   :
    begin
     _ab:=GetNamedValueBool(aScript,_as);
     _bb:=GetNamedValueBool(aScript,_bs);
     Case GetOperand(Evalution) of
      1 : Result:=_ab=_bb;
      2 : Result:=_ab<>_bb;
      3 : Result:=false;
      4 : Result:=false;
     end;
    end;

  end;
end;

procedure AddScriptTextFunctions(var aScript : TScript; Functions : string);
var
  funct, fname, _farg, fbody : string;
  farg : TArrayOfString;
  fb, fe, ps, _type, sb, se, bb, be, i : integer;
  Ftype : string;
  ScriptStringFunction : TScriptStringFunction;
begin
 if Length(Functions)<5 then exit;
 fb:=1;
 //fe:=Length(Functions);
 repeat
  fe:=PosExS(';',Functions,fb);
  funct:=Trim(Copy(Functions,fb,fe-fb+1));
  if funct<>'' then
  if funct[1]='.' then
  begin
   ps:=Pos(' ',funct);
   if ps>2 then
   begin
    Ftype:=Copy(funct,2,ps-2);
    _type:=VALUE_TYPE_ERROR;
    if Ftype='int' then _type:=VALUE_TYPE_INTEGER else
    if Ftype='string' then _type:=VALUE_TYPE_STRING else
    if Ftype='bool' then _type:=VALUE_TYPE_BOOLEAN else
    if Ftype='float' then _type:=VALUE_TYPE_FLOAT else
    if Ftype='string[]' then _type:=VALUE_TYPE_STRING_ARRAY else
    if Ftype='int[]' then _type:=VALUE_TYPE_INT_ARRAY else
    if Ftype='bool[]' then _type:=VALUE_TYPE_BOOL_ARRAY else
    if Ftype='float[]' then _type:=VALUE_TYPE_FLOAT_ARRAY else
    if Ftype='void' then _type:=VALUE_TYPE_VOID;
    if _type<>VALUE_TYPE_ERROR then
    begin
     sb:=PosEx('(',funct,ps);
     fname:=Trim(Copy(funct,ps,sb-ps));
     se:=PosExK(')',funct,sb);
     _farg:=Copy(funct,sb+1,se-sb-1);
     bb:=PosEx('{',funct,se);
     be:=PosExS(EndSymbol,funct,bb);
     fbody:=Copy(funct,bb+1,be-bb-1);
     for i:=Length(_farg) downto 1 do
     if _farg[i]=' ' then Delete(_farg,i,1);
     for i:=1 to Length(_farg) do
     if _farg[i]=';' then _farg[i]:=' ';
     SetLength(farg,0);
 {$IFNDEF EXT}
     farg:=Copy(SpilitWordsW(_farg,','));
 {$ENDIF EXT}

     if fname<>'' then
     begin
      ScriptStringFunction.fType:=_type;
      ScriptStringFunction.fName:=fname;
      ScriptStringFunction.fArgs:=farg;
      ScriptStringFunction.fBody:=fbody;
      AddScriptTextFunction(aScript.Enviroment, ScriptStringFunction);
     end;
    end;
   end;
  end;
  fb:=fe+1;
 until (PosEx(';',Functions,fb)<1) or (fb>=Length(Functions));
end;

procedure ExecuteScript(Sender : TMenuItemW; aScript : TScript; AlternativeCommand : string; var ImagesCount : integer; ImageList : TImageList; OnClick : TNotifyEvent = nil);
var
  apos, af, fb, fe, i, J, n, r, ifb, ifsb, ifse, ifssb, ifsse, ifelex, ifelb, ifele, forb, forsb, forse, forssb, forsse, n1,n2,n3 : integer;
  s, script, Command, Func, s1, s2, s3, s4, s5, NVar, aIf, ifScript, aFor, forScript, forinit, foreval, forexevery, NewFunc, NewFunctions : String;
  ss1 : TArrayOfString;
  bb1 : TArrayOfBool;
  ii1 : TArrayOfInt;
  ff1 : TArrayOfFloat;
  Value : TValue;

  i1, i2, k : integer;
  f1, f2 : extended;
  b1, b2, b3 : boolean;
  SimpleProcedure : TSimpleProcedure;
  FunctionString : TFunctionString;
  FunctionInteger : TFunctionInteger;
  ProcedureStringString : TProcedureStringString;
  ProcedureInteger : TProcedureInteger;
  ProcedureIntegerInteger : TProcedureIntegerInteger;
  ProcedureString : TProcedureString;
  ProcedureIntegerString : TProcedureIntegerString;
  ProcedureObject : TProcedureObject;
  FunctionStringIsString : TFunctionStringIsString;
  FunctionIntegerIsInteger : TFunctionIntegerIsInteger;
  ProcedureWriteString : TProcedureWriteString;
  FunctionIntegerIntegerIsInteger : TFunctionIntegerIntegerIsInteger;
  FunctionStringStringIsArrayString : TFunctionStringStringIsArrayString;
  FunctionArrayStringIsInteger : TFunctionArrayStringIsInteger;
  FunctionArrayStringIntegerIsString : TFunctionArrayStringIntegerIsString;
  FunctionCreateItem : TFunctionCreateItem;
  FunctionIntegerIsString : TFunctionIntegerIsString;
  FunctionStringIsArrayString : TFunctionStringIsArrayString;
  FunctinStringIsIntegerObject : TFunctinStringIsIntegerObject;
  FunctionBooleanIsBoolean : TFunctionBooleanIsBoolean;
  FunctionIsBoolean : TFunctionIsBoolean;
  FunctionStringIsBoolean : TFunctionStringIsBoolean;
  FunctionStringStringIsString : TFunctionStringStringIsString;
  FunctionStringStringIsInteger : TFunctionStringStringIsInteger;
  FunctionStringStringIsBool : TFunctionStringStringIsBool;
  FunctionAddIcon : TFunctionAddIcon;
  ProcedureScript : TProcedureScript;
  ProcedureBoolean : TProcedureBoolean;
  FunctionStringIsInteger : TFunctionStringIsInteger;
  FunctionIsArrayString : TFunctionIsArrayString;

  FunctionArrayIntegerIsInteger : TFunctionArrayIntegerIsInteger;
  FunctionArrayIntegerIntegerIsInteger : TFunctionArrayIntegerIntegerIsInteger;
  ProcedureArrayIntegerIntegerInteger : TProcedureArrayIntegerIntegerInteger;
  ProcedureVarArrayIntegerInteger : TProcedureVarArrayIntegerInteger;
  FunctionIntegerIsArrayInteger : TFunctionIntegerIsArrayInteger;

  ProcedureVarArrayStringString : TProcedureVarArrayStringString;
  ProcedureClear : TProcedureClear;
  FunctionCreateItemDef : TFunctionCreateItemDef;
  FunctionCreateItemDefChecked : TFunctionCreateItemDefChecked;

  FunctionIsIntegerObject : TFunctionIsIntegerObject;
  FunctionIntegerIsIntegerObject : TFunctionIntegerIsIntegerObject;
  FunctionIntegerIsStringObject : TFunctionIntegerIsStringObject;
  FunctionStringIsStringObject : TFunctionStringIsStringObject;
  FunctionFloatIsFloat : TFunctionFloatIsFloat;

  ProcedureArrayString : TProcedureArrayString;

  FunctionStringIntegerIntegerIsInteger : TFunctionStringIntegerIntegerIsInteger;
  ProcedureScriptString : TProcedureScriptStringW;
  FunctionStringStringIntegerIsInteger : TFunctionStringStringIntegerIsInteger;

  ProcedureStringStringString : TProcedureStringStringString;
  ProcedureStringStringInteger : TProcedureStringStringInteger;
  ProcedureStringStringBoolean : TProcedureStringStringBoolean;

  FunctionStringStringStringIsString : TFunctionStringStringStringIsString;

  TempItem : TMenuItemW;
  aTempItem : TMenuItem;
  TempScript : TScript;
  pTempScript : TScript;
 {$IFDEF USEDEBUG}

  DebugScriptForm: TDebugScriptForm;
 {$ENDIF}
  LineCounter : integer;


 procedure DoExit;
 begin
  {$IFDEF USEDEBUG}

  if DebugScriptForm<>nil then
  begin
   if DebugScriptForm.Waitind then
   DebugScriptForm.Stop;
   if not DebugScriptForm.Working then
   if not DebugScriptForm.anil then
   begin
    DebugScriptForm.Release;
    if {UseFreeAfterRelease}true then DebugScriptForm.Free;
   end;
   DebugScriptForm:=nil;
  end;
  {$ENDIF}
 end;

begin
 LineCounter:=0;
 apos:=1;
 fb:=1;
// fe:=1;
 DebugScriptForm:=nil;

 if AlternativeCommand<>'' then script:=AlternativeCommand else
 begin
  if Sender<>nil then
  script:=Sender.Script else begin DoExit; exit; end;
 end;

 repeat
  inc(LineCounter);
  {$IFDEF USEDEBUG}
  if DebugScriptForm<>nil then
  begin
   DebugScriptForm.SetActiveLine(LineCounter);
   DebugScriptForm.Wait;
  end;
  {$ENDIF}
  af:=fb;

  r:=PosExR('=',script,fb);
  n:=PosExK(';',script,fb);
  if (r<n) and (r<>0) then
  begin
   NVar:=Trim(Copy(script,fb,r-fb));
  end else
  begin
   ifb:=PosEx('if',script,fb);
   ifsb:=PosExK('(',script,ifb);
   ifse:=PosExS(')',script,ifsb);
   ifssb:=PosExK('{',script,ifse);
   ifsse:=PosExS(EndSymbol,script,ifssb);

   if (n>ifb) and (ifb<>0) and (ifsb<>0) and (ifse<>0) and (ifssb<>0) and (ifsse<>0) then
   begin
    aIf:=Copy(script,ifsb+1,ifse-ifsb-1);
    ifScript:=Copy(script,ifssb+1,ifsse-ifssb-1);
    if RightEvalution(aScript,aIf) then
    begin
     ExecuteScript(Sender,aScript,ifScript,ImagesCount,ImageList,OnClick);
     ifelex:=PosNext('else',script,ifsse+1);
     if ifelex<>0 then
     begin
      ifelb:=PosExK('{',script,ifelex);
      ifele:=PosExS(EndSymbol,script,ifelb);
      fb:=ifele+2;
     end
     else
     fb:=ifsse+2;
     Continue;
    end else
    begin
     ifelex:=PosNext('else',script,ifsse+1);
     if ifelex<>0 then
     begin
      ifelb:=PosExK('{',script,ifelex);
      ifele:=PosExS(EndSymbol,script,ifelb);
      ifScript:=Copy(script,ifelb+1,ifele-ifelb-1);
      ExecuteScript(Sender,aScript,ifScript,ImagesCount,ImageList,OnClick);
      fb:=ifele+2;
      Continue;
     end else
     begin
      fb:=ifsse+2;
      Continue;
     end;
    end;
   end else
   begin
    forb:=PosEx('for',script,fb);
    forsb:=PosExK('(',script,forb);
    forse:=PosExS(')',script,forsb);
    forssb:=PosExK('{',script,forse);
    forsse:=PosExS(EndSymbol,script,forssb)+1;

    if (n>forb) and (forb<>0) and (forsb<>0) and (forse<>0) and (forssb<>0) then
    begin



     n1:=PosExK(';',script,forsb);
     n2:=PosExK(';',script,n1+1);
     if (n1<>0) and (n2<>0) then
     begin
      foreval:=Copy(script,n1+1,n2-n1-1);
      forexevery:=Copy(script,n2+1,forse-n2-1)+';';
      forinit:=Copy(script,forsb+1,n1-forsb);

      if (forsse<>0) then
      begin
       afor:=Copy(script,forsb+1,forse-forsb)+';';
       forScript:=Copy(script,forssb+1,forsse-forssb-2);//+';';
       ExecuteScript(Sender,aScript,forinit,ImagesCount,ImageList,OnClick);
       While RightEvalution(aScript,foreval) do
       begin
        ExecuteScript(Sender,aScript,forScript,ImagesCount,ImageList,OnClick);
        ExecuteScript(Sender,aScript,forexevery,ImagesCount,ImageList,OnClick);
       end;
       fb:=forsse+2;
       continue;
      end;
     end;

    end

   end;
  end;
  if n<>0 then fe:=n else fe:=Length(script);
  Command:=Copy(script,fb,fe-fb+1);
  if Copy(Trim(Command),1,10)='@functions' then
  begin

   fe:=PosEx('@end',script,fb+10);
   fb:=PosEx('@functions',script,fb);
   if fe<1 then fe:=Length(script);
   NewFunctions:=Copy(script,fb+10,fe-fb-10);
   Command:=NewFunctions;
   AddScriptTextFunctions(aScript,Command);
   fb:=fe+4;
   Continue;
  end;
  Func:=GetFunctionName(Command);

  NewFunc:=CalcExpression(aScript,Func);
  if (NewFunc<>Func) and (r<>0) then
  begin
   Func:=GetFunctionName(NewFunc);
   Command:=Copy(script,af,r-af+1)+NewFunc;

  end;

  fb:=fe+1;
  for i:=0 to aScript.ScriptFunctions.Count - 1 do
  begin
   if aScript.ScriptFunctions[i].Name=Func then
   begin
    Case aScript.ScriptFunctions[i].aType of


    F_TYPE_FUNCTION_DEBUG_START :
    begin
    {$IFDEF USEDEBUG}
     if DebugScriptForm=nil then
     begin
      Application.CreateForm(TDebugScriptForm, DebugScriptForm);
      DebugScriptForm.LoadScript(script);
      DebugScriptForm.SetScript(@aScript);
      DebugScriptForm.Show;
      DebugScriptForm.SetFocus;
      SetForegroundWindow(DebugScriptForm.Handle)
     end;
    {$ENDIF}
    end;

    F_TYPE_FUNCTION_DEBUG_END :
    begin
     DoExit;
    end;

    F_TYPE_FUNCTION_REGISTER_SCRIPT :
    begin
     if r<>0 then SetNamedValueStr(aScript,NVar,ScriptsManager.AddScript(aScript));
    end;

    F_TYPE_FUNCTION_LOAD_VARS :
    begin
      s1:=GetNamedValueString(aScript,OneParam(Command));
      pTempScript:=ScriptsManager.GetScriptByID(s1);

      if pTempScript<>nil then
      begin
        aScript.ParentScript := pTempScript;
        aScript.Enviroment := pTempScript.Enviroment;

        for J := 0 to pTempScript.NamedValues.Count - 1 do
        begin
          Value :=  pTempScript.NamedValues[J];
          if not aScript.NamedValues.Exists(Value.AName) then
            aScript.NamedValues.GetValueByName(Value.AName).Assign(Value);
        end;
      end;
    end;

    F_TYPE_FUNCTION_DELETE_VAR :
    begin
     s1 := ParamNO(Command, 1);
     aScript.NamedValues.Remove(s1);
    end;

    F_TYPE_FUNCTION_SAVE_VAR :
    begin
     s1:=GetNamedValueString(aScript,ParamNO(Command,1));
     s2:=ParamNO(Command,2);
     pTempScript:=ScriptsManager.GetScriptByID(s1);
     pTempScript.NamedValues.GetValueByName(s2).Assign(aScript.NamedValues.GetValueByName(s2));
    end;

    F_TYPE_FUNCTION_OF_SCRIPT :
    begin
      TempScript := TScript.Create(aScript.Enviroment.Name);
      try
        for J:=0 to Length(aScript.ScriptFunctions[i].ScriptStringFunction.fArgs) - 1 do
        begin
          SetNamedValueEx(TempScript, aScript, aScript.ScriptFunctions[i].ScriptStringFunction.fArgs[J], ParamNo(Command, J + 1));
        end;

        ExecuteScript(Sender, TempScript, aScript.ScriptFunctions[i].ScriptStringFunction.fBody,ImagesCount,ImageList,OnClick);
        CopyVar(aScript, TempScript, '$Result', NVar);
      finally
        TempScript.Free;
      end;
    end;

    F_TYPE_PROCEDURE_CLEAR :
     begin
      @ProcedureClear:=aScript.ScriptFunctions[i].aFunction;
      if Sender<>nil then ProcedureClear(Sender);
     end;

    F_TYPE_FUNCTION_CREATE_ITEM_DEF :
     begin
      @FunctionCreateItemDef:=aScript.ScriptFunctions[i].aFunction;
      if Sender<>nil then
      begin
       s1:=GetNamedValueString(aScript,ParamNO(Command,1));
       s2:=GetNamedValueString(aScript,ParamNO(Command,2));
       i2:=GetNamedValueInt(aScript,ParamNO(Command,2),-1);
       if i2<>-1 then s2:=IntToStr(i2);
       s3:=GetNamedValueString(aScript,ParamNO(Command,3));
       b1:=GetNamedValueBool(aScript,ParamNO(Command,4));
       b2:=GetNamedValueBool(aScript,ParamNO(Command,5));
       i1:=GetNamedValueInt(aScript,ParamNO(Command,6));
       Sender.Add(FunctionCreateItemDef(Sender,s1,s2,s3,b1,b2,i1,ImageList,ImagesCount,OnClick));
      end;
     end;

    F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED :
     begin
      @FunctionCreateItemDefChecked:=aScript.ScriptFunctions[i].aFunction;
      if Sender<>nil then
      begin
       s1:=GetNamedValueString(aScript,ParamNO(Command,1));
       s2:=GetNamedValueString(aScript,ParamNO(Command,2));
       i2:=GetNamedValueInt(aScript,ParamNO(Command,2),-1);
       if i2<>-1 then s2:=IntToStr(i2);
       s3:=GetNamedValueString(aScript,ParamNO(Command,3));
       b1:=GetNamedValueBool(aScript,ParamNO(Command,4));
       b2:=GetNamedValueBool(aScript,ParamNO(Command,5));
       b3:=GetNamedValueBool(aScript,ParamNO(Command,6));
       i1:=GetNamedValueInt(aScript,ParamNO(Command,7));
       Sender.Add(FunctionCreateItemDefChecked(Sender,s1,s2,s3,b1,b2,b3,i1,ImageList,ImagesCount,OnClick));
      end;
     end;

    F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED_SUBTAG :
     begin
      @FunctionCreateItemDefChecked:=aScript.ScriptFunctions[i].aFunction;
      if Sender<>nil then
      begin
       s1:=GetNamedValueString(aScript,ParamNO(Command,1));
       s2:=GetNamedValueString(aScript,ParamNO(Command,2));
       i2:=GetNamedValueInt(aScript,ParamNO(Command,2),-1);
       if i2<>-1 then s2:=IntToStr(i2);
       s3:=GetNamedValueString(aScript,ParamNO(Command,3));
       b1:=GetNamedValueBool(aScript,ParamNO(Command,4));
       b2:=GetNamedValueBool(aScript,ParamNO(Command,5));
       b3:=GetNamedValueBool(aScript,ParamNO(Command,6));
       i1:=GetNamedValueInt(aScript,ParamNO(Command,7));
       i2:=GetNamedValueInt(aScript,ParamNO(Command,8));

       for k:=0 to Sender.Count-1 do
       if Sender.Items[k].Tag=i2 then
       begin
        Sender.Items[k].Add(FunctionCreateItemDefChecked(Sender,s1,s2,s3,b1,b2,b3,i1,ImageList,ImagesCount,OnClick));
       end;
      end;
     end;

    F_TYPE_FUNCTION_CREATE_ITEM :
     begin
      @FunctionCreateItem:=aScript.ScriptFunctions[i].aFunction;
      if Sender<>nil then
      begin
       s1:=GetNamedValueString(aScript,ParamNO(Command,1));
       s2:=GetNamedValueString(aScript,ParamNO(Command,2));
       i2:=GetNamedValueInt(aScript,ParamNO(Command,2),-1);
       if i2<>-1 then s2:=IntToStr(i2);
       s3:=GetNamedValueString(aScript,ParamNO(Command,3));
       b1:=GetNamedValueBool(aScript,ParamNO(Command,4));
       i1:=GetNamedValueInt(aScript,ParamNO(Command,5));
       Sender.Add(FunctionCreateItem(Sender,s1,s2,s3,b1,i1,ImageList,ImagesCount,OnClick));
      end;
     end;
    F_TYPE_FUNCTION_CREATE_PARENT_ITEM :
     begin
      @FunctionCreateItem:=aScript.ScriptFunctions[i].aFunction;
      if Sender<>nil then
      begin
       s1:=GetNamedValueString(aScript,ParamNO(Command,1));
       s2:=GetNamedValueString(aScript,ParamNO(Command,2));
       i2:=GetNamedValueInt(aScript,ParamNO(Command,2),-1);
       if i2<>-1 then s2:=IntToStr(i2);
       s3:=GetNamedValueString(aScript,ParamNO(Command,3));
       b1:=GetNamedValueBool(aScript,ParamNO(Command,4));
       i1:=GetNamedValueInt(aScript,ParamNO(Command,5));
       if Sender is TMenuItemW then
       if (Sender as TMenuItemW).TopItem<>nil then
       begin
        aTempItem:=(Sender as TMenuItemW).TopItem;
        aTempItem.Add(FunctionCreateItem(aTempItem,s1,s2,s3,b1,i1,ImageList,ImagesCount,OnClick));
       end;
      end;
     end;
    F_TYPE_FUNCTION_ADD_ICON :
     begin
      @FunctionAddIcon:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      i1:=FunctionAddIcon(s1,ImageList,ImagesCount);
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(i1));
     end;
    F_TYPE_PROCEDURE_WRITE_STRING :
     begin
      @ProcedureWriteString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      s1:=ProcedureWriteString(s1);
      insert(s1,script,n+1);
     end;
    F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING :
     begin
      @FunctionStringStringIsArrayString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,FirstParam(Command));
      s2:=GetNamedValueString(aScript,SecondParam(Command));
      if r<>0 then SetNamedValueArrayStrings(aScript,NVar,FunctionStringStringIsArrayString(s1,s2)) else
      FunctionStringStringIsArrayString(s1,s2);
     end;

    F_TYPE_FUNCTION_STRING_STRING_IS_STRING :
     begin
      @FunctionStringStringIsString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,FirstParam(Command));
      s2:=GetNamedValueString(aScript,SecondParam(Command));
      if r<>0 then SetNamedValueStr(aScript,NVar,FunctionStringStringIsString(s1,s2)) else
      FunctionStringStringIsString(s1,s2);
     end;

    F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER :
     begin
      @FunctionStringStringIsInteger:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,FirstParam(Command));
      s2:=GetNamedValueString(aScript,SecondParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionStringStringIsInteger(s1,s2))) else
      FunctionStringStringIsInteger(s1,s2);
     end;

    F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN :
     begin
      @FunctionStringStringIsBool:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,FirstParam(Command));
      s2:=GetNamedValueString(aScript,SecondParam(Command));
      b1:=FunctionStringStringIsBool(s1,s2);
      if b1 then s1:='true' else s1:='false';
      if r<>0 then SetNamedValue(aScript,NVar,s1);
     end;

    F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING:
     begin
      @FunctionStringIntegerIntegerIsInteger:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,ParamNO(Command,1));
      i1:=GetNamedValueInt(aScript,ParamNO(Command,2));
      i2:=GetNamedValueInt(aScript,ParamNO(Command,3));
      if r<>0 then SetNamedValueStr(aScript,NVar,FunctionStringIntegerIntegerIsInteger(s1,i1,i2)) else
      FunctionStringIntegerIntegerIsInteger(s1,i1,i2);
     end;

    F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER:
     begin
      @FunctionStringStringIntegerIsInteger:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,ParamNO(Command,1));
      s2:=GetNamedValueString(aScript,ParamNO(Command,2));
      i1:=GetNamedValueInt(aScript,ParamNO(Command,3));

      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionStringStringIntegerIsInteger(s1,s2,i1))) else
      FunctionStringStringIntegerIsInteger(s1,s2,i1);
     end;

    F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING:
     begin
      @FunctionStringStringStringIsString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,ParamNO(Command,1));
      s2:=GetNamedValueString(aScript,ParamNO(Command,2));
      s3:=GetNamedValueString(aScript,ParamNO(Command,3));
      if r<>0 then SetNamedValue(aScript,NVar,FunctionStringStringStringIsString(s1,s2,s3)) else
      FunctionStringStringStringIsString(s1,s2,s3);
     end;

    F_TYPE_PROCEDURE_VAR_ARRAYSTRING_STRING :
     begin
      @ProcedureVarArrayStringString:=aScript.ScriptFunctions[i].aFunction;
      NVar:=FirstParam(Command);
      ss1:=GetNamedValueArrayString(aScript,NVar);
      s1:=GetNamedValueString(aScript,SecondParam(Command));
      ProcedureVarArrayStringString(ss1,s1);
      SetNamedValueArrayStrings(aScript,NVar,ss1)
    end;

    F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING :
     begin
      @FunctionStringIsArrayString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      if r<>0 then SetNamedValueArrayStrings(aScript,NVar,FunctionStringIsArrayString(s1)) else
      FunctionStringIsArrayString(s1);
     end;
    F_TYPE_FUNCTION_IS_ARRAYSTRING :
     begin
      @FunctionIsArrayString:=aScript.ScriptFunctions[i].aFunction;
      if r<>0 then SetNamedValueArrayStrings(aScript,NVar,FunctionIsArrayString) else
      FunctionIsArrayString;
     end;
    F_TYPE_FUNCTION_ARRAYSTRING_INTEGER_IS_STRING :
     begin
      @FunctionArrayStringIntegerIsString:=aScript.ScriptFunctions[i].aFunction;
      ss1:=GetNamedValueArrayString(aScript,FirstParam(Command));
      i2:=GetNamedValueInt(aScript,SecondParam(Command));

      if r<>0 then SetNamedValueStr(aScript,NVar,FunctionArrayStringIntegerIsString(ss1,i2)) else
      FunctionArrayStringIntegerIsString(ss1,i2);
     end;
    F_TYPE_FUNCTION_ARRAYSTRING_IS_INTEGER :
     begin
      @FunctionArrayStringIsInteger:=aScript.ScriptFunctions[i].aFunction;
      ss1:=GetNamedValueArrayString(aScript,OneParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionArrayStringIsInteger(ss1))) else
      FunctionArrayStringIsInteger(ss1);
     end;

    F_TYPE_PROCEDURE_NO_PARAMS :
     begin
      @SimpleProcedure:=aScript.ScriptFunctions[i].aFunction;
      SimpleProcedure;
     end;

    F_TYPE_PROCEDURE_BOOLEAN :
     begin
      @ProcedureBoolean:=aScript.ScriptFunctions[i].aFunction;
      b1:=GetNamedValueBool(aScript,OneParam(Command));
      ProcedureBoolean(b1);
     end;

    F_TYPE_PROCEDURE_TSCRIPT :
     begin
      @ProcedureScript:=aScript.ScriptFunctions[i].aFunction;
      ProcedureScript(aScript);
     end;
    F_TYPE_PROCEDURE_TSCRIPT_STRING_W :
     begin
      @ProcedureScriptString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      if Sender<>nil then ProcedureScriptString(Sender,aScript,AlternativeCommand,ImagesCount,ImageList,OnClick,s1);
     end;

    F_TYPE_FUNCTION_IS_STRING :
     begin
      @FunctionString:=aScript.ScriptFunctions[i].aFunction;
      if r<>0 then SetNamedValueStr(aScript,NVar,FunctionString) else
      FunctionString;
     end;
    F_TYPE_FUNCTION_IS_INTEGER :
     begin
      @FunctionInteger:=aScript.ScriptFunctions[i].aFunction;
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionInteger)) else
      FunctionInteger;
     end;

    F_TYPE_FUNCTION_STRING_IS_STRING :
     begin
      @FunctionStringIsString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      if r<>0 then SetNamedValueStr(aScript,NVar,FunctionStringIsString(s1)) else
      FunctionStringIsString(s1);
     end;

     F_TYPE_FUNCTION_FLOAT_IS_FLOAT :
     begin
      @FunctionFloatIsFloat:=aScript.ScriptFunctions[i].aFunction;
      f1:=GetNamedValueFloat(aScript,OneParam(Command));
      if r<>0 then SetNamedValueFloat(aScript,NVar,FunctionFloatIsFloat(f1)) else
      FunctionFloatIsFloat(f1);
     end;



    F_TYPE_FUNCTION_INTEGER_IS_STRING :
     begin
      @FunctionIntegerIsString:=aScript.ScriptFunctions[i].aFunction;
      i1:=GetNamedValueInt(aScript,OneParam(Command));
      if r<>0 then SetNamedValueStr(aScript,NVar,FunctionIntegerIsString(i1)) else
      FunctionIntegerIsString(i1);
     end;
    F_TYPE_FUNCTION_INTEGER_IS_INTEGER :
     begin
      @FunctionIntegerIsInteger:=aScript.ScriptFunctions[i].aFunction;
      i1:=GetNamedValueInt(aScript,OneParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionIntegerIsInteger(i1))) else
      FunctionIntegerIsInteger(i1);
     end;
    F_TYPE_FUNCTION_STRING_IS_INTEGER :
     begin
      @FunctionStringIsInteger:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionStringIsInteger(s1))) else
      FunctionStringIsInteger(s1);
     end;
    F_TYPE_PROCEDURE_STRING_STRING :
     begin
      @ProcedureStringString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,FirstParam(Command));
      s2:=GetNamedValueString(aScript,SecondParam(Command));
      ProcedureStringString(s1,s2);
     end;

    F_TYPE_PROCEDURE_ARRAYSTRING :
     begin
      @ProcedureArrayString:=aScript.ScriptFunctions[i].aFunction;
      ss1:=GetNamedValueArrayString(aScript,OneParam(Command));
      ProcedureArrayString(ss1);
     end;

    F_TYPE_FUNCTION_INTEGER_INTEGER_IS_INTEGER :
     begin
      @FunctionIntegerIntegerIsInteger:=aScript.ScriptFunctions[i].aFunction;
      i1:=GetNamedValueInt(aScript,FirstParam(Command));
      i2:=GetNamedValueInt(aScript,SecondParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionIntegerIntegerIsInteger(i1,i2))) else
      FunctionIntegerIntegerIsInteger(i1,i2);
     end;

    F_TYPE_PROCEDURE_STRING_STRING_STRING :
     begin
      @ProcedureStringStringString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,ParamNO(Command,1));
      s2:=GetNamedValueString(aScript,ParamNO(Command,2));
      s3:=GetNamedValueString(aScript,ParamNO(Command,3));
      ProcedureStringStringString(s1,s2,s3);
     end;
    F_TYPE_PROCEDURE_STRING_STRING_INTEGER :
     begin
      @ProcedureStringStringInteger:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,ParamNO(Command,1));
      s2:=GetNamedValueString(aScript,ParamNO(Command,2));
      i1:=GetNamedValueInt(aScript,ParamNO(Command,3));
      ProcedureStringStringInteger(s1,s2,i1);
     end;
    F_TYPE_PROCEDURE_STRING_STRING_BOOLEAN :
     begin
      @ProcedureStringStringBoolean:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,ParamNO(Command,1));
      s2:=GetNamedValueString(aScript,ParamNO(Command,2));
      b1:=GetNamedValueBool(aScript,ParamNO(Command,3));
      ProcedureStringStringBoolean(s1,s2,b1);
     end;

    F_TYPE_PROCEDURE_INTEGER :
     begin
      @ProcedureInteger:=aScript.ScriptFunctions[i].aFunction;
      i1:=GetNamedValueInt(aScript,OneParam(Command));
      ProcedureInteger(i1);
     end;
    F_TYPE_PROCEDURE_INTEGER_INTEGER :
     begin
      @ProcedureIntegerInteger:=aScript.ScriptFunctions[i].aFunction;
      i1:=GetNamedValueInt(aScript,FirstParam(Command));
      i2:=GetNamedValueInt(aScript,SecondParam(Command));
      ProcedureIntegerInteger(i1,i2);
     end;
    F_TYPE_PROCEDURE_STRING :
     begin
      @ProcedureString:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      ProcedureString(s1);
     end;
    F_TYPE_PROCEDURE_INTEGER_STRING :
     begin
      @ProcedureIntegerString:=aScript.ScriptFunctions[i].aFunction;
      i1:=GetNamedValueInt(aScript,FirstParam(Command));
      s2:=GetNamedValueString(aScript,SecondParam(Command));
      ProcedureIntegerString(i1,s2);
     end;
    F_TYPE_OBJ_PROCEDURE_TOBJECT :
     begin
      aScript.ScriptFunctions[i].aObjFunction(Sender);
      Continue;
     end;
    F_TYPE_FUNCTION_STRING_IS_INTEGER_OBJECT :
     begin
      s1:=GetNamedValueString(aScript,OneParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(aScript.ScriptFunctions[i].aObjFunctinStringIsInteger(s1))) else
      aScript.ScriptFunctions[i].aObjFunctinStringIsInteger(s1);
     end;
    F_TYPE_FUNCTION_IS_INTEGER_OBJECT :
     begin
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(aScript.ScriptFunctions[i].aObjFunctionIsInteger)) else
      aScript.ScriptFunctions[i].aObjFunctionIsInteger;
     end;
    F_TYPE_FUNCTION_IS_ARRAY_STRING_OBJECT :
     begin
      if r<>0 then SetNamedValueArrayStrings(aScript,NVar,aScript.ScriptFunctions[i].aObjFunctionIsArrayStrings) else
      aScript.ScriptFunctions[i].aObjFunctionIsArrayStrings;
     end;
    F_TYPE_FUNCTION_IS_BOOL_OBJECT :
     begin
      if r<>0 then SetBoolAttr(aScript,NVar,aScript.ScriptFunctions[i].aObjFunctionIsBool) else
      aScript.ScriptFunctions[i].aObjFunctionIsBool;
     end;
    F_TYPE_FUNCTION_IS_STRING_OBJECT :
     begin
      if r<>0 then SetNamedValueStr(aScript,NVar,aScript.ScriptFunctions[i].aObjFunctionIsString) else
      aScript.ScriptFunctions[i].aObjFunctionIsString;
     end;

    F_TYPE_FUNCTION_INTEGER_IS_INTEGER_OBJECT :
     begin
      i1:=GetNamedValueInt(aScript,OneParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(aScript.ScriptFunctions[i].aObjFunctionIntegerIsInteger(i1))) else
      aScript.ScriptFunctions[i].aObjFunctionIntegerIsInteger(i1);
     end;
    F_TYPE_FUNCTION_INTEGER_IS_STRING_OBJECT :
     begin
      i1:=GetNamedValueInt(aScript,OneParam(Command));
      if r<>0 then SetNamedValueStr(aScript,NVar,aScript.ScriptFunctions[i].aObjFunctionIntegerIsString(i1)) else
      aScript.ScriptFunctions[i].aObjFunctionIntegerIsString(i1);
     end;
    F_TYPE_FUNCTION_STRING_IS_STRING_OBJECT :
     begin
      s1:=GetNamedValueString(aScript,OneParam(Command));
      if r<>0 then SetNamedValueStr(aScript,NVar,aScript.ScriptFunctions[i].aObjFunctionStringIsString(s1)) else
      aScript.ScriptFunctions[i].aObjFunctionStringIsString(s1);
     end;


    F_TYPE_FUNCTION_BOOLEAN_IS_BOOLEAN :
     begin
      @FunctionBooleanIsBoolean:=aScript.ScriptFunctions[i].aFunction;
      b1:=GetNamedValueBool(aScript,OneParam(Command));
      b1:=FunctionBooleanIsBoolean(b1);
      if b1 then s1:='true' else s1:='false';
      if r<>0 then SetNamedValue(aScript,NVar,s1);
     end;
    F_TYPE_FUNCTION_IS_BOOLEAN :
     begin
      @FunctionIsBoolean:=aScript.ScriptFunctions[i].aFunction;
      b1:=FunctionIsBoolean;
      if b1 then s1:='true' else s1:='false';
      if r<>0 then SetNamedValue(aScript,NVar,s1);
     end;

    F_TYPE_FUNCTION_STRING_IS_BOOLEAN :
     begin
      @FunctionStringIsBoolean:=aScript.ScriptFunctions[i].aFunction;
      s1:=GetNamedValueString(aScript,OneParam(Command));
      b1:=FunctionStringIsBoolean(s1);
      if b1 then s1:='true' else s1:='false';
      if r<>0 then SetNamedValue(aScript,NVar,s1);
     end;

    F_TYPE_FUNCTION_ARRAYINTEGER_INTEGER_IS_INTEGER :
     begin
      @FunctionArrayIntegerIntegerIsInteger:=aScript.ScriptFunctions[i].aFunction;
      ii1:=GetNamedValueArrayInt(aScript,FirstParam(Command));
      i1:=GetNamedValueInt(aScript,SecondParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionArrayIntegerIntegerIsInteger(ii1,i1))) else
      FunctionArrayIntegerIntegerIsInteger(ii1,i1);
     end;
    F_TYPE_FUNCTION_ARRAYINTEGER_IS_INTEGER :
     begin
      @FunctionArrayIntegerIsInteger:=aScript.ScriptFunctions[i].aFunction;
      ii1:=GetNamedValueArrayInt(aScript,OneParam(Command));
      if r<>0 then SetNamedValue(aScript,NVar,IntToStr(FunctionArrayIntegerIsInteger(ii1))) else
      FunctionArrayIntegerIsInteger(ii1);
     end;
    F_TYPE_PROCEDURE_ARRAYINTEGER_INTEGER_INTEGER :
     begin
      @ProcedureArrayIntegerIntegerInteger:=aScript.ScriptFunctions[i].aFunction;
      ii1:=GetNamedValueArrayInt(aScript,ParamNo(Command,1));
      i1:=GetNamedValueInt(aScript,ParamNo(Command,2));
      i2:=GetNamedValueInt(aScript,ParamNo(Command,3));
      ProcedureArrayIntegerIntegerInteger(ii1,i1,i2);
     end;
    F_TYPE_PROCEDURE_VAR_ARRAYINTEGER_INTEGER :
     begin
      @ProcedureVarArrayIntegerInteger:=aScript.ScriptFunctions[i].aFunction;
      NVar:=FirstParam(Command);
      ii1:=GetNamedValueArrayInt(aScript,NVar);
      i1:=GetNamedValueInt(aScript,SecondParam(Command));
      ProcedureVarArrayIntegerInteger(ii1,i1);
      SetNamedValueArrayInt(aScript,NVar,ii1)
     end;
    F_TYPE_FUNCTION_INTEGER_IS_ARRAYINTEGER :
     begin
      @FunctionIntegerIsArrayInteger:=aScript.ScriptFunctions[i].aFunction;
      i1:=GetNamedValueInt(aScript,OneParam(Command));
      if r<>0 then SetNamedValueArrayInt(aScript,NVar,FunctionIntegerIsArrayInteger(i1)) else
      FunctionIntegerIsArrayInteger(i1);
     end;

    end;

    break;
   end;
  end;
  if fb=0 then begin DoExit; exit; end;
 until (PosEx(';',script,fb)<1) or (fb>=Length(script));
 DoExit;
end;

function ValidMenuDescription(const Desc : string) : boolean;
var
  n, k : integer;
begin
 Result:=false;
 n:=PosExS('<',Desc,1);
 if n=0 then exit;
 n:=PosExS('>',Desc,n);
 if n=0 then exit;
 n:=PosExS('[',Desc,n);
 if n=0 then exit;
 n:=PosExS(']',Desc,n);
 if n=0 then exit;
 n:=PosExS('{',Desc,n);
 if n=0 then exit;
 k:=PosExS('}',Desc,n);
 if k=0 then exit;
 Result:=true;
end;

procedure DeleteMenuDescription(var Desc : string);
var
  b, n, e : integer;
begin
 b:=PosExS('<',Desc,1);
 if b=0 then exit;
 n:=PosExS('>',Desc,b);
 if n=0 then exit;
 n:=PosExS('[',Desc,n);
 if n=0 then exit;
 n:=PosExS(']',Desc,n);
 if n=0 then exit;
 n:=PosExS('{',Desc,n);
 if n=0 then exit;
 e:=PosExS('}',Desc,n);
 if e=0 then exit;
 Delete(Desc,b,e-b+1);
end;

function MakeNewItem(MenuItem : TMenuItem; ImageList : TImageList; Caption, Icon : string; var Script : string; var aScript : TScript; OnClick : TNotifyEvent; var ImagesCount : integer) : TMenuItemW;
var
  Item : TMenuItemW;
  Ico : TIcon;
  Command : string;
begin
 Item:=TMenuItemW.Create(nil);
 Item.Caption:=Caption;
 if (Icon<>'') then
 begin
  if (Length(icon)>1) then
  begin
   if (icon[2]=':') then
   begin
    inc(ImagesCount);
    {$IFNDEF EXT}
    Ico:=GetSmallIconByPath(Icon);
    {$ENDIF EXT}
    ImageList.AddIcon(Ico);
    Ico.Free;
    Item.ImageIndex:=ImageList.Count-1;
   end else Item.ImageIndex:=StrToIntDef(Icon,-1);
  end else Item.ImageIndex:=StrToIntDef(Icon,-1);
 end else Item.ImageIndex:=StrToIntDef(Icon,-1);
 Item.OnClick:=OnClick;
 Command:=Script;
 While ValidMenuDescription(Command) do
 DeleteMenuDescription(Command);

 Item.Tag:=GetNamedValueInt(aScript,'$Tag');
 Item.Visible:=GetNamedValueBool(aScript,'$Visible');
 Item.Default:=GetNamedValueBool(aScript,'$Default');
 Item.Enabled:=GetNamedValueBool(aScript,'$Enabled');
 Item.Checked:=GetNamedValueBool(aScript,'$Checked');

 Item.Script:=Command;
 MenuItem.Add(Item);
 Result:=Item;
end;

procedure LoadItemVariables(aScript : TScript; Sender : TMenuItem);
var
  s : string;
  i : integer;
begin
 if Sender<>nil then
 begin
  s:=Sender.Caption;
  for i:=1 to Length(s)-1 do
  begin
   if (s[i]='&') and (s[i+1]<>'&') then Delete(s,i,1);
  end;
  SetNamedValue(aScript,'$Caption','"'+s+'"');
  SetNamedValue(aScript,'$Tag',IntToStr(Sender.Tag));
 end;
end;

procedure LoadMenuFromScript(MenuItem : TMenuItem; ImageList : TImageList; Script : string; var aScript : TScript; OnClick : TNotifyEvent; var ImagesCount : integer; initialize : boolean);
var
  Text, Icon, Command, InitScript, RunScript, IncludeFile  : string;
  i : integer;
  apos, cb, ce, ib, ie, tb, te, p, l, scc : integer;
  NewItem, TempItem : TMenuItemW;
  aRun : boolean;
  VirtualItem : TMenuItemW;

const
  ItitStringCommand = 'initialization:';
  RunStringCommand = 'run:';

begin
 NewItem:=nil;
 apos:=1;
 script := StringReplace(script, #10#13 , '', [rfReplaceAll]);
 MenuItem.Clear;
 if initialize then
 for i:=1 to ImagesCount do
 begin
  if ImageList.Count=0 then break;
  ImageList.Delete(ImageList.Count-1);
  ImagesCount:=0;
 end;
 if script='' then exit;
 repeat
  tb:=PosExS('<',script,apos);
  te:=PosExS('>',script,tb);
  ib:=PosExS('[',script,te);
  ie:=PosExS(']',script,ib);
  cb:=PosExS('{',script,ie);
  ce:=PosExS('}',script,cb);
  Text:=Copy(script,tb+1,te-tb-1);
  Icon:=Copy(script,ib+1,ie-ib-1);
  Command:=Copy(script,cb+1,ce-cb-1);

  aRun:=true;
  InitScript:='';
  RunScript:='';
  l:=Length(Command);
  p:=1;
  scc:=0;
  if l>0 then
  Repeat
   if Command[p]='{' then inc(scc);
   if Command[p]='}' then dec(scc);
   if scc=0 then
   if Copy(Command,p,Length(ItitStringCommand))=ItitStringCommand then
   begin
    aRun:=false;
    inc(p,Length(ItitStringCommand));
   end;
   if scc=0 then
   if Copy(Command,p,Length(RunStringCommand))=RunStringCommand then
   begin
    aRun:=true;
    inc(p,Length(RunStringCommand));
   end;
   if aRun then RunScript:=RunScript+Command[p] else InitScript:=InitScript+Command[p];
   inc(p);
  until p>l;

  if (tb<>0) and (te<>0) and (ib<>0) and (ie<>0) and (cb<>0) and (ce<>0)  then
  begin
   if (Length(Trim(Text))>0) then
   begin
    if Trim(Text)='#' then
    begin
     if MenuItem<>nil then
     begin
      if MenuItem is TMenuItemW then
        TempItem:=MenuItem as TMenuItemW
      else
        TempItem:=nil;
     end else
     TempItem:=nil;
     ExecuteScriptFile(TempItem,aScript,'',ImagesCount,ImageList,OnClick,Command);
    end else
    begin
     SetNamedValue(aScript,'$Tag','0');
     SetNamedValue(aScript,'$Visible','true');
     SetNamedValue(aScript,'$Default','false');
     SetNamedValue(aScript,'$Enabled','true');
     SetNamedValue(aScript,'$Checked','false');
     VirtualItem := TMenuItemW.Create(nil);
     VirtualItem.TopItem:=MenuItem;
     ExecuteScript(VirtualItem,aScript,InitScript,ImagesCount,ImageList,OnClick);
     NewItem:=MakeNewItem(MenuItem,ImageList,Text,Icon,RunScript,aScript,OnClick,ImagesCount);
     for i:=0 to VirtualItem.Count-1 do
     begin
      TempItem:=TMenuItemW.Create(NewItem);
      TempItem.Caption:=VirtualItem.Items[i].Caption;
      TempItem.Script:=(VirtualItem.Items[i] as TMenuItemW).Script;
      TempItem.ImageIndex:=VirtualItem.Items[i].ImageIndex;
      TempItem.Default:=VirtualItem.Items[i].Default;
      TempItem.Tag:=VirtualItem.Items[i].Tag;
      TempItem.OnClick:=VirtualItem.Items[i].OnClick;
      NewItem.Add(TempItem);
     end;
     VirtualItem.free;
    end;
   end else
   begin
    if aFileExists(Command) then
    begin
     IncludeFile:=Include(Command);
     Insert(IncludeFile,script,ce+1);
    end;
   end;
  end;
  if RunScript<>'' then
  if ValidMenuDescription(RunScript) then
  begin
   LoadMenuFromScript(NewItem,ImageList,RunScript,aScript,OnClick,ImagesCount,false);
  end;

  if (ce=0) or (cb=0) or (ie=0) or (ib=0) or (te=0) or (tb=0) then break;
  Delete(script,tb,ce-tb+1);
  apos:=tb;
 until PosEx('<',script,apos)<1;
end;

function CalcExpression(aScript : TScript; const Expression : string) : string;
var
  n, nnew : integer;
  s, ResS : string;

begin
 Case GetValueType(aScript,Expression) of
   VALUE_TYPE_STRING : Result:='String('+Expression+');';
   VALUE_TYPE_INTEGER : Result:='Integer('+Expression+');';
   VALUE_TYPE_BOOLEAN : Result:='Boolean('+Expression+');';
  else
  begin
   if Expression<>'' then
   if Expression[1]='#' then
   begin
    s:=FloatToStr(UnitScriptsMath.StringToFloatScript(Copy(Expression,2,Length(Expression)-1),aScript));
    UnMakeFloat(s);
    Result:='Float('+s+')';
    exit;
   end;
   if Expression<>'' then
   if Expression[1]='%' then
   begin
    s:=Copy(Expression,2,Length(Expression)-1);
    n:=Trunc(UnitScriptsMath.StringToFloatScript(s,aScript));
    s:=IntToStr(n);
    Result:='Integer('+s+')';
    exit;
   end;

   n:=1;
   ResS:='';
   if PosExS('+',Expression)<>0 then
   begin
    Repeat
     nnew:=PosExS('+',Expression,n);
     if nnew<>0 then
     begin
      s:=Copy(Expression,n,nnew-n);
      if GetValueType(aScript,s)=VALUE_TYPE_STRING then
      ResS:=ResS+GetNamedValueString(aScript,s);
      n:=nnew+1;
     end;
    until nnew=0;
    s:=Copy(Expression,n,Length(Expression)-n+1);
    ResS:=ResS+GetNamedValueString(aScript,s);
    {$IFNDEF EXT}
    Result:='String("'+AnsiQuotedStr(ResS)+'");';
    {$ENDIF EXT}
   end else
   Result:=Expression;
  end;
 end;
end;

procedure AddScriptTextFunction(Enviroment : TScriptEnviroment; AFunction : TScriptStringFunction);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := AFunction.fName;
  FFunction.aType := F_TYPE_FUNCTION_OF_SCRIPT;
  FFunction.aFunction := nil;
  FFunction.ScriptStringFunction := AFunction;
  Enviroment.Functions.Register(FFunction, True);
end;

procedure AddScriptFunction(Enviroment : TScriptEnviroment; const FunctionName : String; FunctionType : integer; FunctionPointer : Pointer);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := FunctionType;
  FFunction.aFunction := FunctionPointer;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunction(Enviroment : TScriptEnviroment; const FunctionName : String; FunctionType : integer; AFunction : TNotifyEvent);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := FunctionType;
  FFunction.aFunction := nil;
  FFunction.aObjFunction := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionStringIsInteger(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctinStringIsIntegerObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_STRING_IS_INTEGER_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctinStringIsInteger := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionIntegerIsInteger(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctionIntegerIsIntegerObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_INTEGER_IS_INTEGER_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctionIntegerIsInteger := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionIsInteger(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctionIsIntegerObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_IS_INTEGER_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctionIsInteger := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionIsBool(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctionIsBoolObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_IS_BOOL_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctionIsBool := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionIsString(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctionIsStringObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_IS_STRING_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctionIsString := aFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionIntegerIsString(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctionIntegerIsStringObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_INTEGER_IS_STRING_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctionIntegerIsString := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionStringIsString(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctionStringIsStringObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_STRING_IS_STRING_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctionStringIsString := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

procedure AddScriptObjFunctionIsArrayStrings(Enviroment : TScriptEnviroment; const FunctionName : String; AFunction : TFunctionIsArrayStringsObject);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := F_TYPE_FUNCTION_IS_ARRAY_STRING_OBJECT;
  FFunction.aFunction := nil;
  FFunction.aObjFunctionIsArrayStrings := AFunction;
  Enviroment.Functions.Register(FFunction);
end;

function aSetString(const S : String) : String;
begin
 Result:=S;
end;

function aSetInteger(int : integer) : integer;
begin
 Result:=int;
end;

function aSetFloat(float : extended) : extended;
begin
 Result:=float;
end;

function WriteCode(const str : string) : string;
begin
 Result:=str;
end;

function Include(FileName : string) : string;
var
  d, s : string;
  i, p : integer;
  F : TInitScriptFunction;
  FS : TStrings;
begin
 Result:='';
 if Length(FileName)<4 then exit;
 if (FileName[1]='"') and (FileName[Length(FileName)]='"') then
 FileName:=Copy(FileName,2,Length(FileName)-2);
 if FileName[2]=':' then d:=FileName else
 d:=ExtractFileDir(paramstr(0))+'\'+FileName;
 if FileExists(d) then
 begin
  FS:=TStringList.Create;
  try
   FS.LoadFromFile(d);
  except
   exit;
  end;
  for i:=0 to FS.Count-1 do
  begin
   s:=FS[i];
   p:=PosExK('//',s);
   if p>0 then
   begin
    FS[i]:=Copy(S,1,p-1);
   end;
  end;
  Result:=FS.Text;
  FS.Free;

  Result := StringReplace(Result, #10#13 , '', [rfReplaceAll]);
  if InitScriptFunction<>nil then
  begin
   @F:=InitScriptFunction;
   Result:=F(Result);
  end;
  Result:=Result;
 end;
end;

function ReadFile(FileName : string) : string;
var
  FS : TFileStream;
  d : string;
  F : TInitScriptFunction;
begin
 Result:='';
 if Length(FileName)<4 then exit;
 if (FileName[1]='"') and (FileName[Length(FileName)]='"') then
 FileName:=Copy(FileName,2,Length(FileName)-2);
 if FileName[2]=':' then d:=FileName else
 d:=ExtractFileDir(paramstr(0))+'\'+FileName;
 if FileExists(d) then
 begin
  try
  FS := TFileStream.Create(d,fmOpenRead);
  except
   exit;
  end;
  SetLength(Result,FS.Size);
  FS.Read(Result[1],FS.Size);
  FS.Free;
  if InitScriptFunction<>nil then
  begin
   @F:=InitScriptFunction;
   Result:=F(Result);
  end;
  Result:=Result;
 end;
end;

function ReadScriptFile(FileName : string) : string;
var
  d, s : string;
  i, p : integer;
  F : TInitScriptFunction;
  FS : TStrings;
begin
 Result:='';
 if Length(FileName)<4 then exit;
 if (FileName[1]='"') and (FileName[Length(FileName)]='"') then
 FileName:=Copy(FileName,2,Length(FileName)-2);
 if FileName[2]=':' then d:=FileName else
 d:=ExtractFileDir(paramstr(0))+'\'+FileName;
 if FileExists(d) then
 begin
  FS:=TStringList.Create;
  try
    try
     FS.LoadFromFile(d);
    except
     exit;
    end;
    for i:=0 to FS.Count-1 do
    begin
     s:=FS[i];
     p:=PosExK('//',s);
     if p>0 then
     begin
      FS[i]:=Copy(S,1,p-1);
     end;
    end;
    Result:=FS.Text;
  finally
    FS.Free;
  end;

  Result := StringReplace(Result, #10#13 , '', [rfReplaceAll]);
  if InitScriptFunction<>nil then
  begin
   @F:=InitScriptFunction;
   Result:=F(Result);
  end;
  Result:=Result;
 end;
end;

function Float(ext : Extended) : Extended;
begin
 Result:=ext;
end;

function ArrayStringLength(aArray : TArrayOfString) : integer;
begin
 Result:=Length(aArray);
end;

function GetStringItem(aArray : TArrayOfString; int : integer) : string;
begin
 if int<=Length(aArray)-1 then
 Result:=aArray[int] else
 Result:='';
end;

function ArrayIntLength(aArray : TArrayOfInt) : integer;
begin
 Result:=Length(aArray);
end;

function GetIntItem(aArray : TArrayOfInt; int : integer) : integer;
begin
 if int<=Length(aArray)-1 then
 Result:=aArray[int] else
 Result:=0;
end;

procedure SetIntItem(aArray : TArrayOfInt; index, value : integer);
begin
 if index<=Length(aArray)-1 then
 aArray[index]:=value;
end;

function GetIntArray(int : integer) : TArrayOfInt;
begin
 if int<0 then
 SetLength(Result,0) else SetLength(Result,int);
end;

function GetStringArray(int : integer) : TArrayOfInt;
begin
 if int<0 then
 SetLength(Result,0) else SetLength(Result,int);
end;

procedure AddIntItem(var aArray : TArrayOfInt; Value : integer);
var
  l : integer;
begin
 l:=Length(aArray);
 SetLength(aArray,l+1);
 aArray[l]:=Value;
end;

procedure AddStringItem(var aArray : TArrayOfString; Value : String);
var
  l : integer;
begin
 l:=Length(aArray);
 SetLength(aArray,l+1);
 aArray[l]:=Value;
end;

function CreateItem(aOwner: TMenuItem; Caption, Icon, Script: string; Default : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
var
  Ico : TIcon;
begin
 Result:=TMenuItemW.Create(aOwner);
 Result.Caption:=Caption;
 Result.Script:=Script;
 Result.Default:=Default;
 Result.OnClick:=OnClick;
 Result.Tag:=Tag;
 if (Icon<>'') then
 begin
  if (Length(icon)>1) then
  begin
   if (icon[2]=':') then
   begin
    inc(ImagesCount);
    {$IFNDEF EXT}
    Ico:=GetSmallIconByPath(Icon);
    {$ENDIF EXT}
    ImageList.AddIcon(Ico);
    Ico.Free;
    Result.ImageIndex:=ImageList.Count-1;
   end else Result.ImageIndex:=StrToIntDef(Icon,-1);
  end else Result.ImageIndex:=StrToIntDef(Icon,-1);
 end else Result.ImageIndex:=StrToIntDef(Icon,-1);
end;

function CreateItemDef(aOwner: TMenuItem; Caption, Icon, Script: string; Default, Enabled : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
var
  Ico : TIcon;
begin
 Result:=TMenuItemW.Create(aOwner);
 Result.Caption:=Caption;
 Result.Script:=Script;
 Result.Default:=Default;
 Result.OnClick:=OnClick;
 Result.Enabled:=Enabled;
 Result.Tag:=Tag;
 if (Icon<>'') then
 begin
  if (Length(icon)>1) then
  begin
   if (icon[2]=':') then
   begin
    inc(ImagesCount);
    {$IFNDEF EXT}
    Ico:=GetSmallIconByPath(Icon);
    {$ENDIF EXT}
    ImageList.AddIcon(Ico);
    Ico.Free;
    Result.ImageIndex:=ImageList.Count-1;
   end else Result.ImageIndex:=StrToIntDef(Icon,-1);
  end else Result.ImageIndex:=StrToIntDef(Icon,-1);
 end else Result.ImageIndex:=StrToIntDef(Icon,-1);
end;

function CreateItemDefChecked(aOwner: TMenuItem; Caption, Icon, Script: string; Default, Enabled, Checked : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
var
  Ico : TIcon;
begin
 Result:=TMenuItemW.Create(aOwner);
 Result.Caption:=Caption;
 Result.Script:=Script;
 Result.Default:=Default;
 Result.OnClick:=OnClick;
 Result.Enabled:=Enabled;
 Result.Checked:=Checked;
 Result.Tag:=Tag;
 if (Icon<>'') then
 begin
  if (Length(icon)>1) then
  begin
   if (icon[2]=':') then
   begin
    inc(ImagesCount);
    {$IFNDEF EXT}
    Ico:=GetSmallIconByPath(Icon);
    {$ENDIF EXT}
    ImageList.AddIcon(Ico);
    Ico.Free;
    Result.ImageIndex:=ImageList.Count-1;
   end else Result.ImageIndex:=StrToIntDef(Icon,-1);
  end else Result.ImageIndex:=StrToIntDef(Icon,-1);
 end else Result.ImageIndex:=StrToIntDef(Icon,-1);
end;



function aBoolean(bool : boolean) : boolean;
begin
  Result:=bool;
end;

function aFileExists(FileName : string) : boolean;
var
  d : string;
  oldMode: Cardinal;
begin
 Result:=false;
 if Length(FileName)<4 then exit;
  oldMode:= SetErrorMode(SEM_FAILCRITICALERRORS);
 if (FileName[1]='"') and (FileName[Length(FileName)]='"') then
 FileName:=Copy(FileName,2,Length(FileName)-2);
 if FileName[2]=':' then d:=FileName else
 d:=ExtractFileDir(paramstr(0))+'\'+FileName;
 if FileExists(d) then
  Result:=true else Result:=FileExists(FileName);
  SetErrorMode(oldMode);
end;

{ TMenuItemW }

constructor TMenuItemW.Create(aOwner: TComponent);
begin
 inherited;
 TopItem:=nil;
end;

procedure SetNamedValueInt(aScript : TScript; Name : string; Value : integer);
begin
 SetNamedValue(aScript,Name,IntToStr(Value));
end;

procedure InitializeScript(aScript : TScript);
begin
 aScript.ParentScript := nil;
end;

procedure SetBoolAttr(aScript : TScript; Name : String; Value : boolean);
begin
 if Value then
 SetNamedValue(aScript,Name,'true') else SetNamedValue(aScript,  Name,'false');
end;

procedure SetIntAttr(aScript : TScript; Name : String; Value :Integer);
begin
 SetNamedValue(aScript,Name,IntToStr(Value));
end;

procedure Clear(Item : TMenuItem);
begin
 Item.Clear;
end;

procedure DeleteNoFirst(Item : TMenuItem);
var
  i : integer;
begin
 for i:=1 to Item.Count-1 do
 Item.Delete(1);
end;

procedure aHalt;
begin
 Halt;
end;

procedure ClearMemory(var aScript : TScript);
begin
 aScript.NamedValues.Clear;
end;

function VarValue(aScript : TScript; const Variable : string; List : TListBox = nil) : string;
var
   Value : TValue;
   j : integer;
   StringResult : boolean;
begin
 Result:='';
 Value := aScript.NamedValues.GetValueByName(Variable);
 StringResult:=List=nil;

  Case Value.aType of
   VALUE_TYPE_ERROR         :
   begin
    Result:='['+Variable+']=ERROR!';
   end;
   VALUE_TYPE_STRING        :
   begin
    Result:='['+Variable+']='''+Value.StrValue+'''';
   end;
   VALUE_TYPE_INTEGER       :
   begin
    Result:='['+Variable+']='+IntToStr(Value.IntValue)+'';
   end;
   VALUE_TYPE_BOOLEAN       :
   begin
    if Value.BoolValue then
    Result:='['+Variable+']=true' else
    Result:='['+Variable+']=false';
   end;
   VALUE_TYPE_FLOAT         :
   begin
    Result:='['+Variable+']='+FloatToStr(Value.FloatValue)+'';
   end;
   VALUE_TYPE_STRING_ARRAY  :
   begin
    if StringResult then
    begin
     Result:='string[';
     for j:=0 to Length(Value.StrArray)-1 do
     begin
      if j<>0 then Result:=Result+',';
      Result:=Result+'"'+Value.StrArray[j]+'"';
     end;
     Result:=Result+']';
     exit;
    end;
    List.Items.Add('['+Variable+'] = array of string['+IntToStr(Length(Value.StrArray))+']:');
    for j:=0 to Length(Value.StrArray)-1 do
    List.Items.Add('  '+IntToStr(j+1)+')  '''+Value.StrArray[j]+'''');
   end;
   VALUE_TYPE_INT_ARRAY     :
   begin
    if StringResult then
    begin
     Result:='integer[';
     for j:=0 to Length(Value.StrArray)-1 do
     begin
      if j<>0 then Result:=Result+',';
      Result:=Result+IntToStr(Value.IntArray[j]);
     end;
     Result:=Result+']';
     exit;
    end;
    List.Items.Add('['+Variable+'] = array of integer['+IntToStr(Length(Value.IntArray))+']:');
    for j:=0 to Length(Value.IntArray)-1 do
    List.Items.Add('  '+IntToStr(j+1)+')  '+IntToStr(Value.IntArray[j]));
   end;
   VALUE_TYPE_BOOL_ARRAY    :
   begin
    List.Items.Add('['+Variable+'] = array of boolean['+IntToStr(Length(Value.BoolArray))+']:');
    for j:=0 to Length(Value.BoolArray)-1 do
    begin
     if Value.BoolArray[j] then
     List.Items.Add('  '+IntToStr(j+1)+')  true') else
     List.Items.Add('  '+IntToStr(j+1)+')  false');
    end;
   end;
   VALUE_TYPE_FLOAT_ARRAY    :
   begin
    List.Items.Add('['+Variable+'] = array of float['+IntToStr(Length(Value.FloatArray))+']:');
    for j:=0 to Length(Value.FloatArray)-1 do
    List.Items.Add('  '+IntToStr(j+1)+')  '+FloatToStr(Value.FloatArray[j]));
   end;
  end;
end;

procedure ShowMemoryStatus(const aScript : TScript);
var
  StatusForm : TForm;
  List : TListBox;
  i : integer;
begin
 Application.CreateForm(TForm,StatusForm);
 StatusForm.Caption:='Memory for ['+aScript.Description+']';
 List := TListBox.Create(StatusForm);
 List.Parent:=StatusForm;
 List.Align:=AlClient;
 StatusForm.Position:=poScreenCenter;
 for i:=0 to aScript.NamedValues.Count-1 do
 begin
  VarValue(aScript,aScript.NamedValues[i].aName,List);
 end;
 StatusForm.ShowModal;
 StatusForm.Release;
 StatusForm.Free;
end;

procedure ShowFunctionList(const aScript : TScript);
var
  StatusForm : TForm;
  List : TListBox;
  I : integer;

  function GetTypeName(aType : integer) : string;
  var
    i : integer;
  begin
   Result:='Unknown';
   for i:=1 to FTypesLength do
   begin
    if FTypesInt[i]=aType then
    begin
     Result:=FTypes[i];
     break;
    end;
   end;
  end;

begin
 Application.CreateForm(TForm,StatusForm);
 StatusForm.Caption:='Functions for ['+aScript.Description+']';
 List := TListBox.Create(StatusForm);
 List.Parent:=StatusForm;
 List.Align:=AlClient;
 StatusForm.Width:=500;
 StatusForm.Height:=300;
 StatusForm.Position:=poScreenCenter;
{ TempFunctions:=aScript.ScriptFunctions;

 for j:=0 to Length(TempFunctions)-1 do
 for i:=0 to Length(TempFunctions)-2 do
 begin
  if CompareStr(TempFunctions[i].Name,TempFunctions[i+1].Name)>0 then
  begin
   TempFunct:=TempFunctions[i];
   TempFunctions[i]:=TempFunctions[i+1];
   TempFunctions[i+1]:=TempFunct;
  end;
 end; }

 for i:=0 to aScript.ScriptFunctions.Count - 1 do
 begin
  List.Items.Add(aScript.ScriptFunctions[i].Name+'   ['+GetTypeName(aScript.ScriptFunctions[i].aType)+']');
 end;
 StatusForm.ShowModal;
 StatusForm.Release;
 StatusForm.Free;
end;

procedure ExecuteScriptFile(Sender : TMenuItemW; var aScript : TScript; AlternativeCommand : string; var ImagesCount : integer; ImageList : TImageList; OnClick : TNotifyEvent = nil; FileName : string = '');
var
   FileText : string;
begin
 FileText:=ReadScriptFile(FileName);
 ExecuteScript(Sender,aScript,FileText,ImagesCount,ImageList,OnClick);
end;

function aMessageBox(Text, Caption : string; params : integer) : integer;
begin
 Result:=Application.MessageBox(PWideChar(Text), PWideChar(Caption), params);
end;

function ReplaceString(Str : string; WhatReplase, ToReplase : string) : string;
begin
 Result:=StringReplace(Str,WhatReplase,ToReplase,[rfReplaceAll,rfIgnoreCase]);
end;

function ReplaceStringAll(Str : string; WhatReplase, ToReplase : string) : string;
begin
 Result:=StringReplace(Str,WhatReplase,ToReplase,[rfIgnoreCase]);
end;

procedure LoadBaseFunctions(Enviroment : TScriptEnviroment);
begin
 AddScriptFunction(Enviroment,'ShowString',F_TYPE_PROCEDURE_STRING,@ShowString);

 AddScriptFunction(Enviroment,'REGISTER_SCRIPT',F_TYPE_FUNCTION_REGISTER_SCRIPT,nil);

 AddScriptFunction(Enviroment,'START_DEBUG',F_TYPE_FUNCTION_DEBUG_START,nil);
 AddScriptFunction(Enviroment,'STOP_DEBUG',F_TYPE_FUNCTION_DEBUG_END,nil);
 AddScriptFunction(Enviroment,'LOAD_VARS',F_TYPE_FUNCTION_LOAD_VARS,nil);
 AddScriptFunction(Enviroment,'SAVE_VAR',F_TYPE_FUNCTION_SAVE_VAR,nil);
 AddScriptFunction(Enviroment,'DELETE_VAR',F_TYPE_FUNCTION_DELETE_VAR,nil);

 AddScriptFunction(Enviroment,'ReplaceString',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@ReplaceString);
 AddScriptFunction(Enviroment,'ReplaceStringAll',F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING,@ReplaceStringAll);

 AddScriptFunction(Enviroment,'ArrayIntLength',F_TYPE_FUNCTION_ARRAYINTEGER_IS_INTEGER,@ArrayIntLength);
 AddScriptFunction(Enviroment,'GetIntItem',F_TYPE_FUNCTION_ARRAYINTEGER_INTEGER_IS_INTEGER,@GetIntItem);
 AddScriptFunction(Enviroment,'SetIntItem',F_TYPE_PROCEDURE_ARRAYINTEGER_INTEGER_INTEGER,@SetIntItem);
 AddScriptFunction(Enviroment,'GetIntArray',F_TYPE_FUNCTION_INTEGER_IS_ARRAYINTEGER,@GetIntArray);
 AddScriptFunction(Enviroment,'AddIntItem',F_TYPE_PROCEDURE_VAR_ARRAYINTEGER_INTEGER,@AddIntItem);
 AddScriptFunction(Enviroment,'AddStringItem',F_TYPE_PROCEDURE_VAR_ARRAYSTRING_STRING,@AddStringItem);
 AddScriptFunction(Enviroment,'GetStringArray',F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING,@GetStringArray);
 AddScriptFunction(Enviroment,'Clear',F_TYPE_PROCEDURE_CLEAR,@Clear);
 AddScriptFunction(Enviroment,'DeleteNoFirst',F_TYPE_PROCEDURE_CLEAR,@DeleteNoFirst);
 AddScriptFunction(Enviroment,'SetNamedValue',F_TYPE_PROCEDURE_STRING_STRING,@SetNamedValue);
 AddScriptFunction(Enviroment,'String',F_TYPE_FUNCTION_STRING_IS_STRING,@aSetString);
 AddScriptFunction(Enviroment,'Integer',F_TYPE_FUNCTION_INTEGER_IS_INTEGER,@aSetInteger);
 AddScriptFunction(Enviroment,'WriteCode',F_TYPE_PROCEDURE_WRITE_STRING,@WriteCode);
 AddScriptFunction(Enviroment,'Include',F_TYPE_PROCEDURE_WRITE_STRING,@include);
 {$IFNDEF EXT}

 AddScriptFunction(Enviroment,'SumInt',F_TYPE_FUNCTION_INTEGER_INTEGER_IS_INTEGER,@SumInt);
 AddScriptFunction(Enviroment,'SumStr',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@SumStr);
 AddScriptFunction(Enviroment,'ArrayStringLength',F_TYPE_FUNCTION_ARRAYSTRING_IS_INTEGER,@ArrayStringLength);
 AddScriptFunction(Enviroment,'GetStringItem',F_TYPE_FUNCTION_ARRAYSTRING_INTEGER_IS_STRING,@GetStringItem);
 AddScriptFunction(Enviroment,'CreateItem',F_TYPE_FUNCTION_CREATE_ITEM,@CreateItem);
 AddScriptFunction(Enviroment,'CreateItemDef',F_TYPE_FUNCTION_CREATE_ITEM_DEF,@CreateItemDef);
 AddScriptFunction(Enviroment,'CreateItemDefChecked',F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED,@CreateItemDefChecked);
 AddScriptFunction(Enviroment,'CreateItemDefCheckedSubTag',F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED_SUBTAG,@CreateItemDefChecked);
 AddScriptFunction(Enviroment,'CreateParentItem',F_TYPE_FUNCTION_CREATE_PARENT_ITEM,@CreateItem);


 AddScriptFunction(Enviroment,'IntToStr',F_TYPE_FUNCTION_INTEGER_IS_STRING,@aIntToStr);
 AddScriptFunction(Enviroment,'SpilitWords',F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING,@SpilitWords);
 AddScriptFunction(Enviroment, 'ReadFile',F_TYPE_FUNCTION_STRING_IS_STRING,@ReadFile);
 AddScriptFunction(Enviroment, 'Default',F_TYPE_PROCEDURE_TSCRIPT,@Default);
 AddScriptFunction(Enviroment, 'InVisible',F_TYPE_PROCEDURE_TSCRIPT,@InVisible);
 AddScriptFunction(Enviroment, 'Disabled',F_TYPE_PROCEDURE_TSCRIPT,@Disabled);
 AddScriptFunction(Enviroment, 'Checked',F_TYPE_PROCEDURE_TSCRIPT,@Checked);
 AddScriptFunction(Enviroment, 'AddIcon',F_TYPE_FUNCTION_ADD_ICON,@AddIcon);
 AddScriptFunction(Enviroment, 'Boolean',F_TYPE_FUNCTION_BOOLEAN_IS_BOOLEAN,@aBoolean);
 AddScriptFunction(Enviroment, 'GetDirListing',F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING,@GetDirListing);
 AddScriptFunction(Enviroment, 'FileExists',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@aFileExists);
 AddScriptFunction(Enviroment, 'DirectoryExists',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@aDirectoryExists);
 AddScriptFunction(Enviroment, 'DirectoryFileExists',F_TYPE_FUNCTION_STRING_IS_BOOLEAN,@aDirectoryFileExists);
 AddScriptFunction(Enviroment, 'AddAssociatedIcon',F_TYPE_FUNCTION_ADD_ICON,@AddAssociatedIcon);
 AddScriptFunction(Enviroment, 'PathFormat',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@aPathFormat);
 AddScriptFunction(Enviroment, 'GetUSBDrives',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetUSBDrives);
 AddScriptFunction(Enviroment, 'GetCDROMDrives',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetCDROMDrives);
 AddScriptFunction(Enviroment, 'GetAllDrives',F_TYPE_FUNCTION_IS_ARRAYSTRING,@GetAllDrives);
 AddScriptFunction(Enviroment, 'GetDriveName',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@GetDriveName);
 AddScriptFunction(Enviroment, 'GetMyPicturesFolder',F_TYPE_FUNCTION_IS_STRING,@GetMyPicturesFolder);
 AddScriptFunction(Enviroment, 'GetMyDocumentsFolder',F_TYPE_FUNCTION_IS_STRING,@GetMyDocumentsFolder);
 AddScriptFunction(Enviroment, 'ShowInt',F_TYPE_PROCEDURE_INTEGER,@ShowInt);
 AddScriptFunction(Enviroment, 'Sleep',F_TYPE_PROCEDURE_INTEGER,@Sleep);
 AddScriptFunction(Enviroment, 'AltKeyDown',F_TYPE_FUNCTION_IS_BOOLEAN,@AltKeyDown);
 AddScriptFunction(Enviroment, 'CtrlKeyDown',F_TYPE_FUNCTION_IS_BOOLEAN,@CtrlKeyDown);
 AddScriptFunction(Enviroment, 'ShiftKeyDown',F_TYPE_FUNCTION_IS_BOOLEAN,@ShiftKeyDown);
 AddScriptFunction(Enviroment, 'NowString',F_TYPE_FUNCTION_IS_STRING,@NowString);
 AddScriptFunction(Enviroment, 'Halt',F_TYPE_PROCEDURE_NO_PARAMS,@aHalt);
 AddScriptFunction(Enviroment, 'LoadFilesFromClipBoard',F_TYPE_FUNCTION_IS_ARRAYSTRING,@LoadFIlesFromClipBoard);
 AddScriptFunction(Enviroment, 'ClipboardCopyFile',F_TYPE_PROCEDURE_STRING,@CopyFile);
 AddScriptFunction(Enviroment, 'ClipboardCutFile',F_TYPE_PROCEDURE_STRING,@CutFile);
 AddScriptFunction(Enviroment, 'ClipboardCopyFiles',F_TYPE_PROCEDURE_ARRAYSTRING,@CopyFiles);
 AddScriptFunction(Enviroment, 'ClipboardCutFiles',F_TYPE_PROCEDURE_ARRAYSTRING,@CutFiles);
 AddScriptFunction(Enviroment, 'ShowMemoryStatus',F_TYPE_PROCEDURE_TSCRIPT,@ShowMemoryStatus);
 AddScriptFunction(Enviroment, 'ClearMemory',F_TYPE_PROCEDURE_TSCRIPT,@ClearMemory);
 AddScriptFunction(Enviroment, 'ShowFunctionList',F_TYPE_PROCEDURE_TSCRIPT,@ShowFunctionList);

 AddScriptFunction(Enviroment, 'StrToInt',F_TYPE_FUNCTION_STRING_IS_INTEGER,@aStrToInt);
 AddScriptFunction(Enviroment, 'Pos',F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER,@aPos);
 AddScriptFunction(Enviroment, 'StrCopy',F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING,@aStrCopy);

 AddScriptFunction(Enviroment, 'GetOpenDirectory',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@GetOpenDirectory);


 AddScriptFunction(Enviroment, 'GetProgramFolder',F_TYPE_FUNCTION_IS_STRING,@GetProgramFolder);
 AddScriptFunction(Enviroment, 'ExtractFileName',F_TYPE_FUNCTION_STRING_IS_STRING,@aExtractFileName);

 AddScriptFunction(Enviroment, 'ExtractFileDirectory',F_TYPE_FUNCTION_STRING_IS_STRING,@GetDirectory);
 AddScriptFunction(Enviroment, 'ExecuteScriptFile',F_TYPE_PROCEDURE_TSCRIPT_STRING_W,@ExecuteScriptFile);
 {$ENDIF EXT}
 AddScriptFunction(Enviroment, 'MessageBox',F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER,@aMessageBox);
 AddScriptFunction(Enviroment, 'Float',F_TYPE_FUNCTION_FLOAT_IS_FLOAT,@Float);

 AddScriptFunction(Enviroment, 'FileInPath',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@FileInPath);

 AddScriptFunction(Enviroment, 'FileHasExt',F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN,@UnitScriptsFunctions.FileHasExt);
end;

procedure LoadFileFunctions(Enviroment : TScriptEnviroment);
begin
 {$IFNDEF EXT}
 AddScriptFunction(Enviroment, 'CopyFile',F_TYPE_PROCEDURE_STRING_STRING,@aCopyFile);
 AddScriptFunction(Enviroment, 'CopyFileSynch',F_TYPE_PROCEDURE_STRING_STRING,@CopyFileSynch);
 AddScriptFunction(Enviroment, 'RenameFile',F_TYPE_PROCEDURE_STRING_STRING,@aRenameFile);
 AddScriptFunction(Enviroment, 'Run',F_TYPE_PROCEDURE_STRING_STRING,@Run);
 AddScriptFunction(Enviroment, 'RunWait',F_TYPE_PROCEDURE_STRING_STRING,@ExecAndWait);
 AddScriptFunction(Enviroment, 'DeleteFile',F_TYPE_PROCEDURE_STRING,@aDeleteFile);
 AddScriptFunction(Enviroment, 'Exec',F_TYPE_PROCEDURE_STRING,@Exec);

 AddScriptFunction(Enviroment, 'WriteLnToFile',F_TYPE_PROCEDURE_STRING_STRING,@WriteLnToFile);
 AddScriptFunction(Enviroment, 'WriteToFile',F_TYPE_PROCEDURE_STRING_STRING,@WriteToFile);
 AddScriptFunction(Enviroment, 'CreateFile',F_TYPE_PROCEDURE_STRING,@CreateFile);
 AddScriptFunction(Enviroment, 'GetSaveFileName',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@GetSaveFileName);
 AddScriptFunction(Enviroment, 'GetOpenFileName',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@GetOpenFileName);

 AddScriptFunction(Enviroment, 'GetSaveImageFileName',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@GetSaveImageFileName);
 AddScriptFunction(Enviroment, 'GetOpenImageFileName',F_TYPE_FUNCTION_STRING_STRING_IS_STRING,@GetOpenImageFileName);
 {$ENDIF EXT}
end;

procedure FinalizeScript(aScript : TScript);
//var
//  i : integer;
begin
{ for i:=0 to Length(aScript.NamedValues)-1 do
 if aScript.NamedValues[i].aName='$NO_UNLOAD' then
 if aScript.NamedValues[i].BoolValue=true then
  exit; }
  //TODO: !!!!!
 //if aScript.ID<>'' then
 //ScriptsManager.RemoveScript(aScript.ID);
end;

{ TScriptsManager }

function TScriptsManager.AddScript(Script: TScript) : string;
var
  Index : integer;
begin
  Index := FScripts.IndexOf(Script);
  if Index > -1 then
    Result := TScript(FScripts[Index]).ID
  else
    Result := TScript(FScripts[FScripts.Add(Script)]).ID;
end;

constructor TScriptsManager.Create;
begin
  FScripts := TList.Create;
end;

destructor TScriptsManager.Destroy;
var
  I : Integer;
begin
  for I := 0 to FScripts.Count - 1 do
    if GOM.IsObj(FScripts[i]) then
      TScript(FScripts[i]).Free;

  FScripts.Free;
  inherited;
end;

function TScriptsManager.GetScriptByID(ID: string): TScript;
var
  I : integer;
begin
  Result := nil;
  for I := 0 to FScripts.Count - 1 do
    if TScript(FScripts[I]).ID = ID then
    begin
      Result := FScripts[I];
      Exit;
    end;
end;

procedure TScriptsManager.RemoveScript(ID : string);
var
  I : integer;
begin
  for I := 0 to FScripts.Count - 1 do
    if TScript(FScripts[I]).ID = ID then
    begin
      FScripts.Delete(I);
      Exit;
    end;
end;

function TScriptsManager.ScriptExists(ID : string): Boolean;
var
  I : integer;
begin
  Result := False;
  for I := 0 to FScripts.Count - 1 do
    if TScript(FScripts[I]).ID = ID then
    begin
      Result := True;
      Exit;
    end;
end;

initialization

  ScriptsManager := TScriptsManager.Create;

finalization

  F(ScriptsManager);

end.
