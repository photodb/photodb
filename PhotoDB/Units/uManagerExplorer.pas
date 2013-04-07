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
    FSync: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    function NewExplorer(GoToLastSavedPath: Boolean): TCustomExplorerForm;
    procedure AddExplorer(Explorer: TCustomExplorerForm);
    procedure RemoveExplorer(Explorer: TCustomExplorerForm);
    function IsExplorer(Explorer: TCustomExplorerForm): Boolean;
    property ShowPrivate: Boolean read FShowPrivate write FShowPrivate;
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
  FShowEXIF := AppSettings.ReadBool('Options', 'ShowEXIFMarker', False);

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

function TManagerExplorer.IsExplorer(Explorer: TCustomExplorerForm): Boolean;
begin
  FSync.Enter;
  try
    Result := FExplorers.IndexOf(Explorer) <> -1;
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

initialization

finalization
  F(FExplorerManager);

end.
