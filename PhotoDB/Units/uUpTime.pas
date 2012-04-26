unit uUpTime;

interface

uses
  uSettings,
  SysUtils,
  Classes,
  uMemory,
  uConfiguration;

procedure AddUptimeSecs(Secs: Integer);
procedure PermanentlySaveUpTime;
function GetCurrentUpTime: Integer;

implementation

procedure AddUptimeSecs(Secs: Integer);
var
  Time: Integer;
begin
  Time := Settings.ReadInteger('Options', 'UpTime', 0);
  Settings.WriteInteger('Options', 'UpTime', Time + Secs);
end;

procedure PermanentlySaveUpTime;
var
  FileName: string;
  FS: TFileStream;
  SW: TStreamWriter;
  Time: Integer;
begin
  FileName := GetAppDataDirectory + '\uptime.dat';

  Time := GetCurrentUpTime;
  try
    FS := TFileStream.Create(FileName, fmCreate);
    try
      SW := TStreamWriter.Create(FS);
      try
        SW.Write(IntToStr(Time));
        Settings.WriteInteger('Options', 'UpTime', 0);
      finally
        F(SW);
      end;
    finally
      F(FS);
    end;
  except
   //don't throw any exception
  end;
end;

function GetCurrentUpTime: Integer;
var
  FS: TFileStream;
  SR: TStreamReader;
  FileName, S: string;
begin
  FileName := GetAppDataDirectory + '\uptime.dat';
  Result := Settings.ReadInteger('Options', 'UpTime', 0);
  try
    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      SR := TStreamReader.Create(FS);
      try
        S := SR.ReadToEnd;
        Result := Result + StrToIntDef(S, 0);
      finally
        F(SR);
      end;
    finally
      F(FS);
    end;
  except
   //don't throw any exception
  end;
end;

end.
