(* CommConnect - comm connection components
 * Copyright (C) 2003 Tomas Mandys-MandySoft
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA  02111-1307  USA
 *)

{ URL: http://www.2p.cz }

unit CommConnect;

{ CommConnect.htx }

interface
uses
  Classes, SysUtils, Connect {$IFDEF LINUX}, Libc, Types, KernelIoctl{$ELSE}, Windows{$ENDIF}, SyncObjs;

{$IFDEF LINUX}
const
  INFINITE = $FFFFFFFF;
  INVALID_HANDLE_VALUE = THandle(-1);
{$IF NOT DECLARED(_PATH_LOCK)}
  _PATH_LOCK = '/var/lock';
{$IFEND}
{$ENDIF}

type
  TCommEvent = procedure(Sender: TObject; Status: dword) of object;
  TCommEventType = (evBreak, evCts, evDsr, evError, evRing, evRlsd, evRxChar, evRxFlag, evTxEmpty);
  TCommEventTypes = set of TCommEventType;

  TBaudrate =(br110, br300, br600, br1200, br2400, br4800, br9600, br14400,
    br19200, br38400, br56000, br57600, br115200, br128000, br256000);
  TParity = (paNone, paOdd, paEven, paMark, paSpace);
  TStopbits = (sb10, sb15, sb20);
  TDatabits=(da4, da5, da6, da7, da8);
  TFlowControl = (fcNone, fcCTS, fcDTR, fcSoftware, fcDefault);

  TCommOption = (coParityCheck, coDsrSensitivity, coIgnoreXOff,
    coErrorChar, coNullStrip);
  TCommOptions = set of TCommOption;

  TCommErrorEvent = procedure(Sender: TObject; Errors: Integer) of object;

  TCommHandle = class;

  TCommEventThread = class(TThread)
  private
    FCommHandle: THandle;
    FEventMask: dWord;
    FComm: TCommHandle;
  {$IFDEF LINUX}
    FEvents: TCommEventTypes;
    FCriticalSection: TCriticalSection;
    FWriteFlag: Boolean;
    FModemFlags: Integer;
  {$ELSE}
    FEvent: TSimpleEvent;
  {$ENDIF}
  protected
    procedure Execute; override;
    procedure Terminate;
    procedure DoOnSignal;
  public
    constructor Create(aComm: TCommHandle; Handle: THandle; Events: TCommEventTypes);
    destructor Destroy; override;
  end;

  TCommHandle = class(TCommunicationConnection)
  private
    FhCommDev: THandle;
    FBaudrate: TBaudrate;
    FParity: TParity;
    FStopBits: TStopBits;
    FDataBits: TDataBits;
    FFlowControl: TFlowControl;
    FOptions: TCommOptions;
    FReadTimeout: Integer;
    FWriteTimeout: Integer;
    FReadBufSize: Integer;
    FWriteBufSize: Integer;
    FMonitorEvents: TCommEventTypes;
    FEventChars: array[1..5] of AnsiChar;
    FEvent: TSimpleEvent;
    FCriticalSection: TCriticalSection;
    FEventThread: TCommEventThread;
    FOnBreak: TNotifyEvent;
    FOnCts: TNotifyEvent;
    FOnDsr: TNotifyEvent;
    FOnError: TCommErrorEvent;
    FOnRing: TNotifyEvent;
    FOnRlsd: TNotifyEvent;
    FOnRxFlag: TNotifyEvent;
    FOnTxEmpty: TNotifyEvent;
    procedure SethCommDev(Value: THandle);
    procedure SetBaudRate(Value: TBaudRate);
    procedure SetParity(Value: TParity);
    procedure SetStopbits(Value: TStopBits);
    procedure SetDatabits(Value: TDatabits);
    procedure SetOptions(Value: TCommOptions);
    procedure SetFlowControl(Value: TFlowControl);
    function GetEventChar(Index: Integer): AnsiChar;
    procedure SetEventChar(Index: Integer; Value: AnsiChar);
    procedure SetReadBufSize(Value: Integer);
    procedure SetWriteBufSize(Value: Integer);
    procedure SetMonitorEvents(Value: TCommEventTypes);
{$IFNDEF LINUX}
    function GetComState(Index: Integer): Boolean;
{$ENDIF}
    function GetModemState(Index: Integer): Boolean;
    procedure SetEsc(Index: Integer; Value: Boolean);
{$IFDEF LINUX}
    procedure SetEscBreak(Value: Boolean);
{$ENDIF}
    procedure UpdateCommTimeouts;
    procedure UpdateDataControlBlock;
  protected
    procedure OpenConn; override;
    procedure CloseConn; override;
    procedure UpdateDCB; virtual;
{$IFNDEF LINUX}
    procedure EscapeComm(Flag: Integer);
{$ENDIF}
    procedure HandleCommEvent(Status: dword); virtual;
    function Write({const}var Buf; Count: Integer): Integer; override;
    function Read(var Buf; Count: Integer): Integer; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ComError2(const aFunc: string);
    property hCommDev: THandle read FhCommDev write SethCommDev;
    function InQueCount: Integer; override;
    function OutQueCount: Integer;
    procedure Lock;
    procedure Unlock;
    procedure PurgeIn; override;
    procedure PurgeOut; override;
{$IFNDEF LINUX}
    property CtsHold: Boolean index Integer(fCtlHold) read GetComState;
    property DsrHold: Boolean index Integer(fDsrHold) read GetComState;
    property RlsdHold: Boolean index Integer(fRlsHold) read GetComState;
    property XoffHold: Boolean index Integer(fXoffHold) read GetComState;
    property XOffSent: Boolean index Integer(fXoffSent) read GetComState;
    property Eof: Boolean index Integer(fEof) read GetComState;
{$ENDIF}
    {Comm escape functions}
    property DTRState: Boolean index 1 write SetEsc;
    property RTSState: Boolean index 2 write SetEsc;
{$IFDEF LINUX}
    property BreakState: Boolean write SetEscBreak;
{$ELSE}
    property BreakState: Boolean index 3 write SetEsc;
{$ENDIF}
    property XONState: Boolean index 4 write SetEsc;
    {Comm status flags}
    property CTS: Boolean index Integer({$IFDEF LINUX}TIOCM_CTS{$ELSE}MS_CTS_ON{$ENDIF}) read GetModemState;
    property DSR: Boolean index Integer({$IFDEF LINUX}TIOCM_DSR{$ELSE}MS_DSR_ON{$ENDIF}) read GetModemState;
    property RING: Boolean index Integer({$IFDEF LINUX}TIOCM_RNG{$ELSE}MS_RING_ON{$ENDIF}) read GetModemState;
    property RLSD: Boolean index Integer({$IFDEF LINUX}TIOCM_CAR{$ELSE}MS_RLSD_ON{$ENDIF}) read GetModemState;
  published
    property Baudrate: TBaudrate read FBaudrate write SetBaudrate default br9600;
    property Parity: TParity read FParity write SetParity default paNone;
    property Stopbits: TStopbits read FStopbits write SetStopbits default sb10;
    property Databits: TDatabits read FDatabits write SetDatabits default da8;
    property Options: TCommOptions read FOptions write SetOptions;
    property DontSynchronize;
    property FlowControl: TFlowControl read FFlowControl write SetFlowControl default fcDefault;
    property XonChar: AnsiChar index 1 read GetEventChar write SetEventChar default #17;
    property XoffChar: AnsiChar index 2 read GetEventChar write SetEventChar default #19;
    property ErrorChar: AnsiChar index 3 read GetEventChar write SetEventChar default #0;
    property EofChar: AnsiChar index 4 read GetEventChar write SetEventChar default #0;
    property EvtChar: AnsiChar index 5 read GetEventChar write SetEventChar default #0;
    property ReadTimeout: Integer read FReadTimeout write FReadTimeout default 1000;
    property WriteTimeout: Integer read FWriteTimeout write FWriteTimeout default 1000;
    property ReadBufSize: Integer read FReadBufSize write SetReadBufSize default 4096;
    property WriteBufSize: Integer read FWriteBufSize write SetWriteBufSize default 2048;
    property MonitorEvents: TCommEventTypes read FMonitorEvents write SetMonitorEvents;
    property OnBreak: TNotifyEvent read FOnBreak write FOnBreak;
    property OnCts: TNotifyEvent read FOnCts write FOnCts;
    property OnDsr: TNotifyEvent read FOnDsr write FOnDsr;
    property OnRing: TNotifyEvent read FOnRing write FOnRing;
    property OnRlsd: TNotifyEvent read FOnRlsd write FOnRlsd;
    property OnError: TCommErrorEvent read FOnError write FOnError;
    property OnRxChar;
    property OnRxFlag: TNotifyEvent read FOnRxFlag write FOnRxFlag;
    property OnTxEmpty: TNotifyEvent read FOnTxEmpty write FOnTxEmpty;
  end;

  TKMComm = class(TCommHandle)
  private
    FDeviceName: string;
    procedure SetDeviceName(const Value: string);
  protected
    procedure OpenConn; override;
    procedure CloseConn; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DeviceName: string read FDeviceName write SetDeviceName;
  end;

  TModemRxCommandEvent = procedure (Sender: TObject; aRx: string) of object;


  EComError = class(EConnectError)
  end;

procedure Register;

function Int2BaudRate(BR1: Longint; var BR: TBaudRate): Boolean;
function BaudRate2Int(BR: TBaudRate): Longint;

function Event_WaitFor(fEvent: TEvent; aTimeout: LongWord): TWaitResult;
{$IFDEF LINUX}
procedure AcquireLock(DeviceName: string);
procedure ReleaseLock(DeviceName: string);
function GetTickCount(): LongWord; {ms}
{$ENDIF}

implementation

resourcestring
  sCommError = 'Error %d %s in function: %s';
  sModemNoResponse = 'No response on %s';
  sModemNoDialTone = 'No dial tone';
  sModemBusy = 'Line is busy';
  sModemNoConnection = 'Cannot connect';
  {$IFDEF LINUX}
  sDeviceLocked = 'Device "%s" is locked';
  sCommErr4Databits = 'Four databits not supported';
  sCommNotSupported= 'Not supported in linux';
  sCommErrDatabits = 'Databits settings not supported';
  sCommErrParity = 'Baudrate settings not supported';
  sCommErrBaudrate = 'Baudrate settings not supported';
  sCommErrStopBits = 'Stopbits settings not supported';
  sCommErrFlow = 'Flow control settings not supported';
  {$ENDIF}

const
{$IFDEF LINUX}
  DefaultDeviceName = _PATH_TTY+'S0';
const
  EV_RXCHAR = 1;        { Any Character received }
  EV_RXFLAG = 2;        { Received certain character }
  EV_TXEMPTY = 4;       { Transmitt Queue Empty }
  EV_CTS = 8;           { CTS changed state }
  EV_DSR = $10;         { DSR changed state }
  EV_RLSD = $20;        { RLSD changed state }
  EV_BREAK = $40;       { BREAK received }
  EV_ERR = $80;         { Line status error occurred }
  EV_RING = $100;       { Ring signal detected }
  EV_PERR = $200;       { Printer error occured }
var
  CommEventThreadList: TList;
{$ELSE}
  DefaultDeviceName = 'Com2';
{$ENDIF}

procedure ComError(const Msg: string);
begin
  raise EComError.Create(Msg);
end;

procedure TCommHandle.ComError2(const aFunc: string);
var
  S: string;
const
 CRLF = #13#10;
begin
{$IFDEF LINUX}
  S:= '';
{$ELSE}
  SetLength(S, 1023);
  SetLength(S, FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, GetLastError, 0, PChar(S), Length(S), nil));
  if (S <> '') then
    if Pos(CRLF, S) = (Length(S) - 1) then
      S := Copy(S, 1, Length(S) - 2);
{$ENDIF}
  ComError(Format(sCommError, [GetLastError, S, aFunc]));
