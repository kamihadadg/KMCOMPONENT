unit KMBtn;

interface

uses
  Windows, Messages, SysUtils,ExtCtrls, Classes,
  Controls, StdCtrls,graphics, Buttons,DB,forms,
  untfrmimagedbbutton,UntMSGDLG;
type
  TClickAction=(caNone,caInsert,caEdit,caDelete,caPost,caCancel,caFirst,caPrior,caNext,caLast,caRefresh,caselect,cahelp,caprint1,caprint2,caexit);
  TBtnGroup=(PG_Public,PG_Accounting);
  TKMDBBitBtnDataLink=class;

  TKMBtn = class(TBitBtn)
  private
    { Private declarations }
    FDataLink: TKMDBBitBtnDataLink;
    FBtnGroup:TBtnGroup;
    FClickAction: TClickAction;
    FLetDataSetControlEnable: Boolean;
    Ffrmimage:Tfrmimagedbbutton ;
    FImage:TImage ;
    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    procedure SetBtnGroup(const Value: TBtnGroup);
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
    property GroupButton : TBtnGroup read FBtnGroup write SetBtnGroup  default PG_Public  ;
    property ClickAction : TClickAction read FClickAction write SetClickAction default caNone;
    property LetDataSetControlEnable : Boolean read FLetDataSetControlEnable write SetLetDataSetControlEnable;
  end;

  TKMDBBitBtnDataLink = class(TDataLink)
  private
    FTssButton: TKMBtn;

  protected
    procedure EditingChanged; override;
    procedure DataSetChanged; override;
    procedure ActiveChanged; override;

  public
    constructor Create(ATSSButton: TKMBtn);
    destructor Destroy; override;
  end;

procedure Register;

implementation


procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMBtn]);
end;
Const
    TCaptions: array [TClickAction] of string= ('','ÃœÌœ','ÊÌ—«Ì‘','Õ–›','À» ','«‰’—«›','«Ê·Ì‰','ﬁ»·Ì','»⁄œÌ','¬Œ—Ì‰','œÊ»«—Â ”«“Ì','«‰ Œ«»','—«Â‰„«','ç«Å1','ç«Å2','Œ—ÊÃ');
    TGlyphs: array [TClickAction] of string= ('','DBBIT_Insert','DBBIT_Edit','DBBIT_Delete','DBBIT_Post','DBBIT_Cancel','DBBIT_First','DBBIT_Prior','DBBIT_Next','DBBIT_Last','DBBIT_REFRESH','DBBIT_Select','DBBIT_Help','DBBIT_Print1','DBBIT_Print2','DBBIT_Exit');
{ TKMDBBitBtnDataLink }

procedure TKMDBBitBtnDataLink.ActiveChanged;
begin
  if FTssButton <> nil then FTssButton.ChekEnable;
end;

constructor TKMDBBitBtnDataLink.Create(ATSSButton: TKMBtn);
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

procedure TKMBtn.ChekEnable;
begin
   // Do not remove this else will have error!!!
   //Application.ProcessMessages;
   //
   if FLetDataSetControlEnable  then
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

procedure TKMBtn.Click;
var
  BMsg:TKMMsgdlg ;
