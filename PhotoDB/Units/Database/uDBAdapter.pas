unit uDBAdapter;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.StrUtils,
  Data.DB;

type
  TImageTableAdapter = class(TObject)
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
    function GetLongImageID: string;
    procedure SetLongImageID(const Value: string);
    function GetLinks: string;
    procedure SetLinks(const Value: string);
    function GetAttributes: Integer;
    procedure SetAttributes(const Value: Integer);
    function GetColors: string;
    function GetViewCount: Integer;
    function GetUpdateDate: TDateTime;
    procedure SetColors(const Value: string);
    procedure SetViewCount(const Value: Integer);
    procedure SetUpdateDate(const Value: TDateTime);
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
    property LongImageID: string read GetLongImageID write SetLongImageID;
    property Links: string read GetLinks write SetLinks;
    property Attributes: Integer read GetAttributes write SetAttributes;
    property Colors: string read GetColors write SetColors;
    property ViewCount: Integer read GetViewCount write SetViewCount;
    property UpdateDate: TDateTime read GetUpdateDate write SetUpdateDate;
    property DataSet: TDataSet read FDS;
  end;

implementation

{ TDBAdapter }

constructor TImageTableAdapter.Create(DS: TDataSet);
begin
  FDS := DS;
end;

function TImageTableAdapter.GetAccess: Integer;
begin
  Result := FDS.FieldByName('Access').AsInteger;
end;

function TImageTableAdapter.GetAttributes: Integer;
begin
  Result := FDS.FieldByName('Attr').AsInteger;
end;

function TImageTableAdapter.GetColors: string;
begin
  Result := FDS.FieldByName('Colors').AsString;
end;

function TImageTableAdapter.GetComment: string;
begin
  Result := FDS.FieldByName('Comment').AsString;
end;

function TImageTableAdapter.GetDate: TDate;
begin
  Result := DateOf(FDS.FieldByName('DateToAdd').AsDateTime);
end;

function TImageTableAdapter.GetFileName: string;
begin
  Result := FDS.FieldByName('FFileName').AsString;
end;

function TImageTableAdapter.GetFileSize: Integer;
begin
  Result := FDS.FieldByName('FileSize').AsInteger;
end;

function TImageTableAdapter.GetGroups: string;
begin
  Result := FDS.FieldByName('Groups').AsString;
end;

function TImageTableAdapter.GetHeight: Integer;
begin
  Result := FDS.FieldByName('Height').AsInteger;
end;

function TImageTableAdapter.GetID: Integer;
begin
  Result := FDS.FieldByName('ID').AsInteger;
end;

function TImageTableAdapter.GetInclude: Boolean;
begin
  Result := FDS.FieldByName('Include').Value;
end;

function TImageTableAdapter.GetIsDate: Boolean;
begin
  Result := FDS.FieldByName('IsDate').Value;
end;

function TImageTableAdapter.GetIsTime: Boolean;
begin
  Result := FDS.FieldByName('IsTime').Value;
end;

function TImageTableAdapter.GetKeyWords: string;
begin
  Result := FDS.FieldByName('Keywords').AsString;
end;

function TImageTableAdapter.GetLinks: string;
begin
  Result := FDS.FieldByName('Links').AsString;
end;

function TImageTableAdapter.GetLongImageID: string;
begin
  Result := FDS.FieldByName('StrTh').AsString;
end;

function TImageTableAdapter.GetName: string;
begin
  Result := Trim(FDS.FieldByName('Name').AsString);
end;

function TImageTableAdapter.GetRating: Integer;
begin
  Result := FDS.FieldByName('Rating').AsInteger;
end;

function TImageTableAdapter.GetRotation: Integer;
begin
  Result := FDS.FieldByName('Rotated').AsInteger;
end;

function TImageTableAdapter.GetThumb: TField;
begin
  Result := FDS.FieldByName('thum');
end;

function TImageTableAdapter.GetTime: TTime;
begin
  Result := TimeOf(FDS.FieldByName('aTime').AsDateTime);
