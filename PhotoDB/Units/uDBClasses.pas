unit uDBClasses;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.Variants,
  Vcl.Imaging.jpeg,
  Data.DB,
  Data.Win.ADODB,

  Dmitry.Utils.System,

  CommonDBSupport,

  uMemory,
  uStringUtils,
  uRuntime;

type
  TParameterAction = (paNone, paGrateThan, paGrateOrEq, paLessThan, paLessOrEq, paEquals, paNotEquals);

  TParameter = class
  private
    FName: string;
    FAction: TParameterAction;
    function GetAction: string;
  protected
    function GetValue: Variant; virtual; abstract;
  public
    constructor Create(Name: string; Action: TParameterAction);
    property Value: Variant read GetValue;
    property Name: string read FName;
    property Action: string read GetAction;
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
    constructor Create(Name: string; Value: Integer; Action: TParameterAction = paEquals);
  end;

  TDateTimeParameter = class(TParameter)
  private
    FValue: TDateTime;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Value: TDateTime; Action: TParameterAction = paEquals);
  end;

  TStringParameter = class(TParameter)
  private
    FValue: string;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Value: string = ''; Action: TParameterAction = paEquals);
  end;

  TBooleanParameter = class(TParameter)
  private
    FValue: Boolean;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Value: Boolean; Action: TParameterAction = paEquals);
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

  TStreamParameter = class(TParameter)
  private
    FStream: TStream;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; Stream: TStream);
    property Stream: TStream read FStream;
  end;

  TPersistentParameter = class(TParameter)
  private
    FPersistentObject: TPersistent;
  protected
    function GetValue: Variant; override;
  public
    constructor Create(Name: string; PersistentObject: TPersistent);
    property PersistentObject: TPersistent read FPersistentObject;
  end;

  FParameterCollection = class
  private
    FList: TList<TParameter>;
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

  TFieldHelper = class;

  TSqlCommand = class
  private
    FParameters: FParameterCollection;
    FWhereParameters: FParameterCollection;
    FCustomParameters: FParameterCollection;
    FQuery: TDataSet;
    function GetRecordCount: Integer;
  protected
    function GetSQL: string; virtual; abstract;
  public
    constructor Create(Async: Boolean = False);
    destructor Destroy; override;
    procedure UpdateParameters;
    function Execute: Integer; virtual; abstract;
    procedure AddParameter(Parameter: TParameter);
    procedure AddWhereParameter(Parameter: TParameter);
    procedure AddCustomeParameter(Parameter: TParameter);
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

  TOrderParameter = class
  private
    FColumnName: string;
    FDesc: Boolean;
  public
    constructor Create(AColumnName: string; ADesc: Boolean);
    property ColumnName: string read FColumnName;
    property ColumnDesc: Boolean read FDesc;
  end;

  TOrderParameterCollection = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItemByID(Index: Integer): TOrderParameter;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(Order: TOrderParameter);
    function AsOrderSQL: string;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TOrderParameter read GetItemByID; default;
  end;

  TSelectCommand = class(TSqlCommand)
  private
    FTableName: string;
    FTopRecords: Integer;
    FOrderParameterCollection: TOrderParameterCollection;
  protected
    function GetSQL: string; override;
  public
    function Execute: Integer; override;
    function ExecuteSql(Sql: string; ForwardOnly: Boolean): Integer;
    constructor Create(TableName: string; Async: Boolean = False);
    destructor Destroy; override;
    property TopRecords: Integer read FTopRecords write FTopRecords;
    property Order: TOrderParameterCollection read FOrderParameterCollection;
  end;

  TDatabaseManager = class(TObject)
  private
    function GetDBFile: string;
  public
    property DBFile: string read GetDBFile;
  end;

  TFieldHelper = class(TObject)
  protected
    FCommand: TSqlCommand;
    constructor Create(Command: TSqlCommand);
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

procedure TSqlCommand.AddCustomeParameter(Parameter: TParameter);
begin
  FCustomParameters.Add(Parameter);
end;

procedure TSqlCommand.AddParameter(Parameter: TParameter);
begin
  FParameters.Add(Parameter);
