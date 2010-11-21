unit uTranslate;

interface

uses
  Classes, SysUtils, uLogger, uMemory, MSXML, OmniXML_MSXML, uConstants,
  SyncObjs;

type
  TTranslate = class(TObject)
  private
    FOriginal : string;
    FTranslate : string;
  public
    constructor Create(Node : IXMLDOMNode);
    property Original : string read FOriginal write FOriginal;
    property Translate : string read FTranslate write FTranslate;
  end;

  TLanguageScope = class(TObject)
  private
    FScope: string;
    FTranslateList: TList;
    FParces: Boolean;
    FScopeNode: IXMLDOMNode;
    function GetTranslate(Index: Integer): TTranslate;
  protected
    procedure LoadTranslateList(ScopeNode : IXMLDOMNode);
  public
    constructor Create(ScopeNode : IXMLDOMNode);
    destructor Destroy; override;
    function Translate(Original: string; out ATranslate : string): Boolean;
    property Scope : string read FScope write FScope;
    property Items[Index : Integer] : TTranslate read GetTranslate; default;
  end;

type
  TLanguage = class(TObject)
  private
    FTranslate : IXMLDOMDocument;
    FTranslateList : TList;
    FName : string;
    FImageName : string;
  public
    constructor Create(FileName : string);
    constructor CreateFromXML(XML : string);
    procedure Init;
    destructor Destroy; override;
    procedure LoadTranslationList;
    function LocateString(const Original, Scope: string): string;
    property Name : string read FName;
    property ImageName : string read FImageName;
  end;

  TTranslateManager = class(TObject)
  private
    FSync: TCriticalSection;
    FLanguage : TLanguage;
    FLanguageCode : string;
    constructor Create;
    function GetLanguage: string;
    procedure SetLanguage(const Value: string);
  protected
    function LocateString(const Original, Scope : string) : string;
  public
    destructor Destroy; override;
    class function Instance : TTranslateManager;
    procedure BeginTranslate;
    procedure EndTranslate;
    function TA(const StringToTranslate, Scope: string) : string; overload;
    function TA(const StringToTranslate: string) : string; overload;
    function Translate(const StringToTranslate: string) : string; overload;
    function Translate(const StringToTranslate, Scope: string) : string; overload;
    property Language : string read GetLanguage write SetLanguage;
  end;

  TLanguageInitCallBack = procedure(var Language : TLanguage; LanguageCode : string);

function TA(const StringToTranslate, Scope: string) : string; overload;
function TA(const StringToTranslate: string) : string; overload;
procedure LoadLanguageFromFile(var Language : TLanguage; LanguageCode : string);

var
  LanguageInitCallBack : TLanguageInitCallBack = LoadLanguageFromFile;

implementation

procedure LoadLanguageFromFile(var Language : TLanguage; LanguageCode : string);
var
  LanguagePath : string;
begin
  if LanguageCode = '--' then
    LanguageCode := 'RU';

  LanguagePath := ExtractFileDir(ParamStr(0)) + Format('Languages\%s%s.xml', [LanguageFileMask, LanguageCode]);
  try
    Language := TLanguage.Create(LanguagePath);
  except
    on e : Exception do
      EventLog(e.Message);
  end;
end;

var
  TranslateManager : TTranslateManager = nil;

function TA(const StringToTranslate, Scope: string) : string; overload;
begin
  Result := TTranslateManager.Instance.TA(StringToTranslate, Scope);
end;

function TA(const StringToTranslate: string) : string; overload;
begin
  Result := TTranslateManager.Instance.TA(StringToTranslate);
end;

{ TTranslateManager }

procedure TTranslateManager.BeginTranslate;
begin
  FSync.Enter;
end;

constructor TTranslateManager.Create;
begin
  FLanguageCode := '--';
  FSync:= TCriticalSection.Create;
  FSync.Enter;
  try
    FLanguage := nil;
    LanguageInitCallBack(FLanguage, Language);
  finally
    FSync.Leave;
  end;
