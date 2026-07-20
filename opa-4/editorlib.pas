unit editorlib;

{$mode Delphi}

interface

uses
  classes, SysUtils, stdctrls, dialogs, globlib, mathlib, comauxlib;

const
  ValidNumbers   =['0'..'9'];
  ValidCharacters=['a'..'z','A'..'Z','_'];

type
  //Buffer for lattice string as linked list (latfilelib, opamenu, opatexteditor)
  CharBufpt=^CharBuf;
  CharBuf  = record
    ch:  Char;
    nex: CharBufpt;
  end;

//string represenation of var, ele, seg
function  NameCheck(s: String): Boolean;
function  VariableToStr(i: integer): String;
function  ElemToStr (i: integer): String;
function  SegmToStr(i: integer): string;

//segment handling
function  AppendAE(var a: AEpt; name: ElemStr): AEpt;
function  NAESeg (i: word; var ne, ns: word): word;
procedure ClearSeg  (iseg: word);
procedure ClearSegAll;

//initialize element
procedure IniElem (j: word);

//text buffer containing lattice file as string
function  AppendChar(var a: CharBufpt; ch: Char): CharBufpt;
procedure ClearTextBuffer (var TextBuf: pointer);

//update the drop-down menu for selecting a segment
procedure FillComboSeg (var comboseg: TComboBox);

//utility to convert undulator element to segment
procedure ExpandUndulator;

//build and show the lattice
procedure MakeLattice (var success: boolean);
procedure ShowLattice (log: TMemo);

implementation

{----------------------------------------------------------------------}
//check syntax of elem/segm/var name. (oelecreate, oeleedit, osegedit)
function NameCheck(s: String): Boolean;
var
  f: boolean;
  i: integer;
begin
  f:=length(s)>0;
  if f then f:= s[1] in ValidCharacters;
  if f then
    for i:=1 to length(s) do f:=f and ((s[i] in ValidCharacters) or (s[i] in ValidNumbers));
  if not f then begin
      MessageDlg('Invalid element/variable/segment name: '+s,mtError, [mbOK],0);
  end;
  NameCheck:=f;
end;
{----------------------------------------------------------------------}
 //output of variable as string  for editor menus (opaeditor, oelecreate, oeleedit)
function VariableToStr(i: integer): String;
var s: string;
begin
  with Variable[i] do begin
    s:='VAR '+ nam+' = ';
    if exp='' then s:=s+Ftos(val,10,4) else s:=s+exp;
  end;
  VariableToStr:=s;
end;

{----------------------------------------------------------------------}
//output of element as a short string for editor menus (opaeditor, oelecreate, oeleedit)
function ElemToStr (i: integer): String;
var
  i8: integer;
  s: String;
begin
  s:= ElemShortName[elem[i].cod]+' '+ Elem[i].nam;
  for i8:=Length(Elem[i].nam)+1 to ElemStrLength do s:=s+' ';
  with elem[i] do case cod of
    cdrif: begin
             s:=s+' L  = ';
             if l_exp=nil then s:=s + FtoS(elem[i].l,5,2) else s:=s + l_exp^;
           end;
    cquad: begin
             s:=s+' Kq = ';
             if kq_exp=nil then s:=s + FToS(elem[i].kq, 5,2) else s:=s + kq_exp^;
           end;
    csole: begin
             s:=s+' Ks = '+FToS(elem[i].ks,5,2);
           end;
    csext: begin
             s:=s+' MS = '+FToS(elem[i].ms, 5,2);
           end;
    cbend: begin
             s:=s+' Ph = ';
             if phi_exp=nil then s:=s + FToS(elem[i].phi*degrad,6,3) else s:=s + phi_exp^;
           end;
    cundu: begin
             s:=s+' Lb = '+FtoS(1000*elem[i].lam, 5,1);
           end;
    ckick: begin
             s:=s+' K = '+FToS(elem[i].amp, 8,3);
           end;
    csept: begin
             s:=s+' Ds = '+FtoS(elem[i].dis, 4,1);
           end;
    comrk: begin
           end;
    ccomb: begin
            s:=s+' Ph = ';
            if cphi_exp=nil then s:=s +FToS(elem[i].cphi*degrad,6,3) else s:=s + cphi_exp^;
           end;
    cxmrk: begin
             s:=s+' Lx = '+FtoS(elem[i].xl, 5,1)+' m';
           end;
    cgird: begin
             s:=s+' typ = '+inttostr(elem[i].gtyp);
           end;
    cmpol: begin
             s:=s+' K = '+FToSv(elem[i].bnl, 8,3 );
           end;
    ccorh: begin
             s:=s+' dxp  = '+ FtoS(elem[i].dxp*1000,7,3);
           end;
    ccorv: begin
             s:=s+' dyp  = '+ FtoS(elem[i].dyp*1000,7,3);
           end;
  end;
  ElemToStr:=s;
