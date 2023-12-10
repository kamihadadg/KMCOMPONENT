unit UntLogfile;

interface

uses
   SysUtils,Classes;

type
  
  TKMLogfile = class(TComponent)
  private
    { Private declarations }
    FFilePath: string;
    FFileExtended: String;
    procedure SetFileLocation(Location: string);
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    property FileLocation: string read FFilePath  write FFilePath;
    property FileExtended: string read FFileExtended write FFileExtended;
    procedure Logfile(filename:string;fael:string;mafool:string;ptime:String;pdate:String);
    Constructor Create (AOwner: TComponent) ;Override ;
  end;

procedure Register;

implementation
Constructor TKMLogfile.Create (AOwner: TComponent) ;
Begin
  inherited Create (AOwner) ;
  FFileExtended:='Log';
End ;
procedure TKMLogfile.Logfile(filename:string;fael:string;mafool:string;ptime:String;pdate:String);
var
  f:TextFile ;
begin
  SetFileLocation(FFilepath);
  if not DirectoryExists(FFilepath+'log\') then
    CreateDir(FFilepath+'log\') ;
  AssignFile(f,FFilepath+'log\'+filename+'.'+FFileExtended);
  if FileExists(FFilepath+'log\'+filename+'.'+FFileExtended)then
    append(f)
  else
  begin
    rewrite(f)  ;
    writeln(f,'   Date       Time    User   Logparameter      (writen by Kamihadad@yahoo.com)');
    writeln(f,'----------------------------------------------') ;
  end ;
  writeln(f,'['+pDate+'];'+'['+pTime+'];'+'['+fael+'];'+mafool+' ;');
  closefile(f);


end ;

procedure TKMLogfile.SetFileLocation(Location: String );
//var
  //dirbrowse:TCustomFileRun ;
begin
  //dirbrowse:=TCustomFileRun.Create(nil);
  //dirbrowse.Execute ;
  //FFilePath:= dirbrowse.Directory ;
  //dirbrowse.Free ;
end;


procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMLogfile]);
end;

end.



