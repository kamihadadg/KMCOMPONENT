unit Untjalalicalender;



interface

uses
   Windows,Vcl.Forms,Vcl.controls, Messages,UntUTIL, SysUtils, Variants,DBCtrls,
    Classes,Vcl.StdCtrls,Vcl.grids,dateutils,Vcl.Samples.Spin ;
type
  TAddSubdate=(Add,Sub);
  TKMJalaliCalender = class(Tcomponent)

  private
    { Private declarations }

    FsYear:TSpinEdit ;
    FMounth:TComboBox ;
    FGrid:TStringGrid ;
    Fshamsi:String[10];

    Month, Day, Year, MonthE, DayE, YearE: Integer;
    Minus: Boolean;
    fcol,frow:Integer ;

    FForm:TForm ;
    FShow:Boolean ;
    Fresult:Boolean ;

    Fedit:TCustomEdit  ;
    FKind:Integer ;







    FUNCTION IsLeapYeartemp(Mil: Boolean): Boolean ;
    FUNCTION DaysInMonthtemp(Mil: Boolean): Integer;
    PROCEDURE SetValue(M, D, Y, ME, DE, YE: Integer);
    procedure dclick(Sender: TObject);
    procedure Deactive(Sender: TObject);
    procedure dclickmodal(Sender: TObject);
    FUNCTION  Lower(SE, SE1: String; Mil: Boolean): Boolean;
    FUNCTION  IsLeapYear(Mil: Boolean): Boolean;
    FUNCTION  GetNumberOfDay(SE, SE1: String; Mil: Boolean): LongInt;
    FUNCTION  GetText(Mil: Boolean): String;
    FUNCTION  DaysInMonth(Mil: Boolean): Integer;

    function  setstring(str1:string;lenstr:integer):string ;

    Procedure ChangeYear(sender:TObject );
    procedure ChangeMounth(sender:TObject );

    procedure cellclick(Sender: TObject; ACol,ARow: Integer; var CanSelect: Boolean);
    FUNCTION  MilToSh(SE: String): String;
    FUNCTION  ShToMil(SE: String): String;
    procedure setgrid (sgrid:TStringGrid);
    procedure setyear (syear:TSpinEdit);
    procedure setmounth(smounth:TComboBox);
   	procedure Formenter(Sender: TObject;var Key: Word;Shift: TShiftState) ;


    procedure setparent (ed:TCustomEdit ) ;


  protected
    { Protected declarations }

  public
    { Public declarations }


     Procedure KMFormatSetting ;
    Function JalaliDateAlpha (DateStr : String) : AnsiString; StdCall;
     Function JalaliDatePartAlpha (DateStr : AnsiString;APart:integer=2) : AnsiString; StdCall;


  	procedure UpDateCalendar(shamsi:String;vfgrid:TStringGrid;vfcbm:TComboBox;vfspin:TSpinEdit);


    FUNCTION  NoOfDay(DateStr: String; Mil: Boolean): Byte;

    function  addsubdate(shdate:string;day:integer;p:TAddSubdate ):String ;
    function  Difdate(shd1,shd2:String):Double ;

    function  miltoshm(d:TDateTime):String;
    FUNCTION  ShToMilm(Sd: String): TDateTime;
    FUNCTION  ShToMils(Sd: String): String;

    function  Execute(Akind:Integer=10):string ;
    function  Executenomodal(Akind:Integer=10):string ;




    FUNCTION  NameOfDay(DateStr: String; Mil: Boolean; Farsi: Boolean): String;
    Function  GetDayFromNo(AID:Byte):Ansistring ;
    function  Agetext(Brth:String):String ;
    Procedure AgefromDate(ABrth,ABrthN:String;Var ASal,AMah,Arooz:Integer) ;
    Function  DatefromAge(ABrthN:String;ASal,AMah,Arooz:Integer):string ;

    function ValidDate(SE: String; Mil: Boolean): Boolean;
    function IsValidSHDate(SHDate : String):Boolean;

    function HHtime(T:TDateTime):String;
    function IsValidHHTime(HHTime : String): Boolean;
    function Timetominute(T:String):Integer ;
    function MinuteToHHTime(Min: Integer;Up24HH: Boolean):String;

    function DatePart(DateTime : String) : String;
    function TimePart(DateTime : String) : String;
    function DateTimeToText(DateTime : TDateTime) : String;






  published
    { Published declarations }
    Constructor Create (AOwner: TComponent) ;Override ;
    destructor Destroy ; override ;


    property parent:TCustomEdit read Fedit write Setparent;

    property Grid:TStringGrid read FGrid write setgrid ;
    property Yearspin:TSpinEdit read FsYear write setyear ;
    property Mounthcombo:TComboBox read FMounth write setmounth ;

  end;

var
    DayF             : Array [1..31] of Ansistring = ('Ìò„','œÊ„','”Ê„','çÂ«—„','Å‰Ã„','‘‘„','Â› „','Â‘ „','‰Â„', 'œÂ„' , 'Ì«“œÂ„' , 'œÊ«“œÂ„',  '”Ì“œÂ„' ,'çÂ«—œÂ„','Å«‰“œÂ„',   '‘«‰“œÂ„',   'Â›œÂ„',   'ÂÃœÂ„',   '‰Ê“œÂ„',   '»Ì” „',   '»Ì”  Ê Ìò„',   '»Ì”  Ê œÊ„',   '»Ì”  Ê ”Ê„',   '»Ì”  Ê çÂ«—„',   '»Ì”  Ê Å‰Ã„',   '»Ì”  Ê ‘‘„',   '»Ì”  Ê Â› „',   '»Ì”  Ê Â‘ „',   '»Ì”  Ê ‰Â„',   '”Ì «„',   '”Ì Ê Ìò„'   );
    MonthF           : Array [1..12] of AnsiString = ('›—Ê—œÌ‰','«—œÌ»Â‘ ','Œ—œ«œ',' Ì—','„—œ«œ','‘Â—ÌÊ—','„Â—','¬»«‰','¬–—','œÌ','»Â„‰','«”›‰œ');



