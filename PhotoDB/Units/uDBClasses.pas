unit uDBClasses;

interface

uses
  DB, SysUtils, Classes, jpeg, uMemory, CommonDBSupport, uStringUtils, ADODB,
  Variants;

type
  TParameter = class
  private
    FName: string;
  protected
    function GetValue: Variant; virtual; abstract;
  public
    constructor Create(Name: string);
    property Value: Variant read GetValue;
    property Name: string read FName;
  end;

  TIntegerParameter = class(TParameter)
  private
    FValue: Integer;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Value: Integer);
  end;

  TDateTimeParameter = class(TParameter)
  private
    FValue: TDateTime;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Value: TDateTime);
  end;

  TStringParameter = class(TParameter)
  private
    FValue: string;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Value: string);
  end;

  TJpegParameter = class(TParameter)
  private
    FValue: TJpegImage;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Value: TJpegImage);
    property Image: TJpegImage read FValue;
  end;

  FParameterCollection = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItemByID(Index: Integer): TParameter;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Parameter: TParameter);
    function AsInsertFields: string;
    function AsInsertValues: string;
    function AsCondition: string;
    function AsUpdateFieldsAndValues: string;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TParameter read GetItemByID; default;
  end;

  TSqlCommand = class
  private
    FParameters: FParameterCollection;
    FWhereParameters: FParameterCollection;
    FQuery: TDataSet;
  protected
    function GetSQL: string; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdateParameters;
    procedure Execute; virtual; abstract;
    procedure AddParameter(Parameter: TParameter);
    procedure AddWhereParameter(Parameter: TParameter);
    property SQL: string read GetSQL;
    property Parameters: FParameterCollection read FParameters;
    property WhereParameters: FParameterCollection read FWhereParameters;
  end;

  TInsertCommand = class(TSqlCommand)
  private
    FTableName: string;
  protected
    function GetSQL: string; override;
  public
    procedure Execute; override;
    constructor Create(TableName: string);
  end;

  TDeleteCommand = class(TSqlCommand)
  private
    FTableName: string;
  protected
    function GetSQL: string; override;
  public
    procedure Execute; override;
    constructor Create(TableName: string);
  end;

  TUpdateCommand = class(TSqlCommand)
  private
    FTableName: string;
  protected
    function GetSQL: string; override;
  public
    procedure Execute; override;
    constructor Create(TableName: string);
  end;

  TDatabaseManager = class(TObject)
  private
    function GetDBFile: string;
  public
    property DBFile: string read GetDBFile;
  end;

function DatabaseManager: TDatabaseManager;

implementation

var
  FManager: TDatabaseManager = nil;

function DatabaseManager: TDatabaseManager;
begin
  if FManager = nil then
    FManager := TDatabaseManager.Create;

  Result := FManager;
end;

{ TInsertCommand }

constructor TInsertCommand.Create(TableName: string);
begin
  inherited Create;
  FTableName := TableName;
end;

procedure TInsertCommand.Execute;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  ExecSQL(FQuery);
end;

function TInsertCommand.GetSQL: string;
begin
  Result := Format('INSERT INTO [%s] (%s) values (%s)', [FTableName, Parameters.AsInsertFields, Parameters.AsInsertValues]);
end;

{ TSqlCommand }

procedure TSqlCommand.AddParameter(Parameter: TParameter);
begin
  FParameters.Add(Parameter);
end;

procedure TSqlCommand.AddWhereParameter(Parameter: TParameter);
begin
  FWhereParameters.Add(Parameter);
end;

constructor TSqlCommand.Create;
begin
  FParameters := FParameterCollection.Create;
  FWhereParameters := FParameterCollection.Create;
  FQuery := GetQuery;
end;

destructor TSqlCommand.Destroy;
begin
  F(FParameters);
  F(FWhereParameters);
  FreeDS(FQuery);
  inherited;
end;

procedure TSqlCommand.UpdateParameters;
var
  I: Integer;
  Parameter: TParameter;
  ADOParameter: ADODB.TParameter;
