unit asfigure;

//{$MODE Delphi}

// contains a paintpox and a public VPlot object for floating point vector graphics
// edit fields may be assigned to display user coords from mouse movement in graphic

interface

uses
  LCLIntf, LCLType, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, vgraph, printers, AsAux;

type
  TFigure = class(TFrame)
    p: TPaintBox;
    procedure pMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pDblClick(Sender: TObject);
  private
    chandle:TCanvas;


//    metafile: TMetaFile;

    xaxismode, yaxismode: integer;
    xaxistitle, yaxistitle: string;
    marginXfixed, marginYfixed: boolean;
    xedit, yedit: TEdit;
    xeditwid, xeditdec, yeditwid, yeditdec: integer;
    xeditcol, yeditcol: TColor;

    freeze: boolean;

    motherform: TForm;
    markbox, markenable:boolean;
    xMouseDown, yMouseDown, xMouseUp, yMouseUp, xMousePrev, yMousePrev: integer;

  public
    plot: VPlot;

    procedure assignScreen;
    function getPaintBox: TPaintBox;

//    procedure beginMetaPlot (fac: integer);
//    procedure endMetaPlot (metaname: string);

//    procedure beginPrintPlot;
//    procedure endPrintPlot;

    procedure forceMarginX(xu, xo: integer);
    procedure forceMarginY(yu, yo: integer);

    procedure Init(xmin, ymin, xmax, ymax: real;
                         xaxm, yaxm: integer; xaxt, yaxt: string;
                         mko: integer; asprat: boolean);
    procedure EnableMark;
    procedure SetSize(aleft, atop, awidth, aheight:integer);

    procedure GetPlotPos(var xl, yt, xw, yh: integer);
    function  GetRange (var x1,y1, x2,y2: real): boolean;


    procedure PassEditHandleX(xedithandle: TEdit; wx, dx: integer);
    procedure PassEditHandleY(yedithandle: TEdit; wy, dy: integer);
    procedure PassFormHandle (formhandle: TForm);
    procedure unfreezeEdit;

  end;

implementation
  {$R *.lfm}

const
  mindist=10;
  clLightYellow=$0088eeff;


  // initialization: set range and axis

// called on construction
  procedure TFigure.assignScreen;
  begin
    chandle:=p.Canvas;
    plot:=VPlot.Create(chandle);
    marginXfixed:=false; marginYfixed:=false;
  end;

  function TFigure.getPaintBox: TPaintBox;
  begin
    getPaintBox:=p;
  end;

{  procedure TFigure.beginMetaPlot (fac: integer);
  begin
    //replaced by PS_plot in vgraph
  end;

  procedure TFigure.endMetaPlot (metaname: string);
  begin
  end;
}

// force fixed margins, no autoscaling by Init and Axis
// to be called BEFORE Init!
  procedure TFigure.forceMarginX(xu, xo: integer);
  begin
    plot.SetMarginX(xu,xo);
    marginXfixed:=true;
  end;

  procedure TFigure.forceMarginY(yu, yo: integer);
  begin
    plot.SetMarginY(yu,yo);
    marginYfixed:=true;
  end;

  procedure TFigure.Init(xmin, ymin, xmax, ymax: real;
                         xaxm, yaxm: integer; xaxt, yaxt: string;
                         mko: integer; asprat: boolean);
  const
    space0=10;
  var
    xaxisspace, yaxisspace, space: integer;
    axmin, aymin, axmax, aymax: real;
  begin
    xaxismode :=xaxm; yaxismode :=yaxm;
    xaxistitle:=xaxt; yaxistitle:=yaxt;
    axmin:=xmin; aymin:=ymin; axmax:=xmax; aymax:= ymax;

    freeze:=false;
    plot.SetRange (xmin,xmax,ymin,ymax);
    if asprat then plot.AdjustAspectRatio(axmin, aymin, axmax, aymax);

    XaxisSpace:=plot.getaxisspace(2*xaxismode-1, axmin,axmax, xaxistitle);
    YaxisSpace:=plot.getaxisspace(2*yaxismode  , aymin,aymax, yaxistitle);
    space:=space0*plot.GetFactor;

    if not MarginYfixed then begin
      case xaxismode of
        1:begin  // x axis at bottom (= top on screen)
            plot.SetMarginY(space,XaxisSpace);
          end;
        2:begin // x axis at top (=bottom on screen)
            plot.SetMarginY(XaxisSpace, space);
          end;
        else begin
            plot.SetMarginY(space, space);
        end;
      end;
    end;
    if not MarginXfixed then begin
      case yaxismode of
        1:begin // y axis at left
            plot.SetMarginX(YaxisSpace, space);
          end;
        2:begin // y axis at right
            plot.SetMarginX(space, YaxisSpace);
          end;
        else begin
            plot.SetMarginX(space, space);
        end;
      end;
    end;
    plot.SetRange (axmin,axmax,aymin,aymax);
//    if asprat then plot.AdjustAspectRatio;

