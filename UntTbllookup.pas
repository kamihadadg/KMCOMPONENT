unit UntTbllookup;
interface

uses
  Adodb,dbgrids,db,  SysUtils,
   Classes,forms,Graphics,stdctrls,untini;

type
  TKMTbllookup = class(Tcomponent)
  private
    { Private declarations }
    //Fbuf: array[0..250] of Char;
    FForm:TForm ;
    Fobname:String ;
    Fini:TKMIniEditor ;
    Flabelsearch:TLabel ;
    FDbgrid:TDBGrid ;
    FDataset:TADODataSet ;
    Fdatasource:TDataSource ;
    FSedit:TEdit ;
    FCmbFieldsearch:TComboBox ;
    Sqlstr:String ;
    FCaption:TStringList ;
    Findex:Integer ;
    Fcaptionwidth:TStringList ;
    FFormcolor:TColor ;
    procedure Setdataset(Dset:TADODataSet) ;
    procedure setcaption(Cap:TStringList);
    procedure Formenter (Sender: TObject;var Key: Word;Shift: TShiftState);
    procedure Seditchange(Sender: TObject);
    procedure Setindex(Sender: TObject) ;
    procedure gridclick(Sender: TObject) ;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  protected
    { Protected declarations }
  public
    { Public declarations }
    function Execute(F:string):Boolean ;
  published
    { Published declarations }
    property Fieldcaption:TStringList read FCaption write setcaption ;
    property Dataset:TADODataSet read FDataset write Setdataset ;
    property FormColor:TColor read FFormcolor write FFormcolor;
    Constructor Create (AOwner: TComponent) ;Override ;
    destructor Destroy ; override ;
  end;

procedure Register;

implementation
constructor TKMTbllookup.Create(Aowner:TComponent);
begin
  inherited Create(AOwner);
  FCaption:=TStringList.Create  ;
  Fcaptionwidth:=TStringList.Create ;
  Fini:=TKMIniEditor.Create(nil);
  Fini.FileName:='KMTLP.ini' ;
end ;
destructor TKMTbllookup.Destroy ;
begin
  FCaption.Free ;
  Fcaptionwidth.Free ;
  fini.Free ;
  inherited ;
end ;
procedure TKMTbllookup.Setindex(Sender: TObject);
begin
  Findex:=FCmbFieldsearch.ItemIndex ;
end ;
procedure TKMTbllookup.gridclick(Sender: TObject);
begin
  FForm.Close ;
end ;
procedure TKMTbllookup.FormKeyPress(Sender: TObject; var Key: Char);
begin
//  if Key='ی' then
//    Key:='ي' ;
//  if Key='ک' then
//    Key:='ك' ;
end ;
procedure TKMTbllookup.Formenter(Sender: TObject;var Key: Word;Shift: TShiftState) ;
begin
  if Key=13 then
    FForm.Close ;
end ;
procedure TKMTbllookup.Seditchange(Sender: TObject) ;
var
  FfieldStr:String ;
  i:Integer ;
begin
  FfieldStr:=FDbgrid.Columns.Items[Findex].Field.FieldName ;
  FDataset.Close ;
  if Pos('where' ,Sqlstr) =0 then
    FDataset.CommandText:=Sqlstr+' where '+FfieldStr+' like '+QuotedStr('%'+FSedit.Text+'%')
  else
    FDataset.CommandText:=Sqlstr+' And '+FfieldStr+' like '+QuotedStr('%'+FSedit.Text+'%') ;


  FDataset.Open ;
  for i:=0 to FCaption.Count-1 do
  begin
    FDbgrid.Columns.Items[i].Title.Caption:=FCaption.Strings[i] ;
    FDbgrid.Columns.Items[i].Width:=(Fini.Readint(Fobname+'Captionwidth',FCaption.Strings[i],90)) ;
  end ;


end ;
procedure TKMTbllookup.setcaption(Cap:TStringList);
begin
  FCaption.Assign(Cap) ;
end ;
procedure TKMTbllookup.Setdataset (dset:TADODataSet) ;
begin
  
    FDataset:=Dset ;
end ;
function TKMTbllookup.Execute (F:string):Boolean ;
var i:integer ;
  Flabel,flabel1:TLabel ;