procedure Register;

implementation


constructor TKMJalaliCalender.Create(Aowner:TComponent);

begin
  inherited Create(AOwner);

end ;
destructor TKMJalaliCalender.Destroy ;
begin

  inherited ;
end ;
procedure TKMJalaliCalender.Deactive(Sender: TObject);
begin
  FForm.Free ;
end ;


procedure TKMJalaliCalender.setparent(ed:TCustomEdit);
begin

  Fedit:=(ed) ;
end ;



FUNCTION TKMJalaliCalender.MilToSh(SE: String): String ;
VAR
  I: LongInt;
  NUM: LongInt;
  Y, D: Integer;
BEGIN
  IF ValidDate(SE,TRUE) THEN
  BEGIN
    Y:=Year;
    Year:=Year-1;
    IF IsLeapYear(TRUE) THEN
      D:=12
    ELSE
      D:=11;
    NUM:=GetNumberOfDay(SE,'1/1/'+INTTOSTR(Y),TRUE);
    SetValue(10,D,Y-622,0,0,0);
  END
  ELSE
  BEGIN
    RESULT:='';
    EXIT;
  END;

  FOR I:=1 TO NUM+1 DO
  BEGIN
    IF Day<DaysInMonth(FALSE) THEN
      INC(Day)
    ELSE
      IF Month<12 THEN
      BEGIN
        INC(Month);
        Day:=1;
      END
      ELSE
      BEGIN
        INC(Year);
        Month:=1;
        Day:=1;
      END;
  END;
  IF (NUM=0) AND Minus THEN
    Day:=Day-1;
    RESULT:=GetText(FALSE);
  END;


FUNCTION TKMJalaliCalender.ShToMil(SE: String): String ;
VAR
  NUM, I: LongInt;
  D: Integer;
BEGIN
  IF ValidDate(SE,FALSE) THEN
  BEGIN
    IF IsLeapYear(FALSE) THEN
      D:=20
    ELSE
      D:=21;
    NUM:=GetNumberOfDay(SE,INTTOSTR(Year)+'/1/1',FALSE);
    SetValue(3,D,Year+621,0,0,0);
  END
  ELSE
  BEGIN
    RESULT:='';
    EXIT;
  END;

  FOR I:=1 TO NUM+1 DO
  BEGIN
    IF Day<DaysInMonth(TRUE) THEN
      INC(Day)
    ELSE
      IF Month<12 THEN
      BEGIN
        INC(Month);
        Day:=1;
      END
      ELSE
      BEGIN
        INC(Year);
        Month:=1;
        Day:=1;
      END;
  END;
  IF (NUM=0) AND Minus  THEN
    Day:=Day-1;
    RESULT:=GetText(TRUE);
  END;


FUNCTION TKMJalaliCalender.Lower(SE, SE1: String; Mil: Boolean): Boolean;
VAR
  YEAR1, MOUNTH1, DAY1, YEAR2, MOUNTH2, DAY2, TEMP: Integer;
BEGIN
  IF ValidDate(SE,Mil) THEN
  BEGIN
    YEAR1:=Year;
    MOUNTH1:=Month;
    DAY1:=Day;
  END
  ELSE
  BEGIN
    RESULT:=FALSE;
    EXIT;
  END;
  IF ValidDate(SE1,Mil) THEN
  BEGIN
    YEAR2:=Year;
    MOUNTH2:=Month;
    DAY2:=Day;
  END
  ELSE
  BEGIN
    RESULT:=FALSE;
    EXIT;
  END;
  IF YEAR1>YEAR2 THEN
  BEGIN
    TEMP:=YEAR1;
    YEAR1:=YEAR2;
    YEAR2:=TEMP;
    TEMP:=MOUNTH1;
    MOUNTH1:=MOUNTH2;
    MOUNTH2:=TEMP;
    TEMP:=DAY1;
    DAY1:=DAY2;
    DAY2:=TEMP;
  END
  ELSE IF YEAR1=YEAR2 THEN
  BEGIN
    IF MOUNTH1>MOUNTH2 THEN
    BEGIN
      TEMP:=MOUNTH1;
      MOUNTH1:=MOUNTH2;
      MOUNTH2:=TEMP;
      TEMP:=DAY1;
      DAY1:=DAY2;
      DAY2:=TEMP;
    END
    ELSE IF MOUNTH1=MOUNTH2 THEN
      IF DAY1>DAY2 THEN
      BEGIN
        TEMP:=DAY1;
        DAY1:=DAY2;
        DAY2:=TEMP;
      END;
  END;
  SetValue(MOUNTH1,DAY1,YEAR1,MOUNTH2,DAY2,YEAR2);
  RESULT:=TRUE;
END;

PROCEDURE TKMJalaliCalender.SetValue(M, D, Y, ME, DE, YE: Integer);
BEGIN
  Month:=M;
  Day:=D;
  Year:=Y;
  MonthE:=ME;
  DayE:=DE;
  YearE:=YE;
END;

FUNCTION TKMJalaliCalender.ValidDate(SE:String;Mil:Boolean):Boolean;
VAR
  SV: String;
  MB, YB: Boolean;
  I, COUNT: ShortInt;
  TEMP: Integer;