end;

{----------------------------------------------------------------------}
function SegmToStr(i: integer): string;
var
   s: string;
   ne, ns {, dummy}: word;
begin
  s:=segm[i].nam+' ';
  ne:=0; ns:=0;
  NAESeg(i,ne,ns);
//  dummy:=NAESeg(i,ne,ns);
  s:=s+'('+ IntToStr(ne)+'/'+IntToStr(ns)+')';
  SegmToStr:=s;
end;

{-----------------------------------------------------------------------}
function AppendAE(var a: AEpt; name: ElemStr): AEpt;
{appends an abstract element to the current segment}
var
  b: AEpt;
  fnd: boolean;
  j, imul, impos: word;
//  valerrcod: integer;
begin
  New(b);
  a^.nex:=b;
  b^.pre:=a;
  impos:=Pos('-',name);
  if impos>0 then begin
    name:=Copy(name,impos+1,length(name)-impos);
    b^.inv:=true;
  end
  else b^.inv:=false;
  imul:=Pos('*',name);
  if imul=0 then b^.rep:=1
  else begin
    Val(Copy(name,1,imul-1),b^.rep);
//    Val(Copy(name,1,imul-1),b^.rep,valerrcod);
    name:=Copy(name,imul+1,length(name));
  end;
  b^.nam:=name;
  fnd:=false; for j:=1 to Glob.NElem do fnd:=fnd or (name=Elem[j].nam);
  if fnd then b^.kin:=ele else b^.kin:=seg;
  b^.nex:=nil;
  AppendAE:=b;
end;

{---------------------------------------------------------------------------}
procedure ClearSeg (iseg: word);
var
  a: AEpt;
begin
  with Segm[iseg] do begin
    while ini<>nil do begin
      a:=ini;
      ini:=a^.nex;
      dispose(a);
    end;
  end;
end;

{-----------------------------------------------------------------------}

procedure ClearSegAll;
var i: integer;
begin
  for i:=1 to Glob.NSegm do ClearSeg(i);
end;

{-----------------------------------------------------------------------}

function NAESeg(i:word; var ne, ns: word): word;
var
  n: word;
  x: AEpt;
begin
  x:=segm[i].ini;
  n:=0; ne:=0; ns:=0;
  repeat
    inc(n);
    if x^.kin=ele then inc(ne) else inc(ns);
    x:=x^.nex;
  until x=nil;
  NAESeg:=n;
end;

{-----------------------------------------------------------------------}


