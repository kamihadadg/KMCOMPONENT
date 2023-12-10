unit KMPaqnell;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ExtCtrls;

type
  TKMPanel = class(TPanel)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMPanel]);
end;

end.