BEGIN
  IF SE='' THEN
  BEGIN
    RESULT:=FALSE;
    EXIT;
  END;
  COUNT:=0;
  YB:=FALSE;
  MB:=FALSE;
  SV:='';
  TRY
    FOR I:=1 TO LENGTH(SE) DO
    BEGIN
      IF SE[I] <>'/' THEN
        SV:=SV+SE[I]
      ELSE
      BEGIN
        COUNT:=COUNT+1;
        IF COUNT>2 THEN
        BEGIN
          RESULT:=FALSE;
          EXIT;
        END;
        IF NOT YB THEN
        BEGIN
          Year:=STRTOINT(SV);
          IF Year<1 THEN
          BEGIN
            RESULT:=FALSE;
            EXIT;
          END;
          YB:=TRUE;
        END
        ELSE IF NOT MB THEN
        BEGIN
          Month:=STRTOINT(SV);
          IF (Month>12) OR (Month<1) THEN
          BEGIN
            RESULT:=FALSE;
            EXIT;
          END;
        END;
        SV:='';
      END;
    END;
    Day:=STRTOINT(SV);
    IF Mil THEN
    BEGIN
      TEMP:=Day;
      Day:=Year;
      Year:=TEMP;
    END;
    IF (Day<1) OR (Day>DaysInMonth(Mil)) THEN
    BEGIN
      RESULT:=FALSE;
      EXIT;
    END;
  EXCEPT
    RESULT:=FALSE;
    EXIT;
  END;
  IF COUNT<>2 THEN
    RESULT:=FALSE
  ELSE
    RESULT:=TRUE;
END;

FUNCTION TKMJalaliCalender.IsLeapYear(Mil: Boolean): Boolean ;
VAR
  MILADI: Integer;
BEGIN
  IF NOT Mil THEN
    MILADI:=Year+621
  ELSE
    MILADI:=Year;

  if MILADI=2000 then
  begin
    IsLeapYear:=TRUE;
    Exit;
  end;

  IF (MILADI MOD 4 <> 0) THEN
    IsLeapYear:=FALSE
  ELSE
    IF (MILADI MOD 100 <>0) THEN
      IsLeapYear:=TRUE
    ELSE
      IF (MILADI MOD 400 <>0) THEN
        IsLeapYear:=FALSE
      ELSE
        IF (MILADI MOD 100=0) THEN
          IsLeapYear:=FALSE
        ELSE
          IsLeapYear:=TRUE;
END;
FUNCTION TKMJalaliCalender.IsLeapYeartemp(Mil: Boolean): Boolean ;
VAR
  MILADI: Integer;
BEGIN
  IF NOT Mil THEN
    MILADI:=StrToInt(FsYear.Text)+621
  ELSE
    MILADI:=Year;

  if MILADI=2000 then
  begin
    Result:=TRUE;
    Exit;
  end;

  IF (MILADI MOD 4 <> 0) THEN
    Result:=FALSE
  ELSE
    IF (MILADI MOD 100 <>0) THEN
      Result:=TRUE
    ELSE
      IF (MILADI MOD 400 <>0) THEN
        Result:=FALSE
      ELSE
        IF (MILADI MOD 100=0) THEN
          Result:=FALSE
        ELSE
          Result:=TRUE;
END;
FUNCTION TKMJalaliCalender.DaysInMonth(Mil: Boolean): Integer;
BEGIN
  DaysInMonth:=30;
  IF  not Mil THEN
  BEGIN
    CASE Month  OF
      1, 2, 3, 4, 5, 6: DaysInMonth:=31;
      7, 8, 9, 10, 11: DaysInMonth:=30;
      12:
        IF(IsLeapYear(Mil)) THEN
          DaysInMonth:=30
        ELSE
          DaysInMonth:=29;
    END;
  END
  ELSE
  BEGIN
    CASE Month OF
      1, 3, 5, 7, 8, 10, 12: DaysInMonth:=31;
      4, 6, 9, 11: DaysInMonth:=30;
      2: IF IsLeapYear(Mil) THEN
           DaysInMonth:=29
         ELSE
           DaysInMonth:=28;
    END;
  END;
END;
FUNCTION TKMJalaliCalender.DaysInMonthtemp(Mil: Boolean): Integer;
BEGIN


  CASE FMounth.ItemIndex+1 OF
    1, 2, 3, 4, 5, 6: Result:=31;
    7, 8, 9, 10, 11: Result:=30;
    12:
      IF(IsLeapYeartemp(Mil)) THEN
        Result:=30
      ELSE
        Result:=29;
  END;

END;



function TKMJalaliCalender.GetDayFromNo(AID: Byte):Ansistring;
begin
      Case AID Of
        1:
          Result:='Ìﬂ‘‰»Â';
        2:
          Result:='œÊ‘‰»Â';
        3:
          Result:='”Â ‘‰»Â';
        4:
          Result:='çÂ«—‘‰»Â';
        5:
          Result:='Å‰Ã‘‰»Â';
        6:
          Result:='Ã„⁄Â';
        7:
          Result:='‘‰»Â';
      END;
end;

FUNCTION TKMJalaliCalender.GetNumberOfDay(SE, SE1: String; Mil: Boolean): LongInt;
VAR
  SUM: LongInt;
BEGIN
  Minus:=FALSE;
  IF Lower(SE,SE1,Mil) THEN
  BEGIN
    SUM:=0;
    IF ((Year=YearE) AND (Month=MonthE) AND (Day=DayE)) THEN
    BEGIN
      Minus:=TRUE;
      RESULT:=0;
      EXIT;
    END;

    REPEAT
      IF (Day<DaysInMonth(Mil)) THEN
        INC(Day)
      ELSE IF (Month<12) THEN
      BEGIN
        INC(Month);
        Day:=1;
      END
      ELSE
      BEGIN
        INC(Year);
        Month:=1;
        Day:=1;
      END;
      INC(SUM);
    UNTIL (Year=YearE) AND (Day=DayE) AND (Month=MonthE);
    SUM:=SUM-1;
    RESULT:=SUM;
  END
  ELSE
  BEGIN
    //ShowMessage(' «—ÌŒ „Ì·«œÌ ’ÕÌÕ ‰„Ì»«‘œ');
    RESULT:=0;
  END;
END;


FUNCTION TKMJalaliCalender.GetText(Mil: Boolean): String;
VAR
  M, D, Y: String;
