unit uDBUtils;

interface

uses
  WIndows, SysUtils, Jpeg, Dolphin_DB, UnitGroupsWork, uTranslate, uLogger;

procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory: string);
procedure CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory : string);

implementation

procedure CreateExampleDB(FileName, IcoName, CurrentImagesDirectory: string);
begin
  if not DBKernel.TestDB(FileName) then
    DBKernel.CreateDBbyName(FileName);

  CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory);
end;

procedure CreateExampleGroups(FileName, IcoName, CurrentImagesDirectory : string);
var
  NewGroup : TGroup;
begin
  if not IsValidGroupsTableW(FileName) then
  begin
    if FileExists(CurrentImagesDirectory + 'Images\Me.jpg') then
    begin
      try
        NewGroup.GroupName := GetWindowsUserName;
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory + 'Images\Me.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := NewGroup.GroupName;
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
  if FileExists(CurrentImagesDirectory + 'Images\Friends.jpg') then
    begin
      try
        NewGroup.GroupName := TA('Friends', 'Groups');
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory + 'Images\Friends.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := TA('Friends', 'Groups');
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
    if FileExists(CurrentImagesDirectory + 'Images\Family.jpg') then
    begin
      try
        NewGroup.GroupName := TA('Family', 'Groups');
        NewGroup.GroupCode := CreateNewGroupCode;
        NewGroup.GroupImage := TJPEGImage.Create;
        try
          NewGroup.GroupImage.LoadFromFile(CurrentImagesDirectory + 'Images\Family.jpg');
          NewGroup.GroupDate := Now;
          NewGroup.GroupComment := '';
          NewGroup.GroupFaces := '';
          NewGroup.GroupAccess := 0;
          NewGroup.GroupKeyWords := TA('Family', 'Groups');
          NewGroup.AutoAddKeyWords := True;
          NewGroup.RelatedGroups := '';
          NewGroup.IncludeInQuickList := True;
          AddGroupW(NewGroup, FileName);
        finally
          NewGroup.GroupImage.Free;
        end;
      except
        on E: Exception do
          EventLog(':CreateExampleDB() throw exception: ' + E.message);
      end;
    end;
  end;
end;

end.
