{*************************************************************}
{            DiskInfo component for Delphi 32                 }
{ Version:   2.0                                              }
{ E-Mail:    info@utilmind.com                                }
{ WWW:       http://www.utilmind.com                          }
{ Created:   May, 4, 1999                                     }
{ Modified:  June, 11, 2000                                   }
{ Legal:     Copyright (c) 1999-2000, UtilMind Solutions      }
{*************************************************************}
{  TDiskInfo:                                                 }
{ Component determines the information about specified local  }
{ or a network disk - Serial number, Volume label, type of    }
{ file system, type of a disk, size of disk and free space.   }
{                                                             }
{  REMARK for Delphi 2 and 3                                  }
{ The DiskSize and DiskFree properties returns incorrect      }
{ values for volumes that are larger than 2 gigabytes (FAT32  }
{ file system) because Delphi 2 and 3 don't support 64-bit    }
{ integer operations.                                         }
{*************************************************************}
{ PROPERTIES:                                                 }
{   Disk: Char - Drive letter                                 }
{                                                             }
{ READ-ONLY PROPERTIES (results)                              }
{   SerialNumberStr: String                                   }
{   SerialNumber: LongInt                                     }
{   VolumeLabel: String                                       }
{   FileSystem: String                                        }
{   DriveType: TDriveType                                     }
{   DiskSize: Int64 (DWord in Delphi 2 and 3)                 }
{   DiskFree: Int64 (DWord in Delphi 2 and 3)                 }
{*************************************************************}
{ Please see demo program for more information.               }
{*************************************************************}
{                     IMPORTANT NOTE:                         }
{ This software is provided 'as-is', without any express or   }
{ implied warranty. In no event will the author be held       }
{ liable for any damages arising from the use of this         }
{ software.                                                   }
{ Permission is granted to anyone to use this software for    }
{ any purpose, including commercial applications, and to      }
{ alter it and redistribute it freely, subject to the         }
{ following restrictions:                                     }
{ 1. The origin of this software must not be misrepresented,  }
{    you must not claim that you wrote the original software. }
{    If you use this software in a product, an acknowledgment }
{    in the product documentation would be appreciated but is }
{    not required.                                            }
{ 2. Altered source versions must be plainly marked as such,  }
{    and must not be misrepresented as being the original     }
{    software.                                                }
{ 3. This notice may not be removed or altered from any       }
{    source distribution.                                     }
{*************************************************************}


unit UntDISKINFO;

interface

uses
    shellapi,mmsystem,Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

Const
  FPU_FLAG = $00000001; // Floating-Point unit on chip
  VME_FLAG = $00000002; // Virtual Mode Extention
   DE_FLAG = $00000004; // Debugging Extention
  PSE_FLAG = $00000008; // Page Size Extention
  TSC_FLAG = $00000010; // Time Stamp Counter
  MSR_FLAG = $00000020; // Model Specific Registers
  PAE_FLAG = $00000040; // Physical Address Extention
  MCE_FLAG = $00000080; // Machine Check Exception
  CX8_FLAG = $00000100; // CMPXCHG8 Instruction
 APIC_FLAG = $00000200; // Software-accessible local APIC on Chip
  BIT_10   = $00000400; // Reserved, do not count on value
  SEP_FLAG = $00000800; // Fast System Call
 MTRR_FLAG = $00001000; // Memory Type Range Registers
  PGE_FLAG = $00002000; // Page Global Enable
  MCA_FLAG = $00004000; // Machine Check Architecture
 CMOV_FLAG = $00008000; // Conditional Move Instruction
  BIT_16   = $00010000; // Reserved, do not count on value
  BIT_17   = $00020000; // Reserved, do not count on value
  BIT_18   = $00040000; // Reserved, do not count on value
  BIT_19   = $00080000; // Reserved, do not count on value
  BIT_20   = $00100000; // Reserved, do not count on value
  BIT_21   = $00200000; // Reserved, do not count on value
  BIT_22   = $00400000; // Reserved, do not count on value
  MMX_FLAG = $00800000; // MMX technology
  BIT_24   = $01000000; // Reserved, do not count on value
  BIT_25   = $02000000; // Reserved, do not count on value
  BIT_26   = $04000000; // Reserved, do not count on value
  BIT_27   = $08000000; // Reserved, do not count on value
  BIT_28   = $10000000; // Reserved, do not count on value
  BIT_29   = $20000000; // Reserved, do not count on value
  BIT_30   = $40000000; // Reserved, do not count on value
  BIT_31   = $80000000; // Reserved, do not count on value




type
  Freq_info = Record
    Raw_Freq: Cardinal;       // Raw frequency of CPU in MHz.
    Norm_Freq: Cardinal;      // Normalized frequency of CPU in MHz.
    In_Cycles: Cardinal;      // Internal clock cycles during test
    Ex_Ticks: Cardinal;       // Microseconds elapsed during test
  end;

  TCpuInfo = Record
    VendorIDString: String;
    Manufacturer: String;
    CPU_Name: String;
    PType: Byte;
    Family: Byte;
    Model: Byte;
    Stepping: Byte;
    Features: Cardinal;
    MMX: Boolean;
    Frequency_Info: Freq_Info;
    IDFDIVOK: Boolean;
end ;
type
  TDriveType = (dtUnknown, dtNoDrive, dtFloppy, dtFixed, dtNetwork, dtCDROM, dtRAM);
  TDragDropEvent=procedure(files:tstringlist) of object;
  TBetriebsSystem=(bsWin95,bsWinNT,bsWin32);
  TKMDiskInfo = class(TComponent)


  private
     FDisk: Char;
     FSerialNumberStr: String;
     FSerialNumber: LongInt;
     FVolumeLabel: String;
     FFileSystem: String;
     FDriveType: TDriveType;
     FDiskSize: Int64;
     FDiskFree: Int64;
     FOnDragDrop:TDragDropEvent;
     FFiles:TStringList;
     FHide:boolean;





     
     procedure Appmessage(var Msg:tmsg; var handled:boolean);
     procedure SetHide(status:boolean);
     procedure SetDisk(Value: Char);
     procedure SetNothing(Value: String);
     procedure SetNothingLong(Value: LongInt);
     procedure SetNothingInt64(Value: Int64);
     procedure SetNothingDT(Value: TDriveType);

  public
     function GetColorCount:Integer ;
     function getAvailPhysMemory:longint;
     function getTotalPageFile:longint;
     function getAvailPageFile:longint;
     function getwindowsdirectory:string;
     function getSystemdirectory:string;
     function getUsername:string;
     function getComputername:string;
     function GetCPUSpeed: Freq_Info;
     function CPUID: TCpuInfo;
     function TestFDIVInstruction: Boolean;
     function getprocessorType:string;
     function getprocessorcount:integer;
     function getsystem:tBetriebssystem;
     function getTotalPhysMemory:longint;
     function sound:boolean;
     function diskindrive(lw:char;statusanzeige:boolean):boolean;
     function disktyp(lw:char):string;
     function diskserialnumber(lw:char):integer;
     function diskfilesystem(lw:char):string;
     function disknamelength(lw:char):integer;
     function diskfreespace(lw:char):int64;
     function disktotalspace(lw:char):int64;
     function setComputername(name:string):boolean;
     procedure GetCPUInfo(Var CPUInfo: TCpuInfo);
     procedure shutdown;
     procedure reboot;
     procedure logoff;
     
     
  published
   constructor Create(aOwner: TComponent); override;
     property Disk: Char read FDisk write SetDisk;
     property SerialNumberStr: String read FSerialNumberStr write SetNothing;
     property SerialNumber: LongInt read FSerialNumber write SetNothingLong;
     property VolumeLabel: String read FVolumeLabel write SetNothing;
     property FileSystem: String read FFileSystem write SetNothing;
     property DriveType: TDriveType read FDriveType write SetNothingDT;
     property DiskSize: Int64 read FDiskSize write SetNothingInt64;
     property DiskFree: Int64 read FDiskFree write SetNothingInt64;
     property OnDragDrop:TDragDropEvent read FOnDragDrop write FOnDragDrop;
     property Hide:boolean read FHide write SetHide;








     property AvailPhysmemory:longint read getavailphysmemory ;
     property totalPageFile:longint read gettotalPageFile;
     property AvailPageFile:longint read getAvailPageFile ;
     property windowsdirectory:string read getwindowsdirectory ;
     property Systemdirectory:string read getSystemdirectory ;
     property Username:string read getUsername ;
     property Computername:string read getComputername;
     property Processortype:string read getProcessortype;
     property Processorcount:integer read getProcessorcount ;
     property system:TBetriebsSystem read getsystem ;


  end;

procedure Register;

implementation

constructor TKMDiskInfo.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FFiles:=TStringlist.create;
  DragAcceptFiles((AOwner as Tform).handle,true);
  DraGAcceptFiles(Application.handle,true);
  application.onmessage:=appmessage;
  Disk := 'C';
end;

procedure TKMDiskInfo.SetDisk(Value: Char);
var
  VolumeLabel, FileSystem: Array[0..$FF] of Char;
  SerialNumber, DW, SysFlags: DWord;

  function DecToHex(aValue: LongInt): String;
  var
    w: Array[1..2] of Word absolute aValue;

    function HexByte(b: Byte): String;
    const
      Hex: Array[$0..$F] of Char = '0123456789ABCDEF';
    begin
      HexByte := Hex[b shr 4] + Hex[b and $F];
    end;

    function HexWord(w: Word): String;
    begin
      HexWord := HexByte(Hi(w)) + HexByte(Lo(w));
    end;

  begin
    Result := HexWord(w[2]) + HexWord(w[1]);
  end;

begin
  Value := UpCase(Value);
  if (Value >= 'A') and (Value <= 'Z') then
   begin
    FDisk := Value;
    GetVolumeInformation(PChar(Value + ':\'), VolumeLabel, SizeOf(VolumeLabel),
                         @SerialNumber, DW, SysFlags,
                         FileSystem, SizeOf(FileSystem));
    FSerialNumber := SerialNumber;
    FSerialNumberStr := DecToHex(SerialNumber);
    Insert('-', FSerialNumberStr, 5);
    FVolumeLabel := VolumeLabel;
    FFileSystem := FileSystem;
    FDriveType := TDriveType(GetDriveType(PChar(Value + ':\')));

    FDiskSize := SysUtils.DiskSize(Byte(Value) - $40);
    FDiskFree := SysUtils.DiskFree(Byte(Value) - $40);
   end
end;

procedure TKMDiskInfo.SetNothing(Value: String);
begin

end;
procedure TKMDiskInfo.SetNothingLong(Value: LongInt);
begin {}
end;
procedure TKMDiskInfo.SetNothingInt64(Value: Int64);
begin {}
end;
procedure TKMDiskInfo.SetNothingDT(Value: TDriveType);
begin {}
end;
function TKMDiskInfo.GetColorCount:Integer;
begin
  GetColorCount:=1 SHL getDeviceCaps(GetDC(0),bitspixel);
end;

procedure TKMDiskInfo.sethide(status:boolean);
begin
     fhide:=status;
     if status then
        showwindow(application.handle,sw_hide)
     else
         showwindow(application.handle,sw_show);
end;


procedure TKMDiskInfo.GetCPUInfo(Var CPUInfo: TCpuInfo);
begin
  CPUInfo := CPUID;
  CPUInfo.IDFDIVOK := TestFDIVInstruction;
  iF (CPUInfo.Features and TSC_FLAG = TSC_FLAG) then
     CPUInfo.Frequency_Info := GetCPUSpeed;
  if (CPUInfo.Features and MMX_FLAG) = MMX_FLAG then
     CPUInfo.MMX := True
  else
    CPUInfo.MMX := False;
end;

function TKMDiskInfo.GetCPUSpeed: Freq_Info;
var
  Cpu_Speed: Freq_Info;
  t0, t1: Int64;
  freq, freq2, freq3, Total: Cardinal;
  Total_Cycles, Cycles: Cardinal;
  Stamp0, Stamp1: Cardinal;
  Total_Ticks, Ticks: Cardinal;
  Count_Freq: Int64;
  Tries, IPriority, hThread: Integer;
begin
  freq  := 0;
  freq2 := 0;
  freq3 := 0;
  tries := 0;
  total_cycles := 0;
  total_ticks := 0;
  Total := 0;
  hThread := GetCurrentThread();
  if (not QueryPerformanceFrequency(count_freq)) then
    begin
      Result := cpu_speed;
    end
  else
    begin
      while ((tries < 3 ) or ((tries < 20) and ((abs(3 * freq - total) > 3) or
             (abs(3 * freq2-total) > 3) or (abs(3 * freq3-total) > 3)))) do
      begin
        inc(tries);
        freq3 := freq2;
        freq2 := freq;
        QueryPerformanceCounter(t0);
        t1 := t0;
        iPriority := GetThreadPriority(hThread);
        if ( iPriority <> THREAD_PRIORITY_ERROR_RETURN ) then
          begin
             SetThreadPriority(hThread, THREAD_PRIORITY_TIME_CRITICAL);
          end;
        while (( t1 - t0) < 50) do
        begin
           QueryPerformanceCounter(t1);
//           asm
//              push eax
//              push edx
//              db   0Fh        // Read Time
//              db   31h        // Stamp Counter
//              MOV stamp0, EAX
//              pop  edx
//              pop  eax
//           end;
        end;
        t0 := t1;
        while ((t1 - t0) < 1000) do
        begin
          QueryPerformanceCounter(t1);
//          asm
//            push eax
//            push edx
//            db   0Fh // Read Time
//            db   31h // Stamp Counter
//            MOV stamp1, EAX
//            pop  edx
//            pop  eax
//          end;
        end;
        if ( iPriority <> THREAD_PRIORITY_ERROR_RETURN ) then
        begin
          SetThreadPriority(hThread, iPriority);
        end;
        cycles := stamp1 - stamp0;
        ticks :=  t1 - t0;
        ticks := ticks * 100000;
        ticks := Round(Ticks / (count_freq/10));
        total_ticks := Total_Ticks + ticks;
        total_cycles := Total_Cycles + cycles;
        freq := Round(cycles / ticks);
        total := (freq + freq2 + freq3);
      end;
      freq3 := Round((total_cycles * 10) / total_ticks);
      freq2 := Round((total_cycles * 100) / total_ticks);
      if (freq2 - (freq3 * 10) >= 6) then
        inc(freq3);
      cpu_speed.raw_freq := Round(total_cycles / total_ticks);
      cpu_speed.norm_freq := cpu_speed.raw_freq;
      freq := cpu_speed.raw_freq * 10;
      if((freq3 - freq) >= 6) then
        inc(cpu_speed.norm_freq);
      cpu_speed.ex_ticks := total_ticks;
      cpu_speed.in_cycles := total_cycles;
      Result := cpu_speed;
    end;
end;

Function TKMDiskInfo.CPUID: TCpuInfo;
type
    regconvert = record
          bits0_7: Byte;
          bits8_15: Byte;
          bits16_23: Byte;
          bits24_31: Byte;
    end;
var
   CPUInfo: TCpuInfo;
   TEBX, TEDX, TECX: Cardinal;
   TString: String;
   VString: String;
begin
//     asm
//        MOV  [CPUInfo.PType], 0
//        MOV  [CPUInfo.Model], 0
//        MOV  [CPUInfo.Stepping], 0
//        MOV  [CPUInfo.Features], 0
//        MOV  [CPUInfo.Frequency_Info.Raw_Freq], 0
//        MOV  [CPUInfo.Frequency_Info.Norm_Freq], 0
//        MOV  [CPUInfo.Frequency_Info.In_Cycles], 0
//        MOV  [CPUInfo.Frequency_Info.Ex_Ticks], 0
//
//        push eax
//        push ebp
//        push ebx
//        push ecx
//        push edi
//        push edx
//        push esi
//
//     @@Check_80486:
//        MOV  [CPUInfo.Family], 4
//        MOV  TEBX, 0
//        MOV  TEDX, 0
//        MOV  TECX, 0
//        PUSHFD
//        POP  EAX
//        MOV  ECX,  EAX
//        XOR  EAX,  200000H
//        PUSH EAX
//        POPFD
//        PUSHFD
//        POP  EAX
//        XOR  EAX,  ECX
//        JE   @@DONE_CPU_TYPE
//
//     @@Has_CPUID_Instruction:
//        MOV  EAX,  0
//        DB   0FH
//        DB   0A2H
//
//        MOV  TEBX, EBX
//        MOV  TEDX, EDX
//        MOV  TECX, ECX
//
//        MOV  EAX,  1
//        DB   0FH
//        DB   0A2H
//
//        MOV  [CPUInfo.Features], EDX
//
//        MOV  ECX,  EAX
//
//        AND  EAX,  3000H
//        SHR  EAX,  12
//        MOV  [CPUInfo.PType], AL
//
//        MOV  EAX,  ECX
//
//        AND  EAX,  0F00H
//        SHR  EAX,  8
//        MOV  [CPUInfo.Family], AL
//
//        MOV  EAX,  ECX
//
//        AND  EAX,  00F0H
//        SHR  EAX,  4
//        MOV  [CPUInfo.MODEL], AL
//
//        MOV  EAX,  ECX
//
//        AND  EAX,  000FH
//        MOV  [CPUInfo.Stepping], AL
//
//     @@DONE_CPU_TYPE:
//
//        pop  esi
//        pop  edx
//        pop  edi
//        pop  ecx
//        pop  ebx
//        pop  ebp
//        pop  eax
//     end;

     If (TEBX = 0) and (TEDX = 0) and (TECX = 0) and (CPUInfo.Family = 4) then
     begin
          CPUInfo.VendorIDString := 'Unknown';
          CPUInfo.Manufacturer := 'Unknown';
          CPUInfo.CPU_Name := 'Generic 486';
     end
     else
     begin
          With regconvert(TEBX) do
          begin
               TString := CHR(bits0_7) + CHR(bits8_15) + CHR(bits16_23) + CHR(bits24_31);
          end;
          With regconvert(TEDX) do
          begin
               TString := TString + CHR(bits0_7) + CHR(bits8_15) + CHR(bits16_23) + CHR(bits24_31);
          end;
          With regconvert(TECX) do
          begin
               TString := TString + CHR(bits0_7) + CHR(bits8_15) + CHR(bits16_23) + CHR(bits24_31);
          end;
          VString := TString;
          CPUInfo.VendorIDString := TString;
          If (CPUInfo.VendorIDString = 'GenuineIntel') then
          begin
               CPUInfo.Manufacturer := 'Intel';
               Case CPUInfo.Family of
               4: Case CPUInfo.Model of
                  1: CPUInfo.CPU_Name := 'Intel 486DX Processor';
                  2: CPUInfo.CPU_Name := 'Intel 486SX Processor';
                  3: CPUInfo.CPU_Name := 'Intel DX2 Processor';
                  4: CPUInfo.CPU_Name := 'Intel 486 Processor';
                  5: CPUInfo.CPU_Name := 'Intel SX2 Processor';
                  7: CPUInfo.CPU_Name := 'Write-Back Enhanced Intel DX2 Processor';
                  8: CPUInfo.CPU_Name := 'Intel DX4 Processor';
                  else CPUInfo.CPU_Name := 'Intel 486 Processor';
                  end;
               5: CPUInfo.CPU_Name := 'Pentium';
               6: Case CPUInfo.Model of
                  1: CPUInfo.CPU_Name := 'Pentium Pro';
                  3: CPUInfo.CPU_Name := 'Pentium II';
                  else CPUInfo.CPU_Name := Format('P6 (Model %d)', [CPUInfo.Model]);
                  end;
               else CPUInfo.CPU_Name := Format('P%d', [CPUInfo.Family]);
               end;
          end
          else if (CPUInfo.VendorIDString = 'CyrixInstead') then
          begin
                CPUInfo.Manufacturer := 'Cyrix';
                Case CPUInfo.Family of
                5: CPUInfo.CPU_Name := 'Cyrix 6x86';
                6: CPUInfo.CPU_Name := 'Cyrix M2';
                else CPUInfo.CPU_Name := Format('%dx86', [CPUInfo.Family]);
                end;
          end
          else if (CPUInfo.VendorIDString = 'AuthenticAMD') then
          begin
               CPUInfo.Manufacturer := 'AMD';
               Case CPUInfo.Family of
               4: CPUInfo.CPU_Name := 'Am486 or Am5x86';
               5: Case CPUInfo.Model of
                  0: CPUInfo.CPU_Name := 'AMD-K5 (Model 0)';
                  1: CPUInfo.CPU_Name := 'AMD-K5 (Model 1)';
                  2: CPUInfo.CPU_Name := 'AMD-K5 (Model 2)';
                  3: CPUInfo.CPU_Name := 'AMD-K5 (Model 3)';
                  6: CPUInfo.CPU_Name := 'AMD-K6';
                  else CPUInfo.CPU_Name := 'Unknown AMD Model';
                  end;
               else CPUInfo.CPU_Name := 'Unknown AMD Chip';
               end;
          end
          else
          begin
               CPUInfo.VendorIDString := TString;
               CPUInfo.Manufacturer := 'Unknown';
               CPUInfo.CPU_Name := 'Unknown';
          end;
     end;
     Result := CPUInfo;
end;

Function TKMDiskInfo.TestFDIVInstruction: Boolean;
var
   TopNum:    Double;
   BottomNum: Double;
   One:       Double;
   ISOK:      Boolean;
begin
     { The following code was found in Borlands
       fdiv.asm file in the Delphi 3\Source\RTL\SYS
       directory, ( I made some minor modifications )
       therefor I cannot take credit for it }

     TopNum     := 2658955;
     BottomNum  := PI;
     One        := 1;

//     asm
//        PUSH    EAX
//        FLD     [TopNum]
//        FDIV    [BottomNum]
//        FMUL    [BottomNum]
//        FSUBR   [TopNum]
//        FCOMP   [One]
//        FSTSW   AX
//        SHR     EAX, 8
//        AND     EAX, 01H
//        MOV     ISOK, AL
//        POP     EAX
//     end;
     Result := ISOK;
end;

procedure TKMDiskInfo.Appmessage(var MSG:tmsg;var handled:boolean);
var
   i:integer;
   anzahl:word;
   Pfilename:Pchar;
begin
     {if msg.message=WM_DROPFILES then begin
     PFilename:=stralloc(255);
     FFILES.clear;
     anzahl:=DRagQueryFile(MSG.Wparam,$FFFFFFFF,PFilename,255);
     for i:=0 to (anzahl-1) do begin
         DragQueryFile(MSG.WPARAM,i,Pfilename,255);
         FFiles.add(STRPAS(PFilename));
     end;
     DragFinish(Msg.wparam);
     handled:=true;
     if assigned(Fondragdrop) then Fondragdrop(FFiles);
     strdispose(pFilename);
end; }
end;

function TKMDiskInfo.gettotalphysmemory:Longint;
var
memory:TMEMORYSTATUS;
begin
     globalmemorystatus(memory);
     gettotalphysmemory:=memory.dwtotalphys;
end;

function TKMDiskInfo.getavailphysmemory:longint;
var
memory:TMEMORYSTATUS;
begin
     globalmemorystatus(memory);
     getavailphysmemory:=memory.dwavailphys;
end;

function TKMDiskInfo.gettotalpagefile:longint;
var
memory:TMEMORYSTATUS;
begin
     globalmemorystatus(memory);
     gettotalpagefile:=memory.dwtotalpagefile;
end;

function TKMDiskInfo.getavailpagefile:longint;
var
memory:TMEMORYSTATUS;
begin
     globalmemorystatus(memory);
     getavailpagefile:=memory.dwavailpagefile;
end;
function TKMDiskInfo.getwindowsdirectory:string;
var
p:Pchar;
begin
     p:=stralloc(MAX_PATH+1);
     windows.getwindowsdirectory(p,max_path+1);
     getwindowsdirectory:=p;
     strdispose(p);
end;


function TKMDiskInfo.getSystemdirectory:string;
var
p:Pchar;
begin
     p:=stralloc(MAX_PATH+1);
     windows.getSystemdirectory(p,max_path+1);
     getsystemdirectory:=p;
     strdispose(p);
end;

function TKMDiskInfo.getusername:string;
var
p:Pchar;
size:Dword;
begin
     size:=1024;
     p:=stralloc(size);
     windows.getusername(p,size);
     getusername:=p;
     strdispose(p);
end;

function TKMDiskInfo.getcomputername:string;
var
p:Pchar;
size:Dword;
begin
     size:=MAX_COMPUTERNAME_LENGTH+1;
     p:=stralloc(size);
     windows.getcomputername(p,size);
     getcomputername:=p;
     strdispose(p);
end;

function TKMDiskInfo.getprocessortype:string;
var
   systeminfo:TSysteminfo;
   zw:string;
begin
     geTSysteminfo(systeminfo);
     case systeminfo.dwprocessortype of
          386:zw:='Intel 80386';
          486:zw:='Intel 80486';
          586:zw:='Intel Pentium';
          860:zw:='Intel 860';
          2000:zw:='MIPS R2000';
          3000:zw:='MIPS R3000';
          4000:zw:='MIPS R4000';
         21064:zw:='ALPHA 21064';
     else ZW:='Processor nicht klassifiziert';
     end;

     result:=zw;
end;

function TKMDiskInfo.getprocessorcount:integer;
var
systeminfo:TSysteminfo;
begin
     geTSysteminfo(systeminfo);
     result:=systeminfo.dwnumberofprocessors;
end;

function TKMDiskInfo.geTSystem:tBetriebssystem;
var
os:TOSVERSIONINFO;
begin
     os.dwosversioninfosize:=sizeof(os);
     getversionex(os);
     case os.dwplatformid of
     VER_PLATFORM_WIN32s:result:=bswin32;
     ver_PLATFORM_WIN32_Windows:result:=bswin95;
     VER_PLATFORM_Win32_nt:result:=bswinNT;
     else result:=bswin95;
     end;
end;

procedure TKMDiskInfo.shutdown;
begin
  exitwindowsex(EWX_SHUTDOWN,0);
end;

procedure TKMDiskInfo.reboot;
begin
  exitwindowsex(EWX_REBOOT,0);
end;

procedure TKMDiskInfo.logoff;
begin
  exitwindows(0,0)
end;

function TKMDiskInfo.sound: boolean;
begin
  result:=waveoutgetnumdevs>0;
end;

function TKMDiskInfo.diskindrive(lw: char; statusanzeige: boolean): boolean;
var
sRec:TsearchRec;
i:integer;
begin
     result:=false;
     {$I-}
     i:=findfirst(lw+':\*.*',faAnyfile,Srec);
     findclose(Srec);
     {$I+}
     case i of
     0:result:=true;
     2,18:begin
               if statusanzeige then
               showmessage('Diskette im Laufwerk '+lw+' ist leer !');
               result:=true;
          end;
     21,3:if statusanzeige then showmessage('Keine Diskette im Laufwerk '+lw+' !');
     else if statusanzeige then showmessage('Diskette nicht formatiert !'+inttostr(i));
     end;
end;

function TKMDiskInfo.disktyp(lw: char): string;
var
i,typ:integer;
s:string;
begin
if diskindrive(lw,false) then begin
s:=lw+':\';
typ:=getdrivetype(Pchar(s));
if typ <>0 then
   case typ of
   DRIVE_REMOVABLE:result:='Diskette';
   DRIVE_FIXED:result:='Festplatte';
   DRIVE_CDROM:result:='CDROM';
   DRIVE_RAMDISK:result:='RAMDisk';
   DRIVE_REMOTE:result:='Netzlaufwerk';
   else result:='Laufwerktyp unbekannt';
   end;
end;
end;

function TKMDiskInfo.diskserialnumber(lw: char): integer;
var
root:string;
volumenamebuffer,filesystemnamebuffer:pchar;
filesystemflags,maximumcomponentlength:Dword;
sectorspercluster,bytespersector,numberoffreeclusters,totalnumberofclusters:dword;
volumeserialnumber:pdword;
begin
if diskindrive(lw,false)then begin
root:=lw+':\';
volumenamebuffer:=stralloc(256);
filesystemnamebuffer:=stralloc(256);
getvolumeinformation(pchar(root),volumenamebuffer,255,volumeserialnumber,maximumcomponentlength,filesystemflags,filesystemnamebuffer,255);
result:=dword(volumeserialnumber);
strdispose(volumenamebuffer);
strdispose(filesystemnamebuffer);
end;

end;

function TKMDiskInfo.diskfilesystem(lw: char): string;
var
root:string;
volumenamebuffer,filesystemnamebuffer:pchar;
filesystemflags,maximumcomponentlength:Dword;
sectorspercluster,bytespersector,numberoffreeclusters,totalnumberofclusters:dword;
volumeserialnumber:pdword;
begin
if diskindrive(lw,false)then begin
root:=lw+':\';
volumenamebuffer:=stralloc(256);
filesystemnamebuffer:=stralloc(256);
getvolumeinformation(pchar(root),volumenamebuffer,255,volumeserialnumber,maximumcomponentlength,filesystemflags,filesystemnamebuffer,255);
result:=filesystemnamebuffer;    
strdispose(volumenamebuffer);
strdispose(filesystemnamebuffer);
end;

end;

function TKMDiskInfo.disknamelength(lw: char): integer;
var
root:string;
volumenamebuffer,filesystemnamebuffer:pchar;
filesystemflags,maximumcomponentlength:Dword;
sectorspercluster,bytespersector,numberoffreeclusters,totalnumberofclusters:dword;
volumeserialnumber:pdword;
begin
if diskindrive(lw,false)then begin
root:=lw+':\';
volumenamebuffer:=stralloc(256);
filesystemnamebuffer:=stralloc(256);
getvolumeinformation(pchar(root),volumenamebuffer,255,volumeserialnumber,maximumcomponentlength,filesystemflags,filesystemnamebuffer,255);
result:=maximumcomponentlength;  
strdispose(volumenamebuffer);
strdispose(filesystemnamebuffer);
end;
end;

function TKMDiskInfo.diskfreespace(lw: char): int64;
var
la:Int64 ;
lw2:char;
begin
     lw2:=upcase(lw);
     la:=ord(lw2)-64;
     result:=diskfree;
end;

function TKMDiskInfo.disktotalspace(lw: char): int64;
var
la:byte;
lw2:char;
begin
     lw2:=upcase(lw);
     la:=ord(lw2)-64;
     result:=disksize;
end;

function TKMDiskInfo.setComputername(name: string): boolean;
begin
     result:=windows.SetComputerName(pchar(name));

end;
procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMDiskInfo]);
end;

end.
