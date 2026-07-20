unit chromelelib;

//{$MODE Delphi}

{this unit contains octupole related handles to the opachroma GUI}
                         
interface

uses StdCtrls, chromlib, Sysutils;

procedure Pass_osvd_handles(
  ButOsvdDo, ButOsvdNp, ButOsvdNm: TButton; ChkOsvdAuto: TCheckBox;
  LabOsvdCon, LabOsvdNw: TLabel);
procedure Osvd_Status;
procedure Osvd_Wfilter;
//-------------------------------------------------------------

implementation

var
// handles for the octupol-SVD related components:
  ButOsvdDo_handle, ButOsvdNp_handle, ButOsvdNm_handle: TButton;
  ChkOsvdAuto_handle: TCheckBox;
  LabOsvdCon_handle, LabOsvdNw_handle: TLabel;

//-------------------------------------------------------------
procedure Pass_osvd_handles(
  ButOsvdDo, ButOsvdNp, ButOsvdNm: TButton; ChkOsvdAuto: TCheckBox;
  LabOsvdCon, LabOsvdNw: TLabel);
begin
  ButOsvdDo_handle  :=ButOsvdDo;
  ButOsvdNp_handle  :=ButOsvdNp;
  ButOsvdNm_handle  :=ButOsvdNm;
  ChkOsvdAuto_handle:=ChkOsvdAuto;
  LabOsvdCon_handle :=LabOsvdCon;
  LabOsvdNw_handle  :=LabOsvdNw;
end;

//-----------------------------------------------------------

procedure Oct_auto_off;
begin
  chkOsvdAuto_handle.checked:=false;
end;

procedure Osvd_status;
var
  wmin, wmax: real;
  nw, i: integer;
  ena: boolean;
begin
  osvd_active:=osvd_enable and ChkOsvdAuto_handle.Checked;
  ena:=osvd_enable and (not osvd_active);
  butosvddo_handle.enabled  := ena;
  chkosvdauto_handle.enabled:= osvd_enable;
  butosvdnp_handle.enabled  := ena;
  butosvdnm_handle.enabled  := ena;
  if osvd_enable then begin
    wmin:=1e10; wmax:=-1e10; nw:=0;
    for i:=1 to high(osvd_w) do if osvd_wuse[i]>osvd_wnull then begin // osvd_wnull=0 constant
      Inc(nw);
      if osvd_wuse[i]<wmin then wmin:=osvd_w[i];
      if osvd_wuse[i]>wmax then wmax:=osvd_w[i];
    end;
    labosvdcon_handle.caption:='Con = '+FloatToStrF(wmin/wmax, ffexponent, 3, 1);
    labosvdnw_handle.caption :='Nw = ' +IntToStr(nw);
  end else begin
    labosvdcon_handle.caption:='  Condition  ';
    labosvdnw_handle.caption:='Nweight';
  end;
end;

procedure Osvd_Wfilter;
// copy osvd_w to osvd_wuse, but set the osvd_null smallest elements = 0
const
  wbig=1e10;
var
  i, j, jmin: integer;
  wmin: real;
begin
  for i:=0 to high(osvd_w) do osvd_wuse[i]:=osvd_w[i];
  for i:=0 to osvd_null-1 do begin
    wmin:=wbig;
    for j:=1 to high(osvd_wuse) do if osvd_wuse[j]<wmin then begin
      wmin:=osvd_wuse[j]; jmin:=j;
    end;
    osvd_wuse[jmin]:=2*wbig;
  end;
  for i:=1 to high(osvd_wuse) do if osvd_wuse[i]>wbig then osvd_wuse[i]:=0.0;
  Osvd_status;
end;

end.