end;

{$IFNDEF LINUX}
const
  CommEventList: array[TCommEventType] of dword = (EV_BREAK, EV_CTS, EV_DSR, EV_ERR, EV_RING, EV_RLSD, EV_RXCHAR, EV_RXFLAG, EV_TXEMPTY);
{$ENDIF}

constructor TCommEventThread.Create(aComm: TCommHandle; Handle: THandle; Events: TCommEventTypes);
{$IFNDEF LINUX}
var
  EvIndex: TCommEventType;
  AttrWord: dword;
{$ENDIF}
begin
  FCommHandle := Handle;
  {$IFDEF LINUX}
  CommEventThreadList.Add(Self);
  FCriticalSection:= TCriticalSection.Create;
  ioctl(FCommHandle, TIOCMGET, @FModemFlags);
  FEvents:= Events;
  {$ELSE}
  AttrWord := $0;
  for EvIndex := Low(TCommEventType) to High(TCommEventType) do
    if EvIndex in Events then AttrWord := AttrWord or CommEventList[EvIndex];
  SeTCommMask(FCommHandle, AttrWord);
  FEvent := TSimpleEvent.Create;
  {$ENDIF}
  FComm:= aComm;
  inherited Create(False);
  {$IFNDEF LINUX}
  Priority := tpHigher;
  {$ENDIF}
