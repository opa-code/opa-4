unit EdElCreate;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType,  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OPAglobal, EdElSet, EdSgSet;

type
  TEditElemCreate = class(TForm)
    Label1: TLabel;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    NameInput: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure ComboBox1Change(Sender: TObject);
    procedure NameInputChange(Sender: TObject);
    procedure NameInputKeyPress (Sender: TObject; var Key:Char);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    Shandle: TEditSegSet;
    ListHandle: TListBox;
    newElemCode: integer;
    newElemName: ElemStr;
    procedure Exit;
  public
    procedure Init (handle: TListBox; ESShandle: TEditSegSet);
  end;

var
  EditElemCreate: TEditElemCreate;

implementation


{$R *.lfm}

procedure TEditElemCreate.ComboBox1Change(Sender: TObject);
begin
  newElemCode:=ComboBox1.ItemIndex;
end;


procedure TEditElemCreate.NameInputChange(Sender: TObject);
begin
  newElemName:= NameInput.text;
end;

procedure TEditElemCreate.NameInputKeyPress (Sender: TObject; var Key:Char);
begin
  key:=UpCase(key);
  if key=#13 then key:=#0;
end;



procedure TEditElemCreate.Exit;
begin
 if EditElemCreate<>nil then begin
    Release;
    EditElemCreate:=nil;
  end;
end;


procedure TEditElemCreate.Button2Click(Sender: TObject);
begin
 Exit;
end;

procedure TEditElemCreate.Button1Click(Sender: TObject);
begin
{check if name is valid and kind was selected}
  if newElemCode = -1 then begin
    MessageDlg('Select the type of element!',mtError, [mbOK],0);
  end else begin
    if NameCheck(newElemName) then begin
      if newElemCode = NElemKind+1 then begin // variable
        setLength(Variable, Length(Variable)+1);
        with Variable[High(Variable)] do begin
          nam:=newElemName;
          exp:=''; use:=false; Tag:=-1; val:=0;
        end;
        ListHandle.Items.Add(VariableToStr(High(Variable)));
        Exit;
        if EditElemSet=nil then EditElemSet:=TEditElemSet.Create(Application);
        ListHandle.ItemIndex:=glob.NElem+1+High(Variable);
        EditElemSet.InitEVar (ListHandle);
        EditElemSet.Show;

      end else begin
        Inc(glob.nElem);
        Elem[glob.nElem].Nam:=newElemName;
        Elem[glob.nElem].cod:=newElemCode;
{create new element in global structure, add to list:}
        Inielem(glob.nElem);
        ListHandle.Items.Insert(glob.Nelem,ElemToStr(glob.nelem));

{close this form:}
        Exit;
{redraw the grid of the segment editor if it is open - reason: maybe we
 just created an element that was claimed to be unknown there.}
        if Shandle <> nil then Shandle.grid.Refresh;

{set list index on the new element and launch form to edit the new element}
        if EditElemSet=nil then EditElemSet:=TEditElemSet.Create(Application);
        ListHandle.ItemIndex:=glob.NElem;
        EditElemSet.InitE (ListHandle);
        EditElemSet.Show;
      end;
    end else begin
      NameInput.text:='';
    end;
  end;

end;


procedure TEditElemCreate.Init (handle: TListBox; ESShandle: TEditSegSet);
var i {, index}: integer;
begin
  ListHandle:=handle;
  Shandle:=ESShandle;
  NameInput.text:='';
  with ComboBox1 do begin
    for i:=0 to NelemKind do begin
      {index:=} Items.Add(ElemName[i]);
    end;
    {index:=} Items.Add('Variable');
  end;
  newElemCode:=-1;
  newElemName:='-?-';
end;

end.