begin
  inherited Click;
  BMsg:=TKMMsgdlg.Create(nil);
  BMsg.ButtonNames.Add('»·Ì') ;
  BMsg.ButtonNames.Add('ŒÌ—') ;
  BMsg.Prompt:='¬Ì« «ÿ„Ì‰«‰ œ«—Ìœ';
  BMsg.Title:='Õ–› «ÿ·«⁄« ' ;
  //BMsg.CenterOnParent:=True ;
  if not Assigned(OnClick) then
  begin
    if ClickAction<>caNone then
    begin
      if Assigned(FDataLink.DataSource) then
      if Assigned(FDataLink.DataSource.DataSet) then
      if FDataLink.DataSource.DataSet.Active then
      begin
        if FDataLink.DataSource.DataSet.State=dsBrowse then
        begin
          with FDataLink.DataSource.DataSet do
          begin
                case ClickAction of
                  caInsert:Append ;
                  caEdit:Edit ;
                  caDelete:
                  begin
                    if BMsg.Execute = 0 then
                      Delete ;
                  end ;
                  caFirst:First;
                  caPrior:Prior;
                  caNext:Next;
                  caLast:Last;
                  caRefresh:Refresh;
                end;
          end;
        end
        else
        begin
          if (FDataLink.DataSource.DataSet.State=dsEdit) OR (FDataLink.DataSource.DataSet.State=dsInsert) then
          begin
                case ClickAction of
                  caPost:FDataLink.DataSource.DataSet.Post ;
                  caCancel:FDataLink.DataSource.DataSet.Cancel;
                end ;
          end ;
        end;
      end;
    end;
  end ;
  BMsg.Free ;
end;
constructor TKMBtn.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TKMDBBitBtnDataLink.Create(Self);
    FLetDataSetControlEnable:=False;
    ShowHint:=True;
    Width:=40;
    Height:=40 ;
    Ffrmimage:=Tfrmimagedbbutton.Create(nil);
end;

destructor TKMBtn.Destroy;
begin
  Ffrmimage.Free ;
  FDataLink.Free;
  inherited;
end;

function TKMBtn.GetDataSource: TDataSource;
begin
  //if FDataLink<>nil then
    // if FDataLink.DataSource <>nil then
       Result := FDataLink.DataSource;
end;


procedure TKMBtn.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TKMBtn.SetBtnGroup(const Value: TBtnGroup);
begin
  FBtnGroup:= Value;
end;

procedure TKMBtn.SetClickAction(const Value: TClickAction);
var
  VB_Image:Boolean ;
begin
  
  FClickAction := Value;
  VB_Image:=False ;
  if (csDesigning in ComponentState)and not(csloading in ComponentState) then
  begin
    FLetDataSetControlEnable:=True;
    Invalidate;
    Caption:='' ;
    Hint:=TCaptions[value];
    case FBtnGroup of
    PG_Public :
    begin
      VB_Image:=True ;
      if  TGlyphs[Value]= 'DBBIT_Insert' then
      begin
        FImage:=Ffrmimage.DBBIT_Insert ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Edit' then
      begin
        FImage:=Ffrmimage.DBBIT_Edit ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Delete' then
      begin
        FImage:=Ffrmimage.DBBIT_Delete ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Post' then
      begin
        FImage:=Ffrmimage.DBBIT_Post ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Cancel' then
      begin
        FImage:=Ffrmimage.DBBIT_Cancel ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_First' then
      begin
        FImage:=Ffrmimage.DBBIT_First ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Prior' then
      begin
        FImage:=Ffrmimage.DBBIT_Prior ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Next' then
      begin
        FImage:=Ffrmimage.DBBIT_Next ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Last' then
      begin
        FImage:=Ffrmimage.DBBIT_Last ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Help' then
      begin
        FImage:=Ffrmimage.DBBIT_Help ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Print1' then
      begin
        FImage:=Ffrmimage.DBBIT_Print1 ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Print2' then
      begin
        FImage:=Ffrmimage.DBBIT_Print2 ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Exit' then
      begin
        FImage:=Ffrmimage.DBBIT_Exit ;
      end ;
      if  TGlyphs[Value]= 'DBBIT_Select' then
      begin
        FImage:=Ffrmimage.DBBIT_Select  ;
      end ;
      if  TGlyphs[Value]= '' then
      begin
        VB_Image:=False ;
      end ;

    end ;
      PG_Accounting :VB_Image:=False ;
    end ;

    if VB_Image then
      Glyph:=FImage.Picture.Bitmap;

    ChekEnable;

  end;
end;

procedure TKMBtn.SetDataSource(const Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if not (csLoading in ComponentState) then ChekEnable;
  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TKMBtn.SetLetDataSetControlEnable(const Value: Boolean);
begin
  FLetDataSetControlEnable := Value;
end;

end.