end;

destructor TCommEventThread.Destroy;
{$IFDEF LINUX}
var
  I: Integer;
{$ENDIF}
begin
  {$IFDEF LINUX}
  FCriticalSection.Free;
  I:= CommEventThreadList.IndexOf(Self);
  if I >= 0 then
    CommEventThreadList.Delete(I);
  {$ELSE}
  FEvent.Free;
  {$ENDIF}
  inherited Destroy;
end;

procedure TCommEventThread.Execute;
{$IFNDEF LINUX}
var
  Overlapped: TOverlapped;
  WaitEventResult: Boolean;
{$ELSE}
var
  rfds, wfds, efds: TFDSet;
  wfds2: PFDSet;
  tv: TTimeVal;
  Flags, Flags2: Integer;
{$ENDIF}
begin
{$IFDEF LINUX}
  while not Terminated do
  begin
    FD_ZERO(rfds); FD_ZERO(wfds); FD_ZERO(efds);
    FD_SET(FCommHandle, rfds);
    FD_SET(FCommHandle, wfds);
    FD_SET(FCommHandle, efds);
    tv.tv_sec:= 0;
    tv.tv_usec:= 10{ms};
    if fWriteFlag then
      wfds2:= @wfds
    else
      wfds2:= nil;    // is set when buffer is empty
    if select(FCommHandle+1, @rfds, wfds2, @efds, @tv) > 0 then
    begin
      FCriticalSection.Enter;
      try
        if FD_ISSET(FCommHandle, rfds) then
          fEventMask:= fEventMask or EV_RXCHAR;
        if FWriteFlag and FD_ISSET(FCommHandle, wfds) then
          if fComm.OutQueCount = 0 then
          begin
            fEventMask:= fEventMask or EV_TXEMPTY;
            fWriteFlag:= False;
          end;
        if FD_ISSET(FCommHandle, efds) then
          fEventMask:= fEventMask or EV_ERR;
      finally
        fCriticalSection.Leave;
      end;
      if fEventMask <> 0 then
        if FComm.DontSynchronize then DoOnSignal
                                 else Synchronize(DoOnSignal);
    end;
    if not Terminated and (FEvents * [evRing, evCts, evDsr] <> []) then
    begin
      ioctl(FCommHandle, TIOCMGET, @Flags);
      Flags2:= FModemFlags xor Flags;
      FModemFlags:= Flags;
      if (evRing in FEvents) and (Flags2 and TIOCM_RNG <> 0) then
        FEventMask:= FEventMask or EV_RING;
      if (evCts in FEvents) and (Flags2 and TIOCM_CTS <> 0) then
        FEventMask:= FEventMask or EV_CTS;
      if (evDsr in FEvents) and (Flags2 and TIOCM_DSR <> 0) then
        FEventMask:= FEventMask or EV_DSR;
