unit OpticMatchScan;

//{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpticPlot, StdCtrls, OPAglobal, ASaux;

type
  TsetMatchScan = class(TForm)
    ButGo: TButton;
    butcan: TButton;
    edMin: TEdit;
    labMin: TLabel;
    edMax: TEdit;
    labMax: TLabel;
    labNsteps: TLabel;
    EdNstep: TEdit;
    combosel: TComboBox;
    procedure butcanClick(Sender: TObject);
    procedure ButGoClick(Sender: TObject);
    procedure comboselChange(Sender: TObject);
    procedure edKeyPress(Sender: TObject; var Key: Char);
    procedure edExit(Sender: TObject);
  private
    index: array of integer;
    procedure Exit;
  public
    procedure Load;
  end;

var
  setMatchScan: TsetMatchScan;

implementation

{$R *.lfm}


procedure TsetMatchScan.Load;
var
  i: integer;
begin
  index:=nil;
  with combosel do begin
    for i:=1 to nMatchFunc do if scanpar[i].act then begin
      Items.Add(scanpar[i].nam);
      setlength(index, length(index)+1);
      index[High(index)]:=i;
    end;
  end;
  iscan:=-1;
  edMin.Enabled:=false; edMax.Enabled:=false; edNstep.enabled:=False;
end;

procedure TsetMatchScan.Exit;
begin
  Close;
  setMatchScan:=nil;
end;

procedure TsetMatchScan.butcanClick(Sender: TObject);
begin
 iscan:=-1;
 Exit;
end;

procedure TsetMatchScan.ButGoClick(Sender: TObject);
var
  val: real;
  flag: boolean;
begin
  flag:=false;
  iscan:=index[combosel.ItemIndex];
  if iscan > -1 then begin
    if TEReadVal(edMin,val,8,4) then scanpar[iscan].minval:=val else flag:=true;
    if TEReadVal(edMax,val,8,4) then scanpar[iscan].maxval:=val else flag:=true;
    if TEReadVal(edNstep,val,8,0) then scanpar[iscan].nstep:=round(val) else flag:=true;
  end;
  if not flag then Exit;
end;

procedure TsetMatchScan.comboselChange(Sender: TObject);
begin
  with combosel do begin
    if ItemIndex > -1 then begin
      iscan:=index[ItemIndex];
      edMin.Enabled:=true; edMax.Enabled:=true; edNstep.enabled:=true;
      edMin.Text:=FtoS(scanpar[iscan].minval,8,4);
      edMax.Text:=FtoS(scanpar[iscan].maxval,8,4);
      edNstep.Text:=FtoS(scanpar[iscan].nstep,4,0);
    end else begin
      edMin.Enabled:=false; edMax.Enabled:=false; edNstep.enabled:=False;
    end;
  end;
end;

procedure TsetMatchScan.edKeyPress(Sender: TObject; var Key: Char);
var
  v: Real;
begin
  if edmin=Sender then  TEKeyVal(edmin, Key, v, 8,4);
  if edmax=Sender then  TEKeyVal(edmax, Key, v, 8,4);
  if edNstep=Sender then  TEKeyVal(ednstep, Key, v, 4,0);
end;

procedure TsetMatchScan.edExit(Sender: TObject);
{check edit fields on exit if they contain a valid number}
var
  v: Real;
begin
  if edmin=Sender then TEReadVal(edmin,v,7,4);
  if edmax=Sender then TEReadVal(edmax,v,7,4);
  if edNstep=Sender then TEReadVal(edNstep,v,4,0);
end;

end.
