unit UntDBUTIL;

interface
  uses  adodb,variants,Classes,UntINI,db, StdCtrls,Datasnap.DBClient,
        logvieweru;
	type
   TDynamicMapArray = Array of int64;
	 TKMDButil = class(TComponent)

  protected
  {protected declarations }
  private
  { Private declarations }
  qry:TADOQuery ;
  public
	{ Public declarations }
	function Getresult(Sqltext:WideString;adcn:TADOConnection):Variant ;
	function Dbinsert(Tname:String;fieldnames,valnames:TStringList;dbm:TADOConnection):Boolean ;
	function DBUpdate(TName : String; FNames, Values : TStringList; WhereClause : WideString;
		dbm : TADOConnection) : Boolean;
	function DbExe(SQLStr:Widestring;dbm:TADOConnection):Boolean ;
  procedure OpenSQL(q : TADOQuery; s : wideString);

  function GetLastID(AConnenction:TADOConnection;AShenase:string):Largeint ;
  procedure SetLastID(AConnenction:TADOConnection;AShenase:string) ;


  function GetDatetimeServer(adcn:TADOConnection):TDateTime ;
	function FindMax(Tabname,wherestr,Fldname:string;startint:integer;dbm:TADOConnection):integer  ;
	function FindRecord(Tab,Fld,Val:String;dbm:TADOConnection):Integer ;



	procedure RefreshTable(adodataset:TCustomADODataSet) ;



	function wheresql(field:TStringList):String ;




	function AdoConectionstring():WideString  ;

  { TODO : infunction bayad pak shavad chon mesle dbcombolookup amal mikonad }
	procedure FillComboFromDataSet(DataSet : TDataSet; DisplayField, KeyField : String;
		var MapArray : TDynamicMapArray; Cmb : TCombobox; IndexZeroIsAllValues : Boolean = False); Overload;


	procedure FillComboFromDataSet(DataSet : TDataSet; DisplayField : String;
		Cmb : TCombobox; IndexZeroIsAllValues : Boolean = False); Overload;

  function GetIDIndex(MapArray : Array of int64; ID : int64) : integer;
  procedure SetComboItemIndex(Cmb : TCombobox; s : String);
  Function SetSqlConStr(Aserver,Adbname,Auser,APass:string):string ;

  function SortClientDataSet(ClientDataSet: TClientDataSet;
    const FieldName: String): Boolean;

  procedure Deletetemptable (ATablename:string;Adbm:TADOConnection) ;

  procedure loginsert(Adate, Atime, Acomm: string;
  Auid,AFKID,Akind: Integer; Adbm: TADOConnection)  ;

  function logView(Akind,AID:Integer;Acnn:TADOConnection):TADOStoredProc ;

	published
	{ Published declarations }
	Constructor Create (AOwner: TComponent) ;Override ;
	destructor Destroy ; override ;
  end;

procedure Register;
implementation

uses SysUtils;
Constructor TKMDButil.Create (AOwner: TComponent) ;
Begin
  inherited Create (AOwner) ;
  qry:=TADOQuery.Create(nil);
End ;
procedure TKMDButil.Deletetemptable(ATablename: string; Adbm: TADOConnection);
var
  vstr:string ;
