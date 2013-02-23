unit uFormEditPlaces;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,

  uDBForm, Vcl.StdCtrls, Vcl.ImgList, Dmitry.Controls.Base,
  Dmitry.Controls.WebLink, Vcl.ExtCtrls;

type
  TFormEditPlaces = class(TDBForm)
    BtnClose: TButton;
    WebLink1: TWebLink;
    ImPlaces: TImageList;
    WebLink2: TWebLink;
    WebLink3: TWebLink;
    Bevel1: TBevel;
    WebLink4: TWebLink;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
