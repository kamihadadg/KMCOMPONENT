
unit UntBARHL; {Barcode High-Level routines}

{.$define debug}
{$ifdef debug}
  {$A+,B-,D+,F-,G+,I+,K+,L+,P-,R+,Q+,S+,T-,U-,V+,W-,X+,Y-,Z-}
{$else}
  {$A+,B-,D-,F-,G+,I+,K+,L-,P-,R-,Q-,S-,T-,U-,V+,W-,X+,Y-,Z-}
{$endif}

interface

uses
  Wintypes,Winprocs, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, UntBarLL;

{This const declarations must be the same as in bar32LL,
 this construction is needed for the 16-Bit version only,
 but it is included to be compatible for 16- and 32-bit Delphi}

{$ifndef ver93} {Only for Delphi, leads to ambiguity with CPP Builder}
type
  btCodeTypes=(EAN_8,EAN_13,UPC_A,UPC_E,CODE39,CODE25i,CODE25iP,
               CODE128_A,CODE128_B,CODE128_C,MSI_Plessey,Codabar,Postnet,Postnet_FIM);
  btCodeSizes=(SC0,SC1,SC2,SC3,SC4,SC5,SC6,SC7,SC8,SC9);{Must be the same as in Bar32LL!!!}
  btCodeRotate=(rotate_000,rotate_090,rotate_180,rotate_270);
  btCodeRatio=(Ratio_3,Ratio_2);
{$else}  {CPP Builder}
type
  btCodeTypes=lbtCodeTypes;
  btCodeSizes=lbtCodeSizes;
  btCodeRotate=lbtCodeRotate;
  btCodeRatio=lbtCodeRatio;
{$endif}

type
  TCustomBarcode = class(TGraphicControl)
             private
               { Private-Deklarationen }
               procedure paint;override;
             protected
               { Barcode low-level routines are protected}
               Barcode:TLLBarcode;
             public
               { User callable procedures are public}
               constructor Create(AOwner: TComponent);override;
               destructor destroy;override;
               procedure InternalPrint(MyCanvas:TCanvas;x,y:Integer;Point:PPoint);
               procedure SetFrachtpostKundenNummerStellen(Anzahl:Integer);
               procedure SetInputcode(NewCode:String);
               function GetInputcode:String;
               procedure SetAddonCode(NewAddon:String);
               function GetAddonCode:String;
               procedure SetBTyp(NewTyp:btCodeTypes);
               function GetBTyp:btCodeTypes;
               procedure SetSCSize(NewSize:btCodeSizes);
               function GetSCSize:btCodeSizes;
               procedure SetHeightPercent(NewHeight:Integer);
               function GetHeightPercent:Integer;
               procedure SetFontname(NewName:string);
               function GetFontname:string;
               procedure SetFontscaling(NewScaling:Integer);
               function GetFontScaling:Integer;
               procedure SetReduceWidth(New:boolean);
               function GetReduceWidth:boolean;
               procedure SetHDCode(New:boolean);
               function GetHDCode:boolean;
               procedure SetHReadable(New:boolean);
               function GetHReadable:boolean;
               procedure SetZoomSize(New:boolean);
               function GetZoomSize:boolean;
               function GetCodeLicensed:string;
               procedure SetCodeLicensed(s:string);
               function GetCodeVersion:string;
               procedure SetCodeVersion(s:string);
               function GetRotate:btCodeRotate;
               procedure SetRotate(New:btCodeRotate);
               function GetRatio:btCodeRatio;
               procedure SetRatio(New:btCodeRatio);
             published
               { Property declarations are published to make them visible }
               property Bar_Caption:string read GetInputcode write SetInputcode;
               property Bar_CodeAddon: string read GetAddonCode write SetAddonCode;
               property Bar_CodeType: btCodeTypes read GetbTyp write SetbTyp default EAN_8;
               property Bar_Fontname:string read GetFontname write SetFontname;
               property Bar_Fontscaling:Integer read GetFontScaling write SetFontscaling default 100;
               property Bar_HeightPercent:Integer read GetHeightPercent write SetHeightPercent default 100;
               property Bar_HighDensity:Boolean read GetHDCode write SetHDCode;
               property Bar_HumanReadable:Boolean read GetHReadable write SetHReadable default true;
               property Bar_ModuleWidth: btCodeSizes read GetSCSize write SetSCSize default SC0;
               property Bar_Ratio: btCodeRatio read GetRatio write SetRatio default Ratio_3;
               property Bar_Rotation: btCodeRotate read GetRotate write SetRotate default Rotate_000;
               property Bar_WidthReduce:Boolean read GetReduceWidth write SetReduceWidth;
               property Bar_ZoomSize:Boolean read GetZoomSize write SetZoomSize;
               property Code_License: string read GetCodeLicensed write SetCodeLicensed;
               property Code_Version:string read GetCodeVersion write SetCodeVersion;
               property OnDragDrop;
               property OnDragOver;
               property OnEndDrag;
               property OnMouseDown;
               property OnMouseMove;
               property OnMouseUp;
             end;

