unit UnitImportingImagesForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, DmProgress, Dolphin_DB, ComCtrls,
  acDlgSelect, ImgList, UnitUpdateDBObject, UnitDBkernel,
  UnitTimeCounter, uVistaFuncs, UnitDBFileDialogs, UnitDBDeclare,
  UnitDBCommon, UnitDBCommonGraphics, uFileUtils, uGraphicUtils,
  uConstants, uMemory, uDBForm, uShellIntegration, uRuntime,
  uShellUtils, uSettings, pngimage, uMemoryEx;

type
  TImportPlace = class(TObject)
  public
    Path: string;
  end;

type
  TFormImportingImages = class(TDBForm)
    Image1: TImage;
    Label1: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
    BtnNext: TButton;
    BtnPrev: TButton;
    BtnCancel: TButton;
    Button4: TButton;
    Button5: TButton;
    Panel2: TPanel;
    Label2: TLabel;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Label3: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    Panel3: TPanel;
    Label6: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Edit3: TEdit;
    Label7: TLabel;
    Button6: TButton;
    PbMain: TDmProgress;
    Label8: TLabel;
    Image2: TImage;
    Edit4: TEdit;
    PlacesListView: TListView;
    PlacesImageList: TImageList;
    PopupMenu1: TPopupMenu;
    DeleteItem1: TMenuItem;
    BtnBegin: TButton;
    Image3: TImage;
    Label9: TLabel;
    ComboBox1: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    BtnBreak: TButton;
    BtnPause: TButton;
    BtnFinish: TButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button4Click(Sender: TObject);
    procedure PlacesListViewContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button5Click(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnPrevClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure BtnBeginClick(Sender: TObject);
    procedure BtnBreakClick(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangedDBDataByID(Sender : TObject; ID : integer; params : TEventFields; Value : TEventValues);
    procedure BtnFinishClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FFileName: string;
    SilentClose: Boolean;
    Step: Integer;
    DBTestOK: Boolean;
    UpdateObject: TUpdaterDB;
    FullSize: Int64;
    ImageCounter: Integer;
    ProcessingSize: Int64;
    ImageProcessedCounter: Integer;
    TimeCounter: TTimeCounter;
    procedure LoadLanguage;
  protected
    function GetFormID: string; override;
  public
    { Public declarations }
    procedure Execute(FileName: string);
    procedure AddFolder(NewPlace: string);
    procedure FileFounded(Owner: TObject; FileName: string; Size: Int64);
    procedure DirectoryAdded(Sender: TObject);
    procedure SetMaxValue(Value: Integer);
    procedure SetPosition(Value: Integer);
    procedure OnDone(Sender: TObject);
  end;

const
  DefaultIcon = '%SystemRoot%\system32\shell32.dll,3';

procedure ImportImages(FileName : string);

implementation

{$R *.dfm}

uses
  UnitUpdateDBThread, UnitHelp;

procedure ImportImages(FileName: string);
var
  FormImportingImages: TFormImportingImages;
begin
  Application.CreateForm(TFormImportingImages, FormImportingImages);
  try
    FormImportingImages.Execute(FileName);
  finally
    R(FormImportingImages);
  end;
end;

procedure TFormImportingImages.Execute(FileName: string);
begin
  FFileName := FileName;
  ShowModal;
end;

procedure TFormImportingImages.FormCreate(Sender: TObject);
begin
  FullSize := 0;
  TimeCounter := TTimeCounter.Create;
  TimeCounter.TimerInterval := 15000; // 15 seconds to refresh
  ImageCounter := 0;
  ImageProcessedCounter := 0;
  ProcessingSize := 0;
  Step := 1;
  DBTestOK := False;

  DBKernel.RegisterChangesID(Self, ChangedDBDataByID);

  PopupMenu1.Images := DBKernel.ImageList;
  DeleteItem1.ImageIndex := DB_IC_DELETE_INFO;
  PlacesImageList.BkColor := PlacesListView.Color;

  AddFolder(GetMyPicturesPath);

  LoadLanguage;
end;

procedure TFormImportingImages.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Import your images into the database');
    Label1.Caption := L('This wizard will help you add to the database your photos or other images');
    Label4.Caption := L('Select folders to import images');
    Button4.Caption := L('Add folder');
    BtnCancel.Caption := L('Cancel');
    Button5.Caption := L('Delete');
    BtnPrev.Caption := L('Previous');
    BtnNext.Caption := L('Next');
    DeleteItem1.Caption := L('Delete');
    CheckBox1.Caption := L('Do not add files to collection if size less than') + ':';
    Label3.Caption := L('Width');
    Label5.Caption := L('Height');
    RadioButton1.Caption := L('Current collection');
    RadioButton2.Caption := L('Create new collection');
    Label7.Caption := L('File with collection') + ':';
    Label2.Caption := L('Please, select additional options of import');
    Label6.Caption := L('Click the "Start" button and wait until the program finds and adds all your images. This may require a long time depending on the size of your photo album');
    BtnBegin.Caption := L('Start');
    ComboBox1.Clear;
    ComboBox1.Items.Add(L('Ask me'));
    ComboBox1.Items.Add(L('Add all'));
    ComboBox1.Items.Add(L('Skip all'));
    ComboBox1.Items.Add(L('Replace all'));
    ComboBox1.ItemIndex := 0;
    Label9.Caption := L('If duplicates are found');
    Label10.Caption := L('Searching for images...');
    Label11.Caption := Format(L('Current size - %s'), [SizeInText(FullSize)]);
    Label12.Caption := Format(L('Found %d images'), [ImageCounter]);
    BtnBreak.Caption := L('Break');
    BtnPause.Caption := L('Pause');
    BtnFinish.Caption := L('Finish');
    PlacesListView.Columns[0].Caption := L('Locations to import');
    PbMain.Text := L('Progress... (&%%)');
  finally
    EndTranslate;
  end;
end;

procedure TFormImportingImages.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormImportingImages.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  I: Integer;
begin
  for I := 0 to PlacesListView.Items.Count - 1 do
    TObject(PlacesListView.Items[I].Data).Free;
  PlacesListView.Clear;
end;

procedure TFormImportingImages.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if not SilentClose then
  begin
    if ID_OK = MessageBoxDB(Handle,
      L('Do you really want to close this wizard?'), L('Question'),
      TD_BUTTON_OKCANCEL, TD_ICON_QUESTION) then
    begin
      CanClose := true;
      if UpdateObject <> nil then
      begin
        UpdateObject.DoTerminate;
        F(UpdateObject);
      end;
    end
    else
      CanClose := false;
  end;
end;

procedure TFormImportingImages.AddFolder(NewPlace : string);
var
  P: TImportPlace;
begin
  if DirectoryExists(NewPlace) then
  begin
    AddIconToListFromPath(PlacesImageList, DefaultIcon);
    P:= TImportPlace.Create;
    P.Path := NewPlace;
    with PlacesListView.Items.AddItem(nil) do
    begin
      ImageIndex := PlacesImageList.Count - 1;
      Caption := Mince(NewPlace, 30);
      Data := P;
    end;
  end;
end;

procedure TFormImportingImages.Button4Click(Sender: TObject);
var
  NewPlace: String;
begin
  NewPlace := UnitDBFileDialogs.DBSelectDir(Handle, L('Please, select a folder'),
    UseSimpleSelectFolderDialog);
  AddFolder(NewPlace);
end;

procedure TFormImportingImages.PlacesListViewContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  Item: TListItem;
begin
  Item := PlacesListView.GetItemAt(MousePos.X, MousePos.Y);
  if Item <> nil then
  begin
    PopupMenu1.Tag := Item.Index;
    PopupMenu1.Popup(PlacesListView.ClientToScreen(MousePos).X,
      PlacesListView.ClientToScreen(MousePos).Y);
  end;
end;

procedure TFormImportingImages.Button5Click(Sender: TObject);
var
  I: Integer;
begin
  if PopupMenu1.Tag <> -1 then
    if PlacesListView.Selected <> nil then
      PopupMenu1.Tag := PlacesListView.Selected.Index;

  if PopupMenu1.Tag <> -1 then
  begin
    PlacesImageList.Delete(PopupMenu1.Tag);
    TObject(PlacesListView.Items[PopupMenu1.Tag].Data).Free;
    PlacesListView.Items.Delete(PopupMenu1.Tag);
    for I := PopupMenu1.Tag to PlacesListView.Items.Count - 1 do
      PlacesListView.Items[I].ImageIndex := PlacesListView.Items[I].ImageIndex - 1;
  end;
end;

procedure TFormImportingImages.BtnNextClick(Sender: TObject);
begin
  if Step = 2 then
  begin
    BtnBegin.Visible := true;
    BtnNext.Visible := false;
    Panel2.Visible := false;
    Panel3.Visible := true;
    Step := 3;
  end;
  if Step = 1 then
  begin
    if PlacesListView.Items.Count = 0 then
    begin
      MessageBoxDB(Handle, L('Please, add any path to import images!'), L('Warning'),
        TD_BUTTON_OK, TD_ICON_WARNING);
      Exit;
    end;
    BtnPrev.Enabled := true;
    Panel1.Visible := false;
    Panel2.Visible := true;
    Step := 2;
  end;
end;

procedure TFormImportingImages.BtnPrevClick(Sender: TObject);
begin
  if Step = 2 then
  begin
    BtnPrev.Enabled := false;
    Panel1.Visible := true;
    Panel2.Visible := false;
    Step := 1;
  end;
  if Step = 3 then
  begin
    Panel2.Visible := true;
    Panel3.Visible := false;
    BtnBegin.Visible := false;
    BtnNext.Visible := true;
    Step := 2;
  end;
end;

procedure TFormImportingImages.Button6Click(Sender: TObject);
var
  SaveDialog: DBSaveDialog;
  FileName: string;
begin
  SaveDialog := DBSaveDialog.Create;
  try
    SaveDialog.Filter := L('PhotoDB Files (*.photodb)|*.photodb');
    SaveDialog.FilterIndex := 0;

    if SaveDialog.Execute then
    begin
      FileName := SaveDialog.FileName;

      if SaveDialog.GetFilterIndex = 2 then
        if GetExt(FileName) <> 'DB' then
          FileName := FileName + '.db';
      if SaveDialog.GetFilterIndex = 1 then
        if GetExt(FileName) <> 'PHOTODB' then
          FileName := FileName + '.photodb';

      if FileExistsSafe(FileName) and (ID_OK <> MessageBoxDB(Handle,
          Format(L('File &quot;%s&quot; already exists! $nl$Replace?'), [FileName]), L('Warning'),
          TD_BUTTON_OKCANCEL, TD_ICON_WARNING)) then
        Exit;
      begin
        DBKernel.CreateDBbyName(FileName);
        DBTestOK := DBKernel.TestDB(FileName);
        Edit3.Text := FileName;
      end;
    end;
  finally
    F(SaveDialog);
  end;
end;

procedure TFormImportingImages.CheckBox1Click(Sender: TObject);
begin
  Edit1.Enabled := CheckBox1.Checked;
  Edit2.Enabled := CheckBox1.Checked;
end;

procedure TFormImportingImages.RadioButton2Click(Sender: TObject);
begin
  Edit3.Enabled := RadioButton2.Checked;
  Button6.Enabled := RadioButton2.Checked;
end;

procedure TFormImportingImages.BtnBeginClick(Sender: TObject);
begin
  BtnCancel.Enabled := False;
  BtnPrev.Visible := False;
  BtnBegin.Visible := False;
  BtnBreak.Visible := True;
  BtnPause.Visible := True;

  Settings.WriteBool('Options', 'NoAddSmallImages', CheckBox1.Checked);
  Settings.WriteString('Options', 'NoAddSmallImagesWidth', Edit1.Text);
  Settings.WriteString('Options', 'NoAddSmallImagesHeight', Edit2.Text);

  UpdateObject := TUpdaterDB.Create(Self);
  UpdateObject.OwnerFormSetMaxValue := SetMaxValue;
  UpdateObject.OwnerFormSetPosition := SetPosition;
  UpdateObject.OnDirectoryAdded := DirectoryAdded;
  UpdateObject.SetDone := OnDone;

  Case ComboBox1.ItemIndex of
    1:
      UpdateObject.AutoAnswer := Result_add_all;
    2:
      UpdateObject.AutoAnswer := Result_skip_all;
    3:
      UpdateObject.AutoAnswer := Result_replace_all;
  end;
  UpdateObject.Auto := False;
  UpdateObject.AddDirectory(TImportPlace(PlacesListView.Items[0].Data).Path, FileFounded);
  Label10.Visible := True;
  Label11.Visible := True;
  Label12.Visible := True;
  Image3.Visible := True;
end;

procedure TFormImportingImages.FileFounded(Owner: TObject; FileName: string;
  Size: int64);
begin
  FullSize := FullSize + Size;
  Inc(ImageCounter);
  Label11.Caption := Format(L('Current size - %s'), [SizeInText(FullSize)]);
  Label12.Caption := Format(L('Found %d images'), [ImageCounter]);
  Edit4.Text := FileName;
end;

procedure TFormImportingImages.DirectoryAdded(Sender: TObject);
begin
  TObject(PlacesListView.Items[0].Data).Free;
  PlacesListView.Items[0].Delete;
  if PlacesListView.Items.Count > 0 then
    UpdateObject.AddDirectory(TImportPlace(PlacesListView.Items[0].Data).Path,
      FileFounded)
  else
  begin
    if UpdateObject.GetCount = 0 then
    begin
      OnDone(Sender);
      Exit;
    end;
    TimeCounter.MaxActions := FullSize;
    TimeCounter.DoBegin;
    UpdateObject.Execute;
    Label10.Caption := L('Processing images');
  end;
end;

procedure TFormImportingImages.BtnBreakClick(Sender: TObject);
begin
  if UpdateObject <> nil then
    UpdateObject.DoTerminate;
end;

procedure TFormImportingImages.BtnPauseClick(Sender: TObject);
begin
  if UpdateObject <> nil then
  begin
    if UpdateObject.Pause then
    begin
      UpdateObject.DoUnPause;
      BtnPause.Caption := L('Pause');
    end else
    begin
      UpdateObject.DoPause;
      BtnPause.Caption := L('Unpause');
    end;
  end;
end;

procedure TFormImportingImages.FormDestroy(Sender: TObject);
begin
  F(TimeCounter);
  DBKernel.UnRegisterChangesID(Self, ChangedDBDataByID);
end;

function TFormImportingImages.GetFormID: string;
begin
  Result := 'ImportImages';
end;

procedure TFormImportingImages.ChangedDBDataByID(Sender: TObject;
  ID: integer; params: TEventFields; Value: TEventValues);
var
  Bit: TBitmap;
  P: TPoint;
  FileSize: Integer;

  procedure FillRectToBitmapA(Bitmap: TBitmap);
  var
    C : TCanvas;
  begin
    C := Bitmap.Canvas;
    C.Pen.Color := 0;
    C.Brush.Color := MakeDarken(ClWindow, 0.9);
    C.Rectangle(0, 0, Bitmap.Width, Bitmap.Height);
    C.Pen.Color := ClWindow;
  end;

begin
  if (SetNewIDFileData in params) or (EventID_FileProcessed in params) then
    if UpdateObject.Active then
    begin
      Image3.Visible := false;
      Bit := TBitmap.Create;
      try
        Bit.PixelFormat := pf24bit;
        Bit.Assign(Value.JPEGImage);
        Bit.Width := ThSize;
        Bit.Height := ThSize;
        FillRectToBitmapA(Bit);
        Bit.Canvas.Draw(ThSize div 2 - Value.JPEGImage.Width div 2,
          ThSize div 2 - Value.JPEGImage.Height div 2, Value.JPEGImage);
        Image2.Picture.Graphic := Bit;
      finally
        F(Bit);
      end;
      Edit4.Text := Value.Name;

      Inc(ImageProcessedCounter);
      FileSize := GetFileSizeByName(Value.Name);
      ProcessingSize := ProcessingSize + FileSize;
      Label11.Caption := Format(L('Size: %s from %s'),
        [SizeInText(ProcessingSize), SizeInText(FullSize)]);
      Label12.Caption := Format(L('Processed %d from %d'),
        [ImageProcessedCounter, ImageCounter]);

      TimeCounter.NextAction(FileSize);

      Label8.Visible := true;
      Label8.Caption := Format(L('Time remaining: %s (&%%)'),
        [FormatDateTime('hh:mm:ss', TimeCounter.GetTimeRemaining)]);

      Exit;
    end;

  if EventID_Param_Add_Crypt_WithoutPass in params then
  begin
    if not CryptFileWithoutPassChecked then
    begin
      DoHelpHint(L('Warning'), L('Can''t add some files to collection because password was not found!'), P,
        Self);
    end;
  end;
end;

procedure TFormImportingImages.SetMaxValue(Value: integer);
begin
  PbMain.MaxValue := Value;
end;

procedure TFormImportingImages.SetPosition(Value: integer);
begin
  PbMain.Position := Value;
end;

procedure TFormImportingImages.OnDone(Sender: TObject);
begin
  PbMain.Position := PbMain.MaxValue;
  BtnCancel.Visible := False;
  BtnBreak.Visible := False;
  BtnPause.Visible := False;
  BtnFinish.Visible := True;
  Label8.Visible := False;
end;

procedure TFormImportingImages.BtnFinishClick(Sender: TObject);
begin
  SilentClose := True;
  Close;
end;

end.
