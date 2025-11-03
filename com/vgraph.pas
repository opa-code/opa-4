// vector graphics using real functions
// wraps TCanvas functionality


// to do: carefully check axis space calculation for PS output! x ax on top does not work yet 23.7.2024

unit vgraph;

//{$MODE Delphi}
                                                 
interface

uses LCLIntf, LCLType, Graphics, Classes, Clipbrd, Dialogs, sysutils, Math;

type
  VPlot = class (TObject)
    private
      cnv: TCanvas;                        // canvas to plot
      pxbot, pxtop, pybot, pytop,          //bottom and top margins of plot area
      pxrange, pyrange, pxtotal, pytotal,  //width and height of plot, resp. canvas
//      pxoffset, pyoffset,                  //offset of whole plot to canvas (0,0)
      px0, py0: integer;                   //origin of plot (left,lower) in pixel
      xmin, xmax, ymin, ymax,              //plot size in user coordinates
      xrange, yrange, scalx, scaly: real;  //plot range and scaling factors
      factor: integer; fontFactor: real;   //scaling factors for symbols and fonts
      pxsym, pysym, symtyp: integer;       //symbol size and type
      PS: boolean;                         //postscript mode
      fps: textfile;
      procedure AxisPrivate (mode: Integer; ra1, ra2: real; col:TColor; caption: string; var LabelSpace:integer);
      function ps_color(col: TColor): string;

    public
      constructor Create (chandle:TCanvas);
//      destructor  Close;
      procedure PS_start (psfile, opacom: string; var errmsg: string);
      procedure PS_stop;

      procedure SetDefaultDrawPen;
      procedure SetDefaultDragPen;
      procedure SetCanvas(chandle: TCanvas);

//      procedure SetOffset(xoff, yoff: integer);
      procedure SetArea(iwidth, iheight: integer);

      procedure SetFactor    (fac        : integer);
      function  GetFactor: integer;
      procedure SetFontFactor(fontfac    : real);

      procedure ScaleByFactor(fac,fontfac: integer);

      procedure SetMarginX(bottom, top: integer);
      procedure SetMarginY(bottom, top: integer);
      procedure SetMargin (xbot, xtop, ybot, ytop: integer);

      procedure SetRangeX (x0, x1: real);
      procedure SetRangeY (y0, y1: real);
      procedure SetRange  (x0, x1, y0, y1: real);
      procedure GetPlotPos (var pxl, pyt, pxw, pyh: integer);
      procedure GetRange(var x0,y0, x1,y1 :real);
      procedure ReSetScale;

      function getpx(x: Real): integer;
      function getpy(y: Real): integer;

      function PS_getpx(x: Real): string;
      function PS_getpy(y: Real): string;
      function PS_getpxr(x: Real): real;
      function PS_getpyr(y: Real): real;

      function getx(px: integer): real;
      function gety(py: integer): real;
      function getdx(dpx: integer): real;
      function getdy(dpy: integer): real;

      procedure MoveTo(x,y: real);
      procedure LineTo(x,y: real);
      procedure Stroke;
      procedure Line(x1, y1, x2, y2: real);
      procedure Rectangle(x1,y1, x2, y2: real);
      procedure IRectangle(px1,py1,px2,py2:integer);
      procedure Frame;

    //  procedure Polygon(x,y: array of real; LineCol, FillCol: TColor);
      procedure Polygon4(x,y: array of real; LineCol, FillCol: TColor);
      procedure Polygon(x,y: array of real; start, count: integer; LineCol, FillCol: TColor);

      procedure SetColor (col:TColor);
      function  GetColor:TColor;
      procedure SetStyle (sty: TPenStyle);
      procedure SetThick (t:integer);

      procedure PSolid (x1, y1, x2, y2: Real; col: TColor);
      procedure Solid  (x1, y1, x2, y2: Real; col: TColor);
      procedure ClearArea (col: TColor);
      procedure ClearView (cl, cr, ct, cb: Boolean; col: TColor);
      procedure Clear (col: TColor);

      procedure SetSymbol(size: integer; typ:integer; col: TColor);
      procedure Symbol (x,y: real);
      procedure Symbolc (x,y: real; col: TColor);
      procedure Symbol0(x,y: real; size: integer; typ:integer; col: TColor);
      procedure Arrow(x0,y0,ang,size: real);

      procedure MarkOriginX;
      procedure MarkOriginY;
      procedure MarkOrigin (mko:integer);

      function GetAspectRatio: real;
      procedure AdjustAspectRatio(var axmin, aymin, axmax, aymax: real);

      function  GetAxisSpace (mode:integer; au, ao: real; caption: string): integer;
      procedure Axis (mode: Integer; col:TColor; caption: string);
      procedure AxisPart (mode: Integer; ra1, ra2: real; col:TColor; caption: string);


//      procedure FDC_TextOut(x,y,winkel,groesse:integer;txt:string);
      procedure TextAlign(s:string; x,y: real; xalign, yalign: integer; col:TColor);

      procedure Circle (xorg, yorg, rad: real; col: TColor);
      procedure Ellipse (Be, Al, Em, Orb, OrbP, skal, skalP: real; col: TColor);

      procedure GrabImage;

    end;

implementation

  const
    eps=1e-20;
    defaultFontName='Courier New';
    defaultFontSize=12;
    axisFontName='Courier New';
//    axisFontSize=10;
    axisNticks=5;
    // settings for postscript output
    //linestyles and thickness factor
    ps_solid  = '[] 0 setdash';
    ps_dashed = '[10 4] 5 setdash';
    ps_dotted = '[2 3] 0 setdash';
    ps_thkfac = 0.3 ; // thickness 1 corresponds to 0.3 pt ~ 0.1 mm
    ps_fontsize= 14;


  constructor VPlot.Create(chandle:TCanvas);
  begin
  {
   construct with canvas and size, this is a must,
   for margins etc set some reasonable defaults:
  }

//OPAMessage(0,'vplot.create');
    SetCanvas(chandle);
//    SetOffset(0,0);
    SetArea(100,100);
    SetFactor(1);
    SetFontFactor(1);
    SetMargin(10,10,10,10);
    SetRange (0.0, 1.0, 0.0, 1.0);
    PS:=false;
  end;

