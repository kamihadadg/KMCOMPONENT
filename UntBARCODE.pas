
unit UntBARCODE;
{ Copyright 1996-1999 by Juergen Schlottke, Elmshorn (Germany)
  e-mail:  schlottke@compuserve.com
  In the Internet You will find the latest version always at:
  http://ourworld.compuserve.com/homepages/schlottke

 This file contains the components TBarcode and TQRBarcode
 and can be used whith Quickreports v1.0, v1.1, v2.0 and v3.0,
 please have a look at the comments in the interface section if
 You need to support other versions of Quickreport than delivered
 from Borland with You Delphi release}

{.$define debug}
{$ifdef debug}
  {$A+,B-,D+,F-,G+,I+,K+,L+,P-,R+,Q+,S+,T-,U-,V+,W-,X+,Y-,Z-}
{$else}
  {$A+,B-,D-,F-,G+,I+,K+,L-,P-,R-,Q-,S-,T-,U-,V+,W-,X+,Y-,Z-}
{$endif}

interface

{$IFDEF VER90}     {With Delphi-2}
  {$DEFINE QR_V1}  {Quickreport v1.0 is default for Delphi-2}
{$ENDIF}

{$IFDEF VER93}     {With CPP Builder 1.0}
  {$DEFINE QR_V1}  {Quickreport v1.0 is default for CPP Builder 1.0}
{$ENDIF}

{$IFDEF VER100}    {With Delphi-3}
  {$DEFINE QR_V2}  {Quickreport v2.0 is default for Delphi-3}
{$ENDIF}

{$IFDEF VER110}    {With C++-Builder v3}
  {.$DEFINE QR_V2}  {Quickreport is disabled by default for CPPB-3}
{$ENDIF}           {remove the dot in line above to enable T for CPPB-3}

{$IFDEF VER120}    {With Delphi-4}
  {.$DEFINE QR_V2}  {Quickreport v2.0/v3.0 is default for Delphi-4}
{$ENDIF}

{$IFDEF VER125}    {With C++-Builder v4}
  {.$DEFINE QR_V2}  {Quickreport is disabled by default for CPPB-4}
{$ENDIF}           {remove the dot in line above to enable TSSQRBarcode for CPPB-3}

{$IFDEF VER130}    {With Delphi-5}
  {$DEFINE QR_V2}  
{$ENDIF}           {remove the dot in line above to enable TSSQRBarcode for CPPB-3}

{Please note: Define QR_V2 ist correct for Quickreports v2.0 AND v3.0!}

{---------- BEGIN OF USER DEFINABLE SECTION ----------}

{.To override the default Quickreport setting, You can remove the dot
 in one of the following comment lines to make it a $DEFINE statement
 Warning: Incorrect QR_xx setting may crash the VCL library!}

{To force compilation for Quickreports v1.0 remove the dot in the following line}
{.$DEFINE QR_V1}

{To force compilation for Quickreports v1.1 remove the dot in the following line}
{.$DEFINE QR_V11}

{To force compilation for Quickreports v2.0 remove the dot in the following line}
{$DEFINE QR_V2}

{See help file TBARCODE.HLP for detailed installation instructions}

{---------- END OF USER DEFINABLE SECTION ----------}

{QR_V1 and QR_V2 defines are not allowed at the same time}
{$IFDEF QR_V2}
  {$UNDEF QR_V1}
  {$UNDEF QR_V11}
  {$define WITHQUICKREPORT}
{$endif}
{$ifdef QR_V1}
  {$UNDEF QR_V2}
  {$define WITHQUICKREPORT}
{$endif}
{$ifdef QR_V11}
  {$UNDEF QR_V2}
  {$define WITHQUICKREPORT}
  {$define QR_V1}
{$endif}


uses
  Wintypes,Winprocs,Classes,Graphics,dialogs,
  UntBarLL, UntBarHL
{$ifdef QR_V1}
  ,Quickrep           {include unit with Quickreport v1.x}
{$endif}
{$ifdef QR_V2}
 ,Quickrpt, QRCtrls {include units with Quickreport v2.x}
{$endif}
  ;

procedure Register;

