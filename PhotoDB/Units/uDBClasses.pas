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

  TAllParameter = class(TParameter)
  protected
    function GetValue: Variant; override;
  public
    constructor Create;
  end;

  TCustomFieldParameter = class(TParameter)
  private
    FExpression: string;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Expression: string);
    property Expression: string read FExpression;
  end;

  TCustomConditionParameter = class(TParameter)
  private
    FExpression: string;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Expression: string);
    property Expression: string read FExpression;
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
    destructor Destroy; override;
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
    function AsFieldList: string;
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
    function GetRecordCount: Integer;
  protected
    function GetSQL: string; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure UpdateParameters;
    function Execute: Integer; virtual; abstract;
    procedure AddParameter(Parameter: TParameter);
    procedure AddWhereParameter(Parameter: TParameter);
    property SQL: string read GetSQL;
    property Parameters: FParameterCollection read FParameters;
    property WhereParameters: FParameterCollection read FWhereParameters;
    property DS: TDataSet read FQuery;
    property RecordCount: Integer read GetRecordCount;
  end;

  TInsertCommand = class(TSqlCommand)
  private
    FTableName: string;
  protected
    function GetSQL: string; override;
  public
    function Execute: Integer; override;
    function LastID: Integer;
    constructor Create(TableName: string);
  end;

  TDeleteCommand = class(TSqlCommand)
  private
    FTableName: string;
  protected
    function GetSQL: string; override;
  public
    function Execute: Integer; override;
    constructor Create(TableName: string);
  end;

  TUpdateCommand = class(TSqlCommand)
  private
    FTableName: string;
  protected
    function GetSQL: string; override;
  public
    function Execute: Integer; override;
    constructor Create(TableName: string);
  end;

  TSelectCommand = class(TSqlCommand)
  private
    FTableName: string;
  protected
    function GetSQL: string; override;
  public
    function Execute: Integer; override;
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

function TInsertCommand.Execute: Integer;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  ExecSQL(FQuery);
  Result := LastID;
end;

function TInsertCommand.GetSQL: string;
begin
  Result := Format('INSERT INTO [%s] (%s) values (%s)', [FTableName, Parameters.AsFieldList, Parameters.AsInsertValues]);
end;

function TInsertCommand.LastID: Integer;
var
  SC: TSelectCommand;
begin
  SC := TSelectCommand.Create('');
  try
    SC.AddParameter(TCustomFieldParameter.Create('@@identity as LastID'));
    SC.Execute;
    Result := SC.DS.FieldByName('LastID').AsInteger;
  finally
    F(SC);
  end;
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

function TSqlCommand.GetRecordCount: Integer;
begin
  Result := 0;
  if FQuery.Active then
    Result := FQuery.RecordCount;
end;

procedure TSqlCommand.UpdateParameters;
var
  I: Integer;
  Parameter: TParameter;
  ADOParameter: ADODB.TParameter;

  procedure UpdateParameter;
  begin
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

begin
  for I := 0 to FParameters.Count - 1 do
  begin
    Parameter := FParameters[I];
    UpdateParameter;
  end;
  for I := 0 to FWhereParameters.Count - 1 do
  begin
    Parameter := FWhereParameters[I];
    UpdateParameter;
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

function TDeleteCommand.Execute: Integer;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  ExecSQL(FQuery);
  Result := -1;
end;

function TDeleteCommand.GetSQL: string;
begin
  Result := Format('DELETE FROM [%s] WHERE (%s)', [FTableName, WhereParameters.AsCondition]);
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
    begin
      if Items[I] is TCustomConditionParameter then
      begin
        SL.Add(TCustomConditionParameter(Items[I]).Expression);
        Continue;
      end;

      SL.Add(Format('[%s] = :%s', [Items[I].Name, Items[I].Name]));
    end;

    Result := ' ' + SL.Join(' and ') + ' ';
  finally
    F(SL);
  end;
end;

function FParameterCollection.AsFieldList: string;
var
  I: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for I := 0 to Count - 1 do
    begin
      if Items[I] is TAllParameter then
      begin
        SL.Add('*');
        Continue;
      end;
      if Items[I] is TCustomFieldParameter then
      begin
        SL.Add(TCustomFieldParameter(Items[I]).Expression);
        Continue;
      end;
      SL.Add(Format('[%s]', [Items[I].Name]));
    end;

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

destructor TJpegParameter.Destroy;
begin
  F(FValue);
  inherited;
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

function TUpdateCommand.Execute: Integer;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  ExecSQL(FQuery);
  Result := -1;
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

{ TAllParameter }

constructor TAllParameter.Create;
begin
  inherited Create('*');
end;

function TAllParameter.GetValue: Variant;
begin
  Result := Null;
end;

{ TCustomConditionParameter }

constructor TCustomConditionParameter.Create(Expression: string);
begin
  inherited Create('');
  FExpression := Expression;
end;

function TCustomConditionParameter.GetValue: Variant;
begin
  Result := Null;
end;

{ TSelectCommand }

constructor TSelectCommand.Create(TableName: string);
begin
  inherited Create;
  FTableName := TableName;
end;

function TSelectCommand.Execute: Integer;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  FQuery.Open;
  Result := FQuery.RecordCount;
end;

function TSelectCommand.GetSQL: string;
begin
  Result := Format('SELECT %s', [Parameters.AsFieldList]);
  if FTableName <> '' then
    Result := Result + Format(' FROM [%s] ', [FTableName]);
  if WhereParameters.Count > 0 then
    Result := Result + Format(' WHERE %s', [WhereParameters.AsCondition]);
end;

{ TCustomFieldParameter }

constructor TCustomFieldParameter.Create(Expression: string);
begin
  inherited Create('');
  FExpression := Expression;
end;

function TCustomFieldParameter.GetValue: Variant;
begin
  Result := Null;
end;

initialization

finalization
  F(FManager);

end.