//      (evBreak, evError, evevRlsd, evRxFlag);  ???  not supported in linux
    end;
  end;
  ioctl(integer(FCommHandle), TCFLSH, TCIOFLUSH);
{$ELSE}
  FillChar(Overlapped, Sizeof(Overlapped), 0);
  Overlapped.hEvent:= FEvent.Handle;
  while not Terminated do
  begin
    WaitEventResult:= WaiTCommEvent(FCommHandle, FEventMask, @Overlapped);
    if (GetLastError = ERROR_IO_PENDING) then
      WaitEventResult:= (FEvent.WaitFor(INFINITE) = wrSignaled);
    if WaitEventResult then
    begin
      if FComm.DontSynchronize then DoOnSignal
                               else Synchronize(DoOnSignal);
      FEvent.ResetEvent;
    end;
  end;
  PurgeComm(FCommHandle, PURGE_RXABORT+PURGE_RXCLEAR+PURGE_TXABORT+PURGE_TXCLEAR);
{$ENDIF}
end;

procedure TCommEventThread.Terminate;
begin
  inherited;   // Terminated:= True;
{$IFNDEF LINUX}
  FEvent.SetEvent;
{$ENDIF}
end;

procedure TCommEventThread.DoOnSignal;
{$IFDEF LINUX}
var
  Msk: DWord;
{$ENDIF}
begin
  {$IFDEF LINUX}
  FCriticalSection.Enter;
  try
    Msk:= fEventMask;
    fEventMask:= 0;
  finally
    FCriticalSection.Leave;
  end;
  FComm.HandleCommEvent(Msk);
  {$ELSE}
  FComm.HandleCommEvent(fEventMask);
  {$ENDIF}
end;

const
  fBinary              = $00000001;
  fParity              = $00000002;
  fOutxCtsFlow         = $00000004;
  fOutxDsrFlow         = $00000008;
  fDtrControl          = $00000030;
  fDtrControlDisable   = $00000000;
  fDtrControlEnable    = $00000010;
  fDtrControlHandshake = $00000020;
  fDsrSensitivity      = $00000040;
  fTXContinueOnXoff    = $00000080;
  fOutX                = $00000100;
  fInX                 = $00000200;
  fErrorChar           = $00000400;
  fNull                = $00000800;
  fRtsControl          = $00003000;
  fRtsControlDisable   = $00000000;
  fRtsControlEnable    = $00001000;
  fRtsControlHandshake = $00002000;
  fRtsControlToggle    = $00003000;
  fAbortOnError        = $00004000;
  fDummy2              = $FFFF8000;

constructor TCommHandle.Create;
begin
  inherited Create(AOwner);
  FhCommDev:= INVALID_HANDLE_VALUE;
  FReadTimeout := 1000;
  FWriteTimeout := 1000;
  FReadBufSize := 4096;
  FWriteBufSize := 2048;
  FMonitorEvents := [evBreak, evCts, evDsr, evError, evRing,
    evRlsd, evRxChar, evRxFlag, evTxEmpty];
  FBaudRate := br9600;
  FParity := paNone;
  FStopbits := sb10;
  FDatabits := da8;
  FOptions := [];
  FFlowControl := fcDefault;
  XonChar := #17;
  XoffChar := #19;
  FEvent := TSimpleEvent.Create;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TCommHandle.Destroy;
begin
  inherited Destroy;
  FEvent.Free;
  FCriticalSection.Free;
end;

procedure TCommHandle.SethCommDev(Value: THandle);
begin
  CheckInactive;
  FhCommDev:= Value;
end;

procedure TCommHandle.SetBaudRate(Value: TBaudRate);
begin
  if FBaudRate <> Value then
  begin
    FBaudRate := Value;
    UpdateDataControlBlock;
  end;
end;

procedure TCommHandle.SetParity(Value: TParity);
begin
  if FParity <> Value then
  begin
    FParity := Value;
    UpdateDataControlBlock;
  end;
end;

procedure TCommHandle.SetStopbits(Value: TStopbits);
begin
  if FStopBits <> Value then
  begin
    FStopbits := Value;
    UpdateDataControlBlock;
  end;
end;

procedure TCommHandle.SetDataBits(Value: TDatabits);
begin
  if FDataBits <> Value then
  begin
    FDataBits:=Value;
    UpdateDataControlBlock;
  end;
end;

procedure TCommHandle.SetOptions(Value: TCommOptions);
begin
  if FOptions <> Value then
  begin
    FOptions := Value;
    UpdateDataControlBlock;
  end;
end;

procedure TCommHandle.SetFlowControl(Value: TFlowControl);
begin
  if FFlowControl <> Value then
  begin
    FFlowControl := Value;
    UpdateDataControlBlock;
  end;
end;

function TCommHandle.GetEventChar;
begin
  Result:= FEventChars[Index];
end;

procedure TCommHandle.SetEventChar;
begin
  if FEventChars[Index] <> Value then
  begin
    FEventChars[Index]:= Value;
    UpdateDataControlBlock;
  end;
end;

procedure TCommHandle.SetReadBufSize(Value: Integer);
begin
  CheckInactive;
  FReadBufSize:= Value;
end;

procedure TCommHandle.SetWriteBufSize(Value: Integer);
begin
  CheckInactive;
  FWriteBufSize:= Value;
end;

procedure TCommHandle.SetMonitorEvents(Value: TCommEventTypes);
begin
  CheckInactive;
  FMonitorEvents := Value;
end;

procedure TCommHandle.Lock;
begin
  FCriticalSection.Enter;
end;

procedure TCommHandle.Unlock;
begin
  FCriticalSection.Leave;
end;

