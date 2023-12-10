unit CrossClientDataSet;

//{$R-,T-,H+,X+}

interface

uses
  Windows, Messages, SysUtils, Classes, typinfo, variants, DB, DBClient,
  Dialogs, MaskUtils;

type

  TCrossFieldType = (CftSmallint, CftInteger, CftWord, CftLargeint, CftAutoInc,
    CftCurrency, CftBCD, CftFloat, CftBoolean, CftDate, CftTime, CftDateTime,
    CftTimeStamp, CftBlob, CftMemo, CftGraphic, CftWideString, CftString);
  TFieldTotalMethod = (FTM_MIN, FTM_MAX, FTM_SUM, FTM_AVG, FTM_COUNT, FTM_COUNTNOTNULL,
    FTM_AVGNOTNULL, FTM_MAXNOTNULL, FTM_MINNOTNULL, FTM_UNKNOWN);
   //合计方法
  TCCDFdKind = (ccdRow, ccdData, ccdCalculated, ccdOther);
    //字段类型,行字段,数据字段,计算字段
  TOnUpdateTotalValue = procedure(TotalV: Variant) of object;

  //只有TNumFieldType才能进行swAddValue
  TNumFieldType = CftSmallint..CftFloat;
  TIntNumFieldType = CftSmallint..CftAutoInc;
  TRealNumFieldType = CftCurrency..CftFloat;

  TOnSetFieldFormat = procedure(SetField: TField; FdKind: TCCDFdKind) of object;
  TOnGetFieldTotalMethod = procedure(SetField: TField; FdKind: TCCDFdKind; var TotalMethod: TFieldTotalMethod) of object;
  TOnGetFieldClass = procedure(FieldName: string; FdKind: TCCDFdKind; var cft: TCrossFieldType) of
    object;
  TOnCustomCalcField = procedure(Field: TField; CustMethod: string) of object;

  TFieldFormat = class(TComponent)
  //用于设置字段格式的类
  private
    FAlignment: TAlignment;
    FDisplayLabel, FDisplayFormat, FEditFormat: string;
    FSize, FDisplayWidth, FPrecision: Integer;
    FEditMask: TEditMask;
    FRequired, FVisible, FCurrency: boolean;
    FMaxValue, FMinValue: Double;
  published
    property Alignment: TAlignment read FAlignment write FAlignment;
    property DisplayLabel: string read FDisplayLabel write FDisplayLabel;
    property DisplayFormat: string read FDisplayFormat write FDisplayFormat;
    property EditFormat: string read FEditFormat write FEditFormat;
    property Size: Integer read FSize write FSize;
    property DisplayWidth: Integer read FDisplayWidth write FDisplayWidth;
    property Visible: boolean read FVisible write FVisible;
    property Precision: Integer read FPrecision write FPrecision;
    property EditMask: TEditMask read FEditMask write FEditMask;
    property Required: Boolean read FRequired write FRequired;
    property Currency: Boolean read FCurrency write FCurrency;
    property MaxValue: Double read FMaxValue write FMaxValue;
    property MinValue: Double read FMinValue write FMinValue;
  end;

  TInterDataSetTotal = class(TComponent)
  private
    FEnabled, FPause: boolean;
    FDefalutRowTotalMethod, FDefalutDataTotalMethod, FDefalutCalcTotalMethod: TFieldTotalMethod;
  public
    TotalValue: Variant;
    procedure Pause;
    procedure Resume;
  published
    property Enabled: boolean read FEnabled write FEnabled;
    property DefalutRowTotalMethod: TFieldTotalMethod read FDefalutRowTotalMethod write FDefalutRowTotalMethod;
    property DefalutCalcTotalMethod: TFieldTotalMethod read FDefalutCalcTotalMethod write FDefalutCalcTotalMethod;
    property DefalutDataTotalMethod: TFieldTotalMethod read FDefalutDataTotalMethod write FDefalutDataTotalMethod;
  end;

  TCustomCrossDataSet = class(TCustomClientDataSet)
  private
    { Private declarations }
    FRowFieldName: string;
    FColFieldClass, FCalcFieldClass, FRowFieldClass: TCrossFieldType;
    FColLists, FRowLists, FCalcLists: TStrings;
    {整个数据集的字段为: FRowFieldName,FColLists,FCalcLists
    行列计算列表,读取去遍历并保存到列表,写的话则保存到列表,并且只能在数据集未创建的时候写,这也是一个办法
    }
    FOnGetFieldClass: TOnGetFieldClass;
    //缺省为FColFieldClass,FCalcFieldClass,但提供具体到每个字段时不同设置
    FOnSetFieldFormat: TOnSetFieldFormat;
    //设置字段格式
    FOnCustomCalcFields: TOnCustomCalcField;
    FOnGetFieldTotalMethod: TOnGetFieldTotalMethod;
    FDefaultDataFieldFormat, FDefaultCalcFieldFormat, FDefaultRowFieldFormat: TFieldFormat;
    FVersion: string;
    FInterDataSetTotaler: TInterDataSetTotal;
    FAfterDelete, FAfterPost, FAfterOpen, FAfterClose: TDataSetNotifyEvent;
    FOnUpdateTotalValue: TOnUpdateTotalValue;
    procedure SetColLists(V: TStrings);
    procedure SetRowLists(V: TStrings);
    procedure SetCalcLists(V: TStrings);
    //下面二函数以遍历方式构造交叉表行列列表
    procedure InCalcFields(DataSet: TDataSet);
    function GetColstrings: TStrings;
    function GetRowstrings: TStrings;
    function GetCalcstrings: TStrings;

    procedure SetVersion(v: string);
    procedure SetRowFieldName(v: string);

    procedure SelfAfterPost(DataSet: TDataSet);
    procedure SelfAfterOpen(DataSet: TDataSet);
    procedure SelfAfterClose(DataSet: TDataSet);
    procedure SelfAfterDelete(DataSet: TDataSet);
    //重载原来的事件,在事件中刷新数据
    function GetCurrRow: Variant;
    function GetIRowField: TField;
    function FindRepeat: boolean;
  protected
    { Protected declarations }

  public
    { Public declarations }
    property RowFieldName: string read FRowFieldName write SetRowFieldName;
    //行值字段名
    property ColFieldClass: TCrossFieldType read FColFieldClass write
      FColFieldClass;
    //缺省列的字段类
    property CalcFieldClass: TCrossFieldType read FCalcFieldClass write
      FCalcFieldClass;
    //行字段的缺省类
    property RowFieldClass: TCrossFieldType read FRowFieldClass write
      FRowFieldClass;
    //计算字段的缺省类
    property CalcLists: TStrings read GetCalcstrings write SetCalcLists;
    //计算字段列表
    property ColLists: TStrings read GetColstrings write SetColLists;
    //交叉表的所有列,不包括计算列和行字段列
    property RowLists: TStrings read GetRowstrings write SetRowLists;

    //取交叉表的所有行,如果当前在编辑状态,必须先保存
    //行列列表都只能在未创建数据集的时候进行设置

    property DefaultDataFieldFormat: TFieldFormat read FDefaultDataFieldFormat;
    property DefaultRowFieldFormat: TFieldFormat read FDefaultRowFieldFormat;
    property DefaultCalcFieldFormat: TFieldFormat read FDefaultCalcFieldFormat;

    property InterDataSetTotaler: TInterDataSetTotal read FInterDataSetTotaler;
    //合计器

    property IRowField: TField read GetIRowField;
    //交叉表的行值字段,也就是FRowFieldName字段
    property CurrRow: Variant read GetCurrRow;
    //取交叉表当前行的行值(FRowFieldName字段值)
    procedure ClearValues(v: Variant);
    //设置所有列字段(数据字段)值,v=null则清空所有数据,但不包括结构
    procedure ClearAll;
    //清除交叉表全部数据,包括结构

    procedure SkipInsert;
    procedure SkipPost;
    procedure SkipDelete;
    //越过相关事件直接插入,提交,删除
    //提供行列反转方法

    //定义一个刷新统计值的虚方法virtual;
    //统计值在afterOpen,Afterdelete,AfterPost后要刷新统计值
    //如果是主从表,mastersouce发生改变也应该刷新统计值的
    procedure RefreshTotal;
    procedure InsertCol(Col: string; Index: Integer; defaultvalue: Variant);
    procedure DeleteCol(Col: string);
    procedure InsertRow(Row: Variant; defaultvalue: Variant);
    procedure DeleteRow(Row: string);
    //插入/删除  行/列,可以指定缺省值,缺省值也可以为NULL
    function RowExist(Row: string): boolean;
    function ColExist(Col: string): boolean;
    //判断行列是否存在  TFields

    function SumTotalValue(FieldList: string;
      TotalMode: string): Variant;
    //进行行合计

    function CreateEmpty: boolean;
    //创建交叉表,数据均为空,rowlists允许为''

    procedure ApplyFieldFormat;
    //引发设置交叉表字段格式事件

    function IsDataField(Field: TField): boolean;
    //是否是一个计算字段

    function SumDataField(Mode: string): Extended;
    //合计计算字段,仅对数值型字段有效

    procedure SaveDt(var dt: TCustomClientDataSet);
    //保存交叉表当前数据到一个临时的TClientDataset,dt在函数内部创建
    procedure ResumeOri(dt: TCustomClientDataSet; NotRe: string);
    //将dt的数据恢复到交叉表,id=''则恢复所有数据,NotRe<>''则此列不恢复.不管哪种情况,
    //数据均以覆盖的方式写重叠数据,但不会删除不冲突的数据.

    function IsInterCalc(CalcMethod: string): boolean;
    //计算方法是否一个内部计算方法

    //在创建数据集的时候应该提供添加计算字段的功能

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OnGetFieldClass: TOnGetFieldClass read FOnGetFieldClass write FOnGetFieldClass;
    property OnSetFieldFormat: TOnSetFieldFormat read FOnSetFieldFormat write FOnSetFieldFormat;
    property OnGetFieldTotalMethod: TOnGetFieldTotalMethod read FOnGetFieldTotalMethod write FOnGetFieldTotalMethod;
    property OnCustomCalcFields: TOnCustomCalcField read FOnCustomCalcFields write FOnCustomCalcFields;
    property OnUpdateTotalValue: TOnUpdateTotalValue read FOnUpdateTotalValue write FOnUpdateTotalValue;
    //覆盖原事件
    property AfterDelete: TDataSetNotifyEvent read FAfterDelete write FAfterDelete;
    property AfterPost: TDataSetNotifyEvent read FAfterPost write FAfterPost;
    property AfterOpen: TDataSetNotifyEvent read FAfterOpen write FAfterOpen;
    property AfterClose: TDataSetNotifyEvent read FAfterClose write FAfterClose;

  published
    property Version: string read FVersion write SetVersion;
  end;


  TCrossDataSet = class(TCustomCrossDataSet)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DefaultDataFieldFormat;
    property DefaultRowFieldFormat;
    property DefaultCalcFieldFormat;

    property RowFieldName;
    property ColFieldClass;
    property CalcFieldClass;
    property RowFieldClass;
    property CalcLists;
    property ColLists;
    property RowLists;
    property InterDataSetTotaler;

    //事件
    property OnGetFieldClass;
    property OnSetFieldFormat;
    property OnCustomCalcFields;
    property OnGetFieldTotalMethod;
    property OnUpdateTotalValue;
    //-------------------------------------------
    property Active;
    property Aggregates;
    property AggregatesActive;
    //property AutoCalcFields;
    //property CommandText;
    //property ConnectionBroker;
    property Constraints;
    //property DataSetField;
    property DisableStringTrim;
    property FileName;
    property Filter;
    property Filtered;
    property FilterOptions;
    //property FieldDefs;
    property IndexDefs;
    property IndexFieldNames;
    property IndexName;
    //property FetchOnDemand;
    property MasterFields;
    property MasterSource;
    property ObjectView;
    //property PacketRecords;
    //property Params;
    //property ProviderName;
    property ReadOnly;
    //property RemoteServer;
    property StoreDefs;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property BeforeRefresh;
    property AfterRefresh;
    //property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    //property OnReconcileError;
    //property BeforeApplyUpdates;
    //property AfterApplyUpdates;
    //property BeforeGetRecords;
    //property AfterGetRecords;
    //property BeforeRowRequest;
    //property AfterRowRequest;
    //property BeforeExecute;
    //property AfterExecute;
    //property BeforeGetParams;
    //property AfterGetParams;
  end;

