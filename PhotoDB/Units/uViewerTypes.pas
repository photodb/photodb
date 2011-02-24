unit uViewerTypes;

interface

uses
  uThreadForm, uImageSource, UnitDBDeclare;

type
  TViewerForm = class(TThreadForm, IImageSource)
  private
    FFullScreenNow: Boolean;
    FSlideShowNow: Boolean;
  public
    CurrentFileNumber: Integer;
    property FullScreenNow: Boolean read FFullScreenNow write FFullScreenNow;
    property SlideShowNow: Boolean read FSlideShowNow write FSlideShowNow;
    function GetItem: TDBPopupMenuInfoRecord; virtual;
  end;

implementation

{ TViewerForm }

function TViewerForm.GetItem: TDBPopupMenuInfoRecord;
begin
  Result := nil;
end;

end.