type
  TKMBarcode=class(TCustomBarcode)
           private
             fAutoSize:boolean;
           public
             constructor Create(AOwner: TComponent);override;
             procedure paint;override;
             {Print ==> Barcode output on any Delphi canvas}
             procedure Print(MyCanvas:TCanvas;x,y:Integer;Point:PPoint);
             {SaveToFile ==> Save a barcode as a BMP file}
             procedure SaveToFile(BorderWidth:Integer;Filename:string);
             {Save to Bitmap with extended features}
             procedure SaveToFileEx(BorderWidth:Integer;Filename:string;
                                monochrome:boolean;MagnifyBy:Integer);
             {CopyToClipboard ==> Copy a barcode to the clipboard in format cf_bitmap}
             procedure CopyToClipboard(BorderWidth:Integer);
             {CopyToRect  ==> Copy barcode to a given rectangle on a Canvas}
             procedure CopyToRect(DestCanvas:TCanvas;DestRect:TRect);
             {Special procedure for German "Frachtpost"-Barcodes}
             procedure SetFrachtpostKundenNummerStellen(Anzahl:Integer);
             procedure SetAutoSize(New:boolean);
           published
             property AutoSize:boolean read fAutoSize write SetAutoSize default true;
             property OnClick;     {Publish the hidden "Click" properties}
             property OnDblClick;
           end;

{$ifdef WITHQUICKREPORT}