end;

function TImageTableAdapter.GetUpdateDate: TDateTime;
begin
  Result := FDS.FieldByName('DateUpdated').AsDateTime;
end;

function TImageTableAdapter.GetViewCount: Integer;
begin
  Result := FDS.FieldByName('ViewCount').AsInteger;
end;

function TImageTableAdapter.GetWidth: Integer;
begin
  Result := FDS.FieldByName('Width').AsInteger;
end;

procedure TImageTableAdapter.SetAccess(const Value: Integer);
begin
  FDS.FieldByName('Access').AsInteger := Value;
end;

procedure TImageTableAdapter.SetAttributes(const Value: Integer);
begin
  FDS.FieldByName('Attr').AsInteger := Value;
end;

procedure TImageTableAdapter.SetColors(const Value: string);
begin
  FDS.FieldByName('Colors').AsString := Value;
end;

procedure TImageTableAdapter.SetComment(const Value: string);
begin
  FDS.FieldByName('Comment').AsString := Value;
end;

procedure TImageTableAdapter.SetDate(const Value: TDate);
begin
  FDS.FieldByName('DateToAdd').AsDateTime := DateOf(Value);
end;

procedure TImageTableAdapter.SetFileName(const Value: string);
begin
  FDS.FieldByName('FFileName').AsString := Value;
end;

procedure TImageTableAdapter.SetFileSize(const Value: Integer);
begin
  FDS.FieldByName('FileSize').AsInteger := Value;
end;

procedure TImageTableAdapter.SetGroups(const Value: string);
begin
  FDS.FieldByName('Groups').AsString := Value;
end;

procedure TImageTableAdapter.SetHeight(const Value: Integer);
begin
  FDS.FieldByName('Height').AsInteger := Value;
end;

procedure TImageTableAdapter.SetID(const Value: Integer);
begin
  FDS.FieldByName('ID').AsInteger := Value;
end;

procedure TImageTableAdapter.SetInclude(const Value: Boolean);
begin
  FDS.FieldByName('Include').AsBoolean := Value;
end;

procedure TImageTableAdapter.SetIsDate(const Value: Boolean);
begin
  FDS.FieldByName('IsDate').AsBoolean := Value;
end;

procedure TImageTableAdapter.SetIsTime(const Value: Boolean);
begin
  FDS.FieldByName('IsTime').AsBoolean := Value;
end;

procedure TImageTableAdapter.SetKeyWords(const Value: string);
begin
  FDS.FieldByName('Keywords').AsString := Value;
end;

procedure TImageTableAdapter.SetLinks(const Value: string);
begin
  FDS.FieldByName('Links').AsString := Value;
end;

procedure TImageTableAdapter.SetLongImageID(const Value: string);
begin
  FDS.FieldByName('StrTh').AsString :=  LeftStr(Value, 100);
end;

procedure TImageTableAdapter.SetName(const Value: string);
begin
  FDS.FieldByName('Name').AsString := Value;
end;

procedure TImageTableAdapter.SetRating(const Value: Integer);
begin
  FDS.FieldByName('Rating').AsInteger := Value;
end;

procedure TImageTableAdapter.SetRotation(const Value: Integer);
begin
  FDS.FieldByName('Rotated').AsInteger := Value;
end;

procedure TImageTableAdapter.SetTime(const Value: TTime);
begin
  FDS.FieldByName('aTime').AsDateTime := Value;
end;

procedure TImageTableAdapter.SetUpdateDate(const Value: TDateTime);
begin
  FDS.FieldByName('DateUpdated').AsDateTime := Value;
end;

procedure TImageTableAdapter.SetViewCount(const Value: Integer);
begin
  FDS.FieldByName('ViewCount').AsInteger := Value;
end;

procedure TImageTableAdapter.SetWidth(const Value: Integer);
begin
  FDS.FieldByName('Width').AsInteger := Value;
end;

end.