//destructor VPlot.Close;
//begin
//end;

  procedure VPlot.PS_start (psfile, opacom: string; var errmsg: string);
  begin
    try
      AssignFile(fps,psfile);
      rewrite(fps);
      PS:=true;
      errmsg:='';
      writeln(fps,'%!PS-Adobe-3.0');
      writeln(fps,'%%Title: '+psfile);
      writeln(fps,'%%Creator: '+opacom);
      writeln(fps,'%%CreationDate: ',DateTimeToStr(Now));
      writeln(fps,'%%BoundingBox: 0 0 ', pxtotal, ' ', pytotal); // to be changed dep on format
      writeln(fps,'%%EndComments');
      //ps procs for centered and right aligned text
      writeln(fps,'/centertext {dup stringwidth pop -2 div 0 rmoveto show} def');
      writeln(fps,'/raligntext {dup stringwidth pop neg 0 rmoveto show} def');
      // ps procs for hori and vert aligned text
      writeln(fps,'/rightmidtext  {dup false charpath pathbbox exch 4 -1 roll 2 mul sub neg 3 1 roll exch 3 mul sub neg 2 div moveto show newpath} def');
      writeln(fps,'/leftmidtext   {dup false charpath pathbbox exch pop exch 3 mul sub neg 2 div moveto show newpath} def');
      writeln(fps,'/centertoptext {dup false charpath pathbbox exch 4 -1 roll 3 mul sub neg 2 div 3 1 roll exch 2 mul sub neg moveto show newpath} def');
      writeln(fps,'/centerbottext {dup false charpath pathbbox exch 4 -1 roll 3 mul sub neg 2 div 3 1 roll pop moveto show newpath} def');
      {   dup 			   % s s 		(s=text to show)
          false charpath pathbbox  % s x1 y1 x2 y2
          exch 4 -1 roll	   % s y1 y2 x2 x1
          3 mul sub neg 2 div	   % s y1 y2 xout=-(x2-3*x1)/2 = x1-dx/2  --> centered
          2 mul sub neg            % s y1 y2 xout=-(x2-2*x1)   = x1-dx    --> right bound
          3 1 roll exch 	   % s xout y2 y1
          3 mul sub neg 2 div	   % s xout yout=-(y2-3*y1)/2 = y1-dy/2   --> vert. centered
          moveto show newpath      % print text at xout yout position and erase stored path
       ??? In case of some particular texts, results become wrong, not yet understood
      }

    except
      on E: EInOutError do
        errmsg:='File handling error occurred: '+E.Message;
    end;
  end;

  procedure VPlot.PS_stop;
  begin
    if PS then begin
      writeln(fps,'%%EOF');
      closefile(fps);
    end;
    PS:=false;
  end;

  procedure VPlot.SetCanvas(chandle: TCanvas);
  begin
//    if chandle=nil then writeln('vplot setcanvas nil');
    cnv:=chandle;
    with cnv.Font do begin
      Color:=clblack;
      Size:=defaultFontSize;
      Name:=defaultFontName;
    end;
  end;

  procedure VPlot.SetDefaultDrawPen;
  begin
    setColor(clBlack);
    setThick(1);
    setStyle(psSolid);
    if not PS then with cnv.Pen do begin
      Mode:=pmCopy;
    end;
  end;

  procedure VPlot.SetDefaultDragPen;
  begin
    with cnv.Pen do begin
      Mode:=pmNotXor; Color:=clBlack; Style:=psDash; Width:=1;
    end;
  end;

{ never used
  procedure VPlot.SetOffset(xoff, yoff: integer);
  begin
    pxoffset:=xoff;
    pyoffset:=yoff;
  end;
}
  procedure VPlot.SetArea(iwidth, iheight: integer);
  begin
    pxtotal:=iwidth;
    pytotal:=iheight;
  end;

  procedure VPlot.SetFactor(fac: integer);
  begin
    factor:=fac;
  end;

  function VPlot.GetFactor: integer;
  begin
    GetFactor:=Factor;
  end;

  procedure VPlot.SetFontFactor(fontFac: real);
  begin
    fontFactor:=fontFac;
  end;

  // scale an existing plot to a new size
  procedure VPlot.ScaleByFactor(fac, fontfac: integer);
  var
    r: real;
  begin
    r     :=fac/factor; // ratio new factor to old one
    setFactor(fac);
    setFontFactor(fontFac);
    SetArea(round(r*pxtotal), round(r*pytotal));
    SetMargin(round(r*pxbot),round(r*pxtop),round(r*pybot),round(r*pytop));
    SetRange (xmin,xmax,ymin,ymax);
//?    cnv.Font.Size:=Round(r*cnv.Font.Size);
  end;


  procedure VPlot.SetMarginX(bottom, top: integer);
  begin
    pxbot  :=bottom;
    pxtop  :=top;
    pxrange:=pxtotal-pxbot-pxtop;
    px0    :=pxbot {+pxoffset};
  end;

  procedure VPlot.SetMarginY(bottom, top: integer);
  begin
    pybot  :=bottom;
    pytop  :=top;
    pyrange:=pytotal-pybot-pytop;
    py0    :=pytotal-pytop{+pyoffset}; //+ since offset comes from top
  end;

  procedure VPlot.SetMargin (xbot, xtop, ybot, ytop: integer);
  begin
    SetMarginX(xbot,xtop);
    SetMarginY(ybot,ytop);
  end;

  procedure VPlot.GetPlotPos (var pxl, pyt, pxw, pyh: integer);
  begin
    pxl:=pxbot; pxw:=pxrange;
    pyt:=pybot; pyh:=pyrange;
  end;

  procedure VPlot.SetRangeX(x0, x1: real);
  begin
    xmin:=x0;
    xmax:=x1;
    xrange:=xmax-xmin;
    if abs(xrange) > eps then scalx:=pxrange/xrange else begin
      scalx:=1.0;
      xrange:=pxrange;
      xmin:=pxbot;
      xmax:=pxbot+pxrange;
    end;
  end;

  procedure VPlot.SetRangeY(y0, y1: real);
  begin
    ymin:=y0;
    ymax:=y1;
    yrange:=ymax-ymin;
    if abs(yrange) > eps then scaly:=-pyrange/yrange else begin
      //      scaly:=-1.0;
      scaly:= 1.0;
      yrange:=pyrange;
