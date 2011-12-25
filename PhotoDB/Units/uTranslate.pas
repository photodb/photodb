unit uTranslate;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, Classes, SysUtils, uLogger, uMemory, xmldom, uConstants,
  SyncObjs, Registry, uRuntime, uTime;

type
  TTranslate = class(TObject)
  private
    FOriginal: string;
    FTranslate: string;
  public
    constructor Create(Node: IDOMNode);
    property Original: string read FOriginal write FOriginal;
    property Translate: string read FTranslate write FTranslate;
  end;

  TLanguageScope = class(TObject)
  private
    FScope: string;
    FTranslateList: TList;
    FParced: Boolean;
    FScopeNode: IDOMNode;
    function GetTranslate(index: Integer): TTranslate;
  protected
    procedure LoadTranslateList(ScopeNode: IDOMNode);
  public
    constructor Create(ScopeNode: IDOMNode);
    destructor Destroy; override;
    function Translate(Original: string; out ATranslate: string): Boolean;
    property Scope: string read FScope write FScope;
    property Items[index: Integer]: TTranslate read GetTranslate; default;
  end;

type
  TLanguage = class(TObject)
  private
    FTranslate: IDOMDocument;
    FTranslateList: TList;
    FName: string;
    FImageName: string;
    FAutor: string;
    FCode: string;
    FLangCode: Integer;
    FLastScope: TLanguageScope;
  public
    constructor Create(FileName: string);
    constructor CreateFromXML(XML: string);
    procedure Init;
    destructor Destroy; override;
    procedure LoadTranslationList;
    function LocateString(Original, Scope: string): string;
    property name: string read FName;
    property ImageName: string read FImageName;
    property Autor: string read FAutor;
    property Code: string read FCode;
    property LangCode: Integer read FLangCode;
  end;

  TTranslateManager = class(TObject)
  private
    FSync: TCriticalSection;
    FLanguage: TLanguage;
    FLanguageCode: string;
    FIsTranslating: Boolean;
    constructor Create;
    function GetLanguage: string;
    procedure SetLanguage(const Value: string);
  protected
    function LocateString(const Original, Scope: string): string;
  public
    destructor Destroy; override;
    class function Instance: TTranslateManager;
    procedure BeginTranslate;
    procedure EndTranslate;
    function TA(const StringToTranslate, Scope: string): string; overload;
    function TA(const StringToTranslate: string): string; overload;
    function Translate(const StringToTranslate: string): string; overload;
    function Translate(const StringToTranslate, Scope: string): string; overload;
    function SmartTranslate(const StringToTranslate, Scope: string): string;
    property Language: string read GetLanguage write SetLanguage;
    property IsTranslating: Boolean read FIsTranslating write FIsTranslating;
  end;

  TLanguageInitCallBack = procedure(var Language: TLanguage; var LanguageCode: string);

function TA(const StringToTranslate, Scope: string): string; overload;
function TA(const StringToTranslate: string): string; overload;
procedure LoadLanguageFromFile(var Language: TLanguage; var LanguageCode: string);
function ResolveLanguageString(S: string): string;

var
  LanguageInitCallBack: TLanguageInitCallBack = LoadLanguageFromFile;

procedure UnloadTranslateModule;

implementation

var
  TranslateManager: TTranslateManager = nil;

procedure UnloadTranslateModule;
begin
  F(TranslateManager);
end;

function ResolveLanguageString(S: string): string;
begin
  Result := StringReplace(S, '{LNG}', AnsiLowerCase(TTranslateManager.Instance.Language), [RfReplaceAll, RfIgnoreCase]);
end;

procedure LoadLanguageFromFile(var Language: TLanguage; var LanguageCode: string);
var
  LanguagePath: string;
  Reg: TRegistry;
begin
  TW.I.Start('LoadLanguageFromFile - START');
  if LanguageCode = '--' then
  begin
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := Windows.HKEY_LOCAL_MACHINE;
      Reg.OpenKey(RegRoot, False);
      LanguageCode := Reg.ReadString('Language');
    finally
      F(Reg);
    end;
  end;

  LanguagePath := ExtractFilePath(ParamStr(0)) + Format('Languages\%s%s.xml', [LanguageFileMask, LanguageCode]);
  try
    TW.I.Start(' TLanguage.Create - START');
    Language := TLanguage.Create(LanguagePath);
    TW.I.Start(' TLanguage.Create - END');
  except
    on e : Exception do
      EventLog(e.Message);
  end;