BEGIN
  STR(Month:2,M);
  IF Month<10 THEN
    M[1]:='0';
  STR(Day:2,D);
  IF Day<10 THEN
    D[1]:='0';
  STR(Year:4,Y);
  IF Year<10 THEN
  BEGIN
    Y[1]:='0';
    Y[2]:='0';
    Y[3]:='0';
  END
  ELSE IF Year<100 THEN
  BEGIN
    Y[1]:='0';
    Y[2]:='0';
  END
  ELSE IF Year<1000 THEN
    Y[1]:='0';
  IF Mil THEN
    GetText:=D+'/'+M+'/'+Y
  ELSE
    GetText:=y+'/'+M+'/'+d;
END;

FUNCTION  TKMJalaliCalender.NameOfDay(DateStr: String; Mil: Boolean; Farsi: Boolean): String;
Var
  C_Day: Integer;
  Name: String;
BEGIN
  IF Mil THEN
  BEGIN
    if not ValidDate(DateStr,True) then
    begin
      Name:='ERR';
      Result:=Name;
      Abort;
    end;
    C_Day:=DayOfWeek(EncodeDate(Year,Month,Day));
    Case C_Day Of
      1:
        Name:='Sun';
      2:
        Name:='Mon';
      3:
        Name:='Tue';
      4:
        Name:='Wed';
      5:
        Name:='Thu';
      6:
        Name:='Fri';
      7:
        Name:='Sat';
    END
  END
  ELSE
  BEGIN
    if not ValidDate(DateStr,False) then
    begin
      Name:='ERR';
      Result:=Name;
      Abort;
    end;
    ShToMil(DateStr);

    C_Day:=DayOfWeek(EncodeDate(Year,Month,Day));
    if Farsi then
    BEGIN
      Case C_Day Of
        1:
          Name:='Ìﬂ‘‰»Â';
        2:
          Name:='œÊ‘‰»Â';
        3:
          Name:='”Â ‘‰»Â';
        4:
          Name:='çÂ«—‘‰»Â';
        5:
          Name:='Å‰Ã‘‰»Â';
        6:
          Name:='Ã„⁄Â';
        7:
          Name:='‘‰»Â';
      END;
    END
    ELSE
    BEGIN
      Case C_Day Of
        1:
          Name:='Ì€“·»„';
        2:
          Name:='Õ‰“·»„';
        3:
          Name:='—„ “·»„';
        4:
          Name:='ç„∆œ“·»„';
        5:
          Name:='Å·À“·»„';
        6:
          Name:='Àê÷„';
        7:
          Name:='“·»„';
      END;
    END;
  END;
  Result:=Name;
END;
FUNCTION  TKMJalaliCalender.NoOfDay(DateStr: String; Mil: Boolean): Byte;
var
  C_Day: Byte;
begin
  Result:=0;
  IF Mil THEN
  BEGIN
    if not ValidDate(DateStr,True) then
    begin
      Abort;
    end;
    C_Day:=DayOfWeek(EncodeDate(Year,Month,Day));
    Result:=C_Day;
  END
  ELSE
  BEGIN
    if not ValidDate(DateStr,False) then
    begin
      Abort;
    end;
    ShToMil(DateStr);
    C_Day:=DayOfWeek(EncodeDate(Year,Month,Day));
    Case C_Day Of
      1:
        Result:=2;
      2:
        Result:=3;
      3:
        Result:=4;
      4:
        Result:=5;
      5:
        Result:=6;
      6:
        Result:=7;
      7:
        Result:=1;
      END;
  END;
end;


 function TKMJalaliCalender.setstring(str1:string;lenstr:integer):string ;
  var
   i,j:integer ;
  begin
   i:=lenstr-length(str1) ;
   for j:=1 to i do
      str1:='0'+str1 ;
   Result:=str1 ;
  end ;
procedure TKMJalaliCalender.UpDateCalendar(shamsi:string;vfgrid:TStringGrid;vfcbm:TComboBox;vfspin:TSpinEdit);
  var
    Indx, Index, Days, First: Byte;
    TempDate: String;
    C_Date:String ;
    GridCol, GridRow: Byte;
    ys,ms,ds:String[4] ;
    d:Word ;

     label h  ;
begin

  for Indx:=1 to 6 do
    for Index:=0 to 6 do
      vfgrid .Cells[Index,Indx]:='';
  vfgrid .Refresh;
  vfspin.OnChange:=ChangeYear ;
  vfcbm.OnChange:=ChangeMounth ;
  vfgrid.OnSelectCell:=cellclick ;

  try


    C_Date:=(shamsi) ;
    ys:=copy(C_Date,1,4);
    ms:=copy(C_Date,6,2);
    ds:=copy(C_Date,9,2);

    d:=StrToInt(ds);

    vfcbm.ItemIndex:=strtoint(ms)-1 ;
    vfspin.Text:=ys;
    TempDate:=Copy(C_Date,1,8)+'01';

    First:=NoOfDay(TempDate,false);
	if ((Abs(First-1+Day)) mod 7)=0 then
      GridCol:=6
    else
      GridCol:=((Abs(First-1+Day)) mod 7)-1;
    if Frac(Abs(First-1+Day)/7)=0 then
      GridRow:=Trunc(Abs(First-1+Day)/7)
    else
      GridRow:=Trunc(Abs(First-1+Day)/7)+1;
    First:=First-1;
    Days:=1;
    for Indx:=1 to 6 do
    begin
      for Index:=First to 6 do
      begin
        if  not (Days>DaysInMonthtemp(false)) then
        begin
          vfgrid.Cells[Index,Indx]:=IntToStr(Days);
          if vfgrid.Cells[Index,Indx]=inttostr(d) then
          begin
            GridCol:=Index ;
            GridRow:=Indx ;
          end ;
        end
        else
        begin
          vfgrid.Col:=GridCol; vfgrid.Row:=GridRow;
          goto h;
        end;
        Days:=Days+1;
      end;
      First:=0;
    end;
    h:
    finally
  end;