//      ymin:=pybot;
//      ymax:=pybot+pyrange;
// use full canvas in pixel mode (?)
      ymin:=0;
      ymax:=pytotal;
//writeln('vplot setrangeY ymin, ymax ', round(ymin),' ', round(ymax));
    end;
  end;

  procedure VPlot.SetRange(x0, x1, y0, y1: real);
  begin
    SetRangeX(x0, x1);
    SetRangeY(y0, y1);
  end;

  procedure VPlot.GetRange(var x0,y0, x1,y1 :real);
  begin
    x0:=xmin; x1:=xmax; y0:=ymin; y1:=ymax;
  end;

// adjusts scales after resize of canvas
  procedure VPlot.ReSetScale;
  begin
    SetMargin(pxbot,pxtop,pybot,pybot);
    SetRange(xmin,xmax,ymin,ymax);
  end;

  //data to pixel
  function VPlot.getpx(x: Real): integer;
  begin
    getpx:=px0+Round(scalx*(x-xmin));
  end;

  function VPlot.getpy(y: Real): integer;
  begin
    getpy:=py0+Round(scaly*(y-ymin));
  end;

  //data to PS pixel (may be fractional)
  function VPlot.PS_getpx(x: Real): string;
  begin
    PS_getpx:=FloatToStrF(PS_getpxr(x), fffixed, 8, 2)+' ';
  end;

  function VPlot.PS_getpy(y: Real): string;
  begin
    PS_getpy:=FloatToStrF(PS_getpyr(y), fffixed, 8, 2)+' ';
  end;
  //data to PS pixel (may be fractional)
  function VPlot.PS_getpxr(x: Real): real;
  begin
    PS_getpxr:=px0+scalx*(x-xmin);
  end;

  function VPlot.PS_getpyr(y: Real): real;
  begin
    PS_getpyr:=pytotal-(py0+scaly*(y-ymin));
  end;

  // pixel to data
  function VPlot.getx(px: integer): real;
  begin
    getx:=xmin + (px-px0)/scalx;
  end;

  function VPlot.gety(py: integer): real;
  begin
    gety:=ymin + (py-py0)/scaly;
  end;

  function VPlot.getdx(dpx: integer): real;
  begin
    getdx:=dpx/scalx;
  end;

  function VPlot.getdy(dpy: integer): real;
  begin
    getdy:=dpy/scaly;
  end;

//line drawing
  procedure VPlot.MoveTo(x,y: real);
  begin
    if PS
    then writeln(fps,PS_getpx(x), PS_getpy(y), 'moveto')
    else cnv.MoveTo(getpx(x),getpy(y));
  end;

  procedure VPlot.LineTo(x,y: real);
  begin
    if PS
    then writeln(fps,PS_getpx(x), PS_getpy(y), 'lineto')     //no stroke yet
    else cnv.LineTo(getpx(x),getpy(y));
  end;

  procedure VPlot.Stroke; //to terminate curve in ps mode
  begin
    if PS then writeln(fps,'stroke');
  end;

  procedure VPlot.Line(x1, y1, x2, y2: real);
  begin
    MoveTo(x1,y1); LineTo(x2,y2);
    if PS then writeln(fps,'stroke');
  end;

  procedure VPlot.Rectangle(x1,y1, x2, y2: real);
  begin
    MoveTo(x1, y1); LineTo(x1, y2); LineTo(x2,y2); LineTo(x2,y1); LineTo(x1,y1);
    if PS then writeln(fps,'stroke');
  end;

  procedure VPlot.IRectangle(px1,py1,px2,py2:integer);
  //rectangle in pixel
  begin
    with cnv do begin
      SetDefaultDragPen;
      Brush.Style:=bsClear;
      Rectangle(Rect(px1,py1,px2,py2));
    end;
  end;

  procedure VPlot.Frame;
  begin
    Rectangle(xmin, ymin, xmax, ymax);
  end;


  procedure VPlot.Polygon(x,y: array of real; start, count: integer; LineCol, FillCol: TColor);
  var
    p: array of TPoint;
    i: integer;
    prevPenstyle: TPenStyle;
    prevBrushstyle: TBrushStyle;
  begin
    if count > 2 then begin
      setLength(p,count);
      for i:=0 to count-1 do begin
        p[i].x:=GetPx(x[start+i]);
        p[i].y:=GetPy(y[start+i]);
      end;
      with cnv do begin
        prevPenstyle:=Pen.Style; prevBrushstyle:=Brush.Style;
        if LineCol =-1 then Pen.Style :=psClear else begin
          Pen.Color:=LineCol;
          Pen.Style:=psSolid;
        end;
        if FillCol =-1 then Brush.style :=bsClear else begin
          Brush.Color :=FillCol;
          Brush.Style :=bssolid;
        end;
        Polygon(p);
        Pen.style:=prevPenstyle;  Brush.style:=prevBrushstyle;
      end;
      p:=nil;
    end;
  end;

  procedure VPlot.Polygon4(x,y: array of real; LineCol, FillCol: TColor);
  var
    p: array of TPoint;
    i: integer;
    prevPenstyle: TPenStyle;
    prevBrushstyle: TBrushStyle;
  begin
    setLength(p,4);
    for i:=0 to 3 do begin
      p[i].x:=GetPx(x[i]);  p[i].y:=GetPy(y[i]);
    end;
    with cnv do begin
      prevPenstyle:=Pen.Style; prevBrushstyle:=Brush.Style;
      if LineCol =-1 then Pen.Style :=psClear else begin
        Pen.Color:=LineCol;  Pen.Style:=psSolid;
      end;
      if FillCol =-1 then Brush.style :=bsClear else begin
        Brush.Color :=FillCol;  Brush.Style :=bssolid;
      end;
      Polygon(p);
      Pen.style:=prevPenstyle;  Brush.style:=prevBrushstyle;
      p:=nil;
    end;
  end;

  function VPlot.ps_color(col: TColor): string;
  var r,g,b: real; c: integer;
  begin
    c:=col;
    b:= c div 65536; c:=c - round(65536*b);
    g:= c div 256  ; r:=c-  round(256*g);
    ps_color:= FloatToStrF(r/255,fffixed,5,3) + ' '+FloatToStrF(g/255,fffixed,5,3)+' '
             + FloatToStrF(b/255,fffixed,5,3) + ' setrgbcolor';
  end;

  procedure VPlot.SetColor(col:TColor);
  var r,g,b: real; c: integer;
  begin
    if PS
    then writeln(fps, ps_color(col))
    else cnv.Pen.Color:=col
  end;

  function VPlot.GetColor:TColor;
  begin
    GetColor:=cnv.Pen.Color;
  end;

  procedure VPlot.SetStyle(sty: TPenStyle);
  begin
    if PS then begin
      case sty of
        psDash:  writeln(fps, ps_dashed);
        psDot:   writeln(fps, ps_dotted);
        psClear: writeln(fps, '1 1 1 setrgbcolor ',ps_solid); //clear = white line (?)
        else writeln(fps, ps_solid);
      end;
    end
    else cnv.Pen.Style:=sty;
  end;

  procedure VPlot.SetThick(t:integer);
  begin
    if PS
    then writeln(fps, ps_thkfac*t:6:2 ,' setlinewidth')
    else cnv.Pen.Width:=t;
  end;

  procedure VPlot.PSolid (x1, y1, x2, y2: Real; col: TColor);
