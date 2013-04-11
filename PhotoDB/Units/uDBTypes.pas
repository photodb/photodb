unit uDBTypes;

interface

uses
  System.Classes,
  Vcl.Imaging.Jpeg,
  UnitDBDeclare,
  uDBBaseTypes;

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
    Encrypted: Boolean;
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
    PreviewID: TGUID;
    GeoLocation: TGeoLocation;
  end;

  TMediaInfo = record
    ImTh: string;
    Jpeg: TJpegImage;
    ImageWidth, ImageHeight: Integer;
    IsEncrypted: Boolean;
    Password: string;
    Size: Integer;

    Count: Integer;
    IDs: array of Integer;
    FileNames: array of string;
    ChangedRotate: array of Boolean;
    Attr: array of Integer;

    UsedFileNameSearch: Boolean;
    IsError: Boolean;
    ErrorText: string;
  end;

  TMediaInfoArray = array of TMediaInfo;

implementation

end.
