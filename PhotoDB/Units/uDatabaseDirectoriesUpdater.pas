unit uDatabaseDirectoriesUpdater;

interface

uses
  System.SyncObjs,

  uDBThread,
  uSettings;

type
  TDatabaseDirectoriesUpdater = class(TDBThread)
  protected
    procedure Execute; override;
  public
  end;

  TUserDirectoriesUpdater = class(TDBThread)
  protected
    procedure Execute; override;
  end;

  TUserDirectoriesWatcher = class(TDBThread)
  protected
    procedure Execute; override;
  end;

  TUpdaterQueue = class(TObject)

  end;

implementation


{ TDatabaseDirectoriesUpdater }

procedure TDatabaseDirectoriesUpdater.Execute;
begin
  inherited;

end;

{ TUserDirectoriesUpdater }

procedure TUserDirectoriesUpdater.Execute;
begin
  inherited;

end;

{ TUserDirectoriesWatcher }

procedure TUserDirectoriesWatcher.Execute;
begin
  inherited;

end;

end.

