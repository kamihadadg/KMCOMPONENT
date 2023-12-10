unit UntDBBtn;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls,
  cxLookAndFeelPainters, cxButtons, Buttons,DB,forms;
type
  TClickAction=(caNone,caInsert,caEdit,caDelete,caPost,caCancel,caFirst,caPrior,caNext,caLast,caRefresh);

  TKMDBBitBtnDataLink=class;

  TKMDBBtn = class(TcxButton)
  private
    { Private declarations }
    FDataLink: TKMDBBitBtnDataLink;
    FClickAction: TClickAction;
    FLetDataSetControlEnable: Boolean;
    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    procedure SetClickAction(const Value: TClickAction);
    procedure SetLetDataSetControlEnable(const Value: Boolean);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure ChekEnable;

    { Protected declarations }
  public
    procedure Click; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  published
    { Published declarations }
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ClickAction : TClickAction read FClickAction write SetClickAction default caNone;
    property LetDataSetControlEnable : Boolean read FLetDataSetControlEnable write SetLetDataSetControlEnable;
  end;

  TKMDBBitBtnDataLink = class(TDataLink)
  private
    FTssButton: TKMDBBtn;
  protected
    procedure EditingChanged; override;
    procedure DataSetChanged; override;
    procedure ActiveChanged; override;

  public
    constructor Create(ATSSButton: TKMDBBtn);
    destructor Destroy; override;
  end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMDBBtn]);
end;
Const
    TCaptions: array [TClickAction] of string= ('','ÃœÌœ','ÊÌ—«Ì‘','Õ–›','À» ','«‰’—«›','«Ê·Ì‰','ﬁ»·Ì','»⁄œÌ','¬Œ—Ì‰','œÊ»«—Â ”«“Ì');
    TGlyphs: array [TClickAction] of string= ('','DBBIT_Insert','DBBIT_Edit','DBBIT_Delete','DBBIT_Post','DBBIT_Cancel','DBBIT_First','DBBIT_Prior','DBBIT_Next','DBBIT_Last','DBBIT_REFRESH');
    TNumGlyphs : array [TClickAction] of Byte= (2,2,2,2,2,2,1,1,1,1,2);
{ TKMDBBitBtnDataLink }

procedure TKMDBBitBtnDataLink.ActiveChanged;
begin
  if FTssButton <> nil then FTssButton.ChekEnable;
end;

constructor TKMDBBitBtnDataLink.Create(ATSSButton: TKMDBBtn);
begin
  inherited Create;
  FTssButton := ATSSButton;
end;

procedure TKMDBBitBtnDataLink.DataSetChanged;
begin
  if FTssButton <> nil then FTssButton.ChekEnable;
end;

destructor TKMDBBitBtnDataLink.Destroy;
begin
  FTssButton := nil;
  inherited Destroy;
end;

procedure TKMDBBitBtnDataLink.EditingChanged;
begin
  if FTssButton <> nil then FTssButton.ChekEnable;
end;

{ TTSSDBBitBtn }

procedure TKMDBBtn.ChekEnable;
begin
   // Do not remove this else will have error!!!
   //Application.ProcessMessages;
   //
   if FLetDataSetControlEnable and(FClickAction<>caNone) then
   if FDataLink.DataSource<>nil then
   if FDataLink.DataSource.DataSet<>nil then
   if FDataLink.DataSource.DataSet.Active then begin
      if FDataLink.DataSource.DataSet.State=dsBrowse then begin
         with FDataLink.DataSource.DataSet do begin
            case ClickAction of
              caInsert,caRefresh:Enabled:=True;
              caDelete,caEdit:Enabled:=Not (Bof and Eof);
              caPrior,caFirst:Enabled:=Not FDataLink.DataSource.DataSet.Bof;
              caLast,caNext:  Enabled:=Not FDataLink.DataSource.DataSet.Eof;
              caPost,caCancel : Enabled:=False;
            end;
         end;
      end else begin
         if (FDataLink.DataSource.DataSet.State=dsInsert)or(FDataLink.DataSource.DataSet.State=dsEdit) then begin
            case ClickAction of
               caInsert,caEdit,caDelete,caFirst,caPrior,caNext,caLast,caRefresh :Enabled:=False;
               caPost,caCancel:Enabled:=True;
            end;
         end;
      end;
   end;
end;

procedure TKMDBBtn.Click;
begin
 if Assigned(OnClick) then begin
     inherited Click;
 end else begin
    if (FClickAction<>caNone)and Assigned(FDataLink.DataSource) then
    if Assigned(FDataLink.DataSource.DataSet) then
    if FDataLink.DataSource.DataSet.Active then begin
        if FDataLink.DataSource.DataSet.State=dsBrowse then begin
           with FDataLink.DataSource.DataSet do begin
              case ClickAction of
                caInsert:Append ;
                caEdit:Edit ;
                caDelete:Delete;
                caFirst:First;
                caPrior:Prior;
                caNext:Next;
                caLast:Last;
                caRefresh:Refresh;
              end;
           end;
        end else begin
           if (FDataLink.DataSource.DataSet.State=dsEdit) OR (FDataLink.DataSource.DataSet.State=dsInsert) then begin
              case ClickAction of
                caPost:FDataLink.DataSource.DataSet.Post ;
                caCancel:FDataLink.DataSource.DataSet.Cancel;
              end;
           end;
        end;
    end;
 end;
end;

constructor TKMDBBtn.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TKMDBBitBtnDataLink.Create(Self);
    FClickAction:=caNone;
    FLetDataSetControlEnable:=False;
    ShowHint:=True; 
end;

destructor TKMDBBtn.Destroy;
begin
  FDataLink.Free;  
  inherited;
end;

function TKMDBBtn.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;


procedure TKMDBBtn.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TKMDBBtn.SetClickAction(const Value: TClickAction);
begin
  FClickAction := Value;
  if (csDesigning in ComponentState)and not(csloading in ComponentState) then
  if Value=caNone then begin
    FLetDataSetControlEnable:=False;
    Glyph:=nil;
    Caption:='?';
    Enabled:=True
  end else begin
    FLetDataSetControlEnable:=True;
    Caption:=TCaptions[value];
    Hint:=Caption; 
    Glyph.LoadFromResource(HInstance,TGlyphs[Value],'');
    NumGlyphs:=TNumGlyphs[Value];

    ChekEnable;
  end;
end;

procedure TKMDBBtn.SetDataSource(const Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if not (csLoading in ComponentState) then ChekEnable;
  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TKMDBBtn.SetLetDataSetControlEnable(const Value: Boolean);
begin
  FLetDataSetControlEnable := Value;
end;

end.
