
unit UntBARLL; {Barcode Low-Level routines}

{.$define debug}
{$ifdef debug}
  {$A+,B-,D+,F-,G+,I+,K+,L+,P-,R+,Q+,S+,T-,U-,V+,W-,X+,Y-,Z-}
{$else}
  {$A+,B-,D-,F-,G+,I+,K+,L-,P-,R-,Q-,S-,T-,U-,V+,W-,X+,Y-,Z-}
{$endif}


interface
uses wintypes,winprocs,graphics;

const
  MaxBarcodeLen=50; {Barcode darf max. 50 Zeichen enthalten}
  {Max. 16 Module je Zeichen bei Code39, und zwar
   3 breite Elementa á 3, 6 schmale Elemente, 1 Trennelement}
  MaxModularray=(MaxBarcodeLen+2)*16+1; {Codelänge + Start-/Stopzeichen}
  {Die tatsächliche Modulbreite beträgt
   EAN08 : 67 Module= 3 Start/7*4 Nutz/5 Mitte/7*4 Nutz/3 Stop
   EAN13 : 95 Module= 3 Start/7*6 Nutz/5 Mitte/7*6 Nutz/3 Stop
                      (das 13. Zeichen wird speziell codiert)
   Code39: je 16 Module (inkl. Trennmodul) für Start-/Stop- und Nutzzeichen
           (3 breite Elementa á 3, 6 schmale Elemente, 1 Trennelement)
   Code128: je 11 Module für Startzeichen und sonstige Zeichen, 13 Module Stopzeichen
  }

type
  lbtCodeTypes=(EAN_8,EAN_13,UPC_A,UPC_E,CODE39,CODE25i,CODE25iP,
                CODE128_A,CODE128_B,CODE128_C,MSI_Plessey,Codabar,Postnet,Postnet_FIM);
  lbtCodeSizes=(SC0,SC1,SC2,SC3,SC4,SC5,SC6,SC7,SC8,SC9);
  lbtCodeRotate=(rotate_000,rotate_090,rotate_180,rotate_270);
  lbtCodeRatio=(Ratio_3,Ratio_2);

type
  TBarcodeParams=class
                   {Inputcode holds original inputstring, Barcode is actually coded with}
                   Inputcode:Array[0..MaxbarcodeLen+2] of char;
                   AddonCode:Array[0..5] of Char;{max 5 chars}
                   BTyp:lbtCodeTypes;
                   SCSize:lbtCodeSizes;
                   Ratio:lbtCodeRatio;
                   HeightPerCent:Integer;
                   Fontname:string;
                   FontScaling:Integer;
                   ReduceWidth:Boolean;
                   HDCode:boolean;
                   ZoomSize:boolean;
                   Rotate:lbtCodeRotate;
                   HumanReadable:boolean;
                   FrachtpostKdKennungLen:Integer;
                   constructor create;
                 end;


type
TLLBarcode=class
           public
             Params:TBarcodeParams;
             constructor create;
             destructor destroy;override;
             procedure ToCanvas(Canvas:TCanvas;x,y:Integer;var Point:TPoint);
             procedure PostnetToCanvas(Canvas:TCanvas;x,y:Integer;var Point:TPoint);
            { procedure}
           private
            {Barcode is the same definition as Inputcode in Params}
            {array to hold the chars for coding}
            Barcode:Array[0..MaxbarcodeLen+2] of char;
            {temporary array for Code39}
            temp39array:array[1..(Maxbarcodelen+2)*9] of byte;
            {temporary array for Code25}
            temp25array:array[1..(Maxbarcodelen+2)*5] of byte;
            {Array to hold all modul elements for output}
            Modularray:array[1..MaxModulArray] of byte;
            {How many modul elements are needed for output}
            ModulCount:Integer;
            function  getSize:Extended;
            procedure AllRecalc;
            procedure DoCode_Ean8;
            procedure DoCode_Ean13;
            procedure DoCode_UPCA;
            procedure DoCode_UPCE;
            procedure DoCode_Code39;
            procedure DoCode_Code25I;
            procedure DoCode_128(CodeTable:Char);
            procedure DoCode_MSIPlessey;
            procedure DoCode_Codabar;
            procedure DoCode_Postnet;
            procedure DoCode_Postnet_FIM;
            procedure AppendAddon2;
            procedure AppendAddon5;
            procedure AddFrachtpostPunkte(Barcode:Pchar);
            procedure Beschriftung(Canvas:TCanvas;x,y,xout,yout,w,h,codehoehe:Integer;text:Pchar);
            procedure DoRect(canvas:Tcanvas;r:TRect;x,y,w,h,modulewidth:Integer);
          end;


implementation
uses sysutils;

constructor TBarcodeParams.create;
{Set defaults for barcode}
begin
  inherited create;
  strcopy(Inputcode,'4711');
  BTyp:=EAN_8;
  SCSize:=SC2;
  HeightPerCent:=100;
  Fontname:='Arial';
  Fontscaling:=100;
  HumanReadable:=true;
  ReduceWidth:=false;
  HDCode:=false;
  ZoomSize:=false;
  rotate:=rotate_000;
  FrachtpostKdKennungLen:=7;
end;

type
  Str2=string[2];
  Str4=string[4];
  Str7=string[7];
  Str6=string[6];
  Str5=string[5];
  Str9=string[9];
  Str11=string[11];


const
EAN_Zeichensatz_A:array[0..9] of Str7=
      ('0001101', '0011001', '0010011', '0111101', '0100011',
       '0110001', '0101111', '0111011', '0110111', '0001011');

EAN_Zeichensatz_B:array[0..9] of Str7=
      ('0100111', '0110011', '0011011', '0100001', '0011101',
       '0111001', '0000101', '0010001', '0001001', '0010111');

EAN_Zeichensatz_C:array[0..9] of Str7=
      ('1110010', '1100110', '1101100', '1000010', '1011100',
       '1001110', '1010000', '1000100', '1001000', '1110100');

EAN_Char13:array[0..9] of Str6=
      ('AAAAAA',  'AABABB',  'AABBAB',  'AABBBA',  'ABAABB',
       'ABBAAB',  'ABBBAA',  'ABABAB',  'ABABBA',  'ABBABA');

Addon2_Table:array[0..3] of Str2=('AA','AB','BA','BB');

Addon5_Table:array[0..9] of Str5=
      ('BBAAA','BABAA','BAABA','BAAAB','ABBAA',
       'AABBA','AAABB','ABABA','ABAAB','AABAB');

UPC_Char8:array[0..9] of str6= {untested}
      ('BBBAAA',  'BBABAA',  'BBAABA',  'BBAAAB',  'BABBAA',
       'BAABBA',  'BAAABB',  'BABABA',  'BABAAB',  'BAABAB');

const
  Numeric_Chars:String[10]=('0123456789');

  {Code 25i: Breiter Code= 3fache Breite wie schmaler Code}
  code25i_Code:array[0..9] of str5=
  ('00110','10001','01001','11000','00101', {01234}
   '10100','01100','00011','10010','01010');{56789}
  code25start:string[4]='0000';
  code25stop:string[4]='0100';


type
  TBarCode39=class
            {Chars and Code array will be initialized on creation}
            Chars:String[44];
            Code:array[0..43] of Str9;
            Procedure InitCode39;
            Constructor Create;
          end;

  TBarCode128=class
             {Chars and Code2 array will be initialized on creation}
             Chars:string[107];
             Code2:array[0..106] of Str11;
             Procedure InitCode128;
             Constructor Create;
           end;

  TBarCodabar=class
                Chars:string[20];
                Code:array[0..19] of Str7;
                Procedure InitCodabar;
                Constructor Create;
              end;

  TBarPostnet=class
                Chars:string[10];
                Code:array[0..9] of Str5;
                Code_FIM_A,Code_FIM_B,Code_FIM_C:Str9;
                Procedure InitPostnet;
                Constructor Create;
              end;
var
  BarCode39 :TBarCode39;
  BarCode128:TBarCode128;
  BarCodabar:TBarCodabar;
  BarPostnet:TBarPostnet;

{If the bit is a 1, the pattern to be used is a wide bar followed by a narrow space.
 If the bit is to be a 0, the pattern is a narrow bar followed by a wide space.}
const MSI_Plessey_Code:array[0..9] of Str9=
         ('0000', '0001', '0010', '0011', '0100',{01234}
          '0101', '0110', '0111', '1000', '1001' {56789});

(*Alternative, nicht verwendet da aufwendiger zu codieren
const {0-schmales Element, 1-breites Element abwechselnd Bar-Space}
  MSI_Plessey_Code:array[0..11] of Str9=
   ('01010101', '01010110', '01011001', '01011010', '01100101', {01234}
    '01100110', '01101001', '01101010', '10010101', '10010110', {56789}
    '10'      , '010' {Startchar, Stopchar});*)

const
  ean8ProofCode:Pchar= '3131313';      {7 Zeichen Prüfcode}
  ean13ProofCode:Pchar='131313131313'; {12 Zeichen Prüfcode}
  upcAProofCode:Pchar='31313131313';   {11 Zeichen Prüfcode, auch für UPC-E}
  code25iProofCode:PChar ='31313131313131313131313131313131313131313131313131';
  code25IPProofCode:Pchar='49494949494949494949494949494949494949494949494949';

function isAllDigits(pc:Pchar):boolean;
var i:Integer;
begin
  isAllDigits:=true;
  for i:=0 to strlen(pc)-1 do
  begin
    if not (pc[i] in ['0'..'9']) then
    begin
      isAllDigits:=false;
      exit;
    end;
  end;
