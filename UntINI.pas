unit UntINI;

interface

uses
  SysUtils, WinProcs, Classes, Forms;

type
  TKMIniEditor = class(TComponent)
  private
    FFileName: string;
    FFilePath: string;
    FFileExtended: String;
    FKFilePath: string;
    procedure SetFileName(strFileName: string);
    procedure SetFileLocation();
    procedure AppendFilePath(var FullPath: string);
    procedure SetKFilePath(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FileName: string read FFileName write SetFileName;
    property KFilePath: string read FKFilePath write SetKFilePath;
    property FileExtended: string read FFileExtended write FFileExtended;
    procedure WriteBool(Section, Entry: string; Value: boolean);
    procedure WriteChar(Section, Entry: string; Value: char);
    procedure WriteInt(Section, Entry: string; Value: LongInt);
    procedure WriteReal(Section, Entry: string; Value: Extended);
    procedure WriteStr(Section, Entry, Value: string);
    procedure WriteWideStr(Section, Entry, Value: WideString);
    function ReadBool(Section, Entry: string; DefaultValue: boolean): boolean;
    function ReadChar(Section, Entry: string; DefaultValue: char): char;
    function ReadInt(Section, Entry: string; DefaultValue: LongInt): LongInt;
    function ReadReal(Section, Entry: string; DefaultValue: Extended): Extended;
    function ReadStr(Section, Entry, DefaultValue: string): string;
    function ReadWideStr(Section, Entry, DefaultValue: WideString;WideStringSize:integer=1000): WideString;
    procedure EraseSection(Section: string);
    procedure EraseEntry(Section, Entry: string);
  end;

procedure Register;

implementation

constructor TKMIniEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFileName := '';
  FFileExtended:='ini';
end;

procedure TKMIniEditor.SetFileName(strFileName: string);
begin
  if strFileName <> FFileName then
    FFileName := strFileName;
end;

procedure TKMIniEditor.SetKFilePath(const Value: string);
begin
  FKFilePath := Value;
end;

procedure TKMIniEditor.SetFileLocation();
var
  i: integer;
  szPath: PChar;
  strPath: string;
begin
  //if Location <> FFileLocation then
  //  FFileLocation := Location;
  //if FFileLocation = ApplicationPath then
  begin
    {Set path to the application. Data files will be in DATA directory below application}
    strPath := Application.ExeName;
    i := Length(strPath);
    while (i >= 1) and (strPath[i] <> '\') do
      dec(i);
    FFilePath := Copy(strPath,1,i);
  end ;
//  else
//  if FFileLocation = WindowsPath then
//  begin
//    szPath := StrAlloc(144);
//    GetWindowsDirectory(szPath, 144);
//    FFilePath := StrPas(szPath);
//    if FFilePath[Length(FFilePath)] <> '\' then
//      FFilePath := FFilePath + '\';
//    StrDispose(szPath);
//  end
//  else
//    FFilePath := '';


//  if FFileLocationStr<>''  then
    FFilePath:=FFilePath+'INI\' ;

end;



function StrToBool(strVal: string): boolean;
begin
  if (UpperCase(strVal) = 'TRUE') or (UpperCase(strVal) = 'YES') or (strVal = '1') then
    Result := True
  else
    Result := False;
end;

function BoolToStr(bVal: boolean): string;
begin
  if bVal then
    Result := 'True'
  else
    Result := 'False';
end;

procedure TKMIniEditor.WriteBool(Section, Entry: string; Value: boolean);
begin
  WriteStr(Section, Entry, BoolToStr(Value));
end;

function TKMIniEditor.ReadBool(Section, Entry: string; DefaultValue: boolean): boolean;
var
  iniStrVal: string;
begin
  iniStrVal := ReadStr(Section, Entry, BoolToStr(DefaultValue));
  result := StrToBool(iniStrVal);
end;

procedure TKMIniEditor.WriteChar(Section, Entry: string; Value: char);
begin
  WriteStr(Section, Entry, Value);
end;

function TKMIniEditor.ReadChar(Section, Entry: string; DefaultValue: char): char;
var
  iniVal: string;
begin
  iniVal := DefaultValue;
  iniVal := ReadStr(Section, Entry, DefaultValue);
  result := iniVal[1];
end;

procedure TKMIniEditor.WriteReal(Section, Entry: string; Value: Extended);
begin
  WriteStr(Section, Entry, FormatFloat('',Value));
end;

procedure TKMIniEditor.WriteInt(Section, Entry: string; Value: LongInt);
begin
  WriteStr(Section, Entry, IntToStr(Value));
end;

function TKMIniEditor.ReadReal(Section, Entry: string; DefaultValue: Extended): Extended;
var
  StrValue: string;
  strDefault: string;
begin
  try
    strDefault := FloatToStr(DefaultValue);
    StrValue := ReadStr(Section, Entry, StrDefault);
    result := StrToFloat(strValue);
  except
    result := DefaultValue;
  end;
end;

function TKMIniEditor.ReadInt(Section, Entry: string; DefaultValue: LongInt): LongInt;
begin
  try
    result := Trunc(ReadReal(Section, Entry, DefaultValue));
  except
    result := DefaultValue;
  end;
end;

procedure TKMIniEditor.EraseSection(Section: string);
begin
  WriteStr(Section, '', '');
end;

procedure TKMIniEditor.EraseEntry(Section, Entry: string);
begin
  WriteStr(Section, Entry, '');
end;

procedure TKMIniEditor.AppendFilePath(var FullPath: string);
begin
  if FKFilePath='' then
    FFilePath:='INI\'
  else
    FFilePath:=FKFilePath+'\' ;
  if (FFilePath = '') or (FFileName[2] = ':') then
    FullPath := FFileName
  else
  if FFileName[1] = '\' then
    FullPath := FFilePath + Copy(FFileName, 2, Length(FFileName)-1)
  else
    FullPath := FFilePath + FFileName;
  if Pos('.',FullPath) = 0 then
    FullPath := FullPath + '.'+FFileExtended;
end;

procedure TKMIniEditor.WriteStr(Section, Entry, Value: string);
var
  szEntry, szFile, szSection, szValue: PChar;
  Path: string;
begin
  if (Section <> '') and (FFileName <> '') then
  begin
    { Allocate some memory for PChars }
    szSection := StrAlloc(256);
    szEntry := StrAlloc(256);
    szValue := StrAlloc(256);
    szFile := StrAlloc(256);
    try
      { Add path and filename }
      AppendFilePath(Path);
      { Copy our properties into the PChars }
      StrPCopy(szFile, Path);
      StrPCopy(szSection, Section);
      StrPCopy(szEntry, Entry);
      if Value = '' then
      begin
        if Entry = '' then
          {Erase Entry by passing NIL for its value.}
          WritePrivateProfileString(szSection, NIL, NIL, szFile)
        else
          {Erase Entry by passing NIL for its value.}
          WritePrivateProfileString(szSection, szEntry, NIL, szFile);
      end
      else
      begin
        StrPCopy(szValue, Value);
        WritePrivateProfileString(szSection, szEntry, szValue, szFile);
      end;
    finally
      StrDispose(szEntry);
      StrDispose(szFile);
      StrDispose(szSection);
      StrDispose(szValue);
    end;
  end;
end;

function TKMIniEditor.ReadStr(Section, Entry, DefaultValue: string): string;
var
  Path: string;
  szSection, szEntry, szDefaultValue, szValue, szFile: PChar;
begin
  if (Section <> '') and (Entry <> '') and (FFileName <> '') then
  begin
    { Allocate some memory for PChars }
    szSection := StrAlloc(256);
    szEntry := StrAlloc(256);
    szDefaultValue := StrAlloc(256);
    szValue := StrAlloc(256);
    szFile := StrAlloc(256);
    try
      { Add path and filename }
      AppendFilePath(Path);
      { Copy our properties into the PChars }
      StrPCopy(szFile, Path);
      StrPCopy(szSection, Section);
      StrPCopy(szEntry, Entry);
      StrPCopy(szDefaultValue, DefaultValue);
      { Read the profile string }
      GetPrivateProfileString(szSection, szEntry, szDefaultValue, szValue, 256, szFile);
      Result := StrPas(szValue);
    finally
      StrDispose(szSection);
      StrDispose(szEntry);
      StrDispose(szValue);
      StrDispose(szDefaultValue);
      StrDispose(szFile);
    end;
  end
  else
  begin
    Result := DefaultValue;
  end;
end;

function TKMIniEditor.ReadWideStr(Section, Entry,
  DefaultValue: WideString;WideStringSize:integer=1000): WideString;
var
  Path: string;
  szSection, szEntry, szDefaultValue, szValue, szFile: PChar;
begin
  if (Section <> '') and (Entry <> '') and (FFileName <> '') then
  begin
    { Allocate some memory for PChars }
    szSection := StrAlloc(256);
    szEntry := StrAlloc(256);
    szFile := StrAlloc(256);
    szDefaultValue := StrAlloc(length(DefaultValue));
    szValue := StrAlloc(WideStringSize);
    try
      { Add path and filename }
      AppendFilePath(Path);
      { Copy our properties into the PChars }
      StrPCopy(szFile, Path);
      StrPCopy(szSection, Section);
      StrPCopy(szEntry, Entry);
      StrPCopy(szDefaultValue, DefaultValue);
      { Read the profile string }
      GetPrivateProfileString(szSection, szEntry, szDefaultValue, szValue, WideStringSize, szFile);
      Result := StrPas(szValue);
    finally
      StrDispose(szSection);
      StrDispose(szEntry);
      StrDispose(szValue);
      StrDispose(szDefaultValue);
      StrDispose(szFile);
    end;
  end
  else
  begin
    Result := DefaultValue;
  end;
end;
procedure TKMIniEditor.WriteWideStr(Section, Entry, Value: WideString);
var
  szEntry, szFile, szSection, szValue: PChar;
  Path: string;
begin
  if (Section <> '') and (FFileName <> '') then begin
    { Allocate some memory for PChars }
    szSection := StrAlloc(256);
    szEntry := StrAlloc(256);
    szFile := StrAlloc(256);
    szValue := StrAlloc(length(Value)+10);
    try
      { Add path and filename }
      AppendFilePath(Path);
      { Copy our properties into the PChars }
      StrPCopy(szFile, Path);
      StrPCopy(szSection, Section);
      StrPCopy(szEntry, Entry);
      if Value = '' then begin
        if Entry = '' then
          {Erase Entry by passing NIL for its value.}
          WritePrivateProfileString(szSection, NIL, NIL, szFile)
        else
          {Erase Entry by passing NIL for its value.}
          WritePrivateProfileString(szSection, szEntry, NIL, szFile);
      end else begin
        StrPCopy(szValue, Value);
        WritePrivateProfileString(szSection, szEntry, szValue, szFile);
      end;
    finally
      StrDispose(szEntry);
      StrDispose(szFile);
      StrDispose(szSection);
      StrDispose(szValue);
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMIniEditor]);
end;

end.
