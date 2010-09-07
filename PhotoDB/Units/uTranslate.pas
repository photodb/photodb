unit uTranslate;

interface

uses
  Classes, SysUtils, uLogger, uMemory, MSXML, OmniXML_MSXML;

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
    function Translate(Original : string) : string;
    property Scope : string read FScope write FScope;
    property Items[Index : Integer] : TTranslate read GetTranslate; default;
  end;

type
  TTranslateManager = class(TObject)
  private
    FTranslate : IXMLDOMDocument;
    FTranslateList : TList;
    constructor Create;
    function GetLanguage: string;
  protected
    procedure LoadTranslationList;
    function LocateString(Original, Scope : string) : string;
  public
    destructor Destroy; override;
    class function Instance : TTranslateManager;
    function Translate(StringToTranslate: string) : string; overload;
    function Translate(StringToTranslate, Scope: string) : string; overload;
    property Language : string read GetLanguage;
  end;

implementation

var
  TranslateManager : TTranslateManager = nil;

{ TTranslateManager }

constructor TTranslateManager.Create;
var
  LanguagePath : string;
begin
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
  inherited;
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

function TTranslateManager.LocateString(Original, Scope: string): string;
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
      Result := FScope.Translate(Original);
      Break;
    end;
  end;
end;

function TTranslateManager.Translate(StringToTranslate, Scope: string): string;
begin
  Result := LocateString(StringToTranslate, Scope);
end;

function TTranslateManager.Translate(StringToTranslate: string): string;
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

function TLanguageScope.Translate(Original: string): string;
var
  I : Integer;
  Translate : TTranslate;
begin
  for I := 0 to FTranslateList.Count - 1 do
  begin
    Translate := FTranslateList[I];
    if Translate.FOriginal = Original then
    begin
      Result := Translate.FTranslate;
      Break;
    end;
  end;
end;

{ TTranslate }

constructor TTranslate.Create(Node: IXMLDOMNode);
begin
  FOriginal := Node.attributes.getNamedItem('name').text;
  FTranslate := Node.attributes.getNamedItem('value').text;
end;

end.
