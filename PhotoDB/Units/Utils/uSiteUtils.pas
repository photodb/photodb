unit uSiteUtils;

interface

uses
  Winapi.Windows,
  Winapi.ShellApi,
  System.SysUtils,

  Dmitry.Utils.System,

  uConstants,
  uTranslate,
  uActivationUtils,
  uUpTime;

procedure DoHelp;
procedure DoHomeContactWithAuthor;
procedure DoHomePage;
procedure DoBuyApplication;
procedure DoDonate;
function GenerateProgramSiteParameters: string;

implementation

function GenerateProgramSiteParameters: string;
begin
  Result := '?v=' + ProductVersion + '&ac=' + TActivationManager.Instance.ApplicationCode + '&ut=' + IntToStr(GetCurrentUpTime);
end;

procedure DoHelp;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(HomePageURL) + '?mode=help'), nil, nil, SW_NORMAL);
end;

procedure DoHomePage;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(HomePageURL)), nil, nil, SW_NORMAL);
end;

procedure DoHomeContactWithAuthor;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar('mailto:' + ProgramMail + '?subject=''''' + ProductName + ''''''), nil, nil, SW_NORMAL);
end;

procedure DoBuyApplication;
var
  BuyUrl: string;
begin
  BuyUrl := ResolveLanguageString(BuyPageURL) + GenerateProgramSiteParameters;
  ShellExecute(GetActiveWindow, 'open', PWideChar(BuyUrl), nil, nil, SW_NORMAL);
end;

procedure DoDonate;
begin
  ShellExecute(GetActiveWindow, 'open', PWideChar(ResolveLanguageString(DonateURL)), nil, nil, SW_NORMAL);
end;

end.
