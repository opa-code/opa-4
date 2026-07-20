unit owriteomrk;

//{$MODE Delphi}

// panel to select opticmarkers for overwriting

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  globlib, linoplib, StdCtrls;

type
  TWOMK = class(TForm)
    labtit: TLabel;
    butgo: TButton;
    butcan: TButton;
    procedure butcanClick(Sender: TObject);
    procedure butgoClick(Sender: TObject);
  private
    nomk: integer;
    procedure Exit;
  public
    procedure Load;
  end;

var
  WOMK: TWOMK;
{$R *.lfm}


const
  maxnomk=20;
var
  ioma, joma: array[1..maxnomk] of integer;

implementation

procedure TWOMK.Load;

var
  i, k, j: integer;
  fnd: boolean;
  comk: TCheckBox;

begin

// find all optics markers (max 20) in the lattice:
  for j:=1 to maxnomk do joma[j]:=-1;
  nomk:=0;
  for i:=1 to Glob.NLatt do begin
    j:=FindEl(i);
    if Ella[j].cod=comrk then begin
      fnd:=false;
      for k:=1 to nomk do fnd:=fnd or (joma[k]=j);
      if not fnd then begin
        inc(nomk);
        joma[nomk]:=j;
        ioma[nomk]:=i;
      end;
    end;
  end;

  height:=labtit.top+(nomk+3)*24+50;
  width:=labtit.width+2*labtit.left;
  butgo.top:=height-75; butcan.top:=butgo.top;
  for i:=1 to nomk do begin
    comk:=TCheckBox(FindComponent('comk_'+IntToStr(i)));
    if comk = nil then begin
      comk:=TCheckBox.Create(self);
      comk.parent:=Self;
      comk.name:= 'comk_'+IntToStr(i);
      comk.caption:=Ella[joma[i]].nam;
      comk.Tag:=i;
      comk.setBounds(labtit.left,labtit.top+i*24,labtit.width, 24);
      comk.Checked:=True;
    end;
  end;
end;

procedure TWOMK.Exit;
var
  i: integer;
  comk: TCheckBox;
begin
  for i:=1 to maxnomk do begin
    comk:=TCheckBox(FindComponent('comk_'+IntToStr(i)));
    if comk <> nil then comk.free;
  end;
  Close;
//  WOMK:=nil;
end;



procedure TWOMK.butcanClick(Sender: TObject);
begin
  Exit;
end;

procedure TWOMK.butgoClick(Sender: TObject);
var
  i, j: integer;
  comk: TCheckBox;
begin
  for i:=1 to nomk do begin
    comk:=TCheckBox(FindComponent('comk_'+IntToStr(i)));
    if comk.Checked then begin
      with Ella[joma[i]].om^ do begin
        with Opval[0,ioma[i]] do begin
          bet[1]:=beta;  bet[2]:=alfa;
          bet[3]:=betb;  bet[4]:=alfb;
          eta[1]:=disx;  eta[2]:=dipx;
          eta[3]:=disy;  eta[4]:=dipy;
          cma:=cmat;
//          dpp:=Beam.dppset;
        end;
      end;
      for j:=1 to 4 do Ella[joma[i]].om^.orb[j]:=Opval[0,ioma[i]].orb[j];
    end;
  end;
  Exit;
end;

end.