//initialize element data  (lattfilelib, lgbeditlib, oelecreate, opaeditor)
procedure IniElem (j: word);
var i: integer;
begin
  with elem[j] do begin
    l:=0.0; ax:=glob.ax; ay:=glob.ay; tag:=-1; rot:=0;
    l_exp:= nil; rot_exp:=nil;
    nl:=nil;  TypNam:='void';
    case cod of
      cdrif: block:=false;
      cquad: begin
               kq:=0;
               kq_exp:=nil;
             end;
      csole: ks:=0;
      csext: begin
               ms:=0; sslice:=1;
             end;
      cbend: begin
              kb:=0; phi:=0; tin:=0; tex:=0; gap:=0;
              k1in:=0; k1ex:=0; k2in:=0; k2ex:=0;
              kb_exp:=nil; phi_exp:=nil; tin_exp:=nil; tex_exp:=nil;
             end;
      cundu: begin
               lam:=0; bmax:=0; ugap:=1.0;
               // init undu with sinusoidal field params
               fill1:=2/pi; fill2:=0.5; fill3:=4/3/pi;
               halfu:=false;
             end;
      ckick: begin
               amp:=0;
               xoff:=0;
               mpol:=1;
               tau:=0;
               delay:=0;
               kslice:=1;
             end;
      csept: begin thk:=0; dis:=0; end;
      comrk: begin
               New(om);
               for i:=1 to 4 do begin
                 om^.bet[i]:=0.0; om^.eta[i]:=0.0; om^.orb[i]:=0.0;
               end;
               om^.bet[1]:=1.0; om^.bet[3]:=1.0; //om^.dpp:=0.0;
               om^.cma:=matnul2;
               screen:=false;
             end;
      ccomb: begin
               cphi:=0; cerin:=0; cerex:=0; cek1in:=0; cek1ex:=0; cgap:=0;
               ckq:=0; cms:=0; cslice:=1;
               cphi_exp:=nil; cerin_exp:=nil; cerex_exp:=nil; ckq_exp:=nil;
             end;
      cxmrk: begin xl:=20; nstyle:=0; snap:=0; end;
      cgird: begin gtyp:=0; shift:=0.0; end;
      cmpol: begin bnl:=0; lmpol:=0; nord:=1; end;
      ccorh: begin dxp:=0; ocox:=false; end;
      ccorv: begin dyp:=0; ocoy:=false; end;
      cmoni: ocom:=false;
    end;
  end;
end;


{-------------------------------------------------------------------------}

//append a character to a linked list       (lattfilelib, opamenu, opatexteditor)
function AppendChar(var a: CharBufpt; ch: Char): CharBufpt;
var
  b: CharBufpt;
begin
  New(b);
  a^.nex:=b;
  b^.ch:=ch;
  b^.nex:=nil;
  AppendChar:=b;
end;

//clear lattice buffer, (opamenu and opatexteditor)
procedure ClearTextBuffer (var TextBuf: pointer);
var
  a: CharBufpt;
begin
  while TextBuf<>nil do begin
    a:=TextBuf;
    TextBuf:=a^.nex;
    dispose(a);
  end;
end;

   //fills the dropdown menu of segments in opamenu
procedure FillComboSeg (var comboseg: TComboBox);
var i: integer;
begin
  with comboseg do begin
    Clear;
    Text:='select!' ;
    for i:=1 to Glob.NSegm do begin
      {index:=}Items.Add(Segm[i].nam);
    end;
  end;
end;

procedure ExpandUndulator;
// expand all undulators -> create series of bends
// (option for later: drop down for selection of undulator)
// original undu is kept in element table
// new elements for poles and drifts are created, and two new segments,
// _pol and _exp for one pole and for the undulator
var
  dnam: ElemStr;
  und: ElementType;
  i, ju, jd, Nuper: integer;
  irho, tphi, kedge, drsh, drb: real;
  found:boolean;
  p: AEpt;