// workaround: alternative to Solid using Polygon instead of FillREct,
// which, for reasons not yet understood, sometimes does not work
   var
    p: array[0..3] of TPoint;
    i: integer;
    prevPenstyle: TPenStyle;
    prevBrushstyle: TBrushStyle;
    sx1, sx2, sy1, sy2: string;
  begin
    if PS then begin
      writeln(fps, ps_color(col));
      sx1:=PS_getpx(x1); sy1:=PS_getpy(y1);  sx2:=PS_getpx(x2); sy2:=PS_getpy(y2);
      writeln(fps, sx1, sy1, 'moveto');      writeln(fps, sx2, sy1, 'lineto');
      writeln(fps, sx2, sy2, 'lineto');      writeln(fps, sx1, sy2, 'lineto');
      writeln(fps, 'closepath fill');
    end else begin
      p[0].x:=GetPx(x1); p[1].x:=GetPx(x2); p[2].x:=p[1].x;    p[3].x:=p[0].x;
      p[0].y:=GetPy(y1); p[1].y:=p[0].y;    p[2].y:=GetPy(y2); p[3].y:=p[2].y;
      with cnv do begin
        prevPenstyle:=Pen.Style; prevBrushstyle:=Brush.Style;
        Pen.Style :=psClear;
        Brush.Color :=Col;  Brush.Style :=bssolid;
        Polygon(p);
        Pen.style:=prevPenstyle;  Brush.style:=prevBrushstyle;
      end;
    end;
  end;

  procedure VPlot.Solid (x1, y1, x2, y2: Real; col: TColor);
  var
    rec: TRect;
  begin
    if PS then begin
      writeln(fps, ps_color(col));
      writeln(fps, PS_getpx(x1), PS_getpy(y1), 'moveto');
      writeln(fps, PS_getpx(x2), PS_getpy(y1), 'lineto');
      writeln(fps, PS_getpx(x2), PS_getpy(y2), 'lineto');
      writeln(fps, PS_getpx(x1), PS_getpy(y2), 'lineto');
      writeln(fps, 'closepath fill');
    end else begin
      rec:=Rect(getpx(x1), getpy(y1), getpx(x2), getpy(y2));
      with cnv do begin
        Brush.Color:=col;
        Brush.style:=bssolid;
        FillRect(rec);
      end;
    end;
  end;

//paint data area only with color col
  procedure VPlot.ClearArea(col: TColor);
  begin
    Solid(xmin,ymin,xmax, ymax, col);
  end;

  // paint part of canvas with color col
  procedure VPlot.ClearView (cl, cr, ct, cb: boolean; col: TColor);
  var rec: TRect;
  begin
    with cnv do begin
      Brush.Color:=col;
      Brush.style:=bssolid;
      if cl then rec.left  :=0       else rec.left  :=px0;
      if ct then rec.top   :=0       else rec.top   :=pytop;
      if cr then rec.right :=pxtotal else rec.right :=pxtotal-pxtop;
      if cb then rec.bottom:=pytotal else rec.Bottom:=py0;
      FillRect(rec);
    end;
  end;

// paint whole canvas with color col
  procedure VPlot.Clear(col: TColor);
  var rec: TRect;
  begin
    if PS then
    //nothing ?
    else with cnv do begin
      Brush.Color:=col;
      Brush.style:=bssolid;
      rec.left:=0; rec.top:=0; rec.right:=pxtotal; rec.bottom:=pytotal;
      FillRect(rec);
    end;
  end;

