unit UnitScripts;

interface

{$DEFINE USEDEBUG}

{$DEFINE USEDLL}
//{$DEFINE EXT}

{$IFDEF USEDLL}

//{$IFNDEF USEDLL}

{$ELSE}

{$ENDIF}

uses
  Windows, Menus, SysUtils, Graphics, ShellAPI, StrUtils, Dialogs, uMemoryEx,
  Classes, Controls, Registry, ShlObj, Forms, StdCtrls, uScript, uStringUtils,
  uMemory, uGOM, uTime, uTranslate, uRuntime, uActivationUtils, uSysUtils,
  uGUIDUtils,
  uPortableScriptUtils;

type
  TMenuItemW = class(TMenuItem)
  private
    { Private declarations }
  public
    { Public declarations }
    Script : string;
    TopItem : TMenuItem;
    constructor Create(aOwner : TComponent); override;
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
  TProcedureScript = procedure(const Script : TScript);
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
    F_TYPE_FUNCTION_FORMAT = 65;


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

   procedure SetNamedValueInt(AScript: TScript; name: string; Value: Integer);
   procedure SetBoolAttr(aScript : TScript; Name : String; Value : boolean);
   procedure SetIntAttr(aScript : TScript; Name : String; Value :Integer);
   function Include(FileName : string) : string;
   function aFileExists(FileName : string) : boolean;
   procedure ExecuteScriptFile(Sender : TMenuItemW; var aScript : TScript; AlternativeCommand : string; var ImagesCount : integer; ImageList : TImageList; OnClick : TNotifyEvent = nil; FileName : string = '');

   function ReadScriptFile(FileName : string) : string;

   procedure AddScriptTextFunction(Enviroment : TScriptEnviroment; AFunction : TScriptStringFunction);
   procedure AddScriptFunction(Enviroment : TScriptEnviroment; const FunctionName : String; FunctionType : integer; FunctionPointer : Pointer; ReplaceExisted : Boolean = False);
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
   procedure LoadBaseFunctions(Enviroment: TScriptEnviroment);
   procedure LoadFileFunctions(Enviroment: TScriptEnviroment);

   const
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
   TIncludeScript = class(TObject)
   public
     FilePath : string;
     ScriptContent : string;
   end;

   TScriptsManager = class(TObject)
   private
   public
     FScripts: TList;
     FIncludes: TList;
     constructor Create;
     destructor Destroy; override;
     function AddScript(Script: TScript): string;
     procedure RemoveScript(ID: string);
     function ScriptExists(ID: string): Boolean;
     function GetScriptByID(ID: string): TScript;
     procedure RegisterIncludeScript(FileName, ScriptContent : string);
     function GetIncludeScript(FileName : string) : TIncludeScript;
   end;

var
 InitScriptFunction : Pointer = nil;
 ScriptsManager : TScriptsManager = nil;

function IsVariable(const s : string) : Boolean;

implementation

uses
  UnitScriptsMath, UnitScriptsFunctions, DBScriptFunctions, uMobileUtils
 {$IFDEF USEDEBUG}
   ,UnitDebugScriptForm
 {$ENDIF}
 ;

/////////////////////////////////////////////////////////////////////////

function IsVariable(const s : string) : Boolean;
begin
  Result := (s <> '') and (s[1] = '$');
end;

function GetCID: string;
begin
  Result := GUIDToString(GetGUID);
end;

function GetValueType(const aScript : TScript; const Value : string) : integer;
var
  I: Integer;
  C: Char;
begin
  Result := VALUE_TYPE_ERROR;
  if Value = '' then
    Exit;

  C := Value[1];
  if C = '$' then
  begin
    for I := 0 to AScript.NamedValues.Count - 1 do
      if AScript.NamedValues[I].AName = Value then
      begin
        Result := AScript.NamedValues[I].AType;
        Exit;
      end;
    if AScript.ParentScript <> nil then
    begin
      Result := GetValueType(AScript.ParentScript, Value);
    end;
    Exit;
  end;
  if (Value = 'true') or (Value = 'false') then
  begin
    Result := VALUE_TYPE_BOOLEAN;
    Exit;
  end;
  if CharInSet(C, ['a'..'z', 'A'..'Z']) then
    Exit;

  if (C = '"') and (C = Value[Length(Value)]) then
    if PosExS('+', Value) = 0 then
    begin
      Result := VALUE_TYPE_STRING;
      Exit;
    end;

  if StrToIntDef(Value, -1) = StrToIntDef(Value, 1) then
  begin
    Result := VALUE_TYPE_INTEGER;
    Exit;
  end;
  if StrToIntDef(Value, -1) = StrToIntDef(Value, 1) then
  begin
    Result := VALUE_TYPE_INTEGER;
    Exit;
  end;
  if Length(Value) > 1 then
    if (Value[1] = Value[Length(Value)]) and (Value[1] = '"') then
      if PosExS('+', Value) = 0 then
      begin
        Result := VALUE_TYPE_STRING;
        Exit;
      end;
  if StrToFloatDef(ConvertUniversalFloatToLocal(Value), -1) = StrToFloatDef(ConvertUniversalFloatToLocal(Value), 1) then
  begin
    Result := VALUE_TYPE_FLOAT;
    Exit;
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

procedure SetNamedValueStr(const AScript: TScript; const ValueName, AValue: string);
begin
  SetNamedValue(AScript, ValueName, AnsiQuotedStr(AValue, '"'));
end;

procedure UnMakeFloat(var S: string);
var
  J: Integer;
  B: Boolean;
begin
  B := True;
  for J := 1 to Length(S) do
    if S[J] = FormatSettings.DecimalSeparator then
    begin
      S[J] := '.';
      B := False;
    end;
  if B then
    S := S + '.0';
end;

procedure SetNamedValueFloat(const AScript: TScript; const ValueName: string; const Value: Extended);
var
  S: string;
begin
  S := FloatToStr(Value);
  UnMakeFloat(S);
  SetNamedValue(AScript, ValueName, S);
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
  if ValueName <> '' then
  begin
    if ValueName[1] = '$' then
    begin
      Value := aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_INTEGER);
      if Value <> nil then
        Result := Value.IntValue
      else
        Result := Default;
    end else
      Result := StrToIntDef(ValueName, Default);
  end else
    Result := Default;
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
  if ValueName <> '' then
  begin
    if ValueName[1] = '$' then
    begin
    Value := aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_BOOLEAN);
    if Value <> nil then
      Result := Value.BoolValue
    else
      Result := False;
    end else
      Result := ValueName = 'true';
  end else
    Result := False;
end;

function GetNamedValueArrayString(const aScript : TScript; const ValueName : string) : TArrayOfString;
begin
  if aScript.NamedValues.Exists(ValueName, True) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_STRING_ARRAY).StrArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueArrayInt(const aScript : TScript; const ValueName : string) : TArrayOfInt;
begin
  if aScript.NamedValues.Exists(ValueName, True) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_INT_ARRAY).IntArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueArrayBool(const aScript : TScript; const ValueName : string) : TArrayOfBool;
begin
  if aScript.NamedValues.Exists(ValueName, True) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_BOOL_ARRAY).BoolArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueArrayFloat(const aScript : TScript; const ValueName : string) : TArrayOfFloat;
begin
  if aScript.NamedValues.Exists(ValueName, True) then
    Result := Copy(aScript.NamedValues.GetByNameAndType(ValueName, VALUE_TYPE_FLOAT_ARRAY).FloatArray)
  else
    SetLength(Result, 0);
end;

function GetNamedValueString(const aScript : TScript; const ValueName : string) : string;
var
  Value : TValue;
begin
  Result := '';
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
  P: PChar;
  C: Char;
begin
  Result := 0;
  if Str = '' then
    Exit;

  P := PChar(Integer(Addr(Str[1])));
  Inc(P, Index - 2);
  for I := Index to Length(Str) do
  begin
    Inc(P, 1);
    C := P[0];
    if not CharInSet(C, ['0' .. '9', 'a' .. 'z', 'A' .. 'Z', '_', ' ', '$', '=']) then
      Exit;
    if C = SubStr then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function PosNext(const SubStr : string; const Str : string; const index : integer = 1) : integer;
var
  I: Integer;
  S: string;
  P: PChar;
  C: Char;
