unit uViewerTypes;

interface

uses
  uThreadForm, uImageSource;

type
  TViewerForm = class(TThreadForm, IImageSource)
  private
    FFullScreenNow: Boolean;
    FSlideShowNow: Boolean;
  public
    property FullScreenNow: Boolean read FFullScreenNow write FFullScreenNow;
    property SlideShowNow: Boolean read FSlideShowNow write FSlideShowNow;
  end;

implementation

end.
