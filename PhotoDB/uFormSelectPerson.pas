unit uFormSelectPerson;

interface

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.CommCtrl,
  Winapi.ActiveX,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  Dmitry.Utils.System,
  Dmitry.Controls.Base,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.SaveWindowPos,

  UnitDBKernel,
  UnitDBDeclare,

  uConstants,
  uThreadForm,
  uThreadTask,
  uPeopleRepository,
  uBitmapUtils,
  uMemory,
  uMachMask,
  uFormInterfaces,
  uDBEntities,
  uDBContext,
  uGraphicUtils;

type
  TFormFindPerson = class(TThreadForm)
    WedPersonFilter: TWatermarkedEdit;
    LbFindPerson: TLabel;
    ImSearch: TImage;
    BtnOk: TButton;
    BtnCancel: TButton;
    LvPersons: TListView;
    TmrSearch: TTimer;
    ImlPersons: TImageList;
    LsMain: TLoadingSign;
    WlCreatePerson: TWebLink;
    SaveWindowPos1: TSaveWindowPos;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure WedPersonFilterChange(Sender: TObject);
    procedure TmrSearchTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LvPersonsDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure WedPersonFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LvPersonsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure WlCreatePersonClick(Sender: TObject);
  private
    { Private declarations }
    FContext: IDBContext;
    FPeopleRepository: IPeopleRepository;
    WndMethod: TWndMethod;
    FInfo: TMediaItem;
    FFormResult: Integer;
    FPersons: TPersonCollection;
    function GetIndex(aNMHdr: pNMHdr): Integer;
    procedure CheckMsg(var aMsg: TMessage);
    procedure LoadList;
    procedure AddItem(P: TPerson);
    procedure LoadLanguage;
    procedure EnableControls(IsEnabled: Boolean);
  protected
    function GetFormID: string; override;
    procedure CustomFormAfterDisplay; override;
    procedure CloseForm;
  public
    { Public declarations }
    function Execute(Info: TMediaItem; var Person: TPerson): Integer;
  end;

const
  SELECT_PERSON_CANCEL     = 0;
  SELECT_PERSON_OK         = 1;
  SELECT_PERSON_CREATE_NEW = 2;

implementation

{$R *.dfm}

function TFormFindPerson.GetFormID: string;
begin
  Result := 'SelectPerson';
end;

function TFormFindPerson.GetIndex(aNMHdr: pNMHdr): Integer;
var
  hHWND: HWND;
  HdItem: THdItem;
  iIndex: Integer;
  iResult: Integer;
  iLoop: Integer;
  sCaption: string;
  sText: string;
  Buf: array [0..128] of Char;
begin
  Result := -1;

  hHWND := aNMHdr^.hwndFrom;

  iIndex := pHDNotify(aNMHdr)^.Item;

  FillChar(HdItem, SizeOf(HdItem), 0);
  with HdItem do
  begin
    pszText    := Buf;
    cchTextMax := SizeOf(Buf) - 1;
    Mask       := HDI_TEXT;
  end;

  Header_GetItem(hHWND, iIndex, HdItem);

  with LvPersons do
  begin
    sCaption := Columns[iIndex].Caption;
    sText    := HdItem.pszText;
    iResult  := CompareStr(sCaption, sText);
    if iResult = 0 then
      Result := iIndex
    else
    begin
      iLoop := Columns.Count - 1;
      for iIndex := 0 to iLoop do
      begin
        iResult := CompareStr(sCaption, sText);
        if iResult <> 0 then
          Continue;

        Result := iIndex;
        break;
      end;
    end;
  end;
end;

procedure TFormFindPerson.CloseForm;
begin
  LsMain.Hide;
  if (LvPersons.Selected <> nil) and (FInfo <> nil) and (FInfo.ID = 0) then
  begin
    NewFormState;
    FInfo.Include := True;
    CollectionAddItemForm.Execute(FInfo);
    if FInfo.ID = 0 then
      Exit;
  end;

  FFormResult := SELECT_PERSON_OK;
  Close;
end;

procedure TFormFindPerson.CustomFormAfterDisplay;
begin
  inherited;
  WedPersonFilter.Refresh;
end;

