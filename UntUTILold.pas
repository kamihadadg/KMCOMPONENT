unit UntUTIL;

interface
  uses  mmsystem,windows,variants,SysUtils ,
        controls,Classes,Messages,Dialogs,activex
        ,Soap.SOAPHTTPClient,smsService,SOAPHTTPTrans,Soap.OpConvertOptions,
        Vcl.Graphics;
    type
     TKMUtil = class(TComponent)


  protected
  {protected declarations }
  private
  { Private declarations }
    function Unspace(Data: string):string;

  public
    { Public declarations }

    function Kinddigitwindows():Integer ;
    function Setdigitwindows(p:PWideChar):Boolean ;

    function setstring(str1:string;lenstr:integer;AChr:AnsiChar='0'):string ;



    function TurnScreenSaverOn : bool;

    function HexToBin(Data: string): string;
    function DecToBin(Value:Integer; Base: Integer=2): string;
    function BinToHex(Data: string): string;

    Function FindOsVer:String;

    Function NoTextFarsi( X :variant ):String;
    Function NoTextEnglish( X :variant  ):String;

    function Base64Encode(const Source: AnsiString): AnsiString;
    function Base64Decode(const Source: AnsiString): AnsiString;



    function BaseEncode(const Source: Integer;AKind:Integer): Integer;
    function BaseDecode(const Source: Integer;AKind:Integer): Integer;


    function BaseStrEncode(const Source: string;AKind:Integer): string;
    function BaseStrDecode(const Source: string;AKind:Integer): string;

    procedure  OpenCloseCDROM(Open:Boolean);

    procedure SetWinControlBiDi(Control: TWinControl);
    function GetComputerNetName: string;
    Function GetUserFromWindows: string;
    function GetTempDir:string ;

    procedure MyBeep(AFreq, ADelay: Integer );

    function HardwareID():string;

    function IsInstalledActiveX(AProgID:WideString='ShockwaveFlash.ShockwaveFlash'): Boolean;
    Function String_Reverse(S : String): String;
    function CodeMeli(Code : String):Boolean;
    function BytesToString(bytearray: array of byte; len : Integer): String;

    function SendSMSwebservice(var ASoap:THTTPRIO;AUser,APass,ANumber,AComment,ACustNumber:string):string;
    function SendSMSCustomer(var ASoap:THTTPRIO;AComment,ACustNumber:string;AKind:Integer):string;
    function ReciveSMSwebservice(var ASoap:THTTPRIO;AUser,APass,ANumber:string;
        var fPKey,FMobile,FComment:TStringList):string;

    function ScreenCapture():TBitmap;

    function CharmKardan(inputcom:string):String ;
    function CharmOmid(inputcom:string):String ;
    published
    { Published declarations }
    Constructor Create (AOwner: TComponent) ;Override ;
  end;

procedure Register;

//procedure SetLicenseKey(Regcode: PAnsiChar); stdcall; external '.\HardwareID.DLL';
//procedure SetAppName(AppName: PAnsiChar); stdcall; external '.\HardwareID.DLL';
//function GetHardwareId(HDD, NIC, CPU, BIOS: LongBool; lpHWID: PAnsiChar; nMaxCount: Integer): Integer; stdcall; external '.\HardwareID.DLL';
//function GetDllVer(lpVersion: PAnsiChar; nMaxCount: Integer): Integer; stdcall; external '.\HardwareID.DLL';
//function IsInsideVMWare: Integer; stdcall; external '.\HardwareID.DLL';
//function IsInsideVirtualPC: Integer; stdcall; external '.\HardwareID.DLL';


implementation
const
  WS_EX_NOINHERITLAYOUT = $00100000; // Disable inheritence of mirroring by children
  WS_EX_LAYOUTRTL = $00400000; // Right to left mirroring

  Base64_Table : shortstring = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
Constructor TKMUtil.Create (AOwner: TComponent) ;
Begin
  inherited Create (AOwner) ;
End ;


function TKMUtil.CharmOmid(inputcom:string):String ;
var
  SBin1,SBin2,SHex1,SHex2:String ;
  i:Integer ;
