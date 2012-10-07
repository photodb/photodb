unit ConsoleOoutput;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Forms;

function GetDosOutput(const CommandLine, Directory: string): string;

implementation

function GetDosOutput(const CommandLine, Directory: string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir, Line: string;
begin
  with SA do
  begin
    nLength := SizeOf(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  // созда¸м пайп для перенаправления стандартного вывода
  CreatePipe(StdOutPipeRead, // дескриптор чтения
    StdOutPipeWrite, // дескриптор записи
    @SA, // аттрибуты безопасности
    0 // количество байт принятых для пайпа - 0 по умолчанию
    );
  try
    // Созда¸м дочерний процесс, используя StdOutPipeWrite в качестве стандартного вывода,
    // а так же проверяем, чтобы он не показывался на экране.
    with SI do
    begin
      FillChar(SI, SizeOf(SI), 0);
      cb := SizeOf(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // стандартный ввод не перенаправляем
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;

    // Запускаем компилятор из командной строки
    WorkDir := ExtractFilePath(Directory);
    WasOK := CreateProcess(nil, PChar(CommandLine), nil, nil, True, 0, nil, PChar(WorkDir), SI, PI);

    // Теперь, когда дескриптор получен, для безопасности закрываем запись.
    // Нам не нужно, чтобы произошло случайное чтение или запись.
    CloseHandle(StdOutPipeWrite);
    // если процесс может быть создан, то дескриптор, это его вывод
    if not WasOK then
      raise Exception.Create('Could not execute command line!')
    else
    try
        // получаем весь вывод до тех пор, пока DOS-приложение не будет завершено
      Line := '';
      repeat
          // читаем блок символов (могут содержать возвраты каретки и переводы строки)
        WasOK := ReadFile(StdOutPipeRead, Buffer, 1, BytesRead, nil);

          // есть ли что-нибудь ещ¸ для чтения?
        if BytesRead > 0 then
        begin
            // завершаем буфер PChar-ом
          Buffer[BytesRead] := #0;
            // добавляем буфер в общий вывод
          Line := Buffer;
          Write(Line);
        end;
      until not WasOK or (BytesRead = 0);
        // жд¸м, пока завершится консольное приложение
      WaitForSingleObject(PI.hProcess, INFINITE);
    finally
        // Закрываем все оставшиеся дескрипторы
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
    end;
  finally
    result := Line;
    CloseHandle(StdOutPipeRead);
  end;
end;

end.