const
  calcmethodlist: array[0..8] of string = ('min', 'max', 'sum', 'avg', 'count',
    'countnotnull', 'avgnotnull', 'maxnotnull', 'minnotnull');

  NumFieldTypes = [CftSmallint, CftInteger, CftWord, CftLargeint, CftAutoInc,
    CftCurrency, CftBCD, CftFloat];
  IntNumFieldTypes = [CftSmallint, CftInteger, CftWord, CftLargeint, CftAutoInc];
  RealNumFieldTypes = [CftCurrency, CftBCD, CftFloat];

  FTClass: array[CftSmallint..CftString] of TFieldClass =
  (TSmallIntField, TIntegerField, TWordField, TLargeintField, TAutoIncField,
    TCurrencyField, TBCDField, TFloatField, TBooleanField, TDateField,
    TTimeField, TDateTimeField,
    TSQLTimeStampField, TBlobField, TMemoField, TGraphicField, TWideStringField,
    TStringField);
  alreadyreg: boolean = true;

function TCFT2TFT(value: TCrossFieldType): TFieldType;
function TFT2TCFT(value: TFieldType): TCrossFieldType;
//字段格式转换

//根据字段类别得到字段格式
function GetFieldType(FieldClass: TfieldClass): TFieldType;
//根据字段格式得到字段类别直接用ftclass