procedure TCommHandle.OpenConn;
{$IFNDEF LINUX}
var
  filetype: DWORD;
{$ENDIF}
begin
  if csDesigning in ComponentState then
    Exit;
  if FhCommDev = INVALID_HANDLE_VALUE then
    ComError2('CreateFile');

  {$IFNDEF LINUX}
  filetype:= GetFileType(FhCommDev);

  { Obviously, a Com connection over Bluetooth is of file type unknown instead of char, may be dependent on the Bluetooth interface in the PC }
  if (filetype <> FILE_TYPE_UNKNOWN) and (filetype <> FILE_TYPE_CHAR) then
  begin
    CloseHandle(FhCommDev);
    FhCommDev:= INVALID_HANDLE_VALUE;
    ComError2('GetFileType');
  end;
  {$ENDIF}
  FEventThread:= TCommEventThread.Create(Self, FhCommDev, FMonitorEvents);
  UpdateCommTimeouts;
  UpdateDCB;
  { allow the process to receive SIGIO }
//  fcntl(FhCommDev, F_SETOWN, getpid());
  { Make the file descriptor asynchronous (the manual page says only O_APPEND and O_NONBLOCK, will work with F_SETFL...) }
//  opts:= fcntl(FhCommDev, F_GETFL);
//  if opts < 0 then
//    ComError2('fcntl F_GETFL');
//  opts:= opts or FASYNC;
//  fcntl(FhCommDev, F_SETFL, opts);

  {$IFNDEF LINUX}
  if not SetupComm(FhCommDev, FReadBufSize, FWriteBufSize) then
    ComError2('SetupComm');
  {$ENDIF}
end;

procedure TCommHandle.CloseConn;
begin
  if FhCommDev <> INVALID_HANDLE_VALUE then
  begin
    with FEventThread do
    begin
      Terminate;
      WaitFor;  // set fFinished:= True;
      Free;     // no WaitFor
    end;
    {$IFDEF LINUX}
    FileClose(Integer(FhCommDev));
    {$ELSE}
    CloseHandle(FhCommDev);
    {$ENDIF}
    FhCommDev:= INVALID_HANDLE_VALUE;
  end;
end;

function TCommHandle.Write({const}var Buf; Count: Integer): Integer;
var
{$IFNDEF LINUX}
  Overlapped: TOverlapped;
{$ELSE}
  Tick: LongWord;
  P: PChar;
{$ENDIF}
begin
  Lock;
  try
    {$IFDEF LINUX}
    FEventThread.FWriteFlag:= True;
    Tick:= GetTickCount();
    P:= @Buf;
    repeat
      Result:= FileWrite(integer(FhCommDev), P^, Count);
      if Result > 0 then
      begin
        Inc(P, Result);
        Dec(Count, Result);
      end;
    until (Result < 0) or (Count <= 0) or (FWriteTimeout = 0) or (Abs(GetTickCount-Tick) >= FWriteTimeout);
    if THandle(Result) = INVALID_HANDLE_VALUE then
      ComError2('FileWrite');
    {$ELSE}
    FillChar(Overlapped, Sizeof(Overlapped), 0);
    Overlapped.hEvent := FEvent.Handle;
    if not WriteFile(FhCommDev, Buf, Count, dWord(Result), @Overlapped) then
    if (GetLastError <> ERROR_IO_PENDING) then
      ComError2('WriteFile');
    if FEvent.WaitFor(FWriteTimeout) <> wrSignaled then
      Result:= 0
    else
     begin
       GetOverlappedResult(FhCommDev, Overlapped, dWord(Result), False);
       FEvent.ResetEvent;
     end;
    {$ENDIF}
  finally
    Unlock;
  end;
end;

function TCommHandle.Read(var Buf; Count: Integer): Integer;
var
{$IFNDEF LINUX}
  Overlapped: TOverlapped;
{$ELSE}
  Tick: LongWord;
  P: PChar;
{$ENDIF}
begin
  Lock;
  try
    {$IFDEF LINUX}
    Tick:= GetTickCount;
    P:= @Buf;
    repeat
      Result:= FileRead(integer(FhCommDev), P^, Count);
      if Result > 0 then
      begin
        Inc(P, Result);
        Dec(Count, Result);
      end;
    until (Result < 0) or (Count <= 0) or (FReadTimeout = 0) or (Abs(GetTickCount-Tick) >= FReadTimeout);

    if THandle(Result) = INVALID_HANDLE_VALUE then
      ComError2('FileRead');
    {$ELSE}
    FillChar(Overlapped, Sizeof(Overlapped), 0);
    Overlapped.hEvent := FEvent.Handle;
    if not ReadFile(FhCommDev, Buf, Count, dWord(Result), @Overlapped) and (GetLastError <> ERROR_IO_PENDING) then
      ComError2('ReadFile');
    if FEvent.WaitFor(FReadTimeout) <> wrSignaled then
      Result:= 0
    else
     begin
       GetOverlappedResult(FhCommDev, Overlapped, dWord(Result), False);
       FEvent.ResetEvent;
     end;
    {$ENDIF}
  finally
    Unlock;
  end;
end;

function TCommHandle.InQueCount: Integer;
{$IFNDEF LINUX}
var
  ComStat: TComStat;
  Errors: dword;
{$ENDIF}
begin
  if Active then
  begin
    {$IFDEF LINUX}
    ioctl(integer(FhCommDev), TIOCINQ, @result);
    {$ELSE}
    ClearCommError(FhCommDev, Errors, @ComStat);
    Result:= ComStat.cbInQue;
    {$ENDIF}
  end else Result:= -1;
end;

function TCommHandle.OutQueCount: Integer;
{$IFNDEF LINUX}
var
  ComStat: TComStat;
  Errors: dword;
{$ENDIF}
begin
  if Active then
  begin
    {$IFDEF LINUX}
    ioctl(integer(FhCommDev), TIOCOUTQ, @result);
    {$ELSE}
    ClearCommError(FhCommDev, Errors, @ComStat);
    Result:= ComStat.cbOutQue;
    {$ENDIF}
  end else Result:= -1;
