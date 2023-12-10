object selectfrm: Tselectfrm
  Left = 0
  Top = 0
  BiDiMode = bdRightToLeft
  Caption = #1580#1587#1578#1580#1608
  ClientHeight = 318
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 289
    Width = 689
    Height = 29
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 219
    ExplicitWidth = 577
    object Button1: TButton
      Left = 16
      Top = 2
      Width = 75
      Height = 25
      Caption = #1575#1606#1589#1585#1575#1601
      ModalResult = 2
      TabOrder = 1
    end
    object Button2: TButton
      Left = 96
      Top = 2
      Width = 75
      Height = 25
      Caption = #1578#1575#1574#1740#1583
      ModalResult = 1
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 689
    Height = 23
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 577
    object Label1: TLabel
      Left = 641
      Top = 1
      Width = 47
      Height = 21
      Align = alRight
      Caption = '  '#1580#1587#1578#1580#1608'  '
      ExplicitLeft = 529
      ExplicitHeight = 13
    end
    object Label2: TLabel
      Left = 145
      Top = 1
      Width = 50
      Height = 21
      Align = alLeft
      Caption = ' '#1576#1585' '#1575#1587#1575#1587'  '
      ExplicitHeight = 13
    end
    object Edit1: TEdit
      Left = 413
      Top = 1
      Width = 228
      Height = 21
      Align = alRight
      TabOrder = 0
      OnChange = Edit1Change
      OnKeyDown = Edit1KeyDown
      ExplicitLeft = 301
    end
    object ComboBox1: TComboBox
      Left = 17
      Top = 1
      Width = 128
      Height = 21
      Align = alLeft
      Style = csDropDownList
      TabOrder = 1
      TabStop = False
      OnChange = ComboBox1Change
    end
    object RadioButton1: TRadioButton
      Left = 373
      Top = 1
      Width = 40
      Height = 21
      Align = alRight
      Caption = #1575#1576#1578#1583#1575
      TabOrder = 2
      ExplicitLeft = 261
    end
    object RadioButton2: TRadioButton
      Left = 320
      Top = 1
      Width = 53
      Height = 21
      Align = alRight
      Caption = #1588#1575#1605#1604
      Checked = True
      TabOrder = 3
      TabStop = True
      ExplicitLeft = 208
    end
    object ComboBox2: TComboBox
      Left = 1
      Top = 1
      Width = 16
      Height = 21
      Align = alLeft
      TabOrder = 4
      TabStop = False
      Text = 'ComboBox1'
      Visible = False
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 23
    Width = 689
    Height = 266
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 168
    ExplicitTop = 40
    ExplicitWidth = 250
    ExplicitHeight = 200
    object cxGrid1DBTableView1: TcxGridDBTableView
      OnDblClick = cxGrid1DBTableView1DblClick
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = Ds_Search
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.CancelOnExit = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsView.Footer = True
      OptionsView.GroupByBox = False
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object Ds_Search: TDataSource
    Left = 48
    Top = 88
  end
  object KMIniEditor1: TKMIniEditor
    FileName = 'SeachDialog'
    FileExtended = 'ini'
    Left = 136
    Top = 88
  end
end
