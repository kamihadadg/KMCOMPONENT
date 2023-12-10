unit UntKmSearchList;



interface

uses
   SelectfrmU,DB,ADODB,Windows,
   Forms,controls, Messages,UntUTIL, SysUtils, Variants,
   DBCtrls, Classes,StdCtrls;
type
    TKmSearchList = class(TComponent)
  private
    { Private declarations }
  fresult:string ;

  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    Constructor Create (AOwner: TComponent) ;Override ;
    destructor Destroy ; override ;
    function AformShowOne(ADataset:TADODataSet;AParent:TComponent;
            ATop,Aleft:Integer;AID:Integer=0;AShowKind:Boolean=True;AName:string=''):Integer ;
    function AformShowOneName(ADataset:TCustomADODataSet;AParent:TComponent;
            ATop,Aleft:Integer;AID:string='0';AShowKind:Boolean=True):string ;


    function AformShowMulti(ADataset:TCustomADODataSet;AParent:TComponent):string ;
  end;

procedure Register;

implementation

function TKmSearchList.AformShowMulti(ADataset: TCustomADODataSet;
  AParent: TComponent): string;
var
  VSearchListFrm:Tselectfrm ;
  VI:Integer ;
begin
  VSearchListFrm:=Tselectfrm.Create(AParent);
  VSearchListFrm.Ds_Search.DataSet:=ADataset ;



  if VSearchListFrm.ShowModal=mrOk then
  begin
//    Result:='(';
//    for VI:=0 to   VSearchListFrm.cxGrid1DBTableView1.SelectedRows.Count-1 do
//    begin
//      VSearchListFrm.Ds_Search.DataSet.GotoBookmark(VSearchListFrm.DBGrid1.SelectedRows[VI]);
//      Result:=Result+VSearchListFrm.Ds_Search.DataSet.Fields[0].AsString+',' ;
//    end;
//    if Result<>'(' then
//    begin
//      Result:=Copy(Result,1,Length(Result)-1)+')' ;
//    end
//    else
    begin
      Result:='(-1)';
    end;
  end ;
end;

function TKmSearchList.AformShowOne(ADataset: TADODataSet;AParent:TComponent;
        ATop,Aleft:Integer;AID:Integer=0;AShowKind:Boolean=True;AName:string=''): Integer;
var
  VSearchListFrm:Tselectfrm ;
  i:Integer ;
  Vstr:string ;
begin
  VSearchListFrm:=Tselectfrm.Create(AParent);
  VSearchListFrm.Ds_Search.DataSet:=ADataset ;
  Vstr:=ADataset.CommandText ;

  ADataset.Close ;
  ADataset.CommandText:=Vstr ;
  ADataset.Open ;


  VSearchListFrm.cxGrid1DBTableView1.DataController.CreateAllItems();



  VSearchListFrm.ComboBox1.Items.Clear ;
  VSearchListFrm.ComboBox2.Items.Clear ;

  for I := 0 to ADataset.FieldCount - 1 do
  begin
    if ADataset.Fields[i].Visible then
    begin
      VSearchListFrm.ComboBox1.Items.Add(ADataset.Fields[i].DisplayLabel) ;
      VSearchListFrm.ComboBox2.Items.Add(ADataset.Fields[i].FieldName) ;
    end;
  end;
  VSearchListFrm.ComboBox1.ItemIndex:=VSearchListFrm.KMIniEditor1.ReadInt('Search',AName,0) ; ;

  if not AShowKind then
  begin
    VSearchListFrm.BorderStyle:=bsNone ;
    VSearchListFrm.Top:=ATop ;
    VSearchListFrm.Left:=Aleft ;
  end;

  if AID<>0 then
    VSearchListFrm.Ds_Search.DataSet.Locate(ADataset.Fields[0].FieldName,AID,[loCaseInsensitive]);






  if VSearchListFrm.ShowModal=mrOk then
  begin
    Result:=ADataset.Fields[0].AsInteger ;
  end
  else
  begin
    Result:=-1;
  end;
  VSearchListFrm.KMIniEditor1.WriteInt('Search',AName,VSearchListFrm.ComboBox1.ItemIndex) ;
  ADataset.Close ;
  ADataset.CommandText:=Vstr ;
  ADataset.Open ;
  VSearchListFrm.Release ;
  VSearchListFrm.Free ;
end;

function TKmSearchList.AformShowOneName(ADataset: TCustomADODataSet;AParent:TComponent;
        ATop,Aleft:Integer;AID:String='0';AShowKind:Boolean=True): String;
var
  VSearchListFrm:Tselectfrm ;
  Vi:Integer ;
begin
  VSearchListFrm:=Tselectfrm.Create(AParent);
  VSearchListFrm.Ds_Search.DataSet:=ADataset ;

    VSearchListFrm.cxGrid1DBTableView1.DataController.CreateAllItems();

  if not AShowKind then
  begin
    VSearchListFrm.BorderStyle:=bsNone ;
    VSearchListFrm.Top:=ATop ;
    VSearchListFrm.Left:=Aleft ;
  end;



  VSearchListFrm.ComboBox1.Items.Clear ;
  VSearchListFrm.ComboBox2.Items.Clear ;

  for Vi := 0 to ADataset.FieldCount - 1 do
  begin
    if ADataset.Fields[Vi].Visible then
    begin
      VSearchListFrm.ComboBox1.Items.Add(ADataset.Fields[Vi].DisplayLabel) ;
      VSearchListFrm.ComboBox2.Items.Add(ADataset.Fields[Vi].FieldName) ;
    end;
  end;
  VSearchListFrm.ComboBox1.ItemIndex:=0 ;


  if AID<>'0' then
    VSearchListFrm.Ds_Search.DataSet.Locate(VSearchListFrm.Ds_Search.DataSet.Fields[0].FieldName,AID,[loCaseInsensitive]);

  if VSearchListFrm.ShowModal=mrOk then
  begin
    Result:=VSearchListFrm.Ds_Search.DataSet.Fields[1].AsString ;
  end
  else
  begin
    Result:='';
  end;

end;
constructor TKmSearchList.Create(Aowner:TComponent);

begin
  inherited Create(AOwner);

end ;
destructor TKmSearchList.Destroy ;
begin
  inherited ;
end ;
procedure Register;
begin
  RegisterComponents('Kamran Component', [TKmSearchList]);
end;

end.