begin
 for i:=2 to 3 do
  begin
    SHex1:=SHex1+IntToHex(ord(inputcom[i]),2);
  end ;

  SBin1:=HexToBin(SHex1[3]+SHex1[4]) ;
  SBin2:=(SBin1[1]+SBin1[3]+SBin1[4]+SBin1[5]);
  SHex2:=BinToHex(SBin2) ;
  if SHex1[1]='0' then
    Result:=SHex2+SHex1[2]+'.'+'00';
  if SHex1[1]='1' then
    Result:=SHex2+SHex1[2]+'.'+'25';
  if SHex1[1]='2' then
    Result:=SHex2+SHex1[2]+'.'+'50';
  if SHex1[1]='3' then
    Result:=SHex2+SHex1[2]+'.'+'75';
  if Result='' then
    Result:='0'
  else
    Result:=formatfloat('0.00',(strtofloat(Result)));

end ;
function TKMUtil.CharmKardan(inputcom:string):String ;
var
  vint:Integer ;
  vt,vfloat,vres:Real ;
begin

    vres:=0 ;
    try
      vt:=StrToFloat(FormatFloat('00.000',((StrToFloat(trim(inputcom)))-8)/184.49));
      vint:=Trunc(vt) ;
      vfloat:=vt-vint ;
       if (vfloat<0.125)then
      begin
        vres:=0 ;
      end;
      if (vfloat>=0.125)and (vfloat<=0.374) then
      begin
        vres:=0.25 ;
      end;
      if (vfloat>=0.375)and (vfloat<=0.624) then
      begin
        vres:=0.50 ;
      end;
      if (vfloat>=0.625)and (vfloat<=0.874) then
      begin
        vres:=0.75 ;
      end;
      if (vfloat>=0.875)then
      begin
        vres:=1 ;
      end;

    except
      vres:=-1 ;
    end;

    Result:=FormatFloat('00.000',(vint+vres));
end ;

function TKMUtil.ScreenCapture():TBitmap;
var
 b:TBitmap;
procedure ScreenShot(DestBitmap : TBitmap) ;
 var
   DC : HDC;
 begin
   DC := GetDC (GetDesktopWindow) ;
   try
    DestBitmap.Width := GetDeviceCaps (DC, HORZRES) ;
    DestBitmap.Height := GetDeviceCaps (DC, VERTRES) ;
    BitBlt(DestBitmap.Canvas.Handle, 0, 0, DestBitmap.Width, DestBitmap.Height, DC, 0, 0, SRCCOPY) ;
   finally
    ReleaseDC (GetDesktopWindow, DC) ;
   end;
 end;
begin

 begin
 Result := TBitmap.Create;
 try
  ScreenShot(Result) ;
 finally
// Result.FreeImage;
// FreeAndNil(Result) ;
 end;

end;
end ;



function TKMUtil.BytesToString(bytearray: array of byte; len : Integer): String;
var
  a: Integer;
begin
  result := '';
  for a := 0 to len-1 do begin
    result := result + char(bytearray[a]);
  end;
end;
function TKMUtil.CodeMeli(Code : String):Boolean;
var Sum,i : Integer;
    flag : Boolean;
begin
  flag := (Code = '0000000000') or (code = '1111111111') or (code = '2222222222') or (code = '3333333333');
  flag := (Code = '4444444444') or (code = '5555555555') or (code = '6666666666') or (code = '7777777777') or flag;
  flag := (Code = '8888888888') or (code = '9999999999') or flag;
  if not flag then
  begin
   if Code = '' then
     CodeMeli := False
   else
   if Length(Code) <> 10 then
     CodeMeli := False
   else
   begin
     Sum := 0;
     for i:= 1 to 9 do
       Sum := Sum + (StrToInt(Code[i])*(11-i));
     Sum := Sum mod 11;
     if Sum < 2 then
       CodeMeli := (StrToInt(Code[10]) = Sum)
     else
     if Sum >= 2 then
       CodeMeli := (StrToInt(Code[10]) = (11 - Sum));
   end;
  end
  else CodeMeli := False;
end;
Function TKMUtil.String_Reverse(S : String): String;
Var
   i : Integer;
Begin
   Result := '';
   For i := Length(S) DownTo 1 Do
   Begin
     Result := Result + Copy(S,i,1) ;
   End;
End;
function TKMUtil.GetComputerNetName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;

function TKMUtil.GetTempDir: string;
var
   lng: DWORD;
   thePath: string;
begin
  SetLength(thePath, MAX_PATH) ;
  lng := GetTempPath(MAX_PATH, PChar(thePath)) ;
  SetLength(thePath, lng) ;
  Result:=thePath ;
end;

Function TKMUtil.GetUserFromWindows: string;
Var
   UserName : string;
   UserNameLen : Dword;
Begin
   UserNameLen := 255;
   SetLength(userName, UserNameLen) ;
   If GetUserName(PChar(UserName), UserNameLen) Then
     Result := Copy(UserName,1,UserNameLen - 1)
   Else
     Result := 'Unknown';
