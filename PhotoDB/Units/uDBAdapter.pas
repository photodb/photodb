unit uDBAdapter;

interface

uses
  DB, SysUtils, DateUtils;

type
  TDBAdapter = class(TObject)
  private
    FDS: TDataSet;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetFileName: string;
    procedure SetFileName(const Value: string);
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetRating: Integer;
    procedure SetRating(const Value: Integer);
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetFileSize: Integer;
    procedure SetFileSize(const Value: Integer);
    function GetThumb: TField;
    function GetRotation: Integer;
    procedure SetRotation(const Value: Integer);
    function GetAccess: Integer;
    procedure SetAccess(const Value: Integer);
    function GetKeyWords: string;
    procedure SetKeyWords(const Value: string);
    function GetComment: string;
    procedure SetComment(const Value: string);
    function GetDate: TDate;
    function GetIsDate: Boolean;
    function GetIsTime: Boolean;
    function GetTime: TTime;
    procedure SetDate(const Value: TDate);
    procedure SetIsDate(const Value: Boolean);
    procedure SetIsTime(const Value: Boolean);
    procedure SetTime(const Value: TTime);
    function GetGroups: string;
    procedure SetGroups(const Value: string);
    function GetInclude: Boolean;
    procedure SetInclude(const Value: Boolean);
    function GetLongImageID: AnsiString;
    procedure SetLongImageID(const Value: AnsiString);
    function GetLinks: string;
    procedure SetLinks(const Value: string);
    function GetAttributes: Integer;
    procedure SetAttributes(const Value: Integer);
  public
    constructor Create(DS: TDataSet);
    property ID: Integer read GetID write SetID;
    property Name: string read GetName write SetName;
    property FileName: string read GetFileName write SetFileName;
    property Rating: Integer read GetRating write SetRating;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property FileSize: Integer read GetFileSize write SetFileSize;
    property Thumb: TField read GetThumb;
    property Rotation: Integer read GetRotation write SetRotation;
    property Access: Integer read GetAccess write SetAccess;
    property KeyWords: string read GetKeyWords write SetKeyWords;
    property Comment: string read GetComment write SetComment;
    property Date: TDate read GetDate write SetDate;
    property IsDate: Boolean read GetIsDate write SetIsDate;
    property Time: TTime read GetTime write SetTime;
    property IsTime: Boolean read GetIsTime write SetIsTime;
    property Groups: string read GetGroups write SetGroups;
    property Include: Boolean read GetInclude write SetInclude;
    property LongImageID: AnsiString read GetLongImageID write SetLongImageID;
    property Links: string read GetLinks write SetLinks;
    property Attributes: Integer read GetAttributes write SetAttributes;
  end;

implementation

{ TDBAdapter }

constructor TDBAdapter.Create(DS: TDataSet);
begin
  FDS := DS;
end;

function TDBAdapter.GetAccess: Integer;
begin
  Result := FDS.FieldByName('Access').AsInteger;
end;

function TDBAdapter.GetAttributes: Integer;
begin
  Result := FDS.FieldByName('Attr').AsInteger;
end;

function TDBAdapter.GetComment: string;
begin
  Result := FDS.FieldByName('Comment').AsString;
end;

function TDBAdapter.GetDate: TDate;
begin
  Result := DateOf(FDS.FieldByName('DateToAdd').AsDateTime);
end;

function TDBAdapter.GetFileName: string;
begin
  Result := FDS.FieldByName('FFileName').AsString;
end;

function TDBAdapter.GetFileSize: Integer;
begin
  Result := FDS.FieldByName('FileSize').AsInteger;
end;

function TDBAdapter.GetGroups: string;
begin
  Result := FDS.FieldByName('Groups').AsString;
end;

function TDBAdapter.GetHeight: Integer;
begin
  Result := FDS.FieldByName('Height').AsInteger;
end;

function TDBAdapter.GetID: Integer;
begin
  Result := FDS.FieldByName('ID').AsInteger;
end;

function TDBAdapter.GetInclude: Boolean;
begin
  Result := FDS.FieldByName('Include').AsBoolean;
end;

function TDBAdapter.GetIsDate: Boolean;
begin
  Result := FDS.FieldByName('IsDate').AsBoolean;
