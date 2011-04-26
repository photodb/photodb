unit uDBImageUtils;

interface

uses
  Graphics, GraphicCrypt, uMemory, UnitDBKernel, uAssociations, SysUtils,
  RAWImage;

procedure LoadGraphic(FileName: string; var G: TGraphic; var IsEnCrypted: Boolean; var Password: string);

implementation

procedure LoadGraphic(FileName: string; var G: TGraphic; var IsEnCrypted: Boolean; var Password: string);
begin
  F(G);
  IsEnCrypted := ValidCryptGraphicFile(FileName);
  if IsEnCrypted then
  begin
    Password := DBKernel.FindPasswordForCryptImageFile(FileName);
    if PassWord = '' then
      Exit;

    G := DeCryptGraphicFile(FileName, PassWord);
  end  else
  begin
    G := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName)).Create;
    if G is TRawImage then
      TRawImage(G).IsPreview := True;

    G.LoadFromFile(FileName);
  end;
end;

end.
