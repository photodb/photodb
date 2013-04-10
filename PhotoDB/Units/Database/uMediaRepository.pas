unit uMediaRepository;

interface

uses
  System.SysUtils,

  CommonDBSupport,

  uConstants,
  uMemory,
  uDBClasses,
  uDBContext;

type
  TMediaRepository = class(TInterfacedObject, IMediaRepository)
  private
    FContext: IDBContext;
  public
    constructor Create(Context: IDBContext);
    destructor Destroy; override;
    function GetIdByFileName(FileName: string): Integer;
    function GetFileNameById(ID: Integer): string;
    procedure SetFileNameById(ID: Integer; FileName: string);
    procedure SetAccess(ID, Access: Integer);
    procedure SetRotate(ID, Rotate: Integer);
    procedure SetRating(ID, Rating: Integer);
    procedure SetAttribute(ID, Attribute: Integer);
    function GetCount: Integer;
  end;

implementation

{ TMediaRepository }

constructor TMediaRepository.Create(Context: IDBContext);
begin
  FContext := Context;
end;

destructor TMediaRepository.Destroy;
begin
  FContext := nil;
  inherited;
end;

function TMediaRepository.GetCount: Integer;
var
  SC: TSelectCommand;
begin
  Result := 0;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TCustomFieldParameter.Create('COUNT(*) AS ITEMS_COUNT'));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('ITEMS_COUNT').AsInteger;
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetFileNameById(ID: Integer): string;
var
  SC: TSelectCommand;
begin
  Result := '';

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TStringParameter.Create('FFileName'));
    SC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('FFileName').AsString;
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetIdByFileName(FileName: string): Integer;
var
  SC: TSelectCommand;
begin
  Result := 0;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TIntegerParameter.Create('ID'));

    SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', Integer(GetPathCRC(FileName, True))));
    SC.AddWhereParameter(TStringParameter.Create('Name', AnsiLowerCase(ExtractFileName(FileName)), paLike));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('ID').AsInteger;
  finally
    F(SC);
  end;
end;

procedure TMediaRepository.SetAccess(ID, Access: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Access', Access));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetAttribute(ID, Attribute: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Attr', Attribute));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetFileNameById(ID: Integer; FileName: string);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(FileName, True)));
    UC.AddParameter(TStringParameter.Create('FFileName', AnsiLowerCase(FileName)));
    UC.AddParameter(TStringParameter.Create('Name', ExtractFileName(FileName)));

    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetRating(ID, Rating: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Rating', Rating));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetRotate(ID, Rotate: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Rotated', Rotate));
    UC.Execute;
  finally
    F(UC);
  end;
end;

end.