End;
procedure TKMUtil.SetWinControlBiDi(Control: TWinControl);
var
 ExStyle: Longint;
begin
 ExStyle := GetWindowLong(Control.Handle, GWL_EXSTYLE);
 SetWindowLong(Control.Handle, GWL_EXSTYLE, ExStyle or WS_EX_RTLREADING or WS_EX_RIGHT
   or WS_EX_LAYOUTRTL or WS_EX_NOINHERITLAYOUT );
   Control.Refresh ;
end;
procedure TKMUtil.OpenCloseCDROM(Open:Boolean);
begin
  if Open then
    {To OPEN the CD-ROM: }
    mciSendString('Set cdaudio door open wait', nil, 0, 1)
  else
    { To CLOSE the CD-ROM: }
    mciSendString('Set cdaudio door closed wait', nil, 0, 1) ;
end ;


function TKMUtil.Kinddigitwindows():Integer ;
var
  Res: Integer;
  W: PWideChar;
begin
  Res := GetLocaleInfoW(0, 4116, nil, 0);
  if Res > 0 then
  begin
    GetMem(W, Res * SizeOf(WideChar));
    Res := GetLocaleInfoW(0, 4116, W, Res);
    Result :=strtoint(W);
    FreeMem(W);
  end;
end ;

function TKMUtil.Setdigitwindows(p:PWideChar):Boolean ;
begin
  SetLocaleInfow(0,4116,p);
  if Kinddigitwindows=strtoint(p) then
    Result:=true
  else
    Result:=False ;
end ;
Function TKMUtil.FindOsVer:String;
Type
	TGetVer=Record
   	WinVer,
      WinRev,
      DosVer,
      DosRev:Byte;
   End;
Var
	AllVersions:TGetVer;
Begin
	AllVersions:=TGetVer(GetVersion());
   If AllVersions.WinVer=5 Then
   Begin
   	If AllVersions.WinRev=0 Then
      	Result:='Win2k'
      Else
      If AllVersions.WinRev=1 Then
      	Result:='WinXP';
   End
   Else
   If AllVersions.WinVer<5 Then
   	Result:='Win98';
End;


////////////////Fill Back Of any String With 0 /////////
function TKMUtil.setstring(str1:string;lenstr:integer;AChr:AnsiChar='0'):string ;
var
   i,j:integer ;
begin
   i:=lenstr-length(str1) ;
   for j:=1 to i do
      str1:=AChr+str1 ;
   Result:=str1 ;
end ;
////////////////////////////////screen  saver /////////////////////////////
function TKMUtil.TurnScreenSaverOn : bool;
 var
   b : bool;
 begin
   result := false;
   if SystemParametersInfo(SPI_GETSCREENSAVEACTIVE,0,@b,0)<>true then
     exit;
   if not b then exit;
   PostMessage(GetDesktopWindow, WM_SYSCOMMAND, SC_SCREENSAVE, 0);
   result := true;
 end;

////////////////////////////////////////Hex to bin//////////////////
function TKMUtil.HardwareID: string;
var
  sHWID: array[0..254] of AnsiChar;
  iRtn,i: Integer;
  SID:string ;
begin
//  SetAppName('');
//  SetLicenseKey('U34YQE9PQDW847TA5D1DVC3H4');
//  iRtn:= GetHardwareId(True,True, True, True, sHWID, SizeOf(sHWID));
  SID:=sHWID ;
  SID:=StringReplace(SID,'-','',[rfReplaceAll]) ;
  Result:=SID
end;

function TKMUtil.HexToBin(Data: string): string;
var
a,z,Tmp:string;
I:integer;
begin
Tmp:='';
Data:=UnSpace(Data);

for i:=1 to length(data) do
begin
A:=Copy(Data,i,1);
if a='0' then   z:='0000';
if a='1' then   z:='0001';
if a='2' then   z:='0010';
if a='3' then   z:='0011';
if a='4' then   z:='0100';
if a='5' then   z:='0101';
if a='6' then   z:='0110';
if a='7' then   z:='0111';
if a='8' then   z:='1000';
if a='9' then   z:='1001';
if a='A' then   z:='1010';
if a='B' then   z:='1011';
if a='C' then   z:='1100';
if a='D' then   z:='1101';
if a='E' then   z:='1110';
if a='F' then   z:='1111';
Tmp:=Tmp + z;
end;