end;
procedure TKMJalaliCalender.ChangeYear(sender:TObject);
var
  s:String [10];
begin
  s:=(sender as TSpinEdit).Text ;
  if  length(s)=4 then
  begin
    s:=(sender as TSpinEdit).Text+'/'+setstring(inttostr(fMounth.itemindex+1),2)+'/01' ;
    UpDateCalendar(s,FGrid,FMounth,FsYear)  ;
  end ;
end ;
procedure TKMJalaliCalender.ChangeMounth(sender:TObject );
var
  s:String [10];
begin
  s:=FsYear.Text+'/'+setstring(IntToStr((sender as TComboBox).ItemIndex+1),2)+'/01' ;
  UpDateCalendar(s,FGrid,FMounth,FsYear)  ;
end ;
procedure TKMJalaliCalender.cellclick(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
   fcol:=ACol ;
   frow:=ARow ;

end ;

FUNCTION  TKMJalaliCalender.ShToMilm(Sd: String): TDateTime;
var
  d:String[10];
begin
  if ValidDate(Sd,false) then
  begin
    d:=copy(ShToMil(Sd),7,4)+'/'+copy(ShToMil(Sd),4,2)+'/'+copy(ShToMil(Sd),1,2);
    Result:=StrToDate(d ) ;
  end;

end ;  
FUNCTION  TKMJalaliCalender.ShToMils(Sd: String): String;
var
  d:String[10];
begin
  if ValidDate(Sd,false) then
  begin
    d:=copy(ShToMil(Sd),7,4)+'/'+copy(ShToMil(Sd),4,2)+'/'+copy(ShToMil(Sd),1,2);
    Result:=d ;
  end
  else
    Result:='' ;
end ;
function TKMJalaliCalender.miltoshm(d:TDateTime):String;
var
  year,mounth,day:Word ;
begin

  DecodeDate(d,year,mounth,day);
  if d<>0 then
    Result:=MilToSh(IntToStr(day)+'/'+IntToStr(mounth)+'/'+IntToStr(year))
  else
    Result:='' ;  
end ;

function  TKMJalaliCalender.Executenomodal(Akind:Integer=10):string ;
var
 Flabel:TLabel;
 i,j:Integer ;
 y,m,d:Word  ;
 ys,ms,ds:String[4];
 g:TPoint ;
begin
  FKind:=Akind ;
  ///////////////////form//////////////////
    FForm:=TForm.Create(nil);
    FForm.Parent:=FForm ;
    FForm.BiDiMode:=bdRightToLeft ;
    FForm.BorderStyle:=bsNone ;
    FForm.ScaleBy(Screen.PixelsPerInch, 96);
    g := Fedit.Parent.ClientToScreen(Point(Fedit.Left, Fedit.Top)) ;
    FForm.Top:=g.y+Fedit.Height;
    FForm.Left:=g.x ;
    FForm.Height:=137;
    FForm.Width:=145;
    FForm.Font.Name:='Tahoma';
    FForm.KeyPreview:=True ;
    FForm.OnKeyDown:=Formenter ;
    FForm.OnDeactivate:=Deactive ;
    ////////////////////form//////////////////
    ////////////////////////spinedityear/////////////
    FsYear:=TSpinEdit.Create(nil);
    FsYear.Parent:=FForm ;
    FsYear.Left:=80 ;
    FsYear.Top:=0 ;
    FsYear.Width:=65 ;
    FsYear.BiDiMode:=bdRightToLeft ;
    FsYear.Height:=21;
    FsYear.MaxLength:=4 ;
    FsYear.MinValue:=1300 ;
    FsYear.MaxValue:=1420 ;
    /////////////////////cmbmounth/////////////
    FMounth:=TComboBox.Create(nil);
    FMounth.Parent:=FForm ;
    FMounth.Left:=0 ;
    FMounth.Top:=0 ;
    FMounth.Width:=80 ;
    FMounth.BiDiMode:=bdRightToLeft ;
    FMounth.Height:=21;
    FMounth.Style:=csDropDownList ;
    //////////////////////cmbmounth/////////////
    ///////////////////////stringgrid///////////
    FGrid:=TStringGrid.Create(nil);
    FGrid.Parent:=FForm ;
    FGrid.Left:=0;
    FGrid.Top:=21 ;
    FGrid.Height:=115 ;
    FGrid.Width:=145 ;
    FGrid.RowCount:=7 ;
    FGrid.ColCount:=7 ;
    FGrid.DefaultRowHeight:=15 ;
    FGrid.DefaultColWidth:=19 ;
    FGrid.FixedCols:=0 ;
    {//////////////////////////stringgrid///////////
    ///////////////////////label///////////
    Flabel :=TLabel.Create(nil);
    Flabel.Parent:=FForm ;
    Flabel.Left:=-50;
    Flabel.Top:=150 ;
    Flabel.Height:=35 ;
    Flabel.Width:=185 ;
    Flabel.Caption:=' Kamihadad@Yahoo.com '+#13+'Dara_Alireza@Yahoo.com           '  ;
    //////////////////////////label/////////// }
    FMounth.Items.Add('›—Ê—œÌ‰');
    FMounth.Items.Add('«—œÌ»Â‘ ');
    FMounth.Items.Add('Œ—œ«œ');
    FMounth.Items.Add(' Ì—');
    FMounth.Items.Add('„—œ«œ');
    FMounth.Items.Add('‘Â—ÌÊ—');
    FMounth.Items.Add('„Â—');
    FMounth.Items.Add('¬»«‰');
    FMounth.Items.Add('¬–—');
    FMounth.Items.Add('œÌ');
    FMounth.Items.Add('»Â„‰');
    FMounth.Items.Add('«”›‰œ');
    DecodeDate(Date,y,m,d);
    ys:=IntToStr(y);
    ms:=setstring(IntToStr(m),2 );
    ds:=setstring(IntToStr(d),2 );

    Fshamsi:=MilToSh(ds+'/'+ms+'/'+ys);
    ys:=copy(Fshamsi,7,4);
    ms:=copy(Fshamsi,4,2);
    ds:=copy(Fshamsi,1,2);
    FGrid.Cells[0,0]:='‘'  ;
    FGrid.Cells[1,0]:='Ì'  ;
    FGrid.Cells[2,0]:='œ'  ;
    FGrid.Cells[3,0]:='”'  ;
    FGrid.Cells[4,0]:='ç'  ;
    FGrid.Cells[5,0]:='Å'  ;
    FGrid.Cells[6,0]:='Ã'  ;
    FGrid.OnDblClick:=dclick ;
    UpDateCalendar(Fshamsi,FGrid,FMounth,FsYear) ;

    FForm.Show ;

end ;




function  TKMJalaliCalender.Execute(Akind:Integer=10):string ;
var
  Flabel:TLabel;
  y,m,d:Word  ;
  ys,ms,ds:String[4];
begin
   FKind:=Akind ;
  ///////////////////form//////////////////
  FForm:=TForm.Create(nil);
  FForm.Font.Name:='tahoma' ;
  FForm.Height:=230 ;
  FForm.Width:=210 ;
  FForm.BiDiMode:=bdRightToLeft ;
  FForm.BorderStyle:=bsToolWindow  ;
  FForm.Position:=poDesktopCenter ;
  //FForm.BorderIcons:=[] ;
  FForm.Font.Name:='Tahoma';
  FForm.KeyPreview:=True ;
  FForm.OnKeyDown:=Formenter ;
  ////////////////////form//////////////////
  ////////////////////////spinedityear/////////////
  FsYear:=TSpinEdit.Create(nil);
  FsYear.Parent:=FForm ;
  FsYear.Left:=124 ;
  FsYear.Top:=8 ;
  FsYear.Width:=72 ;
  FsYear.BiDiMode:=bdRightToLeft ;
  FsYear.Height:=21;
  FsYear.MaxLength:=4 ;
  FsYear.MinValue:=1300 ;
  FsYear.MaxValue:=1420 ;
  /////////////////////cmbmounth/////////////
  FMounth:=TComboBox.Create(nil);
  FMounth.Parent:=FForm ;
  FMounth.Left:=9 ;
  FMounth.Top:=8 ;
  FMounth.Width:=97 ;
  FMounth.BiDiMode:=bdRightToLeft ;
  FMounth.Height:=21;
  FMounth.Style:=csDropDownList ;
  //////////////////////cmbmounth/////////////
  ///////////////////////stringgrid///////////
  FGrid:=TStringGrid.Create(nil);
  FGrid.Parent:=FForm ;
  FGrid.Left:=9;
  FGrid.Top:=32 ;
  FGrid.Height:=150 ;
  FGrid.Width:=185 ;
  FGrid.RowCount:=7 ;
  FGrid.ColCount:=7 ;
  FGrid.DefaultRowHeight:=20 ;
  FGrid.DefaultColWidth:=25 ;
  FGrid.FixedCols:=0 ;
  FGrid.OnDblClick:=dclickmodal;
  //////////////////////////stringgrid///////////
  ///////////////////////label///////////
  {Flabel :=TLabel.Create(nil);
  Flabel.Parent:=FForm ;
  Flabel.Left:=10;
  Flabel.Top:=185 ;
  Flabel.Height:=35 ;
  Flabel.Width:=180 ;
  Flabel.Caption:='Design By :  Kamihadad@Yahoo.com  '  ;}
  //////////////////////////label///////////



  FMounth.Items.Add('›—Ê—œÌ‰');
  FMounth.Items.Add('«—œÌ»Â‘ ');
  FMounth.Items.Add('Œ—œ«œ');
  FMounth.Items.Add(' Ì—');
  FMounth.Items.Add('„—œ«œ');
  FMounth.Items.Add('‘Â—ÌÊ—');
  FMounth.Items.Add('„Â—');
  FMounth.Items.Add('¬»«‰');
  FMounth.Items.Add('¬–—');
  FMounth.Items.Add('œÌ');
  FMounth.Items.Add('»Â„‰');
  FMounth.Items.Add('«”›‰œ');
  DecodeDate(Date,y,m,d);
  ys:=IntToStr(y);
  ms:=setstring(IntToStr(m),2 );
  ds:=setstring(IntToStr(d),2 );

  Fshamsi:=MilToSh(ds+'/'+ms+'/'+ys);
  ys:=copy(Fshamsi,7,4);
  ms:=copy(Fshamsi,4,2);
  ds:=copy(Fshamsi,1,2);
  FGrid.Cells[0,0]:='‘'  ;
  FGrid.Cells[1,0]:='Ì'  ;
  FGrid.Cells[2,0]:='œ'  ;
  FGrid.Cells[3,0]:='”'  ;
  FGrid.Cells[4,0]:='ç'  ;
  FGrid.Cells[5,0]:='Å'  ;
  FGrid.Cells[6,0]:='Ã'  ;
  UpDateCalendar(Fshamsi,FGrid,FMounth,FsYear) ;

  FForm.ShowModal ;

  if  (setstring(FGrid.Cells[fcol,frow],2)<>'00') then
  if FKind=10 then
    Result:=FsYear.Text+'/'+setstring(IntToStr(FMounth.ItemIndex+1),2)+'/'+setstring(FGrid.Cells[fcol,frow],2)
  else
    Result:=Copy(FsYear.Text,3,2)+'/'+setstring(IntToStr(FMounth.ItemIndex+1),2)+'/'+setstring(FGrid.Cells[fcol,frow],2)
  else
  Result:='' ;

end ;


procedure TKMJalaliCalender.dclickmodal(Sender: TObject);
begin
  FForm.close ;
end ;
procedure TKMJalaliCalender.dclick(Sender: TObject);
begin
{ TODO : inja avaz mishe }
  if  setstring(FGrid.Cells[fcol,frow],2)<>'00' then
  if FKind=10 then
    Fedit.Text:=FsYear.Text+'/'+setstring(IntToStr(FMounth.ItemIndex+1),2)+'/'+setstring(FGrid.Cells[fcol,frow],2)
  else
    Fedit.Text:=Copy(FsYear.Text,3,2)+'/'+setstring(IntToStr(FMounth.ItemIndex+1),2)+'/'+setstring(FGrid.Cells[fcol,frow],2) ;

  Fedit.SetFocus ;
 
end ;
procedure TKMJalaliCalender.Formenter(Sender: TObject;var Key: Word;Shift: TShiftState) ;
begin

  if (Key=13) or (key=27) then
    FForm.Close ;


end ;
////////////ezafe va kam kardan be tarikh be rooz//////////
function TKMJalaliCalender.addsubdate(shdate:string;day:integer;p:TAddSubdate ):String ;
var
  dmnew:TDateTime ;
  dmold,dsh:String[10] ;
  jdate:Real ;
begin
  dmold:=ShToMil(shdate);
  jdate:=DateTimeToJulianDate(strtodate(dmold[7]+dmold[8]+dmold[9]+dmold[10]+'/'+dmold[4]+dmold[5]+'/'+dmold[1]+dmold[2]));
  if p=Add then
    dmnew:=(JulianDateToDateTime(jdate+day) );
  if p=sub then
    dmnew:=(JulianDateToDateTime(jdate-day) );
  Result:=miltoshm((dmnew ) );
end ;
///////////////////ekhtelafe do tarikh//////////////
function TKMJalaliCalender.Difdate(shd1,shd2:String):Double  ;
var
  dm1,dm2:TDateTime ;
begin
  dm1:=ShToMilm(shd1);
  dm2:=ShToMilm(shd2);
  Result:=abs(DateTimeToJulianDate(dm1)-DateTimeToJulianDate(dm2)) ;
end ;
////////////////////////////////mohasebeh sen va sal//////////////
function TKMJalaliCalender.Agetext(Brth:String):String ;
var
  sal,rooz,Sen:integer ;
  jbrth,jnow:Real ;
  brthl,nowdatel:String ;
begin
  brthl:=ShToMil(brth);
  nowdatel:=ShToMil(miltoshm(Date));
  jbrth:=DateTimeToJulianDate(strtodate(brthl[7]+brthl[8]+brthl[9]+brthl[10]+'/'+brthl[4]+brthl[5]+'/'+brthl[1]+brthl[2]));
  jnow:=DateTimeToJulianDate(strtodate(nowdatel[7]+nowdatel[8]+nowdatel[9]+nowdatel[10]+'/'+nowdatel[4]+nowdatel[5]+'/'+nowdatel[1]+nowdatel[2]));
  sen:=round(jnow-jbrth) ;
  sal:=(Sen div 365) ;
  rooz:=(Sen mod 365) ;
  if (sal>0)And(ROOZ>0) then
    Result:=floattostr(sal)+'”«· Ê ' +FloatToStr(rooz)+' —Ê“' ;
  if (sal>0)And(ROOZ=0) then
    Result:=floattostr(sal)+'”«· '  ;
  if (sal=0)And(ROOZ>0) then
    Result:=FloatToStr(rooz)+' —Ê“' ;
  if (sal=0)And(ROOZ=0) then
    Result:='';
end ;
Procedure TKMJalaliCalender.AgefromDate(ABrth,ABrthN:String;Var ASal,AMah,Arooz:Integer) ;
var
  VsalN,VmahN,VroozN,Vsal,Vmah,Vrooz:integer ;
begin
  if not IsValidSHDate(ABrth) then
    Exit ;


  Vsal:=StrToInt(Copy(ABrth,1,4));
  Vmah:=StrToInt(Copy(ABrth,6,2));
  Vrooz:=StrToInt(Copy(ABrth,9,2));

  VsalN:=StrToInt(Copy(ABrthN,1,4));
  VmahN:=StrToInt(Copy(ABrthN,6,2));
  VroozN:=StrToInt(Copy(ABrthN,9,2));

  ASal:=VsalN-Vsal ;

  AMah:=VmahN-Vmah ;
  if VmahN<Vmah then
  begin
    ASal:=ASal-1 ;
    AMah:=12-(Vmah-VmahN) ;
  end;
  Arooz:=VroozN-Vrooz ;
  if vroozn<Vrooz then
  begin
    AMah:=AMah-1 ;
    if AMah=-1 then
    begin
      ASal:=ASal-1 ;
      AMah:=11 ;
    end;
    if AMah>6 then
      Arooz:=30-(Vrooz-VroozN)
    ELSE
      Arooz:=31-(Vrooz-VroozN)
  end;
end ;
Function TKMJalaliCalender.DatefromAge(ABrthN:String;ASal,AMah,Arooz:Integer):string ;
var

  VsalN,VmahN,VroozN,Vsal,Vmah,Vrooz:integer ;



  vjul:Double ;
  VI:Integer ;
  VMilDate:TDateTime ;
begin

  VsalN:=StrToInt(Copy(ABrthN,1,4));
  VmahN:=StrToInt(Copy(ABrthN,6,2));
  VroozN:=StrToInt(Copy(ABrthN,9,2));



  Vsal:=VsalN-Asal ;

  Vmah:=VmahN-Amah ;
  if VmahN<=Amah then
  begin
    VSal:=VSal-1 ;
    VMah:=12-(Amah-VmahN) ;
  end;

  Vrooz:=VroozN-Arooz ;
  if VroozN<=Arooz then
  begin
    VMah:=VMah-1 ;
    if VMah=12 then
    begin
      VSal:=ASal-1 ;
      VMah:=1 ;
    end;
    if VMah>6 then
      Vrooz:=30-(Arooz-VroozN)
    ELSE
      Vrooz:=31-(Arooz-VroozN)
  end;

  Result:=setstring(IntToStr(Vsal),4)+'/'+setstring(IntToStr(Vmah),2)+'/'+setstring(IntToStr(Vrooz),2) ;





end ;
procedure TKMJalaliCalender.setgrid (sgrid:TStringGrid);
begin
  FGrid:=sgrid ;
end ;
procedure TKMJalaliCalender.setyear (syear:TSpinEdit);
begin
  FsYear:=syear ;
end ;
procedure TKMJalaliCalender.setmounth(smounth:TComboBox);
begin
  FMounth:=smounth ;
end ;
////////////////convert systime to minute (integer) /////////

function TKMJalaliCalender.Timetominute(T:String):Integer ;
var
  Th,Tm:Integer ;
begin
  Th:=StrToInt(T[1]+T[2]) ;
  Tm:=StrToInt(T[4]+T[5]);
  Result:=Th*60+Tm ;
end ;
///////////////// System Time 24H //////////////
function TKMJalaliCalender.HHtime(T:TDateTime):String;
var
  H, M, S, mS : Word;
  C_Time:String ;
begin
DecodeTime(T,H,M,S,mS);
if H=0 then
    C_Time:='00'+':'
  else if H < 10 then
    C_Time:='0'+IntToStr(H)+':'
  else
    C_Time:=IntToStr(H)+':';

  if M=0 then
    C_Time:=C_Time+'00'
  else if M < 10 then
    C_Time:=C_Time+'0'+IntToStr(M)
  else
    C_Time:=C_Time+IntToStr(M);
  Result:=C_Time ;
end ;
procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMJalaliCalender]);
end;

