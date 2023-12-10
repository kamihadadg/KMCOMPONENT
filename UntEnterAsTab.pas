unit UntEnterAsTab;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls,Graphics;

type
  TKMEnterAsTab = class(TGraphicControl)
  private
    FBmp: TBitmap;
    FAllowDefault: Boolean;
    FEnterAsTab: Boolean;
    procedure SetAllowDefault(const Value: Boolean);
    procedure SetEnterAsTab(const Value: Boolean);
    { Private declarations }
  protected
    procedure Paint; override;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;

    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer;
      AHeight: Integer); override;
    { Public declarations }
  published
    property EnterAsTab: Boolean  read FEnterAsTab write SetEnterAsTab default True;
    property AllowDefault: Boolean  read FAllowDefault write SetAllowDefault default True;

    { Published declarations }
  end;

procedure Register;

implementation
uses
  Forms, StdCtrls;

procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMEnterAsTab]);
end;

{ TKMEnterAsTab }

procedure TKMEnterAsTab.CMDialogKey(var Message: TCMDialogKey);
begin
  if (GetParentForm(Self).ActiveControl is TButtonControl) and (FAllowDefault) then
    inherited
  else if (Message.CharCode = VK_RETURN) and (FEnterAsTab) then
  begin
    GetParentForm(Self).Perform(CM_DIALOGKEY, VK_TAB, 0);
    Message.Result := 1;
  end
  else
    inherited;
end;

constructor TKMEnterAsTab.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNoStdEvents, csFixedHeight, csFixedWidth];
  FEnterAsTab := True;
  FAllowDefault := True;
  if (csDesigning in ComponentState) then begin
    FBmp := TBitmap.Create;
    FBmp.LoadFromResourceName(hInstance, 'TKMENTERASTAB_BMP');
  end else begin
    Visible := false;
  end;
end;

destructor TKMEnterAsTab.Destroy;
begin
  FBmp.Free;
  inherited;
end;

procedure TKMEnterAsTab.Paint;
begin
  if not (csDesigning in ComponentState) then
    Exit;
  Canvas.Brush.Color := clBtnFace;
  inherited Canvas.BrushCopy(ClientRect, FBmp, ClientRect, clFuchsia);
end;

procedure TKMEnterAsTab.SetAllowDefault(const Value: Boolean);
begin
  FAllowDefault := Value;
end;

procedure TKMEnterAsTab.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited SetBounds(ALeft, ATop, 28, 28);
end;

procedure TKMEnterAsTab.SetEnterAsTab(const Value: Boolean);
begin
  FEnterAsTab := Value;
end;

end.
