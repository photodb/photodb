unit uMachMask; // © Alexandr Petrovich Sysoev

interface

uses
  Classes;

/// ////////////////////////////////////////////////// Работа со списком шаблонов
// Функции предназначены для сопоставления текстов (имен файлов) на
// соответствие заданному шаблону или списку шаблонов.
// Обычно используется для посторения простых фильтров, например аналогичных
// файловым фильтрам программы Total Commander.
//
// Каждый шаблон аналогичен шаблону имен файлов в MS-DOS и MS Windows,
// т.е. может включать "шаблонные" символы '*' и '?' и не может включать
// символ '|'.
// Любой шаблон может быть заключен в двойные кавычки ('''), при этом двойные
// кавычки имеющиеся в шаблоне должны быть удвоены. Если шаблон включает
// символы ';' или ' ' (пробел) то он обязательно должен быть заключен в
// двойные кавычки.
// В списке, шаблоны разделяются символом ';'.
// За первым списком шаблонов, может следовать символ '|', за которым может
// следовать второй список.
// Текст (имя файла) будет считаться соответствующим списку шаблонов только
// если он соответствует хотя бы одному шаблону из первого списка,
// и не соответствует ни одному шаблону из второго списка.
// Если первый список пуст, то подразумевается '*'
//
// Формальное описание синтаксиса списка шаблонов:
//
// Полный список шаблонов      :: [<список включаемых шаблонов>]['|'<список исключаемых шаблонов>]
// список включаемых шаблонов  :: <список шаблонов>
// список исключаемых шаблонов :: <список шаблонов>
// список шаблонов             :: <шаблон>[';'<шаблон>]
// шаблон                      :: шаблон аналогичный шаблону имен файлов в
// MS-DOS и MS Windows, т.е. может включать
// "шаблонные" символы '*' и '?' и не может
// включать символ '|'. Шаблон может быть
// заключен в двойные кавычки (''') при этом
// двойные кавычки имеющиеся в шаблоне должны
// быть удвоены. Если шаблон включает символы
// ';' или ' ' (пробел) то он
// обязательно должен быть заключен в двойные
// кавычки.
//
// Например:
// '*.ini;*.wav'          - соответствует любым файлам с расшиениями 'ini'
// или 'wav'
// '*.*|*.exe'            - соответствует любым файлам, кроме файлов с
// расширением 'EXE'
// '*.mp3;*.wav|?.*;??.*' - соответствует любым файлам с расшиениями 'mp3'
// и 'wav' за исключением файлов у которых имя
// состоит из одного или двух символов.
// '|awString.*'          - соответствует любым файлам за исключением файлов
// с именем awString и любым расширением.
//

function IsMatchMask(AText, AMask: PChar): Boolean; overload;
function IsMatchMask(AText, AMask: string; AFileNameMode: Boolean = True): Boolean; overload;
// Выполняют сопоставление текста aText с одним шаблоном aMask.
// Возвращает True если сопоставление выполнено успешно, т.е. текст
// aText соответствует шаблону aMask.
// Если aFileNameModd=True, то объект используется для сопоставления
// имен файлов с шаблоном. А именно, в этом случае, если aText не
// содержит символа '.' то он добавляется в конец. Это необходимо для
// того, чтобы файлы без расширений соответствовали например шаблону '*.*'

function IsMatchMaskList(AText, AMaskList: string; AFileNameMode: Boolean = True): Boolean;
// Выполняет сопоставление текста aText со списком шаблонов aMaskList.
// Возвращает True если сопоставление выполнено успешно, т.е. текст
// aText соответствует списку шаблонов aMaskList.
// Если aFileNameModd=True, то объект используется для сопоставления
// имен файлов с шаблоном. А именно, в этом случае, если aText не
// содержит символа '.' то он добавляется в конец. Это необходимо для
// того, чтобы файлы без расширений соответствовали например шаблону '*.*'
//
// Замечание, если требуется проверка сопоставления нескольких строк одному
// списку шаблонов, эффективнее будет воспользоваться объектом tMatchMaskList.

