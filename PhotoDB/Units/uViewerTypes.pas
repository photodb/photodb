unit uViewerTypes;

interface

uses
  uThreadForm,
  uImageSource,
  UnitDBDeclare,
  uDBPopupMenuInfo;

type
  TViewerForm = class(TThreadForm)
  private
    FFullScreenNow: Boolean;
    FSlideShowNow: Boolean;
  protected
    function GetItem: TDBPopupMenuInfoRecord; virtual;
  public
    CurrentFileNumber: Integer;
    property FullScreenNow: Boolean read FFullScreenNow write FFullScreenNow;
    property SlideShowNow: Boolean read FSlideShowNow write FSlideShowNow;
  end;

  TViewerManager = class(TObject)
  public
    procedure DisplayFile(FileName: string);
    procedure DisplayInfo(Info: TDBPopupMenuInfo);
  end;

function ViewerManager: TViewerManager;

implementation

var
  FViewerManager: TViewerManager = nil;

function ViewerManager: TViewerManager;
begin
  if FViewerManager = nil then
    FViewerManager := TViewerManager.Create;

  Result := FViewerManager;
end;

{ TViewerForm }

function TViewerForm.GetItem: TDBPopupMenuInfoRecord;
begin
  Result := nil;
end;

{ TViewerManager }

procedure TViewerManager.DisplayFile(FileName: string);
begin
  //
end;

procedure TViewerManager.DisplayInfo(Info: TDBPopupMenuInfo);
begin
  //
end;

end.
