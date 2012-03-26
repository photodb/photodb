unit uShareImagesThread;

interface

uses
  uMemory,
  Windows,
  uThreadEx,
  uThreadForm,
  Graphics,
  uDBPopupMenuInfo;

type
  TShareImagesThread = class(TThreadEx)
  private
    FData: TDBPopupMenuInfo;
    FIsPreview: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwnerForm: TThreadForm; FileList: TDBPopupMenuInfo; IsPreview: Boolean);
    destructor Destroy; override;
  end;

implementation

uses
  uFormSharePhotos;

{ TShareImagesThread }

constructor TShareImagesThread.Create(AOwnerForm: TThreadForm;
  FileList: TDBPopupMenuInfo; IsPreview: Boolean);
begin
  inherited Create(AOwnerForm, AOwnerForm.StateID);
  FData := TDBPopupMenuInfo.Create;
  FData.Assign(FileList);
  FIsPreview := IsPreview;
end;

destructor TShareImagesThread.Destroy;
begin
  F(FData);
  inherited;
end;

procedure TShareImagesThread.Execute;
var
  I: Integer;
begin
  FreeOnTerminate := True;

end;

end.