begin
  vstr:='IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID(''tempdb..'+ATablename+''')) DROP TABLE '+ATablename ;
  Adbm.Execute(vstr);
end;

destructor TKMDButil.Destroy ;
begin
  qry.free ;
  inherited ;
end ;


function TKMDButil.SortClientDataSet(ClientDataSet: TClientDataSet;
  const FieldName: String): Boolean;
var
  i: Integer;
  NewIndexName: String;
  IndexOptions: TIndexOptions;
  Field: TField;
begin
Result := False;
Field := ClientDataSet.Fields.FindField(FieldName);
//If invalid field name, exit.
if Field = nil then Exit;
//if invalid field type, exit.
if (Field is TObjectField) or (Field is TBlobField) or
  (Field is TAggregateField) or (Field is TVariantField)
   or (Field is TBinaryField) then Exit;
//Get IndexDefs and IndexName using RTTI
//Ensure IndexDefs is up-to-date
ClientDataSet.IndexDefs.Update;
//If an ascending index is already in use,
//switch to a descending index
if ClientDataSet.IndexName = FieldName + '__IdxA'
then
  begin
    NewIndexName := FieldName + '__IdxD';
    IndexOptions := [ixDescending];
  end
else
  begin
    NewIndexName := FieldName + '__IdxA';
    IndexOptions := [];
  end;
//Look for existing index
for i := 0 to Pred(ClientDataSet.IndexDefs.Count) do
begin
  if ClientDataSet.IndexDefs[i].Name = NewIndexName then
    begin
      Result := True;
      Break
    end;  //if
end; // for
//If existing index not found, create one
if not Result then
    begin
      ClientDataSet.AddIndex(NewIndexName,
        FieldName, IndexOptions);
      Result := True;
    end; // if not
//Set the index
ClientDataSet.IndexName := NewIndexName;
end;

///////////////////Find End Of Serial////////////////////
function TKMDButil.FindMax(Tabname,wherestr,Fldname:string;Startint:integer;Dbm:TADOConnection):integer  ;
begin
   
   qry.Connection:=dbm ;
   if wherestr='' then
     qry.SQL.Text:='select max('+fldname+')as [max] from '+tabname
   else
     qry.SQL.Text:='select max('+fldname+')as [max] from '+tabname+' where '+wherestr ;

   qry.Open ;
   if not(qry['max']=null) then
   begin
     Result:=qry['max'];
     Result:=Result ;
   end
   else
     Result:=startint ;
   qry.Close;
end ;
//////////////////////////////locate in database//////////////////////



function TKMDButil.FindRecord(Tab,Fld,Val:String;dbm:TADOConnection):Integer ;
begin
  qry.Connection:=dbm ;
  qry.SQL.Text:='select * from '+tab+' where '+fld+' = '+val;
  qry.Open ;
  result:=qry.RecordCount
end ;
/////////////////////////make Where for Sql String//////////////////////////////
function TKMDButil.wheresql(field:TStringList):String ;
var
  i:Integer ;
  st:String ;
begin
  for i:=0 to field.Count-1 do
  begin
    if i<>field.Count-1 then
	  st:=st+field.Strings[i]+' and '
    else
	  st:=st+field.Strings[i]  ;
  end ;
  if field.Count>0 then
    Result:=' Where '+st
  else
    Result:='';

end ;
/////////////////////////Get one result from Database//////////////////////////////
function TKMDButil.Getresult(Sqltext:WideString;adcn:TADOConnection):Variant ;
begin
  qry.Connection:=adcn ;
  qry.SQL.Text:=Sqltext ;
  qry.open ;
  Result:=qry.Fields[0].Value ;
  if Result = null then
    Result:='0' ;
end ;
function TKMDButil.logView(Akind, AID: Integer;Acnn:TADOConnection): TADOStoredProc;
var
  vfrm:Tfrmlogviewer  ;
begin
  vfrm:=Tfrmlogviewer.Create(nil);
  with vfrm do
  begin
    vfrm.ads_log.Connection:=Acnn;
     vfrm.ads_log.Close  ;
     vfrm.Ads_log.CommandText:='exec [COM].[showlog] :k,:ID';
    vfrm.ads_log.Parameters[0].Value:= Akind ;
    vfrm.ads_log.Parameters[1].Value:= AID ;
    vfrm.ads_log.Open ;
    vfrm.ShowModal ;
    vfrm.Release ;
    vfrm:=nil ;
  end ;

end;

procedure TKMDButil.loginsert(Adate,Atime,Acomm: string;
  Auid,AFKID,Akind: Integer; Adbm: TADOConnection);
begin

  qry.Connection:=Adbm ;
  qry.SQL.Text:='exec [COM].[insertlog] '
      + inttostr(Akind) +','
      + inttostr(AFKID) +','
      + inttostr(Auid) +','
      + QuotedStr(Acomm) +','
      + QuotedStr(Adate) +','
      + QuotedStr(Atime) ;
  qry.ExecSQL ;
end;

function TKMDButil.GetDatetimeServer(adcn:TADOConnection):TDateTime ;
begin
  qry.Connection:=adcn ;
  qry.SQL.Text:='select Getdate()' ;
  qry.open ;
  Result:=qry.Fields[0].AsDateTime ;
end ;
function TKMDButil.Dbinsert(Tname:String;fieldnames,valnames:TStringList;dbm:TADOConnection):Boolean ;
var
	fieldnamesstr, valuesstr : WideString;
	i : integer;
begin
  qry.Connection:=dbm ;
  try
  begin
	fieldnamesstr := '';
	for  i := 0 to fieldnames.Count - 1 do
		fieldnamesstr := fieldnamesstr + fieldnames.Strings[i] + ',';
	delete(fieldnamesstr, Length(fieldnamesstr), 1);

	valuesstr := '';
	for  i := 0 to valnames.Count - 1 do
		valuesstr := valuesstr + valnames.Strings[i] + ',';
  delete(valuesstr, Length(valuesstr), 1);

  qry.SQL.Text:= 'insert into '+Tname+ ' (' + fieldnamesstr + ') Values (' + valuesstr + ')' ;
  qry.ExecSQL ;
  Result:=True ;
  end ;
  except
  begin
	  Result:=False ;
  end ;
  end ;

end ;

/////////////////////////execute any Sql String in database//////////////////////////////
function TKMDButil.DbExe(SQLStr:Widestring;dbm:TADOConnection):Boolean ;
begin
  qry.Connection:=dbm ;
  try
  begin
    qry.SQL.Text:=SQLStr ;
    qry.ExecSQL ;
    Result:=True ;
  end ;
  except
  begin
    Result:=False ;
  end ;
  end ;

end ;
/////////////////////////make connection string //////////////////////////////
function TKMDButil.AdoConectionstring():WideString ;
var
  Auser,ADbase,Apass,Aserver:String ;
  km:TKMIniEditor ;
begin
  km:=TKMIniEditor.Create(nil);
  km.FileName:='CNN.INI';
  Aserver:=km.ReadStr('server1','Server','TSS-SERVER') ;
  ADbase:=km.ReadStr('server1','DataBase','Pubs') ;
  Auser:=km.ReadStr('server1','User','sa') ;
  Apass:=km.ReadStr('server1','Pass','') ;
  Result:='Provider=SQLOLEDB.1;Password='+Apass+
          ';Persist Security Info=True;User ID='+Auser+
          ';Initial Catalog='+ADbase+';Data Source='+Aserver ;

end ;
/////////////////////////refresh table//////////////////////////////
procedure TKMDButil.RefreshTable(adodataset:TCustomADODataSet) ;
var
  t:TBookmark ;
begin
If adodataset.RecNo > 1 Then
Begin
  T:=adodataset.GetBookmark;
  adodataset.DisableControls;
  adodataset.Requery;
  If adodataset.BookmarkValid(T) Then
  Begin
    adodataset.GotoBookmark(T);
		adodataset.FreeBookmark(T);
	 End;
	 adodataset.EnableControls;
End Else
   adodataset.Requery;
end ;
procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMDButil]);
end;
{ReleaseCapture ;
Panel1.Perform(WM_SYSCOMMAND ,$f012,0); }



function TKMDButil.DBUpdate(TName: String; FNames, Values: TStringList;
  WhereClause: WideString; dbm: TADOConnection): Boolean;
var
	i : integer;
begin
	qry.Connection := dbm;
	try
		begin
			qry.SQL.Text := 'update ' + TName + ' set ' + FNames.Strings[0] + ' = ' + Values.Strings[0];
			for i := 1 to FNames.Count - 1 do
				qry.SQL.Text := qry.SQL.Text + ',' + FNames.Strings[i] + ' = ' + Values.Strings[i];

			qry.SQL.Text := qry.SQL.Text + ' where ' + WhereClause;

			qry.ExecSQL;
			Result := True;
		end;
	except
		begin
			Result := False;
		end;
	end;
end;

procedure TKMDButil.FillComboFromDataSet(DataSet: TDataSet; DisplayField,
  KeyField: String; var MapArray: TDynamicMapArray; Cmb: TCombobox; IndexZeroIsAllValues : Boolean);
var
	i : integer;
	DisplayValue : Variant;
begin
	DataSet.First;
	Cmb.Items.Clear;
	if (IndexZeroIsAllValues) then
	begin
		SetLength(MapArray, DataSet.RecordCount + 1);
		Cmb.Items.Add('Â„Â „Ê«—œ');
		MapArray[0] := -1;
	end
	else
		SetLength(MapArray, DataSet.RecordCount);

	for i := 0 to DataSet.RecordCount - 1 do
	begin
		DisplayValue := DataSet.FieldValues[DisplayField];
		if (DisplayValue <> null) then
		begin
			Cmb.Items.Add(DisplayValue);
			if (IndexZeroIsAllValues) then
				MapArray[i + 1] := DataSet.FieldValues[KeyField]
			else
				MapArray[i] := DataSet.FieldValues[KeyField];
		end;
		DataSet.Next;
	end;
end;

procedure TKMDButil.FillComboFromDataSet(DataSet: TDataSet;
  DisplayField: String; Cmb: TCombobox; IndexZeroIsAllValues: Boolean);
var
	i : integer;
	DisplayValue : Variant;
begin
	DataSet.First;
	Cmb.Items.Clear;
	if (IndexZeroIsAllValues) then
	begin
		Cmb.Items.Add('Â„Â „Ê«—œ');
	end;

	for i := 0 to DataSet.RecordCount - 1 do
	begin
		DisplayValue := DataSet.FieldValues[DisplayField];
		if (DisplayValue <> null) then
		begin
			Cmb.Items.Add(DisplayValue);
		end;
		DataSet.Next;
	end;
end;

// Just opens the adoquery with the given query (s)
procedure TKMDButil.OpenSQL(q: TADOQuery; s: wideString);
begin
	q.SQL.Clear;
	q.SQL.Add(s);
  q.Open;
end;

// This function gets a map array and a given ID, and tells the index
// of that ID.
function TKMDButil.GetIDIndex(MapArray: array of int64; ID: int64): integer;
var
	i : integer;
begin
	Result := -1;
	for i := 0 to Length(MapArray) - 1 do
		if (MapArray[i] = ID) then
		begin
			Result := i;
			break;
		end;
end;




// This function set the combobox item index due to given string (s)
// if no item starts with s, the item index will be -1.
procedure TKMDButil.SetComboItemIndex(Cmb: TCombobox; s: String);
var
	i : integer;
begin
	Cmb.ItemIndex := -1;
	for i := 0 to Cmb.Items.Count - 1 do
	begin
		if (Cmb.Items[i] = s) then
		begin
			Cmb.ItemIndex := i;
			break;
		end;
	end;
end;

function TKMDButil.GetLastID(AConnenction: TADOConnection;
  AShenase: string): Largeint;
var
  vqry:TADOQuery ;
begin
  vqry:=TADOQuery.Create(nil);
  vqry.Connection:=AConnenction ;
  vqry.SQL.Text:='select LastCode_ from com.IDGen where Shenase_='+QuotedStr(AShenase) ;
  vqry.Open ;
  Result:=vqry.FieldByName('LastCode_').AsLargeInt ;
  vqry.Free ;
end;

procedure TKMDButil.SetLastID(AConnenction: TADOConnection; AShenase: string) ;
var
  vqry:TADOQuery ;
begin
  vqry:=TADOQuery.Create(nil);
  vqry.Connection:=AConnenction ;
  vqry.SQL.Text:='Update com.IDGen  set LastCode_=LastCode_+1   where Shenase_='+QuotedStr(AShenase) ;
  vqry.ExecSQL ;
  vqry.Free ;
end;

function TKMDButil.SetSqlConStr(Aserver,Adbname,Auser,APass:string): string;
begin
//  Result := 'Provider=SQLNCLI10;' +
//      'Data Source='+AServer+';'+
//      'Initial Catalog='+ADBName+';'+
//      'User Id='+AUser+';Password='+APass+'';

  Result := 'Provider=sqloledb;' +
      'Data Source='+AServer+';'+
      'Initial Catalog='+ADBName+';'+
      'User Id='+AUser+';Password='+APass+'';
end;

end.