Tmp:=Trim(Tmp);
Result:=Tmp;
end;
function TKMUtil.IsInstalledActiveX(AProgID: WideString='ShockwaveFlash.ShockwaveFlash'): Boolean;
var
ClassID : TCLSID;
begin
  Result := False;
  if CLSIDFromProgID(PWideChar(AProgID), ClassID) = S_OK then
    Result := True;
end;
function TKMUtil.DecToBin(Value:Integer; Base: Integer=2): string;
begin
Result:=HexToBin(IntToHex(Value,Base));
end;
function TKMUtil.Unspace(Data: string):string;
begin
Data:=StringReplace(Data,' ','',[rfReplaceAll]);// on Efface tout les Espaces inutiles
Data:=StringReplace(Data,'-','',[rfReplaceAll]);// on Efface tout les '-' inutiles
Data:=StringReplace(Data,',','',[rfReplaceAll]);// on Efface tout les ',' inutiles
result:=Data;
end;
Function TKMUtil.NoTextFarsi( X :variant ):String;
  {--------------------------------------------------}
  {  Directed by Miss Negin Noormahnad   1381/05/06  }
  {--------------------------------------------------}
  Const Vav = ' Ê ' ;
  Var P ,S ,T: String ;  D : int64 ; M : int64 ;
      T1,T2 : String ;
  //====================================================
  Function Ret9993( X : Integer): String ;
    Const Vav = ' Ê ' ;
          Sadgan : Array [1..9] Of ansiString =
           ('Ìﬂ’œ','œÊÌ” ','”Ì ’œ','çÂ«—’œ','Å«‰’œ','‘‘’œ','Â› ’œ','Â‘ ’œ','‰Â’œ') ;
          
          Dahgan : Array [2..9] Of ansiString =
                            ('»Ì” ','”Ì','çÂ·','Å‰Ã«Â','‘’ ','Â› «œ','Â‘ «œ','‰Êœ');
          Ta19 : Array [1..19]Of ansiString =
                  ('Ìﬂ','œÊ','”Â','çÂ«—','Å‰Ã','‘‘','Â› ','Â‘ ','‰Â','œÂ','Ì«“œÂ',
                 'œÊ«“œÂ','”Ì“œÂ','çÂ«—œÂ','Å«‰“œÂ','‘«‰“œÂ','Â›œÂ','ÂÃœÂ','‰Ê“œÂ');
    Var  D : integer ;
  Begin
    Result := '' ;
    D := X Div 100 ;
    X := X Mod 100 ;
    If D <>0   Then Begin
      Result := Result + Sadgan[(D)] ;
      If X = 0 Then Exit ;
      Result := Result + Vav ;
    End;
    If X >19 Then Begin
      D := X Div 10 ;
      X := X Mod 10 ;
      Result := Result + Dahgan[(D)];
      If X = 0 Then Exit ;
      Result := Result + Vav ;
    End;
    Result := Result + Ta19[(X)] ;
  End;
  //====================================================
  Function GetMText3( M : int64):String;
  Begin
    If M = 1000000000 Then Result := '„Ì·Ì«—œ'
    Else If M = 1000000 Then Result := '„Ì·ÌÊ‰'
    Else If M = 1000 Then Result := 'Â“«—'
    Else ShowMessage('⁄œœ «‘ »«Â «” ') ;
  End;
  //====================================================
Begin
      If VarType(X) In [ VarSingle,VarDouble,VarCurrency ]
        Then Begin X := Round(X); X := FloatToStrF(X,ffGeneral,18,0); End;
      If( VarType(X) = VarString )
        Then If Length(X) > 12 Then Begin
          Result := NoTextFarsi( Copy(X,1,Length(X)-9))+' „Ì·Ì«—œ' + Vav + NoTextFarsi(Copy(X,(Length(X)-9+1),9));
          Exit ;
        End Else X := StrToInt64( X ) ;
      M := 1000000000000 ;Result := '' ;P := '' ;
      If X = 0 Then Begin Result := '’›—' ; Exit ; End ;
      Repeat
             M := M Div 1000;
             If X >= M Then Begin
               D := X Div M ;
               X := X Mod M ;
               P := GetMText3( M ) ;
               If D > 999
                 Then Result := Result + NoTextFarsi(D) + ' '+ P
                 Else Result := Result + Ret9993(D) + ' '+ P ;
               If X = 0 Then Exit ;
               Result := Result + Vav ;
             End;
      Until X <= 999 ;
      Result := Result + Ret9993((X)) ;
