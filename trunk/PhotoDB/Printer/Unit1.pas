unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ScrollingImage, ScrollingImageAddons, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses PrintMainForm;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
 files : TStrings;
begin
 files := TStringList.Create;
  Files.Add('D:\Dmitry\My Pictures\806690  Шурэло - Танго белого слона.jpg');
 Files.Add('D:\Dmitry\My Pictures\769150 Alexandr Zadiraka - вечер.jpg');
 Files.Add('D:\Dmitry\My Pictures\796283 без названия - без названия.jpg');
 Files.Add('D:\Dmitry\My Pictures\808138 фшксщдщк - только 2 слова всего.jpg');
{ Files.Add('D:\Dmitry\My Pictures\808709 Ira Bordo - ---.jpg');
 Files.Add('D:\Dmitry\My Pictures\815206 HALFMAX - Мой Пушкин..jpg');
 Files.Add('D:\Dmitry\My Pictures\815794  Павел Киселев - весенние побеги.jpg');
 Files.Add('D:\Dmitry\My Pictures\815903 igor vorobey - MADE IN CHINA.jpg');
 Files.Add('D:\Dmitry\My Pictures\769150 Alexandr Zadiraka - вечер.jpg');
 Files.Add('D:\Dmitry\My Pictures\796283 без названия - без названия.jpg');
 Files.Add('D:\Dmitry\My Pictures\806690  Шурэло - Танго белого слона.jpg');
 Files.Add('D:\Dmitry\My Pictures\808138 фшксщдщк - только 2 слова всего.jpg');
 Files.Add('D:\Dmitry\My Pictures\808709 Ira Bordo - ---.jpg');
 Files.Add('D:\Dmitry\My Pictures\815206 HALFMAX - Мой Пушкин..jpg');
 Files.Add('D:\Dmitry\My Pictures\815794  Павел Киселев - весенние побеги.jpg');
 Files.Add('D:\Dmitry\My Pictures\815903 igor vorobey - MADE IN CHINA.jpg');
 Files.Add('D:\Dmitry\My Pictures\769150 Alexandr Zadiraka - вечер.jpg');
 Files.Add('D:\Dmitry\My Pictures\796283 без названия - без названия.jpg');
 Files.Add('D:\Dmitry\My Pictures\806690  Шурэло - Танго белого слона.jpg');
 Files.Add('D:\Dmitry\My Pictures\808138 фшксщдщк - только 2 слова всего.jpg');
 Files.Add('D:\Dmitry\My Pictures\808709 Ira Bordo - ---.jpg');
 Files.Add('D:\Dmitry\My Pictures\815206 HALFMAX - Мой Пушкин..jpg');
 Files.Add('D:\Dmitry\My Pictures\815794  Павел Киселев - весенние побеги.jpg');
 Files.Add('D:\Dmitry\My Pictures\815903 igor vorobey - MADE IN CHINA.jpg'); 

 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292073.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292036.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292043.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292049.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292061.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292068.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292070.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292083.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292086.JPG');
 Files.Add('D:\Dmitry\My Pictures\Photoes\05.03.29 = 29 марта 2005 г. (Оля, парк)\P3292093.JPG'); }
 GetPrintForm(Files);

// PrintForm.Execute(Files);
// PrintForm.show;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
pic : Tpicture;
bit : Tbitmap;
begin
pic := Tpicture.create;
pic.LoadFromFile('D:\Dmitry\My Pictures\808709 Ira Bordo - ---.jpg');
bit := Tbitmap.Create;
bit.PixelFormat:=pf24bit;
bit.Assign(pic.Graphic);
pic.free;
GetPrintForm(bit);
end;

end.