end;

procedure TransfervalidCodabar(Inchars,Outchars:PChar);
var
  MyCode:string[maxbarcodelen+2];
  i:Integer;
begin
  MyCode:='';
  strupper(Inchars);
  for i:=1 to strlen(Inchars) do
  begin
    if (i=1) and not (Inchars[i-1] in ['A','B','C','D']) then
      MyCode:=MyCode+'A';
    If pos(InChars[i-1],BarCodabar.Chars)>0 then
      MyCode:=MyCode+Inchars[i-1];
    if (i=strlen(Inchars)) and not (Inchars[i-1] in ['A','B','C','D']) then
      MyCode:=MyCode+'A';
  end;
  while (length(MyCode)<2) do MyCode:=MyCode+'A';
  For i:=2 to length(MyCode)-1 do
    if (MyCode[i] in ['A','B','C','D']) then MyCode[i]:='0';
  strpcopy(OutChars,MyCode);
end;


function ParseCode128(Inputcode:String;HumanVisible:boolean):string;
{Eingabe: Code128-Startzeichen plus zu codierender String
 Rückgabe: Humanvisible:=false ==> zu codierende Zeichen mit Stopzeichen
           Humanvisible:=true ==> für Textausgabe
}
const
  eos=#255;
type TC128status=(CodeNone,CodeA,CodeB,CodeC);
var
  Code128Status:TC128Status;
  num:Integer;
  PendingDigit:string[2];
  c:char;
  byteval:Byte;
  err:Integer;

  function NextChar:Char;
  begin
    inc(num);
    if num<=length(Inputcode) then
      result:=Inputcode[num]
    else
      result:=eos;
  end;

begin
  result:='';
  pendingDigit:='';
  num:=0;
  Code128Status:=CodeNone;
  repeat
    c:=nextchar;
    case c of
      #135:begin  {Start-A}
             Code128status:=CodeA;
             if not HumanVisible then result:=result+c;
           end;
      #136:begin  {Start-B}
             Code128status:=CodeB;
             if not HumanVisible then result:=result+c;
           end;
      #137:begin  {Start-C}
             Code128status:=CodeC;
             if not HumanVisible then result:=result+c;
           end;
      #131:begin
             if Code128status in [CodeA,CodeB] then
             begin  {CODE-C}
               Code128status:=CodeC;
               if not humanvisible then result:=result+c;
             end
             else if Humanvisible then result:=result+' ' else result:=result+c;
           end;
      #132:begin
             if Code128status in [CodeA,CodeC] then
             begin
               Code128status:=CodeB;
               if not humanvisible then result:=result+c;
             end
             else if Humanvisible then result:=result+' ' else result:=result+c;
           end;
      #133:begin
             if Code128status in [CodeB,CodeC] then
             begin
               Code128status:=CodeA;
               if not humanvisible then result:=result+c;
             end
             else if Humanvisible then result:=result+' ' else result:=result+c;
           end;
       eos:begin
             if (Code128Status=CodeC) and (pendingDigit<>'') then
             begin
               If HumanVisible then
                 result:=result+PendingDigit
               else
                 result:=result+#133+PendingDigit;
             end;
             if not humanvisible then result:=result+chr(106+32); {Stopzeichen}
           end;
      else begin
             if (Code128status=CodeC) then
             begin
               if PendingDigit='' then
               begin
                 if c=#134 then  {FNC1}
                 begin
                   if not HumanVisible then
                     result:=result+c    {append FNC1 to code}
                   else
                     result:=result+' '; {show visble as space}
                 end
                 else
                 begin
                   if not (c in ['0'..'9']) then c:='0';
                   pendingDigit:=c;
                 end
               end
               else {schon eine Ziffer in Lauerstellung}
               begin
                 if not (c in ['0'..'9']) then c:='0';
                 Pendingdigit:=PendingDigit+c;
                 If HumanVisible then
                   result:=result+PendingDigit
                 else
                 begin
                   val(Pendingdigit,byteval,err);
                   result:=result+chr(byteval+32);
                 end;
                 pendingDigit:='';
               end;
             end
             else
             begin  {Code A oder B}
               if not HumanVisible then
                 result:=result+c {Code A + B , Zeichen anhängen}
               else
               begin {HumanReadable, nicht darstellbare Zeichen filtern}
                 if (Code128Status=CodeA) and (ord(c)<=95) then
                   result:=result+c
                 else if (Code128Status=CodeB) and (ord(c)<=126) then
                   result:=result+c
                 else result:=result+' ';
               end;
             end;
           end;
    end;
  until c=eos;
end;


procedure Transfervalidchars(Inchars,Outchars:PChar;typ:lbtCodeTypes);
{gültige Zeichen zum Codieren übertragen}
var
  i,num,error:Integer;
  validatestring,c128:string;
  startChar,stopChar:Char;
begin
  case typ of
    Code39: validatestring:=BarCode39.Chars;
    Postnet: validatestring:=BarPostnet.Chars;
    Postnet_FIM: begin
                   validatestring:='ABCabc';
                 end;
    Code128_A: begin
                 StrPcopy(OutChars,ParseCode128(char(103+32)+strpas(Inchars),false));
                 exit;
               end;
    Code128_B: begin
                 StrPcopy(OutChars,ParseCode128(char(104+32)+strpas(Inchars),false));
                 exit;
               end;
    Code128_C: begin
                 StrPcopy(OutChars,ParseCode128(char(105+32)+strpas(Inchars),false));
                 exit;
               end;
    Codabar: begin
               TransferValidCodabar(Inchars,Outchars);
               exit;
             end;
    else
      validatestring:=Numeric_Chars;
  end;
  for i:=0 to Integer(strlen(Inchars))-1 do
    if pos(Inchars[i],validatestring)>0 then
    begin
      Outchars[i]:=Inchars[i];
      If typ in [Code39,Codabar] then Outchars[i]:=upcase(Outchars[i]);
    end
    else
      Outchars[i]:='0';
  Outchars[strlen(Inchars)]:=#0;
  if typ in [Code39,Code128_A,Code128_B,Code128_C] then
  begin  {Start und Stopzeichen einfügen/anhängen}
    case typ of
    Code39:    begin
                 StartChar:='*';
                 StopChar:='*';
               end;
    else
      Raise EOverflow.create('Unknown barcode type in BARLL (TransfervalidChars)');
    end;
    i:=strlen(Outchars);
    strmove(@Outchars[1],@Outchars[0],i);
    outchars[0]:=startChar;
    Outchars[i+1]:=StopChar;
    Outchars[i+2]:=#0;
  end;
end;

function UPC_E_Proofsum(code:Pchar):longint;
type str10=string[10];
const
  proofarray:array[0..9] of str10=
{ Last Digit Decoded UPC-A, Example 123453 would be 12300-00045}
     {0}   ('XX00000XXX',
     {1}    'XX10000XXX',
     {2}    'XX20000XXX',
     {3}    'XXX00000XX',
     {4}    'XXXX00000X',
     {5}    'XXXXX00005',
     {6}    'XXXXX00006',
     {7}    'XXXXX00007',
     {8}    'XXXXX00008',
     {9}    'XXXXX00009');
var
  i,j,proofsum:Integer;
  earray:str10;
  upcaarray:string;
  ProofCode:Pchar;
begin
  earray:=proofarray[ord(code[5])-ord('0')];
  upcaarray:='0';
  j:=0;
  for i:=1 to length(earray) do
  begin
    if earray[i]='X' then
    begin
      upcaarray:=upcaarray+code[j];
      inc(j);
    end
    else
      upcaarray:=upcaarray+earray[i];
  end;
  if length(upcaarray)<>11 then raise eOverflow.create('Decoded legth of UPC-E code is wrong!');
  {Calculate proof sum and proof sign}
  Proofcode:=upcAProofcode;
  ProofSum:=0;
  for i:=1 to length(upcaarray) do
  begin
    inc(ProofSum,(ord(upcaarray[i])-ord('0'))*(ord(ProofCode[i-1])-ord('0')));
  end;
  UPC_E_Proofsum:=Proofsum;
end;

procedure Add128ProofChar(code:Pchar;Typ:lbtCodeTypes);
{Input: Code128 including Start and Stop Char}
{Output: Appended ProofChar for Code128 before Stop Char}
var
  i:Integer;
  sum:Longint;
  Refnumber:integer;
