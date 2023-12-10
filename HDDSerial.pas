unit HDDSerial;

interface

uses
  SysUtils, Classes, Windows,Forms ;

type
 {$R *.res}
  TStringArray = array of string;
  THDDSerial = class(TComponent)
  private
    { Private declarations }
     function  GetIdeSN(HddNum: Byte) : string;
  protected
    { Protected declarations }
  public
    { Public declarations }
     function  DriveIsReady(const Drive: string): Boolean;
     function  GetIdeSerialNumber(HddNum: Byte) : string;
     function  GetVolumeLabel(const Drive: string): string;
     procedure GetLogicalDrives(var Drives: TStringArray; ReadyOnly: Boolean = True; WithLabels: Boolean = True); overload;
     procedure GetLogicalDrives(var Drives: TStringList; ReadyOnly: Boolean = True; WithLabels: Boolean = True); overload;
     procedure GetLogicalDrivesVolume(var Drives: TStringList; ReadyOnly: Boolean = True; WithLabels: Boolean = True); overload;
  published
    { Published declarations }
  end;

  THddLock = Class
    public
      function  ConvertHexTostring(HexString: String): String;
      function  ConvertString(Buffer: array of Byte; Len: Integer): String;overload;
      function  ConvertString(Buffer: PByteArray; Len: Integer ): String;overload;
      function  ConvStr(S: string): string;
      function  ConvStrCode(S: string): string;
      function  DecodeSerial(S: string): string;
      function  DecodeCoding(S: string): string;
      function  GetInfoHDD( HddCode: String ): string;overload;
      function  GetInfoHDD( HddCode: String; var Serial,CR,SRCoded,CRCoded:String ): string;overload;
      function  SetSecurity( var Buf: array of Byte; FindValue, F_N,New_F_N,License,CR: String): Boolean;overload;
      function  Mypos(SubS, St: String): Integer;
      procedure WriteToBuffer(var Buf:array of Byte; PS : Integer; CR: String );overload;
      procedure WriteToBuffer( Buf:PByteArray; PS : Integer; CR: String );overload;
      function  TestValid( Buf: array of Byte; SCode: string): Boolean;

  end;


procedure Register;

implementation

uses StrUtils;

procedure Register;
begin
  RegisterComponents('Kamran Component', [THDDSerial]);
end;


function THDDSerial.GetIdeSerialNumber(HddNum: Byte): string;
begin
 Result:= Trim(GetIdeSN(HddNum));
end;

function  THDDSerial.GetIdeSN(HddNum: Byte) : string;
const IDENTIFY_BUFFER_SIZE = 512;
type
  TIDERegs = packed record
    bFeaturesReg     : BYTE; // Used for specifying SMART "commands".
    bSectorCountReg  : BYTE; // IDE sector count register
    bSectorNumberReg : BYTE; // IDE sector number register
    bCylLowReg       : BYTE; // IDE low order cylinder value
    bCylHighReg      : BYTE; // IDE high order cylinder value
    bDriveHeadReg    : BYTE; // IDE drive/head register
    bCommandReg      : BYTE; // Actual IDE command.
    bReserved        : BYTE; // reserved for future use.  Must be zero.
  end;

  TSendCmdInParams = packed record
    // Buffer size in bytes
    cBufferSize  : DWORD;
    // Structure with drive register values.
    irDriveRegs  : TIDERegs;
    // Physical drive number to send command to (0,1,2,3).
    bDriveNumber : BYTE;
    bReserved    : Array[0..2] of Byte;
    dwReserved   : Array[0..3] of DWORD;
    bBuffer      : Array[0..0] of Byte;  // Input buffer.
  end;
  TIdSector = packed record
    wGenConfig                 : Word;
    wNumCyls                   : Word;
    wReserved                  : Word;
    wNumHeads                  : Word;
    wBytesPerTrack             : Word;
    wBytesPerSector            : Word;
    wSectorsPerTrack           : Word;
    wVendorUnique              : Array[0..2] of Word;
    sSerialNumber              : Array[0..19] of CHAR;
    wBufferType                : Word;
    wBufferSize                : Word;
    wECCSize                   : Word;
    sFirmwareRev               : Array[0..7] of Char;
    sModelNumber               : Array[0..39] of Char;
    wMoreVendorUnique          : Word;
    wDoubleWordIO              : Word;
    wCapabilities              : Word;
    wReserved1                 : Word;
    wPIOTiming                 : Word;
    wDMATiming                 : Word;
    wBS                        : Word;
    wNumCurrentCyls            : Word;
    wNumCurrentHeads           : Word;
    wNumCurrentSectorsPerTrack : Word;
    ulCurrentSectorCapacity    : DWORD;
    wMultSectorStuff           : Word;
    ulTotalAddressableSectors  : DWORD;
    wSingleWordDMA             : Word;
    wMultiWordDMA              : Word;
    bReserved                  : Array[0..127] of BYTE;
  end;
  PIdSector = ^TIdSector;
  TDriverStatus = packed record
    // Error code from driver, or 0 if no error.
    bDriverError : Byte;
    // Contents of IDE Error register. Only valid when bDriverError is SMART_IDE_ERROR.
    bIDEStatus   : Byte;
    bReserved    : Array[0..1] of Byte;
    dwReserved   : Array[0..1] of DWORD;
  end;
  TSendCmdOutParams = packed record
    // Size of bBuffer in bytes
    cBufferSize  : DWORD;
    // Driver status structure.
    DriverStatus : TDriverStatus;
    // Buffer of arbitrary length in which to store the data read from the drive.
    bBuffer      : Array[0..0] of BYTE;
  end;

