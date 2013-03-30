unit uCollectionEvents;

interface

uses
  System.Classes,
  System.SysUtils,

  UnitDBDeclare,

  uMemory,
  uDBForm;

type
  DBChangesIDEvent = procedure(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues) of object;

type
  DBEventsIDArray = record
    Sender: TObject;
    IDs: Integer;
    DBChangeIDArrayesEvents: DBChangesIDEvent;
  end;

type
  TDBEventsIDArray = array of DBEventsIDArray;

  TCollectionEvents = class
  private
    FEvents: TDBEventsIDArray;
  public
    procedure UnRegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
    procedure UnRegisterChangesIDByID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
    procedure RegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
    procedure RegisterChangesIDbyID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
    procedure DoIDEvent(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues);
  end;

function CollectionEvents: TCollectionEvents;

implementation

var
  FCollectionEvents: TCollectionEvents = nil;

function CollectionEvents: TCollectionEvents;
begin
  if FCollectionEvents = nil then
    FCollectionEvents := TCollectionEvents.Create;

  Result := FCollectionEvents;
end;

procedure TCollectionEvents.UnRegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
var
  I, J: Integer;
begin
  if Length(Fevents) = 0 then
    Exit;
  for I := 0 to Length(Fevents) - 1 do
  begin
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = -1) and (Sender = Fevents[I].Sender) then
    begin
      for J := I to Length(Fevents) - 2 do
        Fevents[J] := Fevents[J + 1];
      SetLength(Fevents, Length(Fevents) - 1);
      Break;
    end;
  end;
end;

procedure TCollectionEvents.UnRegisterChangesIDByID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
var
  I, J: Integer;
begin
  if Length(Fevents) = 0 then
    Exit;
  for I := 0 to Length(Fevents) - 1 do
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = Id) and (Sender = Fevents[I].Sender) then
    begin
      for J := I to Length(Fevents) - 2 do
        Fevents[J] := Fevents[J + 1];
      SetLength(Fevents, Length(Fevents) - 1);
      Break;
    end;
end;

procedure TCollectionEvents.DoIDEvent(Sender: TDBForm; ID: Integer; Params: TEventFields; Value: TEventValues);
begin
  if Sender = nil then
    raise Exception.Create('Sender is null!');

  TThread.Synchronize(nil,
    procedure
    var
      I: Integer;
      FXevents: TDBEventsIDArray;
    begin

      if Length(Fevents) = 0 then
        Exit;

      SetLength(FXevents, Length(Fevents));
      for I := 0 to Length(Fevents) - 1 do
        FXevents[I] := Fevents[I];
      for I := 0 to Length(FXevents) - 1 do
      begin
        if FXevents[I].Ids = -1 then
        begin
          if Assigned(FXevents[I].DBChangeIDArrayesEvents) then
            FXevents[I].DBChangeIDArrayesEvents(Sender, ID, Params, Value)
        end else
        begin
          if FXevents[I].Ids = ID then
          begin
            if Assigned(FXevents[I].DBChangeIDArrayesEvents) then
              FXevents[I].DBChangeIDArrayesEvents(Sender, ID, Params, Value)
          end;
        end;
      end;


    end
  );
end;

procedure TCollectionEvents.RegisterChangesID(Sender: TObject; Event_: DBChangesIDEvent);
var
  I: Integer;
  Is_: Boolean;
begin
  Is_ := False;
  for I := 0 to Length(Fevents) - 1 do
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = -1) and (Sender = Fevents[I].Sender) then
    begin
      Is_ := True;
      Break;
    end;
  if not Is_ then
  begin
    Setlength(Fevents, Length(Fevents) + 1);
    Fevents[Length(Fevents) - 1].Ids := -1;
    Fevents[Length(Fevents) - 1].Sender := Sender;
    Fevents[Length(Fevents) - 1].DBChangeIDArrayesEvents := Event_;
  end;
end;

procedure TCollectionEvents.RegisterChangesIDByID(Sender: TObject; Event_: DBChangesIDEvent; Id: Integer);
var
  I: Integer;
  Is_: Boolean;
begin
  Is_ := False;
  for I := 0 to Length(Fevents) - 1 do
    if (@Fevents[I].DBChangeIDArrayesEvents = @Event_) and (Fevents[I].Ids = Id) and (Sender = Fevents[I].Sender) then
    begin
      Is_ := True;
      Break;
    end;
  if not Is_ then
  begin
    Setlength(Fevents, Length(Fevents) + 1);
    Fevents[Length(Fevents) - 1].Ids := Id;
    Fevents[Length(Fevents) - 1].Sender := Sender;
    Fevents[Length(Fevents) - 1].DBChangeIDArrayesEvents := Event_;
  end;
end;

initialization
finalization
  F(FCollectionEvents);

end.