begin


  Fobname:= f ;

  sqlstr:=FDataset.CommandText;
  FForm:=TForm.Create(nil);
  FForm.BiDiMode:=bdRightToLeft ;
  FForm.Position:=poDesktopCenter ;
  FForm.BorderStyle:=bsDialog ;
  FForm.Height:=300;
  FForm.Width:=600;
  FForm.KeyPreview:=True ;
  FForm.OnKeyDown:=Formenter ;
  FForm.Font.Name:='Tahoma';
  FForm.FormStyle:=fsStayOnTop ;
  FForm.Color:=FFormcolor;
  FForm.KeyPreview:=True ;
  FForm.OnKeyPress:=FormKeyPress;
  Fdatasource:=TDataSource.Create(nil);
  Fdatasource.DataSet:=FDataset ;


  Flabel1 :=TLabel.Create(nil);
  Flabel1.Parent:=FForm ;
  Flabel1.Left:=FForm.Width-Flabel1.Width-20 ;
  Flabel1.Top:=10  ;
  //flabel1.Width:=60 ;
  Flabel1.Caption:='جستجو :  '  ;

  Fsedit:=TEdit.Create(nil);
  FSedit.Parent:=FForm ;
  FSedit.Width:=330 ;
  FSedit.Top:=8 ;
  FSedit.Left:=200   ;
  FSedit.OnChange:=Seditchange ;



  FDbgrid:=TDBGrid.Create(nil);
  FDbgrid.Parent:=FForm ;
  FDbgrid.Top:=FSedit.Top+FSedit.Height+5 ;
  FDbgrid.Height:=200;
  FDbgrid.Width:=FForm.Width-5 ;
  FDbgrid.DataSource:=Fdatasource ;
  FDbgrid.ReadOnly:=True ;

  FDbgrid.Options:=[dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgConfirmDelete,dgCancelOnExit];

  for i:=0 to FCaption.Count-1 do
  begin
    FDbgrid.Columns.Items[i].Title.Caption:=FCaption.Strings[i] ;
    FDbgrid.Columns.Items[i].Width:=(Fini.Readint(Fobname+'Captionwidth',FCaption.Strings[i],90)) ;
  end ;

  FDbgrid.OnDblClick:=gridclick ;

  Flabelsearch:=TLabel.Create(nil);
  Flabelsearch.Caption:='براساس :';
  Flabelsearch.Parent:=FForm ;
  Flabelsearch.Left:=150 ;
  Flabelsearch.Top:=10 ;

  FCmbFieldsearch:=TComboBox.Create(nil);
  FCmbFieldsearch.Parent:=FForm ;
  FCmbFieldsearch.Top:=8;
  FCmbFieldsearch.Left:=0  ;
  FCmbFieldsearch.Style:=csDropDownList ;
  for i:=0 to FCaption.Count-1 do
    FCmbFieldsearch.Items.Add(FCaption.Strings[i]) ;
  FCmbFieldsearch.OnChange:=Setindex ;
  FCmbFieldsearch.ItemIndex:=Fini.ReadInt(Fobname+'Comboitem','Cmb',0)  ;

  if FDataset.RecordCount>0 then
    result:=true
  else
    result:=False ;
  {Flabel :=TLabel.Create(nil);
  Flabel.Parent:=FForm ;
  Flabel.Left:=10;
  Flabel.Top:=FDbgrid.Top+FDbgrid.Height +10; ;
  Flabel.Height:=35 ;
  Flabel.Width:=185 ;
  Flabel.Caption:='Design By : Kamihadad@Yahoo.com  '  ; }
  //////////////////////////label///////////
  FSedit.TabOrder:=0 ;
  Setindex(Self);
  FForm.ShowModal ;



  for i:=0 to FCaption.Count-1 do
    Fini.Writeint(Fobname+'Captionwidth',FCaption.Strings[i],FDbgrid.Columns.Items[i].Width ) ;
  Fini.WriteInt(Fobname+'Comboitem','Cmb',FCmbFieldsearch.ItemIndex);
  FForm.Free ;
end ;
procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMTbllookup]);
end;
end.