//    plot.SetRange (xmin,xmax,ymin,ymax);
    plot.Clear(clWhite);
    plot.SetDefaultDrawPen;
    plot.Frame;
// mark the origin
    plot.MarkOrigin(mko);
// draw the axis
    if xaxismode > 0 then plot.Axis(2*xaxismode-1, clBlack, xaxistitle); // 1,2->1,3
    if yaxismode > 0 then plot.Axis(2*yaxismode,   clBlack, yaxistitle); // 1,2 ->2,4
    markenable:=false;
  end;

  procedure TFigure.enableMark;
  begin
    markenable:=True;
  end;

  // set figure size (after resize of parent), GUI only
  procedure TFigure.SetSize(aleft, atop, awidth, aheight:integer);
  const
    edge=2;
  begin
    SetBounds(aleft, atop, awidth, aheight);
    p.SetBounds(edge, edge, awidth-2*edge, aheight-2*edge);
    plot.SetArea(p.width, p.height);
  end;



//pass handles to TEdit fields to show the mouse movements in the paintbox window
// separate procs to be able to only set one
  procedure TFigure.PassEditHandleX(xedithandle: TEdit; wx, dx: integer);
  begin
    xedit:=xedithandle;
    xeditcol:=xedit.Color;
    xeditwid:=wx; xeditdec:=dx;
  end;
  procedure TFigure.PassEditHandleY(yedithandle: TEdit; wy, dy: integer);
  begin
    yedit:=yedithandle;
    yeditcol:=yedit.Color;
    yeditwid:=wy; yeditdec:=dy;
  end;

//pass handle to TForm panel to launch its repaint event...?
  procedure TFigure.PassFormHandle (formhandle: TForm);
  begin
    motherform:=formhandle;
  end;


procedure TFigure.getPlotPos(var xl, yt, xw, yh: integer);
// return position of plot on parent form in pixel
begin
  plot.GetPlotPos(xl, yt, xw, yh);
  Inc(xl,p.left+left);
  Inc(yt,p.top + top);
end;

// on mouse click freeze or unfreeze edit fields
// change color to indicate freeze status
procedure TFigure.pMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (mbLeft = Button) and markenable then begin
    markbox:=true;
    xMouseDown:=x;
    yMouseDown:=y;
  end;

  freeze:=not freeze;
  if xedit<>nil then begin
    xedit.text:=USnumber(FloattoStrF(plot.getx(x),fffixed,xeditwid,xeditdec));
    if freeze then xedit.Color:=clLightYellow else xedit.Color:=xeditcol;
  end;
  if yedit<>nil then begin
    yedit.text:=USnumber(FloattoStrF(plot.gety(y),fffixed,yeditwid,yeditdec));
    if freeze then yedit.Color:=clLightYellow else yedit.Color:=yeditcol;
  end;
end;

// show mouse position in plot coords in edit fields
procedure TFigure.pMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  markbox:=markbox and (ssLeft in Shift);
  if markbox then begin
    plot.IRectangle(XMouseDown,YMouseDown,XMousePrev,YMousePrev);
    plot.IRectangle(XMouseDown,YMouseDown,X,Y);
  end;
  XMousePrev:=X; YMousePrev:=Y;

  if not freeze then begin
    if xedit<>nil then xedit.text:=USnumber(FloattoStrF(plot.getx(x),fffixed,xeditwid,xeditdec));
    if yedit<>nil then yedit.text:=USnumber(FloattoStrF(plot.gety(y),fffixed,yeditwid,yeditdec));
  end;
end;

{
if the form, where this figure is embedded, has been assigned,
the repaint proc of the form is called to adjust the plot to
the area marked by the mouse...
--> no, better only repaint the figure.
}
procedure TFigure.pMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if motherform=nil then markbox:=false else begin
    if (mbLeft = Button) and markbox then
    if (abs(x-xMouseDown)>mindist) and (abs(y-yMouseDown)>mindist) then begin
      xMouseUp:=x; yMouseUp:=y;
 //     motherform.repaint; //this was enabled before
      self.repaint; // better only repaint myself, otherwise a 2nd event is launched by form paint (?) 6.2.20
      markbox:=false;
    end;
  end;
end;

function TFigure.GetRange (var x1,y1, x2,y2: real): boolean;
begin
  if markbox then begin
  // return mouseBox
    x1:=plot.getx(xMouseDown); y1:=plot.gety(yMouseDown);
    x2:=plot.getx(xMouseUp  ); y2:=plot.gety(yMouseUp  );
  end else begin
  // just return present range
    plot.getrange(x1,y1,x2,y2);
  end;
  getrange:=markbox;
end;

procedure TFigure.unfreezeEdit;
begin
  freeze:=false;
  if xedit<>nil then xedit.Color:=xeditcol;
  if yedit<>nil then yedit.Color:=yeditcol;
end;

procedure TFigure.pDblClick(Sender: TObject);
begin
  plot.grabimage;
end;

end.
