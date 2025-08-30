unit otunematrix;

//{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, linoplib, globlib, ASaux, MathLib;

type
  TtuneMatrix = class(TForm)
    Eddkk: TEdit;
    labdkk: TLabel;
    labf: TLabel;
    labd: TLabel;
    shapeMat: TShape;
    LabFX: TLabel;
    LabFY: TLabel;
    LabDX: TLabel;
    LabDY: TLabel;
    LabX: TLabel;
    LabY: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Label1: TLabel;
    Label2: TLabel;
    EdX: TEdit;
    EdY: TEdit;
    labQx: TLabel;
    LabQy: TLabel;
    butSet: TButton;
    butreset: TButton;
    butex: TButton;
    procedure butexClick(Sender: TObject);
    procedure EddkkKeyPress(Sender: TObject; var Key: Char);
    procedure EdXKeyPress(Sender: TObject; var Key: Char);
    procedure EdYKeyPress(Sender: TObject; var Key: Char);
    procedure EdXExit(Sender: TObject);
    procedure EdYExit(Sender: TObject);
    procedure butSetClick(Sender: TObject);
    procedure butresetClick(Sender: TObject);
  private
    dkkexp:integer;
    ikf, ikd: array[1..100] of integer;
    kf, kd: array[1..100] of real;
    nkf, nkd: integer;
    Qx0, Qy0, tmfx, tmfy, tmdx, tmdy: double;
    kfac, Qxset, Qyset: real;
    procedure AllocQuads;
    procedure GetMatrix;
  public
    procedure Load;
    procedure Exit;
  end;

var
  tuneMatrix: TtuneMatrix;

implementation

const
  kabsmin=0.00;

{$R *.lfm}
procedure TtuneMatrix.Load;
begin
  dkkexp:=-6;
  Qx0:=Beam.Qx; Qy0:=Beam.Qy;
  Eddkk.Text:=InttoStr(dkkexp);
  AllocQuads;
  GetMatrix;
  EdX.text:=FtoS(Qx0,8,4);
  EdY.text:=FtoS(Qy0,8,4);
  Qxset:=Qx0; Qyset:=Qy0;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.AllocQuads;
var
  j:integer;
begin
  nkf:=0; nkd:=0;
  for j:=1 to Glob.NElla do if Ella[j].cod=cquad then begin
    if getkval(j,0)> kabsmin then begin
      Inc(nkf); ikf[nkf]:=j; kf[nkf]:=getkval(j,0);
    end;
    if getkval(j,0)< -kabsmin then begin
      Inc(nkd); ikd[nkd]:=j; kd[nkd]:=getkval(j,0);
    end;
  end;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.GetMatrix;
var
  j: integer;
  tx, ty: double;
  cfx, cfy, cdx, cdy, cdet: double;
begin
  kfac:=PowI(10,dkkexp);
  OpticReCalc;
  Qx0:=Beam.Qx; Qy0:=Beam.Qy;

//obtain tune shift with relative quad change by numeric diff of periodic solutions:
  for j:=1 to nkf do putkval(kf[j]*(1+kfac),ikf[j],0);
  OpticReCalc;
  tx:=(Beam.Qx-Qx0)/kfac; ty:=(Beam.Qy-Qy0)/kfac;

  for j:=1 to nkf do putkval(kf[j]*(1-kfac),ikf[j],0);
  OpticReCalc;
  cfx:=((Beam.Qx-Qx0)/(-kfac) + tx)/2.0;
  cfy:=((Beam.Qy-Qy0)/(-kfac) + ty)/2.0;

  for j:=1 to nkf do putkval(kf[j],ikf[j],0);

  for j:=1 to nkd do putkval(kd[j]*(1+kfac),ikd[j],0);
  OpticReCalc;
  tx:=(Beam.Qx-Qx0)/kfac; ty:=(Beam.Qy-Qy0)/kfac;

  for j:=1 to nkd do putkval(kd[j]*(1-kfac),ikd[j],0);
  OpticReCalc;
  cdx:=((Beam.Qx-Qx0)/(-kfac) + tx)/2.0;
  cdy:=((Beam.Qy-Qy0)/(-kfac) + ty)/2.0;

  for j:=1 to nkd do putkval(kd[j],ikd[j],0);

// invert tune response matrix to get tune shift matrix:
  cdet:=(cfx*cdy-cfy*cdx);
  tmfx:=cdy/cdet; tmfy:=-cdx/cdet; tmdx:=-cfy/cdet;  tmdy:=cfx/cdet;

  LabFX.Caption:=FtoS(tmfx,10,6);
  LabFY.Caption:=FtoS(tmfy,10,6);
  LabDX.Caption:=FtoS(tmdx,10,6);
  LabDY.Caption:=FtoS(tmdy,10,6);

  Snapsave.Qx  :=Qx0;
  Snapsave.Qy  :=Qy0;
  SnapSave.tmfx:=tmfx;
  SnapSave.tmfy:=tmfy;
  SnapSave.tmdx:=tmdx;
  SnapSave.tmdy:=tmdy;
  Status.Tmatrix:=true;
  setStatusLabel(stlab_tmx,status_flag);

end;

{---------------------------------------------------------------}

procedure TtuneMatrix.Exit;
begin
  Close;
  tuneMatrix:=nil;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.butexClick(Sender: TObject);
begin
  Exit;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.EddkkKeyPress(Sender: TObject; var Key: Char);
var
  kv:real;
begin
  if TEKeyVal(eddkk, Key, kv, 2,0) and (Key=#0) then begin
    dkkexp:=round(kv);
    Getmatrix;
  end;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.EdXKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
begin
  if TEKeyVal(edX, Key, kv, 8, 4) then Qxset:=kv;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.EdYKeyPress(Sender: TObject; var Key: Char);
var
  kv: real;
begin
  if TEKeyVal(edY, Key, kv, 8, 4) then Qyset:=kv;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.EdXExit(Sender: TObject);
begin
  TEReadVal(edX,Qxset,8,4);
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.EdYExit(Sender: TObject);
begin
  TEReadVal(edY,Qyset,8,4);
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.butSetClick(Sender: TObject);
var
  kfc: double;
  j: integer;

begin
  kfc:=(Qxset-Qx0)*tmfx+(Qyset-Qy0)*tmfy;
  for j:=1 to nkf do putkval(kf[j]*(1+kfc), ikf[j],0);
  kfc:=(Qxset-Qx0)*tmdx+(Qyset-Qy0)*tmdy;
  for j:=1 to nkd do putkval(kd[j]*(1+kfc), ikd[j],0);
  OpticRecalc;
  if status.periodic then begin
    PlotBeta;
    butreset.enabled:=true;
  end else begin
    OPALog(2,'TuneMatrix: no periodic solution');
    for j:=1 to nkf do putkval(kf[j], ikf[j],0);
    for j:=1 to nkd do putkval(kd[j], ikd[j],0);
    OpticRecalc;
    EdX.text:=FtoS(Qx0,8,4);
    EdY.text:=FtoS(Qy0,8,4);
  end;
end;

{---------------------------------------------------------------}

procedure TtuneMatrix.butresetClick(Sender: TObject);
var
  j:integer;
begin
  for j:=1 to nkf do putkval(kf[j], ikf[j],0);
  for j:=1 to nkd do putkval(kd[j], ikd[j],0);
  OpticRecalc;
  EdX.text:=FtoS(Qx0,8,4);
  EdY.text:=FtoS(Qy0,8,4);
  butreset.enabled:=false;
end;

{---------------------------------------------------------------}

end.
