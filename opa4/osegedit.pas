unit osegedit;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, globlib, asaux, ExtCtrls;

type

  { TEditSegSet }

  TEditSegSet = class(TForm)
    grid: TStringGrid;
    butok: TButton;
    butcre: TButton;
    butCan: TButton;
    lab_hint: TLabel;
    LabMod: TLabel;
    EditSegName: TEdit;
    butdel: TButton;
    edper: TEdit;
    LabPer: TLabel;
    procedure drawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure butokClick(Sender: TObject);
    procedure ButCanClick(Sender: TObject);
    procedure butcreClick(Sender: TObject);
    procedure EditSegNameChange(Sender: TObject);
    procedure butdelClick(Sender: TObject);
    procedure EditSegNameKeyPress(Sender: TObject; var Key: Char);
    procedure gridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edperKeyPress(Sender: TObject; var Key: Char);
    procedure edperExit(Sender: TObject);
  private
    keyFree: boolean;
    procedure Exit;
    function  ElemCol_C (Wort:ElemStr; var b, c: TColor): boolean;
    procedure ShiftCells(acol, arow, up: integer);
    function  SaveSeg (createSeg: boolean): boolean;
    function  killCheck(talk: boolean): boolean;
  public
    procedure Init (handle: TListBox);
  end;

var
  EditSegSet: TEditSegSet;
  ListHandle: TListBox;
  jsegm: integer;


  implementation

{$R *.lfm}

procedure TEditSegSet.Exit;
begin
  if EditSegSet<>nil then begin
    Release;
    EditSegSet:=nil;
  end;
end;

{--------------------------------------------------------------------}

function TEditSegSet.ElemCol_C (Wort:ElemStr; var b, c: TColor): boolean;
{as 010296/160197/230804}
// identify element type by name (may be unknown) and return colors
// function is true if element was found
var
  jel, jsg: word;
  found: Boolean;

begin
  found:=True;
  c:=0;
  Wort:=Copy(Wort,Pos('-',wort)+1,length(wort));
  Wort:=Copy(Wort,Pos('*',wort)+1,length(wort));
  if length(Wort)>0 then begin
    jel:=0; found:=false;
    while not found and (jel<glob.nelem) do begin
      Inc(jel);
      found:=elem[jel].nam=wort;
    end;
    if found then begin
      b:=clBlack;
      c:=ElemCol[elem[jel].cod];
    end else begin
      jsg:=0;
      while (not found) and (jsg<Glob.NSegm) do begin
        Inc(jsg);
        if (jsg <>jsegm) then found:=segm[jsg].nam=wort;
      end;
      if found then begin
        b:=clFuchsia;
        c:=clwhite;
      end else  begin
        c:=clBlack;
        b:=clRed;
      end;
    end;
  end else begin
    b:=clWhite;
  end;
  ElemCol_C:=found;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.Init (handle: TListBox);
const defcols=6;
var
  n, ne, ns, irow, icol, icount: word;
  s: string;
  x: AEpt;

begin
  keyFree:=True;
  ListHandle:=handle;
  jsegm:=ListHandle.ItemIndex;

  if jsegm > 0 then begin
    butcre.enabled:=false;
    grid.Options:=[goVertLine, goHorzLine, goEditing, goTabs];
    EditSegName.Text:=Segm[jsegm].nam;
    EdPer.Text:=inttostr(Segm[jsegm].nper);
    ns:=0; ne:=0;
    n:=NAESeg(jsegm, ne, ns);
    with grid do begin
      ColCount:=defcols;
// make sure to have enough rows:
      RowCount:=n div defcols + 1;
// start segment chain
      x:=Segm[jsegm].ini;
      icount:=0;
      while x<>nil do begin
        irow:=icount div ColCount;
        icol:=icount mod ColCount;
        if x^.inv then s:='-' else s:='';
        if x^.rep>1 then begin
          s:=s+IntToStr(x^.rep)+'*';
        end;
        Cells[icol, irow]:=s+x^.nam;
        x:=x^.nex;
        Inc(icount);
      end;
      for icount:=icol+1 to ColCount-1 do begin
        Cells[icount, irow]:='';
      end;
    end;
  end else begin
    butok.enabled:=false;
    grid.RowCount:=1;
  end;
  butdel.enabled:= KillCheck(false);
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.drawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  b, c: TColor;
begin
  with grid.Canvas do begin
    ElemCol_C (UB(grid.Cells[Acol,Arow]),b,c);
    Brush.Color:=b; Font.Color:=c;
    FillRect(Rect);
    TextOut(Rect.Left+2, Rect.Top+2, UB(grid.Cells[ACol, ARow]));
  end;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.ShiftCells(acol, arow, up: integer);