procedure ClearRepeatLine(var str: string); overload;
procedure ClearRepeatLine(v: TStrings); overload;
//清除重复行和空行


//统计方法与字符串转换
function InterTotalMethod2String(ftm: TFieldTotalMethod): string;
function String2InterTotalMethod(mdn: string): TFieldTotalMethod;

procedure Register;
implementation


function InterTotalMethod2String(ftm: TFieldTotalMethod): string;
begin
  Result := GetEnumName(TypeInfo(TFieldTotalMethod), ord(ftm));
  Delete(Result, 1, 4);
  if Result = '' then Result := 'UNKNOWN';
end;

function String2InterTotalMethod(mdn: string): TFieldTotalMethod;
begin
  mdn := 'FTM_' + Uppercase(Trim(mdn));
  try
    Result := TFieldTotalMethod(GetEnumValue(TypeInfo(TCrossFieldType), mdn));
  except
    Result := FTM_UNKNOWN;
  end;
end;


function replacestr(srcstr, bg, tostr: AnsiString; case1: boolean = false): AnsiString;
var
  id, len: integer;
  restr, src: AnsiString;
begin
//字符串取代函数,case1表示是否区分大小写
  len := Length(bg);
  if len = 0 then
  begin
    result := srcstr;
    Exit;
  end;
  restr := '';
  if not case1 then
  begin
    src := UpperCase(srcstr);
    bg := UpperCase(bg);
  end
  else src := srcstr;
  id := AnsiPos(bg, src);
  while (id <> 0) do
  begin
    restr := restr + Copy(srcstr, 1, id - 1);
    Delete(src, 1, id - 1 + len);
    Delete(srcstr, 1, id - 1 + len);
    restr := restr + tostr;
    id := AnsiPos(bg, src);
  end;
  restr := restr + srcstr;
  result := restr;
end;


function TCFT2TFT(value: TCrossFieldType): TFieldType;
var
  ename: string;
begin
  ename := GetEnumName(TypeInfo(TCrossFieldType), ord(value));
  Delete(ename, 1, 1);
  Result := TFieldType(GetEnumValue(TypeInfo(TFieldType), ename));
end;

function TFT2TCFT(value: TFieldType): TCrossFieldType;
var
  ename: string;
begin
  ename := GetEnumName(TypeInfo(TFieldType), ord(value));
  ename := 'C' + ename;
  Result := TCrossFieldType(GetEnumValue(TypeInfo(TCrossFieldType), ename));
end;

procedure ClearRepeatLine(var str: string);
var
  list1, list2: TStringList;
  i: Integer;
  lsstr: string;
begin
  list1 := TStringList.Create;
  list2 := TStringList.Create;
  list1.Text := str;
  for i := 0 to list1.Count - 1 do
  begin
    lsstr := Trim(list1.Strings[i]);
    if (list2.IndexOf(lsstr) = -1)
      and (lsstr <> '') then
      list2.Add(lsstr);
  end;
  str := list2.Text;
  list2.Free;
  list1.Free;
end;

procedure ClearRepeatLine(v: TStrings);
var
  lsstr: string;
begin
  lsstr := v.Text;
  ClearRepeatLine(lsstr);
  v.Text := lsstr;
end;

procedure ISetPropValue(Sender: TObject; Name: string; v: Variant);
begin
  //如何消除组件内的try except 调试警告
  if getpropinfo(sender,name)<>nil then
  try
    SetPropValue(Sender, Name, v);
  except
  end;

end;

function GetFieldType(FieldClass: TfieldClass): TFieldType;
var
  i: TCrossFieldType;
begin
  for i := Low(FTClass) to High(FTClass) do
  begin
    if FTClass[i] = FieldClass then
    begin
      Result := TCFT2TFT(i);
      exit;
    end;
  end;
  Result := ftUnknown;
end;

procedure SetFieldFormat(Sender: TField; Ft: TFieldFormat);
begin
//消除调试警告
  ISetPropValue(Sender, 'Alignment', Ft.Alignment);
  ISetPropValue(Sender, 'DisplayLabel', Ft.DisplayLabel);
  ISetPropValue(Sender, 'EditFormat', Ft.EditFormat);
  ISetPropValue(Sender, 'DisplayFormat', Ft.DisplayFormat);
  ISetPropValue(Sender, 'Size', Ft.Size);
  ISetPropValue(Sender, 'DisplayWidth', Ft.DisplayWidth);
  ISetPropValue(Sender, 'Visible', Ft.Visible);

  ISetPropValue(Sender, 'Precision', Ft.Precision);
  ISetPropValue(Sender, 'EditMask', Ft.EditMask);
  ISetPropValue(Sender, 'Required', Ft.Required);
  ISetPropValue(Sender, 'Currency', Ft.Currency);

  if TFT2TCFT(GetFieldType(TFieldClass(Sender.ClassType))) in IntNumFieldTypes then
  begin
    ISetPropValue(Sender, 'MaxValue', Trunc(Ft.MaxValue));
    ISetPropValue(Sender, 'MinValue', Trunc(Ft.MinValue))
  end
  else if TFT2TCFT(GetFieldType(TFieldClass(Sender.ClassType))) in RealNumFieldTypes then
  begin
    ISetPropValue(Sender, 'MaxValue', Ft.MaxValue);
    ISetPropValue(Sender, 'MinValue', Ft.MinValue);
  end;
end;




procedure TCustomCrossDataSet.ApplyFieldFormat;
var
  i: Integer;
  ccdfd: TCCDFdKind;
begin
  //if VarisNull(Data) then exit;
  //在Createempty时根本还没有创建数据集
  for i := 0 to Fields.Count - 1 do
  begin
    if (CompareText(Fields[i].FieldName, FRowFieldName) = 0) and
      (Fields[i].FieldKind = fkData) then
    begin
      ccdfd := ccdRow;
    end
    else if (Fields[i].FieldKind = fkData) then
    begin
      ccdfd := ccdData;
    end
    else if (Fields[i].FieldKind = fkCalculated) then
    begin
      ccdfd := ccdCalculated;
    end
    else
      ccdfd := ccdother;

    if Assigned(FOnSetFieldFormat) then
      FOnSetFieldFormat(Fields[i], ccdfd);
      //Fields[i].FieldKind := fkData;
      //字段类型是不允许改变的
  end;
end;

procedure TCustomCrossDataSet.SkipInsert;
var
  af, bf: TDataSetNotifyEvent;
  OldReadOnly: boolean;
begin
  af := AfterInsert;
  bf := BeforeInsert;
  AfterInsert := nil;
  BeforeInsert := nil;
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  try
    Insert;
  finally
    ReadOnly := oldReadOnly;
    AfterInsert := af;
    BeforeInsert := bf;
  end;
end;

procedure TCustomCrossDataSet.SkipPost;
var
  af, bf: TDataSetNotifyEvent;
  OldReadOnly: boolean;
