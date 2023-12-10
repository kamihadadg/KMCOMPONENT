unit UntDBPanel;

interface

uses
   Classes, Controls, ExtCtrls,db,forms,windows;

type

  TPanelKind=(pkDataBrowse,pkDataEntry);
  TDisableEffect=(deEnable,deVisible);





  TDBPanelDataLink=class;




  TKMDBpanel = class(TPanel)
  private
    FDataLink: TDBPanelDataLink;
    FPanelKind: TPanelKind;
    FDisableEffect: TDisableEffect;
    FDisableCursor: TCursor;


//    FDataSource: TDataSource;
    procedure SetDataSource(Value: TDataSource);
    function GetDataSource: TDataSource;
    procedure SetPanelKind(const Value: TPanelKind);
    procedure SetDisableEffect(const Value: TDisableEffect);
    procedure SetDisableCursor(const Value: TCursor);


    { Private declarations }
  protected
    procedure DataChanged;
    procedure EditingChanged;
    procedure ActiveChanged;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure SetChildsEnable(VEnable : Boolean=True);
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetPanelState;
    { Public declarations }
  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property PanelKind : TPanelKind read FPanelKind write SetPanelKind;
    property DisableEffect : TDisableEffect read FDisableEffect write SetDisableEffect;
    property DisableCursor : TCursor read FDisableCursor write SetDisableCursor default crNo;
    { Published declarations }
  end;

  TDBPanelDataLink = class(TDataLink)
  private
    FDBPanel: TKMDBpanel;
  protected

    procedure EditingChanged; override;
    procedure DataSetChanged; override;
    procedure ActiveChanged; override;
  public
    constructor Create(ADBPanel: TKMDBpanel);
    destructor Destroy; override;
  end;


procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMDBpanel]);
end;

{ TDBPanelDataLink }


procedure TDBPanelDataLink.ActiveChanged;
begin
  if FDBPanel <> nil then FDBPanel.ActiveChanged;
end;

constructor TDBPanelDataLink.Create(ADBPanel: TKMDBpanel);
begin
  inherited Create;
  FDBPanel := ADBPanel;
end;

procedure TDBPanelDataLink.DataSetChanged;
begin
  if FDBPanel <> nil then FDBPanel.DataChanged;
end;

destructor TDBPanelDataLink.Destroy;
begin
  FDBPanel := nil;
  inherited Destroy;
end;

procedure TDBPanelDataLink.EditingChanged;
begin
  if FDBPanel <> nil then FDBPanel.EditingChanged;
end;

{ TKMDBpanel }


procedure TKMDBpanel.ActiveChanged;
begin
	SetPanelState;
end;

constructor TKMDBpanel.Create(AOwner: TComponent);
begin
  inherited;
  FDataLink := TDBPanelDataLink.Create(Self);
  FPanelKind:=pkDataBrowse;
  FDisableEffect:=deEnable;
  FDisableCursor:=crNo;    
end;

procedure TKMDBpanel.DataChanged;
begin
	SetPanelState;
end;

destructor TKMDBpanel.Destroy;
begin
  FDataLink.Free; 
  inherited;
end;

procedure TKMDBpanel.EditingChanged;
begin
	SetPanelState;
end;

function TKMDBpanel.GetDataSource: TDataSource;
begin
  Result:=FDataLink.DataSource;
end;

procedure TKMDBpanel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TKMDBpanel.SetChildsEnable(VEnable: Boolean);
var
	VCoIdx : integer;
begin
	for VCoIdx :=0 to self.ControlCount-1 do begin
       Controls[VCoIdx].Enabled:=VEnable;
   end;
end;  

procedure TKMDBpanel.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if not (csLoading in ComponentState) then ActiveChanged;
  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TKMDBpanel.SetDisableCursor(const Value: TCursor);
begin
  FDisableCursor := Value;
end;

procedure TKMDBpanel.SetDisableEffect(const Value: TDisableEffect);
begin
  FDisableEffect := Value;
  SetChildsEnable;
 // Enabled:=True ;
  if Assigned(FDataLink.DataSource) then
  SetPanelState;
end;

procedure TKMDBpanel.SetPanelKind(const Value: TPanelKind);
begin
  FPanelKind := Value;
end;

procedure TKMDBpanel.SetPanelState;
begin
   if DataSource.DataSet.State=dsBrowse then begin
      if FPanelKind=pkDataBrowse then begin
          if FDisableEffect=deEnable then begin
            SetChildsEnable(True);
            // Enabled:=true;
          end else begin
			 	 Visible:=True;
          end;
          Cursor:=crDefault;
      end else begin
          if FDisableEffect=deEnable then begin
             SetChildsEnable(false);
             //Enabled:=false;
          end else begin
			 	 Visible:=False;
          end;
			 Cursor:=FDisableCursor;
      end;
   end else begin
      if FPanelKind=pkDataBrowse then begin
          if FDisableEffect=deEnable then begin
             SetChildsEnable(False);
            // Enabled:=False ;
          end else begin
			 	 Visible:=False;
          end;
			 Cursor:=FDisableCursor;
      end else begin
          if FDisableEffect=deEnable then begin
             SetChildsEnable(True);
            // Enabled:=true ;
          end else begin
			 	 Visible:=True;
          end;
          Cursor:=crDefault;
      end;
   end;
end;

end.