var
  cc, nac, nhi, n, r, c, foundr, foundc: integer;

begin

  with grid do begin
    cc:=ColCount;
// find highest non empty cell
    foundc := -1;
    foundr := -1;
    for r:=Rowcount-1 downto 0 do begin
      for c:=cc-1 downto 0 do begin
        if (Cells[c, r] <> '') then
        begin
          foundc := c; foundr := r;
          break;
        end;
      end;
      if (foundc <> -1) or (foundr <> -1) then break;
    end;
    if (foundc = -1) and (foundr = -1) then exit;

    // cells are numbered by n = row*colcount + col
    nhi :=r*cc+c;
    nac :=arow*cc+acol;
//    nmx :=RowCount*cc;
    case up of
    -1:begin
        if nhi >=0 then begin
          for n:=nac to nhi-1 do begin
            Cells[n mod cc, n div cc]:=Cells[(n+1) mod cc, (n+1) div cc];
          end;
          Cells[nhi mod cc, nhi div cc]:='';
          RowCount:=nhi div cc+1;
          if nhi>0 then Dec(nhi);
        end;

      end;
      1:begin
        RowCount:=(nhi+2) div cc +1;
        for n:=nhi downto nac do begin
          Cells[(n+1) mod cc, (n+1) div cc]:=Cells[n mod cc, n div cc];
        end;
        Cells[acol, arow]:='';
       end;
     else
    end;
    refresh;
  end;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.EditSegNameChange(Sender: TObject);
begin
  butcre.enabled:=EditSegName.text <> Segm[jsegm].nam;
end;

{--------------------------------------------------------------------}

function TEditSegSet.SaveSeg(createSeg: boolean): boolean;
var
  tmp: real;
  i,j: integer;
  dumc, dumb: Tcolor;
  a: AEpt;
  fnd, saveflag: boolean;
  sn: string;