end;

procedure TCommHandle.HandleCommEvent;
var
  Errors: dword;
{$IFNDEF LINUX}
  ComStat: TComStat;
{$ELSE}
  N: Integer;
{$ENDIF}
begin
{$IFNDEF LINUX}
  ClearCommError(FhCommDev, Errors, @ComStat);
{$ENDIF}
  if Status and EV_BREAK > 0 then
    if Assigned(FOnBreak) then FOnBreak(self);
  if Status and EV_CTS > 0 then
    if Assigned(FOnCts) then FOnCts(self);
  if Status and EV_DSR > 0 then
    if Assigned(FOnDsr) then FOnDsr(self);
  if Status and EV_ERR > 0 then
    if Assigned(FOnError) then FOnError(self, Errors); // ???
  if Status and EV_RING > 0 then
    if Assigned(FOnRing) then FOnRing(self);
  if Status and EV_RLSD > 0 then
    if Assigned(FOnRlsd) then FOnRlsd(self);
  if Status and EV_RXCHAR > 0 then
  {$IFDEF LINUX}
  begin
    ioctl(integer(FhCommDev), TIOCINQ, @N);  // safe InQueCount
    if N > 0 then
      DoOnRxChar(N);
  end;
  {$ELSE}
    if ComStat.cbInQue > 0 then
      DoOnRxChar(ComStat.cbInQue);
  {$ENDIF}
  if Status and EV_RXFLAG > 0 then
    if Assigned(FOnRxFlag) then FOnRxFlag(self);
  if Status and EV_TXEMPTY > 0 then
    if Assigned(FOnTxEmpty) then FOnTxEmpty(self);
end;

{$IFNDEF LINUX}
procedure TCommHandle.EscapeComm(Flag: Integer);
begin
  CheckActive;
  if not EscapeCommFunction(FhCommDev, Flag) then
    ComError2('EscapeCommFunction');
end;
{$ENDIF}

{$IFDEF LINUX}
procedure TCommHandle.SetEscBreak;
begin
  if Value then
    tcsendbreak(FhCommDev, 0);
end;
{$ENDIF}

procedure TCommHandle.SetEsc;
{$IFDEF LINUX}
var
  Flags: dword;
const
  Esc: array[1..2] of DWORD = (TIOCM_DTR, TIOCM_RTS);
{$ELSE}
const
  Esc: array[1..4, Boolean] of Integer = ((CLRDTR, SETDTR),(CLRRTS, SETRTS),(CLRBREAK, SETBREAK),(SETXOFF, SETXON));
{$ENDIF}
begin
{$IFDEF LINUX}

  if ioctl(FhCommDev, TIOCMGET, @Flags) = 0 then
  begin
    if Value then
      Flags:= Flags or Esc[Index]
    else
      Flags:= Flags and not Esc[Index];
    ioctl(integer(FhCommDev), TIOCMSET, @Flags);
    if Active and (Index = 3) then
      ioctl(integer(FhCommDev), TCFLSH, TCIOFLUSH);
  end;

{$ELSE}
  EscapeComm(Esc[Index, Value]);
  if Active and (Index = 3) then
    PurgeComm(FhCommDev, PURGE_RXABORT+PURGE_RXCLEAR+PURGE_TXABORT+PURGE_TXCLEAR);
{$ENDIF}
end;

{$IFNDEF LINUX}
function TCommHandle.GetComState(Index: Integer): Boolean;
var
  ComStat: TComStat;
  Errors: DWord;
begin
  Result := false;
  if Active then
  begin
{$IFDEF LINUX}
    ComError(sCommNotSupported);
{$ELSE}
    if not ClearCommError(FhCommDev, Errors, @ComStat) then
      ComError2('ClearCommError');
    Result:= TComStateFlag(Index) in ComStat.Flags;
{$ENDIF}
  end;
end;
{$ENDIF}

function TCommHandle.GetModemState(Index: Integer): Boolean;
var
  Flag: dword;
begin
  Result:= False;
  if Active then
  begin
    {$IFDEF LINUX}
    if ioctl(FhCommDev, TIOCMGET, @Flag) < 0 then
      ComError2('ioctl TIOCMGET');
    {$ELSE}
    if not GeTCommModemStatus(FhCommDev, Flag) then
      ComError2('GeTKMCommModemStatus');
    {$ENDIF}
    Result:= (Flag and Index) <> 0;
  end;
end;

procedure TCommHandle.UpdateDataControlBlock;
begin
  if Active then
    UpdateDCB;
end;

procedure TCommHandle.UpdateDCB;
{$IFDEF LINUX}
var
  Term: termios;
const
  CommBaudRates: array[TBaudRate] of Integer = (B110, B300, B600, B1200, B2400, B4800, B9600, -1,
      B19200, B38400, -1, B57600, B115200, -1, B230400);
  CommDataBits: array[TDatabits] of Integer = (-1, CS5, CS6, CS7, CS8);
{$ELSE}
const
  CommBaudRates: array[TBaudRate] of Integer = ( CBR_110, CBR_300, CBR_600, CBR_1200, CBR_2400, CBR_4800, CBR_9600, CBR_14400,
      CBR_19200, CBR_38400, CBR_56000, CBR_57600, CBR_115200, CBR_128000, CBR_256000);
  CommOptions: array[TCommOption] of Integer = (CommConnect.fParity, fDsrSensitivity, fTXContinueOnXoff, fErrorChar, fNull);
  CommDataBits: array[TDatabits] of Integer = (4, 5, 6, 7, 8);
  CommParity: array[TParity] of Integer = (NOPARITY, ODDPARITY, EVENPARITY, MARKPARITY, SPACEPARITY);
  CommStopBits: array[TStopbits] of Integer = (ONESTOPBIT, ONE5STOPBITS, TWOSTOPBITS);
