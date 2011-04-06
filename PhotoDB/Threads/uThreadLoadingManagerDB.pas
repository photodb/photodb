unit uThreadLoadingManagerDB;

interface

uses
  Classes, DB, Forms, CommonDBSupport, ADODB, dolphin_db,
  UnitDBDeclare, uThreadEx, uThreadForm, uMemory;

type
  TThreadLoadingManagerDB = class(TThreadEx)
  private
    FOwner : TForm;
    FDataList : TList;
    { Private declarations }
  protected
    procedure FillDataPacket;
    procedure DoOnEnd;
    procedure Execute; override;
  public
    constructor Create(AOwner : TThreadForm);
  end;

implementation

uses ManagerDBUnit;

{ TThreadLoadingManagerDB }

constructor TThreadLoadingManagerDB.Create(AOwner : TThreadForm);
begin
  inherited Create(AOwner, AOwner.StateID);
  FOwner := AOwner;
end;

procedure TThreadLoadingManagerDB.DoOnEnd;
begin
  if not Terminated then
    (FOwner as TManagerDB).DBOpened(Self);
end;

procedure TThreadLoadingManagerDB.Execute;
var
  SqlText : string;
  ItemData : TDBPopupMenuInfoRecord;
  FQuery : TDataSet;
begin
  FDataList := TList.Create;
  try              
    FQuery := GetQuery(True);
    try
      ForwardOnlyQuery(FQuery);
      SqlText:='SELECT ID FROM $DB$ ORDER BY ID';
      SetSQL(FQuery, SqlText);
      FQuery.Open;

      FQuery.First;
      while not FQuery.Eof do
      begin
        if Terminated then
          Break;
        ItemData := TDBPopupMenuInfoRecord.Create;
        ItemData.ID := FQuery.Fields[0].AsInteger;
        ItemData.InfoLoaded := False;
        FDataList.Add(ItemData);

        if FDataList.Count = 500 then
        begin
          SynchronizeEx(FillDataPacket);
          FDataList.Clear;
        end;

        FQuery.Next;
      end;
            
      Synchronize(FillDataPacket);  
      FDataList.Clear;
    finally
      FreeDS(FQuery);
    end;
  finally
    F(FDataList);
    Synchronize(DoOnEnd);
  end;
end;

procedure TThreadLoadingManagerDB.FillDataPacket;
begin
  if not Terminated then
    (FOwner as TManagerDB).DBLoadDataPacket(FDataList);
end;

end.