//define symbol approx pixel size, set color
  procedure VPlot.SetSymbol(size: integer; typ:integer; col: TColor);
  begin
    symtyp:=typ; pxsym:=factor*size; pysym:=factor*size; // check for aspect ratio ?
    setColor(col);
  end;

  procedure VPlot.Symbolc (x,y: real; col: TColor);
  begin
    setcolor(col);
    Symbol(x,y);
  end;

  procedure VPlot.Symbol(x,y: real);
  var
    pxm, pym: integer;

    function pss(x, y:real):string;
    begin
      pss:=FloatToStrF(x, fffixed, 8, 2)+' '+FloatToStrF(y, fffixed, 8, 2)+' ';
    end;

  begin
    if PS then begin
      pxm:=round(ps_getpxr(x)); pym:=round(ps_getpyr(y));    //writeln(fps,'% symbol ',pxm,' ', pym, ' ',pxsym, ' ',pysym);
      case symtyp of
        1: begin { + }
          writeln(fps, pss(pxm, pym-pysym), 'moveto ',pss(pxm,pym+pysym),'lineto stroke');
          writeln(fps, pss(pxm-pxsym,pym) , 'moveto ',pss(pxm+pxsym,pym),'lineto stroke');
        end;
        2: begin {diamond}
          writeln(fps, pss(pxm      ,pym-pysym),'moveto ',
                       pss(pxm+pxsym,pym      ),'lineto ',
                       pss(pxm      ,pym+pysym),'lineto ',
                       pss(pxm-pxsym,pym      ),'lineto ',
                       pss(pxm      ,pym-pysym),'lineto stroke');
        end;
        3: begin {Y}
          writeln(fps, pss(pxm-pxsym,pym-pysym),'moveto ',
                       pss(pxm      ,pym      ),'lineto ',
                       pss(pxm      ,pym+pysym),'lineto stroke');
          writeln(fps, pss(pxm+pxsym,pym-pysym),'moveto ',
                       pss(pxm      ,pym      ),'lineto stroke');
        end;
        else {=0} begin { X }
          writeln(fps, pss(pxm-pxsym,pym-pysym),'moveto ',pss(pxm+pxsym, pym+pysym),' lineto stroke');
          writeln(fps, pss(pxm-pxsym,pym+pysym),'moveto ',pss(pxm+pxsym, pym-pysym),' lineto stroke');
        end;
      end;
    end else begin
      pxm:=getpx(x) ;
      pym:=getpy(y);
      with cnv do begin
        case symtyp of
          1: begin { + }
            moveto(pxm,pym-pysym); lineto(pxm,pym+pysym);
            moveto(pxm-pxsym,pym); lineto(pxm+pxsym,pym);
          end;
          2: begin {diamond}
            moveto(pxm      ,pym-pysym);
            Lineto(pxm+pxsym,pym      );
            Lineto(pxm      ,pym+pysym);
            Lineto(pxm-pxsym,pym      );
            Lineto(pxm      ,pym-pysym);
          end;
          3: begin {Y}
            moveto(pxm-pxsym,pym-pysym);
            lineto(pxm      ,pym      );
            lineto(pxm      ,pym+pysym);
            moveto(pxm+pxsym,pym-pysym);
            lineto(pxm      ,pym      );
          end;
          else {=0} begin { X }
            moveto(pxm-pxsym,pym-pysym); lineto(pxm+pxsym, pym+pysym);
            moveto(pxm-pxsym,pym+pysym); lineto(pxm+pxsym, pym-pysym);
          end;
        end;
      end;
    end;
  end;

  procedure VPlot.Symbol0(x,y: real; size, typ: integer; col:TColor);
  begin
    SetSymbol(size,typ,col);
    Symbol(x,y);
  end;

  procedure VPlot.Arrow(x0,y0,ang,size: real);
  const
    na=6;
    xa:array[0..na] of real=( 0.0, 0.0,-0.1, 1.0, 0.8, 1.0, 0.8);
    ya:array[0..na] of real=(-0.1, 0.1, 0.0, 0.0,-0.15, 0.0, 0.15);
  var
    x, y: array[0..na] of real;
    ca, sa: real;
    ia: integer;
  begin
    ca:=cos(ang); sa:=sin(ang);
    for ia:=0 to na do begin
      x[ia]:=x0+ (ca*xa[ia] - sa*ya[ia])*size;
      y[ia]:=y0+ (sa*xa[ia] + ca*ya[ia])*size;
    end;
    line(x[0],y[0],x[1],y[1]);
    line(x[2],y[2],x[3],y[3]);
    moveto(x[4],y[4]); lineto(x[5],y[5]); lineto(x[6],y[6]); stroke;
  end;

  procedure VPlot.MarkOriginX;
  begin
    if (xmin*xmax<0) then Line(0,ymin,0,ymax);
  end;

  procedure VPlot.MarkOriginY;
  begin
    if (ymin*ymax<0) then Line(xmin,0,xmax,0);
  end;

  procedure VPlot.MarkOrigin(mko:integer);
  begin
    if mko mod 2 =1 then MarkOriginX; //1,3
    if mko div 2 =1 then MarkOriginY; //2,3
  end;

//return aspect ratio of plot region (to adjust ranges
  function VPlot.GetAspectRatio: real;
  begin
    GetAspectRatio:=1.0*pyrange/pxrange;
  end;

//adjust the user plot range to the pixel plot range by increasing the smaller range
//return adjusted values, because OPAFigure may need them for dimensioning
  procedure VPlot.AdjustAspectRatio(var axmin, aymin, axmax, aymax: real);
  var
    fac, mid, del: real;

  begin
    fac:=(yrange/xrange)/(pyrange/pxrange); //= user asprat / pixel asprat
//OPAMessage(0,ftos(xmin,9,3)+' X '+ftos(xmax,9,3)+' | '+ftos(ymin,9,3)+' y '+ftos(ymax,9,3)+ ' | '+ftos(fac,9,4));
    if fac > 1 then begin //stretch x
      mid :=(xmax+xmin)/2;
      del :=(xmax-xmin)/2*fac;
      xmin:=mid-del; xmax:=mid+del;
      SetRangeX(xmin,xmax);
//OPAMessage(0,ftos(xmin,9,3)+' X '+ftos(xmax,9,3));
    end else if fac < 1 then begin //stretch y
      mid :=(ymax+ymin)/2;
      del :=(ymax-ymin)/2/fac;
      ymin:=mid-del; ymax:=mid+del;
      SetRangeY(ymin,ymax);
//OPAMessage(0,ftos(ymin,9,3)+' Y '+ftos(ymax,9,3));
    end;
    axmin:=xmin; aymin:=ymin; axmax:=xmax; aymax:= ymax;
  end;

  function VPlot.GetAxisSpace (mode:integer; au, ao: real; caption: string): integer;
//guess how much space will be needed for the axis annotations
  const
    dummyCol=clLime;
  var
    space: integer;
  begin
    // call axisPrivate with any space<>0, then it will only calc the margins but draw nothing
    space:=123;
    AxisPrivate(mode, 0,1, dummyCol, caption, space);
    GetAxisSpace:=space;
  end;


  procedure VPlot.Axis(mode: Integer; col:TColor; caption: string);
  var
    dummySpace:integer;
  begin