procedure TFormFindPerson.BtnOkClick(Sender: TObject);
begin
  if LvPersons.Selected <> nil then
  begin
    CloseForm;
    Exit;
  end;

  Close;
end;

procedure TFormFindPerson.CheckMsg(var aMsg: TMessage);
var
  HDNotify: ^THDNotify;
  NMHdr: pNMHdr;
  iCode: Integer;
  iIndex: Integer;
begin
  case aMsg.Msg of
    WM_NOTIFY:
      begin
        HDNotify := Pointer(aMsg.lParam);

        iCode := HDNotify.Hdr.code;
        if (iCode = HDN_BEGINTRACKW) or
          (iCode = HDN_BEGINTRACKA) then
        begin
          NMHdr := TWMNotify(aMsg).NMHdr;
          // chekck column index
          iIndex := GetIndex(NMHdr);
          // prevent resizing of columns if index's less than 3
          if iIndex < 3 then
            aMsg.Result := 1;
        end
        else
          WndMethod(aMsg);
      end;
    else
      WndMethod(aMsg);
  end;
end;

procedure TFormFindPerson.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormFindPerson.EnableControls(IsEnabled: Boolean);
begin
  BtnOk.Enabled := IsEnabled;
  BtnCancel.Enabled := IsEnabled;
  LvPersons.Enabled := IsEnabled;
  WedPersonFilter.Enabled := IsEnabled;
  LsMain.Visible := not IsEnabled;
end;

function TFormFindPerson.Execute(Info: TMediaItem; var Person: TPerson): Integer;
begin
  FFormResult := SELECT_PERSON_CANCEL;

  if Info <> nil then
    FInfo := Info.Copy
  else
    WlCreatePerson.Hide;

  ShowModal;
  if LvPersons.Selected <> nil then
    Person := TPerson(TPerson(LvPersons.Selected.Data).Clone);

  Result := FFormResult;
end;

procedure TFormFindPerson.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LvPersons.WindowProc := WndMethod;
end;

procedure TFormFindPerson.FormCreate(Sender: TObject);
begin
  FContext := DBKernel.DBContext;
  FPeopleRepository := FContext.People;

  FInfo := nil;
  FPersons := TPersonCollection.Create(False);
  FFormResult := SELECT_PERSON_CANCEL;
  WndMethod := LvPersons.WindowProc;
  LvPersons.WindowProc := CheckMsg;
  LoadList;
  TmrSearchTimer(Self);
  LoadLanguage;
  SaveWindowPos1.Key := RegRoot + 'SelectPerson';
  SaveWindowPos1.SetPosition(True);
end;

procedure TFormFindPerson.FormDestroy(Sender: TObject);
begin
  SaveWindowPos1.SavePosition;
  FPersons.FreeItems;
  F(FPersons);
  F(FInfo);

  FPeopleRepository := nil;
  FContext := nil;
end;

procedure TFormFindPerson.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TFormFindPerson.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Select person');
    BtnOk.Caption := L('Ok');
    BtnCancel.Caption := L('Cancel');
    LvPersons.Column[0].Caption := L('Photo');
    LvPersons.Column[1].Caption := L('Name');
    LbFindPerson.Caption := L('Find person');
    WedPersonFilter.WatermarkText := L('Filter persons');
    WlCreatePerson.Text := L('Close window and create new person');
  finally
    EndTranslate;
  end;
end;

