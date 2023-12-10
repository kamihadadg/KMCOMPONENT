unit UntFARSI;

interface

uses
   Classes;

type
  TKMFarsi = class(TComponent)
  private
    { Private declarations }
    GlobalFont: Array [1..38, 1..5] Of string  ;
    Noandsymbol:Array [1..20] of char ;
    FFarsi:String ;
    FPFE:string ;
    procedure Tabdil (str1: String) ;
    Function Taktak (chr: char ;mode: Integer): Char ;
  protected
    { Protected declarations }
  public
    { Public declarations }

  published
    { Published declarations }
    
    property Farsi: string read FFarsi  write tabdil  ;
    property PFEFont: string read FPFE  write tabdil     ;
    Constructor Create (AOwner: TComponent) ;Override ;
  end;

procedure Register;

implementation


Constructor TKMFarsi.Create (AOwner: TComponent) ;
Begin
  inherited Create (AOwner) ;
  //FFarsi:='˜ÇãÑÇä' ;
  ///////////////////////////////////////////////
  GlobalFont[1, 1]:= 'È' ;
  GlobalFont[1, 2]:= 'F' ;
  GlobalFont[1, 3]:= 'E' ;
  GlobalFont[1, 4]:= '§' ;
  GlobalFont[1, 5]:= '¨' ;
  ///////////////////////////////////////////////
  GlobalFont[2, 1]:= '' ;
  GlobalFont[2, 2]:= 'H' ;
  GlobalFont[2, 3]:= 'G' ;
  GlobalFont[2, 4]:= '©' ;
  GlobalFont[2, 5]:= 'ª' ;
  ///////////////////////////////////////////////
  GlobalFont[3, 1]:= 'Ö' ;
  GlobalFont[3, 2]:= 'b' ;
  GlobalFont[3, 3]:= 'a' ;
  GlobalFont[3, 4]:= 'Ã' ;
  GlobalFont[3, 5]:= 'Ä' ;
  ///////////////////////////////////////////////
  GlobalFont[4, 1]:= 'Õ' ;
  GlobalFont[4, 2]:= '`' ;
  GlobalFont[4, 3]:= '_' ;
  GlobalFont[4, 4]:= 'Á' ;
  GlobalFont[4, 5]:= 'Â' ;
  ///////////////////////////////////////////////
  GlobalFont[5, 1]:= 'Ë' ;
  GlobalFont[5, 2]:= 'M' ;
  GlobalFont[5, 3]:= 'L' ;
  GlobalFont[5, 4]:= '®' ;
  GlobalFont[5, 5]:= '¯' ;
  ///////////////////////////////////////////////
  GlobalFont[6, 1]:= 'Þ' ;
  GlobalFont[6, 2]:= 'n' ;
  GlobalFont[6, 3]:= 'm' ;
  GlobalFont[6, 4]:= 'Ï' ;
  GlobalFont[6, 5]:= 'Ð' ;
  ///////////////////////////////////////////////
  GlobalFont[7, 1]:= 'Ý' ;
  GlobalFont[7, 2]:= 'l' ;
  GlobalFont[7, 3]:= 'k' ;
  GlobalFont[7, 4]:= 'Í' ;
  GlobalFont[7, 5]:= 'Î' ;
  ///////////////////////////////////////////////
  GlobalFont[8, 1]:= 'Û' ;
  GlobalFont[8, 2]:= 'j' ;
  GlobalFont[8, 3]:= 'i' ;
  GlobalFont[8, 4]:= 'Ë' ;
  GlobalFont[8, 5]:= 'Ì' ;
  ///////////////////////////////////////////////
  GlobalFont[9, 1]:= 'Ú' ;
  GlobalFont[9, 2]:= 'h' ;
  GlobalFont[9, 3]:= 'g' ;
  GlobalFont[9, 4]:= 'É' ;
  GlobalFont[9, 5]:= 'Ê' ;
  ///////////////////////////////////////////////
  GlobalFont[10, 1]:= 'å' ;
  GlobalFont[10, 2]:= '{' ;
  GlobalFont[10, 3]:= 'z' ;
  GlobalFont[10, 4]:= 'Ü' ;
  GlobalFont[10, 5]:= 'Ý' ;
  ///////////////////////////////////////////////
  GlobalFont[11, 1]:= 'Î' ;
  GlobalFont[11, 2]:= 'U' ;
  GlobalFont[11, 3]:= 'T' ;
  GlobalFont[11, 4]:= '¶' ;
  GlobalFont[11, 5]:= '·' ;
  ///////////////////////////////////////////////
  GlobalFont[12, 1]:= 'Ì' ;
  GlobalFont[12, 2]:= 'O' ;
  GlobalFont[12, 3]:= 'N' ;
  GlobalFont[12, 4]:= '°' ;
  GlobalFont[12, 5]:= '±' ;
  ///////////////////////////////////////////////
  GlobalFont[13, 1]:= '' ;
  GlobalFont[13, 2]:= 'Q' ;
  GlobalFont[13, 3]:= 'P' ;
  GlobalFont[13, 4]:= '²' ;
  GlobalFont[13, 5]:= '³' ;
  ///////////////////////////////////////////////
  GlobalFont[14, 1]:= '' ;
  GlobalFont[14, 2]:= 'r' ;
  GlobalFont[14, 3]:= 'q' ;
  GlobalFont[14, 4]:= 'Ó' ;
  GlobalFont[14, 5]:= 'Ô' ;
  ///////////////////////////////////////////////
  GlobalFont[15, 1]:= Chr (223) ;
  GlobalFont[15, 2]:= 'p' ;
  GlobalFont[15, 3]:= 'o' ;
  GlobalFont[15, 4]:= 'Ñ' ;
  GlobalFont[15, 5]:= 'Ò' ;
  ///////////////////////////////////////////////
  GlobalFont[16, 1]:= 'ã' ;
  GlobalFont[16, 2]:= 'v' ;
  GlobalFont[16, 3]:= 'u' ;
  GlobalFont[16, 4]:= '×' ;
  GlobalFont[16, 5]:= 'Ø' ;
  ///////////////////////////////////////////////
  GlobalFont[17, 1]:= 'ä' ;
  GlobalFont[17, 2]:= 'x' ;
  GlobalFont[17, 3]:= 'w' ;
  GlobalFont[17, 4]:= 'Ù' ;
  GlobalFont[17, 5]:= 'Ú' ;
  ///////////////////////////////////////////////
  GlobalFont[18, 1]:= 'Ê' ;
  GlobalFont[18, 2]:= 'K' ;
  GlobalFont[18, 3]:= 'J' ;
  GlobalFont[18, 4]:= '¬' ;
  GlobalFont[18, 5]:= '­' ;
  ///////////////////////////////////////////////
  GlobalFont[19, 1]:= 'á' ;
  GlobalFont[19, 2]:= 't' ;
  GlobalFont[19, 3]:= 's' ;
  GlobalFont[19, 4]:= 'Õ' ;
  GlobalFont[19, 5]:= 'Ö' ;
  ///////////////////////////////////////////////
  GlobalFont[20, 1]:= 'í' ; 
  GlobalFont[20, 2]:= '}' ;
  GlobalFont[20, 3]:= '|' ;
  GlobalFont[20, 4]:= 'Þ' ;
  GlobalFont[20, 5]:= 'ß' ;
  ///////////////////////////////////////////////
  GlobalFont[21, 1]:= 'Ó' ;
  GlobalFont[21, 2]:= '\' ;
  GlobalFont[21, 3]:= '[' ;
  GlobalFont[21, 4]:= '½' ;
  GlobalFont[21, 5]:= '¾' ;
  ///////////////////////////////////////////////
  GlobalFont[22, 1]:= 'Ô' ;
  GlobalFont[22, 2]:= '^' ;
  GlobalFont[22, 3]:= ']' ;
  GlobalFont[22, 4]:= '¿' ;
  GlobalFont[22, 5]:= 'À' ;
  ///////////////////////////////////////////////
  GlobalFont[23, 1]:= 'æ' ;
  GlobalFont[23, 2]:= 'y' ;
  GlobalFont[23, 3]:= '0' ;
  GlobalFont[23, 4]:= '0' ;
  GlobalFont[23, 5]:= 'Û' ;
  ///////////////////////////////////////////////
  GlobalFont[24, 1]:= 'Æ' ;
  GlobalFont[24, 2]:= 'D' ;
  GlobalFont[24, 3]:= 'C' ;
  GlobalFont[24, 4]:= '¥' ;
  GlobalFont[24, 5]:= '¦' ;
  ///////////////////////////////////////////////
  GlobalFont[25, 1]:= 'Ï' ;
  GlobalFont[25, 2]:= 'V' ;
  GlobalFont[25, 3]:= '0' ;
  GlobalFont[25, 4]:= '0' ;
  GlobalFont[25, 5]:= '¸' ;
  ///////////////////////////////////////////////
  GlobalFont[26, 1]:= 'Ð' ;
  GlobalFont[26, 2]:= 'W' ;
  GlobalFont[26, 3]:= '0' ;
  GlobalFont[26, 4]:= '0' ;
  GlobalFont[26, 5]:= '¹' ;
  ///////////////////////////////////////////////
  GlobalFont[27, 1]:= 'Ñ' ;
  GlobalFont[27, 2]:= 'X' ;
  GlobalFont[27, 3]:= '0' ;
  GlobalFont[27, 4]:= '0' ;
  GlobalFont[27, 5]:= 'º' ;
  ///////////////////////////////////////////////
  GlobalFont[28, 1]:= 'Ò' ;
  GlobalFont[28, 2]:= 'Y' ;
  GlobalFont[28, 3]:= '0' ;
  GlobalFont[28, 4]:= '0' ;
  GlobalFont[28, 5]:= '»' ;
  ///////////////////////////////////////////////
  GlobalFont[29, 1]:= 'Ø' ;
  GlobalFont[29, 2]:= 'd' ;
  GlobalFont[29, 3]:= 'c' ;
  GlobalFont[29, 4]:= 'Å' ;
  GlobalFont[29, 5]:= 'Æ' ;
  ///////////////////////////////////////////////
  GlobalFont[30, 1]:= 'Ù' ;
  GlobalFont[30, 2]:= 'f' ;
  GlobalFont[30, 3]:= 'e' ;                    
  GlobalFont[30, 4]:= 'Ç' ;
  GlobalFont[30, 5]:= 'È' ;
  ///////////////////////////////////////////////
  GlobalFont[31, 1]:= 'Ž' ;
  GlobalFont[31, 2]:= 'Z' ;
  GlobalFont[31, 3]:= '0' ;
  GlobalFont[31, 4]:= '0' ;
  GlobalFont[31, 5]:= '¼' ;
  ///////////////////////////////////////////////
  GlobalFont[32, 1]:= 'Ç' ;
  GlobalFont[32, 2]:= '>' ;
  GlobalFont[32, 3]:= '0' ;
  GlobalFont[32, 4]:= '0' ;
  GlobalFont[32, 5]:= '¡' ;
  ///////////////////////////////////////////////
  GlobalFont[33, 1]:= 'Í' ;
  GlobalFont[33, 2]:= 'S' ;
  GlobalFont[33, 3]:= 'R' ;
  GlobalFont[33, 4]:= '´' ;
  GlobalFont[33, 5]:= 'µ' ;
  ///////////////////////////////////////////////
  GlobalFont[34, 1]:= Chr (152) ;
  GlobalFont[34, 2]:= 'p' ;
  GlobalFont[34, 3]:= 'o' ;
  GlobalFont[34, 4]:= 'Ñ' ;
  GlobalFont[34, 5]:= 'Ò' ;
  //////////////////////////////////////////////
  GlobalFont[35, 1]:= 'Â' ;
  GlobalFont[35, 2]:= '=' ;
  GlobalFont[35, 3]:= '0' ;
  GlobalFont[35, 4]:= '0' ;
  GlobalFont[35, 5]:= '¡' ;
  ///////////////////////////////////////////////
  GlobalFont[36, 1]:= '¿' ;
  GlobalFont[36, 2]:= Chr (39) ;
  GlobalFont[36, 3]:= Chr (39) ;                
  GlobalFont[36, 4]:= Chr (39) ;
  GlobalFont[36, 5]:= Chr (39) ;
  ///////////////////////////////////////////////
  GlobalFont[37, 1]:= ':' ;
  GlobalFont[37, 2]:= '&' ;
  GlobalFont[37, 3]:= '&' ;
  GlobalFont[37, 4]:= '&' ;
  GlobalFont[37, 5]:= '&' ;
  ///////////////////////////////////////////////
  GlobalFont[38, 1]:= 'Ä' ;
  GlobalFont[38, 2]:= '%' ;
  GlobalFont[38, 3]:= '%' ;
  GlobalFont[38, 4]:= '%' ;
  GlobalFont[38, 5]:= '%' ;
  
  ////////////////////////////////NOandsymbol/////////////////////
  Noandsymbol[1]:='0';
  Noandsymbol[2]:='1';
  Noandsymbol[3]:='2';
  Noandsymbol[4]:='3';
  Noandsymbol[5]:='4';
  Noandsymbol[6]:='5';
  Noandsymbol[7]:='6';
  Noandsymbol[8]:='7';
  Noandsymbol[9]:='8';
  Noandsymbol[10]:='9';
  Noandsymbol[11]:='(';
  Noandsymbol[12]:=')';
  Noandsymbol[13]:='.';
  Noandsymbol[14]:=' ';
  //Noandsymbol[14]:='-';
  //Noandsymbol[14]:='+';
  //Noandsymbol[14]:=' ';


