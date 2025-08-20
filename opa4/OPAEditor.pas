unit OPAEditor;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  OPAglobal, ASaux,  EdElCreate, EdElSet, EdSgSet;

type

  { TFormEdit }

  TFormEdit = class(TForm)
    ButExit: TButton;
    ChkGloRI: TCheckBox;
    chkAllAper: TCheckBox;
    Edrref: TEdit;
    lab_rref: TLabel;
    ListBoxE: TListBox;
    ListBoxS: TListBox;
    LabelElem: TLabel;
    LabelSegm: TLabel;
    Label1: TLabel;
    LabGloE: TLabel;
    LabGloEU: TLabel;
    EditGloE: TEdit;
    ButDipInv: TButton;
    MemCom: TMemo;
    LabCom: TLabel;
    ButAllAper: TButton;
    EditAx: TEdit;
    EditAy: TEdit;
    ButInvUnd: TButton;
    procedure ButExitClick(Sender: TObject);
    procedure EdrrefExit(Sender: TObject);
    procedure EdrrefKeyPress(Sender: TObject; var Key: char);
    procedure ListBoxEClick(Sender: TObject);
    procedure ListBoxSClick(Sender: TObject);
    procedure EditGloEKeyPress(Sender: TObject; var Key: Char);
    procedure ButDipInvClick(Sender: TObject);
    procedure EditAxKeyPress(Sender: TObject; var Key: Char);
    procedure EditAyKeyPress(Sender: TObject; var Key: Char);
    procedure ButAllAperClick(Sender: TObject);
    procedure ButInvUndClick(Sender: TObject);
  private
    cshandle: TComboBox;
    EleVarNames, SegmNames: TStrings;
    radref: real;
  public
    procedure Init (handle: TComboBox);
  end;

var
  FormEdit: TFormEdit;

implementation

{$R *.lfm}

{------------------------------------------------------------}

procedure TFormEdit.ButExitClick(Sender: TObject);
var i: integer;
begin
// create new LineBuffer (Latwrite does it) and TextBuffer to serve as
// backup for texteditor

  with glob do begin
    rot_inv:=ChkGloRI.Checked;
    text:=MemCom.text;
    for i:=0 to Length(text)-1 do begin
      if text[i]='{' then text[i]:=' ';
      if text[i]='}' then text[i]:=' ';
    end;
  end;
// this has been removed, obviously works without too (13.2.2019)
//  Latwrite;
//  UpDateTextBuffer;   //????????
  with cshandle do begin
    Clear;
    Text:='select!' ;
    for i:=1 to Glob.NSegm do begin
      Items.Add(Segm[i].nam);
    end;
  end;
  if FormEdit<>nil then begin
    Release;
    FormEdit:=nil;
  end;
end;

procedure TFormEdit.EdrrefExit(Sender: TObject);
begin

end;



{------------------------------------------------------------}

procedure TFormEdit.Init (handle: TComboBox);
var i: integer;
begin
  cshandle:=handle;
  {fill elements and segments into listboxes}
  with ListBoxE do begin
    Clear;
    EleVarNames:=TStringList.Create;
    EleVarNames.Add('-- new entry --');
    for i:=1 to Glob.NElem do begin
      EleVarNames.Add(ElemToStr(i) );
    end;
    for i:=0 to High(Variable) do begin
      EleVarNames.Add(VariableToStr(i));
    end;
    Items:=EleVarNames;
  end;
  with ListBoxS do begin
    Clear;
    SegmNames:=TStringList.Create;
    SegmNames.Add('-- new entry --');
    for i:=1 to Glob.NSegm do begin
      SegmNames.Add(SegmToStr(i) );
    end;
    Items:=SegmNames;
  end;
  EditGloE.Text:=FtoS(Glob.Energy,8,4);
  ChkGloRI.Checked:=Glob.rot_inv;
  EditAx.Text:=FtoS(Glob.Ax,5,1);
  EditAy.Text:=FtoS(Glob.Ay,5,1);
  radref:=FDefGet('envel/rref');
  Edrref.Text:=Ftos(radref,5,1);
  MemCom.Text:=glob.text;
