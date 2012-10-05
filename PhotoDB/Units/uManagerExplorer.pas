unit uManagerExplorer;

interface

uses
  Generics.Collections,
  System.Classes,
  System.SysUtils,
  System.SyncObjs,
  Vcl.Forms,
  uSettings,
  uMemory,
  ExplorerTypes;

type
  TManagerExplorer = class(TObject)
  private
    FExplorers: TList<TCustomExplorerForm>;
    FForms: TList<TForm>;
    FShowPrivate: Boolean;
    FShowEXIF: Boolean;
    FShowQuickLinks: Boolean;
    FSync: TCriticalSection;
    procedure SetShowQuickLinks(const Value: Boolean);
    function GetExplorerByIndex(Index: Integer): TCustomExplorerForm;
  public
    constructor Create;
    destructor Destroy; override;
    function NewExplorer(GoToLastSavedPath: Boolean): TCustomExplorerForm;
    procedure FreeExplorer(Explorer: TCustomExplorerForm);
    procedure AddExplorer(Explorer: TCustomExplorerForm);
    procedure RemoveExplorer(Explorer: TCustomExplorerForm);
    function GetExplorersTexts: TStrings;
    function IsExplorer(Explorer: TCustomExplorerForm): Boolean;
    function ExplorersCount: Integer;
    function GetExplorerNumber(Explorer: TCustomExplorerForm): Integer;
    function GetExplorerBySID(SID: string): TCustomExplorerForm;
    property ShowPrivate: Boolean read FShowPrivate write FShowPrivate;
    function IsExplorerForm(Explorer: TForm): Boolean;
    property ShowQuickLinks: Boolean read FShowQuickLinks write SetShowQuickLinks;
    property Items[Index: Integer]: TCustomExplorerForm read GetExplorerByIndex; default;
  end;

function ExplorerManager: TManagerExplorer;

implementation

uses
  ExplorerUnit;

var
  FExplorerManager: TManagerExplorer = nil;

function ExplorerManager: TManagerExplorer;
begin
  if FExplorerManager = nil then
    FExplorerManager := TManagerExplorer.Create;
  Result := FExplorerManager;
end;

{ TManagerExplorer }

procedure TManagerExplorer.AddExplorer(Explorer: TCustomExplorerForm);
begin
  FShowEXIF := Settings.ReadBool('Options', 'ShowEXIFMarker', False);
  ShowQuickLinks := Settings.ReadBool('Options', 'ShowOtherPlaces', True);

  if FExplorers.IndexOf(Explorer) = -1 then
    FExplorers.Add(Explorer);

  if FForms.IndexOf(Explorer) = -1 then
    FForms.Add(Explorer);

end;

constructor TManagerExplorer.Create;
begin
  FSync := TCriticalSection.Create;
  FExplorers := TList<TCustomExplorerForm>.Create;
  FForms := TList<TForm>.Create;
  FShowPrivate := False;
end;

destructor TManagerExplorer.Destroy;
begin
  F(FExplorers);
  F(FForms);
  F(FSync);
  inherited;
end;

function TManagerExplorer.ExplorersCount: Integer;
begin
  FSync.Enter;
  try
    Result := FExplorers.Count;
  finally
    FSync.Leave;
  end;
end;

procedure TManagerExplorer.FreeExplorer(Explorer: TCustomExplorerForm);
begin
  Explorer.Close;
end;

function TManagerExplorer.GetExplorerBySID(SID: String): TCustomExplorerForm;
var
  I: Integer;
begin
  Result := nil;
  FSync.Enter;
  try
    for I := 0 to FExplorers.Count - 1 do
      if IsEqualGUID(FExplorers[I].StateID, StringToGUID(SID)) then
      begin
        Result := FExplorers[I];
        Break;
      end;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.GetExplorerNumber(Explorer: TCustomExplorerForm): Integer;
begin
  FSync.Enter;
  try
    Result := FExplorers.IndexOf(Explorer);
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.GetExplorersTexts: TStrings;
var
  I: Integer;
  B: Boolean;
  S: string;
begin
  Result := TStringList.Create;
  FSync.Enter;
  try
    for I := 0 to FExplorers.Count - 1 do
      Result.Add(FExplorers[I].Caption);

    repeat
      B := False;
      for I := 0 to Result.Count - 2 do
        if CompareStr(Result[I], Result[I + 1]) > 0 then
        begin
          S := Result[I];
          Result[I] := Result[I + 1];
          Result[I + 1] := S;
          B := True;
        end;
    until not B;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.IsExplorer(Explorer: TCustomExplorerForm): Boolean;
begin
  FSync.Enter;
  try
    Result := FExplorers.IndexOf(Explorer) <> -1;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.IsExplorerForm(Explorer: TForm): Boolean;
begin
  FSync.Enter;
  try
    Result := FForms.IndexOf(Explorer) <> -1;
  finally
    FSync.Leave;
  end;
end;

function TManagerExplorer.NewExplorer(GoToLastSavedPath: Boolean): TCustomExplorerForm;
begin
  Result := TExplorerForm.Create(Application, GoToLastSavedPath);
end;

procedure TManagerExplorer.RemoveExplorer(Explorer: TCustomExplorerForm);
begin
  FSync.Enter;
  try
    FExplorers.Remove(Explorer);
    FForms.Remove(Explorer);
  finally
    FSync.Leave;
  end;
end;

procedure TManagerExplorer.SetShowQuickLinks(const Value: Boolean);
begin
  FShowQuickLinks := Value;
end;

function TManagerExplorer.GetExplorerByIndex(index: Integer): TCustomExplorerForm;
begin
  Result := nil;
  FSync.Enter;
  try
    if (Index > -1) and (Index < FExplorers.Count) then
      Result := FExplorers[Index];
  finally
    FSync.Leave;
  end;
end;

initialization

finalization
  F(FExplorerManager);

end.