var
  OptIndex: TCommOption;
  DCB: TDCB;
{$ENDIF}
begin
  {$IFDEF LINUX}
  tcgetattr(Integer(FhCommDev), term);
  cfmakeraw(term);

  // input flags
//  if evBreak in fMonitorEvents then
//    term.c_iflag:= term.c_iflag or BRKINT and not IGNBRK  // generate global interrupt (signal)
//  else
    term.c_iflag:= term.c_iflag or IGNBRK;  // ignore BREAK

  if evError in fMonitorEvents then
    term.c_iflag:= term.c_iflag and not IGNPAR or PARMRK  // prefix a character with a parity error or  framing  error  with \377 \0.
  else
    term.c_iflag:= term.c_iflag or IGNPAR;

  if fParity in [paOdd, paEven] then
    term.c_iflag:= term.c_iflag or INPCK  // check parity
  else
    term.c_iflag:= term.c_iflag and not INPCK;

  if FFlowControl = fcSoftware then
    term.c_iflag := term.c_iflag or (IXON or IXOFF or IXANY)
  else if FFlowControl <> fcDefault then
    term.c_iflag := term.c_iflag and not (IXON or IXOFF or IXANY);

  // control flags
  term.c_cflag := term.c_cflag or CREAD or HUPCL or CLOCAL;

  term.c_cflag := term.c_cflag and not CSIZE;
  if CommDataBits[fDataBits] = -1 then
    ComError(sCommErrDatabits);
  term.c_cflag := term.c_cflag and not CSIZE or Cardinal(CommDataBits[fDataBits]);

  case fStopBits of
    sb10: term.c_cflag := term.c_cflag and not CSTOPB;
    sb15: ComError(sCommErrStopBits);
    sb20: term.c_cflag := term.c_cflag or CSTOPB;
  end;

  if fParity = paNone then
    term.c_cflag := term.c_cflag and not PARENB
  else
    term.c_cflag := term.c_cflag or PARENB;

  case fParity of
    paOdd:
      term.c_cflag := term.c_cflag or PARODD;
    paEven:
      term.c_cflag := term.c_cflag and not PARODD;
    paMark, paSpace:
      ComError(sCommErrParity);
  end;

  if FFlowControl in [fcCTS] then
    term.c_cflag := term.c_cflag or CRTSCTS
  else if FFlowControl = fcDTR then
    ComError(sCommErrFlow)
  else if FFlowControl <> fcDefault then
    term.c_cflag := term.c_cflag and not CRTSCTS;

  if CommBaudRates[fBaudRate] = -1 then
    ComError(sCommErrBaudrate);

  cfsetospeed(term, CommBaudRates[fBaudRate]);
  cfsetispeed(term, CommBaudRates[fBaudRate]);

  // local modec
  term.c_lflag:= term.c_lflag and not ICANON;

  // character slots
  term.c_cc[VEOF]:= EofChar;  // only canonical
  term.c_cc[VSTART]:= XonChar;
  term.c_cc[VSTOP]:= XoffChar;
  term.c_cc[VINTR]:= EvtChar;
    // ErrorChar .. not supported
  term.c_cc[VMIN]:= #0;
  term.c_cc[VTIME]:= #0;

  if tcsetattr(Integer(FhCommDev), TCSANOW, term) < 0 then
    ComError2('tcsetattr TSCANOW');
  {$ELSE}
  GeTCommState(FhCommDev, DCB);
  DCB.BaudRate := CommBaudRates[FBaudRate];
  DCB.Parity := CommParity[FParity];
  DCB.Stopbits := CommStopbits[FStopbits];
  DCB.Bytesize := CommDatabits[FDatabits];
  DCB.XonChar := XonChar;
  DCB.XoffChar := XOffChar;
  DCB.ErrorChar := ErrorChar;
  DCB.EofChar := EofChar;
  DCB.EvtChar := EvtChar;
  DCB.XonLim := FReadBufSize div 4;
  DCB.XoffLim := FReadBufSize div 4;

  case FFlowControl of
    fcNone: //Clear all flags
      DCB.Flags := fBinary;
    fcDefault:; //do nothing;
    fcCTS:
      DCB.Flags := DCB.Flags or fOutxCtsFlow or fRtsControlHandshake;
    fcDTR:
      DCB.Flags := DCB.Flags or fOutxDsrFlow or fDtrControlHandshake;
    fcSoftware:
      DCB.Flags := DCB.Flags or fOutX or fInX;
  end;
  for OptIndex := Low(TCommOption) to High(TCommOption) do
    if OptIndex in FOptions then DCB.Flags := DCB.Flags or CommOptions[OptIndex]
                            else DCB.Flags := DCB.Flags and not CommOptions[OptIndex];

  if not SeTCommState(FhCommDev, DCB) then
    ComError2('SeTKMCommState');
  {$ENDIF}
end;

procedure TCommHandle.UpdateCommTimeouts;
{$IFNDEF LINUX}
var
  CommTimeouts: TCommTimeouts;
{$ENDIF}
begin
{$IFNDEF LINUX}   
  FillChar(CommTimeOuts, Sizeof(CommTimeOuts), 0);
  CommTimeOuts.ReadIntervalTimeout := MAXDWORD;
  if not SeTCommTimeOuts(FhCommDev, CommTimeOuts) then
    ComError2('SeTKMCommTimeouts');
{$ENDIF}
end;