procedure TFormFindPerson.LoadList;
begin
  LvPersons.Clear;
  ImlPersons.Clear;
  NewFormState;
  LsMain.Show;
  LvPersons.ControlStyle := LvPersons.ControlStyle + [csOpaque];

  TThreadTask.Create(Self, Pointer(nil),
    procedure(Thread: TThreadTask; Data: Pointer)
    var
      W, H: Integer;
      B, B32, SmallB, LB: TBitmap;
      ImageListWidth, ImageListHeight: Integer;
    begin
      ImageListWidth := 0;
      ImageListHeight := 0;
      if not Thread.SynchronizeTask(
         procedure
         begin
           ImageListWidth := ImlPersons.Width;
           ImageListHeight := ImlPersons.Height;
         end
        ) then Exit;

      CoInitialize(nil);
      try
        FPeopleRepository.LoadTopPersons(procedure(P: TPerson; var StopOperation: Boolean)
          begin
            B := TBitmap.Create;
            try
              B.Assign(P.Image);
              W := B.Width;
              H := B.Height;
              SmallB := TBitmap.Create;
              try
                ProportionalSize(ImageListWidth - 4, ImageListHeight - 4, W, H);
                DoResize(W, H, B, SmallB);
                B32 := TBitmap.Create;
                try
                  B32.PixelFormat := pf32Bit;
                  DrawShadowToImage(B32, SmallB);

                  LB := TBitmap.Create;
                  try
                    LB.PixelFormat := pf32bit;
                    LB.SetSize(ImageListWidth, ImageListHeight);
                    FillTransparentColor(LB, Theme.ListViewColor, 0);
                    DrawImageEx32To32(LB, B32, ImageListWidth div 2 - B32.Width div 2, ImageListHeight div 2 - B32.Height div 2);

                    if not Thread.SynchronizeTask(
                      procedure
                      begin
                        FPersons.Add(P);
                        ImlPersons.Add(LB, nil);
                        LvPersons.Items.BeginUpdate;
                        try
                          AddItem(P);
                        finally
                          LvPersons.Items.EndUpdate;
                        end;
                      end
                    ) then
                    begin
                      F(P);
                      StopOperation := True;
                    end;

                  finally
                    F(LB);
                  end;
                finally
                  F(B32);
                end;
              finally
                F(SmallB);
              end;
            finally
              F(B);
            end;
          end
        );
      finally
        CoUninitialize;
      end;
      Thread.SynchronizeTask(
        procedure
        begin
          LsMain.Hide;
          LvPersons.ControlStyle := LvPersons.ControlStyle - [csOpaque];
        end
      );

    end
  );
end;

procedure TFormFindPerson.LvPersonsDblClick(Sender: TObject);
begin
  CloseForm;
end;

procedure TFormFindPerson.LvPersonsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  BtnOk.Enabled := (Item <> nil) and Selected;
end;

procedure TFormFindPerson.TmrSearchTimer(Sender: TObject);
var
  I: Integer;
begin
  TmrSearch.Enabled := False;
  BtnOk.Enabled := False;

  if Sender <> Self then
    BeginScreenUpdate(Handle);
  LvPersons.Items.BeginUpdate;
  try
    LvPersons.Clear;

    for I := 0 to FPersons.Count - 1 do
      AddItem(FPersons[I]);

  finally
    LvPersons.Items.EndUpdate;
    if Sender <> Self then
      EndScreenUpdate(Handle, True);
  end;
end;

procedure TFormFindPerson.AddItem(P: TPerson);
var
  LI: TListItem;
  SearchTerm, Key, Description: string;
  Visible: Boolean;
begin
  SearchTerm := AnsiLowerCase(WedPersonFilter.Text);
  if Pos('*', SearchTerm) = 0 then
    SearchTerm := '*' + SearchTerm + '*';

  Key :=  AnsiLowerCase(P.Name + ' ' + P.Comment);
  Visible := IsMatchMask(Key, SearchTerm);

  if Visible then
  begin
    LI := LvPersons.Items.Add;
    LI.Caption := P.Name;
    LI.ImageIndex := FPersons.IndexOf(P);
    Description := P.Name;
    if Trim(P.Comment) <> '' then
      Description := Description + #13 + P.Comment;
    Description := Description + #13 + FormatEx(L('Photos: {0}'), [P.Count]);

    LI.SubItems.Add(Description);
    LI.Data := Pointer(P);
  end;
end;

procedure TFormFindPerson.WedPersonFilterChange(Sender: TObject);
begin
  TmrSearch.Enabled := False;
  TmrSearch.Enabled := True;
end;

procedure TFormFindPerson.WedPersonFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (LvPersons.Items.Count = 1) then
  begin
    Key := 0;
    LvPersons.Items[0].Selected := True;
    BtnOkClick(Sender);
  end;
end;

procedure TFormFindPerson.WlCreatePersonClick(Sender: TObject);
begin
  FFormResult := SELECT_PERSON_CREATE_NEW;
  Close;
end;

end.
