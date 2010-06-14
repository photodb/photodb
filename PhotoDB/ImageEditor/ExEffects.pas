unit ExEffects;

interface

uses Effects, StdCtrls, Graphics, GraphicsBaseTypes, Forms, StrUtils, SysUtils;

type TExEffect = class(TObject)
  private
    FSetImageProc: TSetPointerToNewImage;
    FEditor: TForm;
    procedure SetSetImageProc(const Value: TSetPointerToNewImage);
    procedure SetEditor(const Value: TForm);
    { Private declarations }
  public
   constructor Create; virtual;
   destructor Destroy; override;
   class function ID : ShortString; virtual;
   function GetProperties : string; virtual;
   procedure SetProperties(Properties : string); virtual;
   function Execute(S,D : TBitmap; Panel : TGroupBox; aMakeImage : boolean) : boolean; virtual;
   function GetName : String; virtual;
   function GetBestValue : integer; virtual;
   Procedure GetPreview(S,D : TBitmap); virtual;
  published
   Property SetImageProc : TSetPointerToNewImage read FSetImageProc write SetSetImageProc;
   property Editor : TForm read FEditor write SetEditor;
   function GetValueByName(Properties, Name: string): string;
   function GetIntValueByName(Properties, Name: string; Default : integer): integer;
   function GetBoolValueByName(Properties, Name: string; Default : boolean): boolean;
   { Public declarations }
  end;

type
  TExEffectsClass = class of TExEffect;

  TExEffects = array of TExEffectsClass;

implementation

uses ImEditor, Variants;

{ TExEffect }

function TExEffect.GetValueByName(Properties, Name: string): string;
var
  str : string;
  pbegin, pend : integer;
begin
 pbegin:=Pos('[',Properties);
 pend:=PosEx(';]',Properties,pbegin);
 str:=Copy(Properties,pbegin,pend-pbegin+1);
 pbegin:=Pos(Name+'=',str)+Length(Name)+1;
 pend:=PosEx(';',str,pbegin);
 Result:=Copy(str,pbegin,pend-pbegin);
end;

constructor TExEffect.Create;
begin
end;

function TExEffect.GetBestValue : integer;
begin
 Result:=-1;
end;

function TExEffect.Execute(S, D: TBitmap; Panel: TGroupBox; aMakeImage : boolean): boolean;
begin
 result:=false;
end;

function TExEffect.GetName: String;
begin
 Result:='';
end;

procedure TExEffect.GetPreview(S, D: TBitmap);
begin
 D.Assign(S);
end;

procedure TExEffect.SetSetImageProc(const Value: TSetPointerToNewImage);
begin
  FSetImageProc := Value;
end;

procedure TExEffect.SetEditor(const Value: TForm);
begin
  FEditor := Value;
end;

destructor TExEffect.Destroy;
begin
  if EditorsManager.IsEditor(FEditor) then
  (FEditor as TImageEditor).StatusBar1.Panels[0].Text:='';
  inherited;
end;

class function TExEffect.ID: ShortString;
begin
 Result:='{005943F7-CD7E-4B79-8D1A-0489C47C85A0}';
end;

function TExEffect.GetProperties: string;
begin
 Result:='';
end;

procedure TExEffect.SetProperties(Properties: string);
begin
//
end;

function TExEffect.GetBoolValueByName(Properties, Name: string;
  Default: boolean): boolean;
var
  Val : string;
begin
 Val:=AnsiUpperCase(GetValueByName(Properties, Name));
 Result:=Default;
 if Val='TRUE' then Result:=true;
 if Val='FALSE' then Result:=false;
end;

function TExEffect.GetIntValueByName(Properties, Name: string;
  Default: integer): integer;
begin
 Result:=StrToIntDef(GetValueByName(Properties, Name),Default);
end;

end.