begin
  FInterDataSetTotaler.Pause;
  af := AfterPost;
  {可以改变自身的afterpost事件,但TDataset的afterpost还是执行了,在这个事件中
  除了执行afterpost事件外,还会根据设置执行合计,所以要禁止合计
  }
  bf := BeforePost;
  AfterPost := nil;
  BeforePost := nil;
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  try
    Post;
  finally
    FInterDataSetTotaler.Resume;
    ReadOnly := oldReadOnly;
    AfterPost := af;
    BeforePost := bf;
  end;
  RefreshTotal;
end;

procedure TCustomCrossDataSet.SkipDelete;
var
  af, bf: TDataSetNotifyEvent;
  OldReadOnly: boolean;
begin
  FInterDataSetTotaler.Pause;
  af := AfterDelete;
  bf := BeforeDelete;
  BeforeDelete := nil;
  AfterDelete := nil;
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  try
    Delete;
  finally
    FInterDataSetTotaler.Resume;
    ReadOnly := oldReadOnly;
    BeforeDelete := bf;
    AfterDelete := af;
  end;
  RefreshTotal;
end;

procedure TCustomCrossDataSet.SetColLists(V: TStrings);
begin
  if VarisNull(Data) then
  begin
    ClearRepeatLine(V);
    FColLists.Assign(V);
    //应该判断其他字段是否有重复值
  end
  else
  begin
    raise Exception.Create('只能在创建数据集之前设置ColLists');
  end;
end;

procedure TCustomCrossDataSet.SetCalcLists(V: TStrings);
var
  i: Integer;
  nm, mdm: string;
begin
  if VarisNull(Data) then
  begin
    ClearRepeatLine(V);
    FCalcLists.Clear;
    for i := 0 to V.Count - 1 do
    begin
      nm := Trim(V.Names[i]);
      mdm := Trim(V.Values[V.Names[i]]);
      if nm <> '' then
      begin
        FCalcLists.Add(nm + '=' + mdm);
      end;
    end;
  end
  else
  begin
    raise Exception.Create('只能在创建数据集之前设置CalcLists');
  end;
end;

procedure TCustomCrossDataSet.SetRowLists(V: TStrings);
begin
  if VarisNull(Data) then
  begin
    FRowLists.Assign(V);
    ClearRepeatLine(FRowLists);
  end
  else
  begin
    raise Exception.Create('只能在创建数据集之前设置RowLists');
  end;
end;

function TCustomCrossDataSet.GetCurrRow: Variant;
begin
  if VarisNull(Data) or not Active then
    Result := ''
  else
    Result := FieldByName(FRowFieldName).AsVariant;
end;

function TCustomCrossDataSet.GetIRowField: TField;
begin
 { if VarisNull(Data) then
    Result := nil
    }
  Result := Fields.FindField(FRowFieldName);
  //findfield不会产生异常
  // FieldByName(FRowFieldName);
end;

{
procedure TCrossClientDataSet.SetDataSet(Value: TDataSet);
begin
  if (Value is TDataset) and (Value = self) then
  begin
    raise Exception.Create('不能将数据集设置为自身');
  end;
  FDataSet := Value;
end;
 }

function TCustomCrossDataSet.GetColstrings: Tstrings;
var
  i: Integer;
begin
  Result := FColLists;
  if not varisnull(data) then
  begin
    //若尚未创建数据集,FCollists保存用来创建数据集的字段列表,是不能Clear的
    FColLists.Clear;
    for i := 0 to Fields.Count - 1 do
    begin
      if IsDataField(Fields[i]) then
        FColLists.Add(Fields[i].FieldName);
    end;
  end;
end;

function TCustomCrossDataSet.GetCalcstrings: Tstrings;
{var
  i: Integer;
  }
begin
  Result := FCalcLists;
  {
  if not varisnull(data) then
  begin
    FCalcLists.Clear;
    for i := 0 to Fields.Count - 1 do
    begin
      if (Fields[i].FieldKind = fkCalculated)
        then
        FColLists.Add(Fields[i].FieldName);
    end;
  end;
  }
  //不允许添加计算字段,因为计算字段列表是包含计算方法的
end;

function TCustomCrossDataSet.GetRowstrings: Tstrings;
var
  bk: string;
begin
  Result := FRowLists;
  if VarisNull(data) then
    exit
  else
    if not Active then
      Active := true;
  //访问data时如果在编辑状态下会自动Post,所以此时肯定不在编辑状态
  DisableControls;
  bk := Bookmark;
  First;
  FRowLists.Clear;
  while (not Eof) do
  begin
    FRowLists.Add(FieldByName(FRowFieldName).AsString);
    Next;
  end;
  bookmark := bk;
  EnableControls;
end;

function TCustomCrossDataSet.CreateEmpty: boolean;
var
  i: Integer;
  errormes: string;
  afd, bfd, afp, bfp: TDataSetNotifyEvent;
  OldReadOnly: boolean;
  Fd: TField;
  cft: TCrossFieldType;
begin
  if Trim(FRowFieldName) = '' then
    raise Exception.Create('请先指定RowFieldName');

  if FColLists.Count < 1 then
    raise Exception.Create('至少需要一个数据字段,请设置ColLists');

  FindRepeat;
  //检测是否有重复字段

  ClearAll;
  oldReadOnly := ReadOnly;
  ReadOnly := false;

  //增加行值字段,(行值字段缺省应该为只读的)
  cft := FRowFieldClass;
  if Assigned(FOnGetFieldClass) then
    FOnGetFieldClass(FRowFieldName, ccdRow, cft);
  Fd := FTClass[cft].Create(self);
  Fd.FieldName := FRowFieldName;
  Fd.Name := Self.Name + 'RowF' + IntToStr(Self.FieldCount + 1);
  Fd.DataSet := Self;
  SetFieldFormat(Fd, FDefaultRowFieldFormat);

  //增加列值字段
  for i := 0 to FColLists.Count - 1 do
  begin
    cft := FColFieldClass;
    if Assigned(FOnGetFieldClass) then
      FOnGetFieldClass(FColLists.Strings[i], ccdData, cft);
    Fd := FTClass[cft].Create(self);
    Fd.FieldName := FColLists.Strings[i];
    Fd.Name := Self.Name + 'DataF' + IntToStr(Self.FieldCount + 1);
    Fd.DataSet := Self;
    SetFieldFormat(Fd, FDefaultDataFieldFormat);
    Fd.DisplayLabel := Fd.FieldName;
  end;

  //增加计算字段
  ClearRepeatLine(FCalcLists);
  for i := 0 to FCalcLists.Count - 1 do
  begin
    cft := FCalcFieldClass;
    if Assigned(FOnGetFieldClass) then
      FOnGetFieldClass(FCalcLists.Strings[i], ccdCalculated, cft);
    Fd := FTClass[cft].Create(self);
    Fd.FieldName := FCalcLists.Names[i];
    Fd.Name := Self.Name + 'CalcF' + IntToStr(Self.FieldCount + 1);
    Fd.FieldKind := fkCalculated;
    Fd.DataSet := Self;
    SetFieldFormat(Fd, FDefaultCalcFieldFormat);
    Fd.DisplayLabel := Fd.FieldName;
  end;


  //设置字段格式
  ApplyFieldFormat;

  //创建数据集,会自动Open
  CreateDataSet;

  //按指定行添加数据
  errormes := '';
  FInterDataSetTotaler.Pause;
  afd := AfterInsert;
  bfd := BeforeInsert;
  afp := AfterPost;
  bfp := BeforePost;
  AfterInsert := nil;
  BeforeInsert := nil;
  AfterPost := nil;
  BeforePost := nil;
  DisableControls;
  try
    //最好不要用RowLists,因为RowLists调用GetRowstrings
    ClearRepeatLine(FRowLists);
    for i := 0 to FRowlists.count - 1 do
    begin
      Insert;
      FieldByName(FRowFieldName).AsVariant := FRowLists.Strings[i];
      Post;
    end;
  except
    on e: Exception do
      errormes := e.Message;
  end;
  FInterDataSetTotaler.Resume;
  AfterInsert := afd;
  BeforeInsert := bfd;
  AfterPost := afp;
  BeforePost := bfp;
  if Active then
  begin
    First;
    RefreshTotal;
  end;
  EnableControls;
  ReadOnly := oldReadOnly;
  if errormes <> '' then
    raise Exception.Create(errormes);
  Result := true;
