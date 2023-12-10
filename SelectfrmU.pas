unit SelectfrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,Grids, DBGrids, DB, StdCtrls, ExtCtrls, ADODB, UntINI, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges,
  cxDataControllerConditionalFormattingRulesManagerDialog, cxDBData,
  cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid ;

type
  Tselectfrm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Ds_Search: TDataSource;
    Panel2: TPanel;
    Edit1: TEdit;
    ComboBox1: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox2: TComboBox;
    KMIniEditor1: TKMIniEditor;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure cxGrid1DBTableView1DblClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FVstr:string ;
  public
    { Public declarations }
  end;

var
  selectfrm: Tselectfrm;

implementation

{$R *.dfm}


procedure Tselectfrm.ComboBox1Change(Sender: TObject);
begin
  ComboBox2.ItemIndex:=ComboBox1.ItemIndex ;
end;

procedure Tselectfrm.cxGrid1DBTableView1DblClick(Sender: TObject);
begin
    Button2.Click ;
end;

procedure Tselectfrm.Edit1Change(Sender: TObject);
var
  VsqlText,WhereText:string ;
begin

  if not RadioButton1.Checked then
    WhereText:=ComboBox2.Items.Strings[ComboBox1.ItemIndex]+' like  ''%'+Edit1.Text+'%'''
  else
    WhereText:=ComboBox2.Items.Strings[ComboBox1.ItemIndex]+' like  ''%'+Edit1.Text+'''';



  TADODataSet(Ds_Search.DataSet).Close ;
  TADODataSet(Ds_Search.DataSet).CommandText:=FVstr+' and  '+ WhereText ;
  TADODataSet(Ds_Search.DataSet).Open ;



end;

procedure Tselectfrm.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_DOWN then
    cxGrid1.SetFocus ;

end;

procedure Tselectfrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_RETURN then
  begin
    Button2.Click ;
  end ;
  if Key=VK_ESCAPE then
  begin
    Button1.Click ;
  end ;
end;

procedure Tselectfrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key='ی' then
    Key:='ي' ;
  if Key='ک' then
    Key:='ك' ;

end;

procedure Tselectfrm.FormShow(Sender: TObject);
begin
  FVstr:=TADODataSet(Ds_Search.DataSet).CommandText ;




end;

end.