end;

{------------------------------------------------------------}

procedure TFormEdit.ListBoxEClick(Sender: TObject);
var
  iev: integer;
begin
{get index of selected element: if NEW (0) then launch elem create form,
if other, launch elem set form. pass handle to element list box for
updating}

  iev:= ListBoxE.ItemIndex;
  if iev=0 then begin
    if EditElemCreate= nil then EditElemCreate:=TEditElemCreate.Create(Application);
    EditElemCreate.Init (ListBoxE, EditSegSet);
    EditElemCreate.Show;
  end else begin
    if EditElemSet=nil then EditElemSet:=TEditElemSet.Create(Application);
    if iev <= Glob.Nelem then EditElemSet.InitE (ListBoxE) else EditElemSet.InitEVar (ListBoxE);
    EditElemSet.Show;
  end;
end;

{------------------------------------------------------------}

procedure TFormEdit.ListBoxSClick(Sender: TObject);
//var isegm: integer;
begin
//  isegm:=ListBoxS.ItemIndex;
  if EditSegSet=nil then EditSegSet:=TEditSegSet.Create(Application);
  EditSegSet.Init(ListBoxS);
  EditSegSet.Show;
end;

{------------------------------------------------------------}

procedure TFormEdit.EditGloEKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(EditGloE, Key, glob.energy, 8, 4);
end;
{------------------------------------------------------------}

procedure TFormEdit.ButDipInvClick(Sender: TObject);
var j: integer;
begin
  for j:=1 to glob.nelem do with elem[j] do begin
    if cod=cbend then begin
      phi:=-phi; tin:=-tin; tex:=-tex;
    end;
    if elem[j].cod=ccomb then begin
      cphi:=-cphi;
      cerin:=-cerin;
      cerex:=-cerex;
    end;
// ckick , csept ?
  end;
  self.Init(cshandle);
end;

procedure TFormEdit.EditAxKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(EditAx, Key, glob.ax, 5, 1);
end;

procedure TFormEdit.EditAyKeyPress(Sender: TObject; var Key: Char);
begin
  TEKeyVal(EditAy, Key, glob.ay, 5, 1);
end;

procedure TFormEdit.EdrrefKeyPress(Sender: TObject; var Key: char);
begin
  TEKeyVal(Edrref, Key, radref, 5, 1);
  DefSet('envel/rref',radref);
end;

procedure TFormEdit.ButAllAperClick(Sender: TObject);
var j:integer;
begin
  if ChkAllAper.Checked then begin
    for j:=1 to Glob.NElem do with Elem[j] do begin
      ax:=Glob.ax; ay:=Glob.ay;
    end;
  end else begin
    for j:=1 to Glob.NElem do with Elem[j] do begin
      if ax > Glob.ax then ax:=Glob.ax; if ay > Glob.ay then ay:=Glob.ay;
    end;
  end;
end;

procedure TFormEdit.ButInvUndClick(Sender: TObject);
// expand undulators -> create series of bends
// later: drop down for selection of undulator
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
        nam :='UND_POL';
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
        nam :='UND_EXP';
        ini :=nil;
        nper:=1;
        p:=AppendAE(p,dnam);
        ini:=p;
        p^.pre:=nil;
                                 p:=AppendAE(p,und.nam+'_BM1');   p:=AppendAE(p,dnam);
        p:=AppendAE(p,dnam);     p:=AppendAE(p,und.nam+'_BP3');   p:=AppendAE(p,dnam);
//        for i:=1 to Nuper-2 do   p:=AppendAE(p,'UND_POL');
        p:=AppendAE(p,'UND_POL'); p.rep:=nuper-2;
        p:=AppendAE(p,dnam);   p:=AppendAE(p,und.nam+'_BM3');   p:=AppendAE(p,dnam);
        p:=AppendAE(p,dnam);   p:=AppendAE(p,und.nam+'_BP1');   p:=AppendAE(p,dnam);
        fin:=p;
        p^.nex:=nil;
      end; // with
      self.Init(cshandle);  //update element and segment lists
    end; //not found
  end; // ju
end;

end.
