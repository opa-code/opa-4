unit ChromGUILib1;

//{$MODE Delphi}

{this unit contains handles to the OPAChroma GUI and procedures which
 are commonly used by OPAChroma, CSexLine, CHamLine in order to avoid to
 pass too many handles between these units
}
                         
interface

uses StdCtrls, CHamLine, ChromLib, Sysutils;

procedure Pass_CH_handles(CH: array of TCHam);
procedure Pass_LabPath_handles(Laba1L, Laba2L, Laba3L: TLabel);

procedure UpdateHamilton;
procedure UpdatePenalty(P:double);
//procedure UpdatePenalty;
procedure UpdatePath;
//-------------------------------------------------------------

implementation

var
  CH_handle: array[0..nCHamilton-1] of TCHam; //the 25 Hamiltonians
  laba1l_handle, laba2l_handle, laba3l_handle: TLabel; //handles for path
// handles for the octupol-SVD related components:

//-------------------------------------------------------------
procedure Pass_CH_handles(CH: array of TCHam);
var
  i:integer;
begin
  for i:=0 to nCHamilton-1 do CH_handle[i]:=CH[i];
end;


procedure Pass_LabPath_handles(Laba1L, Laba2L, Laba3L: TLabel);
begin
  Laba1L_handle:=Laba1L;
  Laba2L_handle:=Laba2L;
  Laba3L_handle:=Laba3L;
end;


//-----------------------------------------------------------

procedure UpdateHamilton;
var
  i: integer;
begin
   for i:=0 to nCHamilton-1 do begin
    CH_handle[i].UpdateHam;
  end;
  UpdatePath;
end;

procedure UpdatePenalty(P:double);
begin
  LabPen_handle.Caption:=FloatToStrF(P, ffexponent, 3, 2);
end;

{ keine gute Idee - Penalty ist eine Funktion!
procedure UpdatePenalty;
begin
  LabPen_handle.Caption:=FloatToStrF(Penalty, ffexponent, 3, 2);
end;
}

procedure UpdatePath;
begin
  laba1l_handle.caption:='a1L='+FloatToStrF(Path_al[1], ffexponent, 3, 2);
  laba2l_handle.caption:='a2L='+FloatToStrF(Path_al[2], ffexponent, 3, 2);
  laba3l_handle.caption:='a3L='+FloatToStrF(Path_al[3], ffexponent, 3, 2);
end;


end.
