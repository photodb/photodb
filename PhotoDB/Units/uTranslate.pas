unit uTranslate;

interface

uses
  Classes, SysUtils, uLogger, uMemory, MSXML, OmniXML_MSXML,
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
    FScope : string; 
    FTranslateList : TList;
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
  TTranslateManager = class(TObject)
  private
    FTranslate : IXMLDOMDocument;
    FTranslateList : TList;
    FSync: TCriticalSection;
    constructor Create;
    function GetLanguage: string;
  protected
    procedure LoadTranslationList;
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
    property Language : string read GetLanguage;
  end;

function TA(const StringToTranslate, Scope: string) : string; overload;
function TA(const StringToTranslate: string) : string; overload;

implementation

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
var
  LanguagePath : string;
begin
  FSync:= TCriticalSection.Create;
  LanguagePath := ExtractFileDir(ParamStr(0)) + Format('\Language%s.xml', [Language]);

  FTranslateList := TList.Create;
  FTranslate := CreateXMLDoc;
  try
    FTranslate.load(LanguagePath);
    LoadTranslationList;
  except
    on e : Exception do
      EventLog(e.Message);
  end;
end;

destructor TTranslateManager.Destroy;
begin
  FreeList(FTranslateList);
  F(FSync);
  inherited;
end;

procedure TTranslateManager.EndTranslate;
begin
  FSync.Leave;
end;

function TTranslateManager.GetLanguage: string;
begin
  Result := 'RU';
end;

class function TTranslateManager.Instance: TTranslateManager;
begin
  if TranslateManager = nil then
    TranslateManager := TTranslateManager.Create;

  Result := TranslateManager;
end;

procedure TTranslateManager.LoadTranslationList;
var
  DocumentElement : IXMLDOMElement;
  ScopeList : IXMLDOMNodeList;
  ScopeNode : IXMLDOMNode;
  I : Integer;
  Scope : TLanguageScope;
begin
  FTranslateList.Clear;
  DocumentElement := FTranslate.documentElement;
  if DocumentElement <> nil then
  begin
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

function TTranslateManager.LocateString(const Original, Scope: string): string;
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
begin
  FTranslateList := TList.Create;   
  FScope := ScopeNode.attributes.getNamedItem('name').text;
  LoadTranslateList(ScopeNode);
end;

destructor TLanguageScope.Destroy;
begin
  FreeList(FTranslateList);
  F(FTranslateList);
  inherited;
end;

function TLanguageScope.GetTranslate(Index: Integer): TTranslate;
begin
  Result := FTranslateList[Index];
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

function TLanguageScope.Translate(Original: string; out ATranslate : string): Boolean;
var
  I : Integer;
  Translate : TTranslate;
begin
  Result := False;
  ATranslate := Original;
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

{ TTranslate }

constructor TTranslate.Create(Node: IXMLDOMNode);
begin
  FOriginal := Node.attributes.getNamedItem('name').text;
  FTranslate := Node.attributes.getNamedItem('value').text;
end;

initialization

finalization
  F(TranslateManager);


end.