begin
  for I := 0 to FParameters.Count - 1 do
  begin
    Parameter := FParameters[I];
    ADOParameter := nil;
    if FQuery is TADOQuery then
      ADOParameter := TADOQuery(FQuery).Parameters.FindParam(Parameter.Name);
    if ADOParameter <> nil then
    begin
      if Parameter is TDateTimeParameter then
        ADOParameter.Value := TDateTimeParameter(Parameter).Value;
      if Parameter is TIntegerParameter then
        ADOParameter.Value := TIntegerParameter(Parameter).Value;
      if Parameter is TStringParameter then
        ADOParameter.Value := TStringParameter(Parameter).Value;
      if Parameter is TJpegParameter then
      begin
        TJpegParameter(Parameter).Image.Compress;
        ADOParameter.Assign(TJpegParameter(Parameter).Image);
      end;
    end;
  end;
end;

{ TParameter }

constructor TParameter.Create(Name: string);
begin
  FName := Name;
end;

{ TDeleteCommand }

constructor TDeleteCommand.Create(TableName: string);
begin
  inherited Create;
  FTableName := TableName;
end;

procedure TDeleteCommand.Execute;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  ExecSQL(FQuery);
end;

function TDeleteCommand.GetSQL: string;
begin
  Result := Format('DELETE FROM [%s] WHERE (s)', [FTableName, WhereParameters.AsCondition]);
end;

{ FParameterCollection }

procedure FParameterCollection.Add(Parameter: TParameter);
begin
  FList.Add(Parameter);
end;

function FParameterCollection.AsCondition: string;
var
  I: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      SL.Add(Format('[%s] = :%s', [Items[I].Name, Items[I].Name]));

    Result := ' ' + SL.Join(' and ') + ' ';
  finally
    F(SL);
  end;
end;

function FParameterCollection.AsInsertFields: string;
var
  I: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      SL.Add(Format('[%s]', [Items[I].Name]));

    Result := ' ' + SL.Join(', ') + ' ';
  finally
    F(SL);
  end;
end;

function FParameterCollection.AsInsertValues: string;
var
  I: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      SL.Add(Format(':%s', [Items[I].Name]));

    Result := ' ' + SL.Join(', ') + ' ';
  finally
    F(SL);
  end;
end;


function FParameterCollection.AsUpdateFieldsAndValues: string;
var
  I: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
      SL.Add(Format('[%s] = :%s', [Items[I].Name, Items[I].Name]));

    Result := ' ' + SL.Join(', ') + ' ';
  finally
    F(SL);
  end;
end;

constructor FParameterCollection.Create;
begin
  FList := TList.Create;
end;

destructor FParameterCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function FParameterCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function FParameterCollection.GetItemByID(Index: Integer): TParameter;
begin
  Result := FList[Index];
end;

{ TStringParameter }

constructor TStringParameter.Create(Name, Value: string);
begin
  inherited Create(Name);
  FValue := Value;
end;

function TStringParameter.GetValue: Variant;
begin
  Result := FValue;
end;

{ TIntegerParameter }

constructor TIntegerParameter.Create(Name: string; Value: Integer);
begin
  inherited Create(Name);
  FValue := Value;
end;

function TIntegerParameter.GetValue: Variant;
begin
  Result := FValue;
end;

{ TDateTimeParameter }

constructor TDateTimeParameter.Create(Name: string; Value: TDateTime);
begin
  inherited Create(Name);
  FValue := Value;
end;

function TDateTimeParameter.GetValue: Variant;
begin
  Result := FValue;
end;

{ TJpegParameter }

constructor TJpegParameter.Create(Name: string; Value: TJpegImage);
begin
  inherited Create(Name);
  FValue := TJPEGImage.Create;
  FValue.Assign(Value);
end;

function TJpegParameter.GetValue: Variant;
begin
  Result := Null;
end;

{ TUpdateCommand }

constructor TUpdateCommand.Create(TableName: string);
begin
  inherited Create;
  FTableName := TableName;
end;

procedure TUpdateCommand.Execute;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  ExecSQL(FQuery);
end;

function TUpdateCommand.GetSQL: string;
begin
  Result := Format('UPDATE [%s] SET %s WHERE %s', [FTableName, Parameters.AsUpdateFieldsAndValues, WhereParameters.AsCondition]);
end;

{ TDatabaseManager }

function TDatabaseManager.GetDBFile: string;
begin
  Result := dbname;
end;

initialization

finalization
  F(FManager);

end.