function TKMJalaliCalender.IsValidSHDate(SHDate: String): Boolean;
begin
  if(Trim(SHDate) ='')or(Trim(SHDate)='    /  /  ')then
  begin
    Result:=False ;
    Exit ;
  end;

	if (ShToMils(SHDate)<>'') then
		Result:=True
	else
		Result:=False;
end;

function TKMJalaliCalender.IsValidHHTime(HHTime: String): Boolean;
begin
	if ((Copy(HHTime,0,2)<'00') or  (Copy(HHTime,0,2)>'23')) or
		((Copy(HHTime,4,2)<'00') or  (Copy(HHTime,4,2)>'59'))then
	begin
		if HHTime<>'24:00' then
			Result:=False
		else
			Result:=True
	end
	else
		Result:=True;
end;

function TKMJalaliCalender.MinuteToHHTime(Min: Integer;
  Up24HH: Boolean): String;
begin
	if not Up24HH then
		Min:=Min MOD 1440;
	Result:=FormatFloat('00',Min DIV 60)+':'+FormatFloat('00',Min MOD 60);
end;

// just returns the date part of the given string date time.
function TKMJalaliCalender.DatePart(DateTime: String): String;
begin
	if (pos(' ', DateTime) > 0) then
		result := copy(DateTime, 1, pos(' ', DateTime) - 1)
	else
		result := DateTime;