end;

destructor TTranslateManager.Destroy;
begin
  F(FSync);
  F(FLanguage);
  inherited;
end;

procedure TTranslateManager.EndTranslate;
begin
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
  LanguageInitCallBack(FLanguage, Language);
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

constructor TLanguageScope.Create(ScopeNode : IXMLDOMNode);
var
  NameAttr : IXMLDOMNode;
begin
  FScopeNode := ScopeNode;
  FTranslateList := TList.Create;
  NameAttr := ScopeNode.attributes.getNamedItem('name');
  if NameAttr <> nil then
    FScope := NameAttr.text;
  FParces := False;
end;

destructor TLanguageScope.Destroy;
begin
  FreeList(FTranslateList);
  F(FTranslateList);
  inherited;
end;

function TLanguageScope.GetTranslate(Index: Integer): TTranslate;
begin
  if not FParces then
    LoadTranslateList(FScopeNode);
  Result := FTranslateList[Index];
end;

function TLanguageScope.Translate(Original: string; out ATranslate : string): Boolean;
var
  I : Integer;
  Translate : TTranslate;
begin
  Result := False;
  ATranslate := Original;

  if not FParces then
    LoadTranslateList(FScopeNode);

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

procedure TLanguageScope.LoadTranslateList(ScopeNode: IXMLDOMNode);
var
  I : Integer;
  TranslateList : IXMLDOMNodeList;
  TranslateNode : IXMLDOMNode;
  Translate : TTranslate;
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

constructor TTranslate.Create(Node: IXMLDOMNode);
var
  NameAttr : IXMLDOMNode;
  ValueAttr : IXMLDOMNode;
begin
  NameAttr := Node.attributes.getNamedItem('name');
  if NameAttr <> nil then
    FOriginal := NameAttr.text;

  ValueAttr := Node.attributes.getNamedItem('value');
  if ValueAttr <> nil then
    FTranslate := ValueAttr.text;
end;

{ TLanguage }

constructor TLanguage.Create(FileName: string);
begin
  Init;
  FTranslate.load(FileName);
  LoadTranslationList;
end;

constructor TLanguage.CreateFromXML(XML: string);
begin
  Init;
  FTranslate.loadXML(XML);
  LoadTranslationList;
end;

destructor TLanguage.Destroy;
begin
  FreeList(FTranslateList);
  inherited;
end;

procedure TLanguage.Init;
begin
  FTranslateList := TList.Create;
  FTranslate := CreateXMLDoc;
end;

procedure TLanguage.LoadTranslationList;
var
  DocumentElement : IXMLDOMElement;
  ScopeList : IXMLDOMNodeList;
  ScopeNode : IXMLDOMNode;
  NameAttr,
  ImageNameAttr : IXMLDOMNode;
  I : Integer;
  Scope : TLanguageScope;
begin
  FTranslateList.Clear;
  DocumentElement := FTranslate.documentElement;
  if DocumentElement <> nil then
  begin
    NameAttr := DocumentElement.attributes.getNamedItem('name');
    if NameAttr <> nil then
      FName := NameAttr.text;

    ImageNameAttr := DocumentElement.attributes.getNamedItem('image');
    if ImageNameAttr <> nil then
      FImageName := ImageNameAttr.text;

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

function TLanguage.LocateString(const Original, Scope: string): string;
var
  I : Integer;
  FScope : TLanguageScope;
begin
  Result := Original;
  for I := 0 to FTranslateList.Count - 1 do
  begin
    FScope := TLanguageScope(FTranslateList[I]);
    if FScope.Scope = Scope then
    begin
      if FScope.Translate(Original, Result) then
        Break
      else
        if Scope <> '' then
          Result := LocateString(Original, '');

    end;
  end;
end;

initialization

finalization
  F(TranslateManager);

end.