begin
  for ju:=1 to Glob.NElem do if Elem[ju].cod=cundu then begin
    und:=Elem[ju];
    dnam:=und.nam+'_D';
    found:=false;
    for jd:=1 to Glob.Nelem do found:=found or (Elem[jd].nam = dnam);
    if not found then begin
      irho  := und.bmax/(Glob.Energy/(speed_of_light/1E9)); {=B/Brho = 1/rho}
      tphi  := irho*und.lam/2*und.fill1;
      kedge:=und.lam/4/und.ugap*(und.fill1-und.fill2);
      Nuper:=Round(und.l/und.lam);
      drb   :=und.fill1*und.lam/2;
      drsh  :=(1-und.fill1)*und.lam/4;

      Inc(Glob.Nelem);
      with Elem[Glob.Nelem] do begin
        nam:=dnam;
        cod:=cdrif;
        IniElem(Glob.NElem);
        l:=drsh;
        block:=true;
        ax:=und.ax; ay:=und.ay;
      end;
      Inc(Glob.Nelem);
      with Elem[Glob.Nelem] do begin
        nam:=und.nam+'_BP';
        cod:=cbend;
        IniElem(Glob.NElem);
        l:=drb; phi:=tphi; tin:=tphi/2; tex:=tphi/2; k1in:=kedge; k1ex:=kedge; gap:=und.ugap;
        ax:=und.ax; ay:=und.ay;
      end;
      Inc(Glob.Nelem);
      with Elem[Glob.Nelem] do begin
        nam:=und.nam+'_BM';
        cod:=cbend;
        IniElem(Glob.NElem);
        l:=drb; phi:=-tphi; tin:=-tphi/2; tex:=-tphi/2; k1in:=kedge; k1ex:=kedge; gap:=und.ugap;
        ax:=und.ax; ay:=und.ay;
      end;
      Inc(Glob.Nelem);
      with Elem[Glob.Nelem] do begin
        nam:=und.nam+'_BM1';
        cod:=cbend;
        IniElem(Glob.NElem);
        l:=drb; phi:=-tphi/4; tin:=0; tex:=-tphi/4; k1in:=kedge; k1ex:=kedge; gap:=und.ugap;
        ax:=und.ax; ay:=und.ay;
      end;
      Inc(Glob.Nelem);
      with Elem[Glob.Nelem] do begin
        nam:=und.nam+'_BP1';
        cod:=cbend;
        IniElem(Glob.NElem);
        l:=drb; phi:=tphi/4; tex:=0; tin:=tphi/4; k1in:=kedge; k1ex:=kedge; gap:=und.ugap;
        ax:=und.ax; ay:=und.ay;
      end;
      Inc(Glob.Nelem);
      with Elem[Glob.Nelem] do begin
        nam:=und.nam+'_BP3';
        cod:=cbend;
        IniElem(Glob.NElem);
        l:=drb; phi:=3*tphi/4; tin:=tphi/4; tex:=tphi/2; k1in:=kedge; k1ex:=kedge; gap:=und.ugap;
        ax:=und.ax; ay:=und.ay;
      end;
      Inc(Glob.Nelem);
      with Elem[Glob.Nelem] do begin
        nam:=und.nam+'_BM3';
        cod:=cbend;
        IniElem(Glob.NElem);
        l:=drb; phi:=-3*tphi/4; tex:=-tphi/4; tin:=-tphi/2; k1in:=kedge; k1ex:=kedge; gap:=und.ugap;
        ax:=und.ax; ay:=und.ay;
      end;

      Inc(Glob.NSegm,2);
      for i:=Glob.NSegm downto 3 do Segm[i]:=Segm[i-2];
      New(p);
      with Segm[1] do begin
        nam :=und.nam+'_POL';
        ini :=nil;
        nper:=1;
        p:=AppendAE(p,dnam);
        ini:=p;
        p^.pre:=nil;
                                 p:=AppendAE(p,und.nam+'_BM');   p:=AppendAE(p,dnam);
        p:=AppendAE(p,dnam);     p:=AppendAE(p,und.nam+'_BP');   p:=AppendAE(p,dnam);
        fin:=p;
        p^.nex:=nil;
      end; // with      with Segm[1] do begin
      New(p);
      with Segm[2] do begin
        nam :=und.nam+'_EXP';
        ini :=nil;
        nper:=1;
        p:=AppendAE(p,dnam);
        ini:=p;
        p^.pre:=nil;
                                 p:=AppendAE(p,und.nam+'_BM1');   p:=AppendAE(p,dnam);
        p:=AppendAE(p,dnam);     p:=AppendAE(p,und.nam+'_BP3');   p:=AppendAE(p,dnam);
        p:=AppendAE(p,und.nam+'_POL'); p.rep:=nuper-2;
        p:=AppendAE(p,dnam);   p:=AppendAE(p,und.nam+'_BM3');   p:=AppendAE(p,dnam);
        p:=AppendAE(p,dnam);   p:=AppendAE(p,und.nam+'_BP1');   p:=AppendAE(p,dnam);
        fin:=p;
        p^.nex:=nil;
      end; // with

      //change name in all other segments and switch from ele to seg
      for i:=3 to Glob.NSegm do begin
         p:=segm[i].ini;
         while p<>nil do begin
           if p^.nam=und.nam then begin
             p^.nam := segm[2].nam;
             p^.kin:=seg;
           end;
           p:=p^.nex;
         end;
      end;
      elem[ju]:=und;
    end; //not found
  end; // ju
