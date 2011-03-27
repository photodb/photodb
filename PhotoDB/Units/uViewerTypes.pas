unit uViewerTypes;

interface

uses
  uThreadForm, uImageSource, UnitDBDeclare;

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

implementation

{ TViewerForm }

function TViewerForm.GetItem: TDBPopupMenuInfoRecord;
begin
  Result := nil;
end;

end.