End;
Function TKMUtil.NoTextEnglish( X :variant  ):String;
  Const Vav = ' ' ;
  Var P : String ;D : Integer ;M :int64 ;
  //====================================================
  Function Ret9994( X : Integer): String ;
    Const Sadgan : Array [1..9] Of String =
           ('One Hundred','Tow Hundred','Three Hundred','Four Hundred','Five Hundred',
                      'Six Hundred','Seven Hundred','Eight Hundred','Nine Hundred') ;
          Dahgan : Array [2..9] Of String =
                            ('Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety');
          Ta19 : Array [1..19]Of String =
                  ('One','Tow','Three','Four','Five','Six','Seven','Eight','Nine','Ten','Eleven',
                 'Twelve','Thirteen','Fourteen','Fiveteen','Sixteen','Seventeen','Eightteen','Nineteen');
    Var  D : integer ;
  Begin
    Result := '' ;
    D := X Div 100 ;
    X := X Mod 100 ;
    If D <>0   Then Begin
      Result := Result + Sadgan[D] ;
      If X = 0 Then Exit ;
      Result := Result + Vav ;
    End;
    If X >19 Then Begin
      D := X Div 10 ;
      X := X Mod 10 ;
      Result := Result + Dahgan[D];
      If X = 0 Then Exit ;
      Result := Result + Vav ;
    End;
    Result := Result + Ta19[X] ;
  End;
  //====================================================
  Function GetMText2( M : int64):String;
  Begin
    If M = 1000000000 Then Result := 'Billion'
    Else If M = 1000000 Then Result := 'Million'
    Else If M = 1000 Then Result := 'Thousands'
    Else ShowMessage('Error') ;
  End;
  //====================================================
Begin
  If VarType(X) In [ VarSingle,VarDouble,VarCurrency ]
    Then Begin X := Round(X); X := FloatToStrF(X,ffGeneral,18,0); End;
  If( VarType(X) = VarString )
     Then If Length(X) > 12 Then Begin
       Result := NoTextEnglish( Copy(X,1,Length(X)-9)) + ' Billion' + 'And' +
                 NoTextEnglish(Copy(X,(Length(X)-9+1),9));
       Exit ;
     End Else X := StrToInt64( X ) ;
  M := 1000000000000 ;
  Result := '' ;
  P := '' ;
  If X = 0 Then Begin Result := 'Zero' ;Exit ;End ;
  Repeat
    M := M Div 1000;
    If X >= M Then Begin
      D := X Div M ;
      X := X Mod M ;
      P := GetMText2( M ) ;
      If D > 999
        Then Result := Result + NoTextEnglish(D) + ' '+ P
        Else Result := Result + Ret9994(D) + ' '+ P ;
      If X = 0 Then Exit ;
      Result := Result + Vav ;
    End;
  Until X <= 999 ;
  Result := Result + Ret9994(X) ;
End;






function TKMUtil.Base64Encode(const Source: AnsiString): AnsiString;
var
  NewLength: Integer;
begin
  NewLength := ((2 + Length(Source)) div 3) * 4;
  SetLength( Result, NewLength);

  asm
    Push  ESI
    Push  EDI
    Push  EBX
    Lea   EBX, Base64_Table
    Inc   EBX                // Move past String Size (ShortString)
    Mov   EDI, Result
    Mov   EDI, [EDI]
    Mov   ESI, Source
    Mov   EDX, [ESI-4]        //Length of Input String
@WriteFirst2:
    CMP EDX, 0
    JLE @Done
    MOV AL, [ESI]
    SHR AL, 2
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    MOV AL, [ESI + 1]
    MOV AH, [ESI]
    SHR AX, 4
    AND AL, 63
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    CMP EDX, 1
    JNE @Write3
    MOV AL, 61                        // Add ==
    MOV [EDI], AL
    INC EDI
    MOV [EDI], AL
    INC EDI
    JMP @Done
@Write3:
    MOV AL, [ESI + 2]
    MOV AH, [ESI + 1]
    SHR AX, 6
    AND AL, 63
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    CMP EDX, 2
    JNE @Write4
    MOV AL, 61                        // Add =
    MOV [EDI], AL
    INC EDI
    JMP @Done
@Write4:
    MOV AL, [ESI + 2]
    AND AL, 63
{$IFDEF VER140} // Changes to BASM in D6
    XLATB
{$ELSE}
    XLAT
{$ENDIF}
    MOV [EDI], AL
    INC EDI
    ADD ESI, 3
    SUB EDX, 3
    JMP @WriteFirst2
@done:
    Pop EBX
    Pop EDI
    Pop ESI
  end;
end;