end;

{-----------------------------------------------------------------------}

procedure MakeLattice (var success: boolean);
{circular reference check:
 the segment index (imaster) is appended to istack if seglat calls
 itself for the next level. there it checks the stack if it contains
 already the next segment. this would be a circular reference.
 when seglat returns to the previous level, the imaster is removed.
 so the stack contains always seglat's recursive calling sequence.
 as-060808
}

var
  fnd, invmod: boolean;
  il, i, j, ji: word;
  nch, ncv, nbpm, ncs, nqa, NElla0: integer;
  SegLatFail: byte;
  istack, elemindex: array of integer;
  imaster: integer;
  np: NameListpt;

  function getNewName(var n: integer; basname: String): ElemStr;
// find a new name like CH001, which does NOT yet exist
  var sn: ElemStr; k:integer; fnd:boolean;
  begin
    repeat
      Inc(n);
      sn:=basname+copy(inttostr(1000+n),2,3);
      fnd:=false;
      for k:=1 to Glob.NElem do fnd:=fnd or (Elem[k].nam = sn);
    until not fnd;
    getNewName:=sn;
  end;


  procedure SegStack_in (i:integer);
  begin
    setlength(istack,length(istack)+1);
    istack[high(istack)]:=i;
  end;

  procedure SegStack_out;
  begin
    setlength(istack,high(istack));
  end;

  function Segstack_Show(ic: integer): string;
  var i: integer; s: string;
  begin
    s:=' ';
//    for i:=0 to ic-1 do s:=s+'('+Segm[istack[i]].nam+') ';
    for i:=ic to High(istack) do s:=s+Segm[istack[i]].nam+' -> ';
    SegStack_show:=s;
  end;

{.....................................................................}

  procedure SegLat (ae: AEpt);
    {Expands the lattice from the active segment by recursive call:
     proceeds forward or backwards along segment starting from ini or fin
     terminates list when .pre or .nex of AEpt is nil
     checks for undefinded segments in order to avoid system crashes from
     undefined pointers - but this should never happen.
     thanks to Johan Bengtsson for the recursive call concept!}

  var
    name: ElemStr;
    i, irep, iam, its, icirc: integer;
    fnd, locinv: boolean;
  begin
    iam:=imaster;  // I am the master, i.e. the calling segment
    locinv:=invmod;
    while (ae<>nil) and (SegLatFail=0)do begin
      name:=ae^.nam;
      for irep:=1 to ae^.rep do begin
         if ae^.kin=ele then begin
          if Glob.NLatt<NLattmax then begin
            setlength(Lattice, length(Lattice)+1);
            Glob.NLatt:=High(Lattice);
            with Lattice[Glob.NLatt] do begin
              elnam:=name;
              if locinv xor ae^.inv then inv:=-1 else inv:= 1;
            end;
          end
          else SegLatFail:=2;
        end
        else begin
          i:=0;
          fnd:=false; {warum war das auskommentiert?}
          repeat
            Inc(i);
            fnd:=(Segm[i].nam=name);
          until fnd or (i=Glob.NSegm);
          if fnd then begin
          // check for circular reference
            icirc:=-1;
            for its:=High(istack) downto 0 do if (istack[its]=i) then icirc:=its;
            if icirc >= 0 then begin
              SegLatFail:=3;
//              ErrLogHandle.Lines.Append('LATTICE ERROR > circular reference for segments '+
              OpaLog(1,'Lattice: circular reference for segments '+
                SegStack_show(icirc)+Segm[iam].nam);
            end else begin
              invmod:=locinv xor ae^.inv;
              imaster:=i;  //the next segment will become the master
              SegStack_in(iam);  // add ME (the present master) to istack
              if invmod then SegLat(Segm[i].fin) else SegLat(Segm[i].ini); // recursive call
              SegStack_out;  // remove ME from istack
            end;
          end  else begin
            SegLatFail:=1;
            opalog(1,'Lattice: undefinded entry '+name+' in segment '+Segm[iam].nam);