begin
  Result := 0;
  P := PChar(Integer(Addr(Str[1])));
  Inc(P, Index - 2);
  for I := Index to Length(Str) - 1 do
  begin
    Inc(P, 1);
    C := P^;
    if C = ';' then
      Continue;
    if (C = #32) and (P[1] <> #32) then
    begin

      S := Copy(Str, I + 1, Length(SubStr));
      if S = SubStr then
        Result := I;
    end else
      Exit;
  end;
end;

function PosExK(const SubStr: string; const Str: string; Index: Integer = 1): Integer;
var
  I: Integer;
  N: Boolean;
  Ls: Integer;
  C, FS: Char;
  OneChar: Boolean;
  PS, PSup: PChar;

  function IsSubStr: Boolean;
  var
    K: Integer;
    APS: PChar;
    APSub: PChar;
  begin
    Integer(APS) := Integer(PS);
    Integer(APSub) := Integer(PSup);
    for K := 1 to LS do
    begin
      if APS^ <> APSub^ then
      begin
        Result := False;
        Exit;
      end;
      Inc(APS, 1);
      Inc(APSub, 1);
    end;
    Result := True;
  end;

begin
  if (Index < 1) or (Length(Str) = 0) then
  begin
    Result := 0;
    Exit;
  end;
  if Length(SubStr) = 0 then
  begin
    Result := Index;
    Exit;
  end;

  n := False;
  Result := 0;
  FS := #0;
  Ls := Length(SubStr);
  OneChar := Ls = 1;

  if OneChar then
    FS := SubStr[1]
  else
    PSup := PChar(Addr(SubStr[1]));

  PS := PChar(Addr(Str[1]));
  Inc(PS, Index - 2);

  for I := Index to Length(Str) do
  begin
    Inc(PS, 1);

    if OneChar then
    begin
      C := PS^;
      if (C = FS) and (not N) then
      begin
        Result := I;
        Exit;
      end;
    end else
    begin
      if IsSubStr and (not N) then
      begin
        Result := I;
        Exit;
      end;
      C := PS^;
    end;

    if I = index then
      Continue;

    if (C = '"')  then
    begin
      N := not N;
      Continue;
    end;

    if (not N) then
    begin
      if OneChar then
      begin
        if (C = FS) then
        begin
          Result := I;
          Exit;
        end;
      end else
      begin
        if IsSubStr then
        begin
          Result := I;
          Exit;
        end;
      end;
    end;
  end;
end;

/////////////////////////////////////////////////////////////////////////

function GetFunctionName(aFunction : string) : string;
var
  Fb, Fe, R: Integer;
begin
  R := PosExR('=', AFunction, 1);
  if R <> 0 then
    Delete(AFunction, 1, R);

  AFunction := TrimLeft(AFunction);

  Fb := 1;
  Fe := 0;
  if AFunction <> '' then
    if AFunction[1] <> '#' then
      Fe := PosExS('(', AFunction);
  if Fe = 0 then
    Fe := PosExS(';', AFunction, 1);
  if Fe <> 0 then
    Result := Copy(AFunction, Fb, Fe - Fb);

  Result := TrimRight(Result);
end;

function OneParam(const aFunction : string) : string;
var
  Fb, Fe: Integer;
begin
  Fb := Pos('(', AFunction);
  Fe := PosExK(')', AFunction, Fb);
  Result := Copy(AFunction, Fb + 1, Fe - Fb - 1);
end;

function FirstParam(const aFunction : string) : string;
var
  Fb, Fe, P: Integer;
begin
  Fb := Pos('(', AFunction);
  Fe := PosExS(');', AFunction, Fb);
  P := PosExS(',', AFunction, Fb);
  if P > Fe then
    P := Fe;
  Result := Copy(AFunction, Fb + 1, P - Fb - 1);
end;

function SecondParam(const aFunction : string) : string;
var
  Fb, Fe, P: Integer;
begin
  Fb := Pos('(', AFunction);
  Fe := PosExS(');', AFunction, Fb);
  P := PosExS(',', AFunction, Fb);
  Result := Copy(AFunction, P + 1, Fe - P - 1);
end;

function ParamNO(const aFunction : string; const N : integer) : string;
var
  Fb, I, P, Px, Pold: Integer;
begin
  Fb := Pos('(', AFunction);
  P := Fb - 1;
  Pold := P;
  for I := 1 to N do
  begin
    Pold := P;
    P := PosEx(',', AFunction, P + 1);
    Px := PosEx(')', AFunction, P + 1);
    if (Px < P) or (P = 0) then
      P := Px;
  end;
  if N = 1 then
    Inc(Pold);
  Result := Copy(AFunction, Pold + 1, P - Pold - 1);
end;

function RightEvalution(const aScript : TScript; Evalution : string) : boolean;
var
 _as, _bs : string;
 _ai, _bi : integer;
 _af, _bf : extended;
 _ab, _bb : boolean;

  function LeftOperand(const S: string): string;
  var
    I, LS: Integer;
    C: Char;
  begin
    Result := '';
    LS := Length(S);
    for I := 1 to LS do
    begin
      C := S[I];
      if (C = '=') or ((C = '!') and (S[I + 1] = '=') and (I <= LS)) or (C = '<') or (C = '>') then
      begin
        Result := Copy(S, 1, I - 1);
        Exit;
      end;
    end;
  end;

  function RightOperand(const S : string) : string;
  var
    I, LS: Integer;
    C: Char;
  begin
    Result := '';
    LS := Length(S);
    for I := 1 to LS do
    begin
      C := S[I];
      if (C = '=') or ((C = '!') and (S[I + 1] = '=') and (I <= LS)) or (C = '<') or (C= '>') then
      begin
        if (C = '!') then
          Result := Copy(S, I + 2, LS - I - 1)
        else
          Result := Copy(S, I + 1, LS - I);
        Exit;
      end;
    end;
  end;

  function GetOperand(const S : string) : integer;
  var
    I: Integer;
    C: Char;
  begin
    Result := 0;
    for I := 1 to Length(S) - 1 do
    begin
      C := S[I];
      if (C = '=') or ((C = '!') and (S[I + 1] = '=')) or (C = '<') or (C = '>') then
      begin
        if (C = '=') then
        begin
          Result := 1;
          Exit;
        end else if ((C = '!') and (S[I + 1] = '=')) then
        begin
          Result := 2;
          Exit;
        end else if (C = '<') then
        begin
          Result := 3;
          Exit;
        end else if (C = '>') then
        begin
          Result := 4;
          Exit;
        end;
      end;
    end;
  end;

begin
  Result := False;
  if Evalution <> '' then
    if Evalution[1] = '#' then
    begin
      Delete(Evalution, 1, 1);
      Result := StringToFloatScript(Evalution, AScript) = 1;
      Exit;
    end;
  _as := LeftOperand(Evalution);
  _bs := RightOperand(Evalution);
  case GetValueType(AScript, _as) of
    VALUE_TYPE_STRING:
      begin
        _as := GetNamedValueString(AScript, _as);
        _bs := GetNamedValueString(AScript, _bs);
        case GetOperand(Evalution) of
          1:
            Result := _as = _bs;
          2:
            Result := _as <> _bs;
          3:
            Result := CompareStr(_as, _bs) < 0;
          4:
            Result := CompareStr(_as, _bs) > 0;
        end;
      end;
    VALUE_TYPE_INTEGER:
      begin
        _ai := GetNamedValueInt(AScript, _as);
        _bi := GetNamedValueInt(AScript, _bs);
        case GetOperand(Evalution) of
          1:
            Result := _ai = _bi;
          2:
            Result := _ai <> _bi;
          3:
            Result := _ai < _bi;
          4:
            Result := _ai > _bi;
        end;
      end;
    VALUE_TYPE_FLOAT:
      begin
        _af := GetNamedValueFloat(AScript, _as);
        _bf := GetNamedValueFloat(AScript, _bs);
        case GetOperand(Evalution) of
          1:
            Result := _af = _bf;
          2:
            Result := _af <> _bf;
          3:
            Result := _af < _bf;
          4:
            Result := _af > _bf;
        end;
      end;
    VALUE_TYPE_BOOLEAN:
      begin
        _ab := GetNamedValueBool(AScript, _as);
        _bb := GetNamedValueBool(AScript, _bs);
        case GetOperand(Evalution) of
          1:
            Result := _ab = _bb;
          2:
            Result := _ab <> _bb;
          3:
            Result := False;
          4:
            Result := False;
        end;
      end;

  end;
end;

procedure AddScriptTextFunctions(var aScript : TScript; Functions : string);
var
  Funct, Fname, _farg, Fbody: string;
  Farg: TArrayOfString;
  Fb, Fe, Ps, _type, Sb, Se, Bb, Be: Integer;
  Ftype: string;
  ScriptStringFunction: TScriptStringFunction;
begin
  if Length(Functions) < 5 then
    Exit;
  Fb := 1;
  repeat
    Fe := PosExS(';', Functions, Fb);
    Funct := Trim(Copy(Functions, Fb, Fe - Fb + 1));
    if Funct <> '' then
      if Funct[1] = '.' then
      begin
        Ps := Pos(' ', Funct);
        if Ps > 2 then
        begin
          Ftype := Copy(Funct, 2, Ps - 2);
          _type := VALUE_TYPE_ERROR;
          if Ftype = 'void' then
            _type := VALUE_TYPE_VOID
          else if Ftype = 'int' then
            _type := VALUE_TYPE_INTEGER
          else if Ftype = 'string' then
            _type := VALUE_TYPE_STRING
          else if Ftype = 'bool' then
            _type := VALUE_TYPE_BOOLEAN
          else if Ftype = 'float' then
            _type := VALUE_TYPE_FLOAT
          else if Ftype = 'string[]' then
            _type := VALUE_TYPE_STRING_ARRAY
          else if Ftype = 'int[]' then
            _type := VALUE_TYPE_INT_ARRAY
          else if Ftype = 'bool[]' then
            _type := VALUE_TYPE_BOOL_ARRAY
          else if Ftype = 'float[]' then
            _type := VALUE_TYPE_FLOAT_ARRAY;
          if _type <> VALUE_TYPE_ERROR then
          begin
            Sb := PosEx('(', Funct, Ps);
            Fname := Trim(Copy(Funct, Ps, Sb - Ps));
            Se := PosExK(')', Funct, Sb);
            _farg := Copy(Funct, Sb + 1, Se - Sb - 1);
            Bb := PosEx('{', Funct, Se);
            Be := PosExS(EndSymbol, Funct, Bb);
            Fbody := Copy(Funct, Bb + 1, Be - Bb - 1);
            _farg := Trim(_farg);

            SetLength(Farg, 0);
{$IFNDEF EXT}
            Farg := Copy(SpilitWordsW(_farg, ','));
{$ENDIF EXT}
            if Fname <> '' then
            begin
              ScriptStringFunction.FType := _type;
              ScriptStringFunction.FName := Fname;
              ScriptStringFunction.FArgs := Farg;
              ScriptStringFunction.FBody := Fbody;
              AddScriptTextFunction(AScript.Enviroment, ScriptStringFunction);
            end;
          end;
        end;
      end;
    Fb := Fe + 1;
  until (PosEx(';', Functions, Fb) < 1) or (Fb >= Length(Functions));
end;

procedure ExecuteScript(Sender : TMenuItemW; aScript : TScript; AlternativeCommand : string; var ImagesCount : integer; ImageList : TImageList; OnClick : TNotifyEvent = nil);
var
  Apos, Af, Fb, Fe, I, J, N, R, Ifb, Ifsb, Ifse, Ifssb, Ifsse, Ifelex, Ifelb, Ifele, Forb, Forsb, Forse, Forssb,
    Forsse, N1, N2, N3: Integer;
  S, Script, Command, Func, S1, S2, S3, S4, S5, NVar, AIf, IfScript, AFor, ForScript, Forinit, Foreval, Forexevery,
    NewFunc, NewFunctions: string;
  Ss1: TArrayOfString;
  Bb1: TArrayOfBool;
  Ii1: TArrayOfInt;
  Ff1: TArrayOfFloat;
  Value: TValue;
  I1, I2, K: Integer;
  F1, F2: Extended;
  B1, B2, B3: Boolean;
  SimpleProcedure: TSimpleProcedure;
  FunctionString: TFunctionString;
  FunctionInteger: TFunctionInteger;
  ProcedureStringString: TProcedureStringString;
  ProcedureInteger: TProcedureInteger;
  ProcedureIntegerInteger: TProcedureIntegerInteger;
  ProcedureString: TProcedureString;
  ProcedureIntegerString: TProcedureIntegerString;
  ProcedureObject: TProcedureObject;
  FunctionStringIsString: TFunctionStringIsString;
  FunctionIntegerIsInteger: TFunctionIntegerIsInteger;
  ProcedureWriteString: TProcedureWriteString;
  FunctionIntegerIntegerIsInteger: TFunctionIntegerIntegerIsInteger;
  FunctionStringStringIsArrayString: TFunctionStringStringIsArrayString;
  FunctionArrayStringIsInteger: TFunctionArrayStringIsInteger;
  FunctionArrayStringIntegerIsString: TFunctionArrayStringIntegerIsString;
  FunctionCreateItem: TFunctionCreateItem;
  FunctionIntegerIsString: TFunctionIntegerIsString;
  FunctionStringIsArrayString: TFunctionStringIsArrayString;
  FunctinStringIsIntegerObject: TFunctinStringIsIntegerObject;
  FunctionBooleanIsBoolean: TFunctionBooleanIsBoolean;
  FunctionIsBoolean: TFunctionIsBoolean;
  FunctionStringIsBoolean: TFunctionStringIsBoolean;
  FunctionStringStringIsString: TFunctionStringStringIsString;
  FunctionStringStringIsInteger: TFunctionStringStringIsInteger;
  FunctionStringStringIsBool: TFunctionStringStringIsBool;
  FunctionAddIcon: TFunctionAddIcon;
  ProcedureScript: TProcedureScript;
  ProcedureBoolean: TProcedureBoolean;
  FunctionStringIsInteger: TFunctionStringIsInteger;
  FunctionIsArrayString: TFunctionIsArrayString;

  FunctionArrayIntegerIsInteger: TFunctionArrayIntegerIsInteger;
  FunctionArrayIntegerIntegerIsInteger: TFunctionArrayIntegerIntegerIsInteger;
  ProcedureArrayIntegerIntegerInteger: TProcedureArrayIntegerIntegerInteger;
  ProcedureVarArrayIntegerInteger: TProcedureVarArrayIntegerInteger;
  FunctionIntegerIsArrayInteger: TFunctionIntegerIsArrayInteger;

  ProcedureVarArrayStringString: TProcedureVarArrayStringString;
  ProcedureClear: TProcedureClear;
  FunctionCreateItemDef: TFunctionCreateItemDef;
  FunctionCreateItemDefChecked: TFunctionCreateItemDefChecked;

  FunctionIsIntegerObject: TFunctionIsIntegerObject;
  FunctionIntegerIsIntegerObject: TFunctionIntegerIsIntegerObject;
  FunctionIntegerIsStringObject: TFunctionIntegerIsStringObject;
  FunctionStringIsStringObject: TFunctionStringIsStringObject;
  FunctionFloatIsFloat: TFunctionFloatIsFloat;

  ProcedureArrayString: TProcedureArrayString;

  FunctionStringIntegerIntegerIsInteger: TFunctionStringIntegerIntegerIsInteger;
  ProcedureScriptString: TProcedureScriptStringW;
  FunctionStringStringIntegerIsInteger: TFunctionStringStringIntegerIsInteger;

  ProcedureStringStringString: TProcedureStringStringString;
  ProcedureStringStringInteger: TProcedureStringStringInteger;
  ProcedureStringStringBoolean: TProcedureStringStringBoolean;

  FunctionStringStringStringIsString: TFunctionStringStringStringIsString;

  TempItem: TMenuItemW;
  ATempItem: TMenuItem;
  TempScript: TScript;
  PTempScript: TScript;
  SF: TScriptFunction;
{$IFDEF USEDEBUG}

  DebugScriptForm: TDebugScriptForm;
{$ENDIF}
  LineCounter: Integer;

 procedure DoExit;
  begin
{$IFDEF USEDEBUG}
    if DebugScriptForm <> nil then
    begin
      if DebugScriptForm.Waitind then
        DebugScriptForm.Stop;
      if not DebugScriptForm.Working then
        if not DebugScriptForm.Anil then
          DebugScriptForm.Release;
      DebugScriptForm := nil;
    end;
    TW.I.Start('END Script: ' + Copy(Script, 1, 20));
{$ENDIF}
  end;

begin
  LineCounter := 0;
  Apos := 1;
  Fb := 1;
  DebugScriptForm := nil;

  if AlternativeCommand <> '' then
    Script := AlternativeCommand
  else
  begin
    if Sender <> nil then
      Script := Sender.Script
    else
    begin
      DoExit;
      Exit;
    end;
  end;
  TW.I.Start('Script: ' + Copy(Script, 1, 100));

  repeat
    Inc(LineCounter);
{$IFDEF USEDEBUG}
    if DebugScriptForm <> nil then
    begin
      DebugScriptForm.SetActiveLine(LineCounter);
      DebugScriptForm.Wait;
    end;
{$ENDIF}
    Af := Fb;

    R := PosExR('=', Script, Fb);
    N := PosExK(';', Script, Fb);
    if (R < N) and (R <> 0) then
    begin
      NVar := Trim(Copy(Script, Fb, R - Fb));
    end else
    begin
      Ifb := PosExW('if', Script, Fb, N);
      Ifsb := PosExK('(', Script, Ifb);
      Ifse := PosExS(')', Script, Ifsb);
      Ifssb := PosExK('{', Script, Ifse);
      Ifsse := PosExS(EndSymbol, Script, Ifssb);

      if (N > Ifb) and (Ifb <> 0) and (Ifsb <> 0) and (Ifse <> 0) and (Ifssb <> 0) and (Ifsse <> 0) then
      begin
        AIf := Copy(Script, Ifsb + 1, Ifse - Ifsb - 1);
        IfScript := Copy(Script, Ifssb + 1, Ifsse - Ifssb - 1);
        if RightEvalution(AScript, AIf) then
        begin
          ExecuteScript(Sender, AScript, IfScript, ImagesCount, ImageList, OnClick);
          Ifelex := PosNext('else', Script, Ifsse + 1);
          if Ifelex <> 0 then
          begin
            Ifelb := PosExK('{', Script, Ifelex);
            Ifele := PosExS(EndSymbol, Script, Ifelb);
            Fb := Ifele + 2;
          end else
            Fb := Ifsse + 2;
          Continue;
        end else
        begin
          Ifelex := PosNext('else', Script, Ifsse + 1);
          if Ifelex <> 0 then
          begin
            Ifelb := PosExK('{', Script, Ifelex);
            Ifele := PosExS(EndSymbol, Script, Ifelb);
            IfScript := Copy(Script, Ifelb + 1, Ifele - Ifelb - 1);
            ExecuteScript(Sender, AScript, IfScript, ImagesCount, ImageList, OnClick);
            Fb := Ifele + 2;
            Continue;
          end else
          begin
            Fb := Ifsse + 2;
            Continue;
          end;
        end;
      end else
      begin
        Forb := PosExW('for', Script, Fb, N);
        Forsb := PosExK('(', Script, Forb);
        Forse := PosExS(')', Script, Forsb);
        Forssb := PosExK('{', Script, Forse);
        Forsse := PosExS(EndSymbol, Script, Forssb) + 1;

        if (N > Forb) and (Forb <> 0) and (Forsb <> 0) and (Forse <> 0) and (Forssb <> 0) then
        begin

          N1 := PosExK(';', Script, Forsb);
          N2 := PosExK(';', Script, N1 + 1);
          if (N1 <> 0) and (N2 <> 0) then
          begin
            Foreval := Copy(Script, N1 + 1, N2 - N1 - 1);
            Forexevery := Copy(Script, N2 + 1, Forse - N2 - 1) + ';';
            Forinit := Copy(Script, Forsb + 1, N1 - Forsb);

            if (Forsse <> 0) then
            begin
              Afor := Copy(Script, Forsb + 1, Forse - Forsb) + ';';
              ForScript := Copy(Script, Forssb + 1, Forsse - Forssb - 2); // +';';
              ExecuteScript(Sender, AScript, Forinit, ImagesCount, ImageList, OnClick);
              while RightEvalution(AScript, Foreval) do
              begin
                ExecuteScript(Sender, AScript, ForScript, ImagesCount, ImageList, OnClick);
                ExecuteScript(Sender, AScript, Forexevery, ImagesCount, ImageList, OnClick);
              end;
              Fb := Forsse + 2;
              Continue;
            end;
          end;
        end
      end;
    end;
    if N <> 0 then
      Fe := N
    else
      Fe := Length(Script);
    Command := Copy(Script, Fb, Fe - Fb + 1);
    if Copy(Trim(Command), 1, 10) = '@functions' then
    begin
      TW.I.Start('@functions');
      Fe := PosEx('@end', Script, Fb + 10);
      Fb := PosEx('@functions', Script, Fb);
      if Fe < 1 then
        Fe := Length(Script);
      NewFunctions := Copy(Script, Fb + 10, Fe - Fb - 10);
      Command := NewFunctions;
      TW.I.Start('@AddScriptTextFunctions');
      AddScriptTextFunctions(AScript, Command);
      TW.I.Start('@AddScriptTextFunctions - END');
      Fb := Fe + 4;
      Continue;
    end;
    Func := GetFunctionName(Command);

    NewFunc := CalcExpression(AScript, Func);
    if (NewFunc <> Func) and (R <> 0) then
    begin
      Func := GetFunctionName(NewFunc);
      Command := Copy(Script, Af, R - Af + 1) + NewFunc;

    end;

    Fb := Fe + 1;
    for I := 0 to AScript.ScriptFunctions.Count - 1 do
    begin
      SF := AScript.ScriptFunctions[I];
      if SF.name = Func then
      begin
        case SF.AType of

          F_TYPE_FUNCTION_DEBUG_START:
            begin
{$IFDEF USEDEBUG}
              if DebugScriptForm = nil then
              begin
                Application.CreateForm(TDebugScriptForm, DebugScriptForm);
                DebugScriptForm.LoadScript(Script);
                DebugScriptForm.SetScript(@AScript);
                DebugScriptForm.Show;
                DebugScriptForm.SetFocus;
                SetForegroundWindow(DebugScriptForm.Handle)
              end;
{$ENDIF}
            end;

          F_TYPE_FUNCTION_DEBUG_END:
            begin
              DoExit;
            end;

          F_TYPE_FUNCTION_REGISTER_SCRIPT:
            begin
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, ScriptsManager.AddScript(AScript));
            end;

          F_TYPE_FUNCTION_LOAD_VARS:
            begin
              S1 := GetNamedValueString(AScript, OneParam(Command));
              PTempScript := ScriptsManager.GetScriptByID(S1);

              if PTempScript <> nil then
              begin
                AScript.ParentScript := PTempScript;
                AScript.Enviroment := PTempScript.Enviroment;

                for J := 0 to PTempScript.NamedValues.Count - 1 do
                begin
                  Value := PTempScript.NamedValues[J];
                  if not AScript.NamedValues.Exists(Value.AName) then
                    AScript.NamedValues.GetValueByName(Value.AName).Assign(Value);
                end;

                for J := 0 to PTempScript.Enviroment.Functions.Count - 1 do
                  AScript.Enviroment.Functions.register(PTempScript.Enviroment.Functions[J].Copy, True);

                for J := 0 to PTempScript.PrivateEnviroment.Functions.Count - 1 do
                  AScript.PrivateEnviroment.Functions.register(PTempScript.PrivateEnviroment.Functions[J].Copy, True);
              end;
            end;

          F_TYPE_FUNCTION_DELETE_VAR:
            begin
              S1 := ParamNO(Command, 1);
              AScript.NamedValues.Remove(S1);
            end;

          F_TYPE_FUNCTION_SAVE_VAR:
            begin
              S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
              S2 := ParamNO(Command, 2);
              PTempScript := ScriptsManager.GetScriptByID(S1);
              if PTempScript <> nil then
                PTempScript.NamedValues.GetValueByName(S2).Assign(AScript.NamedValues.GetValueByName(S2));
            end;

          F_TYPE_FUNCTION_OF_SCRIPT:
            begin
              TempScript := TScript.Create(AScript.Owner, AScript.Enviroment.name);
              try
                for J := 0 to Length(AScript.ScriptFunctions[I].ScriptStringFunction.FArgs) - 1 do
                begin
                  SetNamedValueEx(TempScript, AScript, AScript.ScriptFunctions[I].ScriptStringFunction.FArgs[J],
                    ParamNo(Command, J + 1));
                end;

                ExecuteScript(Sender, TempScript, AScript.ScriptFunctions[I].ScriptStringFunction.FBody, ImagesCount,
                  ImageList, OnClick);
                CopyVar(AScript, TempScript, '$Result', NVar);
              finally
                TempScript.Free;
              end;
            end;

          F_TYPE_PROCEDURE_CLEAR:
            begin
              @ProcedureClear := AScript.ScriptFunctions[I].AFunction;
              if Sender <> nil then
                ProcedureClear(Sender);
            end;

          F_TYPE_FUNCTION_CREATE_ITEM_DEF:
            begin
              @FunctionCreateItemDef := AScript.ScriptFunctions[I].AFunction;
              if Sender <> nil then
              begin
                S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
                S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
                I2 := GetNamedValueInt(AScript, ParamNO(Command, 2), -1);
                if I2 <> -1 then
                  S2 := IntToStr(I2);
                S3 := GetNamedValueString(AScript, ParamNO(Command, 3));
                B1 := GetNamedValueBool(AScript, ParamNO(Command, 4));
                B2 := GetNamedValueBool(AScript, ParamNO(Command, 5));
                I1 := GetNamedValueInt(AScript, ParamNO(Command, 6));
                Sender.Add(FunctionCreateItemDef(Sender, S1, S2, S3, B1, B2, I1, ImageList, ImagesCount, OnClick));
              end;
            end;

          F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED:
            begin
              @FunctionCreateItemDefChecked := AScript.ScriptFunctions[I].AFunction;
              if Sender <> nil then
              begin
                S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
                S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
                I2 := GetNamedValueInt(AScript, ParamNO(Command, 2), -1);
                if I2 <> -1 then
                  S2 := IntToStr(I2);
                S3 := GetNamedValueString(AScript, ParamNO(Command, 3));
                B1 := GetNamedValueBool(AScript, ParamNO(Command, 4));
                B2 := GetNamedValueBool(AScript, ParamNO(Command, 5));
                B3 := GetNamedValueBool(AScript, ParamNO(Command, 6));
                I1 := GetNamedValueInt(AScript, ParamNO(Command, 7));
                Sender.Add(FunctionCreateItemDefChecked(Sender, S1, S2, S3, B1, B2, B3, I1, ImageList, ImagesCount,
                    OnClick));
              end;
            end;

          F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED_SUBTAG:
            begin
              @FunctionCreateItemDefChecked := AScript.ScriptFunctions[I].AFunction;
              if Sender <> nil then
              begin
                S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
                S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
                I2 := GetNamedValueInt(AScript, ParamNO(Command, 2), -1);
                if I2 <> -1 then
                  S2 := IntToStr(I2);
                S3 := GetNamedValueString(AScript, ParamNO(Command, 3));
                B1 := GetNamedValueBool(AScript, ParamNO(Command, 4));
                B2 := GetNamedValueBool(AScript, ParamNO(Command, 5));
                B3 := GetNamedValueBool(AScript, ParamNO(Command, 6));
                I1 := GetNamedValueInt(AScript, ParamNO(Command, 7));
                I2 := GetNamedValueInt(AScript, ParamNO(Command, 8));

                for K := 0 to Sender.Count - 1 do
                  if Sender.Items[K].Tag = I2 then
                  begin
                    Sender.Items[K].Add(FunctionCreateItemDefChecked(Sender, S1, S2, S3, B1, B2, B3, I1, ImageList,
                        ImagesCount, OnClick));
                  end;
              end;
            end;

          F_TYPE_FUNCTION_CREATE_ITEM:
            begin
              @FunctionCreateItem := AScript.ScriptFunctions[I].AFunction;
              if Sender <> nil then
              begin
                S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
                S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
                I2 := GetNamedValueInt(AScript, ParamNO(Command, 2), -1);
                if I2 <> -1 then
                  S2 := IntToStr(I2);
                S3 := GetNamedValueString(AScript, ParamNO(Command, 3));
                B1 := GetNamedValueBool(AScript, ParamNO(Command, 4));
                I1 := GetNamedValueInt(AScript, ParamNO(Command, 5));
                Sender.Add(FunctionCreateItem(Sender, S1, S2, S3, B1, I1, ImageList, ImagesCount, OnClick));
              end;
            end;
          F_TYPE_FUNCTION_CREATE_PARENT_ITEM:
            begin
              @FunctionCreateItem := AScript.ScriptFunctions[I].AFunction;
              if Sender <> nil then
              begin
                S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
                S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
                I2 := GetNamedValueInt(AScript, ParamNO(Command, 2), -1);
                if I2 <> -1 then
                  S2 := IntToStr(I2);
                S3 := GetNamedValueString(AScript, ParamNO(Command, 3));
                B1 := GetNamedValueBool(AScript, ParamNO(Command, 4));
                I1 := GetNamedValueInt(AScript, ParamNO(Command, 5));
                if Sender is TMenuItemW then
                  if (Sender as TMenuItemW).TopItem <> nil then
                  begin
                    ATempItem := (Sender as TMenuItemW).TopItem;
                    ATempItem.Add(FunctionCreateItem(ATempItem, S1, S2, S3, B1, I1, ImageList, ImagesCount, OnClick));
                  end;
              end;
            end;
          F_TYPE_FUNCTION_ADD_ICON:
            begin
              @FunctionAddIcon := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              I1 := FunctionAddIcon(S1, ImageList, ImagesCount);
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(I1));
            end;
          F_TYPE_PROCEDURE_WRITE_STRING:
            begin
              @ProcedureWriteString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              S1 := ProcedureWriteString(S1);
              Insert(S1, Script, N + 1);
            end;

          F_TYPE_FUNCTION_FORMAT:
            begin
              if R <> 0 then
              begin
                S1 := GetNamedValueString(AScript, FirstParam(Command));
                I1 := 2;
                repeat
                  S2 := GetNamedValueString(AScript, ParamNO(Command, I1));
                  if S2 <> '' then
                    S1 := StringReplace(S1, '{' + IntToStr(I1 - 1) + '}', S2, [rfReplaceAll]);
                  Inc(I1);
                until S2 = '';
                SetNamedValueStr(AScript, NVar, S1);
              end;
            end;

          F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING:
            begin
              @FunctionStringStringIsArrayString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, FirstParam(Command));
              S2 := GetNamedValueString(AScript, SecondParam(Command));
              if R <> 0 then
                SetNamedValueArrayStrings(AScript, NVar, FunctionStringStringIsArrayString(S1, S2))
              else
                FunctionStringStringIsArrayString(S1, S2);
            end;

          F_TYPE_FUNCTION_STRING_STRING_IS_STRING:
            begin
              @FunctionStringStringIsString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, FirstParam(Command));
              S2 := GetNamedValueString(AScript, SecondParam(Command));
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, FunctionStringStringIsString(S1, S2))
              else
                FunctionStringStringIsString(S1, S2);
            end;

          F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER:
            begin
              @FunctionStringStringIsInteger := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, FirstParam(Command));
              S2 := GetNamedValueString(AScript, SecondParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionStringStringIsInteger(S1, S2)))
              else
                FunctionStringStringIsInteger(S1, S2);
            end;

          F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN:
            begin
              @FunctionStringStringIsBool := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, FirstParam(Command));
              S2 := GetNamedValueString(AScript, SecondParam(Command));
              B1 := FunctionStringStringIsBool(S1, S2);
              if B1 then
                S1 := 'true'
              else
                S1 := 'false';
              if R <> 0 then
                SetNamedValue(AScript, NVar, S1);
            end;

          F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING:
            begin
              @FunctionStringIntegerIntegerIsInteger := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
              I1 := GetNamedValueInt(AScript, ParamNO(Command, 2));
              I2 := GetNamedValueInt(AScript, ParamNO(Command, 3));
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, FunctionStringIntegerIntegerIsInteger(S1, I1, I2))
              else
                FunctionStringIntegerIntegerIsInteger(S1, I1, I2);
            end;

          F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER:
            begin
              @FunctionStringStringIntegerIsInteger := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
              S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
              I1 := GetNamedValueInt(AScript, ParamNO(Command, 3));

              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionStringStringIntegerIsInteger(S1, S2, I1)))
              else
                FunctionStringStringIntegerIsInteger(S1, S2, I1);
            end;

          F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING:
            begin
              @FunctionStringStringStringIsString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
              S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
              S3 := GetNamedValueString(AScript, ParamNO(Command, 3));
              if R <> 0 then
                SetNamedValue(AScript, NVar, FunctionStringStringStringIsString(S1, S2, S3))
              else
                FunctionStringStringStringIsString(S1, S2, S3);
            end;

          F_TYPE_PROCEDURE_VAR_ARRAYSTRING_STRING:
            begin
              @ProcedureVarArrayStringString := AScript.ScriptFunctions[I].AFunction;
              NVar := FirstParam(Command);
              Ss1 := GetNamedValueArrayString(AScript, NVar);
              S1 := GetNamedValueString(AScript, SecondParam(Command));
              ProcedureVarArrayStringString(Ss1, S1);
              SetNamedValueArrayStrings(AScript, NVar, Ss1)
            end;

          F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING:
            begin
              @FunctionStringIsArrayString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValueArrayStrings(AScript, NVar, FunctionStringIsArrayString(S1))
              else
                FunctionStringIsArrayString(S1);
            end;
          F_TYPE_FUNCTION_IS_ARRAYSTRING:
            begin
              @FunctionIsArrayString := AScript.ScriptFunctions[I].AFunction;
              if R <> 0 then
                SetNamedValueArrayStrings(AScript, NVar, FunctionIsArrayString)
              else
                FunctionIsArrayString;
            end;
          F_TYPE_FUNCTION_ARRAYSTRING_INTEGER_IS_STRING:
            begin
              @FunctionArrayStringIntegerIsString := AScript.ScriptFunctions[I].AFunction;
              Ss1 := GetNamedValueArrayString(AScript, FirstParam(Command));
              I2 := GetNamedValueInt(AScript, SecondParam(Command));

              if R <> 0 then
                SetNamedValueStr(AScript, NVar, FunctionArrayStringIntegerIsString(Ss1, I2))
              else
                FunctionArrayStringIntegerIsString(Ss1, I2);
            end;
          F_TYPE_FUNCTION_ARRAYSTRING_IS_INTEGER:
            begin
              @FunctionArrayStringIsInteger := AScript.ScriptFunctions[I].AFunction;
              Ss1 := GetNamedValueArrayString(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionArrayStringIsInteger(Ss1)))
              else
                FunctionArrayStringIsInteger(Ss1);
            end;

          F_TYPE_PROCEDURE_NO_PARAMS:
            begin
              @SimpleProcedure := AScript.ScriptFunctions[I].AFunction;
              SimpleProcedure;
            end;

          F_TYPE_PROCEDURE_BOOLEAN:
            begin
              @ProcedureBoolean := AScript.ScriptFunctions[I].AFunction;
              B1 := GetNamedValueBool(AScript, OneParam(Command));
              ProcedureBoolean(B1);
            end;

          F_TYPE_PROCEDURE_TSCRIPT:
            begin
              @ProcedureScript := AScript.ScriptFunctions[I].AFunction;
              ProcedureScript(AScript);
            end;
          F_TYPE_PROCEDURE_TSCRIPT_STRING_W:
            begin
              @ProcedureScriptString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              if Sender <> nil then
                ProcedureScriptString(Sender, AScript, AlternativeCommand, ImagesCount, ImageList, OnClick, S1);
            end;

          F_TYPE_FUNCTION_IS_STRING:
            begin
              @FunctionString := AScript.ScriptFunctions[I].AFunction;
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, FunctionString)
              else
                FunctionString;
            end;
          F_TYPE_FUNCTION_IS_INTEGER:
            begin
              @FunctionInteger := AScript.ScriptFunctions[I].AFunction;
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionInteger))
              else
                FunctionInteger;
            end;

          F_TYPE_FUNCTION_STRING_IS_STRING:
            begin
              @FunctionStringIsString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, FunctionStringIsString(S1))
              else
                FunctionStringIsString(S1);
            end;

          F_TYPE_FUNCTION_FLOAT_IS_FLOAT:
            begin
              @FunctionFloatIsFloat := AScript.ScriptFunctions[I].AFunction;
              F1 := GetNamedValueFloat(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValueFloat(AScript, NVar, FunctionFloatIsFloat(F1))
              else
                FunctionFloatIsFloat(F1);
            end;

          F_TYPE_FUNCTION_INTEGER_IS_STRING:
            begin
              @FunctionIntegerIsString := AScript.ScriptFunctions[I].AFunction;
              I1 := GetNamedValueInt(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, FunctionIntegerIsString(I1))
              else
                FunctionIntegerIsString(I1);
            end;
          F_TYPE_FUNCTION_INTEGER_IS_INTEGER:
            begin
              @FunctionIntegerIsInteger := AScript.ScriptFunctions[I].AFunction;
              I1 := GetNamedValueInt(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionIntegerIsInteger(I1)))
              else
                FunctionIntegerIsInteger(I1);
            end;
          F_TYPE_FUNCTION_STRING_IS_INTEGER:
            begin
              @FunctionStringIsInteger := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionStringIsInteger(S1)))
              else
                FunctionStringIsInteger(S1);
            end;
          F_TYPE_PROCEDURE_STRING_STRING:
            begin
              @ProcedureStringString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, FirstParam(Command));
              S2 := GetNamedValueString(AScript, SecondParam(Command));
              ProcedureStringString(S1, S2);
            end;

          F_TYPE_PROCEDURE_ARRAYSTRING:
            begin
              @ProcedureArrayString := AScript.ScriptFunctions[I].AFunction;
              Ss1 := GetNamedValueArrayString(AScript, OneParam(Command));
              ProcedureArrayString(Ss1);
            end;

          F_TYPE_FUNCTION_INTEGER_INTEGER_IS_INTEGER:
            begin
              @FunctionIntegerIntegerIsInteger := AScript.ScriptFunctions[I].AFunction;
              I1 := GetNamedValueInt(AScript, FirstParam(Command));
              I2 := GetNamedValueInt(AScript, SecondParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionIntegerIntegerIsInteger(I1, I2)))
              else
                FunctionIntegerIntegerIsInteger(I1, I2);
            end;

          F_TYPE_PROCEDURE_STRING_STRING_STRING:
            begin
              @ProcedureStringStringString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
              S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
              S3 := GetNamedValueString(AScript, ParamNO(Command, 3));
              ProcedureStringStringString(S1, S2, S3);
            end;
          F_TYPE_PROCEDURE_STRING_STRING_INTEGER:
            begin
              @ProcedureStringStringInteger := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
              S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
              I1 := GetNamedValueInt(AScript, ParamNO(Command, 3));
              ProcedureStringStringInteger(S1, S2, I1);
            end;
          F_TYPE_PROCEDURE_STRING_STRING_BOOLEAN:
            begin
              @ProcedureStringStringBoolean := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, ParamNO(Command, 1));
              S2 := GetNamedValueString(AScript, ParamNO(Command, 2));
              B1 := GetNamedValueBool(AScript, ParamNO(Command, 3));
              ProcedureStringStringBoolean(S1, S2, B1);
            end;

          F_TYPE_PROCEDURE_INTEGER:
            begin
              @ProcedureInteger := AScript.ScriptFunctions[I].AFunction;
              I1 := GetNamedValueInt(AScript, OneParam(Command));
              ProcedureInteger(I1);
            end;
          F_TYPE_PROCEDURE_INTEGER_INTEGER:
            begin
              @ProcedureIntegerInteger := AScript.ScriptFunctions[I].AFunction;
              I1 := GetNamedValueInt(AScript, FirstParam(Command));
              I2 := GetNamedValueInt(AScript, SecondParam(Command));
              ProcedureIntegerInteger(I1, I2);
            end;
          F_TYPE_PROCEDURE_STRING:
            begin
              @ProcedureString := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              ProcedureString(S1);
            end;
          F_TYPE_PROCEDURE_INTEGER_STRING:
            begin
              @ProcedureIntegerString := AScript.ScriptFunctions[I].AFunction;
              I1 := GetNamedValueInt(AScript, FirstParam(Command));
              S2 := GetNamedValueString(AScript, SecondParam(Command));
              ProcedureIntegerString(I1, S2);
            end;
          F_TYPE_OBJ_PROCEDURE_TOBJECT:
            begin
              AScript.ScriptFunctions[I].AObjFunction(Sender);
              Continue;
            end;
          F_TYPE_FUNCTION_STRING_IS_INTEGER_OBJECT:
            begin
              S1 := GetNamedValueString(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(AScript.ScriptFunctions[I].AObjFunctinStringIsInteger(S1)))
              else
                AScript.ScriptFunctions[I].AObjFunctinStringIsInteger(S1);
            end;
          F_TYPE_FUNCTION_IS_INTEGER_OBJECT:
            begin
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(AScript.ScriptFunctions[I].AObjFunctionIsInteger))
              else
                AScript.ScriptFunctions[I].AObjFunctionIsInteger;
            end;
          F_TYPE_FUNCTION_IS_ARRAY_STRING_OBJECT:
            begin
              if R <> 0 then
                SetNamedValueArrayStrings(AScript, NVar, AScript.ScriptFunctions[I].AObjFunctionIsArrayStrings)
              else
                AScript.ScriptFunctions[I].AObjFunctionIsArrayStrings;
            end;
          F_TYPE_FUNCTION_IS_BOOL_OBJECT:
            begin
              if R <> 0 then
                SetBoolAttr(AScript, NVar, AScript.ScriptFunctions[I].AObjFunctionIsBool)
              else
                AScript.ScriptFunctions[I].AObjFunctionIsBool;
            end;
          F_TYPE_FUNCTION_IS_STRING_OBJECT:
            begin
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, AScript.ScriptFunctions[I].AObjFunctionIsString)
              else
                AScript.ScriptFunctions[I].AObjFunctionIsString;
            end;

          F_TYPE_FUNCTION_INTEGER_IS_INTEGER_OBJECT:
            begin
              I1 := GetNamedValueInt(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(AScript.ScriptFunctions[I].AObjFunctionIntegerIsInteger(I1)))
              else
                AScript.ScriptFunctions[I].AObjFunctionIntegerIsInteger(I1);
            end;
          F_TYPE_FUNCTION_INTEGER_IS_STRING_OBJECT:
            begin
              I1 := GetNamedValueInt(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, AScript.ScriptFunctions[I].AObjFunctionIntegerIsString(I1))
              else
                AScript.ScriptFunctions[I].AObjFunctionIntegerIsString(I1);
            end;
          F_TYPE_FUNCTION_STRING_IS_STRING_OBJECT:
            begin
              S1 := GetNamedValueString(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValueStr(AScript, NVar, AScript.ScriptFunctions[I].AObjFunctionStringIsString(S1))
              else
                AScript.ScriptFunctions[I].AObjFunctionStringIsString(S1);
            end;

          F_TYPE_FUNCTION_BOOLEAN_IS_BOOLEAN:
            begin
              @FunctionBooleanIsBoolean := AScript.ScriptFunctions[I].AFunction;
              B1 := GetNamedValueBool(AScript, OneParam(Command));
              B1 := FunctionBooleanIsBoolean(B1);
              if B1 then
                S1 := 'true'
              else
                S1 := 'false';
              if R <> 0 then
                SetNamedValue(AScript, NVar, S1);
            end;
          F_TYPE_FUNCTION_IS_BOOLEAN:
            begin
              @FunctionIsBoolean := AScript.ScriptFunctions[I].AFunction;
              B1 := FunctionIsBoolean;
              if B1 then
                S1 := 'true'
              else
                S1 := 'false';
              if R <> 0 then
                SetNamedValue(AScript, NVar, S1);
            end;

          F_TYPE_FUNCTION_STRING_IS_BOOLEAN:
            begin
              @FunctionStringIsBoolean := AScript.ScriptFunctions[I].AFunction;
              S1 := GetNamedValueString(AScript, OneParam(Command));
              B1 := FunctionStringIsBoolean(S1);
              if B1 then
                S1 := 'true'
              else
                S1 := 'false';
              if R <> 0 then
                SetNamedValue(AScript, NVar, S1);
            end;

          F_TYPE_FUNCTION_ARRAYINTEGER_INTEGER_IS_INTEGER:
            begin
              @FunctionArrayIntegerIntegerIsInteger := AScript.ScriptFunctions[I].AFunction;
              Ii1 := GetNamedValueArrayInt(AScript, FirstParam(Command));
              I1 := GetNamedValueInt(AScript, SecondParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionArrayIntegerIntegerIsInteger(Ii1, I1)))
              else
                FunctionArrayIntegerIntegerIsInteger(Ii1, I1);
            end;
          F_TYPE_FUNCTION_ARRAYINTEGER_IS_INTEGER:
            begin
              @FunctionArrayIntegerIsInteger := AScript.ScriptFunctions[I].AFunction;
              Ii1 := GetNamedValueArrayInt(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValue(AScript, NVar, IntToStr(FunctionArrayIntegerIsInteger(Ii1)))
              else
                FunctionArrayIntegerIsInteger(Ii1);
            end;
          F_TYPE_PROCEDURE_ARRAYINTEGER_INTEGER_INTEGER:
            begin
              @ProcedureArrayIntegerIntegerInteger := AScript.ScriptFunctions[I].AFunction;
              Ii1 := GetNamedValueArrayInt(AScript, ParamNo(Command, 1));
              I1 := GetNamedValueInt(AScript, ParamNo(Command, 2));
              I2 := GetNamedValueInt(AScript, ParamNo(Command, 3));
              ProcedureArrayIntegerIntegerInteger(Ii1, I1, I2);
            end;
          F_TYPE_PROCEDURE_VAR_ARRAYINTEGER_INTEGER:
            begin
              @ProcedureVarArrayIntegerInteger := AScript.ScriptFunctions[I].AFunction;
              NVar := FirstParam(Command);
              Ii1 := GetNamedValueArrayInt(AScript, NVar);
              I1 := GetNamedValueInt(AScript, SecondParam(Command));
              ProcedureVarArrayIntegerInteger(Ii1, I1);
              SetNamedValueArrayInt(AScript, NVar, Ii1)
            end;
          F_TYPE_FUNCTION_INTEGER_IS_ARRAYINTEGER:
            begin
              @FunctionIntegerIsArrayInteger := AScript.ScriptFunctions[I].AFunction;
              I1 := GetNamedValueInt(AScript, OneParam(Command));
              if R <> 0 then
                SetNamedValueArrayInt(AScript, NVar, FunctionIntegerIsArrayInteger(I1))
              else
                FunctionIntegerIsArrayInteger(I1);
            end;
        end;

        Break;
      end;
    end;
    if Fb = 0 then
    begin
      DoExit;
      Exit;
    end;
  until (PosEx(';', Script, Fb) < 1) or (Fb >= Length(Script));
  DoExit;
end;

function ValidMenuDescription(const Desc: string): Boolean;
var
  N, K: Integer;
begin
  Result := False;
  N := PosExS('<', Desc, 1);
  if N = 0 then
    Exit;
  N := PosExS('>', Desc, N);
  if N = 0 then
    Exit;
  N := PosExS('[', Desc, N);
  if N = 0 then
    Exit;
  N := PosExS(']', Desc, N);
  if N = 0 then
    Exit;
  N := PosExS('{', Desc, N);
  if N = 0 then
    Exit;
  K := PosExS('}', Desc, N);
  if K = 0 then
    Exit;
  Result := True;
end;

procedure DeleteMenuDescription(var Desc: string);
var
  B, N, E: Integer;
begin
  B := PosExS('<', Desc, 1);
  if B = 0 then
    Exit;
  N := PosExS('>', Desc, B);
  if N = 0 then
    Exit;
  N := PosExS('[', Desc, N);
  if N = 0 then
    Exit;
  N := PosExS(']', Desc, N);
  if N = 0 then
    Exit;
  N := PosExS('{', Desc, N);
  if N = 0 then
    Exit;
  E := PosExS('}', Desc, N);
  if E = 0 then
    Exit;
  Delete(Desc, B, E - B + 1);
end;

function MakeNewItem(Owner: TComponent; MenuItem : TMenuItem; ImageList : TImageList; Caption, Icon : string; var Script : string; var aScript : TScript; OnClick : TNotifyEvent; var ImagesCount : integer) : TMenuItemW;
var
  Item: TMenuItemW;
  Ico: TIcon;
  Command: string;
begin
  Item := TMenuItemW.Create(Owner);
  Item.Caption := Caption;
  if (Icon <> '') then
  begin
    if (Length(Icon) > 1) then
    begin
      if (Icon[2] = ':') then
      begin
        Inc(ImagesCount);
        Ico := GetSmallIconByPath(Icon);
        try
          ImageList.AddIcon(Ico);
        finally
          F(Ico);
        end;
        Item.ImageIndex := ImageList.Count - 1;
      end else
        Item.ImageIndex := StrToIntDef(Icon, -1);
    end else
      Item.ImageIndex := StrToIntDef(Icon, -1);
  end else
    Item.ImageIndex := StrToIntDef(Icon, -1);
  Item.OnClick := OnClick;
  Command := Script;
  while ValidMenuDescription(Command) do
    DeleteMenuDescription(Command);

  Item.Tag := GetNamedValueInt(AScript, '$Tag');
  Item.Visible := GetNamedValueBool(AScript, '$Visible');
  Item.default := GetNamedValueBool(AScript, '$Default');
  Item.Enabled := GetNamedValueBool(AScript, '$Enabled');
  Item.Checked := GetNamedValueBool(AScript, '$Checked');

  Item.Script := Command;
  MenuItem.Add(Item);
  Result := Item;
end;

procedure LoadItemVariables(aScript : TScript; Sender : TMenuItem);
var
  S: string;
  I: Integer;
begin
  if Sender <> nil then
  begin
    S := Sender.Caption;
    for I := 1 to Length(S) - 1 do
    begin
      if (S[I] = '&') and (S[I + 1] <> '&') then
        Delete(S, I, 1);
    end;
    SetNamedValue(AScript, '$Caption', '"' + S + '"');
    SetNamedValue(AScript, '$Tag', IntToStr(Sender.Tag));
  end;
end;

procedure LoadMenuFromScript(MenuItem : TMenuItem; ImageList : TImageList; Script : string; var aScript : TScript; OnClick : TNotifyEvent; var ImagesCount : integer; initialize : boolean);
var
  Text, Icon, Command, InitScript, RunScript, IncludeFile: string;
  I: Integer;
  Apos, Cb, Ce, Ib, Ie, Tb, Te, P, L, Scc: Integer;
  NewItem, TempItem: TMenuItemW;
  ARun: Boolean;
  VirtualItem: TMenuItemW;
  C: Char;
  LInitString, LRun: Integer;
  PC: Integer;
  PInit, PRun: PChar;

const
  ItitStringCommand = 'initialization:';
  RunStringCommand = 'run:';

  function IsInit(PCommand, L : Integer) : Boolean;
  var
    J, P : Integer;
    C : Char;
  begin
    Result := True;
    for J := 0 to LInitString div 2 - 1 do
    begin
      P := PCommand + J * 2;
      if P > L then
        Exit;
      C := PChar(P)^;
      if ItitStringCommand[J + 1] <> C then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

  function IsRun(PCommand, L : Integer) : Boolean;
  var
    J, P : Integer;
    C : Char;
  begin
    Result := True;
    for J := 0 to LRun div 2 - 1 do
    begin
      P := PCommand + J * 2;
      if P > L then
        Exit;
      C := PChar(P)^;
      if RunStringCommand[J + 1] <> C then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

begin
  NewItem := nil;
  Apos := 1;
  MenuItem.Clear;
  if Initialize then
    for I := 1 to ImagesCount do
    begin
      if ImageList.Count = 0 then
        Break;
      ImageList.Delete(ImageList.Count - 1);
      ImagesCount := 0;
    end;
  LInitString := Length(ItitStringCommand) * SizeOf(Char);
  LRun := Length(RunStringCommand) * SizeOf(Char);
  if Script = '' then
    Exit;
  repeat
    Tb := PosExS('<', Script, Apos);
    Te := PosExS('>', Script, Tb);
    Ib := PosExS('[', Script, Te);
    Ie := PosExS(']', Script, Ib);
    Cb := PosExS('{', Script, Ie);
    Ce := PosExS('}', Script, Cb);
    Text := Copy(Script, Tb + 1, Te - Tb - 1);
    Text := TTranslateManager.Instance.SmartTranslate(Text, 'DBMenu');
    Icon := Copy(Script, Ib + 1, Ie - Ib - 1);
    Command := Copy(Script, Cb + 1, Ce - Cb - 1);

    if (Tb <> 0) and (Te <> 0) and (Ib <> 0) and (Ie <> 0) and (Cb <> 0) and (Ce <> 0) then
    begin
      if (Length(Trim(Text)) > 0) then
      begin
        if Trim(Text) = '#' then
        begin
          if MenuItem <> nil then
          begin
            if MenuItem is TMenuItemW then
              TempItem := MenuItem as TMenuItemW
            else
              TempItem := nil;
          end else
            TempItem := nil;
          ExecuteScriptFile(TempItem, AScript, '', ImagesCount, ImageList, OnClick, Command);
        end
        else
        begin
          TW.I.Start('Init-Run: ' + Copy(Command, 1, 20));
          if Command <> '' then
          begin
            ARun := True;
            SetLength(InitScript, Length(Command));
            FillChar(InitScript[1], Length(Command) * 2, 0);
            PInit := PChar(Addr(InitScript[1]));
            SetLength(RunScript, Length(Command));
            FillChar(RunScript[1], Length(Command) * 2, 0);
            PRun := PChar(Addr(RunScript[1]));

            Scc := 0;
            P := Integer(Addr(Command[1]));
            L := Integer(Addr(Command[Length(Command)]));
            if Length(Command) > 0 then
            begin
              repeat
                C := PChar(P)[0];
                if C = '{' then
                  Inc(Scc)
                else if C = '}' then
                  Dec(Scc);

                if Scc = 0 then
                begin

                  if IsInit(P, L) then
                  begin
                    ARun := False;
                    Inc(P, LInitString);
                    C := PChar(P)[0];
                  end
                  else if IsRun(P, L) then
                  begin
                    ARun := True;
                    Inc(P, LRun);
                    C := PChar(P)[0];
                  end;

                end;
                if ARun then
                begin
                  PRun[0] := C;
                  Inc(PRun, 1);
                end
                else
                begin
                  PInit[0] := C;
                  Inc(PInit, 1);
                end;

                Inc(P, 2);
              until P > L;
            end;

            InitScript := Trim(InitScript);
            RunScript := Trim(RunScript);
          end;
          TW.I.Start('END - Init-Run');


          SetNamedValue(AScript, '$Tag', '0');
          SetNamedValue(AScript, '$Visible', 'true');
          SetNamedValue(AScript, '$Default', 'false');
          SetNamedValue(AScript, '$Enabled', 'true');
          SetNamedValue(AScript, '$Checked', 'false');
          VirtualItem := TMenuItemW.Create(MenuItem.Owner);
          try
            VirtualItem.TopItem := MenuItem;
            ExecuteScript(VirtualItem, AScript, InitScript, ImagesCount, ImageList, OnClick);
            NewItem := MakeNewItem(MenuItem.Owner, MenuItem, ImageList, Text, Icon, RunScript, AScript, OnClick,
              ImagesCount);
            for I := 0 to VirtualItem.Count - 1 do
            begin
              TempItem := TMenuItemW.Create(NewItem);
              TempItem.Caption := VirtualItem.Items[I].Caption;
              TempItem.Script := (VirtualItem.Items[I] as TMenuItemW).Script;
              TempItem.ImageIndex := VirtualItem.Items[I].ImageIndex;
              TempItem.default := VirtualItem.Items[I].default;
              TempItem.Tag := VirtualItem.Items[I].Tag;
              TempItem.OnClick := VirtualItem.Items[I].OnClick;
              NewItem.Add(TempItem);
            end;
          finally
            F(VirtualItem);
          end;
        end;
      end else
      begin
        IncludeFile := Include(Command);
        Insert(IncludeFile, Script, Ce + 1);
      end;
    end;
    if RunScript <> '' then
      if ValidMenuDescription(RunScript) then
      begin
        LoadMenuFromScript(NewItem, ImageList, RunScript, AScript, OnClick, ImagesCount, False);
      end;

    if (Ce = 0) or (Cb = 0) or (Ie = 0) or (Ib = 0) or (Te = 0) or (Tb = 0) then
      Break;
    Delete(Script, Tb, Ce - Tb + 1);
    Apos := Tb;
  until PosEx('<', Script, Apos) < 1;
end;

function CalcExpression(aScript : TScript; const Expression : string) : string;
var
  N, Nnew: Integer;
  S, ResS: string;

begin
  case GetValueType(AScript, Expression) of
    VALUE_TYPE_STRING:
      Result := 'String(' + Expression + ');';
    VALUE_TYPE_INTEGER:
      Result := 'Integer(' + Expression + ');';
    VALUE_TYPE_BOOLEAN:
      Result := 'Boolean(' + Expression + ');';
  else
    begin
      if Expression <> '' then
        if Expression[1] = '#' then
        begin
          S := FloatToStr(UnitScriptsMath.StringToFloatScript(Copy(Expression, 2, Length(Expression) - 1), AScript));
          UnMakeFloat(S);
          Result := 'Float(' + S + ')';
          Exit;
        end;
      if Expression <> '' then
        if Expression[1] = '%' then
        begin
          S := Copy(Expression, 2, Length(Expression) - 1);
          N := Trunc(UnitScriptsMath.StringToFloatScript(S, AScript));
          S := IntToStr(N);
          Result := 'Integer(' + S + ')';
          Exit;
        end;

      N := 1;
      ResS := '';
      if PosExS('+', Expression) <> 0 then
      begin
        repeat
          Nnew := PosExS('+', Expression, N);
          if Nnew <> 0 then
          begin
            S := Copy(Expression, N, Nnew - N);
            if GetValueType(AScript, S) = VALUE_TYPE_STRING then
              ResS := ResS + GetNamedValueString(AScript, S);
            N := Nnew + 1;
          end;
        until Nnew = 0;
        S := Copy(Expression, N, Length(Expression) - N + 1);
        ResS := ResS + GetNamedValueString(AScript, S);
        Result := 'String(' + AnsiQuotedStr(ResS, '"') + ');';
      end else
        Result := Expression;
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

procedure AddScriptFunction(Enviroment : TScriptEnviroment; const FunctionName : String; FunctionType : integer; FunctionPointer : Pointer; ReplaceExisted : Boolean = False);
var
  FFunction: TScriptFunction;
begin
  FFunction := TScriptFunction.Create;
  FFunction.Name := FunctionName;
  FFunction.aType := FunctionType;
  FFunction.aFunction := FunctionPointer;
  Enviroment.Functions.Register(FFunction, ReplaceExisted);
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

function ASetString(const S: string): string;
begin
  Result := S;
end;

function ASetInteger(Int: Integer): Integer;
begin
  Result := Int;
end;

function ASetFloat(Float: Extended): Extended;
begin
  Result := Float;
end;

function WriteCode(const Str: string): string;
begin
  Result := Str;
end;

function Include(FileName : string) : string;
begin
  Result := ReadScriptFile(FileName);
end;

function ReadScriptFile(FileName : string) : string;
var
  D, S: string;
  I, P: Integer;
  F: TInitScriptFunction;
  Script: TIncludeScript;
  FS: TStrings;
begin
  if ScriptsManager <> nil then
  begin
    Script := ScriptsManager.GetIncludeScript(FileName);
    if Script <> nil then
    begin
      Result := Script.ScriptContent;
      Exit;
    end;
  end;
  Result := '';
  if Length(FileName) < 4 then
    Exit;
  if (FileName[1] = '"') and (FileName[Length(FileName)] = '"') then
    FileName := Copy(FileName, 2, Length(FileName) - 2);
  if FileName[2] = ':' then
    D := FileName
  else if FolderView then
    D := ExtractFileName(FileName)
  else
    D := ExtractFileDir(Paramstr(0)) + '\' + FileName;

  if FileExists(D) or FolderView then
  begin
    FS := TStringList.Create;
    try
      try
        if not FolderView then
          FS.LoadFromFile(D)
        else
          FS.Text := ReadInternalFSContent(D)
      except
        Exit;
      end;
      for I := 0 to FS.Count - 1 do
      begin
        S := FS[I];
        P := PosExK('//', S);
        if P > 0 then
        begin
          FS[I] := Copy(S, 1, P - 1);
        end;
      end;
      Result := FS.Text;
    finally
      FS.Free;
    end;

    Result := StringReplace(Result, #13#10, '', [RfReplaceAll]);
    if InitScriptFunction <> nil then
    begin
      @F := InitScriptFunction;
      Result := F(Result);
    end;
    Result := Result;
  end;

  if ScriptsManager <> nil then
    ScriptsManager.RegisterIncludeScript(FileName, Result);
end;

function Float(Ext: Extended): Extended;
begin
  Result := Ext;
end;

function ArrayStringLength(aArray : TArrayOfString) : integer;
begin
  Result := Length(AArray);
end;

function GetStringItem(aArray : TArrayOfString; int : integer) : string;
begin
  if Int <= Length(AArray) - 1 then
    Result := AArray[Int]
  else
    Result := '';
end;

function ArrayIntLength(AArray: TArrayOfInt): Integer;
begin
  Result := Length(AArray);
end;

function GetIntItem(AArray: TArrayOfInt; Int: Integer): Integer;
begin
  if Int <= Length(AArray) - 1 then
    Result := AArray[Int]
  else
    Result := 0;
end;

procedure SetIntItem(AArray: TArrayOfInt; index, Value: Integer);
begin
  if index <= Length(AArray) - 1 then
    AArray[index] := Value;
end;

function GetIntArray(Int: Integer): TArrayOfInt;
begin
  if Int < 0 then
    SetLength(Result, 0)
  else
    SetLength(Result, Int);
end;

function GetStringArray(Int: Integer): TArrayOfInt;
begin
  if Int < 0 then
    SetLength(Result, 0)
  else
    SetLength(Result, Int);
end;

procedure AddIntItem(var AArray: TArrayOfInt; Value: Integer);
var
  L: Integer;
begin
  L := Length(AArray);
  SetLength(AArray, L + 1);
  AArray[L] := Value;
end;

procedure AddStringItem(var AArray: TArrayOfString; Value: string);
var
  L: Integer;
begin
  L := Length(AArray);
  SetLength(AArray, L + 1);
  AArray[L] := Value;
end;

function CreateItem(aOwner: TMenuItem; Caption, Icon, Script: string; Default : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
var
  Ico : TIcon;
begin
 Result:= TMenuItemW.Create(AOwner);
  Result.Caption := TTranslateManager.Instance.SmartTranslate(Caption, 'DBMenu');
  Result.Script := Script;
  Result.default := default;
  Result.OnClick := OnClick;
  Result.Tag := Tag;
  if (Icon <> '') then
  begin
    if (Length(Icon) > 1) then
    begin
      if (Icon[2] = ':') then
      begin
        Inc(ImagesCount);
        Ico := GetSmallIconByPath(Icon);
        try
          ImageList.AddIcon(Ico);
        finally
          F(Ico);
        end;
        Result.ImageIndex := ImageList.Count - 1;
      end else
        Result.ImageIndex := StrToIntDef(Icon, -1);
    end else
      Result.ImageIndex := StrToIntDef(Icon, -1);
  end else
    Result.ImageIndex := StrToIntDef(Icon, -1);
end;

function CreateItemDef(aOwner: TMenuItem; Caption, Icon, Script: string; Default, Enabled : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
var
  Ico: TIcon;
begin
  Result := TMenuItemW.Create(AOwner);
  Result.Caption := TTranslateManager.Instance.SmartTranslate(Caption, 'DBMenu');
  Result.Script := Script;
  Result.default := default;
  Result.OnClick := OnClick;
  Result.Enabled := Enabled;
  Result.Tag := Tag;
  if (Icon <> '') then
  begin
    if (Length(Icon) > 1) then
    begin
      if (Icon[2] = ':') then
      begin
        Inc(ImagesCount);
        Ico := GetSmallIconByPath(Icon);
        try
          ImageList.AddIcon(Ico);
        finally
          F(Ico);
        end;
        Result.ImageIndex := ImageList.Count - 1;
      end else
        Result.ImageIndex := StrToIntDef(Icon, -1);
    end else
      Result.ImageIndex := StrToIntDef(Icon, -1);
  end else
    Result.ImageIndex := StrToIntDef(Icon, -1);
end;

function CreateItemDefChecked(aOwner: TMenuItem; Caption, Icon, Script: string; Default, Enabled, Checked : boolean; Tag : integer; ImageList : TImageList; var ImagesCount : integer; OnClick : TNotifyEvent) : TMenuItemW;
var
  Ico : TIcon;
begin
  Result := TMenuItemW.Create(AOwner);
  Result.Caption := TTranslateManager.Instance.SmartTranslate(Caption, 'DBMenu');
  Result.Script := Script;
  Result.Default := default;
  Result.OnClick := OnClick;
  Result.Enabled := Enabled;
  Result.Checked := Checked;
  Result.Tag := Tag;
  if (Icon <> '') then
  begin
    if (Length(Icon) > 1) then
    begin
      if (Icon[2] = ':') then
      begin
        Inc(ImagesCount);
        Ico := GetSmallIconByPath(Icon);
        try
          ImageList.AddIcon(Ico);
        finally
          F(Ico);
        end;
        Result.ImageIndex := ImageList.Count - 1;
      end else
        Result.ImageIndex := StrToIntDef(Icon, -1);
    end else
      Result.ImageIndex := StrToIntDef(Icon, -1);
  end else
    Result.ImageIndex := StrToIntDef(Icon, -1);
end;

function aBoolean(bool : boolean) : boolean;
begin
  Result:=bool;
end;

function aFileExists(FileName : string) : boolean;
var
  D: string;
  OldMode: Cardinal;
begin
  Result := False;
  if Length(FileName) < 4 then
    Exit;

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if (FileName[1] = '"') and (FileName[Length(FileName)] = '"') then
      FileName := Copy(FileName, 2, Length(FileName) - 2);
    if FileName[2] = ':' then
      D := FileName
    else
      D := ExtractFileDir(Paramstr(0)) + '\' + FileName;
    if FileExists(D) then
      Result := True
    else
      Result := FileExists(FileName);
  finally
    SetErrorMode(OldMode);
  end;
end;

{ TMenuItemW }

constructor TMenuItemW.Create(aOwner: TComponent);
begin
  inherited;
  TopItem := nil;
end;

procedure SetNamedValueInt(AScript: TScript; name: string; Value: Integer);
begin
  SetNamedValue(AScript, name, IntToStr(Value));
end;

procedure InitializeScript(AScript: TScript);
begin
  AScript.ParentScript := nil;
end;

procedure SetBoolAttr(AScript: TScript; name: string; Value: Boolean);
begin
  if Value then
    SetNamedValue(AScript, name, 'true')
  else
    SetNamedValue(AScript, name, 'false');
end;

procedure SetIntAttr(AScript: TScript; name: string; Value: Integer);
begin
  SetNamedValue(AScript, name, IntToStr(Value));
end;

procedure Clear(Item: TMenuItem);
begin
  Item.Clear;
end;

procedure DeleteNoFirst(Item: TMenuItem);
var
  I: Integer;
begin
  for I := 1 to Item.Count - 1 do
    Item.Delete(1);
end;

procedure ClearMemory(const AScript: TScript);
begin
  AScript.NamedValues.Clear;
end;

function VarValue(aScript : TScript; const Variable : string; List : TListBox = nil) : string;
var
  Value: TValue;
  J: Integer;
  StringResult: Boolean;
begin
  Result := '';
  Value := AScript.NamedValues.GetValueByName(Variable);
  StringResult := List = nil;

  case Value.AType of
    VALUE_TYPE_ERROR:
      begin
        Result := '[' + Variable + ']=ERROR!';
      end;
    VALUE_TYPE_STRING:
      begin
        Result := '[' + Variable + ']=''' + Value.StrValue + '''';
      end;
   VALUE_TYPE_INTEGER:
      begin
        Result := '[' + Variable + ']=' + IntToStr(Value.IntValue) + '';
      end;
    VALUE_TYPE_BOOLEAN:
      begin
        if Value.BoolValue then
          Result := '[' + Variable + ']=true'
        else
          Result := '[' + Variable + ']=false';
      end;
    VALUE_TYPE_FLOAT:
      begin
        Result := '[' + Variable + ']=' + FloatToStr(Value.FloatValue) + '';
      end;
    VALUE_TYPE_STRING_ARRAY:
      begin
        if StringResult then
        begin
          Result := 'string[';
          for J := 0 to Length(Value.StrArray) - 1 do
          begin
            if J <> 0 then
              Result := Result + ',';
            Result := Result + '"' + Value.StrArray[J] + '"';
          end;
          Result := Result + ']';
          Exit;
        end;
        List.Items.Add('[' + Variable + '] = array of string[' + IntToStr(Length(Value.StrArray)) + ']:');
        for J := 0 to Length(Value.StrArray) - 1 do
          List.Items.Add('  ' + IntToStr(J + 1) + ')  ''' + Value.StrArray[J] + '''');
      end;
    VALUE_TYPE_INT_ARRAY:
      begin
        if StringResult then
        begin
          Result := 'integer[';
          for J := 0 to Length(Value.StrArray) - 1 do
          begin
            if J <> 0 then
              Result := Result + ',';
            Result := Result + IntToStr(Value.IntArray[J]);
          end;
          Result := Result + ']';
          Exit;
        end;
        List.Items.Add('[' + Variable + '] = array of integer[' + IntToStr(Length(Value.IntArray)) + ']:');
        for J := 0 to Length(Value.IntArray) - 1 do
          List.Items.Add('  ' + IntToStr(J + 1) + ')  ' + IntToStr(Value.IntArray[J]));
      end;
    VALUE_TYPE_BOOL_ARRAY:
      begin
        List.Items.Add('[' + Variable + '] = array of boolean[' + IntToStr(Length(Value.BoolArray)) + ']:');
        for J := 0 to Length(Value.BoolArray) - 1 do
        begin
          if Value.BoolArray[J] then
            List.Items.Add('  ' + IntToStr(J + 1) + ')  true')
          else
            List.Items.Add('  ' + IntToStr(J + 1) + ')  false');
        end;
      end;
    VALUE_TYPE_FLOAT_ARRAY:
      begin
        List.Items.Add('[' + Variable + '] = array of float[' + IntToStr(Length(Value.FloatArray)) + ']:');
        for J := 0 to Length(Value.FloatArray) - 1 do
          List.Items.Add('  ' + IntToStr(J + 1) + ')  ' + FloatToStr(Value.FloatArray[J]));
      end;
  end;
end;

procedure ShowMemoryStatus(const aScript : TScript);
var
  StatusForm: TForm;
  List: TListBox;
  I: Integer;
begin
  Application.CreateForm(TForm, StatusForm);
  try
    StatusForm.Caption := Format(TA('Memory for [%s]', 'DBMenu'), [AScript.Description]);
    List := TListBox.Create(StatusForm);
    List.Parent := StatusForm;
    List.Align := AlClient;
    StatusForm.Position := PoScreenCenter;
    for I := 0 to AScript.NamedValues.Count - 1 do
      VarValue(AScript, AScript.NamedValues[I].AName, List);

    StatusForm.ShowModal;
  finally
    R(StatusForm);
  end;
end;

procedure ShowFunctionList(const aScript : TScript);
var
  StatusForm: TForm;
  List: TListBox;
  I, J: Integer;
  FunctionsList: TStringList;

  function GetTypeName(AType: Integer): string;
  var
    I: Integer;
  begin
    Result := TA('Unknown', 'DBMenu');
    for I := 1 to FTypesLength do
    begin
      if FTypesInt[I] = AType then
      begin
        Result := FTypes[I];
        Break;
      end;
    end;
  end;

begin
  Application.CreateForm(TForm, StatusForm);
  try
    StatusForm.Caption := Format(TA('Functions for [%s]', 'DBMenu'), [AScript.Description]);
    List := TListBox.Create(StatusForm);
    List.Parent := StatusForm;
    List.Align := AlClient;
    StatusForm.Width := 500;
    StatusForm.Height := 300;
    StatusForm.Position := PoScreenCenter;

    FunctionsList:= TStringList.Create;
    for I := 0 to AScript.ScriptFunctions.Count - 1 do
      FunctionsList.Add(AScript.ScriptFunctions[I].Name + '   [' + GetTypeName(AScript.ScriptFunctions[I].AType) + ']');

    for J := 0 to FunctionsList.Count - 1 do
      for I := 0 to FunctionsList.Count - 2 do
        if CompareStr(FunctionsList[I], FunctionsList[I + 1]) > 0 then
          FunctionsList.Exchange(I, I + 1);

    List.Items.Assign(FunctionsList);

    StatusForm.ShowModal;
  finally
    R(StatusForm);
  end;
end;

procedure ExecuteScriptFile(Sender: TMenuItemW; var AScript: TScript; AlternativeCommand: string;
  var ImagesCount: Integer; ImageList: TImageList; OnClick: TNotifyEvent = nil; FileName: string = '');
var
  FileText: string;
begin
  FileText := ReadScriptFile(FileName);
  ExecuteScript(Sender, AScript, FileText, ImagesCount, ImageList, OnClick);
end;

function AMessageBox(Text, Caption: string; Params: Integer): Integer;
begin
  Result := Application.MessageBox(PWideChar(Text), PWideChar(Caption), Params);
end;

function ReplaceString(Str: string; WhatReplase, ToReplase: string): string;
begin
  Result := StringReplace(Str, WhatReplase, ToReplase, [RfReplaceAll, RfIgnoreCase]);
end;

function ReplaceStringAll(Str: string; WhatReplase, ToReplase: string): string;
begin
  Result := StringReplace(Str, WhatReplase, ToReplase, [RfIgnoreCase]);
end;

function TranslateMenuString(Str: string): string;
begin
  Result := TA(Str, 'DBMenu');
end;

function GetCurrentUser: string;
begin
  Result := TActivationManager.Instance.ActivationUserName;
  if Result = '' then
    Result := TA('Unregistered user');
end;

procedure LoadBaseFunctions(Enviroment: TScriptEnviroment);
begin
  AddScriptFunction(Enviroment, 'ShowString', F_TYPE_PROCEDURE_STRING, @ShowString);
  AddScriptFunction(Enviroment, 'Format', F_TYPE_FUNCTION_FORMAT, nil);

  AddScriptFunction(Enviroment, 'REGISTER_SCRIPT', F_TYPE_FUNCTION_REGISTER_SCRIPT, nil);

  AddScriptFunction(Enviroment, 'START_DEBUG', F_TYPE_FUNCTION_DEBUG_START, nil);
  AddScriptFunction(Enviroment, 'STOP_DEBUG', F_TYPE_FUNCTION_DEBUG_END, nil);
  AddScriptFunction(Enviroment, 'LOAD_VARS', F_TYPE_FUNCTION_LOAD_VARS, nil);
  AddScriptFunction(Enviroment, 'SAVE_VAR', F_TYPE_FUNCTION_SAVE_VAR, nil);
  AddScriptFunction(Enviroment, 'DELETE_VAR', F_TYPE_FUNCTION_DELETE_VAR, nil);

  AddScriptFunction(Enviroment, 'ReplaceString', F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING, @ReplaceString);
  AddScriptFunction(Enviroment, 'ReplaceStringAll', F_TYPE_FUNCTION_STRING_STRING_STRING_IS_STRING, @ReplaceStringAll);

  AddScriptFunction(Enviroment, 'ArrayIntLength', F_TYPE_FUNCTION_ARRAYINTEGER_IS_INTEGER, @ArrayIntLength);
  AddScriptFunction(Enviroment, 'GetIntItem', F_TYPE_FUNCTION_ARRAYINTEGER_INTEGER_IS_INTEGER, @GetIntItem);
  AddScriptFunction(Enviroment, 'SetIntItem', F_TYPE_PROCEDURE_ARRAYINTEGER_INTEGER_INTEGER, @SetIntItem);
  AddScriptFunction(Enviroment, 'GetIntArray', F_TYPE_FUNCTION_INTEGER_IS_ARRAYINTEGER, @GetIntArray);
  AddScriptFunction(Enviroment, 'AddIntItem', F_TYPE_PROCEDURE_VAR_ARRAYINTEGER_INTEGER, @AddIntItem);
  AddScriptFunction(Enviroment, 'AddStringItem', F_TYPE_PROCEDURE_VAR_ARRAYSTRING_STRING, @AddStringItem);
  AddScriptFunction(Enviroment, 'GetStringArray', F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING, @GetStringArray);
  AddScriptFunction(Enviroment, 'Clear', F_TYPE_PROCEDURE_CLEAR, @Clear);
  AddScriptFunction(Enviroment, 'DeleteNoFirst', F_TYPE_PROCEDURE_CLEAR, @DeleteNoFirst);
  AddScriptFunction(Enviroment, 'SetNamedValue', F_TYPE_PROCEDURE_STRING_STRING, @SetNamedValue);
  AddScriptFunction(Enviroment, 'String', F_TYPE_FUNCTION_STRING_IS_STRING, @ASetString);
  AddScriptFunction(Enviroment, 'Integer', F_TYPE_FUNCTION_INTEGER_IS_INTEGER, @ASetInteger);
  AddScriptFunction(Enviroment, 'WriteCode', F_TYPE_PROCEDURE_WRITE_STRING, @WriteCode);
  AddScriptFunction(Enviroment, 'Include', F_TYPE_PROCEDURE_WRITE_STRING, @Include);
{$IFNDEF EXT}
  AddScriptFunction(Enviroment, 'SumInt', F_TYPE_FUNCTION_INTEGER_INTEGER_IS_INTEGER, @SumInt);
  AddScriptFunction(Enviroment, 'SumStr', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @SumStr);
  AddScriptFunction(Enviroment, 'ArrayStringLength', F_TYPE_FUNCTION_ARRAYSTRING_IS_INTEGER, @ArrayStringLength);
  AddScriptFunction(Enviroment, 'GetStringItem', F_TYPE_FUNCTION_ARRAYSTRING_INTEGER_IS_STRING, @GetStringItem);
  AddScriptFunction(Enviroment, 'CreateItem', F_TYPE_FUNCTION_CREATE_ITEM, @CreateItem);
  AddScriptFunction(Enviroment, 'CreateItemDef', F_TYPE_FUNCTION_CREATE_ITEM_DEF, @CreateItemDef);
  AddScriptFunction(Enviroment, 'CreateItemDefChecked', F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED, @CreateItemDefChecked);
  AddScriptFunction(Enviroment, 'CreateItemDefCheckedSubTag', F_TYPE_FUNCTION_CREATE_ITEM_DEF_CHECKED_SUBTAG,
    @CreateItemDefChecked);
  AddScriptFunction(Enviroment, 'CreateParentItem', F_TYPE_FUNCTION_CREATE_PARENT_ITEM, @CreateItem);

  AddScriptFunction(Enviroment, 'IntToStr', F_TYPE_FUNCTION_INTEGER_IS_STRING, @AIntToStr);
  AddScriptFunction(Enviroment, 'SplitWords', F_TYPE_FUNCTION_STRING_IS_ARRAYSTRING, @SpilitWords);
  AddScriptFunction(Enviroment, 'ReadFile', F_TYPE_FUNCTION_STRING_IS_STRING, @ReadFile);
  AddScriptFunction(Enviroment, 'Default', F_TYPE_PROCEDURE_TSCRIPT, @default);
  AddScriptFunction(Enviroment, 'InVisible', F_TYPE_PROCEDURE_TSCRIPT, @InVisible);
  AddScriptFunction(Enviroment, 'Disabled', F_TYPE_PROCEDURE_TSCRIPT, @Disabled);
  AddScriptFunction(Enviroment, 'Checked', F_TYPE_PROCEDURE_TSCRIPT, @Checked);
  AddScriptFunction(Enviroment, 'AddIcon', F_TYPE_FUNCTION_ADD_ICON, @AddIcon);
  AddScriptFunction(Enviroment, 'Boolean', F_TYPE_FUNCTION_BOOLEAN_IS_BOOLEAN, @ABoolean);
  AddScriptFunction(Enviroment, 'GetDirListing', F_TYPE_FUNCTION_STRING_STRING_IS_ARRAYSTRING, @GetDirListing);
  AddScriptFunction(Enviroment, 'FileExists', F_TYPE_FUNCTION_STRING_IS_BOOLEAN, @AFileExists);
  AddScriptFunction(Enviroment, 'DirectoryExists', F_TYPE_FUNCTION_STRING_IS_BOOLEAN, @ADirectoryExists);
  AddScriptFunction(Enviroment, 'DirectoryFileExists', F_TYPE_FUNCTION_STRING_IS_BOOLEAN, @ADirectoryFileExists);
  AddScriptFunction(Enviroment, 'AddAssociatedIcon', F_TYPE_FUNCTION_ADD_ICON, @AddAssociatedIcon);
  AddScriptFunction(Enviroment, 'PathFormat', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @APathFormat);
  AddScriptFunction(Enviroment, 'GetUSBDrives', F_TYPE_FUNCTION_IS_ARRAYSTRING, @GetUSBDrives);
  AddScriptFunction(Enviroment, 'GetCDROMDrives', F_TYPE_FUNCTION_IS_ARRAYSTRING, @GetCDROMDrives);
  AddScriptFunction(Enviroment, 'GetAllDrives', F_TYPE_FUNCTION_IS_ARRAYSTRING, @GetAllDrives);
  AddScriptFunction(Enviroment, 'GetDriveName', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @GetDriveName);
  AddScriptFunction(Enviroment, 'GetMyPicturesFolder', F_TYPE_FUNCTION_IS_STRING, @GetMyPicturesFolder);
  AddScriptFunction(Enviroment, 'GetMyDocumentsFolder', F_TYPE_FUNCTION_IS_STRING, @GetMyDocumentsFolder);
  AddScriptFunction(Enviroment, 'ShowInt', F_TYPE_PROCEDURE_INTEGER, @ShowInt);
  AddScriptFunction(Enviroment, 'Sleep', F_TYPE_PROCEDURE_INTEGER, @Sleep);
  AddScriptFunction(Enviroment, 'AltKeyDown', F_TYPE_FUNCTION_IS_BOOLEAN, @AltKeyDown);
  AddScriptFunction(Enviroment, 'CtrlKeyDown', F_TYPE_FUNCTION_IS_BOOLEAN, @CtrlKeyDown);
  AddScriptFunction(Enviroment, 'ShiftKeyDown', F_TYPE_FUNCTION_IS_BOOLEAN, @ShiftKeyDown);
  AddScriptFunction(Enviroment, 'NowString', F_TYPE_FUNCTION_IS_STRING, @NowString);
  AddScriptFunction(Enviroment, 'LoadFilesFromClipBoard', F_TYPE_FUNCTION_IS_ARRAYSTRING, @LoadFilesFromClipBoardA);
  AddScriptFunction(Enviroment, 'ClipboardCopyFile', F_TYPE_PROCEDURE_STRING, @CopyFile);
  AddScriptFunction(Enviroment, 'ClipboardCutFile', F_TYPE_PROCEDURE_STRING, @CutFile);
  AddScriptFunction(Enviroment, 'ClipboardCopyFiles', F_TYPE_PROCEDURE_ARRAYSTRING, @CopyFiles);
  AddScriptFunction(Enviroment, 'ClipboardCutFiles', F_TYPE_PROCEDURE_ARRAYSTRING, @CutFiles);
  AddScriptFunction(Enviroment, 'ShowMemoryStatus', F_TYPE_PROCEDURE_TSCRIPT, @ShowMemoryStatus);
  AddScriptFunction(Enviroment, 'ClearMemory', F_TYPE_PROCEDURE_TSCRIPT, @ClearMemory);
  AddScriptFunction(Enviroment, 'ShowFunctionList', F_TYPE_PROCEDURE_TSCRIPT, @ShowFunctionList);

  AddScriptFunction(Enviroment, 'StrToInt', F_TYPE_FUNCTION_STRING_IS_INTEGER, @AStrToInt);
  AddScriptFunction(Enviroment, 'Pos', F_TYPE_FUNCTION_STRING_STRING_IS_INTEGER, @APos);
  AddScriptFunction(Enviroment, 'StrCopy', F_TYPE_FUNCTION_STRING_INTEGER_INTEGER_IS_STRING, @AStrCopy);

  AddScriptFunction(Enviroment, 'GetOpenDirectory', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @GetOpenDirectory);

  AddScriptFunction(Enviroment, 'GetProgramFolder', F_TYPE_FUNCTION_IS_STRING, @GetProgramFolder);
  AddScriptFunction(Enviroment, 'ExtractFileName', F_TYPE_FUNCTION_STRING_IS_STRING, @AExtractFileName);

  AddScriptFunction(Enviroment, 'ExtractFileDirectory', F_TYPE_FUNCTION_STRING_IS_STRING, @ExtractFileDirectory);
  AddScriptFunction(Enviroment, 'ExecuteScriptFile', F_TYPE_PROCEDURE_TSCRIPT_STRING_W, @ExecuteScriptFile);
{$ENDIF EXT}
  AddScriptFunction(Enviroment, 'MessageBox', F_TYPE_FUNCTION_STRING_STRING_INTEGER_IS_INTEGER, @AMessageBox);
  AddScriptFunction(Enviroment, 'Float', F_TYPE_FUNCTION_FLOAT_IS_FLOAT, @Float);

  AddScriptFunction(Enviroment, 'FileInPath', F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN, @FileInPath);

  AddScriptFunction(Enviroment, 'FileHasExt', F_TYPE_FUNCTION_STRING_STRING_IS_BOOLEAN, @UnitScriptsFunctions.FileHasExt);
  AddScriptFunction(Enviroment, 'T', F_TYPE_FUNCTION_STRING_IS_STRING, @TranslateMenuString);
  AddScriptFunction(Enviroment, 'GetCurrentUser', F_TYPE_FUNCTION_IS_STRING, @GetCurrentUser);

  //////////////////////////////////////////////////////////////////////////////
  //Portable Device Functions
  //////////////////////////////////////////////////////////////////////////////
  AddScriptFunction(Enviroment, 'GetPortableDevices', F_TYPE_FUNCTION_IS_ARRAYSTRING, @GetPortableDevices);
  AddScriptFunction(Enviroment, 'GetPortableDeviceIcon', F_TYPE_FUNCTION_ADD_ICON, @GetPortableDeviceIcon);
end;

procedure LoadFileFunctions(Enviroment: TScriptEnviroment);
begin
{$IFNDEF EXT}
  AddScriptFunction(Enviroment, 'CopyFile', F_TYPE_PROCEDURE_STRING_STRING, @ACopyFile);
  AddScriptFunction(Enviroment, 'CopyFileSynch', F_TYPE_PROCEDURE_STRING_STRING, @CopyFileSynch);
  AddScriptFunction(Enviroment, 'RenameFile', F_TYPE_PROCEDURE_STRING_STRING, @ARenameFile);
  AddScriptFunction(Enviroment, 'Run', F_TYPE_PROCEDURE_STRING_STRING, @Run);
  AddScriptFunction(Enviroment, 'RunWait', F_TYPE_PROCEDURE_STRING_STRING, @ExecAndWait);
  AddScriptFunction(Enviroment, 'DeleteFile', F_TYPE_PROCEDURE_STRING, @ADeleteFile);
  AddScriptFunction(Enviroment, 'Exec', F_TYPE_PROCEDURE_STRING, @Exec);

  AddScriptFunction(Enviroment, 'WriteLnToFile', F_TYPE_PROCEDURE_STRING_STRING, @WriteLnToFile);
  AddScriptFunction(Enviroment, 'WriteToFile', F_TYPE_PROCEDURE_STRING_STRING, @WriteToFile);
  AddScriptFunction(Enviroment, 'CreateFile', F_TYPE_PROCEDURE_STRING, @CreateFile);
  AddScriptFunction(Enviroment, 'GetSaveFileName', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @GetSaveFileName);
  AddScriptFunction(Enviroment, 'GetOpenFileName', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @GetOpenFileName);

  AddScriptFunction(Enviroment, 'GetSaveImageFileName', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @GetSaveImageFileName);
  AddScriptFunction(Enviroment, 'GetOpenImageFileName', F_TYPE_FUNCTION_STRING_STRING_IS_STRING, @GetOpenImageFileName);
{$ENDIF EXT}
end;

{ TScriptsManager }

function TScriptsManager.AddScript(Script: TScript) : string;
var
  Index: Integer;
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
  FIncludes  := TList.Create;
end;

destructor TScriptsManager.Destroy;
var
  I: Integer;
begin
  for I := 0 to FScripts.Count - 1 do
    if GOM.IsObj(FScripts[i]) then
      TScript(FScripts[i]).Free;

  FScripts.Free;
  FreeList(FIncludes);
  inherited;
end;

function TScriptsManager.GetIncludeScript(FileName: string): TIncludeScript;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FIncludes.Count - 1 do
  begin
    if TIncludeScript(FIncludes[I]).FilePath = FileName then
    begin
      Result := FIncludes[I];
      Exit;
    end;
  end;
end;

function TScriptsManager.GetScriptByID(ID: string): TScript;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FScripts.Count - 1 do
    if TScript(FScripts[I]).ID = ID then
    begin
      Result := FScripts[I];
      Exit;
    end;
end;

procedure TScriptsManager.RegisterIncludeScript(FileName,
  ScriptContent: string);
var
  IncludeScript: TIncludeScript;
begin
  if GetIncludeScript(FileName) <> nil then
    Exit;

  IncludeScript := TIncludeScript.Create;
  IncludeScript.FilePath := FileName;
  IncludeScript.ScriptContent := ScriptContent;
  FIncludes.Add(IncludeScript);
end;

procedure TScriptsManager.RemoveScript(ID : string);
var
  I: Integer;
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
  I: Integer;
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