procedure TCommHandle.PurgeIn;
begin
  if Active then
    {$IFDEF LINUX}
    ioctl(integer(FhCommDev), TCFLSH, TCIFLUSH);
    {$ELSE}
    PurgeComm(FhCommDev, PURGE_RXABORT + PURGE_RXCLEAR);
    {$ENDIF}
end;

procedure TCommHandle.PurgeOut;
begin
  if Active then
    {$IFDEF LINUX}
    ioctl(integer(FhCommDev), TCFLSH, TCOFLUSH);
    {$ELSE}
    PurgeComm(FhCommDev, PURGE_TXABORT + PURGE_TXCLEAR);
    {$ENDIF}
end;

constructor TKMComm.Create;
begin
  inherited Create(AOwner);
  FDeviceName:= DefaultDeviceName;
end;

procedure TKMComm.SetDeviceName(const Value: string);
begin
  CheckInactive;
  FDeviceName := Value;
end;

procedure TKMComm.OpenConn;
begin
  if csDesigning in ComponentState then
    Exit;
  {$IFDEF LINUX}
  AcquireLock(fDeviceName);
  FhCommDev := THandle(Libc.open(PChar(fDeviceName), O_RDWR or O_NOCTTY or O_NONBLOCK));
  if FhCommDev = INVALID_HANDLE_VALUE then
    ReleaseLock(fDeviceName);
  {$ELSE}
  FhCommDev := CreateFile(PChar(FDeviceName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
  {$ENDIF}
  inherited;
end;

procedure TKMComm.CloseConn;
begin
  if csDesigning in ComponentState then
    Exit;
  {$IFDEF LINUX}
  if FhCommDev <> INVALID_HANDLE_VALUE then
    begin
      inherited;
      ReleaseLock(fDeviceName);
    end
  else
  {$ENDIF}
    inherited;
end;

{$IFDEF LINUX}
procedure AcquireLock(DeviceName: string);
var
  FName, S: string;
  f: TextFile;
begin
  FName:= _PATH_LOCK+'/LCK..'+ExtractFileName(DeviceName);
  ForceDirectories(_PATH_LOCK);
  // Check the Lockfile
  if FileExists (FName) then
  begin
    AssignFile(f, FName);
    Reset(f);
    Readln(f, S);
    CloseFile(f);
    // Is port owned by orphan? Then it's time for error recovery.
    if Libc.getsid(StrToIntDef(S, -1)) <> -1 then
      ComError(Format(sDeviceLocked, [DeviceName]));
  end;
  // comport is not locked or lockfile was left from former crash, lock it
  AssignFile(f, FName);
  Rewrite(f);
  writeln(f, Libc.getpid():10);
  CloseFile(f);
  // Allow all users to enjoy the benefits of cpom
  chmod(PChar(FName),  S_IRUSR or S_IWUSR or S_IRGRP or S_IWGRP or S_IROTH or S_IWOTH);
end;

procedure ReleaseLock(DeviceName: string);
begin
  DeleteFile(_PATH_LOCK+'/LCK..'+ExtractFileName(DeviceName));
end;

function GetTickCount;
var
  tms: TTimes;
begin
  Result:= times(tms)*1000 div CLK_TCK{tick->ms};
end;

type
{$IFNDEF VER140}
{$MESSAGE WARN 'Check TEvent object definiction in SyncObjs'}
{$ENDIF}
  TEvent2 = class(THandleObject)
  private
    FEvent: TSemaphore;
    FManualReset: Boolean;
    FEventCS: TCriticalSection;
  end;
{$ENDIF}

function Event_WaitFor(fEvent: TEvent; aTimeout: LongWord): TWaitResult;
{$IFDEF LINUX}
var
  I: Integer;
  Tick: LongWord;
{$ENDIF}
begin
{$IFDEF LINUX}
  if (aTimeout > 0) and (aTimeout < LongWord($FFFFFFFF)) then
    begin
      Result:= wrTimeout;
      Tick:= GetTickCount;
      repeat
        sem_getvalue(TEvent2(fEvent).fEvent, I);
        if I > 0 then
          begin
            Result := wrSignaled;
            if TEvent2(fEvent).FManualReset then
            begin
              TEvent2(fEvent).FEventCS.Enter;
              try
                { the event might have been signaled between the sem_wait above and now so we reset it again }
                fEvent.ResetEvent;
                fEvent.SetEvent;
              finally
                TEvent2(fEvent).FEventCS.Leave;
              end;
            end;
          end
        else
          sleep(1); { do not eat full CPU time }
      until (I > 0) or (LongWord(Abs(GetTickCount-Tick)) >= aTimeout);
    end
  else
    Result:= fEvent.WaitFor(aTimeout);
{$ELSE}
  Result:= fEvent.WaitFor(aTimeout);
{$ENDIF}
end;

const
  Bauds: array[br110..br256000] of Longint =
     (110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 56000, 57600, 115200, 128000, 256000);

function Int2BaudRate(BR1: Longint; var BR: TBaudRate): Boolean;
var
  I: TBaudRate;
begin
  Result:= False;
  for I:= Low(Bauds) to High(Bauds) do
    if Bauds[I] = BR1 then
    begin
      BR:= I;
      Result:= True;
      Break;
    end;
end;

function BaudRate2Int(BR: TBaudRate): Longint;
begin
  Result:= Bauds[BR];
end;


procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMComm]);
end;


end.