//            ErrLogHandle.Lines.Append('LATTICE ERROR > undefinded entry '+name+' in segment '+Segm[iam].nam);
          end;
        end;

      end;
      if locinv then ae:=ae^.pre else ae:=ae^.nex;
    end;
  end;

{.....................................................................}

begin
  if Glob.Nsegm>0 then begin
    iactseg:=0;
    repeat inc(iactseg)
    until (actseg^.nam=segm[iactseg].nam) or (iactseg>=glob.nsegm);
    if iactseg>0 then begin
      ActSeg^.nam:=Segm[iactseg].nam;
      ActSeg^.kin:=seg;
      ActSeg^.nex:=Segm[iactseg].ini;
      Glob.NLatt:=0;
      Lattice:=nil;
      setlength(Lattice,1); // historical, 0 never used
      Glob.Nper:=Segm[iactseg].nper;
      SegLatFail:=0;
      InvMod:=False;
      istack:=nil;
      imaster:=iactseg;  //the active segment is the first master
      SegLat(ActSeg^.nex);
      if SegLatFail>0 then begin
//        if SegLatFail=2 then ErrLogHandle.Lines.Append('LATTICE ERROR > too many elements (max.'+IntToStr(NLattMax)+') OR circular segment reference!');
//        ErrLogHandle.Lines.Append('Lattice expansion failed.');
        if SegLatFail=2 then OpaLog(1,'Lattice: too many elements (max.'+IntToStr(NLattMax)+') OR circular segment reference!');
        OpaLog(1,'Lattice expansion failed.');
        {output this message here, in seglat it would come many times}
        Glob.NLatt:=0;
      end
      else begin
// built the table uf USED elements, Ella as subset of ALL elements, Elem
        Glob.NElla:=0;
        setlength(elemindex,Glob.NElem+1); //counting from 1 like Ella
        for i:=1 to glob.nelem do begin
          fnd:=false;
          il:=0;
          repeat
            Inc(il);
            fnd:= (Lattice[il].elnam=elem[i].nam);
          until fnd or (il=glob.nlatt);
          if fnd then begin
            Inc(Glob.NElla);  Ella[Glob.NElla]:=Elem[i];
            elemindex[Glob.NElla]:=i;
// copy copies also the pointer variable %_exp, so the string, where the pointer is pointing to, is the same!
// in order to become independent, a new pointer would have to be created for Ella and the string copied.
// but changing expressions should be reserved to Elem only in Editor.
// save original elem index?
          end;
        end;
      end;
      success:=Glob.NLatt>0;
      istack:=nil;
    end
    else success:=false;
  end
  else begin
//    ErrLogHandle.Lines.Append('LATTICE ERROR > there are no segments to build a lattice !');
    OpaLog(1,'There no segments to build a lattice !');
    success:=false;
  end;

  status.periodic :=false;
  status.symmetric:=false;
  status.betas:=false;
  status.tuneshifts:=false;
  status.chromas:=false;
  status.alphas:=false;
  status.rfaccept:=false;
  status.flopoly:=false;

  for i:=0 to nStatusLabels-1 do setStatusLabel(i,status_void);

  if success then begin

  // find the Ella by name and save its index (has historical roots...)
    for i:=1 to Glob.NLatt do begin
      j:=0;
      repeat Inc(j); until Ella[j].nam = Lattice[i].elnam;
      Lattice[i].jel:=j;
    end;

 { check for potentially coupling elments. This is the case if there are
   - element rotations (i.e. V-bend, skew quad), or
   - explicit rotations [may be edited in optics design], or
   - solenoids
 }
  status.uncoupled:=true;
  for i:=1 to Glob.NLatt do begin
    with Ella[Lattice[i].jel] do begin
      if (rot<>0) or (cod = crota) or (cod = csole) then status.uncoupled:=false;
    end;
  end;