end;

procedure TCustomCrossDataSet.ClearValues(v: Variant);
var
  i: Integer;
  afp, bfp, afe, bfe: TDataSetNotifyEvent;
  bk: string;
  OldReadOnly: boolean;
begin
  if VarisNull(data) then
    exit;
  if not Active then
    Active := true;
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  FInterDataSetTotaler.Pause;
  afp := AfterPost;
  bfp := BeforePost;
  afe := AfterEdit;
  bfe := BeforeEdit;
  AfterPost := nil;
  BeforePost := nil;
  AfterEdit := nil;
  BeforeEdit := nil;
  bk := bookmark;
  DisableControls;
  try
    First;
    while (not Eof) do
    begin
      Edit;
      for i := 0 to Fields.Count - 1 do
      begin
        if IsDataField(Fields[i]) then
          Fields[i].AsVariant := v;
      end;
      Post;
      Next;
      //scoll事件呢?在try中,Abort方法也能引发一个异常
    end;
  except
  end;
  FInterDataSetTotaler.Resume;
  AfterEdit := afe;
  BeforeEdit := bfe;
  AfterPost := afp;
  BeforePost := bfp;
  bookmark := bk;
  RefreshTotal;
  EnableControls;
  ReadOnly := oldReadOnly;
end;

procedure TCustomCrossDataSet.ClearAll;
var
  OldReadOnly: boolean;
begin
  {
  if VarisNull(Data) then
    exit;
  }
  if Active then
    Active := false;
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  Data := Null;
  IndexDefs.Clear;
  Fields.Clear;
  FieldDefs.Clear;
  ReadOnly := oldReadOnly;
end;
{
特别需要注意的是
FieldDefs会自动与Fields对应的,如果新加字段TFileds,而FieldDefs非空,则会出错的
ClientDataSet1.FieldDefs.Add(fd.FieldName,ftBCD,fd.Size,fd.Required);
}

function TCustomCrossDataSet.RowExist(Row: string): boolean;
begin
  //这种判断是基于字符串判断,对于不同的类型呢?
  //最好是都转换为字符串!
  Result := false;
  Row := Trim(Row);
  if (Row = '') or VarisNull(data) then
    exit;
  if GetRowstrings.IndexOf(Row) <> -1 then
    Result := true;
end;

function TCustomCrossDataSet.ColExist(Col: string): boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to Fields.Count - 1 do
  begin
    if CompareText(Col, Fields[i].FieldName) = 0 then
    begin
      //comparetext不区分大小写
      Result := true;
      exit;
    end;
  end;
end;

procedure TCustomCrossDataSet.SaveDt(var dt: TCustomClientDataSet);
begin
  dt := TClientDataSet.Create(self);
  dt.Data := Data;
end;

procedure TCustomCrossDataSet.resumeori(dt: TCustomClientDataSet; NotRe: string);
var
  i: Integer;
  afd, bfd, afp, bfp, afe, bfe: TDataSetNotifyEvent;
  bk: string;
  errormes: string;
  OldReadOnly: boolean;
begin
  //复制数据回原来的数据集,当前数据集必须具有原数据集的所有字段
  //id表示不复制的数据列(index),=0时忽略它
  if VarisNull(dt.Data) or VarisNull(Data) then
    exit;
  if not dt.Active then
    dt.Active := true;
  if not Active then
    Active := true;

  Notre := Trim(Notre);
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  FInterDataSetTotaler.Pause;
  afd := AfterInsert;
  bfd := BeforeInsert;
  afp := AfterPost;
  bfp := BeforePost;
  afe := AfterEdit;
  bfe := BeforeEdit;
  AfterPost := nil;
  BeforePost := nil;
  AfterEdit := nil;
  BeforeEdit := nil;
  AfterInsert := nil;
  BeforeInsert := nil;
  bk := bookmark;
  DisableControls;
  dt.DisableControls;
  dt.First;
  errormes := '';
  try
    while not dt.Eof do
    begin
      if Locate(FRowFieldName, dt.FieldByName(FRowFieldName).asVariant, []) then
        Edit
      else
      begin
        Append;
        FieldByName(FRowFieldName).AsVariant :=
          dt.FieldByName(FRowFieldName).AsVariant;
      end;
      for i := 0 to dt.Fields.Count - 1 do
      begin
        if (CompareText(FRowFieldName, dt.Fields[i].FieldName) <> 0) and
          ((Notre = '') or (CompareText(dt.Fields[i].FieldName, Notre) <> 0))
          then
          FieldByName(dt.Fields[i].FieldName).AsVariant :=
            dt.FieldByName(dt.Fields[i].FieldName).AsVariant;
      end;
      Post;
      dt.Next;
    end;
  except
    on E: Exception do
      errormes := E.Message;
  end;
  FInterDataSetTotaler.Resume;
  dt.EnableControls;
  AfterEdit := afe;
  BeforeEdit := bfe;
  AfterPost := afp;
  BeforePost := bfp;
  AfterInsert := afd;
  BeforeInsert := bfd;
  bookmark := bk;
  RefreshTotal;
  EnableControls;
  ReadOnly := oldReadOnly;
  if errormes <> '' then
    raise Exception.Create(errormes);
end;

//删除列,添加列,删除行,添加行,复制数据集

procedure TCustomCrossDataSet.DeleteCol(Col: string);
var
  dt: TCustomClientDataSet;
  currvalue: Variant;
  errormes: string;
  OldReadOnly: boolean;
  fd: TField;
