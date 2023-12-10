unit UntMSGDLG ;

interface

uses

  Windows,Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls ;

type
  TGLCustomIconType = (itApplication, itComponent, itParentForm) ;

  TGLMessageBeepType = (mbtConfirmation, mbtDefault, mbtError,
                        mbtInformation, mbtNone, mbtWarning);

  TKMMsgdlg = class(TComponent)
  private
     Ffont:String;
     FButtonNames : TStringList ;
     FButtonHeight : integer ;
     FButtonSpacing : integer ;
     FBoldCaptions : boolean ;
     FCenter : boolean ;
     FCustomIconType : TGLCustomIconType ;
     FIcon : TIcon ;
     FMinCaptionMargin : integer ;
     FMinDlgWidth : integer ;
     FReturnValue : integer ;
     FPrompt : string ;
     FTitle : string ;
     FIconType : TMsgDlgType ;
     FInitialButton : integer ;
     FOnShow : TNotifyEvent ;
     FOnClose : TNotifyEvent ;
     FTrapMouse : boolean ;
     FSound : TGLMessageBeepType ;
     FBidiModee:TBiDiMode ;
     procedure ClickButton(Sender: TObject);
     procedure BoldOn(Sender : TObject) ;
     procedure BoldOff(Sender : TObject) ;
     procedure SetInitialButton(i : integer) ;
     procedure MouseTrap(Sender: TObject; Shift: TShiftState; X, Y: Integer) ;
     procedure SetIcon(i : TIcon) ;
     procedure SetButtonNames(s : TStringList) ;
     procedure FormKeyDown(Sender : TObject ; var Key: Word; Shift: TShiftState) ;
     Procedure SetBidiMode(ABidimode:TBiDiMode);
  public
     constructor Create(AOwner : TComponent) ; override ;
     destructor Destroy ; override ;
     function Execute : integer ;
  published
     property Font : string read Ffont write Ffont;
     property BoldCaptions : boolean read FBoldCaptions write FBoldCaptions default False ;
     property ButtonNames : TStringList read FButtonNames
                                        write SetButtonNames ;
     property ButtonHeight : integer read FButtonHeight write FButtonHeight default 22 ;
     property ButtonSpacing : integer read FButtonSpacing write FButtonSpacing default 5 ;
     property CenterOnParent : boolean read FCenter write FCenter default False ;
     property CustomIconType : TGLCustomIconType read FCustomIconType write FCustomIconType default itApplication ;
     property Icon : TIcon read FIcon write SetIcon ;
     property IconType : TMsgDlgType read FIconType write FIconType ;
     property InitialButton : integer read FInitialButton
                                      write SetInitialButton default 0 ;
     property MinimumCaptionMargin : integer read FMinCaptionMargin
                                        write FMinCaptionMargin default 5;
     property MinimumDialogWidth : integer read FMinDlgWidth write FMinDlgWidth default 0 ;
     property OnClose : TNotifyEvent read FOnClose write FOnClose ;
     property OnShow : TNotifyEvent read FOnShow write FOnShow ;
     property Prompt : string read FPrompt write FPrompt ;
     property SoundType : TGLMessageBeepType read FSound write FSound default mbtNone ;
     property Title : string read FTitle write FTitle ;
     property TrapMouse : boolean read FTrapMouse write FTrapMouse default False ;
     property BidiMode : TBiDiMode read FBidiModee write FBidiModee default bdRightToLeft ;
  end;


procedure Register;

implementation

constructor TKMMsgdlg.Create(AOwner : TComponent) ;
begin
     inherited Create(AOwner) ;
     FButtonNames := TStringList.Create ;
     FButtonHeight     := 22 ;
     FButtonSpacing    := 5 ;
     FMinCaptionMargin := 5 ;
     FPrompt := 'Your message goes here' ;
     FTitle := 'Your title goes here' ;
     FSound := mbtNone ;
     FBidiModee:=bdRightToLeft ;
     FIcon := TIcon.Create ;
     Ffont:='tahoma' ;
{$IFDEF SHOW_COPYRIGHT}
     if csDesigning in ComponentState then
        MessageDlg('TKMMsgdlg - Copyright © 1998 Greg Lief',
                   mtInformation, [mbOK], 0) ;
{$ENDIF}
end ;

destructor TKMMsgdlg.Destroy ;
begin
     FButtonNames.Free ;
     FIcon.Free ;
     inherited Destroy ;
end ;

procedure TKMMsgdlg.SetBidiMode(ABidimode: TBiDiMode);
begin

end;

procedure TKMMsgdlg.SetButtonNames(s : TStringList) ;
begin
     FButtonNames.Assign(s) ;
end ;