var hDevice : THandle;
    cbBytesReturned : DWORD;
    //ptr : PChar;
    SCIP : TSendCmdInParams;
    aIdOutCmd : Array [0..(SizeOf(TSendCmdOutParams)+IDENTIFY_BUFFER_SIZE-1)-1] of Byte;
    IdOutCmd  : TSendCmdOutParams absolute aIdOutCmd;

  procedure ChangeByteOrder( var Data; Size : Integer );
  var ptr : PChar;
      i : Integer;
      c : Char;
  begin
    ptr := @Data;
    for i := 0 to (Size shr 1)-1 do
    begin
      c := ptr^;
      ptr^ := (ptr+1)^;
      (ptr+1)^ := c;
      Inc(ptr,2);
    end;
  end;

begin
  Result := 'NOTFOUND'; // return empty string on error
  if SysUtils.Win32Platform=VER_PLATFORM_WIN32_NT then // Windows NT, Windows 2000
    begin
      // warning! change name for other drives:
      // ex.: second drive '\\.\PhysicalDrive1\'
      hDevice :=
       CreateFile( PChar('\\.\PhysicalDrive'+Trim(IntToStr( HddNum ) )),
        GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0 );
    end
  else // Version Windows 95 OSR2, Windows 98
    hDevice := CreateFile( '\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0 );
  if hDevice=INVALID_HANDLE_VALUE then Exit;
  try
    FillChar(SCIP,SizeOf(TSendCmdInParams)-1,#0);
    FillChar(aIdOutCmd,SizeOf(aIdOutCmd),#0);
    cbBytesReturned := 0;
    // Set up data structures for IDENTIFY command.
    with SCIP do
    begin
      cBufferSize  := IDENTIFY_BUFFER_SIZE;
//      bDriveNumber := 0;
      with irDriveRegs do
      begin
        bSectorCountReg  := 1;
        bSectorNumberReg := 1;
//      if Win32Platform=VER_PLATFORM_WIN32_NT then bDriveHeadReg := $A0
//      else bDriveHeadReg := $A0 or ((bDriveNum and 1) shl 4);
        bDriveHeadReg    := $A0;
        bCommandReg      := $EC;
      end;
    end;
    if not DeviceIoControl( hDevice, $0007c088, @SCIP, SizeOf(TSendCmdInParams)-1,
      @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil ) then Exit;
  finally
    CloseHandle(hDevice);
  end;
  with PIdSector(@IdOutCmd.bBuffer)^ do
  begin
    ChangeByteOrder( sSerialNumber, SizeOf(sSerialNumber) );
    (PChar(@sSerialNumber)+SizeOf(sSerialNumber))^ := #0;
    Result := PChar(@sSerialNumber);
  end;
end;

procedure THDDSerial.GetLogicalDrives(var Drives: TStringArray; ReadyOnly,
  WithLabels: Boolean);
var
  FoundDrives  : PChar;
  CurrentDrive : PChar;
  len          : DWord;
  cntDrives    : Integer;
begin
  cntDrives := 0;
  SetLength(Drives, 26);
  GetMem(FoundDrives, 255);
  len := GetLogicalDriveStrings(255, FoundDrives);
  if len > 0 then
  begin
    try
      CurrentDrive := FoundDrives;
      while CurrentDrive[0] <> #0 do
      begin
        if ReadyOnly then
        begin
          if DriveIsReady(string(CurrentDrive)) then
          begin
            if WithLabels then
              Drives[cntDrives] := CurrentDrive + ' [' +
                GetVolumeLabel(CurrentDrive) + ']'
            else
              Drives[cntDrives] := CurrentDrive;
            Inc(cntDrives);
          end;
        end
        else
        begin
          if WithLabels then
            Drives[cntDrives] := CurrentDrive + ' [' +
              GetVolumeLabel(CurrentDrive) + ']'
          else
            Drives[cntDrives] := CurrentDrive;
          Inc(cntDrives);
        end;
        CurrentDrive := PChar(@CurrentDrive[lstrlen(CurrentDrive) + 1]);
      end;
    finally
      FreeMem(FoundDrives, len);
    end;
    SetLength(Drives, cntDrives);
  end;
end;

procedure THDDSerial.GetLogicalDrives(var Drives: TStringList; ReadyOnly,
  WithLabels: Boolean);
var
  FoundDrives  : PChar;
  CurrentDrive : PChar;
  len          : DWord;
begin
  Drives.Clear;
  GetMem(FoundDrives, 255);
  len := GetLogicalDriveStrings(255, FoundDrives);
  if len > 0 then
  begin
    try
      CurrentDrive := FoundDrives;
      while CurrentDrive[0] <> #0 do
      begin
        if ReadyOnly then
        begin
          if DriveIsReady(string(CurrentDrive)) then
          begin
            if WithLabels then
              Drives.Add(CurrentDrive + ' [' + GetVolumeLabel(CurrentDrive) + ']')
            else
              Drives.Add( CurrentDrive );
          end;
        end
        else
        begin
          if WithLabels then
            Drives.Add(CurrentDrive + ' [' + GetVolumeLabel(CurrentDrive) + ']')
          else
            Drives.Add(CurrentDrive);
        end;
        CurrentDrive := PChar(@CurrentDrive[lstrlen(CurrentDrive) + 1]);
      end;
    finally
      FreeMem(FoundDrives, len);
    end;
  end;
end;

procedure THDDSerial.GetLogicalDrivesVolume(var Drives: TStringList;
  ReadyOnly, WithLabels: Boolean);
var
  FoundDrives  : PChar;
  CurrentDrive : PChar;
  len          : DWord;
  VL: String;
begin
  Drives.Clear;
  GetMem(FoundDrives, 255);
  len := GetLogicalDriveStrings(255, FoundDrives);
  if len > 0 then
  begin
    try
      CurrentDrive := FoundDrives;
      while CurrentDrive[0] <> #0 do
      begin
        if ReadyOnly then
        begin
          if DriveIsReady(string(CurrentDrive)) then
          begin
            VL := Trim(GetVolumeLabel(CurrentDrive));
            if WithLabels and (Vl <> '') then Drives.Add(CurrentDrive + ' [' + VL +']');
          end;
        end
        else
        begin
          VL := Trim(GetVolumeLabel(CurrentDrive));
          if WithLabels and (Vl <> '') then Drives.Add(CurrentDrive + ' [' + VL +']');
        end;
        CurrentDrive := PChar(@CurrentDrive[lstrlen(CurrentDrive) + 1]);
      end;
    finally
      FreeMem(FoundDrives, len);
    end;
  end;
end;

function THDDSerial.GetVolumeLabel(const Drive: string): string;
var
  RootDrive    : string;
  Buffer       : array[0..MAX_PATH + 1] of Char;
  FileSysFlags : DWORD;
  MaxCompLength: DWORD;
begin
  result := '';
  FillChar(Buffer, sizeof(Buffer), #0);
  if length(Drive) = 1 then
    RootDrive := Drive + ':\'
  else
    RootDrive := Drive;
  if GetVolumeInformation(PChar(RootDrive), Buffer, sizeof(Buffer), nil,
    MaxCompLength, FileSysFlags, nil, 0) then
  begin
    result := string(Buffer);
  end;
end;



function THDDSerial.DriveIsReady(const Drive: string): Boolean;
var
  wfd        : TWin32FindData;
  hFindData  : THandle;
begin
  SetErrorMode(SEM_FAILCRITICALERRORS);
  hFindData := FindFirstFile(Pointer(Drive + '*.*'), wfd);
  if hFindData <> INVALID_HANDLE_VALUE then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;
  Windows.FindClose(hFindData);
  SetErrorMode(0);
end;

//--------------------------------------------------
function THddLock.ConvertHexTostring(HexString: String): String;
var
 i,l: Integer;
 ch: String[2];
begin
 l:= length(HexString);
 if l mod 2 <> 0 then Dec(l);
 i:=1;
 while i<=l do
 begin
   Ch:=Copy(HexString,I,2);
   Result:=Result+ char(StrToInt('$'+ch)) ;
   inc(i,2);
 end;

end;

//--------------------------------------------------
function THddLock.ConvertString(Buffer: array of Byte; Len: Integer): String;
var
  L: Integer;
 Ch: String[2];
  B: Byte;
begin
  for L:=0 to Len-1 do
  begin
    Application.ProcessMessages;
    B:= Buffer[L];
    Ch :=IntToHex(B,2);
    Result:= Result + Ch;
  end;
end;

//--------------------------------------------------
function THddLock.ConvertString(Buffer: PByteArray; Len: Integer): String;
var
  L: Integer;
 Ch: String[2];
  B: Byte;
begin
  for L:=0 to Len-1 do
  begin
    Application.ProcessMessages;
    B:= Buffer^[L];
    Ch :=IntToHex(B,2);
    Result:= Result + Ch;
  end;
end;

//--------------------------------------------------
function THddLock.ConvStr(S: string): string;
var
 i,L: Integer;
begin
 L:= length(S);
 for i:=1 to L do
   Result:= Result+ char( Byte(S[i]) + L- i + 1 );

 Result:= ReverseString(Result);
 Randomize;
 Result:=Result+ Char(65+Random(26));
 Insert(Char(65+Random(26)),Result,5);
 Insert(Char(65+Random(26)),Result,5);
 Result:= Char(65+Random(26)) +Result;
end;


//--------------------------------------------------
function THddLock.ConvStrCode(S: string): string;
var
 i,l: Integer;
begin
 L:= length(S);
 for i:=1 to L do
   Result:= Result+ char(Byte(S[i])+L-i+1);
 Result:= ReverseString(Result);
end;


//--------------------------------------------------
function THddLock.DecodeSerial(S: string): string;
var
 i: Integer;
begin
  Delete(S,1,1);
  Delete(S,5,2);
  Delete(S,Length(S),1);
 for i:=1 to Length(S) do
   Result:= Result+ Char(Byte(S[i])-i);
 Result:=ReverseString(Result);
end;


//--------------------------------------------------
function THddLock.DecodeCoding(S: string): string;
var
 i: Integer;
begin
 for i:=1 to Length(S) do
   Result:= Result+ Char(Byte(S[i])-i);
 Result:=ReverseString(Result);
end;


//--------------------------------------------------
function  THddLock.GetInfoHDD( HddCode: String): string;
var
 x1,x2,
 y1,y2:String;
 X,Y: Int64;
 Serial,CR,SRCoded,CRCoded:String;
begin
  Serial := Trim(HddCode);
  SRCoded:= ConvStr(Serial);
  X1:= Inttostr(Byte(Serial[1]))+ Inttostr(Byte(Serial[3]))+  Inttostr(Byte(Serial[5]))+ Inttostr(Byte(Serial[7]));
  X2:= Inttostr(Byte(Serial[2]))+ Inttostr(Byte(Serial[4]))+ Inttostr(Byte(Serial[6]))+ Inttostr(Byte(Serial[8]));
  Y1:= Inttostr(Byte(Serial[8]))+ Inttostr(Byte(Serial[6]))+ Inttostr(Byte(Serial[4]))+ Inttostr(Byte(Serial[2]));
  Y2:= Inttostr(Byte(Serial[7]))+ Inttostr(Byte(Serial[5]))+ Inttostr(Byte(Serial[3]))+ Inttostr(Byte(Serial[1]));
  X:= StrToInt64(X1) + StrToInt64(X2) ;
  Y:= StrToInt64(Y1) + StrToInt64(Y2) ;
  CR:= IntToStr(X*Y);
  CRCoded:= ConvStrCode(CR);
  Result:= CR ;
end;

//--------------------------------------------------
function  THddLock.GetInfoHDD( HddCode: String; var Serial,CR,SRCoded,CRCoded:String  ): string;
var
 x1,x2,
 y1,y2:String;
 X,Y: Int64;
begin
  Serial := Trim(HddCode);
  SRCoded:= ConvStr(Serial);
  X1:= Inttostr(Byte(Serial[1]))+ Inttostr(Byte(Serial[3]))+  Inttostr(Byte(Serial[5]))+ Inttostr(Byte(Serial[7]));
  X2:= Inttostr(Byte(Serial[2]))+ Inttostr(Byte(Serial[4]))+ Inttostr(Byte(Serial[6]))+ Inttostr(Byte(Serial[8]));
  Y1:= Inttostr(Byte(Serial[8]))+ Inttostr(Byte(Serial[6]))+ Inttostr(Byte(Serial[4]))+ Inttostr(Byte(Serial[2]));
  Y2:= Inttostr(Byte(Serial[7]))+ Inttostr(Byte(Serial[5]))+ Inttostr(Byte(Serial[3]))+ Inttostr(Byte(Serial[1]));
  X:= StrToInt64(X1) + StrToInt64(X2) ;
  Y:= StrToInt64(Y1) + StrToInt64(Y2) ;
  CR:= IntToStr(X*Y);
  CRCoded:= ConvStrCode(CR);
  Result:= CR ;
end;

//--------------------------------------------------
function THddLock.SetSecurity( var Buf: array of Byte; FindValue, F_N,New_F_N,License , CR: String): Boolean;
var
  S: String;
  PS,NumRead, NumWritten: Integer;
  FS,FD: TFileStream;
  i,Cnt: Integer;
begin

   Result:= False;
   New_F_N := ExtractFilePath( F_N )+ 'tmp_' + ExtractFileName( F_N );
  try
    FS := TFileStream.Create( F_N, fmOpenRead );
    FD := TFileStream.Create( New_F_N, fmCreate );
    Cnt:= FS.Read(Buf, FS.Size);
    S := '';
    S := ConvertString(@Buf,Cnt);
    PS := Mypos(FindValue,S);
    if PS > 0 then
    begin
      WriteToBuffer(@Buf , PS div 2 , License + CR );
      FD.Write(Buf,FS.Size);
      Result:=True;
    end;

  finally
    FS.Free;
    FD.Free;
  end;
end;

//--------------------------------------------------
function THddLock.Mypos(SubS, St: String): Integer;
var
 i: Integer;
 Ch: String[2];
 Temp: String;
begin
 for i:= 1 to Length(SubS) do
 begin
  CH:= IntToHex(Byte(SubS[i]),2);
  Temp:= Temp + Ch;
 end;
 Result:= Pos(Temp,ST);
end;


//--------------------------------------------------
procedure THddLock.WriteToBuffer(var Buf: array of Byte; PS: Integer;
  CR: String);
var
 i,Len: Integer;
begin
  Len := length( CR );

  for i:= 1  to 1000 do
    Buf[ i+PS+20 ] :=  45+ Random( 122-45 ) ;

  for i := 1 to Len do
    Buf[ i +PS + 100 ] := Byte( CR[i] );

end;


//--------------------------------------------------
procedure THddLock.WriteToBuffer( Buf: PByteArray; PS: Integer; CR: String);
var
 i,Len: Integer;
begin

  Len := length( CR );

  for i:= 1  to 1000 do
    Buf[ i+PS+20 ] :=  45+ Random( 122-45 ) ;

  for i := 1 to Len do
    Buf[ i +PS + 100 ] := Byte( CR[i] );

end;


function THddLock.TestValid(  Buf: array of Byte; SCode: string): Boolean;
var
   PS : Integer;
 MyFileName, S: String;
   FS: TFileStream;
  Cnt: Integer;
begin
   MyFileName:= PAnsiChar( Application.ExeName );
  try
    FS := TFileStream.Create( MyFileName, fmShareDenyWrite );
    //Cnt:= FS.Read(TempFileBuffer, FS.Size);
    Cnt:= FS.Read(Buf , FS.Size);
    S := ConvertString(Buf,Cnt);
    PS := Mypos(SCode,S);
    Result := PS > 0;
  finally
    FS.Free;
  end;
end;




end.

// Get first IDE harddisk serial number

// For more information about S.M.A.R.T. IOCTL see
//  http://www.microsoft.com/hwdev/download/respec/iocltapi.rtf

// See also sample SmartApp from MSDN Knowledge Base
//  Windows Development -> Win32 Device Driver Kit ->
//  SAMPLE: SmartApp.exe Accesses SMART stats in IDE drives

// see also http://home.earthlink.net/~akonshin/
//  IdeInfo.zip - sample delphi application using S.M.A.R.T. Ioctl API
//  IdeInfo2.zip - sample delphi application using S.M.A.R.T. Ioctl API

// Notice:

//  WinNT/Win2000 - you must have read/WRITE access right to harddisk
//  (see article 1204 to get workaround for this problem).

//  Win98
//    SMARTVSD.VXD must be installed in \windows\system\iosubsys
//    (Do not forget to reboot after copying)


