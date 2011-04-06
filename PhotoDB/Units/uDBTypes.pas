unit uDBTypes;

interface

uses
  Jpeg, UnitDBDeclare, uDBBaseTypes;

type
  RString = type AnsiString(1251);

type
  TSelectedInfo = record
    FileName: string;
    FileType: Integer;
    FileTypeW: string;
    KeyWords: string;
    CommonKeyWords: string;
    Rating: Integer;
    CommonRating: Integer;
    Comment: string;
    Groups: string;
    CommonComment: string;
    IsVariousComments: Boolean;
    IsVariousDates: Boolean;
    IsVariousTimes: Boolean;
    Size: Int64;
    Date: TDateTime;
    IsDate: Boolean;
    IsTime: Boolean;
    Time: TDateTime;
    Access: Integer;
    Id: Integer;
    Ids: TArInteger;
    One: Boolean;
    Width: Integer;
    Height: Integer;
    Nil_: Boolean;
    _GUID: TGUID;
    SelCount: Integer;
    Selected: TObject;
    Links: string;
    IsVaruousInclude: Boolean;
    Include: Boolean;
  end;

  TImageDBRecordA = record
    IDs: array of Integer;
    FileNames: array of string;
    ImTh: AnsiString;
    Count: Integer;
    Attr: array of Integer;
    Jpeg: TJpegImage;
    OrWidth, OrHeight: Integer;
    Crypt: Boolean;
    Password: string;
    Size: Integer;
    UsedFileNameSearch: Boolean;
    ChangedRotate: array of Boolean;
    IsError: Boolean;
    ErrorText: string;
  end;

  TImageDBRecordAArray = array of TImageDBRecordA;

implementation

end.
