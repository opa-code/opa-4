unit texteditor;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OPAglobal, OPALatticeFiles;

type

  TFormTxtEdt = class(TForm)
    ButChk: TButton;
    ButOK:  TButton;
    ButCnc: TButton;
    Button1: TButton;
    myerrlog: TMemo;
    EdtWin: TMemo;
    procedure filetest(Sender: TObject);
    procedure fileGet(Sender: TObject);
    procedure fileRestore(Sender: TObject);
    procedure disableOKBut(Sender: TObject);
  private
//    prevlog: TMemo;
    segselect: TComboBox;
    function getEdtTxt: pointer;
    procedure Exit;
  public
    procedure Init (cbshandle: TComboBox);
    procedure LoadLattice;
  end;

var
  FormTxtEdt: TFormTxtEdt;

implementation
                            
{$R *.lfm}

{------------------------------------------------------------------}

procedure TFormTxtEdt.Init (cbshandle: TComboBox);
const
  dd=8;
begin
//   prevLog  :=loghandle;
   segselect:=cbshandle;
   Height:=Round(0.8*Screen.height);
   Top:=Round(0.1*screen.height);
   edtwin.Left:=dd;
   edtwin.Top:=dd;
   edtwin.Height:=ClientHeight-myerrlog.height-3*dd;
   edtwin.Width:=ClientWidth-2*dd;
   myerrlog.top:=edtwin.Height+2*dd;
   myerrlog.width:=ClientWidth-myerrlog.Left-dd;
   butchk.top:=edtwin.Height+2*dd;
//   butprt.top:=butchk.top+30;
   butok.top :=butchk.top+30;
   butcnc.top:=butok.top+30;
// assign texteditor's errorlog to global errorlog - why?
   ButOK.Enabled:=True;
//   PassErrLogHandle(myerrlog); // direct error messages from latread/write to MY window
end;

{--- it seems that TMemo does not like to receive input before it is shown ? ---}
procedure TFormTxtEdt.LoadLattice;
// text editor does not work and throws weird error message if next two lines are omitted ???!!!
begin
   // clear editor window
  EdtWin.Clear;
  EdtWin.Text:=WriteLattice(0);
  // launching the text editor should copy the current file to TextBuffer, so
  // canceling the editor returns to the status when it was started and not
  // to the status when the file was read!
  TextBuffer:=GetEdtTxt;
//  dum:= Edtwin.Lines.count;
//  opamessage(0,'no. lines ='+inttostr(dum ) );
end;

{------------------------------------------------------------------}

procedure  TFormTxtEdt.Exit;
begin
  if FormTxtEdt<>nil then begin
    if segselect <>nil then begin
       FillComboSeg(segselect);
       segselect.itemindex:=glob.nsegm-1;
    end;
//    if prevlog <> nil then ErrorLog:=prevLog;
    Release;
    FormTxtEdt:=nil;
  end;
end;

{------------------------------------------------------------------}

function TFormTxtEdt.getEdtTxt: pointer;
// reads editor window into linked list of char and returns start pointer
var
  chpt: CharBufpt;
  firstchar: boolean;
  line: String;
  ich, ilin: integer;
begin
  firstchar:=true;
  New(chpt);
  chpt.nex:=nil;
  for ilin:=1 to EdtWin.Lines.Count do begin
    line:=EdtWin.Lines[ilin];
    for ich:=1 to Length(line) do begin
      chpt:=AppendChar(chpt,line[ich]);
      if firstchar then begin
        getEdtTxt:=chpt;
        firstchar:=false;
      end
    end
  end;
end;

procedure TFormTxtEdt.FileTest(Sender: TObject);
var
  TeStBuffer: Pointer;
  ntext: integer;
  mainErrLogHandle: TMemo;
begin
  TeStBuffer:=getEdtTxt;
// clear the error window and read edit window contense in order to
// obtain the error messages.
  myErrLog.Clear;
  mainErrLoghandle:=ErrLogHandle; //presently set error logging window, should point to main errlog
  passErrLogHandle(myerrlog); // direct errors from latread to my errlog window

  if TeStBuffer <>nil then begin
    ntext:=length(glob.text);
    LatRead(TestBuffer);
    LatReadCom(TestBuffer);
    if (length(glob.text)=0) and (ntext>0) then
      myErrLog.Lines.Append('warning: no comment text found. check delimiters: {com ... com}');
//     ErrorLog.Lines.Append('<<'+glob.text+'>>');
    // delete the char chain used for testing
    ClearTextBuffer(TeStBuffer);
    if myErrLog.Lines.Count=0 then begin
      myErrLog.Lines.Append('test passed successfully!');
      ButOK.Enabled:=True;
      if segselect <>nil then segselect.itemindex:=glob.nsegm-1;
    end else begin
      ButOK.Enabled:=False;
    end;
  end;
  passErrLogHandle(mainErrLogHandle); // set back the error window to main
end;

{procedure TFormTxtEdt.Button1Click(Sender: TObject);
begin
  opamessage(0,'no. lines ='+inttostr( Edtwin.Lines.count) );
  EdtWin.Text:=WriteLattice(0);
  opamessage(0,'no. lines ='+inttostr( Edtwin.Lines.count) );
end;
}
procedure TFormTxtEdt.fileGet(Sender: TObject);
var
  TestBuffer: pointer;
begin
// now use the real, global list, not the test list:
  TestBuffer:=getEdtTxt;
  if TestBuffer<>nil then begin
    LatRead(TestBuffer);
    LatReadCom(TestBuffer);
    ClearTextBuffer(TestBuffer);
    Exit;
  end;
end;

procedure TFormTxtEdt.fileRestore(Sender: TObject);
begin
// don't read TextBuffer from Edit, but return to the content
// we saved when launchingthe editor
  LatRead(TextBuffer);
  Exit;
end;

procedure TFormTxtEdt.disableOKBut(Sender: TObject);
begin
// when entering the editor, the ok button is disabled
  ButOK.Enabled:=False;
end;


end.
