unit uFormBusyApplications;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ImgList,

  Dmitry.Utils.System,

  uIconUtils,
  uDBForm;

type
  TFormBusyApplications = class(TDBForm)
    ImApplications: TImageList;
    LbInfo: TLabel;
    LstApplications: TListBox;
    BtnCancel: TButton;
    BtnRetry: TButton;
    procedure LstApplicationsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnRetryClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure LoadApplicationList(Applications: TStrings);
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    function Execute(Applications: TStrings): Boolean;
  end;

implementation

{$R *.dfm}

{ TFormBusyApplications }

procedure TFormBusyApplications.BtnCancelClick(Sender: TObject);
begin
  Close;
  ModalResult := mrClose;
end;

procedure TFormBusyApplications.BtnRetryClick(Sender: TObject);
begin
  Close;
  ModalResult := mrRetry;
end;

function TFormBusyApplications.Execute(Applications: TStrings): Boolean;
begin
  LoadApplicationList(Applications);
  ShowModal;

  Result := ModalResult = mrRetry;
end;

procedure TFormBusyApplications.FormCreate(Sender: TObject);
begin
  ModalResult := mrCancel;
  Caption := L('Close applications');
  BtnCancel.Caption := L('Cancel');
  BtnRetry.Caption := L('Retry');
  LbInfo.Caption := L('Please close the following application to continue uninstall:');
end;

function TFormBusyApplications.GetFormID: string;
begin
  Result := 'Setup';
end;

procedure TFormBusyApplications.LoadApplicationList(Applications: TStrings);
var
  FileName: string;
  ExeInfo: TEXEVersionData;
  Ico: HIcon;
begin
  for FileName in Applications do
  begin
    ExeInfo.FileDescription := '';
    try
      ExeInfo := GetEXEVersionData(FileName);
    except
      //unable for get versin info - ignore it
    end;
    if ExeInfo.FileDescription = '' then
      ExeInfo.FileDescription := ExtractFileName(FileName);

    LstApplications.Items.Add(ExeInfo.FileDescription);

    Ico := ExtractSmallIconByPath(FileName, True);
    try
      ImageList_ReplaceIcon(ImApplications.Handle, -1, Ico);
    finally
      DestroyIcon(Ico);
    end;
  end;
end;

procedure TFormBusyApplications.LstApplicationsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LB: TListBox;
  ACanvas: TCanvas;
  H: Integer;
begin
  LB := TListBox(Control);
  ACanvas := LB.Canvas;

  if odSelected in State then
    ACanvas.Brush.Color := Theme.ListSelectedColor
  else
    ACanvas.Brush.Color := Theme.ListColor;

  ACanvas.FillRect(Rect);
  if Index = -1 then
    Exit;

  ImApplications.Draw(ACanvas, Rect.Left + 1, Rect.Top + 1, Index);

  if odSelected in State then
    ACanvas.Font.Color := Theme.ListFontSelectedColor
  else
    ACanvas.Font.Color := Theme.ListFontColor;

  H := ACanvas.TextHeight(LB.Items[index]);
  ACanvas.TextOut(Rect.Left + ImApplications.Width + ACanvas.TextWidth('W'), Rect.Top + ImApplications.Height div 2 - H div 2, LB.Items[index]);
end;

end.