// call axis with zero space, then it will draw the axis
    dummySpace:=0;
    AxisPrivate(mode, 0, 1, col, caption, dummySpace);
  end;

  procedure VPlot.AxisPart (mode: Integer; ra1, ra2: real; col:TColor; caption: string);
// draw axis on a partial range of the interval, relative [rau, rao]
  var
    dummySpace:integer;
  begin
    dummySpace:=0;
    AxisPrivate(mode, ra1, ra2, col, caption, dummySpace);
  end;


  procedure VPlot.AxisPrivate (mode: Integer; ra1,ra2: real; col:TColor; caption: string; var LabelSpace:integer);
  {
    Mode: 1:x, 2:y
          3: xtop, 4: ytop
    Farbe
    Beschriftung
  }

  const
    md : array[1..4] of real = (1,2,5,10);
    eps=1E-5;

  var
    au, ao, mag, dan, expd, ldan, pow2, pow10, a, skal: real;
    im , iu, io, n: integer;
    tmp,
    nm, x0, y0, len, ndez, x1, y1, ipm, xymode, disT, disZ, disH, disR, intexp: Integer;
    stri : string;
  //  ts, tscap: TSize;
    tsw, tsh, tscapw, tscaph: integer;
    tsxmax, tsymax: integer;

//to do for PS: get size of text to calculate proper distances dis*

  begin
    n:=axisNticks;
  // scale tics length to typical text size
    if PS then begin
      writeln(fps, '/Symbol findfont ',Round(ps_fontsize*FontFactor),' scalefont setfont'); //--> const
      disZ:=Round(ps_fontsize*FontFactor);
      //      disH:=round(disZ*0.3); used with centertext for axis annotations
      disH:=round(disZ*0.66);
      disR:=round(ps_fontsize*FontFactor);
    end else begin
      cnv.Font.Color:=col;
      cnv.Font.Name:=axisFontName;
      cnv.Font.Size:=Round(10*FontFactor);
      disZ:=cnv.Textextent('-').cx;
    end;
    disT:=disZ div 2;


    x0:=px0;
    case mode of
    1:begin      // x bottom
        xymode:=1;
        if PS then y0:=pytop else y0:=py0;
      end;
    2:begin     // y left
        xymode:=2;
        if PS then y0:=pytop else y0:=py0;
      end;
    3:begin     // x top
        xymode:=1;
        if PS then y0:=py0 else y0:=pybot; //not pytop! ;
      end;
    4:begin     // y right
        xymode:=2;
        x0:=pxtotal-pxtop;
        if PS then y0:=pytop else y0:=py0;
      end;
      else
    end;

    if (xymode=1) then begin
      len:=round(pxrange*(ra2-ra1));
      x0:=x0+round(ra1*pxrange);
      au:=xmin; ao:=xmax;
    end else begin
      len:=round(pyrange*(ra2-ra1));
      if PS then y0:=y0+round(ra1*pyrange) else y0:=y0-round(ra1*pyrange);
      au:=ymin; ao:=ymax;
    end;

    // extract an exponent if intervall is very small
    dan  := (ao-au)/axisNticks;

    if dan<0 then ipm:=-1 else ipm:=1;
    dan  := ipm*dan;

    mag:=-Log10(dan/Max(abs(ao),abs(au)));

    ldan := Log10(dan);
    expd := int(ldan);
    if ldan<0 then expd:=expd-1;
    dan  :=Power(10, ldan-expd ); // now dan is a number between 1 and 10

    pow2 :=1;
    im:=0;
    repeat
      pow2:=pow2*2;
      Inc(im);
    until dan<pow2;
    dan := md[im]*Power(10,expd);

  //high magnitude (i.e. ratio value/interval)-> undo exp extraction
    if mag > 3 then expd:=0;
    if abs(expd)>=3  then begin
      intexp:=round(expd);
      if expd<0 then Inc(intexp);
    end else intexp:=0;
    pow10:=Power(10,intexp);
    iu  := trunc(ipm*au/dan-eps);
    if au*ipm>0 then Inc(iu);
    io  := trunc(ipm*ao/dan+eps);
    if ao*ipm<0 then Dec(io);
    n:=io-iu+1;
    if dan*(1+eps)<1 then begin {sonst probleme mit dan=0.999...}
      Str(dan:12:10,stri);
      stri:=Copy(stri,3,12);
      ndez:=0;
      repeat  Inc(ndez);   until stri[ndez]<>'0';
    end
    else ndez:=0;

    if intexp <>0 then begin
      ndez:=1;
      nm:=n-1;
    end else nm:=n;

    if LabelSpace=0 then begin // plot the axis (else only return Labelspace req'd for caption)
      skal:=len/(ao-au);
      SetThick(1);

      if PS then begin
        writeln(fps, ps_color(col));
        if xymode=1 then writeln(fps,x0,' ',y0,' moveto ',x0+len,' ',y0,' lineto stroke')
                    else writeln(fps,x0,' ',y0,' moveto ',x0,' ',y0+len,' lineto stroke');
        tsxmax:=0; tsymax:=0;
        for im:=1 to nm do begin
          a := (iu+im-1)*ipm*dan;
          Str(a/pow10:0:ndez,stri);
          if xymode=1 then begin
            x1:=x0+Round(skal*(a-au));
            if mode=1 then begin
              writeln(fps,x1,' ',y0,' moveto ',x1,' ',y0-disT,' lineto stroke');
//             writeln(fps,x1,' ',y0-disR,' moveto'); //alterntaive with simpler centertext ps-proc
//              writeln(fps,'(',stri,') centertext');
              writeln(fps,x1,' ',y0-disH,' moveto');
              writeln(fps,'(',stri,') centertoptext');
            end;
            if mode=3 then begin
              writeln(fps,x1,' ',y0,' moveto ',x1,' ',y0+disT,' lineto stroke');
//              writeln(fps,x1,' ',y0+disR,' moveto');
//              writeln(fps,'(',stri,') centertext');
              writeln(fps,x1,' ',y0+disH,' moveto');
              writeln(fps,'(',stri,') centerbottext');
            end;
          end
          else begin
            y1:=y0+Round(skal*(a-au));
            if mode=2 then begin
              writeln(fps,x0,' ',y1,' moveto ',x0-disT,' ',y1,' lineto stroke');