{for a given lattice, successfully created, the element of family with protected
 names as defined by oco_chname, oco_cvname are expanded to individual elements
 to address them separately in orbit correction}

{ give Ella Names as real names if available:}
    nch:=0; ncv:=0; nbpm:=0; ncs:=0; nqa:=0;
    Nella0:=Glob.NElla;
    for j:=1 to Nella0 do begin

      if Ella[j].cod=ckick then status.Kickers:=true;

      if (Ella[j].cod=cmoni) then begin
        status.Monitors:=true;
        if (Ella[j].nam=oco_bpmname) then begin
          np:=Elem[elemindex[j]].nl;
          for i:=1 to Glob.NLatt do begin
            ji:=findel(i);
            if ji=j then begin
              if np<> nil then begin
                Lattice[i].elnam:=np.realname;
                np:=np^.nex;
              end else Lattice[i].elnam:=getNewName(nbpm, oco_bpmname);
              Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
              Ella[Glob.Nella].nam:=Lattice[i].elnam;
              Ella[Glob.Nella].ocom:=true;
              Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
              Lattice[i].jel:=Glob.NElla;
            end;
          end;
        end;
      end;

      if (Ella[j].cod = ccorh) and (Ella[j].nam=oco_chname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(nch, oco_chname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
            Ella[Glob.Nella].ocox:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;

      if (Ella[j].cod = ccorv) and (Ella[j].nam=oco_cvname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(ncv, oco_cvname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
            Ella[Glob.Nella].ocoy:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;

      if (Ella[j].cod = cquad) and (Ella[j].nam=oco_csname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(ncs, oco_csname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
//          Ella[Glob.Nella].ocoy:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;

      if (Ella[j].cod = cquad) and (Ella[j].nam=oco_qaname) then begin
        np:=Elem[elemindex[j]].nl;
        for i:=1 to Glob.NLatt do begin
          ji:=findel(i);
          if ji=j then begin
            if np<> nil then begin
              Lattice[i].elnam:=np.realname;
              np:=np^.nex;
            end else Lattice[i].elnam:=getNewName(nqa, oco_qaname);
            Inc(Glob.Nella); Ella[Glob.Nella]:=Ella[j];
            Ella[Glob.Nella].nam:=Lattice[i].elnam;
//          Ella[Glob.Nella].ocoy:=true;
            Ella[Glob.Nella].nl:=nil; // remove namelist to force use of ella name
            Lattice[i].jel:=Glob.NElla;
          end;
        end;
      end;
    end;

    for i:=1 to Glob.NLatt do begin
      with Lattice[i] do begin
        dx:=0; dy:=0; dt:=0;
      end;
    end;

  //  GirderSetup;     // why do this here? --> should be done in opaorbit!

  end; //success to expand lattice

  if status.lattice then begin
    if not status.uncoupled then setStatusLabel(stlab_cop,status_light) else setStatusLabel(stlab_cop,status_off);
    if status.kickers then setStatusLabel(stlab_kik,status_light) else setStatusLabel(stlab_kik,status_off);
    setStatusLabel(stlab_mis,status_off);
    setStatusLabel(stlab_cor,status_off);
    //undulators, monitors
  end;


end;

//---------------------------------------------------------------

procedure ShowLattice (log: TMemo);
var
  i, ilin, irow: word;
  s: string;
begin
  log.clear;
  log.Lines.Append('--------------------------------------------------------');
  log.Lines.Append('Expanded Lattice structure: ');
  ilin:=0; irow:=0;
  s:='';
  for i:=1 to Glob.NLatt do begin
    if Lattice[i].inv<0 then s:=s+' -' else s:=s+' ';
    s:=s+Lattice[i].elnam;
//    for i8:=length(Latt[i]) to ElemStrLength-1 do s:=s+' ';
    inc(irow); if irow=ElemStrLength then begin
//      ErrLogHandle.Lines.Append(s); s:='';
      irow:=0;
      inc(ilin);
    end;
  end;
  log.Lines.Append(s);
  log.Lines.Append('--- ('+inttostr(glob.nlatt)+' elements) ---------------------------');
end;


end.