//Decode Base64
function TKMUtil.Base64Decode(const Source: AnsiString): AnsiString;
var
  NewLength: Integer;
begin
{
  NB: On invalid input this routine will simply skip the bad data, a better solution would probably report the error


  ESI -> Source String
  EDI -> Result String

  ECX -> length of Source (number of DWords)
  EAX -> 32 Bits from Source
  EDX -> 24 Bits Decoded

  BL -> Current number of bytes decoded
}

  SetLength( Result, (Length(Source) div 4) * 3);
  NewLength := 0;
  asm
    Push  ESI         //save the good stuff
    Push  EDI
    Push  EBX

    Mov   ESI, Source

    Mov   EDI, Result //Result address
    Mov   EDI, [EDI]

    Or    ESI,ESI   // Test for nil
    Jz    @Done

    Mov   ECX, [ESI-4]
    Shr   ECX,2       // DWord Count

    JeCxZ @Error      // Empty String

    Cld

    jmp   @Read4

  @Next:
    Dec   ECX
    Jz   @Done

  @Read4:
    lodsd

    Xor   BL, BL
    Xor   EDX, EDX

    Call  @DecodeTo6Bits
    Shl   EDX, 6
    Shr   EAX,8
    Call  @DecodeTo6Bits
    Shl   EDX, 6
    Shr   EAX,8
    Call  @DecodeTo6Bits
    Shl   EDX, 6
    Shr   EAX,8
    Call  @DecodeTo6Bits


  // Write Word

    Or    BL, BL
    JZ    @Next  // No Data

    Dec   BL
    Or    BL, BL
    JZ    @Next  // Minimum of 2 decode values to translate to 1 byte

    Mov   EAX, EDX

    Cmp   BL, 2
    JL    @WriteByte

    Rol   EAX, 8

    BSWAP EAX

    StoSW

    Add NewLength, 2

  @WriteByte:
    Cmp BL, 2
    JE  @Next
    SHR EAX, 16
    StoSB

    Inc NewLength
    jmp   @Next

  @Error:
    jmp @Done

  @DecodeTo6Bits:

  @TestLower:
    Cmp AL, 'a'
    Jl @TestCaps
    Cmp AL, 'z'
    Jg @Skip
    Sub AL, 71
    Jmp @Finish

  @TestCaps:
    Cmp AL, 'A'
    Jl  @TestEqual
    Cmp AL, 'Z'
    Jg  @Skip
    Sub AL, 65
    Jmp @Finish

  @TestEqual:
    Cmp AL, '='
    Jne @TestNum
    // Skip byte
    ret

  @TestNum:
    Cmp AL, '9'
    Jg @Skip
    Cmp AL, '0'
    JL  @TestSlash
    Add AL, 4
    Jmp @Finish

  @TestSlash:
    Cmp AL, '\'
    Jne @TestPlus
    Jmp @Finish

  @TestPlus:
    Cmp AL, '+'
    Jne @Skip
    Mov AL, 63

  @Finish:
    Or  DL, AL
    Inc BL

  @Skip:
    Ret

  @Done:
    Pop   EBX
    Pop   EDI
    Pop   ESI

  end;

  SetLength( Result, NewLength); // Trim off the excess
end;
procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMUtil]);
end;

 ////////////////////////////////////////bin to hex //////////////////
function TKMUtil.BinToHex(Data: string): string;
var

  datal,Tmp:String ;
  i:Integer ;
function resultonebyone(T:String):string ;
begin
  if T='0000' then   Result:='0';
  if T='0001' then   Result:='1';
  if T='0010' then   Result:='2';
  if T='0011' then   Result:='3';
  if T='0100' then   Result:='4';
  if T='0101' then   Result:='5';
  if T='0110' then   Result:='6';
  if T='0111' then   Result:='7';
  if T='1000' then   Result:='8';
  if T='1001' then   Result:='9';
  if T='1010' then   Result:='A';
  if T='1011' then   Result:='B';
  if T='1100' then   Result:='C';
  if T='1101' then   Result:='D';
  if T='1110' then   Result:='E';
  if T='1111' then   Result:='F';
end ;
begin
  if (Length(Data)mod 4)<>0 then
    datal:=setstring(Data,((Length(Data)div 4)+1 )*4 )
  else
    datal:=Data ;
  for i:=1 to length(datal)div 4 do
  begin
    tmp:=datal[1]+datal[2]+datal[3]+datal[4];
    datal:=copy(datal,5,length(datal)) ;
    Result:=Result+resultonebyone(Tmp);
 end ;
/////////////////////////////////////////////////////////////////////

end;