procedure TKMMsgdlg.SetIcon(i : TIcon) ;
begin
     FIcon.Assign( i ) ;
     FCustomIconType := itComponent ;
     FIconType := mtCustom ;
end ;

function TKMMsgdlg.Execute : integer ;
var
   TheForm : TForm ;
   TheLabel: TLabel ;
   TheImage : TImage ;
   b : TButton ;
   x : integer ;
   iPos          : integer ;
   iCaptionWidth : integer ;
   iPosition     : integer ;
   ButtonTop     : integer ;
   bResetWidth   : boolean ;
   iMaxWidth     : integer ;
const
   IMAGE_MARGIN   = 14 ;
begin
     { no buttons specified?  adios, muchachos! }
     if FButtonNames.Count = 0 then begin
        Result := -1 ;
        Exit ;
     end ;
     { now that THEY're gone, we may safely proceed... }
     iPosition := 12;
     TheForm := TForm.Create(nil) ;
     TheForm.Font.Name:=Ffont ;
     /////////////////////////////kamran/////////////////
     TheForm.BiDiMode:=FBidiModee ;
     
     TheForm.Caption := FTitle ;
     TheForm.OnKeyDown := FormKeyDown ;
     TheForm.KeyPreview := True ;
     if not FCenter then
        TheForm.Position := poScreenCenter ;
     TheForm.BorderStyle := bsDialog ;
     TheForm.BorderIcons := [biSystemMenu] ;
     TheForm.Icon := nil ;
     TheForm.ShowHint := True ;

     TheImage := TImage.Create(TheForm) ;
     TheImage.AutoSize := True ;
     TheImage.Parent := TheForm ;
     TheImage.Left := IMAGE_MARGIN ;
     TheImage.Top := IMAGE_MARGIN  ;

     with TheImage.Picture.Icon do
        case FIconType of
           mtWarning:      Handle := LoadIcon(0, IDI_EXCLAMATION) ;
           mtError:        Handle := LoadIcon(0, IDI_HAND) ;
           mtInformation:  Handle := LoadIcon(0, IDI_ASTERISK) ;
           mtConfirmation: Handle := LoadIcon(0, IDI_QUESTION) ;
           mtCustom:       case FCustomIconType of
                              itApplication : Assign( Application.Icon ) ;
                              itComponent   : if FIcon.Handle <> 0 then
                                                 Assign( FIcon )
                                              else
                                                 Handle := LoadIcon(0, IDI_APPLICATION) ;
                              itParentForm  : Assign( (Owner as TForm).Icon ) ;
                           end ;
        end ;

     TheLabel := TLabel.Create(TheForm)  ;
     TheLabel.Parent := TheForm ;   { CRUCIAL!!!!!!! }
     TheLabel.Top := IMAGE_MARGIN ;
     ///////////////////////////kamran
     ///  i
     ///
     if FBidiModee=bdRightToLeft then
     begin
       TheLabel.Alignment:=taRightJustify ;
     end
     else
     begin
      TheLabel.Alignment:=taLeftJustify ;

     end;

     TheLabel.Left := TheImage.Left + TheImage.Width + IMAGE_MARGIN ;
     TheLabel.Caption := FPrompt ;

     if TheImage.Height > TheLabel.Height then
        ButtonTop := TheImage.Height
     else
        ButtonTop := TheLabel.Height ;

     Inc(ButtonTop, 29) ;

     bResetWidth := False ;

     iMaxWidth   := 0 ;

     for x := 0 to FButtonNames.Count - 1 do begin
        b := TButton.Create(TheForm) ;
        b.Name := 'Button' + IntToStr(x) ;
        b.Height := FButtonHeight ;
        b.Tag := x ;
        b.Top := ButtonTop ;
        if FTrapMouse then
           b.OnMouseMove := MouseTrap ;
        if FBoldCaptions then begin
           b.OnEnter := BoldOn ;
           b.OnExit := BoldOff ;
        end ;
        b.Left := iPosition ;
        b.Parent := TheForm ;    { CRUCIAL!!!!! }

        if b.Width > iMaxWidth then
           iMaxWidth := b.Width ;

        { look for embedded hint }
        iPos := Pos( '|', FButtonNames.Strings[x] ) ;
        if iPos > 0 then begin
           b.Caption := Copy( FButtonNames.Strings[x], 1, iPos - 1 ) ;
           b.Hint    := Copy( FButtonNames.Strings[x], iPos + 1,
                        Length( FButtonNames.Strings[x] ) ) ;
        end
        else
           b.Caption := FButtonNames.Strings[x] ;

        iCaptionWidth := TheForm.Canvas.TextWidth( b.Caption ) ;
        if iCaptionWidth + ( FMinCaptionMargin * 2 ) > iMaxWidth then begin
           iMaxWidth := iCaptionWidth + ( FMinCaptionMargin * 2 ) ;
           bResetWidth := True ;
        end ;

        b.OnClick := ClickButton ;
        b.ModalResult := mrOK ;
        Inc(iPosition, b.Width + FButtonSpacing) ;
     end ;
     { reset button widths if necessary }
     if bResetWidth then begin
        iPosition := 12 ;
        for x := 0 to FButtonNames.Count - 1 do begin
           with (TheForm.FindComponent('Button' + IntToStr(x)) as TButton) do begin
              Width := iMaxWidth ;
              Left  := iPosition ;
           end ;
           Inc(iPosition, iMaxWidth + FButtonSpacing) ;
        end ;
     end ;

     with TheForm.FindComponent('Button0') as TButton do
        TheForm.Height := Top + Height + (IMAGE_MARGIN * 3) - 1 ;

     TheForm.Width := iPosition + 12 ;

     { make sure message doesn't get truncated! }
     if TheForm.Width < TheLabel.Left + TheLabel.Width + IMAGE_MARGIN then begin
        { determine difference between current form width and soon-to-be form width }
        iPosition := (TheLabel.Left + TheLabel.Width + IMAGE_MARGIN - TheForm.Width) div 2 ;
        TheForm.Width := TheLabel.Left + TheLabel.Width + IMAGE_MARGIN ;
        { adjust button positions }
        for x := 0 to FButtonNames.Count - 1 do
           with (TheForm.FindComponent('Button' + IntToStr(x)) as TButton) do
              Left := Left + iPosition ;
     end ;

     { ensure that form meets desired minimum width requirement }
     if TheForm.Width < FMinDlgWidth then begin
        { determine difference between current form width and soon-to-be form width }
        iPosition := (FMinDlgWidth - TheForm.Width) div 2 ;
        TheForm.Width := FMinDlgWidth ;
        { adjust button positions }
        for x := 0 to FButtonNames.Count - 1 do
           with (TheForm.FindComponent('Button' + IntToStr(x)) as TButton) do
              Left := Left + iPosition ;
     end ;

     { center dialog upon its parent form if requested }
     if FCenter then begin
        TheForm.Top  := (Owner as TForm).Top + ((Owner as TForm).Height - TheForm.Height) div 2 ;
        TheForm.Left := (Owner as TForm).Left + ((Owner as TForm).Width - TheForm.Width) div 2 ;
     end ;
       ////////////////////////kamran////////////////////
       TheLabel.Left:=TheForm.Width-TheLabel.Width-20 ;


     try
        TheForm.ActiveControl := TheForm.FindComponent(
                                 'Button' + IntToStr(FInitialButton)) as TWinControl ;
        case FSound of
           mbtConfirmation: MessageBeep(MB_ICONQUESTION) ;
           mbtDefault:      MessageBeep(MB_OK) ;
           mbtError:        MessageBeep(MB_ICONHAND) ;
           mbtInformation:  MessageBeep(MB_ICONASTERISK) ;
           mbtWarning:      MessageBeep(MB_ICONEXCLAMATION) ;
        end ;

        FReturnValue := -1 ;
        if Assigned(FOnShow) then FOnShow( self ) ;
        TheForm.ShowModal ;
     finally
        TheForm.Release ;
     end ;
     if Assigned(FOnClose) then FOnClose( self ) ;
     Result := FReturnValue ;
end ;

procedure TKMMsgdlg.FormKeyDown(Sender : TObject ; var Key: Word ; Shift: TShiftState) ;
begin
     if Key = 27 then
        (Sender as TForm).ModalResult := mrCancel ;
end ;

procedure TKMMsgdlg.SetInitialButton(i : integer) ;
begin
     if (i < FButtonNames.Count) and (i > -1) then
        FInitialButton := i
     else if csDesigning in ComponentState then
        MessageDlg('You do not have that many buttons!', mtError, [mbOK], 0) ;
end ;

procedure TKMMsgdlg.ClickButton(Sender: TObject);
begin
     FReturnValue := (Sender as TButton).Tag ;
end;

procedure TKMMsgdlg.MouseTrap(Sender: TObject; Shift: TShiftState; X, Y: Integer) ;
begin
     (Sender as TButton).SetFocus ;
end ;

procedure TKMMsgdlg.BoldOn(Sender : TObject) ;
begin
     (Sender as TButton).Font.Style := (Sender as TButton).Font.Style + [fsBold] ;
end ;

procedure TKMMsgdlg.BoldOff(Sender : TObject) ;
begin
     (Sender as TButton).Font.Style := (Sender as TButton).Font.Style - [fsBold] ;
end ;

procedure Register;
begin
  RegisterComponents('Kamran Component', [TKMMsgdlg]);
end;

end.