End ;

function TKMFarsi.taktak(chr:char;mode:Integer):char ;
var
   i,j:integer ;
   hichi,aval,vasat,akhar:string ;
begin
  Result:= ' ' ;
  for i:=1 to 38 do Begin
      hichi:= GlobalFont[i,2] ;
      aval:=GlobalFont[i,3] ;
      vasat:=GlobalFont[i,4] ;
      akhar:=GlobalFont[i,5] ;
      for j:=1 to 14 do
      if chr = Noandsymbol[j]  then Begin
         taktak:=Noandsymbol[j] ;
      End ;
      {if i = 35 then Begin
         Showmessage (IntToStr (Ord (GlobalFont[i,1][1]))) ;
         Showmessage (IntToStr (Ord (chr))) ;
      End ;}

      if chr=GlobalFont[i,1] then Begin
         case mode of
              1:taktak:=hichi[1] ;
              2:taktak:=aval[1] ;
              3:taktak:=vasat[1] ;
              4:taktak:=akhar[1] ;
         End ;

      End ; // if chr=GlobalFont[i,1]
   End ;
end ;

procedure TKMFarsi.tabdil(Str1:string) ;
var
   i:integer ;
   s:String  ;

begin

   for i:=1to Length(str1) do

   begin
      if ((str1[i]='Â')or(str1[i]='Ç')or(str1[i]=' ')or(str1[i]='Ï')
       or(str1[i]='Ð')or(str1[i]='æ')or(str1[i]='Ñ')or(str1[i]='Ò')
       or(str1[i]='Ž')or(str1[i]='0')or(str1[i]='1')or(str1[i]='2')
       or(str1[i]='3')or(str1[i]='4')or(str1[i]='5')or(str1[i]='6')
       or(str1[i]='7')or(str1[i]='8')or(str1[i]='9')or(str1[i]='(')
       or(str1[i]=')')or(str1[i]=':')or(str1[i]='¿')or(str1[i]='.')or(str1[i]='Ä')) then
      begin
         if (i=1)then////////////////////aval////////////////////////
         begin
            s:=taktak(str1[i],1)+s;
         end
         else
         begin
            /////////////////////////////vasat////////////////////
            if (i>1)and(i<>Length(str1))and((str1[i-1]='Â')or(str1[i-1]='Ç')
              or(str1[i-1]=' ')or(str1[i-1]='Ï')or(str1[i-1]='æ')or(str1[i-1]='Ð')
              or(str1[i-1]='Ñ')or(str1[i-1]='Ò')or(str1[i-1]='Ž')
              or(str1[i-1]='0')or(str1[i-1]='1')or(str1[i-1]='2')
              or(str1[i-1]='3')or(str1[i-1]='4')or(str1[i-1]='5')or(str1[i-1]='6')
              or(str1[i-1]='7')or(str1[i-1]='8')or(str1[i-1]='9')or(str1[i-1]='(')
              or(str1[i-1]=')')or(str1[i-1]=':')or(str1[i-1]='¿')or(str1[i-1]='.')or(str1[i-1]='Ä'))then


            begin
               s:=taktak(str1[i],1)+s;
            end
            else
            begin
               //////////////////////////akhar////////////////////
               if ((str1[i-1]='Â')or(str1[i-1]='Ç')or(str1[i-1]=' ')or(str1[i-1]='Ï')
                 or(str1[i-1]='æ')or(str1[i-1]='Ð')or(str1[i-1]='Ñ')or(str1[i-1]='Ò')
                 or(str1[i-1]='Ž')or(str1[i-1]='0')or(str1[i-1]='1')or(str1[i-1]='2')
                 or(str1[i-1]='3')or(str1[i-1]='4')or(str1[i-1]='5')or(str1[i-1]='6')
                 or(str1[i-1]='7')or(str1[i-1]='8')or(str1[i-1]='9')or(str1[i-1]='(')
                 or(str1[i-1]=')')or(str1[i-1]=':')or(str1[i-1]='¿')or(str1[i-1]='Ä')or(str1[i-1]='.'))then
                  s:=taktak(str1[i],1)+s
               else
                  s:=taktak(str1[i],4)+s;
            end ;
         end;
      end
 //yfggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg//////////
      else
      begin
         /////////////////takharfi////////////
         if (Length(str1)=1) then
         begin
            s:=taktak(str1[i],1)+s ;
         end /////////////////////chandharfi///////////////////////
         else
         begin

            if (Length(str1)>1)  then
            begin

               if i=1 then ///////////////////aval/////////////////////////
               begin
                  if ((str1[i]='Â')or(str1[i]='Ç')or(str1[i]=' ')or(str1[i]='Ï')
                     or(str1[i]='Ð')or(str1[i]='æ')or(str1[i]='Ñ')or(str1[i]='Ò')
                     or(str1[i]='Ž')or(str1[i]='0')or(str1[i]='1')or(str1[i]='2')
                     or(str1[i]='3')or(str1[i]='4')or(str1[i]='5')or(str1[i]='6')
                     or(str1[i]='7')or(str1[i]='8')or(str1[i]='9')or(str1[i]='(')
                     or(str1[i]=')')or(str1[i]=':')or(str1[i]='¿')or(str1[i]='Ä')or(str1[i]='.'))   then
                     s:=taktak(str1[i],1)+s
                  else
                     s:=taktak(str1[i],2)+s

               end ;

            /////////////////////vasat///////////////////////

               if (i>1)and(i<Length(str1))then
               begin
                  if ((str1[i-1]='Â')or(str1[i-1]='Ç')or(str1[i-1]=' ')or(str1[i-1]='Ï')
                 or(str1[i-1]='æ')or(str1[i-1]='Ð')or(str1[i-1]='Ñ')or(str1[i-1]='Ò')
                 or(str1[i-1]='Ž')or(str1[i-1]='0')or(str1[i-1]='1')or(str1[i-1]='2')
                 or(str1[i-1]='3')or(str1[i-1]='4')or(str1[i-1]='5')or(str1[i-1]='6')
                 or(str1[i-1]='7')or(str1[i-1]='8')or(str1[i-1]='9')or(str1[i-1]='(')
                 or(str1[i-1]=')')or(str1[i-1]=':')or(str1[i-1]='¿')or(str1[i-1]='Ä')or(str1[i-1]='.')) then
                     if ((str1[i+1]=' ')or(str1[i+1]='0')or(str1[i+1]='1')or(str1[i+1]='2')
                         or(str1[i+1]='3')or(str1[i+1]='4')or(str1[i+1]='5')or(str1[i+1]='6')
                         or(str1[i+1]='7')or(str1[i+1]='8')or(str1[i+1]='9')or(str1[i+1]='(')
                         or(str1[i+1]=')')or(str1[i+1]=':')or(str1[i+1]='¿')or(str1[i+1]='Ä')or(str1[i+1]='.'))then
                        s:=taktak(str1[i],1)+s
                     else
                        s:=taktak(str1[i],2)+s
                  else
                     if ((str1[i+1]=' ')or(str1[i+1]='0')or(str1[i+1]='1')or(str1[i+1]='2')
                         or(str1[i+1]='3')or(str1[i+1]='4')or(str1[i+1]='5')or(str1[i+1]='6')
                         or(str1[i+1]='7')or(str1[i+1]='8')or(str1[i+1]='9')or(str1[i+1]='(')
                         or(str1[i+1]=')')or(str1[i+1]=':')or(str1[i+1]='¿')or(str1[i+1]='Ä')or(str1[i+1]='.'))then
                        s:=taktak(str1[i],4)+s
                     else
                        s:=taktak(str1[i],3)+s ;
               end ;
               ///////////////////akhar///////////////////
               if (i>1)and(i=Length(str1)) then
               begin
                  if ((str1[i-1]='Â')or(str1[i-1]='Ç')or(str1[i-1]=' ')or(str1[i-1]='Ï')
                 or(str1[i-1]='æ')or(str1[i-1]='Ð')or(str1[i-1]='Ñ')or(str1[i-1]='Ò')
                 or(str1[i-1]='Ž')or(str1[i-1]='0')or(str1[i-1]='1')or(str1[i-1]='2')
                 or(str1[i-1]='3')or(str1[i-1]='4')or(str1[i-1]='5')or(str1[i-1]='6')
                 or(str1[i-1]='7')or(str1[i-1]='8')or(str1[i-1]='9')or(str1[i-1]='(')
                 or(str1[i-1]=')')or(str1[i-1]=':')or(str1[i-1]='¿')or(str1[i-1]='Ä')or(str1[i-1]='.')) then
                     s:=taktak(str1[i],1)+s
                  else
                     s:=taktak(str1[i],4)+s;
               end ;
            end ;
         end ;
      end ;
    end ;
   FPFE :=s ;
end ;


procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMFarsi]);
end;

end.
 