type
  TMatchMaskList = class(TObject)
  private
    FMaskList: string;
    FCaseSensitive: Boolean;
    FFileNameMode: Boolean;

    FPrepared: Boolean;
    FIncludeMasks: TStringList;
    FExcludeMasks: TStringList;

    procedure SetMaskList(V: string);
    procedure SetCaseSensitive(V: Boolean);

  public
    constructor Create(const AMaskList: string = '');
    // Создает объект. Если задан параметр aMaskList, то он присваивается
    // свойству MaskList.

    destructor Destroy; override;
    // Разрушает объект

    procedure PrepareMasks;
    // Осуществляет компиляцию списка шаблонов во внутреннюю структуру
    // используемую при сопоставлении текста.
    // Вызов данного метода не является обязательным и при необходимости
    // будет вызван автоматически.

    function IsMatch(AText: string): Boolean;
    // Выполняет сопоставление текста aText со списком шаблонов MaskList.
    // Возвращает True если сопоставление выполнено успешно, т.е. текст
    // aText соответствует списку шаблонов MaskList.

    property MaskList: string read FMaskList write SetMaskList;
    // Списко шаблонов используемый для сопоставления с текстом

    property CaseSensitive: Boolean read FCaseSensitive write SetCaseSensitive default False;
    // Если False (по умолчанию), то при сопоставлении текста будет
    // регистр символов не будет учитываться.
    // Иначе, если True, сопоставление будет проводиться с учетом регистра.

    property FileNameMode: Boolean read FFileNameMode write FFileNameMode default True;
    // Если True (по умолчанию), то объект используется для сопоставления
    // имен файлов с шаблоном. А именно, в этом случае, если aText не
    // содержит символа '.' то он добавляется в конец. Это необходимо для
    // того, чтобы файлы без расширений соответствовали например шаблону '*.*'

  end;

implementation

uses
  SysUtils;

