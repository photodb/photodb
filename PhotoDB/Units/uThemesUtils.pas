unit uThemesUtils;

interface

uses
  uMemory,
  Themes,
  Graphics;

type
  TDatabaseTheme = class(TObject)
  private
    function GetPanelColor: TColor;
    function GetPanelFontColor: TColor;
    function GetListViewColor: TColor;
    function GetListViewFontColor: TColor;
    function GetHighlightTextColor: TColor;
    function GetHighlightColor: TColor;
    function GetEditColor: TColor;
    function GetWindowColor: TColor;
    function GetGradientFromColor: TColor;
    function GetGradientToColor: TColor;
    function GetMenuColor: TColor;
    function GetWizardColor: TColor;
    function GetListSelectedColor: TColor;
    function GetListColor: TColor;
    function GetListFontColor: TColor;
    function GetListFontSelectedColor: TColor;
    function GetComboBoxColor: TColor;
    function GetWindowTextColor: TColor;
    function GetListViewSelectedFontColor: TColor;
    function GetGradientText: TColor;
  public
    property PanelColor: TColor read GetPanelColor;
    property PanelFontColor: TColor read GetPanelFontColor;
    property ListViewColor: TColor read GetListViewColor;
    property ListViewFontColor: TColor read GetListViewFontColor;
    property ListViewSelectedFontColor: TColor read GetListViewSelectedFontColor;
    property HighlightTextColor: TColor read GetHighlightTextColor;
    property HighlightColor: TColor read GetHighlightColor;
    property EditColor: TColor read GetEditColor;
    property WindowColor: TColor read GetWindowColor;
    property WindowTextColor: TColor read GetWindowTextColor;
    property GradientFromColor: TColor read GetGradientFromColor;
    property GradientToColor: TColor read GetGradientToColor;
    property GradientText: TColor read GetGradientText;
    property MenuColor: TColor read GetMenuColor;
    property WizardColor: TColor read GetWizardColor;
    property ListSelectedColor: TColor read GetListSelectedColor;
    property ListColor: TColor read GetListColor;
    property ListFontColor: TColor read GetListFontColor;
    property ListFontSelectedColor: TColor read GetListFontSelectedColor;
    property ComboBoxColor: TColor read GetComboBoxColor;
  end;

function Theme: TDatabaseTheme;

implementation

{ Theme }

var
  FTheme: TDatabaseTheme = nil;

function Theme: TDatabaseTheme;
begin
  if FTheme = nil then
    FTheme := TDatabaseTheme.Create;

  Result := FTheme;
end;

function TDatabaseTheme.GetComboBoxColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scComboBox)
  else
    Result := clWindow;
end;

function TDatabaseTheme.GetEditColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scEdit)
  else
    Result := clWindow;
end;

{
    ListView.Selection.GradientColorTop := MakeDarken(StyleServices.GetSystemColor(clHighlight), 0.8);
    ListView.Selection.GradientColorBottom := MakeDarken(StyleServices.GetSystemColor(clHighlight), 1.2);
    ListView.Selection.TextColor := StyleServices.GetSystemColor(clHighlightText);

    {ListView.Selection.GradientColorTop := StyleServices.GetStyleColor(scGenericGradientBase);
    ListView.Selection.GradientColorBottom := StyleServices.GetStyleColor(scGenericGradientEnd);
    ListView.Selection.TextColor := StyleServices.GetStyleFontColor(sfListItemTextNormal);
}

function TDatabaseTheme.GetGradientFromColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scGenericGradientBase)
  else
    Result := clGradientActiveCaption;
end;

function TDatabaseTheme.GetGradientToColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scGenericGradientEnd)
  else
    Result := clGradientInactiveCaption;
end;

function TDatabaseTheme.GetGradientText: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleFontColor(sfWindowTextNormal)
  else
    Result := clWindowText;
end;

function TDatabaseTheme.GetHighlightColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetSystemColor(clHighlight)
  else
    Result := clHighlight;
end;

function TDatabaseTheme.GetHighlightTextColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetSystemColor(clHighlightText)
  else
    Result := clHighlightText;
end;

function TDatabaseTheme.GetListColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scListBox)
  else
    Result := clWindow;
end;

function TDatabaseTheme.GetListFontColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleFontColor(sfListItemTextNormal)
  else
    Result := clWindow;
end;

function TDatabaseTheme.GetListFontSelectedColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleFontColor(sfListItemTextSelected)
  else
    Result := clWindowText;
end;

function TDatabaseTheme.GetListSelectedColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetSystemColor(clHighlight)
  else
    Result := clHighlight;
end;

function TDatabaseTheme.GetListViewColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scListView)
  else
    Result := clWindow;
end;

function TDatabaseTheme.GetListViewFontColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleFontColor(sfListItemTextNormal)
  else
    Result := clWindowText;
end;

function TDatabaseTheme.GetListViewSelectedFontColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleFontColor(sfListItemTextSelected)
  else
    Result := clHighlightText;
end;

function TDatabaseTheme.GetMenuColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scWindow)
  else
    Result := clMenu;
end;

function TDatabaseTheme.GetPanelColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scPanel)
  else
    Result := clBtnFace;
end;

function TDatabaseTheme.GetPanelFontColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleFontColor(sfPanelTextNormal)
  else
    Result := clWindowText;
end;

function TDatabaseTheme.GetWindowColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scWindow)
  else
    Result := clWindow;
end;

function TDatabaseTheme.GetWindowTextColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleFontColor(sfWindowTextNormal)
  else
    Result := clWindowText;
end;

function TDatabaseTheme.GetWizardColor: TColor;
begin
  if StyleServices.Enabled  then
    Result := StyleServices.GetSystemColor(clWindow)
  else
    Result := clWhite;
end;

initialization

finalization
  F(FTheme);

end.
