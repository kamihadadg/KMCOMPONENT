unit logvieweru;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Data.Win.ADODB;

type
  Tfrmlogviewer = class(TForm)
    ds_log: TDataSource;
    Ads_log: TADODataSet;
    Ads_loglog_key: TLargeintField;
    Ads_loglog_kind: TWordField;
    Ads_loglog_fk: TIntegerField;
    Ads_loguser_key: TIntegerField;
    Ads_loglog_timedate: TDateTimeField;
    Ads_loglog_datesh: TWideStringField;
    Ads_loglog_time: TWideStringField;
    Ads_loglog_ip: TWideStringField;
    Ads_loglog_computername: TWideStringField;
    Ads_logUser_Name: TStringField;
    Ads_loglog_comment: TStringField;
    DBGrid1: TDBGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;



implementation

{$R *.dfm}

{ Tfrmlogviewer }


end.