function TKMUtil.BaseDecode(const Source: Integer;AKind:Integer): Integer;
begin
  case AKind of
    1:Result:= (61362356 xor Source )+26136 ; //khodam
    2:Result:= (8221959 xor Source )+8221959 ;//Khojasteh DonSalivan
    3:Result:= (820058 xor Source )+820058 ;  //hedayat
    4:Result:= (911110 xor Source )+911110 ;// KhojastehAtlassag
    5:Result:= (5899625 xor Source )+5899625 ;// neishaboori
    6:Result:= (83918391 xor Source )+8391 ;//aran
    7:Result:= (23912391 xor Source )+2391 ;//kanoon
    8:Result:= (2356 xor Source )+23562356 ;
  end;
end;

function TKMUtil.BaseEncode(const Source: Integer;AKind:Integer): Integer;
begin

  case AKind of
    1:Result:= (61362356 xor (Source-26136)) ;
    2:Result:= (8221959 xor (Source-8221959)) ;
    3:Result:= (820058 xor (Source-820058)) ;
    4:Result:= (911110 xor (Source-911110)) ;
    5:Result:= (5899625 xor (Source-5899625)) ;
    6:Result:= (83918391 xor (Source-8391)) ;
    7:Result:= (23912391 xor (Source-2391)) ;
    8:Result:= (2356 xor Source )+23562356 ;
  end;
end;
function TKMUtil.BaseStrDecode(const Source: string; AKind: Integer): string;
begin
  case AKind of
    1:Result:= Source ;
  end;
end;

function TKMUtil.BaseStrEncode(const Source: string; AKind: Integer): string;
begin
  case AKind of
    1:Result:= Source ;
  end;
end;


procedure TKMUtil.MyBeep(AFreq, ADelay: Integer );
procedure SetPort(address, Value: Word) ;
var
   bValue: Byte;
begin
   bValue := trunc(Value and 255) ;
//   asm
//     mov dx, address
//     mov al, bValue
//     out dx, al
//   end;
end;

function GetPort(address: Word): Word;
var
   bValue: Byte;
begin
//   asm
//     mov dx, address
//     in al, dx
//     mov bValue, al
//   end;
   GetPort := bValue;
end;

procedure Sound(aFreq, aDelay: Integer) ;

   procedure DoSound(Freq: Word) ;
   var
     B: Byte;
   begin
     if Freq > 18 then
     begin
       Freq := Word(1193181 div Longint(Freq)) ;
       B := Byte(GetPort($61)) ;

       if (B and 3) = 0 then
       begin
         SetPort($61, Word(B or 3)) ;
         SetPort($43, $B6) ;
       end;

       SetPort($42, Freq) ;
       SetPort($42, Freq shr 8) ;
     end;
   end;

   procedure Delay(MSecs: Integer) ;
   var
     FirstTickCount: LongInt;
   begin
     FirstTickCount := GetTickCount;
     repeat
       Sleep(1) ;
       //or use Application.ProcessMessages instead of Sleep
     until ((GetTickCount - FirstTickCount) >= Longint(MSecs)) ;
   end;

begin
   if Win32Platform = VER_PLATFORM_WIN32_NT then
   begin
     Windows.Beep(aFreq, aDelay) ;
   end
   else
   begin
     DoSound(aFreq) ;
     Delay(aDelay) ;
   end;
end;

procedure NoSound;
var
   Value: Word;
begin
   if not (Win32Platform = VER_PLATFORM_WIN32_NT) then
   begin
     Value := GetPort($61) and $FC;
     SetPort($61, Value) ;
   end;
end;

begin
  Sound(AFreq,ADelay);
end;

{ReleaseCapture ;
Panel1.Perform(WM_SYSCOMMAND ,$f012,0);}

function TKMUtil.ReciveSMSwebservice(var ASoap:THTTPRIO;AUser,APass,ANumber:string;
  var fPKey,FMobile,FComment:TStringList): string;
var
  StrKol,FSt,str:string ;
  f2,f4,f5,fkol:TStringList ;
  i:Integer ;
  Const fieldSpreator='###field###' ;
  Const RecordSpreator='###record###' ;

  label L ;

begin

  try

//  case Akind of
//  1:  VS.WSDLLocation:='http://www.sms.kmsoftclub.ir:80/webservice/smsService.php?wsdl' ;
//  2:  VS.WSDLLocation:='http://www.amouzeshyar.com:80/webservice/smsService.php?wsdl' ;
//  end;
//    vs.Converter:=Vs.Converter1;
//    VS.HTTPWebNode:=Vs.HTTPWebNode1 ;
//  VS.HTTPWebNode.UseUTF8InHeader := True ;
//  VS.HTTPWebNode.InvokeOptions := [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI];
//  VS.HTTPWebNode.WebNodeOptions := [] ;
//  VS.Converter.Options := [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML] ;