type
//  btCodeTypes=(EAN_8,EAN_13,UPC_A,UPC_E,CODE39,CODE25i,CODE25iP,CODE128_A,CODE128_B,CODE128_C,MSI_Plessey,Codabar,Postnet,Postnet_FIM);

  TKMQRBarcode = class(TQRDBText) {TSSQRBarcode is derived from TQRDBText}
{  TSSQRBarcode = class(TQRPrintable) {Perhaps this would be better, but I don't have time to do it}
  private
    { Private-Deklarationen }
    fPrintEmpty:boolean;
    Barcode:TCustomBarcode;
    procedure SetInputcode(NewCode:String);
    function GetInputcode:String;
    procedure SetAutoSize(New:boolean);
    function GetAutoSize:boolean;
    procedure SetAddonCode(NewCode:String);
    function GetAddonCode:String;
    procedure SetBTyp(NewTyp:btCodeTypes);
    function GetBTyp:btCodeTypes;
    procedure SetSCSize(NewSize:btCodeSizes);
    function GetSCSize:btCodeSizes;
    procedure SetHeightPercent(NewHeight:Integer);
    function GetHeightPercent:Integer;
    procedure SetHReadable(New:boolean);
    function GetHReadable:boolean;
    procedure SetReduceWidth(New:boolean);
    function GetReduceWidth:boolean;
    procedure SetHDCode(New:boolean);
    function GetHDCode:boolean;
    procedure SetZoomSize(New:boolean);
    function GetZoomSize:boolean;
    procedure SetRotate(New:btCodeRotate);
    function GetRotate:btCodeRotate;
    procedure SetRatio(New:btCodeRatio);
    function GetRatio:btCodeRatio;
    procedure SetFontname(NewName:string);
    function GetFontname:string;
    procedure SetFontscaling(NewScaling:Integer);
    function GetFontScaling:Integer;
    procedure forceRedraw;
    function GetCodeVersion:string;
    procedure SetCodeVersion(NewVersion:string);
    function GetCodeLicensed:string;
    procedure SetCodeLicensed(New:string);
    function GetBarcodeCaption:string;
  public
    { Public-Deklarationen }
    constructor Create(AOwner: TComponent);override;
    procedure Print(X,Y : Integer); override;
    procedure Paint;override;
    function GetHeightAtRuntime:Integer;
  published
    { Published-Deklarationen }
    property AutoSize:boolean read GetAutoSize write SetAutoSize;
    property Bar_Caption:string read GetInputcode write SetInputcode;
    property Bar_CodeAddon:string read GetAddonCode write SetAddonCode;
    property Bar_CodeType: btCodeTypes read GetbTyp write SetbTyp default EAN_8;
    property Bar_HeightPercent:Integer read GetHeightPercent write SetHeightPercent default 100;
    property Bar_HumanReadable:Boolean read GetHReadable write SetHReadable default true;
    {with quickreports "Bar_HighDensity" makes no sense, next line is commented out}
    {property Bar_HighDensity:Boolean read GetHDCode write SetHDCode;}
    property Bar_ModuleWidth: btCodeSizes read GetSCSize write SetSCSize default SC2;
    property Bar_Ratio: btCodeRatio read GetRatio write SetRatio default Ratio_3;
    {with quickreports "Bar_WidthReduce" makes no sense, next line is commented out}
    {property Bar_WidthReduce:Boolean read GetReduceWidth write SetReduceWidth;}
    {with quickreports "Bar_Zoomsize" makes no sense, next line is commented out}
    {property Bar_ZoomSize:Boolean read GetZoomSize write SetZoomSize;}
    property Bar_Rotation: btCodeRotate read GetRotate write SetRotate default Rotate_000;
    property Bar_PrintEmpty: Boolean read fPrintEmpty write fPrintEmpty;
    property Bar_Fontname:String read GetFontname write SetFontname;
    property Bar_FontScaling: Integer read GetFontScaling write SetFontScaling;
    property Code_License: string read GetCodeLicensed write SetCodeLicensed;
    property Code_Version:string read GetCodeVersion write SetCodeVersion;
  end;
{$endif}

implementation


uses sysutils,extctrls,printers,Clipbrd,forms;

constructor TKMBarcode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fAutoSize:=true;
end;

procedure TKMBarcode.SetAutoSize(New:boolean);
begin
  If New<>fAutoSize then
  begin
    fAutoSize:=New;
    invalidate;
  end;
end;


procedure TKMBarcode.paint;
var Point:TPoint;
begin
  InternalPrint(Canvas,0,0,@Point);
  If AutoSize then
  begin
    width:=Point.x;
    height:=Point.y;
  end;
end;

procedure TKMBarcode.Print(MyCanvas:TCanvas;x,y:Integer;Point:PPoint);
var
  DeviceUnits_Per_X_Unit,
  DeviceUnits_Per_Y_Unit:Extended;
  OldMapMode:Integer;
begin
  case getMapmode(MyCanvas.Handle) of
    mm_Text    : begin
                   InternalPrint(MyCanvas,x,y,Point); {Delphi standard mapmode}
                 end;
    mm_LoMetric,
    mm_HiMetric: begin {if You prefer mapmode mm_LoMetric}
                   if getMapmode(MyCanvas.Handle)=mm_LoMetric then
                   begin
                     DeviceUnits_Per_X_Unit:=getdevicecaps(MyCanvas.Handle,logpixelsX)/254.0;
                     DeviceUnits_Per_Y_Unit:=getdevicecaps(MyCanvas.Handle,logpixelsY)/254.0;
                   end
                   else
                   begin
                     DeviceUnits_Per_X_Unit:=getdevicecaps(MyCanvas.Handle,logpixelsX)/25.40;
                     DeviceUnits_Per_Y_Unit:=getdevicecaps(MyCanvas.Handle,logpixelsY)/25.40;
                   end;
                   OldMapMode:=setmapmode(MyCanvas.Handle,mm_Text);{switch mapmode}
                   InternalPrint(MyCanvas,round(x*DeviceUnits_Per_X_Unit),-round(y*DeviceUnits_Per_Y_Unit),Point);
                   If Point<>nil then
                   begin
                     Point^.x:=round(Point^.x/DeviceUnits_Per_X_Unit);
                     Point^.y:=round(Point^.y/DeviceUnits_Per_Y_Unit);
                   end;
                   setmapmode(MyCanvas.Handle,OldMapMode{mm_LoMetric});{switch mapmode back}
                 end;
    else  {no other mapmodes supported yet, please do it yourself if needed}
      raise EOverflow.create('Barcode: Wrong mapmode in "LoMetricPrint"');
  end;
end;

procedure TKMBarcode.SaveToFileEx(BorderWidth:Integer;Filename:string;
                                monochrome:boolean;MagnifyBy:Integer);
{Save barcode graphics as a BMP file, extended version.
 Input variables:
 BorderWidth: How wide is the "white frame" around the barcode
 Filename: Filename for BMP file to store the bitmap
 Monochrome: Will produce a monochrome bitmap if true, color bitmap if false
 MagnifyBy: "1" is a barcode with "screen resolution", bigger values will produce bigger bitmaps
 }
var
  Picture:TPicture;
  point:TPoint;
begin
  If MagnifyBy<1 then raise(EOverflow.create('Barcode: Factor for "MagnifyBy" must be >=1'));
  Picture:=TPicture.create;
  picture.bitmap:=TBitmap.create;
  picture.bitmap.monochrome:=monochrome;
  {Bitmap size is not correct yet, but do output into the bitmap}
  setmapmode(picture.bitmap.canvas.Handle,mm_anisotropic);{switch mapmode}
  SetWindowExtEx(picture.bitmap.canvas.Handle,screen.width,screen.height,nil);
  SetViewportExtEx(picture.bitmap.canvas.Handle,screen.width*MagnifyBy,screen.height*MagnifyBy,nil);
  InternalPrint(picture.bitmap.canvas,BorderWidth,BorderWidth,@point);
  {Now we know the real width and height of the barcode,
   adjust bitmap width and height}
  Picture.Bitmap.width:=point.x+2*BorderWidth;
  Picture.Bitmap.width:=Picture.Bitmap.width*MagnifyBy;
  Picture.Bitmap.height:=point.y+2*BorderWidth;
  Picture.Bitmap.height:=Picture.Bitmap.height*MagnifyBy;
  {Clear the bitmap, seems not necessary}
{  Picture.bitmap.canvas.fillrect(rect(0,0,Picture.width,Picture.height));}
  {Do output again into the bitmap}
  setmapmode(picture.bitmap.canvas.Handle,mm_anisotropic);{switch mapmode}
  SetWindowExtEx(picture.bitmap.canvas.Handle,screen.width,screen.height,nil);
  SetViewportExtEx(picture.bitmap.canvas.Handle,screen.width*MagnifyBy,screen.height*MagnifyBy,nil);
  InternalPrint(picture.bitmap.canvas,BorderWidth,BorderWidth,@point);
  {Now try saving it into the file}
  try
    picture.savetofile(Filename);
  finally
    Picture.free; {Free the dynamically created picture}
  end;
end;


procedure TKMBarcode.SaveToFile(BorderWidth:Integer;Filename:string);
{Save barcode graphics as a BMP file,
 code is nearly the same as in procedure "CopyToClipboard"}
var
  Picture:TPicture;
  point:TPoint;
begin
  Picture:=TPicture.create;
  picture.bitmap:=TBitmap.create;
  {Bitmap size is not correct yet, but do output into the bitmap}
  InternalPrint(picture.bitmap.canvas,BorderWidth,BorderWidth,@point);
  {Now we know the real width and height of the barcode,
   adjust bitmap width and height}
  Picture.Bitmap.width:=point.x+2*BorderWidth;
  Picture.Bitmap.height:=point.y+2*BorderWidth;
  {Clear the bitmap, seems not necessary}
{  Picture.bitmap.canvas.fillrect(rect(0,0,Picture.width,Picture.height));}
  {Do output again into the bitmap}
  InternalPrint(picture.bitmap.canvas,BorderWidth,BorderWidth,@point);
  {Now try saving it into the file}
  try
    picture.savetofile(Filename);
  finally
    Picture.free;  {Free the dynamically created picture}
  end;
end;


procedure TKMBarcode.CopyToClipboard(BorderWidth:Integer);
{Copy barcode graphics into the clipboard,
 code is nearly the same as in procedure "SaveToFile"}
var
  Picture:TPicture;
  point:TPoint;
begin
  Picture:=TPicture.create;
  picture.bitmap:=TBitmap.create;
  {Bitmap size is not correct yet, but do output into the bitmap}
  InternalPrint(picture.bitmap.canvas,BorderWidth,BorderWidth,@point);
  {Now we know the real width and height of the barcode,
   adjust bitmap width and height}
  Picture.Bitmap.width:=point.x+2*BorderWidth;
  Picture.Bitmap.height:=point.y+2*BorderWidth;
  {Clear the bitmap seems not to be necessary}
{  Picture.bitmap.canvas.fillrect(rect(0,0,Picture.width,Picture.height));}
  {Do output again into the bitmap}
  InternalPrint(picture.bitmap.canvas,BorderWidth,BorderWidth,@point);
  {Now try to put image into Clipboard}
  try
    Clipboard.assign(picture.bitmap);
  finally
    Picture.free;  {Free the dynamically created picture}
  end;
end;

procedure TKMBarcode.CopyToRect(DestCanvas:TCanvas;DestRect:TRect);
var
  Picture:TPicture;
  point:TPoint;
begin
  Picture:=TPicture.create;
  picture.bitmap:=TBitmap.create;
  try
    {Bitmap size is not correct yet, but do output into the bitmap}
    InternalPrint(picture.bitmap.canvas,0,0,@point);
    {Now we know the real width and height of the barcode,
     adjust bitmap width and height}
    Picture.Bitmap.width:=point.x;
    Picture.Bitmap.height:=point.y;
    {Do output again into the bitmap}
    InternalPrint(picture.bitmap.canvas,0,0,@point);
    {Now draw bitmap to canvas}
    DestCanvas.StretchDraw(DestRect,Picture.Bitmap);
  finally
    Picture.free;  {Free the dynamically created picture}
  end;
end;



procedure TKMBarcode.SetFrachtpostKundenNummerStellen(Anzahl:Integer);
{This procedure is only needed with the German "Frachtpost"-Version of Code2/5i!
 "Frachtpost" codes have a length of 12 or 14 digits and the human
 readable code is grouped into chunks of digits which are seperated with dots.
 The 12-digit "Leitcode" has coded a "Kundenkennung" that can be 4 to 7 digits.
 This procedure can set the correct length for "Kundenkennung", so the
 "Leitcode"-digits are grouped correctly in the human readable text.
 The default value is 7 digits. }
begin
  inherited SetFrachtpostKundenNummerStellen(Anzahl);
end;


{$ifdef WITHQUICKREPORT}

constructor TKMQRBarcode.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
{  AutoSize:=true; darf nicht sein, sonst Fehler bei QR1}
  Barcode:=TCustomBarcode.create(self);
  Width:=Barcode.width; {Some values<>0 force an immidiate repaint}
  Height:=Barcode.height;
{$ifdef QR_V2}
  {Must Bar_ZoomSize=true or have no WYSIWYG with QR v2}
  Barcode.Bar_ZoomSize:=true;
{$endif}
end;


procedure TKMQRBarcode.ForceRedraw;
{$ifdef QR_V2}
begin
  invalidate;
end;
{$else}
var
  r:TRect;
begin
  invalidate;
  if barcode<>nil then
  begin
    r.top:=top;r.left:=left;
    r.right:=r.left+width;
    r.bottom:=r.top+height;
    invalidaterect(parent.handle,@r,true);
  end;
end;
{$endif}

procedure TKMQRBarcode.SetInputcode(NewCode:String);
begin
  Barcode.setinputcode(copy(NewCode,1,Maxbarcodelen));
  ForceRedraw;
end;

function TKMQRBarcode.GetInputcode:String;
begin
  Getinputcode:=Barcode.Getinputcode;
end;

procedure TKMQRBarcode.SetAutoSize(New:boolean);
begin
  inherited AutoSize:=New;
  ForceRedraw;
end;

function TKMQRBarcode.GetAutoSize:boolean;
begin
  result:=inherited AutoSize;
end;

procedure TKMQRBarcode.SetAddonCode(NewCode:String);
begin
  Barcode.SetAddonCode(NewCode);
  ForceRedraw;
end;

function TKMQRBarcode.GetAddonCode:string;
begin
  GetAddonCode:=Barcode.GetAddonCode;
end;


procedure TKMQRBarcode.SetBTyp(NewTyp:btCodeTypes);
begin
  barcode.SetBTyp(NewTyp);
  ForceRedraw;
end;

function TKMQRBarcode.GetBTyp:btCodeTypes;
begin
  GetBTyp:=btCodeTypes(Barcode.GetBTyp);
end;

procedure TKMQRBarcode.SetSCSize(NewSize:btCodeSizes);
begin
  barcode.SetSCSize(NewSize);
  ForceRedraw;
end;

function TKMQRBarcode.GetSCSize:btCodeSizes;
begin
  GetSCSize:=btCodeSizes(Barcode.GetSCSize);
end;

procedure TKMQRBarcode.SetRotate(New:btCodeRotate);
begin
  barcode.SetRotate(New);
  ForceRedraw;
end;

function TKMQRBarcode.GetRotate:btCodeRotate;
begin
  GetRotate:=btCodeRotate(Barcode.GetRotate);
end;

procedure TKMQRBarcode.SetRatio(New:btCodeRatio);
begin
  barcode.SetRatio(New);
  ForceRedraw;
end;

function TKMQRBarcode.GetRatio:btCodeRatio;
begin
  GetRatio:=btCodeRatio(Barcode.GetRatio);
end;

procedure TKMQRBarcode.SetHeightPercent(NewHeight:Integer);
begin
  Barcode.SetHeightPercent(NewHeight);
  ForceRedraw;
end;

function TKMQRBarcode.GetHeightPercent:Integer;
begin
  GetHeightPercent:=barcode.getheightPercent;
end;

procedure TKMQRBarcode.SetHReadable(New:boolean);
begin
  Barcode.SetHReadable(New);
  ForceRedraw;
end;

function TKMQRBarcode.GetHReadable:boolean;
begin
  GetHReadable:=barcode.GetHReadable;
end;


procedure TKMQRBarcode.SetReduceWidth(New:boolean);
begin
  Barcode.SetReduceWidth(New);
  ForceRedraw;
end;

function TKMQRBarcode.GetReduceWidth:boolean;
begin
  GetReduceWidth:=Barcode.GetReduceWidth;
end;

procedure TKMQRBarcode.SetHDCode(New:boolean);
begin
  Barcode.SetHDCode(New);
  ForceRedraw;
end;

function TKMQRBarcode.GetHDCode:boolean;
begin
  GetHDCode:=Barcode.GetHDCode;
end;

procedure TKMQRBarcode.SetZoomSize(New:boolean);
begin
  Barcode.SetZoomSize(New);
  ForceRedraw;
end;

function TKMQRBarcode.GetZoomSize:boolean;
begin
  GetZoomsize:=BArcode.Getzoomsize;
end;

procedure TKMQRBarcode.SetFontname(NewName:string);
begin
  Barcode.SetFontname(NewName);
  ForceRedraw;
end;

function TKMQRBarcode.GetFontname:string;
begin
  GetFontname:=Barcode.GetFontname;
end;

procedure TKMQRBarcode.SetFontscaling(NewScaling:Integer);
begin
  Barcode.SetFontscaling(NewScaling);
  ForceRedraw;
end;

function TKMQRBarcode.GetFontScaling:Integer;
begin
  GetFontScaling:=Barcode.GetFontScaling;
end;

procedure TKMQRBarcode.SetCodeVersion(NewVersion:string);
begin
  {Don't remove this empty procedure!}
end;

function TKMQRBarcode.GetCodeVersion:string;
begin
  GetCodeVersion:=Barcode.GetCodeVersion;
end;

procedure TKMQRBarcode.SetCodeLicensed(New:string);
begin
  {Don't remove this empty procedure!}
end;

function TKMQRBarcode.GetCodeLicensed:string;
begin
  GetCodeLicensed:=Barcode.GetCodeLicensed;
end;

{$ifdef QR_V1}
function TKMQRBarcode.GeTTSSBarcodeCaption: string;
{If "Datasource" and "Datafield" are assigned, get the
 code string from the datafield and otherwise from "Bar_Caption"}
begin
  if (FDataLink<>nil) and (FDataLink.Field <> nil) and FDataLink.active then
    GeTTSSBarcodeCaption := FDataLink.Field.DisplayText
  else
    GeTTSSBarcodeCaption := Bar_Caption;
end;
{$endif}

(*
{$ifdef QR_V2}
function TKMQRBarcode.GeTTSSBarcodeCaption: string;
{If "Datasource" and "Datafield" are assigned, get the
 code string from the datafield and otherwise from "Bar_Caption"}
begin
  If (dataset<>nil) and (datafield<>'') and (dataset.active) then
    GeTTSSBarcodeCaption:=dataset.fieldbyname(datafield).displaytext
  else
    GeTTSSBarcodeCaption := Bar_Caption;
end;
{$endif}*)

{$ifdef QR_V2}
function TKMQRBarcode.GeTBarcodeCaption: string;
{If "Datasource" and "Datafield" are assigned, get the
 code string from the datafield and otherwise from "Bar_Caption"}
begin
  If (dataset<>nil) and (datafield<>'') and (dataset.active) then
    GeTBarcodeCaption:=dataset.fieldbyname(datafield).displaytext
  else
    GeTBarcodeCaption := Bar_Caption;
end;
{$endif}


{$ifdef QR_V2}
{Paint-procedure with correct handling of design time ZOOM property}
procedure TKMQRBarcode.Paint;
var
  mypoint:TPoint;
begin
  if self.canvas<>nil then
  begin
    canvas.brush.color:=color;
    canvas.fillrect(rect(0,0,width,height));
    if Bar_Caption<>GeTBarcodeCaption then Bar_Caption:=GeTBarcodeCaption;
    setmapmode(self.Canvas.handle,mm_anisotropic);
    {96 dpi is the canvas resolution during showing the form}
    SetWindowExtEx(self.Canvas.handle,96,96,nil);
    SetViewportExtEx(self.Canvas.handle,muldiv(96,zoom,100),muldiv(96,zoom,100),nil);
    if AutoSize or (Alignment=taLeftJustify) then
    begin  {width adjustment is dependent of AutoSize-Property}
      Barcode.internalprint(self.canvas,0,0,@mypoint);
      if AutoSize then
      case Bar_Rotation of
        Rotate_000,Rotate_180: Width:=muldiv(mypoint.x,zoom,100)
        else Height:=muldiv(mypoint.y,zoom,100);
      end;
    end
    else  {calculate alignment, no width changes}
    begin
      // first try: print to invisible coordinates
      Barcode.internalprint(self.canvas,-10000,-10000,@mypoint);
      case Bar_Rotation of
        Rotate_000,Rotate_180:
          begin
            case Alignment of
              taCenter: Barcode.internalprint(self.canvas,(muldiv(width,100,zoom)-mypoint.x)div 2,0,@mypoint);
              taRightJustify: Barcode.internalprint(self.canvas,muldiv(width,100,zoom)-mypoint.x,0,@mypoint);
            end;
{            self.canvas.textout(0,0,format('%d',[zoom]));}
          end;
        else
          begin
            case Alignment of
              taCenter: Barcode.internalprint(self.canvas,0,(muldiv(height,100,zoom)-mypoint.y)div 2,@mypoint);
              taRightJustify: Barcode.internalprint(self.canvas,0,muldiv(height,100,zoom)-mypoint.y,@mypoint);
            end;
          end;
        {end;}
      end;
    end;
    case Bar_Rotation of
      Rotate_000,Rotate_180: Height:=muldiv(mypoint.y,zoom,100);
      else Width:=muldiv(mypoint.x,zoom,100);
    end;
    setmapmode(self.Canvas.handle,mm_text);
  end;
end;
{$else}  {QR 1.0/1.1}
{Normal Paint procedure for old Quickreports v1.0 and v1.1}
procedure TKMQRBarcode.Paint;
var
  mypoint:TPoint;
begin
  if self.canvas<>nil then
  begin
    canvas.brush.color:=color;
    canvas.fillrect(rect(0,0,width,height));
    if Bar_Caption<>GeTTSSBarcodeCaption then Bar_Caption:=GeTTSSBarcodeCaption;
    if AutoSize or (Alignment=taLeftJustify) then
    begin  {width adjustment is dependent of AutoSize-Property}
      Barcode.internalprint(self.canvas,0,0,@mypoint);
      if AutoSize then
      case Bar_Rotation of
        Rotate_000,Rotate_180: Width:=mypoint.x;
        else Height:=mypoint.y;
      end;
    end
    else  {calculate alignment, no width changes}
    begin
      // first try: print to invisible coordinates
      Barcode.internalprint(self.canvas,-10000,-10000,@mypoint);
      case Bar_Rotation of
        Rotate_000,Rotate_180:
          begin
            case Alignment of
              taCenter: Barcode.internalprint(self.canvas,(width-mypoint.x)div 2,0,@mypoint);
              taRightJustify: Barcode.internalprint(self.canvas,width-mypoint.x,0,@mypoint);
            end;
          end;
        else
          begin
            case Alignment of
              taCenter: Barcode.internalprint(self.canvas,0,(height-mypoint.y)div 2,@mypoint);
              taRightJustify: Barcode.internalprint(self.canvas,0,height-mypoint.y,@mypoint);
            end;
          end;
        {end;}
      end;

    end;
    case Bar_Rotation of
      Rotate_000,Rotate_180: Height:=mypoint.y;
      else Width:=mypoint.x;
    end;
  end;
end;
{$endif}

procedure TKMQRBarcode.Print(X,Y : Integer);
var
  value:string;
  mypoint:TPoint;
{$ifdef VER80}
  tempOnPrint:TQRLabelOnPrintEvent;
  tempPtr:Pointer absolute tempOnPrint;
{$endif}
{$ifdef QR_V11}
  scalingXP,scalingYP:Integer;
{$endif}
begin
  value:=GeTBarcodeCaption;    {Get current Bar_caption or Datafield}
//  showmessage(value);
{$ifdef VER80}
  tempOnPrint:=OnPrint;      {Delphi-1 needs some help to compile it}
  {If OnPrint-method is assigned and not designing}
  if (tempptr<>nil) and not (csdesigning in componentstate) then
    OnPrint(self,value);     {Do some user defined actions}
{$else}
  {If OnPrint-method is assigned and not designing}
  if assigned(OnPrint) and not (csdesigning in componentstate) then
    OnPrint(self,value);     {Do some user defined actions}
{$endif}
  {Set new Bar_Caption}
  if bar_caption<>value then bar_caption:=value;
  {If Bar_Caption is to be printed}
  if (Length(bar_caption) > 0) or Bar_PrintEmpty then
  begin
{$ifdef QR_V1}     {Old version for Quickreport 1.x}
{$ifdef QR_V11}  {Only for Quickreports v1.1}
    {384dpi is QR_V11 canvas resolution during preview and printing}
    scalingXP:=384;
    scalingYP:=384;
    setmapmode(QRPrinter.Canvas.handle,mm_anisotropic);
    {96 dpi is the QR1 canvas resolution during showing the form}
    SetWindowExtEx(QRPrinter.Canvas.handle,96,96,nil);
    SetViewportExtEx(QRPrinter.Canvas.handle,scalingXP,scalingYP,nil);
    with parentreport do
    begin
      if AutoSize or (Alignment=taLeftJustify) then
        Barcode.InternalPrint(QRPrinter.Canvas,XPos(X+left)*96 div scalingXP ,
                                               YPos(Y+top)*96 div scalingYP,nil)
      else
        begin
          Barcode.InternalPrint(QRPrinter.canvas,-10000,-10000,@mypoint); {Print it}
          case Bar_Rotation of
            Rotate_000,Rotate_180:
            begin
              case Alignment of
                taCenter: Barcode.internalprint(QRPrinter.canvas,
                                                XPos(x+left+(width-mypoint.x) div 2)*96 div scalingXP,
                                                YPos(y+top)*96 div scalingYP,nil);
                taRightJustify: Barcode.internalprint(QRPrinter.canvas,
                                                      XPos(x+left+width-mypoint.x)*96 div scalingXP,
                                                      YPos(y+top)*96 div scalingYP,nil);
              end;
            end;
          else
            begin
              case Alignment of
                taCenter: Barcode.internalprint(QRPrinter.canvas,
                                                XPos(x+left)*96 div ScalingXP,
                                                YPos(y+top+(height-mypoint.y) div 2)*96 div scalingYP,nil);
                taRightJustify: Barcode.internalprint(QRPrinter.canvas,
                                                      XPos(x+left)*96 div ScalingXP,
                                                      YPos(y+top+height-mypoint.y)*96 div scalingYP,nil);
              end;
            end;
          end;{case}
        end;
    end;
    setmapmode(QRPrinter.Canvas.handle,mm_text);
{$else}  {Only for Quickreports v1.0}
    if AutoSize or (Alignment=taLeftJustify) then
      Barcode.InternalPrint(QRPrinter.canvas,x+left,y+top,nil)
    else
      begin
        Barcode.InternalPrint(QRPrinter.canvas,-10000,-10000,@mypoint); {Print it}
        case Bar_Rotation of
          Rotate_000,Rotate_180:
          begin
            case Alignment of
              taCenter: Barcode.internalprint(QRPrinter.canvas,x+left+(width-mypoint.x) div 2,y+top,nil);
              taRightJustify: Barcode.internalprint(QRPrinter.canvas,x+left+width-mypoint.x,y+top,nil);
            end;
          end;
        else
          begin
            case Alignment of
              taCenter: Barcode.internalprint(QRPrinter.canvas,x+left,y+top+(height-mypoint.y) div 2,nil);
              taRightJustify: Barcode.internalprint(QRPrinter.canvas,x+left,y+top+height-mypoint.y,nil);
            end;
          end;
        end;{case}
      end;
{$endif}  {QR_V11}
{$endif}
{$ifdef QR_V2}   {New version Quickreport 2.x}
    QRPrinter.Canvas.Brush.Color:=Color;
    with Qrprinter do
    begin
      QRPrinter.Canvas.fillrect(rect(Xpos(x+size.left),Ypos(y+size.top),
                                     XPos(x+size.left+size.Width),YPos(y+size.top+size.Height)));

      if AutoSize or (Alignment=taLeftJustify) then
        Barcode.InternalPrint(QRPrinter.canvas,Xpos(x+size.left),Ypos(y+size.top),nil) {Print it}
      else
      begin
        Barcode.InternalPrint(QRPrinter.canvas,-10000,-10000,@mypoint); {Print it}
        case Bar_Rotation of
          Rotate_000,Rotate_180:
          begin
            case Alignment of
              taCenter: Barcode.internalprint(QRPrinter.canvas,Xpos(x+size.left+size.width/2)-mypoint.x div 2,Ypos(y+size.top),nil);
              taRightJustify: Barcode.internalprint(QRPrinter.canvas,Xpos(x+size.left+size.width)-mypoint.x,Ypos(y+size.top),nil);
{              taCenter: Barcode.internalprint(QRPrinter.canvas,Xpos(x+size.left)+(XPos(size.width)-mypoint.x) div 2,Ypos(y+size.top),nil);
              taRightJustify: Barcode.internalprint(QRPrinter.canvas,Xpos(x+size.left+size.width)-mypoint.x,Ypos(y+size.top),nil);}
            end;
          end;
        else
          begin
            case Alignment of
              taCenter: Barcode.internalprint(QRPrinter.canvas,Xpos(x+size.left),Ypos(y+size.top+size.height/2)-mypoint.y div 2,nil);
              taRightJustify: Barcode.internalprint(QRPrinter.canvas,Xpos(x+size.left),Ypos(y+size.top+size.height)-mypoint.y,nil);
            end;
          end;
        end;{case}
      end;
    end;
{$endif}
  end;
end;

function TKMQRBarcode.GetHeightAtRuntime:Integer;
begin
  update;
  case Bar_Rotation of
    rotate_000,rotate_180: result:=height;
    else result:=width;
  end;
end;

{$endif}   {ifdef WITHQUICKREPORT}



procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMBarcode]);
{$ifdef WITHQUICKREPORT}
  RegisterComponents('Kamran Component', [TKMQRBarcode]);
{$endif}
end;

end.
