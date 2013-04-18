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

implementation

end.