implementation


{Begin of functions to check if Delphi is running}
function GetSum(s:string):Longint;
var i:Integer;
begin
  Result:=0;
  for i:=1 to length(s) do
    Result:=Result+ord(s[i]);
end;


procedure updateChecksum(Var Checksum:Longint;s:string);
var i:Integer;
begin
  for i:=1 to length(s) do
  begin
    inc(Checksum,byte(s[i]) xor (random(255)));
  end;
end;

const
  notRegisteredmsg='Not registered';
  nosetLicensedmsg='Setting the BARLICENSE property is not allowed. '+
          'See documentation for details on how to obtain the licensed version '+
          'from J. Schlottke, CIS-ID 100106,3034';
  noSetVersionMsg='Setting the BARVERSION property is not allowed. '+
          'See documentation for details on how to obtain the latest version '+
          'from J. Schlottke, CIS-ID 100106,3034';
  tAppBuilder='TAppBuilder'#0;
  QueryName='Delphi';
  timeoutmsg='Older shareware version of TBarcode by J. Schlottke found. '+
                    'Please get an updated version from Compuserve or the author himself. '+
                    'Or reset Your PCs clock to a date before 1/1/99';

  sharewaremsg='TBarcode is a SHAREWARE programming component. '+
                      'Please register now! Or run application with Delphi! '+
                      'Author is J. Schlottke, e-mail:  schlottke@compuserve.com';
  corruptedmsg='TBarcode: License file is invalid/corrupted. '+
                      'Please contact J. Schlottke, e-mail:  schlottke@compuserve.com';


function IsLicensed:string;
{returns Licensename or '' if no valid license}
begin
  IsLicensed:='Site License';
end;