//              writeln(fps,x0-disZ,' ',y1-disH,' moveto');
//              writeln(fps,'(',stri,') raligntext');
              writeln(fps,x0-disZ,' ',y1,' moveto');
              writeln(fps,'(',stri,') rightmidtext');
            end;
            if mode=4 then begin
              writeln(fps,x0,' ',y1,' moveto ',x0+disT,' ',y1,' lineto stroke');
//              writeln(fps,x0+disZ,' ',y1-disH,' moveto');
//              writeln(fps,'(',stri,') show');
              writeln(fps,x0+disZ,' ',y1,' moveto');
              writeln(fps,'(',stri,') leftmidtext');
            end;
          end;
        end;
    // write exponent (if it was extracted )
        if intexp<>0 then begin
          str(intexp:0,stri);
          stri:='*E'+stri;
          case mode of
              1: writeln(fps, x0+len ,' ',y0-disZ,' moveto (',stri,') centertext');
              2: writeln(fps, x0-disZ,' ',y0+len, ' moveto (',stri,') raligntext');
              3: writeln(fps, x0+len ,' ',y0+disZ,' moveto (',stri,') centertext');
              4: writeln(fps, x0+disZ,' ',y0+len, ' moveto (',stri,') show');
            else
          end;
        end;
    // write the captions
        writeln(fps, '/Times-Roman findfont ',Round(ps_fontsize*FontFactor),' scalefont setfont'); //--> const
        if length(caption)>0 then begin
          case mode of
 //             1:  writeln(fps, x0+ len div 2, ' ', y0-2*disZ,' moveto (', caption,') centertoptext');
              1:  writeln(fps, x0+ len div 2, ' ', y0-1.5*disZ,' moveto (', caption,') centertoptext');
              2: begin
                   writeln(fps,disR,' ', y0+len div 2, ' moveto');
                   writeln(fps,'gsave currentpoint translate 90 rotate');
                   writeln(fps,'(',caption,') centertext grestore');
                 end;
              3: writeln(fps, x0+ len div 2, ' ', y0+2*disZ,' moveto (', caption,') centerbottext');
              4: begin
                   writeln(fps,pxtotal-disR,' ', y0+len div 2, ' moveto');
                   writeln(fps,'gsave currentpoint translate 90 rotate');
                   writeln(fps,'(',caption,') centertext grestore');
                 end;
            else
          end;
        end; //PS

      end else begin //not PS
        cnv.brush.color:=clwhite;
        cnv.brush.style:=bsSolid;
        cnv.pen.color:=col;
//      cnv.MoveTo(x0,y0);
        if xymode=1 then  cnv.Line(x0,y0,x0+len,y0) else  cnv.Line(x0,y0,x0,y0-len);
        tsxmax:=0; tsymax:=0;
        for im:=1 to nm do begin
          a := (iu+im-1)*ipm*dan;
          Str(a/pow10:0:ndez,stri);
          tsw:=cnv.TextExtent(stri).width;
          tsh:=cnv.TextExtent(stri).height;
          if tsxmax < tsw then tsxmax := tsw;
          if tsymax < tsh then tsymax := tsh;
          if xymode=1 then begin
            x1:=x0+Round(skal*(a-au));
            if mode=1 then begin
              cnv.TextOut(x1-tsw div 2, y0+disZ,       stri);
              cnv.MoveTo(x1,y0); cnv.LineTo(x1,y0+disT);
            end;
            if mode=3 then begin
              cnv.TextOut(x1-tsw div 2, y0-disZ-tsh, stri);
              cnv.MoveTo(x1,y0); cnv.LineTo(x1,y0-disT);
            end;
          end
          else begin
            y1:=y0-Round(skal*(a-au));
            if mode=2 then begin
              cnv.MoveTo(x0,y1); cnv.LineTo(x0-disT,y1);
              cnv.TextOut(x0-disZ-tsw, y1-tsh div 2, stri);
            end;
            if mode=4 then begin
              cnv.MoveTo(x0,y1); cnv.LineTo(x0+disT,y1);
              cnv.TextOut(x0+disZ      , y1-tsh div 2, stri);
            end;
          end;
        end;
  // write exponent (if it was extracted )
        if intexp<>0 then begin
          str(intexp:0,stri);
          stri:='xE'+stri;
          tsw:=cnv.TextExtent(stri).width;
          tsh:=cnv.TextExtent(stri).height;
          case mode of
            1: cnv.TextOut(x0+len-tsw, y0+disZ      ,stri);
            2: cnv.TextOut(x0-disZ-tsw,y0-len+tsh ,stri);
            3: cnv.TextOut(x0+len-tsw, y0-disZ-tsh,stri);
            4: cnv.TextOut(x0+disZ      ,y0-len+tsh ,stri);
            else
          end;
        end;
  // write the caption

        if length(caption)>0 then begin
          tscapw:=cnv.TextExtent(caption).width;
          tscaph:=cnv.TextExtent(caption).height;
          case mode of
              1:  cnv.TextOut(x0+ (len - tscapw) div 2, y0+disZ+tsymax, caption);
              2: begin
                   cnv.Font.Orientation:=900;
                   cnv.TextOut(x0-disZ-tsxmax-tscaph, y0-(len - tscapw) div 2, caption);
                   cnv.Font.Orientation:=0;
                 end;
              3:  cnv.TextOut(x0+(len- tscapw) div 2, y0-{+}disZ-tsymax-tscaph, caption);
              4: begin
                   cnv.Font.Orientation:=900;
                   cnv.TextOut(x0+disZ+tsxmax, y0-(len - tscapw) div 2, caption);
                   cnv.Font.Orientation:=0;
                 end;
 //          1:  cnv.TextOut(x0+ (len - tscapw) div 2, y0+disZ+tsymax, caption);