end;

function TA(const StringToTranslate, Scope: string): string; overload;
begin
  Result := TTranslateManager.Instance.TA(StringToTranslate, Scope);
end;

function TA(const StringToTranslate: string): string; overload;
begin
  Result := TTranslateManager.Instance.TA(StringToTranslate);
end;

{ TTranslateManager }

procedure TTranslateManager.BeginTranslate;
begin
  FSync.Enter;
  FIsTranslating := True;
end;

constructor TTranslateManager.Create;
begin
  TW.I.Start('TTranslateManager.Create - START');
  FIsTranslating := True;
  FLanguageCode := '--';
  FSync := TCriticalSection.Create;
  FSync.Enter;
  try
    FLanguage := nil;
    TW.I.Start('TTranslateManager.Create - LOAD');
    LanguageInitCallBack(FLanguage, FLanguageCode);
  finally
    FSync.Leave;
  end;
  TW.I.Start('TTranslateManager.Create - END');
end;

destructor TTranslateManager.Destroy;
begin
  FSync.Enter;
  try
    F(FLanguage);
    TranslateManager := nil;
  finally
    FSync.Leave;
  end;
  F(FSync);
  inherited;
end;

procedure TTranslateManager.EndTranslate;
begin
  FIsTranslating := False;
  FSync.Leave;
end;

function TTranslateManager.GetLanguage: string;
begin
  Result := FLanguageCode;
end;

class function TTranslateManager.Instance: TTranslateManager;
begin
  if TranslateManager = nil then
    TranslateManager := TTranslateManager.Create;

  Result := TranslateManager;
end;

function TTranslateManager.LocateString(const Original, Scope: string): string;
begin
  Result := FLanguage.LocateString(Original, Scope);
end;

procedure TTranslateManager.SetLanguage(const Value: string);
begin
  FLanguageCode := Value;
  F(FLanguage);
  LanguageInitCallBack(FLanguage, FLanguageCode);
end;

function TTranslateManager.SmartTranslate(const StringToTranslate,
  Scope: string): string;
begin
  if FIsTranslating then
    Result := Translate(StringToTranslate, Scope)
  else
    Result := TA(StringToTranslate, Scope);
end;

function TTranslateManager.TA(const StringToTranslate, Scope: string): string;
begin
  BeginTranslate;
  try
    Result := Translate(StringToTranslate, Scope);
  finally
    EndTranslate;
  end;
end;

function TTranslateManager.TA(const StringToTranslate: string): string;
begin
  BeginTranslate;
  try
    Result := Translate(StringToTranslate);
  finally
    EndTranslate;
  end;
end;

function TTranslateManager.Translate(const StringToTranslate, Scope: string): string;
begin
  Result := LocateString(StringToTranslate, Scope);
end;

function TTranslateManager.Translate(const StringToTranslate: string): string;
begin
  Result := LocateString(StringToTranslate, '');
end;

{ TLanguageScope }

constructor TLanguageScope.Create(ScopeNode: IDOMNode);
var
  NameAttr : IDOMNode;
begin
  FScopeNode := ScopeNode;
  FTranslateList := TList.Create;
  NameAttr := ScopeNode.attributes.getNamedItem('name');
  if NameAttr <> nil then
    FScope := NameAttr.nodeValue;
  FParced := False;
end;

destructor TLanguageScope.Destroy;
begin
  FreeList(FTranslateList);
  inherited;
end;

function TLanguageScope.GetTranslate(Index: Integer): TTranslate;
begin
  if not FParced then
  begin
    FParced := True;
    LoadTranslateList(FScopeNode);
  end;

  Result := FTranslateList[Index];
end;

function TLanguageScope.Translate(Original: string; out ATranslate : string): Boolean;
var
  I: Integer;
  Translate: TTranslate;
begin
  Result := False;
  ATranslate := Original;

  if not FParced then
  begin
    FParced := True;
    LoadTranslateList(FScopeNode);
  end;

  for I := 0 to FTranslateList.Count - 1 do
  begin
    Translate := FTranslateList[I];
    if Translate.FOriginal = Original then
    begin
      ATranslate := Translate.FTranslate;
      Result := True;
      Exit;
    end;
  end;
end;

procedure TLanguageScope.LoadTranslateList(ScopeNode: IDOMNode);
var
  I: Integer;
  TranslateList: IDOMNodeList;
  TranslateNode: IDOMNode;
  Translate: TTranslate;