begin

  { 0. test on empty segment which is used by others}
  fnd:=false; saveflag:=true;
  for i:=0 to grid.rowcount-1 do for j:=0 to grid.colcount-1 do fnd:=fnd or (length(grid.cells[j,i])>0);
  if not fnd {i.e. is empty} then saveflag:= KillCheck(true);

  if saveflag then begin
    sn:=UB(EditSegName.text);
{ 1. test syntax}
    saveflag:=NameCheck(sn);
{ 2. test if name exists already for an element/segmant. check OWN name
  only if a new segment is to be created (but should be excl. by butcre disabled anyway}
    fnd:=false;
    for i:=1 to Glob.NElem do fnd:= fnd or (Elem[i].nam = sn);
    for i:=1 to Glob.NSegm do
      fnd:= fnd or ((Segm[i].nam = sn) and ((jsegm <>i) or createSeg) ) ;
    saveflag:= not fnd;
    if fnd then MessageDlg('Name '+sn+' exists already!',mtError, [mbOk],0);
  end;

  if saveflag then begin
{3. check for unknown elements/segments}
    for i:=0 to grid.RowCount-1 do for j:=0 to grid.ColCount-1 do begin
      saveflag:=saveflag and ElemCol_C(UB(grid.Cells[j,i]),dumb,dumc);
    end;
    if not saveflag then MessageDlg(
      'Segment contains unknown elements!', mtError, [mbOK],0)
    else begin

{ok to save: }
      if (jsegm=0) or (CreateSeg) then begin
{create a new segment, append it to end of list}
        inc(glob.Nsegm);
        jsegm:=glob.nsegm;
      end else begin

        if sn = Segm[jsegm].nam then begin
{ old seg, old name: ok, just rewrite, clear first:}
          ClearSeg(jsegm);
        end else begin
{ old seg, new name: rename and change all entries:}
          for i:=1 to Glob.NSegm do if i<>jsegm then begin
            a:=segm[i].ini;
            while a<>nil do begin
              if a^.nam=segm[jsegm].nam then a^.nam:=sn;
              a:=a^.nex;
            end;
          end;
        end;
      end;
{rewrite segment: name and construct linked list from grid cells:}
      segm[jsegm].nam:=sn;
      if TEReadVal(edPer,tmp,4,0) then segm[jsegm].nper:=Round(tmp);
      New(a);
      with grid do begin
        for i:=0 to rowcount-1 do for j:=0 to colcount-1 do begin
          if length(cells[j,i])>0 then begin
             a:=AppendAE(a, UB(Cells[j,i]));
             if (i=0) and (j=0) then begin
               Segm[jsegm].ini:=a;
               a^.pre:=nil;
             end;
          end
        end;
        Segm[jsegm].fin:=a;
      end;

      //empirical fix to avoid error with list
      while jsegm >= listhandle.items.count do listhandle.items.append('new line');


      {if segment happens to be empty, destroy it:}
      if segm[jsegm].ini=nil then begin
        for i:=jsegm to glob.nsegm-1 do begin
          segm[i]:=segm[i+1];
          Listhandle.Items[i]:=SegmToStr(i);
        end;
        Listhandle.Items.Delete(glob.nsegm);
        dec(glob.nsegm);
        if jsegm > glob.nsegm then jsegm:=glob.nsegm;


        {highlight the new/updated segment in the list:}
        Listhandle.Items[jsegm]:=SegmToStr(jsegm);
      end else begin // not empty
        Listhandle.Items[jsegm]:=SegmToStr(jsegm);
      end;
    end;
  end;

{return true if saving the segment was possible}
  SaveSeg:=saveflag;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.butokClick(Sender: TObject);
begin
  if SaveSeg(false) then Exit;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.butcreClick(Sender: TObject);
begin
  if SaveSeg(true) then Exit;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.ButCanClick(Sender: TObject);
begin
  Exit;
end;

{--------------------------------------------------------------------}

function TEditSegSet.killCheck (talk: boolean): boolean;
// check if this segment is used by others, if yes it can not be deleted
var
  i: integer;
  a: AEpt;
  fnd: boolean;
  test,sst: string;
begin
  sst:='Empty segment not allowed, because this segment is used by segments ';
  test:=UB(segm[jsegm].nam);
  fnd:=false;
  for i:=1 to glob.Nsegm do if i<>jsegm then begin
    a:=segm[i].ini;
    while a<>nil do begin
      if (a^.nam=test) then begin
        sst:=sst+segm[i].nam+' ';
        fnd:=true;
      end;
      a:=a^.nex;
    end;
  end;
  if fnd and talk then MessageDlg(sst, mtError, [mbOK],0);
  KillCheck:= not fnd;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.butdelClick(Sender: TObject);
var
  i,j: integer;
{  a: AEpt;
  fnd: boolean;
  sst: string;}
begin
  with grid do for i:=0 to ColCount-1 do for j:=0 to RowCount-1 do Cells[i,j]:='';
  if SaveSeg(false) then Exit;
end;

{--------------------------------------------------------------------}
{events are processed in order: down - pressed - up
 catch onKeyDown for DELETE and INSERT keys to insert/delete cells,
 bypass keyPress actions, else process keyPress events
 -- does not work in Lazarus, was ok in Delphi
 bypass> restore cell content on keyUp
}

procedure TEditSegSet.gridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// press CTRL INSERT / DELETE to insert an delete cells in table
begin
  if ssCtrl in Shift then begin
    if Key  = VK_INSERT then begin
      ShiftCells(grid.Col, grid.Row,1);
      Key:=0;
    end;
    if Key  = VK_DELETE then begin
      ShiftCells(grid.Col, grid.Row,-1);
      Key:=0;
    end;
  end;
end;

{--------------------------------------------------------------------}

procedure TEditSegSet.EditSegNameKeyPress(Sender: TObject; var Key: Char);
begin
  key:=UpCase(key);
end;


procedure TEditSegSet.edperKeyPress(Sender: TObject; var Key: Char);
var
  t:real;
begin
 TEKeyVal(edper, Key, t, 4, 0);
end;

procedure TEditSegSet.edperExit(Sender: TObject);
var
  t:real;
begin
  TEReadVal(edper,t,4,0);
end;


end.