//  VS.Port:= sms_webservicePort ;
//  VS.Service:=sms_webservice ;


 FSt := (ASoap as sms_webservicePort).sms_receive_list(Trim(AUser), Trim(APass), ANumber,
    '0','0','2000');

  f2:=TStringList.Create ;
  f4:=TStringList.Create ;
  f5:=TStringList.Create ;
  fkol:=TStringList.Create ;
  StrKol:= FSt   ;
  L:
  if Pos(RecordSpreator,StrKol)>0 then
  begin
    fkol.Add(Copy(StrKol,1,Pos(RecordSpreator,StrKol)-1));
    StrKol:=Copy(StrKol,pos(RecordSpreator,StrKol)+12,Length(StrKol)-1) ;
  end;

  if Pos(RecordSpreator,StrKol)>0 then
    goto L
  else
    fkol.Add(StrKol);

  //  Memo1.Lines.Text:=StringReplace(Memo1.Text,'###record###','',[rfReplaceAll]);

  for i:= 0 to fkol.Count-1 do
  begin
    Str:=fkol.Strings[i] ;
    fPKey.Add(Copy(Str,0,pos(fieldSpreator,str)-1));
    Str:=Copy(Str,pos(fieldSpreator,str)+11,Length(str)-1) ;
    f2.Add(Copy(Str,0,pos(fieldSpreator,str)-1));
    Str:=Copy(Str,pos(fieldSpreator,str)+11,Length(str)-1) ;
    FMobile.Add(Copy(Str,0,pos(fieldSpreator,str)-1));
    Str:=Copy(Str,pos(fieldSpreator,str)+11,Length(str)-1) ;
    f4.Add(Copy(Str,0,pos(fieldSpreator,str)-1));
    Str:=Copy(Str,pos(fieldSpreator,str)+11,Length(str)-1) ;
    f5.Add(Copy(Str,0,pos(fieldSpreator,str)-1));
    Str:=Copy(Str,pos(fieldSpreator,str)+11,Length(str)-1) ;
    FComment.Add(Str);
    Str:=Copy(Str,pos(fieldSpreator,str)+11,Length(str)-1) ;
  end;
  except
  end ;

end;


function TKMUtil.SendSMSCustomer(var ASoap: THTTPRIO; AComment,
  ACustNumber: string;AKind:Integer): string;
begin
  case AKind of
    1:
    begin
      try
        Result := (ASoap as sms_webservicePort).send_sms(Trim(''), Trim(''), '30003495',
                  ACustNumber, AComment,'','');

      except
      end;
    end;

    2:
    begin
      try
        Result := (ASoap as sms_webservicePort).send_sms(Trim(''), Trim(''), '3000349595',
                  ACustNumber, AComment,'','');

      except
      end;
    end;
  end;
end;

function TKMUtil.SendSMSwebservice(var ASoap:THTTPRIO;AUser,APass,ANumber,AComment,ACustNumber:string): string;
begin
  try
//    VS:=THTTPRIO.Create(nil);
//    vs.Converter:=Vs.Converter;
//    VS.HTTPWebNode:=VS.HTTPWebNode ;
//
////    VS.HTTPWebNode.UseUTF8InHeader := True ;
////    VS.HTTPWebNode.InvokeOptions := [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI];
////    VS.HTTPWebNode.WebNodeOptions := [] ;
////    VS.Converter.Options := [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML] ;
//
//    VS.Port:= 'sms_webservicePort' ;
//    VS.Service:='sms_webservice' ;
//    case Akind of
//    1:  VS.WSDLLocation:='http://www.sms.kmsoftclub.ir:80/webservice/smsService.php?wsdl' ;
//    2:  VS.WSDLLocation:='http://www.amouzeshyar.com:80/webservice/smsService.php?wsdl' ;
//    end;
    Result := (ASoap as sms_webservicePort).send_sms(Trim(AUser), Trim(APass), ANumber,
              ACustNumber, AComment,'','');

//    ASoap.Free ;
  except


  end;


//   St := (s as sms_webservicePort).sms_receive_change_read
// (Trim(Edit1.Text), Trim(Edit2.Text),Ads_RecivePanelKey_.AsInteger,1 );
// ShowMessage(st);



end;


end.


