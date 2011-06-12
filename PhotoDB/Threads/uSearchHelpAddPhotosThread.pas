unit uSearchHelpAddPhotosThread;

interface

uses
  Classes, uDBThread, uDBForm, DB, ActiveX, CommonDBSupport;

type
  TSearchHelpAddPhotosThreadCallBack = procedure(Sender: TObject; RecordsInDB: Integer) of object;

  TSearchHelpAddPhotosThread = class(TDBThread)
  private
    FCallBack: TSearchHelpAddPhotosThreadCallBack;
    FIntParam: Integer;
  protected
    procedure Execute; override;
    procedure DoCallBack;
  public
    constructor Create(OwnerForm: TDBForm; CallBack: TSearchHelpAddPhotosThreadCallBack);
  end;

implementation

{ TSearchHelpAddPhotosThread }

constructor TSearchHelpAddPhotosThread.Create(OwnerForm: TDBForm; CallBack: TSearchHelpAddPhotosThreadCallBack);
begin
  inherited Create(OwnerForm, False);
  FCallBack := CallBack;
end;

procedure TSearchHelpAddPhotosThread.DoCallBack;
begin
  FCallBack(Self, FIntParam);
end;

procedure TSearchHelpAddPhotosThread.Execute;
var
  DS: TDataSet;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    DS := GetQuery(True);
    try
      SetSQL(DS, 'Select count(*) as RecordsCount from $DB$');
      DS.Open;
      FIntParam := DS.FieldByName('RecordsCount').AsInteger;
      SynchronizeEx(DoCallBack);
    finally
      FreeDS(DS);
    end;
  finally
    CoUninitialize;
  end;
end;

end.
