unit ochromsvector;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  chromlib, asfigure, globlib, MathLib;

type
  TSVectorPlot = class(TForm)
    VDiag: TFigure;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    procedure ResizeAll;
  public
    procedure Init;
    procedure Star;
    procedure SaveDefaults;
  end;

var
  SVectorPlot: TSVectorPlot;

implementation

{$R *.lfm}

// event procs

procedure TSVectorPlot.FormCreate(Sender: TObject);
begin
  VDiag.assignScreen;
  Width :=IDefGet('svect/size');
//pass a handle to chromlib for plotting
  VDPH:=VDiag.plot;
  Visible:=false;
  Top:=10; left:=10;
end;

procedure TSVectorPlot.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveDefaults;
end;

procedure TSVectorPlot.FormResize(Sender: TObject);
begin
  ResizeAll;
end;

procedure TSVectorPlot.FormPaint(Sender: TObject);
begin
  Star;
end;

// public

procedure TSVectorPlot.Init;
var
  i: integer;
  hmax: real;
begin
  if VSelect>0 then begin
    visible:=true;
    VDiag.plot.Clear(clBlack);
    hmax:=0.0;
    if VSelect=1 then begin
      Caption:='First order drive terms';
      for i:=2 to VSelectMax do if (c_abs(HamT[i]) > hmax) then hmax:= c_abs(HamT[i]);
    end else begin
      Caption:=HamCap[VSelect];
      getSVector(VSelect);
      for i:=0 to High(Sextupol) do if (c_abs(SVector[i]) > hmax) then hmax:= c_abs(SVector[i]);
      if c_abs(HamT[VSelect]) > hmax then hmax:=c_abs(HamT[VSelect]);
    end;
    VDiag.Init(-hmax,-hmax, hmax,hmax,0,0,' ',' ',0,false);
    Star;
  end else visible:=false;
end;

// star diagram of sextupoles in complex plane
procedure TSVectorPlot.Star;
var
  kp:integer; i:integer;
  ha: complex;
{plots the single resonance star diagram for ONE period, no matter how
period was set}
begin
  with Vdiag.plot do begin
    if VSelect > 0 then begin
      Clear(clBlack);
      if VSelect =1 then begin
        setThick(3);
        for kp:=2 to VSelectMax do begin
          ha:=c_get(0,0);
          for i:=0 to High(SexFam) do ha:=c_add(ha, c_sca(SM1pre[i,kp],SexFam[i].ml));
          setColor(SexColor[kp-2]);
          Line(0,0,ha.re,ha.im);
        end;
        setThick(1);
      end else begin
        getSVector(VSelect);
        for i:=0 to High(Sextupol) do begin
          setColor(SexFam[Sextupol[i].ifam].col);
          Line(0,0,SVector[i].re, SVector[i].im);
        end;
        setColor(clWhite);
        ha:=c_get(0,0);
        for i:=0 to High(SexFam) do  ha:=c_add(ha, c_sca(SM1pre[i,VSelect],SexFam[i].ml));
        Circle(0,0,c_abs(ha), clWhite);
        Line(0,0,ha.re,ha.im);
      end;
    end;
  end;
end;

procedure TSVectorPlot.SaveDefaults;
begin
  Defset('svect/size',Width);
end;

// private

procedure TSVectorPlot.ResizeAll;
const
  dsr  =10; //dist to outside
var
  wid: integer;
begin
  if Width<200 then Width:=200;
  if Width>Screen.Width div 2 then Width:=Screen.Width div 2;
  wid:=ClientWidth-2*dsr;
  ClientHeight:=wid+2*dsr;
  VDiag.SetSize(dsr,dsr,wid,wid);
end;




end.