end;

// time part is hhtime.
function TKMJalaliCalender.DateTimeToText(DateTime: TDateTime): String;
begin
	Result := DatePart(DateTimeToStr(DateTime)) + ' ' + HHtime(DateTime);
end;

// just returns the time part of the given string date time.
function TKMJalaliCalender.TimePart(DateTime: String): String;
begin
	if (Pos(' ', DateTime) > 0) then
		result := copy(DateTime, pos(' ', DateTime) + 1, Length(DateTime) - (pos(' ', DateTime) + 1))
	else if (Pos('/', DateTime) > 0) then
		Result := '00:00'
	else
		Result := DateTime;
end;
///////////////////writen by mohamad tahami//////////////////////////////////
/////// Mtahami0070@yahoo.com  /////// 1385
 Function TKMJalaliCalender.JalaliDateAlpha (DateStr : String) : AnsiString; StdCall;
 var
  FarsiDay , FarsiMonth ,  FarsiYear  : Integer;
  DF,MF,YF : AnsiString;
  k:TKMUtil ;
 begin
  k:=TKMUtil.Create(nil);
  FarsiDay      := StrToInt(Copy(Datestr,9,2));
  FarsiMonth    := StrToInt(Copy(Datestr,6,2));
  FarsiYear:= StrToInt(Copy(Datestr,1,4));

  DF  :=  DayF  [FarsiDay];
  MF  := MonthF [FarsiMonth];
  YF  :=k.NoTextFarsi(FarsiYear) ;
  k.Free ;
  Result := DF + ' ' + MF + ' „«Â ' +  YF;
 end ;
 Function TKMJalaliCalender.JalaliDatePartAlpha (DateStr : AnsiString;APart:integer=2) : AnsiString; StdCall;
 var
  FarsiDay , FarsiMonth ,  FarsiYear  : Integer;
  DF,MF,YF : AnsiString;
  k:TKMUtil ;
 begin
  k:=TKMUtil.Create(nil);
  FarsiDay      := StrToInt(Copy(Datestr,9,2));
  FarsiMonth    := StrToInt(Copy(Datestr,6,2));
  FarsiYear:= StrToInt(Copy(Datestr,1,4));

  DF  :=  DayF  [FarsiDay];
  MF  := MonthF [FarsiMonth];
  YF  :=k.NoTextFarsi(FarsiYear) ;
  k.Free ;
  case APart of
    1: Result :=Copy(Datestr,1,4) ;
    2: Result:=MF ;
    3: Result:=DF ;
  end
 end ;
procedure TKMJalaliCalender.KMFormatSetting;
begin
    FormatSettings.LongDateFormat:='yyyy/mm/dd';
    FormatSettings.ShortDateFormat:='yyyy/mm/dd';
    FormatSettings.CurrencyString:='' ;
    FormatSettings.CurrencyDecimals:=0 ;
end;

end.