//          2:  FDC_textout(x0-disZ-tsxmax-tscaph, y0-(len - tscapw) div 2, 90, cnv.font.size, caption);
//          3:  cnv.TextOut(x0+(len- tscapw) div 2, y0-{+}disZ-tsymax-tscaph, caption);
//          4:  FDC_textout(x0+disZ+tsxmax, y0-(len - tscapw) div 2, 90, cnv.font.size, caption);
            else
          end;
        end;
      end; // not PS
    end else begin // no plotting, just return the space required for the axis

      //improvised version for PS axis space, to be improved: how to measure ps text space without plotting? 20.7.2024
      tsxmax:=0; tsymax:=0;
      for im:=1 to nm do begin
        a := (iu+im-1)*ipm*dan;
        Str(a/pow10:0:ndez,stri);
        if PS then begin
          tsw:=Round(length(stri)*PS_fontsize*FontFactor*0.6); // estimate length of string, avg. char width ~ 0.6 of fontsize
          tsh:=Round(PS_fontsize*FontFactor);
        end else begin
          tsw:=cnv.TextExtent(stri).width;
          tsh:=cnv.TextExtent(stri).height;
        end;
        if tsxmax < tsw then tsxmax := tsw;
        if tsymax < tsh then tsymax := tsh;
      end;
      if PS then begin
        tscapw:=Round(ps_Fontsize*FontFactor); tscaph:=tscapw;
      end else begin
        tscapw:=cnv.TextExtent(caption).width;
        tscaph:=cnv.TextExtent(caption).height;
      end;
      case xymode of               // tscapw never used because v-text is rotated
        1:  LabelSpace:=disZ+tsymax+tscaph;
        2:  LabelSpace:=disZ+tsxmax+tscaph;
        else
      end;

    end;
  end;



{2021, obsolete because Lazarus allows font.orientation}
// Kochbuch R110, creates rotated text font, draws text and deletes font again
// Warning: uses Windows API functions!
{
procedure VPlot.FDC_TextOut(x,y,winkel,groesse:integer;txt:string);
var
  fontheight, hfont, fontold : integer;
  dc             : hdc;
  fontname       : string;

begin
  if length(txt)= 0 then exit;
  dc := cnv.handle;
  SetBkMode(dc,transparent);
  fontname := cnv.font.name;
  fontheight:=-groesse*GetDeviceCaps (dc, LOGPIXELSY) div 72;
  hfont   := CreateFont(fontheight,0,winkel*10, 0,fw_normal,0,0,0,1,4,$10,2,4,PChar(fontname));
  fontold := SelectObject(dc,hfont);
  TextOut(dc,x,y,PChar(txt),length(txt));
  SelectObject(dc, fontold);
  DeleteObject(hfont);
end;
}

procedure VPlot.TextAlign(s:string; x,y: real; xalign, yalign: integer; col:TColor);
// align -1,0,1: left, center, right; top, center, bottom
var
  wt, ht: integer; xshift, yshift: real;
begin
  if PS then begin
    setColor(col);
    writeln(fps,PS_getpx(x), PS_getpy(y), 'moveto') ;

    //incomplete
    if (xalign=0) and (yalign=-1) then  writeln(fps,'(',s,') centertoptext')
    else if (xalign=-1) and (yalign=0) then writeln(fps,'(',s,') leftmidtext')
    else if (xalign= 1) and (yalign=0) then writeln(fps,'(',s,') rightmidtext')
    else writeln(fps,'(',s,') show');

  end else begin
    wt:=cnv.textwidth(s);
    ht:=cnv.textheight(s);
    case xalign of
        0: xshift:=getdx(-wt div 2);
        1: xshift:=getdx(-wt);
      else xshift:=0;
    end;
    case yalign of
        0: yshift:=getdy(-ht div 2);
        1: yshift:=getdy(-ht);
      else yshift:=0;
    end;
    cnv.Font.Color:=col;
    cnv.TextOut(getpx(x+xshift),getpy(y+yshift),s);
  end;
end;



procedure VPlot.Circle (xorg, yorg, rad: real; col: TColor);
const
  np=200;
var
  dp,p,x,y: real;
  i: Integer;
  prev_col: TColor;
begin
  dp:=2*Pi/np;
  prev_col:=Getcolor;
  SetColor(col);
  for i:=0 to np do begin
    p := i*dp;
    x:= xorg+rad*Cos(p); y:=yorg+rad*Sin(p);
    if i=0 then MoveTo(x,y) else LineTo(x,y);
  end;
  SetColor(prev_col);
end;



{plot a sheared ellipse in beam dynamics notation:
be, al, em = beta, alfa, area/pi (emittance)
orb, orbP=origin
skal, skalP: scaling factors = 1000 when entering SI and plotting mm, mrad
col=color}

procedure VPlot.Ellipse (Be, Al, Em, Orb, OrbP, skal, skalP: real; col: TColor);
const
  np=200;
var
  dp,b,a,e,xi,yi,p,x,y: real;
  i: Integer;
  prev_col: TColor;
begin
  dp:=2*Pi/np;
  b:=Sqrt(abs(Be));
  a:=-Al/b;
  e:=Sqrt(abs(Em));
  prev_col:=Getcolor;
  SetColor(col);
  for i:=0 to np do begin
    p := i*dp;
    xi:= e*Cos(p); yi:=e*Sin(p);
    x := (b*xi+Orb)*skal;
    y := (a*xi+yi/b+OrbP)*skalP;
    if i=0 then MoveTo(x,y) else LineTo(x,y);
  end;
  SetSymbol(5,0,col); Symbol(Orb*skal,OrbP*skalP);
  SetColor(prev_col);
end;


// copy image from screen to clipboard - remove? (function provided by system)
  {clipbrd and dialogs uses ONLY for grabimage!}

procedure VPlot.GrabImage;
var
  pic: TBitmap;
  rec: TRect;
begin
  pic:=TBitmap.Create;
  pic.height:=pytotal;
  pic.width :=pxtotal;
  rec := Rect(0,0,pxtotal,pytotal);
  pic.Canvas.CopyRect(rec, cnv, rec);
  ClipBoard.Assign(pic);
  pic.free;
  MessageDlg('Picture saved to ClipBoard.', MtInformation, [mbOK],0)
end;





end.