begin
  Col := Trim(Col);
  if Col = '' then
    exit
  else
    if VarisNull(data) then
      raise Exception.Create('必须先创建数据集才能调用DeleteCol')
    else
      if not ColExist(Col) then
        exit;

  if not Active then
    Active := true;
  currvalue := FieldByName(FRowFieldName).AsVariant;
  Active := false;
  savedt(dt);
  fd := Fields.FieldByName(Col);
  FieldDefs.Delete(FieldDefs.IndexOf(Col));
  Fields.Remove(fd);
  //移除一个列并不会自动Free
  fd.Free;
  errormes := '';
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  try
    CreateDataSet;
  except
    on e: exception do
      errormes := e.Message;
  end;
  ReadOnly := oldReadOnly;
  if errormes = '' then
  begin
    ResumeOri(dt, Col);
  end
  else
  begin
    dt.Free;
    raise Exception.Create(errormes);
  end;
  dt.Free;
  Locate(FRowFieldName, currvalue, []);
end;

procedure TCustomCrossDataSet.InsertCol(Col: string; Index: Integer; defaultvalue: Variant);
  function GetLastDataFieldIndex: Integer;
  var
    i, max: Integer;
  begin
   //读取最后的数据列的index
    max := 0;
    for i := 0 to self.Fields.Count - 1 do
    begin
      if self.IsDataField(self.Fields[i]) then
        max := i;
        //self.Fields[i].Index;
    end;
    Result := max;
  end;
var
  afe, bfe, afp, bfp: TDataSetNotifyEvent;
  bk: string;
  dt: TCustomClientDataSet;
  currvalue: Variant;
  errormes: string;
  cft: TCrossFieldType;
  OldReadOnly: boolean;
  fd: TField;
  maxi: Integer;
begin
  //访问字段的data属性时,如果数据尚未post,将会自动post
  //0/-1自动插到最后(数据列的最后搁置)
  Col := Trim(Col);
  if Col = '' then
    exit
  else
    if VarisNull(data) then
      raise Exception.Create('必须先创建数据集才能调用InsertCol')
    else
      if ColExist(Col) then
        exit;

  if not Active then
    Active := true;
  currvalue := FieldByName(FRowFieldName).AsVariant;
  Active := false;
  savedt(dt);
  cft := FColFieldClass;
  if Assigned(FOnGetFieldClass) then
    FOnGetFieldClass(Col, ccdData, cft);
  Fd := FTClass[cft].Create(self);
  Fd.FieldName := Col;
  Fd.Name := Self.Name + 'DataF' + IntToStr(Self.FieldCount + 1);
  SetFieldFormat(Fd, FDefaultDataFieldFormat);
  maxi := GetLastDataFieldIndex;
  Fd.DataSet := Self;
  if (Index > maxi) or (Index <= 0) then Index := maxi + 1;
  //自动插入到最后
  Fd.Index := Index;
  //0为指定的行字段,是不能改变的
  FieldDefs.Add(fd.FieldName, ftBCD, fd.Size, fd.Required);
  //
  errormes := '';
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  try
    if Assigned(FOnSetFieldFormat) then
      FOnSetFieldFormat(FD, ccddata);
   //保证必须是数据列字段
    Fd.FieldKind := fkData;
    CreateDataSet;
  except
    on e: exception do
      errormes := e.Message;
  end;
  ReadOnly := oldReadOnly;
  if errormes = '' then
  begin
    ResumeOri(dt, '');
  end
  else
  begin
    dt.Free;
    raise Exception.Create(errormes);
  end;
  dt.Free;
  Locate(FRowFieldName, currvalue, []);
  FInterDataSetTotaler.Pause;
  afp := AfterPost;
  bfp := BeforePost;
  afe := AfterEdit;
  bfe := BeforeEdit;
  AfterPost := nil;
  BeforePost := nil;
  AfterEdit := nil;
  BeforeEdit := nil;
  DisableControls;
  bk := bookmark;
  First;
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  try
    while (not Eof) do
    begin
      Edit;
      FieldByName(Col).AsVariant := defaultvalue;
      Post;
      Next;
    end;
  finally
    FInterDataSetTotaler.Resume;
    ReadOnly := oldReadOnly;
    AfterEdit := afe;
    BeforeEdit := bfe;
    AfterPost := afp;
    BeforePost := bfp;
    bookmark := bk;
    RefreshTotal;
    EnableControls;
  end;
end;

procedure TCustomCrossDataSet.DeleteRow(Row: string);
begin
  Row := Trim(Row);
  if VarisNull(data) or (Row = '') or not Rowexist(row) then
    exit;
  //rowexist会自动open
  if Locate(FRowFieldName, Row, []) then
    SkipDelete;
end;

procedure TCustomCrossDataSet.InsertRow(Row: Variant; defaultvalue: Variant);
var
  i: Integer;
  OldReadOnly: boolean;
begin
  Row := Trim(Row);
  if VarisNull(data) or (Row = '') or Rowexist(row) then
    exit;
  oldReadOnly := ReadOnly;
  ReadOnly := false;
  try
    SkipInsert;
  finally
    ReadOnly := oldReadOnly
  end;
  FieldByName(FRowFieldName).AsVariant := Row;
  for i := 0 to Fields.Count - 1 do
  begin
    if IsDataField(Fields[i]) then
      Fields[i].AsVariant := defaultvalue;
  end;
  try
    SkipPost;
  finally
    ReadOnly := oldReadOnly;
  end;
end;

constructor TCustomCrossDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColLists := TStringList.Create;
  FCalcLists := TStringList.Create;
  FRowLists := TStringList.Create;
  FColFieldClass := cftBCD;
  FRowFieldClass := cftString;
  FCalcFieldClass := cftBCD;

  FDefaultDataFieldFormat := TFieldFormat.Create(self);
  FDefaultCalcFieldFormat := TFieldFormat.Create(self);
  FDefaultRowFieldFormat := TFieldFormat.Create(self);

  FDefaultRowFieldFormat.Alignment := taCenter;
  FDefaultRowFieldFormat.Size := 20;
  FDefaultRowFieldFormat.DisplayWidth := 10;
  FDefaultRowFieldFormat.Visible := true;

  FDefaultCalcFieldFormat.Alignment := taCenter;
  FDefaultCalcFieldFormat.DisplayWidth := 6;
  FDefaultCalcFieldFormat.Precision := 18;
  FDefaultCalcFieldFormat.Size := 3;
  FDefaultCalcFieldFormat.Visible := true;

  FDefaultDataFieldFormat.Alignment := taCenter;
  FDefaultDataFieldFormat.DisplayWidth := 6;
  FDefaultDataFieldFormat.Precision := 18;
  FDefaultDataFieldFormat.Size := 3;
  FDefaultDataFieldFormat.Visible := true;

  FInterDataSetTotaler := TInterDataSetTotal.Create(Self);
  FInterDataSetTotaler.TotalValue := NULL;
  FInterDataSetTotaler.Enabled := false;
  FInterDataSetTotaler.FDefalutRowTotalMethod := FTM_COUNT;
  FInterDataSetTotaler.FDefalutDataTotalMethod := FTM_SUM;
  FInterDataSetTotaler.FDefalutCalcTotalMethod := FTM_SUM;

  FDefaultDataFieldFormat.SetSubComponent(True);
  FDefaultCalcFieldFormat.SetSubComponent(True);
  FDefaultRowFieldFormat.SetSubComponent(True);
  FInterDataSetTotaler.SetSubComponent(True);
  //持久化子类对象,否则FDefaultRowFieldFormat等的设置不会保存到dfm

  OnCalcFields := InCalcFields;
  inherited AfterPost := SelfAfterPost;
  inherited AfterDelete := SelfAfterDelete;
  inherited AfterOpen := SelfAfterOpen;
  inherited AfterClose := SelfAfterClose;

  FVersion := 'V1.01 中国湖南 罗应飞';