end;

procedure TSqlCommand.AddWhereParameter(Parameter: TParameter);
begin
  FWhereParameters.Add(Parameter);
end;

constructor TSqlCommand.Create(Async: Boolean = False);
begin
  FParameters := FParameterCollection.Create;
  FWhereParameters := FParameterCollection.Create;
  FCustomParameters := FParameterCollection.Create;
  FQuery := GetQuery(Async);
end;

destructor TSqlCommand.Destroy;
begin
  F(FParameters);
  F(FWhereParameters);
  F(FCustomParameters);
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
  ADOParameter: Data.Win.ADODB.TParameter;

  procedure UpdateParameter;
  begin
    ADOParameter := nil;
    if FQuery is TADOQuery then
      ADOParameter := TADOQuery(FQuery).Parameters.FindParam(Parameter.Name);
    if ADOParameter <> nil then
    begin
      if Parameter is TDateTimeParameter then
        ADOParameter.Value := TDateTimeParameter(Parameter).Value
      else if Parameter is TIntegerParameter then
        ADOParameter.Value := TIntegerParameter(Parameter).Value
      else if Parameter is TStringParameter then
        ADOParameter.Value := TStringParameter(Parameter).Value
      else if Parameter is TBooleanParameter then
        ADOParameter.Value := TBooleanParameter(Parameter).Value
      else if Parameter is TJpegParameter then
      begin
        TJpegParameter(Parameter).Image.Compress;
        ADOParameter.Assign(TJpegParameter(Parameter).Image);
      end else if Parameter is TStreamParameter then
        ADOParameter.LoadFromStream(TStreamParameter(Parameter).Stream, ftBlob)
      else if Parameter is TPersistentParameter then
        ADOParameter.Assign(TPersistentParameter(Parameter).PersistentObject);
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
  for I := 0 to FCustomParameters.Count - 1 do
  begin
    Parameter := FCustomParameters[I];
    UpdateParameter;
  end;
end;

{ TParameter }

constructor TParameter.Create(Name: string; Action: TParameterAction);
begin
  FName := Name;
  FAction := Action;
end;

function TParameter.GetAction: string;
begin
  Result := '';
  case FAction of
    //paNone:
    paGrateThan:
      Result := '>';
     paGrateOrEq:
      Result := '>=';
     paLessThan:
      Result := '<';
     paLessOrEq:
      Result := '<=';
     paEquals:
      Result := '=';
     paNotEquals:
      Result := '<>';
  end;

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

      SL.Add(Format('[%s] %s :%s', [Items[I].Name, Items[I].Action, Items[I].Name]));
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
  FList := TList<TParameter>.Create;
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

constructor TStringParameter.Create(Name: string; Value: string = ''; Action: TParameterAction = paEquals);
begin
  inherited Create(Name, Action);
  FValue := Value;
end;

function TStringParameter.GetValue: Variant;
begin
  Result := FValue;
end;

{ TIntegerParameter }

constructor TIntegerParameter.Create(Name: string; Value: Integer; Action: TParameterAction = paEquals);
begin
  inherited Create(Name, Action);
  FValue := Value;
end;

function TIntegerParameter.GetValue: Variant;
begin
  Result := FValue;
end;

{ TDateTimeParameter }

constructor TDateTimeParameter.Create(Name: string; Value: TDateTime; Action: TParameterAction = paEquals);
begin
  inherited Create(Name, Action);
  FValue := Value;
end;

function TDateTimeParameter.GetValue: Variant;
begin
  Result := FValue;
end;

{ TBooleanParameter }

constructor TBooleanParameter.Create(Name: string; Value: Boolean;
  Action: TParameterAction);
begin
  inherited Create(Name, Action);
  FValue := Value;
end;

function TBooleanParameter.GetValue: Variant;
begin
  Result := FValue;
end;

{ TJpegParameter }

constructor TJpegParameter.Create(Name: string; Value: TJpegImage);
begin
  inherited Create(Name, paNone);
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

{ TStreamParameter }

constructor TStreamParameter.Create(Name: string; Stream: TStream);
begin
  inherited Create(Name, paNone);
  FStream := Stream;