constructor TCustomBarcode.Create(AOwner: TComponent);
{Called when object is created by software statements}
begin
  inherited create(AOwner);
  Barcode:=TLLBarcode.create;
  width:=69; {Set some dimensions, don't matter what values}
  height:=66;{In this case: dimensions for EAN-8 on Screen}
end;


destructor TCustomBarcode.destroy;
begin
  Barcode.free;
  inherited destroy;
end;


procedure TCustomBarcode.SetInputcode(NewCode:String);
{Make String a PChar}
begin
  {This proc is called during loading, so this is
   our hook to initialize our dynamic data}
  if length(NewCode)<=MaxBarcodelen then
  begin
    strpcopy(Barcode.Params.Inputcode,NewCode);
    invalidate;
  end
  else
  raise EOverflow.create('String exceeds maximum length');
end;

function TCustomBarcode.GetInputcode:String;
begin
  {If inserting a component with no size dragged,
   paint is not called, so we must initialize with this code
   and force a redraw}
  GetInputcode:=strpas(Barcode.Params.Inputcode);
end;

procedure TCustomBarcode.SetAddonCode(NewAddon:string);
var
  temp:string;
  i:Integer;
begin
  temp:='';
  for i:=1 to length(NewAddon) do
    if NewAddon[i] in ['0'..'9'] then temp:=temp+NewAddon[i];
  {Prevent exceptions, adjust code}
  if length(temp)>=5 then temp:=copy(temp,1,5)
  else if length(temp)>=2 then temp:=copy(temp,1,2)
  else temp:='';
  if length(temp) in [0,2,5] then {No Addon, Addon-2, Addon-5}
  begin
    Strpcopy(Barcode.Params.AddonCode,Temp);
    invalidate;
  end
  else
  raise EOverflow.create('Addon must be 0, 2 or 5 digits');
end;

function TCustomBarcode.GetAddonCode:String;
begin
  GetAddonCode:=strpas(Barcode.Params.AddonCode);
end;

procedure TCustomBarcode.SetbTyp(NewTyp:btCodeTypes);
begin
  Barcode.Params.bTyp:=lbtCodetypes(ord(NewTyp));
  invalidate;
end;

function TCustomBarcode.GetbTyp:btCodeTypes;
begin
  GetbTyp:=btCodeTypes(ord(Barcode.Params.bTyp));
end;

procedure TCustomBarcode.SetSCSize(NewSize:btCodeSizes);
begin
  If NewSize in [SC0..SC9] then
  begin
    Barcode.Params.SCSize:=lbtCodeSizes(ord(NewSize));
    invalidate;
  end
  else
    raise EOverflow.create('Bar_SC_Size must be in the range 0..9!');
end;

function TCustomBarcode.GetSCSize:btCodeSizes;
begin
  GetSCSize:=btCodeSizes(ord(Barcode.Params.SCSize));
end;

procedure TCustomBarcode.SetRotate(New:btCodeRotate);
begin
  If New in [Rotate_000..Rotate_270] then
  begin
    Barcode.Params.Rotate:=lbtCodeRotate(ord(New));
    invalidate;
  end
  else
    raise EOverflow.create('Bar_Rotate must be in the range rotate_000..rotate_270!');
end;

function TCustomBarcode.GetRotate:btCodeRotate;
begin
  GetRotate:=btCodeRotate(ord(Barcode.Params.Rotate));
end;

function TCustomBarcode.GetRatio:btCodeRatio;
begin
  GetRatio:=btCodeRatio(ord(Barcode.Params.Ratio));
end;

procedure TCustomBarcode.SetRatio(New:btCodeRatio);
begin
  If New in [Ratio_3,Ratio_2] then
  begin
    Barcode.Params.Ratio:=lbtCodeRatio(ord(New));
    invalidate;
  end
  else
    raise EOverflow.create('Bar_Ratio must be in the range 0..1 (Ratio_3 or Ratio_2)!');
end;


procedure TCustomBarcode.SetHeightPercent(NewHeight:Integer);
begin
  If NewHeight in [20..200] then
  begin
    Barcode.Params.HeightPercent:=NewHeight;
    invalidate;
  end
  else
    raise EOverflow.create('Bar_HeightPercent must be in the range 20..200!');
end;

function TCustomBarcode.GetHeightPercent:Integer;
begin
  GetHeightPercent:=Barcode.Params.HeightPercent;
end;

procedure TCustomBarcode.SetFontname(NewName:string);
begin
  Barcode.Params.Fontname:=NewName;
  invalidate;
end;

function TCustomBarcode.GetFontname:string;
begin
  GetFontname:=Barcode.Params.Fontname;
end;

procedure TCustomBarcode.SetFontscaling(NewScaling:Integer);
begin
  If NewScaling in [20..200] then
  begin
    Barcode.Params.Fontscaling:=NewScaling;
    invalidate;
  end
  else
    raise EOverflow.create('Bar_Fontscaling must be in the range 20..200!');
end;

function TCustomBarcode.GetFontScaling:Integer;
begin
  GetFontScaling:=Barcode.Params.Fontscaling;
end;

procedure TCustomBarcode.SetReduceWidth(New:boolean);
begin
  Barcode.Params.ReduceWidth:=New;
  invalidate;
end;

function TCustomBarcode.GetReduceWidth:boolean;
begin
  GetReduceWidth:=Barcode.Params.ReduceWidth;
end;

procedure TCustomBarcode.SetHDCode(New:boolean);
begin
  Barcode.Params.HDCode:=New;
  invalidate;
end;

function TCustomBarcode.GetHDCode:boolean;
begin
  GetHDCode:=Barcode.Params.HDCode;
end;

procedure TCustomBarcode.SetHReadable(New:Boolean);
begin
  Barcode.Params.HumanReadable:=New;
  invalidate;
end;

function TCustomBarcode.GetHReadable:Boolean;
begin
  GetHReadable:=Barcode.Params.HumanReadable;
end;

procedure TCustomBarcode.SetZoomSize(New:boolean);
begin
  Barcode.Params.ZoomSize:=New;
  invalidate;
end;

function TCustomBarcode.GetZoomSize:boolean;
begin
  GetZoomSize:=Barcode.Params.ZoomSize;
end;


function TCustomBarcode.GetCodeLicensed:String;
begin
  GetCodeLicensed:=IsLicensed;
end;

procedure TCustomBarcode.SetCodeLicensed(s:string);
begin
  if not (csReading in ComponentState) then
  raise EOverFlow.create(noSetLicensedmsg);
end;


function TCustomBarcode.GetCodeVersion:string;
begin
  GetCodeVersion:='v3.22';
end;

procedure TCustomBarcode.SetCodeVersion(s:string);
begin
  if not (csReading in ComponentState) then
  raise EOverFlow.create(noSetversionmsg);
end;


procedure TCustomBarcode.paint;
var Point:TPoint;
begin
  {When inserting a new component from the component palette,
   "paint" is called before all other stuff, so in this case
   the barcode is not initialized yet.}
  {Now Paint the Barcode}
  Barcode.ToCanvas(Canvas,0,0,Point);
  {If width<>ReturnWidth, then reset width,
   this will force an invalidate and repaint}
  {Reset Width and Height to fit the barcode}
  width:=Point.x;
  height:=Point.y;
end;

procedure TCustombarcode.InternalPrint(MyCanvas:TCanvas;x,y:Integer;Point:PPoint);
var MyPoint:TPoint;
begin
  Barcode.ToCanvas(MyCanvas,x,y,MyPoint);
  If Point<>nil then
  begin
    Point^.x:=MyPoint.X;
    Point^.y:=MyPoint.Y;
  end;
  (* For debugging only: see bounding box around barcode
  MyCanvas.Brush.style:=bsClear;
  MyCanvas.pen.color:=clRed;
  MyCanvas.pen.style:=psDot;
  MyCanvas.rectangle(x,y,x+mypoint.x,y+mypoint.y);
  *)
end;


procedure TCustombarcode.SetFrachtpostKundenNummerStellen(Anzahl:Integer);
begin
  If Anzahl<4 then Anzahl:=4;
  If Anzahl>7 then Anzahl:=7;
  Barcode.Params.FrachtpostKdKennungLen:=Anzahl;
end;


end.