begin
  Refnumber:=pos(code[0],BarCode128.Chars)-1;
  sum:=Refnumber;
  for i:=1 to strlen(code)-2 do {stop char is not calculated}
  begin
    Refnumber:=pos(code[i],BarCode128.Chars)-1;
    If Refnumber>=0 then
      inc(sum,Refnumber*i)
    else
      raise EOverflow.create('BarcoLL: Code128 error');
  end;
  sum:=sum mod 103;
  code[strlen(code)-1]:=BarCode128.Chars[sum+1];
  code[strlen(code)+1]:=#0;
  code[strlen(code)]:=BarCode128.Chars[107];{Stop Char #106 in array, array starts with 0}
end;

procedure AddProofChar(code:Pchar;Typ:lbtCodeTypes);
{AppendProofChar for all Codes except Code128}
{Input: Code without proof sign,
        len=6 with UPC-E,
        len=7 with EAN-8,
        len=11 with UPC-A
        len=12 with EAN-13
        len=odd with Code25i
 Output: proof sign will be added to code
         len=7 with UPC-E,
         len=8 with EAN-8,
         len=12 with UPC-A
         len=13 with EAN-13
         len=even with Code25i}
var
  i,ProofSum:Integer;
  ProofCode:Pchar;
  ProofChar:Char;
begin
 case Typ of
   EAN_8   : ProofCode:=EAN8ProofCode;
   EAN_13  : ProofCode:=EAN13ProofCode;
   UPC_A   : ProofCode:=upcAProofCode;
   UPC_E   : ProofCode:=upcAProofCode;{not needed}
   CODE25i : ProofCode:=code25IProofCode;
   CODE25iP: ProofCode:=code25IPProofCode;
   Postnet : ProofCode:='11111111111';
   else raise EOverflow.create('BarcoLL: No check char with this barcode type');
 end;
 {Calculate proof sum and proof sign}
 ProofSum:=0;
 for i:=0 to integer(strlen(Code))-1 do
 begin
   inc(ProofSum,(ord(code[i])-ord('0'))*(ord(ProofCode[i])-ord('0')));
 end;
 if Typ=UPC_E then proofsum:=UPC_E_Proofsum(code);

 ProofSum:=ProofSum mod 10;
 if ProofSum>0 then ProofSum:=10-ProofSum;
 ProofChar:=char(ProofSum+ord('0'));
 {Add proof char to end of code}
 i:=strlen(code);
 code[i]:=ProofChar;
 code[i+1]:=#0;
end;

procedure AddMSIProofchar(code:Pchar;Typ:lbtCodeTypes);
var
  i,error:integer;
  compval:longint;
  substrEven,substrOdd:string[Maxbarcodelen div 2];
  s:string[Maxbarcodelen];
  Proofsum:Integer;
  Proofchar:Char;
begin
  if Typ<>MSI_Plessey then raise(Eoverflow.create('Wrong barcode type in procedure AddMSIProofchar'));
  substrEven:='';
  substrOdd:='';
  i:=strlen(code)-1;{last index in string}
  while i>=0 do  {neuen strings aus allen geraden/ungeraden Stellen bilden}
  begin
    substrOdd:=code[i]+substrOdd;
    if i>0 then substrEven:=code[i-1]+substrEven;
    dec(i,2);
  end;
  val(substrOdd,compval,error);
  compval:=compval*2;
  str(compval,substrOdd);
  if copy(substrOdd,1,1)=' ' then substrOdd:=copy(substrOdd,2,255);
{  showmessage(format('%s',[substrOdd]));}
  s:=substrOdd+substrEven;
  Proofsum:=0;
  for i:=1 to length(s) do inc(Proofsum,ord(s[i])-ord('0'));
  ProofSum:=ProofSum mod 10;
  if ProofSum>0 then ProofSum:=10-ProofSum;
  ProofChar:=char(ProofSum+ord('0'));
  {Add proof char to end of code}
  i:=strlen(code);
  code[i]:=ProofChar;
  code[i+1]:=#0;
end;

(*
procedure AddCodabarProofchar(code:Pchar;Typ:lbtCodeTypes);
begin
  if Typ<>Codabar then raise(Eoverflow.create('Wrong barcode type in procedure AddCodabarProofchar'));
end;
  *)

procedure FixBarcode(FromCode,ToCode:Pchar;CodeTyp:lbtCodeTypes);
begin
  {Transfer valid chars from Inputcode to Barcode}
{  if strlen(Fromcode)=0 then
    showmessage('0');}
  TransferValidChars(FromCode,ToCode,CodeTyp);
  case CodeTyp of
    EAN_13: begin  {maxlen 12 without proof char}
                strLCopy(ToCode,ToCode,12);
                {Fill up with zeros if too short}
                while strlen(ToCode)<12 do strcat(ToCode,'0');
                AddProofChar(ToCode,CodeTyp);
              end;
    UPC_A : begin   {maxlen 11 without proof char}
                strLCopy(ToCode,ToCode,11);
                {Fill up with zeros if too short}
                while strlen(ToCode)<11 do strcat(ToCode,'0');
                AddProofChar(ToCode,CodeTyp);
              end;
    EAN_8:   begin {maxlen 7 without proof char}
                strLCopy(ToCode,ToCode,7);
                {Fill up with zeros if too short}
                while strlen(ToCode)<7 do strcat(ToCode,'0');
                AddProofChar(ToCode,CodeTyp);
              end;
    UPC_E : begin {maxlen 6 without proof char}
                strLCopy(ToCode,ToCode,6);
                {Fill up with zeros if too short}
                while strlen(ToCode)<6 do strcat(ToCode,'0');
                AddProofChar(ToCode,CodeTyp);
              end;
    CODE39:begin

           end;
    CODE25i,
    CODE25iP:
             begin
               if strlen(ToCode) mod 2 =1 then AddProofChar(ToCode,CodeTyp);
             end;
    CODE128_A,
    CODE128_B,
    CODE128_C: begin
                 Add128ProofChar(ToCode,CodeTyp);
                 {If ToCode[1]='C' then
                   raise EOverFlow.Create(strpas(ToCode));}
               end;
    MSI_Plessey: begin
                   AddMSIProofchar(ToCode,CodeTyp);
                 end;
    Codabar: begin
               { AddCodabarProofchar(ToCode,CodeTyp);}
             end;
    Postnet: begin
               if strlen(ToCode)>=11 then
                 strLCopy(ToCode,ToCode,11)
               else if strlen(ToCode)>=9 then
                 strLCopy(ToCode,ToCode,9)
               else
               begin
                 strLCopy(ToCode,ToCode,5);
                 while strlen(ToCode)<5 do strcat(ToCode,'0');
               end;
               AddProofchar(ToCode,CodeTyp);
             end;
    Postnet_FIM: ; {do nothing}
    else raise EOverflow.create('Barcode: Unknown Type of Barcode');
  end;
end;


procedure TLLBarcode.AllRecalc;
begin
  {Clear Modularray}
  fillchar(modularray,sizeof(modularray),#0);
  {fix incomplete or incorrect inputcode,
   add proof char if necessary}
  with params do
    FixBarcode(@Inputcode,@Barcode,bTyp);
  {finally code the modularray}
  case params.bTyp of
    EAN_8   : DoCode_EAN8;
    EAN_13  : begin
                DoCode_EAN13;
              end;
    UPC_A   : DoCode_UPCA;
    UPC_E   : DoCode_UPCE;
    CODE39  : DoCode_CODE39;
    CODE25i,
    CODE25iP: DoCode_CODE25i;
    Code128_A:DoCode_128('A');
    Code128_B:DoCode_128('B');
    Code128_C:DoCode_128('C');
    MSI_Plessey:DoCode_MSIPlessey;
    Codabar:DoCode_Codabar;
    Postnet:DoCode_Postnet;
    Postnet_FIM:DoCode_Postnet_FIM;
  end;
  If params.bTyp in [EAN_13,UPC_A] then
  begin
    case strlen(Params.AddonCode) of
      0: ;
      2: AppendAddon2;
      5: AppendAddon5;
      else raise(EOverflow.Create('BarLL: Wrong Addoncode'));
    end;
  end;
end;


constructor TLLBarcode.create;
begin
  inherited create;
  Params:=TBarcodeparams.create;
end; {TLLBarcode.create}

destructor TLLBarcode.destroy;
begin
  Params.free;
  inherited destroy;
end;


procedure TLLBarcode.DoCode_Ean13;
{Zweck: Modularray mit Lücke/Balken für EAN13 codieren}
var
  i,j:Integer;
  ModulCode:Str7;
  CharCode:Str6;
begin
  {Start: Modularray codieren}
  Modularray[1]:=1;  {Randzeichen 3 Module}
  Modularray[2]:=0;
  Modularray[3]:=1;

  charcode:=ean_char13[ord(Barcode[0])-ord('0')];
  for i:=0 to 5 do
  begin
    if Charcode[i+1]='A' then
    begin
      j:=ord(Barcode[i+1])-ord('0');
      ModulCode:=EAN_Zeichensatz_A[j]
    end
    else if Charcode[i+1]='B' then
      ModulCode:=EAN_Zeichensatz_B[ord(Barcode[i+1])-ord('0')]
    else EOverflow.Create('Barcode: Wrong EAN-charset (Internal error)');

    for j:=0 to 6 do
    begin
      Modularray[4+i*7+j]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;

  Modularray[46]:=0; {Trennzeichen 5 Module}
  Modularray[47]:=1;
  Modularray[48]:=0;
  Modularray[49]:=1;
  Modularray[50]:=0;

  for i:=0 to 5 do
  begin
    j:=ord(Barcode[i+7])-ord('0');
    ModulCode:=EAN_Zeichensatz_C[j];

    for j:=0 to 6 do
    begin
      Modularray[51+i*7+j]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;

  Modularray[93]:=1; {Randzeichen 3 Module}
  Modularray[94]:=0;
  Modularray[95]:=1;
  ModulCount:=3+5+3+12*7;{95 Modules}
end; {DoCode_Ean13}

procedure TLLBarcode.AppendAddon2;
var
  i,j,StartAt:Integer;
  li:Longint;
  ModulCode:Str7;
  CharCode:Str2;
begin
  StartAt:=105;
  Modularray[StartAt]:=1;
  Modularray[StartAt+1]:=0;
  Modularray[StartAt+2]:=1;
  Modularray[StartAt+3]:=1;
  Val(strpas(Params.AddonCode),li,j);
  {Zeichensatz für Addon-2 ermitteln}
  CharCode:=Addon2_Table[li mod 4];{e.e. 'AA'}
  for i:=0 to 1 do
  begin
    if Charcode[i+1]='A' then
      ModulCode:=EAN_Zeichensatz_A[ord(Params.AddonCode[i])-ord('0')]
    else if Charcode[i+1]='B' then
      ModulCode:=EAN_Zeichensatz_B[ord(Params.AddonCode[i])-ord('0')]
    else EOverflow.Create('AddonCode: Wrong EAN-charset (Internal error)');
    for j:=0 to 6 do
    begin
      Modularray[StartAt+4+i*9+j]:=ord(Modulcode[j+1])-ord('0');
    end;
    if i<1 then
    begin
      Modularray[StartAt+4+i*9+7]:=0;
      Modularray[StartAt+4+i*9+8]:=1;
    end;
  end;
  Modulcount:=StartAt+4+9+7;
end;

procedure TLLBarcode.AppendAddon5;
var
  i,j,StartAt:Integer;
{  li:Longint;}
  ModulCode:Str7;
  CharCode:Str5;
  table1,table2,table:Integer;
begin
  StartAt:=105;
  {Startzeichen Addon-5}
  Modularray[StartAt]:=1;
  Modularray[StartAt+1]:=0;
  Modularray[StartAt+2]:=1;
  Modularray[StartAt+3]:=1;
{  Val(strpas(Params.AddonCode),li,j);}
  {Zeichensatz für Addon-5 ermitteln}
  with params do
  begin
    {1., 3. und 5. Stelle mit 3 multiplizieren}
    table1:=ord(Addoncode[0])-ord('0');
    inc(table1,ord(Addoncode[2])-ord('0'));
    inc(table1,ord(Addoncode[4])-ord('0'));
    table1:=table1*3;
    {2. und 4. Stelle mit 9 multiplizieren}
    table2:=ord(Addoncode[1])-ord('0');
    inc(table2,ord(Addoncode[3])-ord('0'));
    table2:=table2*9;
    table:=(table1+table2) mod 10;
  end;
  CharCode:=Addon5_Table[Table];{i.e. 'BBAAA'}
  for i:=0 to 4 do
  begin
    if Charcode[i+1]='A' then
      ModulCode:=EAN_Zeichensatz_A[ord(Params.AddonCode[i])-ord('0')]
    else if Charcode[i+1]='B' then
      ModulCode:=EAN_Zeichensatz_B[ord(Params.AddonCode[i])-ord('0')]
    else EOverflow.Create('AddonCode: Wrong EAN-charset (Internal error)');
    for j:=0 to 6 do
    begin
      Modularray[StartAt+4+i*9+j]:=ord(Modulcode[j+1])-ord('0');
    end;
    if i<4 then
    begin
      Modularray[StartAt+4+i*9+7]:=0;
      Modularray[StartAt+4+i*9+8]:=1;
    end;
  end;
  Modulcount:=StartAt+4+4*9+7;
end;

procedure TLLBarcode.DoCode_UPCE;
{Zweck: Modularray mit Lücke/Balken für UPC-E codieren}
var
  i,j:Integer;
  ModulCode:Str7;
  CharCode:Str6;
begin
  {Start: Modularray codieren}
  Modularray[1]:=1;  {Randzeichen 3 Module}
  Modularray[2]:=0;
  Modularray[3]:=1;
  charcode:=upc_char8[ord(Barcode[6])-ord('0')];{Proofchar}
  for i:=0 to 5 do
  begin
    if Charcode[i+1]='A' then
    begin
      j:=ord(Barcode[i{+1}])-ord('0');
      ModulCode:=EAN_Zeichensatz_A[j]
    end
    else if Charcode[i+1]='B' then
      ModulCode:=EAN_Zeichensatz_B[ord(Barcode[i{+1}])-ord('0')]
    else EOverflow.Create('Barcode: Wrong EAN-charset (Internal error)');
    for j:=0 to 6 do
    begin
      Modularray[4+i*7+j]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;
  {Set Modulcount and code stop character}
  Modulcount:=3+7*7-1;
  Modularray[modulcount]:=1;
  Modularray[modulcount-1]:=0;
  Modularray[modulcount-2]:=1;
  Modularray[modulcount-3]:=0;
  Modularray[modulcount-4]:=1;
  Modularray[modulcount-5]:=0;
end;


procedure TLLBarcode.DoCode_UPCA;
{Zweck: Modularray mit Lücke/Balken für UPC-A codieren}
var
  i,j:Integer;
  ModulCode:Str7;
begin
  {Start: Modularray codieren}
  Modularray[1]:=1;  {Randzeichen 3 Module}
  Modularray[2]:=0;
  Modularray[3]:=1;
  for i:=0 to 5 do
  begin
    ModulCode:=EAN_Zeichensatz_A[ord(Barcode[i])-ord('0')];
    for j:=0 to 6 do
    begin
      Modularray[4+i*7+j]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;

  Modularray[46]:=0; {Trennzeichen 5 Module}
  Modularray[47]:=1;
  Modularray[48]:=0;
  Modularray[49]:=1;
  Modularray[50]:=0;

  for i:=0 to 5 do
  begin
    ModulCode:=EAN_Zeichensatz_C[ord(Barcode[i+6])-ord('0')];
    for j:=0 to 6 do
    begin
      Modularray[51+i*7+j]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;

  Modularray[93]:=1; {Randzeichen 3 Module}
  Modularray[94]:=0;
  Modularray[95]:=1;
  ModulCount:=3+5+3+12*7;{95 Modules}
end; {DoCode_UPCA}


procedure TLLBarcode.DoCode_Ean8;
{Zweck: Modularray mit Lücke/Balken für EAN8 codieren}
var
  i,j:Integer;
  ModulCode:Str7;
begin
  {Start: Modularray codieren}
  Modularray[1]:=1;  {Randzeichen 3 Module}
  Modularray[2]:=0;
  Modularray[3]:=1;

  for i:=0 to 3 do
  begin
    ModulCode:=EAN_Zeichensatz_A[ord(Barcode[i])-ord('0')];
    for j:=0 to 6 do
    begin
      Modularray[4+i*7+j]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;
  Modularray[32]:=0; {Trennzeichen 5 Module}
  Modularray[33]:=1;
  Modularray[34]:=0;
  Modularray[35]:=1;
  Modularray[36]:=0;
  for i:=0 to 3 do
  begin
    ModulCode:=EAN_Zeichensatz_C[ord(Barcode[i+4])-ord('0')];
    for j:=0 to 6 do
    begin
      Modularray[37+i*7+j]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;

  Modularray[65]:=1; {Randzeichen 3 Module}
  Modularray[66]:=0;
  Modularray[67]:=1;
  ModulCount:=3+5+3+8*7;{67 Modules}
end;

procedure TLLBarcode.DoCode_128(CodeTable:Char);
var
  i,j,charAscii:Integer;
  ModulCode:Str11;
begin
  {Start: Modularray codieren}
  for i:=0 to Integer(strlen(Barcode))-1 do
  begin
    CharAscii:=ord(BarCode128.Chars[ord(Barcode[i])-ord(' ')+1]);
{    Showmessage(format('Ascii %d',[CharAscii]));}
    ModulCode:=BarCode128.Code2[CharAscii-ord(' ')];
    for j:=0 to 10 do
    begin
      Modularray[i*11+j+1]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;
  Modulcount:=11*strlen(Barcode);
  Modularray[modulcount+1]:=1;
  Modularray[modulcount+2]:=1;
  inc(Modulcount,2);
{  Modularray[;}
end;

procedure TLLBarcode.DoCode_MSIPlessey;
var
  i:Integer;
  tempbits:string[4*Maxbarcodelen];
begin
  tempbits:='1';{Startbit}
  for i:=0 to integer(strlen(barcode))-1 do
  begin {Alle Zeichen zufügen}
    tempbits:=tempbits+MSI_Plessey_Code[ord(barcode[i])-ord('0')];
  end;
  tempbits:=tempbits+'00';
  Modulcount:=0;
  for i:=1 to length(tempbits) do
  begin
    if tempbits[i]='1' then
    begin
      inc(Modulcount);
      Modularray[Modulcount]:=1;
      inc(Modulcount);
      Modularray[Modulcount]:=1;
      If Params.Ratio=Ratio_3 then
      begin
        inc(Modulcount);
        Modularray[Modulcount]:=1;
      end;
      inc(Modulcount);
      Modularray[Modulcount]:=0;
    end
    else
    begin
      inc(Modulcount);
      Modularray[Modulcount]:=1;
      inc(Modulcount);
      Modularray[Modulcount]:=0;
      inc(Modulcount);
      Modularray[Modulcount]:=0;
      If Params.Ratio=Ratio_3 then
      begin
        inc(Modulcount);
        Modularray[Modulcount]:=0;
      end;
    end;
  end;
end;

procedure TLLBarcode.DoCode_Codabar;
{Zweck: Modularray mit Lücke/Balken für Codabar codieren}
var
  i,j:Integer;
  c:char;
  tempbits:string[7];
  strich:Integer;
  x:string;
begin
  Modulcount:=0;
  x:='';
  for i:=1 to strlen(barcode) do
  begin
    c:=barcode[i-1];
    tempbits:=BarCodabar.code[pos(c,BarCodabar.chars)-1];
    x:=x+tempbits;
    for j:=1 to length(tempbits) do
    begin
      if j mod 2=1 then strich:=1 else strich:=0;
      if tempbits[j]='1' then
      begin
        inc(Modulcount);
        Modularray[Modulcount]:=strich;
        inc(Modulcount);
        Modularray[Modulcount]:=strich;
        If Params.Ratio=Ratio_3 then
        begin
          inc(Modulcount);
          Modularray[Modulcount]:=strich;
        end;
      end
      else
      begin
        inc(Modulcount);
        Modularray[Modulcount]:=strich;
      end;
    end;
    inc(Modulcount);
    Modularray[Modulcount]:=0;
  end;
end;

procedure TLLBarcode.DoCode_Postnet;
var
  i,j:Integer;
  Codestring:Str5;
begin
  Modularray[1]:=1;  {Randzeichen 3 Module}
  Modulcount:=1;
  for i:=0 to integer(strlen(barcode))-1 do
  begin {Alle Zeichen einzeln codieren}
    Codestring:=BarPostnet.Code[ord(barcode[i])-ord('0')];
    for j:=1 to 5 do
    begin
      if Codestring[j]='1' then
        Modularray[Modulcount+1]:=1
      else
        Modularray[Modulcount+1]:=0;
      inc(Modulcount);
    end;
  end;
  Modularray[Modulcount+1]:=1;
  inc(Modulcount);
end;

procedure TLLBarcode.DoCode_Postnet_FIM;
var
  i,j:Integer;
  Codestring:Str9;
begin
  case upcase(barcode[0]) of
    'A': begin
           Codestring:=BarPostnet.Code_FIM_A;
           strcopy(barcode,'FIM-A');
         end;
    'B': begin
           Codestring:=BarPostnet.Code_FIM_B;
           strcopy(barcode,'FIM-B');
         end;
    else {'C':} begin
                  Codestring:=BarPostnet.Code_FIM_C;
                  strcopy(barcode,'FIM-C');
                end;
  end;
  Modulcount:=0;
  for j:=1 to 9 do
  begin
    if Codestring[j]='1' then
      Modularray[Modulcount+1]:=1
    else
      Modularray[Modulcount+1]:=0;
    inc(Modulcount);
  end;
end;


procedure TLLBarcode.DoCode_Code39;
{Zweck: Modularray mit Lücke/Balken für Code39 codieren}
var
  i,j:Integer;
  numchar:Integer;
  Modulcode:str9;
{  substr:string[1];}
begin
  {Bei Code39 sind nur Großbuchstaben erlaubt}
  strupper(barcode);
  for i:=0 to integer(strlen(barcode))-1 do
  begin {Alle Zeichen einzeln codieren}
    {Dezimalcode des Code39-Zeichens ermitteln}
    numchar:=pos(barcode[i],BarCode39.Chars)-1;
    if numchar<0 then numchar:=0; {ungültige Zeichen werden "0"}
    {die Codierung des Zeichens in ein temporäres Array einfügen}
    Modulcode:=BarCode39.code[numchar];
    for j:=0 to 8 do
    begin
      temp39array[i*9+j+1]:=ord(Modulcode[j+1])-ord('0');
    end;
  end;
  i:=1;
  {Abarbeiten des temporären Arrays,
   erstellen des endgültigen Modularrays}
  for j:=1 to 9*strlen(barcode) do
  begin
    if j mod 9 in [1,3,5,7,0] then {Strich}
    begin
      modularray[i]:=1;
      inc(i);
      if temp39array[j]=1 then {Breiter Strich, 3 Module}
      begin
        modularray[i]:=1;
        inc(i);
        If Params.Ratio=Ratio_3 then
        begin
          modularray[i]:=1;
          inc(i);
        end;
      end;
    end
    else {Lücke}
    begin
      modularray[i]:=0;
      inc(i);
      if temp39array[j]=1 then {Breite Lücke, 3 Module}
      begin
        modularray[i]:=0;
        inc(i);
        If Params.Ratio=Ratio_3 then
        begin
          modularray[i]:=0;
          inc(i);
        end;
      end;
    end;
    if j mod 9=0 then inc(i); {Trennlücke 1 Modul!}
  end;
  modulcount:=i-1;
{  If Modulcount<>strlen(Barcode*13) then
    raise EOverflow.create('BarcoLL: CODE39 has wrong length');}
    {Each char is: 3 wide elements á 2 + 6 small elements+ gap}
end;

procedure TLLBarcode.DoCode_Code25I;
var
  i,j,numchar,numchar1:Integer;
  Modulcode,Modulcode1:str5;
begin
  {Startzeichen: Je 2 schmale Striche und Lücken}
  temp25array[1]:=0;
  temp25array[2]:=0;
  temp25array[3]:=0;
  temp25array[4]:=0;
  {Nutzzeichen codieren}
  for i:=0 to Integer(strlen(barcode))-1 do
  begin {Alle Zeichen einzeln codieren}
    if i mod 2=0 then
    begin
      {Dezimalcode des Code25-Zeichens ermitteln}
      numchar:=pos(barcode[i],Numeric_Chars)-1;
      if numchar<0 then numchar:=0; {ungültige Zeichen werden "0"}
      numchar1:=pos(barcode[i+1],Numeric_Chars)-1;
      if numchar1<0 then numchar1:=0; {ungültige Zeichen werden "0"}
      {die Codierung des Zeichens in ein temporäres Array einfügen}
      Modulcode:=code25i_code[numchar];
      Modulcode1:=code25i_code[numchar1];
      for j:=0 to 4 do
      begin
        temp25array[i*5+2*j+5]:=ord(Modulcode[j+1])-ord('0');
        temp25array[i*5+2*j+6]:=ord(Modulcode1[j+1])-ord('0');
      end;
    end;
  end;
  {Stopzeichen: breiter Strich-schmale Lücke-schmaler Strich}
  temp25array[strlen(barcode)*5+5]:=1;
  temp25array[strlen(barcode)*5+6]:=0;
  temp25array[strlen(barcode)*5+7]:=0;
  i:=1;
  {Abarbeiten des temporären Arrays,
   erstellen des endgültigen Modularrays}
  for j:=1 to 5*strlen(barcode)+4 {Startzeichen}+3{Stopzeichen} do
  begin
    if j mod 2=1 then {Strich}
      begin
      modularray[i]:=1;
      inc(i);
      if temp25array[j]=1 then {Breiter Strich, 3 Module}
      begin
        modularray[i]:=1;
        inc(i);
        If Params.Ratio=Ratio_3 then
        begin
          modularray[i]:=1;
          inc(i);
        end;
      end
    end
    else
    begin    {Lücke}
      modularray[i]:=0;
      inc(i);
      if temp25array[j]=1 then {Breite Lücke, 3 Module}
      begin
        modularray[i]:=0;
        inc(i);
        If Params.Ratio=Ratio_3 then
        begin
          modularray[i]:=0;
          inc(i);
        end;
      end;
    end;
  end;
  modulcount:=i-1;
  {Modulcount:=NumNutzzeichen*5;}
end;

(*
procedure set25BarodeText(code:Pchar);
var s:string;
begin
  s:=strpas(code);
  case strlen(code) of
    12: begin
          s:=copy(s,1,2)+'.'+copy(s,3,3)+'     '+copy(s,6,3)+'.'+copy(s,9,3)+'     '+s[12];

        end;
    14: begin
          s:=copy(s,1,5)+'.'+copy(s,6,3)+'.'+copy(s,9,3)+'.'+copy(s,12,2)+'     '+s[14];
        end;
  end;
  strpcopy(code,s);
end;
  *)

function TLLBarcode.getSize:Extended;
var Size:Extended;
begin
  case Params.SCSize of   {Modulbreite aus Strichcodegröße ermitteln}
    SC0: Size:=0.270; {lt. DIN 66236}
    SC1: Size:=0.297;
    SC2: Size:=0.330;
    SC3: Size:=0.363;
    SC4: Size:=0.396;
    SC5: Size:=0.445;
    SC6: Size:=0.495;
    SC7: Size:=0.544;
    SC8: Size:=0.610;
    SC9: Size:=0.660;
    else Size:=0.330; {Normalgröße setzen}
  end;
  if Params.HDCode then size:=size/2;{HD-Barcode}
  GetSize:=Size;
end;

procedure TLLBarcode.AddFrachtpostPunkte(Barcode:Pchar);
{Eingabe: 12 oder 14-stelliger Frachtpost-Code,
 Rückgabe: Code mit Punkten und Leerzeichen für Klartext-Ausgabe}
var
  temp:array[0..100] of char;
  l:Integer;
begin
  l:=strlen(Barcode);
  If l=14 then {Leitcode}
  begin
    strLcopy(temp,Barcode,5);
    strcat(temp,'.');
    strLcat(temp,@Barcode[5],9);
    strcat(temp,'.');
    strLcat(temp,@Barcode[8],13);
    strcat(temp,'.');
    strLcat(temp,@Barcode[11],16);
    strcat(temp,'   ');
    strcat(temp,@Barcode[13]);
    strcopy(Barcode,temp);
  end
  else if l=12 then {Identcode}
  begin
    strLcopy(temp,Barcode,2);
    strcat(temp,'.');
    strLcat(temp,@Barcode[2],3+Params.FrachtpostKdKennungLen-2);
    strcat(temp,'   ');
    strLcat(temp,@Barcode[Params.FrachtpostKdKennungLen],15);
    strcat(temp,'   ');
    strcat(temp,@Barcode[11]);
    strcopy(Barcode,temp);
  end;
end;


procedure TLLBarcode.Beschriftung(Canvas:TCanvas;x,y,xout,yout,w,h,codehoehe:Integer;text:Pchar);
var
  logfont:TLogfont;
  font,oldfont:THandle;
  dc:HDC;
begin
  dc:=Canvas.handle;
  fillchar(logfont,sizeof(logfont),#0);
  strpcopy(logfont.lffacename,Params.Fontname);
{  logfont.lfOutPrecision:=OUT_TT_ONLY_PRECIS;
  logfont.lfPitchAndFamily:=FF_DontCare;}
  if Params.btyp in [EAN_13,UPC_A] then
    logfont.lfheight:=round(codehoehe*0.18*Params.Fontscaling/100)
  else
    logfont.lfheight:=round(codehoehe*74.24/56.24*0.18*Params.Fontscaling/100);
  case Params.Rotate of
    rotate_000: ;
    rotate_090: logfont.lfescapement:=900;
    rotate_180: logfont.lfescapement:=1800;
    rotate_270: logfont.lfescapement:=2700;
  end;
  font:=createfontindirect(logfont);
  oldfont:=selectobject(DC,font);
  settextalign(DC,ta_center or ta_top);
  dec(xout,x);
  dec(yout,y);
  case params.rotate of
    rotate_000: begin
                  textout(dc,x+xout,y+yout ,text,strlen(text));
                end;
    rotate_090: begin
                  textout(dc,x+yout,y+w-xout,text,strlen(text));
                end;
    rotate_180: begin
                  textout(dc,x+w-xout,y+h-yout,text,strlen(text));
                end;
    rotate_270: begin
                  textout(dc,x+h-yout,y+xout,text,strlen(text));
                end;
  end;
  selectobject(DC,oldfont);
  deleteobject(font);
end;

procedure TLLBarcode.DoRect(canvas:Tcanvas;r:TRect;x,y,w,h,modulewidth:Integer);
begin
  dec(r.left,x);
  dec(r.right,x);
  dec(r.top,y);
  dec(r.bottom,y);
  case params.rotate of
    rotate_000: begin
                  setrect(r,x+r.left,y+r.top,x+r.right,y+r.bottom);
                end;
    rotate_090: begin
                  setrect(r,x+r.top,y+w-r.left,x+r.bottom,y+w-r.right);
                end;
    rotate_180: begin
                  setrect(r,x+w-r.right,y+h-r.top,x+w-r.left,y+h-r.bottom);
                end;
    rotate_270: begin
                  setrect(r,x+h-r.top,y+r.left,x+h-r.bottom,y+r.right);
                end;
  end;
  canvas.fillrect(r);
end;
(*
function Make128Digits(instr:string):string;
var
  i,digit:Integer;
  s:string;
  s2:string[2];
begin
  s:='';
  for i:=1 to length(instr) do
  begin
    digit:=ord(instr[i])-32;
    s2:=format('%2d',[digit]);
    if s2[1]=' ' then s2[1]:='0';
    s:=s+s2;
{    showmessage(s);}
  end;
  Make128Digits:=s;
end;
*)

procedure TLLBarcode.PostnetToCanvas(Canvas:TCanvas;x,y:Integer;var Point:TPoint);
var
  xmm,ymm:Extended;
  ModulWidthI,ModulShortlength,
  ModulLongLength,ModulDistanceI,Fontfactor:Integer;
  ModulWidthR,ModulDistanceR:Extended;
  i:Integer;
  rect:TRect;
  ScreenDC:HDC;
  OldBrushcolor:TColor;
  OldBrushstyle:TBrushStyle;
  OldAlign:Integer;
  ModulX:Array[1..MaxModulArray] of Integer;
begin
  Xmm:=getdevicecaps(Canvas.Handle,LogPixelsX)/25.4;
  Ymm:=getdevicecaps(Canvas.Handle,LogPixelsY)/25.4;
  if (xmm=0) or (ymm=0) then
  begin  {Workaround für QRPrinter.Canvas 16-Bit-Version}
    ScreenDC:=GetDC(0);
    xmm:=getdevicecaps(ScreenDC,LogPixelsX)/25.4;
    Ymm:=getdevicecaps(ScreenDC,LogPixelsY)/25.4;
    ReleaseDC(0,ScreenDC);
  end;
  AllRecalc;
  case Params.btyp of
    Postnet: begin
               ModulWidthI:=round(0.02*25.4*Xmm);
               ModulDistanceR:=(25.4/22*xmm);
               ModulDistanceI:=Round(ModulDistanceR);
               ModulLongLength:=round(0.125*25.4*ymm);
               ModulShortLength:=round(0.05*25.4*ymm);
               Fontfactor:=5;
             end
    else {Postnet_FIM}
             begin
               ModulWidthI:=round(25.4/32*xmm);
               ModulDistanceR:=(25.4/16*xmm);
               ModulDistanceI:=Round(ModulDistanceR);
               ModulLongLength:=round(25.4*5/8*ymm);
               ModulShortLength:=ModulLongLength;
               Fontfactor:=1;
             end;
  end;
  OldBrushcolor:=canvas.brush.color;
  OldBrushstyle:=canvas.brush.style;
  OldAlign:=settextalign(Canvas.handle,ta_center or ta_top);
  canvas.brush.color:=clblack;
  canvas.font.height:=round(Fontfactor*ModulLongLength*74.24/56.24*0.18*Params.Fontscaling/100);
  {Bei Postnet macht ZoomSize:=false keinen Sinn, daher nur:}
    for i:=1 to ModulCount do    {size}
      ModulX[i]:=X+round((i-1)*ModulDistanceR);
  {Statt:
  if Params.zoomsize then
  begin
    for i:=1 to ModulCount do
      ModulX[i]:=X+round((i-1)*25.4/22*xmm);
  end
  else
  begin
    for i:=1 to ModulCount do
      ModulX[i]:=X+round((i-1)*25.4/32*xmm);
  end;
  }
//  point.x:={round}(Moduldistance*Modulcount+1);
//  point.x:=ModulX[ModulCount];    Moduldistance*(modulcount-1)-x+modulwidth{+1};
  Point.x:=ModulX[modulcount]-x+modulwidthI+1;
  if not Params.Humanreadable then
    point.y:=ModulLonglength+1
  else
    Point.y:=ModulLongLength+canvas.textheight('Ay')+1;
  case Params.btyp of
    Postnet: begin
               for i:=1 to Modulcount do
               begin
                 rect.left:=ModulX[i];
                 rect.right:=rect.left+ModulwidthI;
                 if Modularray[i]=1 then
                   rect.top:=y
                 else
                   rect.top:=y+(ModulLongLength-ModulShortLength);
                 Rect.Bottom:=y+ModulLongLength;
                 DoRect(canvas,rect,x,y,point.x,point.y,modulWidthI);
               end;
             end;
     else    begin  {Postnet_FIM}
               For i:=1 to Modulcount do
               begin
                 if Modularray[i]=1 then
                 begin
                   rect.left:=x+{round}((i-1)*ModulDistanceI);
                   rect.right:=rect.left+ModulwidthI;
                   rect.top:=y;
                   Rect.Bottom:=y+ModulLongLength;
                   DoRect(canvas,rect,x,y,point.x,point.y,modulWidthI);
                 end;
               end;
             end;
  end;
  {prepare for human readable text}
  canvas.brush.color:=clWhite;
  canvas.brush.style:=bsclear;
  Beschriftung(Canvas,x,y,(modulX[1]+modulX[modulcount]) div 2,
               Y+ModulLongLength,point.x,point.y,FontFactor*ModulLongLength,barcode);
  {restore brush and textalign}
  canvas.brush.color:=Oldbrushcolor;
  canvas.brush.style:=Oldbrushstyle;
  settextalign(Canvas.handle,OldAlign);
  if Params.Rotate in [rotate_090,rotate_270] then {90 Grad gegen Uhrzeigersinn}
  begin
    i:=point.x;
    point.x:=point.y;
    point.y:=i;
  end;
end; {PostnetToCanvas}

procedure TLLBarcode.ToCanvas(Canvas:TCanvas;x,y:Integer;var Point:TPoint);
var
  xmm,ymm,size,yfactor:Extended;
  i,j,shorten,Modulbreite,BarOffset,
  Codehoehe:Integer;
  Rect:TRect;
  ModulX:Array[1..MaxModulArray] of Integer;
  OldBrushcolor:TColor;
  OldBrushstyle:TBrushStyle;
  OldAlign:Integer;
  screendc:Integer;
  temp:array[0..MaxBarcodeLen] of char;
begin
  if (Params.bTyp in [Postnet,Postnet_FIM]) then {extra handling for Postnet}
  begin
    PostnetToCanvas(Canvas,x,y,Point);
    exit;
  end;
  Xmm:=getdevicecaps(Canvas.Handle,LogPixelsX)/25.4;
  Ymm:=getdevicecaps(Canvas.Handle,LogPixelsY)/25.4;
  OldBrushcolor:=canvas.brush.color;
  OldBrushstyle:=canvas.brush.style;
  OldAlign:=settextalign(Canvas.handle,ta_center or ta_top);
  canvas.brush.color:=clblack;
  if (xmm=0) or (ymm=0) then
  begin  {Workaround für QRPrinter.Canvas 16-Bit-Version}
    ScreenDC:=GetDC(0);
    xmm:=getdevicecaps(ScreenDC,LogPixelsX)/25.4;
    Ymm:=getdevicecaps(ScreenDC,LogPixelsY)/25.4;
    ReleaseDC(0,ScreenDC);
  end;
  AllRecalc;
  Size:=GetSize;
  Modulbreite:=round(Size*Xmm);
  if Modulbreite=0 then Modulbreite:=1;
//  inc(y,round(Size*Ymm)); {Hellzone oben eine Modulbreite}
  if Params.bTyp in [EAN_13,UPC_A] then
  begin
    yfactor:=74.24;
    barOffset:=10*Modulbreite;     {round(10*Size*Xmm);}
  end
  else
  begin
    yfactor:=56.24;
    barOffset:=0{1};
  end;
  if Params.zoomsize then
  begin
    CodeHoehe:=round((yfactor*Size*Ymm));
    for i:=1 to ModulCount do
      ModulX[i]:=X+round((i-1)*Size*xmm)+Baroffset;
  end
  else
  begin
    CodeHoehe:=round((yfactor*Size*Ymm)*(Modulbreite/(Size*Xmm)));
    for i:=1 to ModulCount do
      ModulX[i]:=X+(i-1)*Modulbreite+BarOffset
  end;
  {muldiv errechnet das Produkt als 32-Bit-Wert und liefert nach
   der Division wieder einen 16-Bit Wert zurück}
  shorten:=muldiv(codehoehe,(100-Params.heightPercent),100);
{Geändert wg. überlauf bei hoher Auflösung Linotronic 1270 dpi:}
{            round(codehoehe*(100-Params.heightPercent)/100);}
  {Fontgröße für Beschriftung berechnen}
  canvas.font.name:=Params.Fontname;
  if Params.btyp in [EAN_13,UPC_A] then
    canvas.font.height:=round(codehoehe*0.18*Params.Fontscaling/100)
  else
    canvas.font.height:=round(codehoehe*74.24/56.24*0.18*Params.Fontscaling/100);
  {Gesamtabmessungen des Barcodes berechen}
  Point.x:=baroffset+ModulX[modulcount]-x+{2*}modulbreite+1;
  {If Params.bTyp=UPC_A then inc(Point.x,baroffset);}
  If Params.bTyp in [EAN_8,EAN_13,UPC_A,UPC_E] then
    Point.y:=round(Codehoehe*0.9336-shorten)+canvas.textheight('Ay')+1
  else
    Point.y:=round(Codehoehe*1.0-shorten)+canvas.textheight('Ay')+1;
  If not Params.HumanReadable then
    Point.y:=round(Codehoehe*1.0-shorten)+1{+1};

  i:=0;j:=1;
  repeat
    inc(i,j);j:=1;
    while (i+j<=modulcount) and (modularray[i+j]=modularray[i]) do inc(j);
    if modularray[i]<>0 then
    begin
      If (Params.btyp in [EAN_13,UPC_A]) and (i>100) then {Addon-Code}
        rect.top:=y+canvas.textheight('Ay')+Modulbreite
      else  {All other Barcodes start at rect.top=y}
        rect.top:=y;
      rect.left:=ModulX[i];
      if Params.zoomsize then
        rect.right:=rect.left+round(j*Size*xmm)
      else
        rect.right:=rect.left+j*Modulbreite;
        if (Params.btyp=EAN_13) and (i in[4..45,51..92]) or
           (Params.btyp=EAN_8) and (i in[4..31,37..64]) or
           (Params.btyp=UPC_A) and (i in[4..45,51..92]) or
           (Params.btyp=UPC_E) and (i in[4..45]) then
           rect.bottom:=y+round(codehoehe*0.917)-shorten
        else
          rect.bottom:=y+codehoehe-shorten;
      if Params.reducewidth and (rect.right-rect.left>1) then dec(rect.right); {Strichbreitenkorrektur}
      DoRect(canvas,rect,x,y,point.x,point.y,modulBreite);
    end;
  until i+j>Modulcount;


  {Beschriftung}
  canvas.brush.color:=clWhite;
  canvas.brush.style:=bsclear;
  {Folgende zwei Zeilen für C++ Builder, sonst werden lt. Lomex AG
   schwarze Klartextzeichen auf schwarzem Grund ausgegeben}
  SetBkColor(Canvas.handle,clWhite);
  SetBkMode(Canvas.handle,Transparent);
  if Params.HumanReadable then
  begin
    case Params.btyp of
    EAN_13:
      begin   {Beschriftung EAN13}
        strpcopy(temp,copy(strpas(Barcode),1,1));
        Beschriftung(Canvas,x,y,x+baroffset div 2,Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
        strpcopy(temp,copy(strpas(Barcode),2,6));
        Beschriftung(Canvas,x,y,modulX[25],Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
        strpcopy(temp,copy(strpas(Barcode),8,6));
        Beschriftung(Canvas,x,y,modulX[72],Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
      end;
    UPC_A:
      begin   {Beschriftung UPC-A}
        strpcopy(temp,copy(strpas(Barcode),1,1));
        Beschriftung(Canvas,x,y,x+baroffset div 2,Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
        strpcopy(temp,copy(strpas(Barcode),2,5));
        Beschriftung(Canvas,x,y,modulX[25],Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
        strpcopy(temp,copy(strpas(Barcode),7,5));
        Beschriftung(Canvas,x,y,modulX[72],Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
        strpcopy(temp,copy(strpas(Barcode),12,1));
        Beschriftung(Canvas,x,y,modulX[95]+modulbreite+baroffset div 2,
                     Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,
                     Codehoehe,temp);
      end;
    EAN_8:
      begin   {Beschriftung EAN8}
        strpcopy(temp,copy(strpas(Barcode),1,4));
        Beschriftung(Canvas,x,y,modulX[18],Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
        strpcopy(temp,copy(strpas(Barcode),5,4));
        Beschriftung(Canvas,x,y,modulX[50],Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,temp);
      end;
    UPC_E:
      begin   {Beschriftung UPC-E}
        strpcopy(barcode,copy(strpas(Barcode),1,6));
        Beschriftung(Canvas,x,y,modulX[(modulcount{+1}) div 2{25}],Y+round(Codehoehe*0.917{0.9336})-shorten,point.x,point.y,Codehoehe,barcode);
      end;
    CODE39,Code128_A,Code128_B,Code128_C,Codabar:
      begin
        if Params.btyp in [Code39,Codabar] then {Erstes und letztes Zeichen abschneiden}
          strpcopy(temp,copy(strpas(Barcode),2,Integer(strlen(Barcode))-2))
        else {Erstes und letztes Zeichen sowie Prüfziffer abschneiden}
        begin {Code 128 gesondert auswerten}
{          showmessage(format('%s',[barcode]));}
          strpcopy(temp,ParseCode128(barcode[0]+strpas(Params.Inputcode),true));
{          strpcopy(temp,copy(strpas(Barcode),2,Integer(strlen(Barcode))-3));}
        end;
{        If Params.btyp=Code128_C then
          strpcopy(temp,Make128Digits(strpas(temp)));}
        Beschriftung(Canvas,x,y,modulX[modulcount div 2],Y+Codehoehe-shorten,point.x,point.y,Codehoehe,temp);
      end;
    Code25i,MSI_Plessey: {Beschriftung Code 25i}
      begin
        Beschriftung(Canvas,x,y,modulX[modulcount div 2],Y+Codehoehe-shorten,point.x,point.y,Codehoehe,Barcode);
      end;
    Code25iP: {Beschriftung Code 25iP}
      begin
        AddFrachtpostPunkte(Barcode);
        Beschriftung(Canvas,x,y,modulX[modulcount div 2],Y+Codehoehe-shorten,point.x,point.y,Codehoehe,Barcode);
      end
    else
      begin
        raise EOverflow.create('Unknown Barcode Type in BARLL.PAS');
      end;
    end; {case}
    {Addon-Beschriftung}
    if Params.btyp in [EAN_13, UPC_A] then
    begin
      case strlen(Params.AddonCode) of
        0: ;{no Addon code, do nothing}
        2: Beschriftung(Canvas,x,y,modulX[105+10],Y,point.x,point.y,Codehoehe,Params.AddonCode);
        5: Beschriftung(Canvas,x,y,modulX[105+23],Y,point.x,point.y,Codehoehe,Params.AddonCode);
      end;
    end;
  end; {if Params.HumandReadable}
  canvas.brush.color:=Oldbrushcolor;
  canvas.brush.style:=Oldbrushstyle;
  settextalign(Canvas.handle,OldAlign);
  if Params.Rotate in [rotate_090,rotate_270] then {90 Grad gegen Uhrzeigersinn}
  begin
    i:=point.x;
    point.x:=point.y;
    point.y:=i;
  end;
end;

  (*Not used because data segment restrictions in Delphi-1
  code39_Chars:String[44]=
   ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*');
  code39_Code:array[0..43] of Str9=
  ('000110100', '100100001', '001100001', '101100000', {0123}
   '000110001', '100110000', '001110000', '000100101', {4567}
   '100100100', '001100100', '100001001', '001001001', {89AB}
   '101001000', '000011001', '100011000', '001011000', {CDEF}
   '000001101', '100001100', '001001100', '000011100', {GHIJ}
   '100000011', '001000011', '101000010', '000010011', {KLMN}
   '100010010', '001010010', '000000111', '100000110', {OPQR}
   '001000110', '000010110', '110000001', '011000001', {STUV}
   '111000000', '010010001', '110010000', '011010000', {VXYZ}
   '010000101', '110000100', '011000100', '010101000', {-. $}
   '010100010', '010001010', '000101010', '010010100');{/+%*}*)

Procedure TBarCode39.initCode39;
begin
  Chars:='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*';
  Code[0]:='000110100';
  Code[1]:='100100001';
  Code[2]:='001100001';
  Code[3]:='101100000';
  Code[4]:='000110001';
  Code[5]:='100110000';
  Code[6]:='001110000';
  Code[7]:='000100101';
  Code[8]:='100100100';
  Code[9]:='001100100';
  Code[10]:='100001001';
  Code[11]:='001001001';
  Code[12]:='101001000';
  Code[13]:='000011001';
  Code[14]:='100011000';
  Code[15]:='001011000';
  Code[16]:='000001101';
  Code[17]:='100001100';
  Code[18]:='001001100';
  Code[19]:='000011100';
  Code[20]:='100000011';
  Code[21]:='001000011';
  Code[22]:='101000010';
  Code[23]:='000010011';
  Code[24]:='100010010';
  Code[25]:='001010010';
  Code[26]:='000000111';
  Code[27]:='100000110';
  Code[28]:='001000110';
  Code[29]:='000010110';
  Code[30]:='110000001';
  Code[31]:='011000001';
  Code[32]:='111000000';
  Code[33]:='010010001';
  Code[34]:='110010000';
  Code[35]:='011010000';
  Code[36]:='010000101';
  Code[37]:='110000100';
  Code[38]:='011000100';
  Code[39]:='010101000';
  Code[40]:='010100010';
  Code[41]:='010001010';
  Code[42]:='000101010';
  Code[43]:='010010100';
end;

Constructor TBarCode39.create;
begin
  inherited create;
  InitCode39;
end;


(* Array not used because data segment restrictions in Delphi-1*)
const
  code128_Code1:array[0..106] of Str6=
  ('212222', '222122', '222221', '121223', '121322', { !"#$}
   '131222', '122213', '122312', '132212', '221213', {%&'()}
   '221312', '231212', '112232', '122132', '122231', {*+'-.}
   '113222', '123122', '123221', '223211', '221132', {/0123}
   '221231', '213212', '223112', '312131', '311222', {45678}
   '321122', '321221', '312212', '322112', '322211', {9:;<=}
   '212123', '212321', '232121', '111323', '131123', {>?@AB}
   '131321', '112313', '132113', '132311', '211313', {CDEFG}
   '231113', '231311', '112133', '112331', '132131', {HILKL}
   '113123', '113321', '133121', '313121', '211331', {MNOPQ}
   '231131', '213113', '213311', '213131', '311123', {RSTUV}
   '311321', '331121', '312113', '312311', '332111', {WXYZ[}
   '314111', '221411', '431111', '111224', '111422', {\]^_`}
   '121124', '121421', '141122', '141221', '112214', {abcde}
   '112412', '122114', '122411', '142112', '142211', {fghij}
   '241211', '221114', '413111', '241112', '134111', {klmno}
   '111242', '121142', '121241', '114212', '124112', {pqrst}
   '124211', '411212', '421112', '421211', '212141', {uvwxy}
   '214121', '412121', '111143', '111341', '131141', (*{z{|}~*)
   '114113', '114311', '411113', '411311', '113141', {Del, Fnc3,Fnc2,Shift,CodeC}
   '114131', '311141', '411131', '211412', '211214', {CodeB,Fnc4,Fnc1,StartA,StartB}
   '211232', '233111'  {StartC, Stop} {Korrektes Stopzeichen ist: 2331112}
   );


Procedure TBarCode128.initCode128;
var
  i,j,k:Integer;
  count:Integer;
  code1:string[6];
begin
  for j:=0 to 106 do
  begin
    case j of
      0:code1:='212222';
      1:code1:='222122';
      2:code1:='222221';
      3:code1:='121223';
      4:code1:='121322';
      5:code1:='131222';
      6:code1:='122213';
      7:code1:='122312';
      8:code1:='132212';
      9:code1:='221213';
      10:code1:='221312';
      11:code1:='231212';
      12:code1:='112232';
      13:code1:='122132';
      14:code1:='122231';
      15:code1:='113222';
      16:code1:='123122';
      17:code1:='123221';
      18:code1:='223211';
      19:code1:='221132';
      20:code1:='221231';
      21:code1:='213212';
      22:code1:='223112';
      23:code1:='312131';
      24:code1:='311222';
      25:code1:='321122';
      26:code1:='321221';
      27:code1:='312212';
      28:code1:='322112';
      29:code1:='322211';
      30:code1:='212123';
      31:code1:='212321';
      32:code1:='232121';
      33:code1:='111323';
      34:code1:='131123';
      35:code1:='131321';
      36:code1:='112313';
      37:code1:='132113';
      38:code1:='132311';
      39:code1:='211313';
      40:code1:='231113';
      41:code1:='231311';
      42:code1:='112133';
      43:code1:='112331';
      44:code1:='132131';
      45:code1:='113123';
      46:code1:='113321';
      47:code1:='133121';
      48:code1:='313121';
      49:code1:='211331';
      50:code1:='231131';
      51:code1:='213113';
      52:code1:='213311';
      53:code1:='213131';
      54:code1:='311123';
      55:code1:='311321';
      56:code1:='331121';
      57:code1:='312113';
      58:code1:='312311';
      59:code1:='332111';
      60:code1:='314111';
      61:code1:='221411';
      62:code1:='431111';
      63:code1:='111224';
      64:code1:='111422';
      65:code1:='121124';
      66:code1:='121421';
      67:code1:='141122';
      68:code1:='141221';
      69:code1:='112214';
      70:code1:='112412';
      71:code1:='122114';
      72:code1:='122411';
      73:code1:='142112';
      74:code1:='142211';
      75:code1:='241211';
      76:code1:='221114';
      77:code1:='413111';
      78:code1:='241112';
      79:code1:='134111';
      80:code1:='111242';
      81:code1:='121142';
      82:code1:='121241';
      83:code1:='114212';
      84:code1:='124112';
      85:code1:='124211';
      86:code1:='411212';
      87:code1:='421112';
      88:code1:='421211';
      89:code1:='212141';
      90:code1:='214121';
      91:code1:='412121';
      92:code1:='111143';
      93:code1:='111341';
      94:code1:='131141';
      95:code1:='114113';
      96:code1:='114311';
      97:code1:='411113';
      98:code1:='411311';
      99:code1:='113141';
      101:code1:='114131';
      102:code1:='311141';
      103:code1:='411131';
      104:code1:='211412';
      105:code1:='211214';
      106:code1:='211232';
      107:code1:='233111';  {Korrektes Stopzeichen ist: 2331112}
    end;{case}
    Code2[j]:='';
    for i:=1 to 6 do
    begin
      count:=ord(code128_Code1[j][i])-ord('0');
      for k:=1 to count do
      begin
        if i mod 2=1 then
          Code2[j]:=Code2[j]+'1'
        else
          Code2[j]:=Code2[j]+'0';
      end;
    end;
  end;
end;

Constructor TBarCode128.create;
begin
  inherited create;
  Chars:=             ' !"#$%&'+#39+'()'+
                            '*+,-./0123'+
                            '456789:;<='+
                            '>?@ABCDEFG'+
                            'HIJKLMNOPQ'+
                            'RSTUVWXYZ['+
                            '\]^_`abcde'+
                            'fghijklmno'+
                            'pqrstuvwxy'+
                            'z{|}~'#127+#128#129#130#131#132#133#134#135#136#137#138;
  InitCode128;
end;

Procedure TBarCodabar.InitCodabar;
begin
  Code[ 0]:='0000011';
  Code[ 1]:='0000110';
  Code[ 2]:='0001001';
  Code[ 3]:='1100000';
  Code[ 4]:='0010010';
  Code[ 5]:='1000010';
  Code[ 6]:='0100001';
  Code[ 7]:='0100100';
  Code[ 8]:='0110000';
  Code[ 9]:='1001000';
  Code[10]:='0001100';
  Code[11]:='0011000';
  Code[12]:='1000101';
  Code[13]:='1010001';
  Code[14]:='1010100';
  Code[15]:='0010101';
  Code[16]:='0011010';
  Code[17]:='0101001';
  Code[18]:='0001011';
  Code[19]:='0001110';
end;

Constructor TBarCodabar.Create;
begin
  inherited create;
  Chars:=('0123456789-$:/.+ABCD');
  InitCodabar;
end;

Procedure TBarPostnet.InitPostnet;
begin
  Code[ 0]:='11000';
  Code[ 1]:='00011';
  Code[ 2]:='00101';
  Code[ 3]:='00110';
  Code[ 4]:='01001';
  Code[ 5]:='01010';
  Code[ 6]:='01100';
  Code[ 7]:='10001';
  Code[ 8]:='10010';
  Code[ 9]:='10100';
  Code_FIM_A:='110010011';
  Code_FIM_B:='101101101';
  Code_FIM_C:='110101011';
end;

Constructor TBarPostnet.Create;
begin
  inherited create;
  Chars:=('0123456789');
  InitPostnet;
end;


initialization
  BarCode39 :=TBarCode39.create;
  BarCode128:=TBarCode128.create;
  BarCodabar:=TBarCodabar.create;
  BarPostnet:=TBarPostnet.create;
end.