function IsMatchMask(AText, AMask: PChar): Boolean; overload;
begin
  Result := False;
  while True do
  begin
    case AMask^ of
      '*': // соответствует любому числу любых символов кроме конца строки
        begin
          // переместиться на очередной символ шаблона, при этом, подряд
          // идущие '*' эквивалентны одному, поэтому пропуск всех '*'
          repeat
            Inc(AMask);
          until (AMask^ <> '*');
          // если за '*' следует любой символ кроме '?' то он должен совпасть
          // с символом в тексте. т.е. нужно пропустить все не совпадающие,
          // но не далее конца строки
          if AMask^ <> '?' then
            while (AText^ <> #0) and (AText^ <> AMask^) do
              Inc(AText);

          if AText^ <> #0 then
          begin // не конец строки, значит совпал символ
            // '*' 'жадный' шаблон поэтому попробуем отдать совпавший символ
            // ему. т.е. проверить совпадение продолжения строки с шаблоном,
            // начиная с того-же '*'. если продолжение совпадает, то
            if IsMatchMask(AText + 1, AMask - 1) then
              Break; // это СОВПАДЕНИЕ
            // продолжение не совпало, значит считаем что здесь закончилось
            // соответствие '*'. Продолжим сопоставление со следующего
            // символа шаблона
            Inc(AMask);
            Inc(AText); // иначе переходим к следующему символу
          end
          else if (AMask^ = #0) then // конец строки и конец шаблона
            Break // это СОВПАДЕНИЕ
          else // конец строки но не конец шаблона
            Exit // это НЕ СОВПАДЕНИЕ
        end;

      '?': // соответствует любому кроме конца строки
        if (AText^ = #0) then // конец строки
          Exit // это НЕ СОВПАДЕНИЕ
        else
        begin // иначе
          Inc(AMask);
          Inc(AText); // иначе переходим к следующему символу
        end;

    else // символ в шаблоне должен совпасть с символом в строке
      if AMask^ <> AText^ then // символы не совпали -
        Exit // это НЕ СОВПАДЕНИЕ
      else
      begin // совпал очередной символ
        if (AMask^ = #0) then // совпавший символ последний -
          Break; // это СОВПАДЕНИЕ
        Inc(AMask);
        Inc(AText); // иначе переходим к следующему символу
      end;
    end;
  end;
  Result := True;
end;

function IsMatchMask(AText, AMask: string; AFileNameMode: Boolean = True): Boolean; overload;
begin
  if AFileNameMode and (Pos('.', AText) = 0) then
    AText := AText + '.';
  Result := IsMatchMask(PChar(AText), PChar(AMask));
end;

function IsMatchMaskList(AText, AMaskList: string; AFileNameMode: Boolean = True): Boolean;
begin
  with TMatchMaskList.Create(AMaskList) do
    try
      FileNameMode := AFileNameMode;
      Result := IsMatch(AText);
    finally
      Free;
    end;
end;

/// //////////////////////////////////////////////////////// tFileMask

procedure TMatchMaskList.SetMaskList(V: string);
begin
  if FMaskList = V then
    Exit;
  FMaskList := V;
  FPrepared := False;
end;

procedure TMatchMaskList.SetCaseSensitive(V: Boolean);
begin
  if FCaseSensitive = V then
    Exit;
  FCaseSensitive := V;
  FPrepared := False;
end;

constructor TMatchMaskList.Create(const AMaskList: string);
begin
  MaskList := AMaskList;
  FFileNameMode := True;

  FIncludeMasks := TStringList.Create;
  with FIncludeMasks do
  begin
    Delimiter := ';';
    // Sorted     := True;
    // Duplicates := dupIgnore;
  end;

  FExcludeMasks := TStringList.Create;
  with FExcludeMasks do
  begin
    Delimiter := ';';
    // Sorted     := True;
    // Duplicates := dupIgnore;
  end;
end;

destructor TMatchMaskList.Destroy;
begin
  FIncludeMasks.Free;
  FExcludeMasks.Free;
end;

procedure TMatchMaskList.PrepareMasks;

  procedure CleanList(L: TStrings);
  var
    I: Integer;
  begin
    for I := L.Count - 1 downto 0 do
      if L[I] = '' then
        L.Delete(I);
  end;

var
  S: string;
  I: Integer;
begin
  if FPrepared then
    Exit;

  if CaseSensitive then
    S := MaskList
  else
    S := UpperCase(MaskList);

  I := Pos('|', S);
  if I = 0 then
  begin
    FIncludeMasks.DelimitedText := S;
    FExcludeMasks.DelimitedText := '';
  end
  else
  begin
    FIncludeMasks.DelimitedText := Copy(S, 1, I - 1);
    FExcludeMasks.DelimitedText := Copy(S, I + 1, MaxInt);
  end;

  CleanList(FIncludeMasks);
  CleanList(FExcludeMasks);

  // если список включаемых шаблонов пуст а
  // список исключаемых шаблонов не пуст, то
  // имеется ввиду что список включаемых шаблонов равен <все файлы>
  if (FIncludeMasks.Count = 0) and (FExcludeMasks.Count <> 0) then
    FIncludeMasks.Add('*');

  FPrepared := True;
end;

function TMatchMaskList.IsMatch(AText: string): Boolean;
var
  I: Integer;
begin
  Result := False;

  if AText = '' then
    Exit;

  if not CaseSensitive then
    AText := UpperCase(AText);

  if FileNameMode and (Pos('.', AText) = 0) then
    AText := AText + '.';

  if not FPrepared then
    PrepareMasks;

  // поиск в списке "включаемых" масок до первого совпадения
  for I := 0 to FIncludeMasks.Count - 1 do
    if IsMatchMask(PChar(AText), PChar(FIncludeMasks[I])) then
    begin
      Result := True;
      Break;
    end;

  // если совпадение найдено, надо проверить по списку "исключаемых"
  if Result then
    for I := 0 to FExcludeMasks.Count - 1 do
      if IsMatchMask(PChar(AText), PChar(FExcludeMasks[I])) then
      begin
        Result := False;
        Break;
      end;
end;

end.
