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
  public
    property PanelColor: TColor read GetPanelColor;
    property PanelFontColor: TColor read GetPanelFontColor;
    property ListViewColor: TColor read GetListViewColor;
    property ListViewFontColor: TColor read GetListViewFontColor;
    property HighlightTextColor: TColor read GetHighlightTextColor;
    property HighlightColor: TColor read GetHighlightColor;
    property EditColor: TColor read GetEditColor;
    property WindowColor: TColor read GetWindowColor;
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

function TDatabaseTheme.GetEditColor: TColor;
begin
  if StyleServices.Enabled then
    Result := StyleServices.GetStyleColor(scEdit)
  else
    Result := clWindow;
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
    Result := ClBtnFace;
end;

initialization

finalization
  F(FTheme);

end.
