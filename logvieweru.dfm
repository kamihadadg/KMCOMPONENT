object frmlogviewer: Tfrmlogviewer
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  ClientHeight = 349
  ClientWidth = 710
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  ParentBiDiMode = False
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 0
    Width = 710
    Height = 349
    Align = alClient
    DataSource = ds_log
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'log_key'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_kind'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_fk'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'user_key'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_timedate'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_datesh'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_time'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_ip'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_computername'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'User_Name'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'log_comment'
        Visible = True
      end>
  end
  object ds_log: TDataSource
    DataSet = Ads_log
    Left = 184
    Top = 80
  end
  object Ads_log: TADODataSet
    LockType = ltReadOnly
    Parameters = <>
    Left = 240
    Top = 80
    object Ads_loglog_key: TLargeintField
      DisplayLabel = #1588#1575#1582#1589
      FieldName = 'log_key'
      ReadOnly = True
    end
    object Ads_loglog_kind: TWordField
      DisplayLabel = #1606#1608#1593
      FieldName = 'log_kind'
    end
    object Ads_loglog_fk: TIntegerField
      DisplayLabel = #1593#1591#1601
      FieldName = 'log_fk'
    end
    object Ads_loguser_key: TIntegerField
      DisplayLabel = #1588#1575#1582#1589' '#1705#1575#1585#1576#1585
      FieldName = 'user_key'
    end
    object Ads_loglog_timedate: TDateTimeField
      DisplayLabel = 'datetime'
      FieldName = 'log_timedate'
    end
    object Ads_loglog_datesh: TWideStringField
      DisplayLabel = #1578#1575#1585#1740#1582
      FieldName = 'log_datesh'
      Size = 10
    end
    object Ads_loglog_time: TWideStringField
      DisplayLabel = #1587#1575#1593#1578
      FieldName = 'log_time'
      Size = 5
    end
    object Ads_loglog_ip: TWideStringField
      DisplayLabel = 'IP'
      FieldName = 'log_ip'
      Size = 15
    end
    object Ads_loglog_computername: TWideStringField
      DisplayLabel = #1606#1575#1605' '#1587#1740#1587#1578#1605
      FieldName = 'log_computername'
      Size = 150
    end
    object Ads_logUser_Name: TStringField
      DisplayLabel = #1606#1575#1605' '#1705#1575#1585#1576#1585
      FieldName = 'User_Name'
      Size = 10
    end
    object Ads_loglog_comment: TStringField
      DisplayLabel = #1588#1585#1581
      FieldName = 'log_comment'
      Size = 4000
    end
  end
end
