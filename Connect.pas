(* Connect - connection components library
 * Copyright (C) 1999-2003  Tomas Mandys-MandySoft
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

unit Connect;
{HTX: -oProt}
{ Connect.htx }

interface
uses
  Classes, SysUtils {$IFDEF LINUX}, Libc, Types{$ELSE}, Windows{$ENDIF}, SyncObjs;

{ DONE 31.3.2003 Kylix compatability }

const
  lchNull = 0;  // fex. channel splitter
  lchOut = 1;
  lchIn = 2;
  lchError = 3;

  devNull = {$IFDEF LINUX}_PATH_DEVNULL{$ELSE}'NUL'{$ENDIF};
type
  TConnection = class;

  TConnectionNotifyEvent = procedure(DataSet: TConnection) of object;

  TConnection = class(TComponent)
  private
    FActive: Boolean;
    FStreamedActive: Boolean;
    FBeforeOpen, FBeforeClose, FAfterOpen, FAfterClose: TConnectionNotifyEvent;
    procedure SetActive(aEnable: Boolean);
  protected
    procedure OpenConn; virtual; abstract;
    procedure CloseConn; virtual; abstract;
    procedure DoBeforeOpen; virtual;
    procedure DoBeforeClose; virtual;
    procedure DoAfterOpen; virtual;
    procedure DoAfterClose; virtual;
    procedure Loaded; override;
    procedure CheckInactive;
    procedure CheckActive;
  public
    destructor Destroy; override;
    procedure Open;
    procedure Close;
  published
    property Active: Boolean read FActive write SetActive;

    property BeforeOpen: TConnectionNotifyEvent read FBeforeOpen write FBeforeOpen;
    property BeforeClose: TConnectionNotifyEvent read FBeforeClose write FBeforeClose;
    property AfterOpen: TConnectionNotifyEvent read FAfterOpen write FAfterOpen;
    property AfterClose: TConnectionNotifyEvent read FAfterClose write FAfterClose;
  end;

  TAcceptChannelEvent = procedure(Sender: TComponent; const aLogName: string; aChannel: Byte; var aAccept: Boolean) of object;

  TLogger = class(TConnection)
  private
    FCriticalSection: TCriticalSection;
    fAutoOpen: Boolean;
    procedure SetAutoOpen(aValue: Boolean);
  protected
    FAcceptChannel: TAcceptChannelEvent;
    procedure DoLog(aText: string); virtual; abstract;
    function PreformatText(const aName: string; aChannel: Byte; aText: string): string; virtual; abstract;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Log(const aName: string; aChannel: Byte; aText: string);
  published
    property AcceptChannel: TAcceptChannelEvent read FAcceptChannel write FAcceptChannel;
    property AutoOpen: Boolean read fAutoOpen write SetAutoOpen;
  end;

  TLogFormatFlag = (lfInsertName, lfInsertChannel, lfDivideNames, lfDivideChannels, lfDivideStream, lfHexadecimal, lfStamp, lfAutoCR);
  TLogFormatFlags = set of TLogFormatFlag;
  TOnDivideStream = procedure(Sender: TComponent; const aLogName: string; aChannel: Byte; var aText: string; var I: Integer; var aDivide: Boolean) of object;

  TStreamLogger = class(TLogger)
  private
    FLogStream: TStream;
    FLogFlags: TLogFormatFlags;
    FMaxLineLength: Integer;
    FLastChannel: Byte;
    FLastName: string;
    FLineLength: Integer;
    FOnDivideStream: TOnDivideStream;
    procedure SetLogStream(Value: TStream);
  protected
    procedure OpenConn; override;
    procedure DoLog(aText: string); override;
    function PreformatText(const aName: string; aChannel: Byte; aText: string): string; override;
    function DivideStream(const aName: string; aChannel: Byte; var aText: string; var I: Integer): Boolean; virtual;
  public
    constructor Create(aOwner: TComponent); override;
    property LogStream: TStream read FLogStream write SetLogStream;
  published
    property LogFlags: TLogFormatFlags read FLogFlags write FLogFlags;
    property MaxLineLength: Integer read FMaxLineLength write FMaxLineLength;
    property OnDivideStream: TOnDivideStream read FOnDivideStream write FOnDivideStream;
  end;

  TFileLogger = class(TStreamLogger)
  private
    FLogFile: TFileName;
    procedure SetLogFile(const aFile: TFileName);
  protected
    procedure OpenConn; override;
    procedure CloseConn; override;
  public
  published
    property LogFile: TFileName read FLogFile write SetLogFile;
  end;

  TFormatLogEvent = procedure(Sender: TComponent; aChannel: Byte; var aText: string) of object;

  TLogConnection = class(TConnection)
  private
    FLogger: TLogger;
    FOnFormatLog: TFormatLogEvent;
    FLogName: string;
  protected
    procedure DoFormatLog(aChannel: Byte; var aText: string); virtual;
  public
    procedure Log(aChannel: Byte; aText: string);
    procedure LogFromStream(aChannel: Byte; aStream: TStream);
  published
    property Logger: TLogger read FLogger write FLogger;
    property LogName: string read FLogName write FLogName;
    property OnFormatLog: TFormatLogEvent read FOnFormatLog write FOnFormatLog;
  end;

  TCommRxCharEvent = procedure(Sender: TObject; Count: Integer) of object;

  TCommunicationConnection = class(TLogConnection)
  private
    FOnRxChar: TCommRxCharEvent;
    FDontSynchronize: Boolean;
  public
    function Send(S: string): Integer;  { wait until not sent }
    function InQueCount: Integer; virtual; abstract;
    function Retrieve(aCount: Integer): string;
    procedure PurgeIn; virtual; abstract;
    procedure PurgeOut; virtual; abstract;
    property OnRxChar: TCommRxCharEvent read FOnRxChar write FOnRxChar;
    property DontSynchronize: Boolean read FDontSynchronize write FDontSynchronize;
  protected
    function Write({const}var Buf; Count: Integer): Integer; virtual; abstract;
    function Read(var Buf; Count: Integer): Integer; virtual; abstract;
    procedure DoOnRxChar(Count: Integer); virtual;
  end;

  EConnectError = class(Exception)
  end;

function  NowUTC: TDateTime;

procedure Register;

resourcestring
  sActiveConnection = 'Connection is active';
  sInactiveConnection = 'Connection is inactive';

implementation

procedure ComError(const Msg: string);
begin
  raise EConnectError.Create(Msg);
end;

function  NowUTC: TDateTime;
var
{$IFDEF LINUX}
  T: TTime_T;
  TV: TTimeVal;
  UT: TUnixTime;
{$ELSE}
  SystemTime: TSystemTime;
{$ENDIF}
begin
{$IFDEF LINUX}
  gettimeofday(TV, nil);
  T := TV.tv_sec;
  gmtime_r(@T, UT);
  Result := EncodeDate(UT.tm_year + 1900, UT.tm_mon + 1, UT.tm_mday) +
    EncodeTime(UT.tm_hour, UT.tm_min, UT.tm_sec, TV.tv_usec div 1000);
{$ELSE}
  GetSystemTime(SystemTime);
  with SystemTime do
    Result := EncodeDate(wYear, wMonth, wDay)+
              EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
{$ENDIF}
end;

destructor TConnection.Destroy;
begin
  Destroying;
  Close;
  inherited;
end;

procedure TConnection.Open;
begin
  Active:= True;
end;

procedure TConnection.Close;
begin
  Active:= False;
end;

procedure TConnection.SetActive;
begin
  if (csReading in ComponentState) then
  begin
    if aEnable then
      FStreamedActive := True;
  end
else
  if FActive <> aEnable then
  begin
    if aEnable then
      begin
        DoBeforeOpen;
        try
          OpenConn;
        except
          CloseConn;
          raise;
        end;
        FActive:= aEnable;
        DoAfterOpen;
      end
    else
      begin
        if not (csDestroying in ComponentState) then
          DoBeforeClose;
        CloseConn;
        FActive:= aEnable;
        if not (csDestroying in ComponentState) then
          DoAfterClose;
      end;
  end;
end;

procedure TConnection.DoBeforeOpen;
begin
  if Assigned(FBeforeOpen) then
    FBeforeOpen(Self);
end;

procedure TConnection.DoBeforeClose;
begin
  if Assigned(FBeforeClose) then
    FBeforeClose(Self);
end;

procedure TConnection.DoAfterOpen;
begin
  if Assigned(FAfterOpen) then
    FAfterOpen(Self);
end;

procedure TConnection.DoAfterClose;
begin
  if Assigned(FAfterClose) then
    FAfterClose(Self);
end;

procedure TConnection.Loaded;
begin
  inherited Loaded;
  if FStreamedActive then
    Active := True;
end;

procedure TConnection.CheckInactive;
begin
  if Active then
    ComError(sActiveConnection);
end;

procedure TConnection.CheckActive;
begin
  if not Active then
    ComError(sInactiveConnection);
end;

constructor TLogger.Create;
begin
  inherited;
  FCriticalSection:= TCriticalSection.Create;
end;

destructor TLogger.Destroy;
begin
  FCriticalSection.Free;
  inherited;
end;

procedure TLogger.SetAutoOpen(aValue: Boolean);
begin
  CheckInactive;
  fAutoOpen:= aValue;
end;

procedure TLogger.Log;     // multithreaded
var
  F, SaveActive: Boolean;
begin
  if (Self <> nil) and (FActive or FAutoOpen) then
  begin
    F:= True;
    if Assigned(FAcceptChannel) then
      FAcceptChannel(Self, aName, aChannel, F);
    if F then
    begin
      FCriticalSection.Enter;
      try
        SaveActive:= fActive;
        Open;
        try
          DoLog(PreformatText(aName, aChannel, aText));
        finally
          Active:= SaveActive;
        end;
      finally
        FCriticalSection.Leave;
      end;
    end;
  end;
end;

constructor TStreamLogger.Create;
begin
  inherited;
  FLogFlags:= [lfInsertName, lfInsertChannel, lfDivideNames, lfDivideChannels, lfHexadecimal];
  FMaxLineLength:= 80;
end;

procedure TStreamLogger.SetLogStream;
begin
  CheckInactive;
  FLogStream:= Value;
end;

procedure TStreamLogger.DoLog;
begin
  FLogStream.WriteBuffer(aText[1], Length(aText));
end;

procedure TStreamLogger.OpenConn;
begin
  if not (csDesigning in ComponentState) then
    FLogStream.Position:= FLogStream.Size;
end;

function TStreamLogger.DivideStream;
begin
  Result:= False;
  if Assigned(FOnDivideStream) then
    FOnDivideStream(Self, aName, aChannel, aText, I, Result);
end;

function TStreamLogger.PreformatText;
const
  CR = #13;
  LF = #10;
  CRLF = #13#10;
var
  I: Integer;
  F, NL: Boolean;
  function FormatCh(B: Byte): string;
  begin
    Result:= Format('%.2x)', [B]);
    if not (lfHexadecimal in FLogFlags) then
      Result:= Result+' ';
  end;
  procedure InsT(var S: string; const aT: string);
  begin
    S:= S+aT;
    Inc(FLineLength, Length(aT));
  end;
begin
  Result:= '';
  I:= 1;
  while I <= Length(aText) do
  begin
    NL:= FLineLength = 0;
    if (FLastName <> aName) and (lfDivideNames in FLogFlags) or
       (FLastChannel <> aChannel) and (lfDivideChannels in FLogFlags) or
       (lfDivideStream in FLogFlags) and DivideStream(aName, aChannel, aText, I) then
    begin
      FLineLength:= 0;
      NL:= False;
    end;
    F:= FLineLength = 0;
    if F then
    begin
      if not NL then
        Result:= Result+CRLF;
      if lfStamp in FLogFlags then
        InsT(Result, DateTimeToStr(Now)+')');
    end;
    if ((FLastName <> aName) or F) and (lfInsertName in FLogFlags) then
      begin
        InsT(Result, aName+'-');
        if lfInsertChannel in FLogFlags then
          InsT(Result, FormatCh(aChannel));
      end
    else
      begin
        if ((FLastChannel <> aChannel) or F) and (lfInsertChannel in FLogFlags) then
          InsT(Result, FormatCh(aChannel));
      end;
    FLastChannel:= aChannel;
    FLastName:= aName;

    if lfHexadecimal in FLogFlags then InsT(Result, Format('%.2x ', [Byte(aText[I])]))
                                  else InsT(Result, aText[I]);
    Inc(I);
    if (FMaxLineLength <> 0) and (FLineLength >= FMaxLineLength) then
    begin
      if I <= Length(aText) then
        Result:= Result+CRLF;
      FLineLength:= 0;    // write on next line
    end;
  end;
  if lfAutoCR in FLogFlags then
  begin
    Result:= Result+CRLF;
    FLineLength:=0;
  end;
  FLastChannel:= aChannel;
  FLastName:= aName;
end;

procedure TFileLogger.SetLogFile;
var
  SaveLogActive: Boolean;
begin
  if (csReading in ComponentState) then
  begin
    FLogFile:= aFile;
  end
else
  if aFile <> FLogFile then
  begin
    SaveLogActive:= Active;
    FActive:= False;
    FLogFile:= aFile;
    if FLogFile <> '' then
      Active:= SaveLogActive;
  end;
end;

procedure TFileLogger.OpenConn;
begin
  if not (csDesigning in ComponentState) then
  begin
    if not FileExists(LogFile) then
    begin
      with TFileStream.Create(LogFile, fmCreate) do
      try
      finally
        Free;
      end;
    end;
    FLogStream:= TFileStream.Create(LogFile, fmOpenWrite or fmShareDenyWrite);
  end;
  inherited;
end;

procedure TFileLogger.CloseConn;
begin
  FLogStream.Free;
end;

procedure TLogConnection.DoFormatLog;
begin
  if Assigned(FOnFormatLog) then
    FOnFormatLog(Self, aChannel, aText);
end;

procedure TLogConnection.Log;
begin
  DoFormatLog(aChannel, aText);
  if FLogger <> nil then
    FLogger.Log(FLogName, aChannel, aText);
end;

procedure TLogConnection.LogFromStream;
var
  SavePos: Int64;
  S: string;
begin
  SavePos:= aStream.Position;
  aStream.Position:= 0;
  SetLength(S, aStream.Size);
  if S <> '' then
    aStream.ReadBuffer(S[1], aStream.Size);
  aStream.Position:= SavePos;
  Log(aChannel, S);
end;

function TCommunicationConnection.Send;
begin
  Result:= Write(S[1], Length(S));
end;

function TCommunicationConnection.Retrieve;
begin
  SetLength(Result, aCount);  { alloc buffer }
  SetLength(Result, Read(Result[1], aCount));
end;

procedure TCommunicationConnection.DoOnRxChar;
begin
  if Assigned(FOnRxChar) then
    FOnRxChar(Self, Count);
end;

procedure Register;
begin
  RegisterComponents('Kamran Component', [TFileLogger]);
end;

end.