end;

function TStreamParameter.GetValue: Variant;
begin
  Result := Null;
end;

{ TPersistentParameter }

constructor TPersistentParameter.Create(Name: string;
  PersistentObject: TPersistent);
begin
  inherited Create(Name, paNone);
  FPersistentObject := PersistentObject;
end;

function TPersistentParameter.GetValue: Variant;
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
  inherited Create('*', paNone);
end;

function TAllParameter.GetValue: Variant;
begin
  Result := Null;
end;

{ TCustomConditionParameter }

constructor TCustomConditionParameter.Create(Expression: string);
begin
  inherited Create('', paNone);
  FExpression := Expression;
end;

function TCustomConditionParameter.GetValue: Variant;
begin
  Result := Null;
end;

{ TSelectCommand }

constructor TSelectCommand.Create(TableName: string; Async: Boolean = False);
begin
  inherited Create(Async);
  FOrderParameterCollection := TOrderParameterCollection.Create;
  FTopRecords := 0;
  FTableName := TableName;
end;

destructor TSelectCommand.Destroy;
begin
  F(FOrderParameterCollection);
  inherited;
end;

function TSelectCommand.Execute: Integer;
begin
  SetSQL(FQuery, SQL);
  UpdateParameters;
  OpenDS(FQuery);
  Result := FQuery.RecordCount;
  if Result > 0 then
    FQuery.First;
end;

function TSelectCommand.ExecuteSql(Sql: string; ForwardOnly: Boolean): Integer;
begin
  SetSQL(FQuery, Sql);
  if ForwardOnly then
  begin
    ReadOnlyQuery(FQuery);
    ForwardOnlyQuery(FQuery);
  end;
  UpdateParameters;
  OpenDS(FQuery);
  Result := IIF(FQuery.Eof, 0, 1);
end;

function TSelectCommand.GetSQL: string;
begin
  Result := 'SELECT';
  if TopRecords > 0 then
    Result := Result + Format(' TOP %d ', [TopRecords]);
  Result := Result + Format(' %s', [Parameters.AsFieldList]);
  if FTableName <> '' then
    Result := Result + Format(IIF(Pos(' ', FTableName)> 0, ' FROM %s', ' FROM [%s] '), [FTableName]);
  if WhereParameters.Count > 0 then
    Result := Result + Format(' WHERE %s', [WhereParameters.AsCondition]);
  Result := Result + FOrderParameterCollection.AsOrderSQL;
end;

{ TCustomFieldParameter }

constructor TCustomFieldParameter.Create(Expression: string);
begin
  inherited Create('', paNone);
  FExpression := Expression;
end;

function TCustomFieldParameter.GetValue: Variant;
begin
  Result := Null;
end;

{ TOrderParameter }

constructor TOrderParameter.Create(AColumnName: string; ADesc: Boolean);
begin
  FColumnName := AColumnName;
  FDesc := ADesc;
end;

{ TOrderParameterCollection }

procedure TOrderParameterCollection.Add(Order: TOrderParameter);
begin
  FList.Add(Order);
end;

function TOrderParameterCollection.AsOrderSQL: string;
var
  I: Integer;
  OrderParams: TStrings;
begin
  Result := '';
  if Count > 0 then
  begin
    Result := 'ORDER BY ';
    OrderParams := TStringList.Create;
    try
      for I := 0 to Count - 1 do
        OrderParams.Add(FormatEx('{0}{1}', [Items[I].ColumnName, IIF(Items[I].ColumnDesc, ' DESC', '')]));
      Result := Result + OrderParams.Join(', ');
    finally
      F(OrderParams);
    end;
  end;
end;

constructor TOrderParameterCollection.Create;
begin
  FList := TList.Create;
end;

destructor TOrderParameterCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TOrderParameterCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TOrderParameterCollection.GetItemByID(Index: Integer): TOrderParameter;
begin
  Result := FList[Index];
end;

{ TFieldHelper }

constructor TFieldHelper.Create(Command: TSqlCommand);
begin
  FCommand := Command;
end;

initialization

finalization
  F(FManager);

end.