end;

function TDBAdapter.GetIsTime: Boolean;
begin
  Result := FDS.FieldByName('IsTime').AsBoolean;
end;

function TDBAdapter.GetKeyWords: string;
begin
  Result := FDS.FieldByName('Keywords').AsString;
end;

function TDBAdapter.GetLinks: string;
begin
  Result := FDS.FieldByName('Links').AsString;
end;

function TDBAdapter.GetLongImageID: AnsiString;
begin
  Result := FDS.FieldByName('StrTh').AsAnsiString;
end;

function TDBAdapter.GetName: string;
begin
  Result := Trim(FDS.FieldByName('Name').AsString);
end;

function TDBAdapter.GetRating: Integer;
begin
  Result := FDS.FieldByName('Rating').AsInteger;
end;

function TDBAdapter.GetRotation: Integer;
begin
  Result := FDS.FieldByName('Rotated').AsInteger;
end;

function TDBAdapter.GetThumb: TField;
begin
  Result := FDS.FieldByName('thum');
end;

function TDBAdapter.GetTime: TTime;
begin
  Result := TimeOf(FDS.FieldByName('aTime').AsDateTime);
end;

function TDBAdapter.GetWidth: Integer;
begin
  Result := FDS.FieldByName('Width').AsInteger;
end;

procedure TDBAdapter.SetAccess(const Value: Integer);
begin
  FDS.FieldByName('Access').AsInteger := Value;
end;

procedure TDBAdapter.SetAttributes(const Value: Integer);
begin
  FDS.FieldByName('Attr').AsInteger := Value;
end;

procedure TDBAdapter.SetComment(const Value: string);
begin
  FDS.FieldByName('Comment').AsString := Value;
end;

procedure TDBAdapter.SetDate(const Value: TDate);
begin
  FDS.FieldByName('DateToAdd').AsDateTime := DateOf(Value);
end;

procedure TDBAdapter.SetFileName(const Value: string);
begin
  FDS.FieldByName('FFileName').AsString := Value;
end;

procedure TDBAdapter.SetFileSize(const Value: Integer);
begin
  FDS.FieldByName('FileSize').AsInteger := Value;
end;

procedure TDBAdapter.SetGroups(const Value: string);
begin
  FDS.FieldByName('Groups').AsString := Value;
end;

procedure TDBAdapter.SetHeight(const Value: Integer);
begin
  FDS.FieldByName('Height').AsInteger := Value;
end;

procedure TDBAdapter.SetID(const Value: Integer);
begin
  FDS.FieldByName('ID').AsInteger := Value;
end;

procedure TDBAdapter.SetInclude(const Value: Boolean);
begin
  FDS.FieldByName('Include').AsBoolean := Value;
end;

procedure TDBAdapter.SetIsDate(const Value: Boolean);
begin
  FDS.FieldByName('IsDate').AsBoolean := Value;
end;

procedure TDBAdapter.SetIsTime(const Value: Boolean);
begin
  FDS.FieldByName('IsTime').AsBoolean := Value;
end;

procedure TDBAdapter.SetKeyWords(const Value: string);
begin
  FDS.FieldByName('Keywords').AsString := Value;
end;

procedure TDBAdapter.SetLinks(const Value: string);
begin
  FDS.FieldByName('Links').AsString := Value;
end;

procedure TDBAdapter.SetLongImageID(const Value: AnsiString);
begin
  FDS.FieldByName('StrTh').AsAnsiString := Value;
end;

procedure TDBAdapter.SetName(const Value: string);
begin
  FDS.FieldByName('Name').AsString := Value;
end;

procedure TDBAdapter.SetRating(const Value: Integer);
begin
  FDS.FieldByName('Rating').AsInteger := Value;
end;

procedure TDBAdapter.SetRotation(const Value: Integer);
begin
  FDS.FieldByName('Rotated').AsInteger := Value;
end;

procedure TDBAdapter.SetTime(const Value: TTime);
begin
  FDS.FieldByName('aTime').AsDateTime := Value;
end;

procedure TDBAdapter.SetWidth(const Value: Integer);
begin
  FDS.FieldByName('Width').AsInteger := Value;
end;

end.
