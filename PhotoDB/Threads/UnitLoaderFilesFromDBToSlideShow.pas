unit UnitLoaderFilesFromDBToSlideShow;

interface

uses
  Classes;

type
  TLoaderFilesFromDBToSlideShow = class(TThread)
  private
  FCID : string;
    { Private declarations }
  protected
    procedure Execute; override;
  public
  constructor Create(CreateSuspennded: Boolean; CID : String);

  end;

implementation

{ TLoaderFilesFromDBToSlideShow }

constructor TLoaderFilesFromDBToSlideShow.Create(CreateSuspennded: Boolean;
  CID: String);
begin
 FCID:=CID;
 inherited Create(CreateSuspennded);
end;

procedure TLoaderFilesFromDBToSlideShow.Execute;
begin
  { Place thread code here }
  
end;

end.