end;

destructor TCustomCrossDataSet.Destroy;
begin
  FRowLists.Free;
  FCalcLists.Free;
  FColLists.Free;
  FInterDataSetTotaler.Free;
  FDefaultDataFieldFormat.Free;
  FDefaultCalcFieldFormat.Free; ;
  FDefaultRowFieldFormat.Free; ;

  inherited Destroy;
end;

procedure TCustomCrossDataSet.SetVersion(v: string);
begin
  //运行时段不显示 (csDesigning  in self.ComponentState)  or
  {
  if (not alreadyreg) and not (csDesigning in self.ComponentState) then
    ShowMessage('欢迎使用交叉表控件  中国湖南  罗应飞' +
      #13 + ' http://www.51bcb.com Lynu@sohu.com');
   }
  {
  if (csDesigning in ComponentState) and
    not (csLoading in ComponentState)
    then
  begin
    ShowMessage('V20020917 交叉表数据集控件 功能够强使用方便' +
      #13 + '国产免费VCL控件 中国湖南 罗应飞 2002/09/17 购买源码请联系Lynu@sohu.com');
  end;
  }
end;

procedure TCustomCrossDataSet.SetRowFieldName(v: string);
begin
  if VarisNull(Data) then
    FRowFieldName := Trim(v)
  else
    raise Exception.Create('创建数据集后不能再设置RowFieldName');
end;


function TCustomCrossDataSet.IsDataField(Field: TField): boolean;
begin
  Result := (Field.DataSet = Self) and (Field.FieldKind = fkData) and
    (CompareText(Field.FieldName, FRowFieldName) <> 0);
end;


procedure TCustomCrossDataSet.InCalcFields(DataSet: TDataSet);
var
  i: Integer;
  FdName: string;
begin
  for i := 0 to FCalcLists.Count - 1 do
  begin
    FdName := Trim(FCalcLists.Names[i]);
    if FdName = '' then continue;
    if IsInterCalc(FCalcLists.Values[FdName]) then
    begin
      DataSet.FieldByName(FdName).AsVariant := SumDataField(FCalcLists.Values[FdName]);
    end
    else
    begin
      if Assigned(FOnCustomCalcFields) then
        FOnCustomCalcFields(DataSet.FindField(FdName), FCalcLists.Values[FdName]);
    end;
  end;
end;

function TCustomCrossDataSet.IsInterCalc(CalcMethod: string): boolean;
var
  i: Integer;
begin
  //计算方法是可以扩展的
  Result := false;
  for i := 0 to High(calcmethodlist) do
  begin
    if CompareText(CalcMethod, calcmethodlist[i]) = 0 then
    begin
      Result := true;
      exit;
    end;
  end;
end;

function TCustomCrossDataSet.FindRepeat: boolean;
var
  i, ed: Integer;
  st, repeatmess: TStringList;
begin
  //查找是否有重复的字段名

  ed := 0;
  st := TStringList.Create;
  repeatmess := TStringList.Create;

  st.Add(FRowFieldName);
  for i := 0 to FColLists.Count - 1 do
  begin
    if st.IndexOf(FColLists.Strings[i]) <> -1 then
    begin
      Inc(ed);
      repeatmess.Add('DataColLists中的[' + FColLists.Strings[i] + ']')
    end
    else
      st.Add(FColLists.Strings[i]);
  end;
  for i := 0 to FCalcLists.Count - 1 do
  begin
    if st.IndexOf(FCalcLists.Names[i]) <> -1 then
    begin
      Inc(ed);
      repeatmess.Add('CalcColLists中的[' + FCalcLists.Names[i] + ']')
    end
    else
      st.Add(FCalcLists.Names[i]);
  end;
  st.Free;
  if repeatmess.Count > 0 then
    raise Exception.Create('以下字段重复:' + #13 + repeatmess.Text);
  repeatmess.Free;
  Result := (ed > 0);
end;

function TCustomCrossDataSet.SumDataField(Mode: string): Extended;
var
  rdcount, rdnotnullcount, i: Integer;
begin
  Result := 0;
  rdCount := 0;
  rdnotnullcount := 0;
  Mode := Uppercase(mode);
  for i := 0 to Fields.Count - 1 do
  begin
    if IsDataField(Fields[i]) then
    begin
      if (Mode = 'SUM') or (Mode = 'AVG') or
        ((Mode = 'AVGNOTNULL') and (not Fields[i].IsNull)) then
      begin
        Result := Result + Fields[i].AsFloat;
      end
      else if (Mode = 'MAX') then
      begin
        if (rdCount = 0) or (Result < Fields[i].AsFloat)
          then
          Result := Fields[i].AsFloat
      end
      else if (Mode = 'MAXNOTNULL') and (not Fields[i].IsNull) then
      begin
        if (rdnotnullCount = 0) or (Result < Fields[i].AsFloat)
          then
          Result := Fields[i].AsFloat
      end

      else if (Mode = 'MIN') then
      begin
        if (rdCount = 0) or (Result > Fields[i].AsFloat)
          then
          Result := Fields[i].AsFloat
      end

      else if (Mode = 'MINNOTNULL') and (not Fields[i].IsNull) then
      begin
        if (rdnotnullCount = 0) or (Result > Fields[i].AsFloat)
          then
          Result := Fields[i].AsFloat
      end;

      if not Fields[i].IsNull then
        Inc(rdnotnullcount);
      Inc(rdcount);
    end; //为数据字段
  end; //for

  if Mode = 'AVG' then
  begin
    if rdcount = 0 then
      Result := 0
    else
      Result := Result / rdcount;
  end
  else if Mode = 'AVGNOTNULL' then
  begin
    if rdnotnullcount = 0 then
      Result := 0
    else
      Result := result / rdnotnullcount;
  end
  else if Mode = 'COUNT' then
    Result := rdcount
  else if Mode = 'COUNTNOTNULL' then
    Result := rdnotnullcount;
end;


procedure TCustomCrossDataSet.RefreshTotal;
var
  i: Integer;
  tm: TFieldTotalMethod;
  fdk: TCCDFdKind;
  lsm: string;
  fdn, tmn: string; //字段列表,方法列表.
begin
  //除了open,delete,post外,插入列,添加列,行等均需刷新,
  FInterDataSetTotaler.TotalValue := NULL;
  if not FInterDataSetTotaler.Enabled or not Active
    or (State in dsEditModes) then
  begin
    if Assigned(FOnUpdateTotalValue) then
      FOnUpdateTotalValue(FInterDataSetTotaler.TotalValue);
    exit;
  end;
  fdn := ''; tmn := '';
  for i := 0 to Fields.Count - 1 do
  begin
    if (CompareText(Fields[i].FieldName, FRowFieldName) = 0) and
      (Fields[i].FieldKind = fkData) then
    begin
      tm := FInterDataSetTotaler.FDefalutRowTotalMethod;
      fdk := ccdRow;
    end
    else if self.IsDataField(Fields[i]) then
    begin
      tm := FInterDataSetTotaler.FDefalutDataTotalMethod;
      fdk := ccdData;
    end
    else if Fields[i].FieldKind = fkCalculated then
    begin
      tm := FInterDataSetTotaler.FDefalutCalcTotalMethod;
      fdk := ccdCalculated;
    end
    else
    begin
      tm := FTM_UNKNOWN;
      fdk := ccdother;
    end;
    if Assigned(FOnGetFieldTotalMethod) then
      FOnGetFieldTotalMethod(Fields[i], fdk, tm);
    lsm := InterTotalMethod2String(tm);
    if fdn = '' then fdn := Fields[i].FieldName
    else fdn := fdn + #13 + Fields[i].FieldName;
    if tmn = '' then tmn := lsm
    else
      tmn := tmn + #13 + lsm;
  end;
  FInterDataSetTotaler.TotalValue := SumTotalValue(fdn, tmn);
  if Assigned(FOnUpdateTotalValue) then
    FOnUpdateTotalValue(FInterDataSetTotaler.TotalValue);
end;

procedure TCustomCrossDataSet.SelfAfterPost(DataSet: TDataSet);
begin
  if not FInterDataSetTotaler.FPause then
  begin
    RefreshTotal;
  end;
  if Assigned(FAfterPost) then FAfterPost(Self);
end;

procedure TCustomCrossDataSet.SelfAfterOpen(DataSet: TDataSet);
begin
  if not FInterDataSetTotaler.FPause then RefreshTotal;
  if Assigned(FAfterOpen) then FAfterOpen(Self);
end;

procedure TCustomCrossDataSet.SelfAfterClose(DataSet: TDataSet);
begin
  if not FInterDataSetTotaler.FPause then RefreshTotal;
  if Assigned(FAfterClose) then FAfterClose(Self);
end;

procedure TCustomCrossDataSet.SelfAfterDelete(DataSet: TDataSet);
begin
  if not FInterDataSetTotaler.FPause then RefreshTotal;
  if Assigned(FAfterDelete) then FAfterDelete(Self);
end;


function TCustomCrossDataSet.sumtotalvalue(FieldList: string;
  TotalMode: string): Variant;
var
  fdlist, tmlist: TStringList;
  i, rdcount: integer;
  bk: string;
  ok: boolean;
  FD: TField;
  rdnotnullcount: Variant;
begin
  Result := Null;

  if (Self = nil) or not Self.Active then Exit;
  if Self.State in dsEditModes then exit;
  //then Self.Cancel;

  fdlist := TStringList.Create;
  tmlist := TStringList.Create;

  fieldlist := Trim(fieldlist);
  totalmode := Trim(LowerCase(totalmode));

  fdlist.Text := replacestr(fieldlist, ';', #13);
  tmlist.Text := replacestr(totalmode, ';', #13);

  if (fdlist.Count <> tmlist.Count) or (fdlist.Count < 1) then
  begin
    //参数不等
  end
  else
  begin
    rdnotnullcount := Variants.VarArrayCreate([0, (fdlist.Count - 1)], varInteger);
    Result := Variants.VarArrayCreate([0, (fdlist.Count - 1)], varDouble);
    for i := 0 to fdlist.Count - 1 do
    begin
      Result[i] := 0.00;
      rdnotnullcount[i] := 0;
    end;
    rdcount := 0;
    bk := bookmark;
    Self.DisableControls;
    Self.First;
    ok := true;
    try
      while (not Self.Eof) do
      begin
        for i := 0 to fdlist.Count - 1 do
        begin
          Fd := Self.FieldByName(fdlist[i]);
          if (tmlist[i] = 'sum') or (tmlist[i] = 'avg')
            or ((tmlist[i] = 'avgnotnull') and (not Fd.IsNull)) then
            Result[i] := Result[i] + fd.AsFloat
          else if (tmlist[i] = 'max') then
          begin
            if (rdcount = 0) or (Result[i] < Fd.AsFloat) then
              Result[i] := Fd.AsFloat
          end
          else if (tmlist[i] = 'maxnotnull') and (not Fd.IsNull) then
          begin
            if (rdnotnullCount[i] = 0) or (Result[i] < fd.AsFloat)
              then
              Result[i] := fd.AsFloat
          end
          else if (tmlist[i] = 'min') then
          begin
            if (rdcount = 0) or (Result[i] > fd.AsFloat) then
              Result[i] := fd.AsFloat
          end
          else if (tmlist[i] = 'minnotnull') and (not Fd.IsNull) then
          begin
            if (rdnotnullCount[i] = 0) or (Result[i] > fd.AsFloat)
              then
              Result[i] := fd.AsFloat
          end;
          if not fd.IsNull then rdnotnullcount[i] := rdnotnullcount[i] + 1;
        end;
        inc(rdcount);
        Self.Next;
      end; //while
    except
      ok := false;
    end;
    bookmark := bk;
    if ok = false then
    begin
      Result := NULL
    end
    else
    begin
      if rdcount > 0 then
      begin
        for i := 0 to fdlist.Count - 1 do
        begin
          if (tmlist[i] = 'avg') then
            Result[i] := Result[i] / rdcount
          else if (tmlist[i] = 'count') then
            Result[i] := rdcount
        end;
      end;
      for i := 0 to fdlist.Count - 1 do
      begin
        if (tmlist[i] = 'countnotnull') then
          Result[i] := rdnotnullcount[i]
        else if (tmlist[i] = 'avgnotnull') then
        begin
          if rdnotnullcount[i] = 0 then Result[i] := 0
          else Result[i] := Result[i] / rdnotnullcount[i]
        end
      end;
    end; //成功
  end; //参数数目相同
  Self.EnableControls;
  fdlist.Free;
  tmlist.Free;
end;

//TInterDataSetTotal

procedure TInterDataSetTotal.Pause;
begin
  FPause := true;
end;

procedure TInterDataSetTotal.Resume;
begin
  FPause := false;
end;

//TCrossDataSet

constructor TCrossDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

end;

destructor TCrossDataSet.Destroy;
begin

  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('Kamran Component', [TCrossDataSet]);
end;

end.