begin
  TranslateList := ScopeNode.childNodes;
  if TranslateList <> nil then
  begin
    for I := 0 to TranslateList.length - 1 do
    begin
      TranslateNode := TranslateList.item[I];
      Translate := TTranslate.Create(TranslateNode);
      FTranslateList.Add(Translate);
    end;
  end;
end;

{ TTranslate }

constructor TTranslate.Create(Node: IDOMNode);
var
  NameAttr : IDOMNode;
  ValueAttr : IDOMNode;
begin
  NameAttr := Node.attributes.getNamedItem('name');
  if NameAttr <> nil then
    FOriginal := StringReplace(NameAttr.nodeValue, '$nl$', #13, [rfReplaceAll]);

  ValueAttr := Node.attributes.getNamedItem('value');
  if ValueAttr <> nil then
    FTranslate := StringReplace(ValueAttr.nodeValue, '$nl$', #13, [rfReplaceAll]);
end;

{ TLanguage }

constructor TLanguage.Create(FileName: string);
begin
  Init;
  (FTranslate as IDOMPersist).load(FileName);
  LoadTranslationList;
end;

constructor TLanguage.CreateFromXML(XML: string);
begin
  Init;
  (FTranslate as IDOMPersist).loadxml(XML);
  LoadTranslationList;
end;

destructor TLanguage.Destroy;
begin
  FTranslate := nil;
  FreeList(FTranslateList);
  inherited;
end;

procedure TLanguage.Init;
begin
  FLastScope := nil;
  FTranslateList := TList.Create;
  FTranslate := GetDOM.createDocument('', '', nil);
  FLangCode := 0;
  FCode := '--';
  FAutor := '';
end;

procedure TLanguage.LoadTranslationList;
var
  DocumentElement: IDOMElement;
  ScopeList: IDOMNodeList;
  ScopeNode: IDOMNode;
  AutorNameAttr,
  NameAttr,
  CodeAttr,
  LangCodeAttr,
  ImageNameAttr: IDOMNode;
  I: Integer;
  Scope: TLanguageScope;
begin
  FTranslateList.Clear;
  DocumentElement := FTranslate.documentElement;
  if DocumentElement <> nil then
  begin
    NameAttr := DocumentElement.attributes.getNamedItem('name');
    if NameAttr <> nil then
      FName := NameAttr.nodeValue;

    ImageNameAttr := DocumentElement.attributes.getNamedItem('image');
    if ImageNameAttr <> nil then
      FImageName := ImageNameAttr.nodeValue;

    AutorNameAttr := DocumentElement.attributes.getNamedItem('autor');
    if AutorNameAttr <> nil then
      FAutor := AutorNameAttr.nodeValue;

    CodeAttr := DocumentElement.attributes.getNamedItem('code');
    if CodeAttr <> nil then
      FCode := CodeAttr.nodeValue;

    LangCodeAttr := DocumentElement.attributes.getNamedItem('langCode');
    if LangCodeAttr <> nil then
      FLangCode := StrToIntDef(LangCodeAttr.nodeValue, 0);

    ScopeList := DocumentElement.childNodes;
    if ScopeList <> nil then
    begin
      for I := 0 to ScopeList.length - 1 do
      begin
        ScopeNode := ScopeList.item[I];
        Scope := TLanguageScope.Create(ScopeNode);
        FTranslateList.Add(Scope);
      end;
    end;
  end;
end;

function TLanguage.LocateString(Original, Scope: string): string;
var
  I: Integer;
  FScope: TLanguageScope;

begin
  Original := StringReplace(Original, '$nl$', #13, [rfReplaceAll]);
  Result := Original;

  //if some form uses a lot of translations - try to cache form scope
  if (Scope <> '') and (FLastScope <> nil) and (FLastScope.Scope = Scope) then
  begin
    if FLastScope.Translate(Original, Result) then
      Exit;
  end;

  for I := 0 to FTranslateList.Count - 1 do
  begin
    FScope := TLanguageScope(FTranslateList[I]);
    if FScope.Scope = Scope then
    begin

      if FScope.Translate(Original, Result) then
      begin
        FLastScope := FScope;
        Break
      end else
        if Scope <> '' then
          Result := LocateString(Original, '');

    end;
  end;
end;

initialization

finalization
  UnloadTranslateModule;

end.
