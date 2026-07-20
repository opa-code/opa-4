unit varlib;

{ ===================== Arithmetic Evaluator ============================================}
{
evaluator works on variables, which are arithmetic expressions. It needs to know about
all variables in use in order to recognize and evaluate recursively. Therefore it needs
to use globlib.  as-26.3.2026


Evaluation of expressions containing real numbers, variable names and +-*/ operators.

Calculator from http://rosettacode.org/wiki/Arithmetic_Evaluator/Pascal
and adjusted to Delphi, basically by replacing
text --> PChar
get --> Inc
eoln(f) --> (f^<>#0)
as-14.10.2015

extended to take real numbers, including exponents and variable names, e.g.
A111=32.05
B=5E-2
C=2.48
1.2E-3*(3.5E+1+A111)*(B+C)/B

as-20.10.2015

Problem! Vorzeichen gefolgt von Variable wurde nicht erkannt, z.B. (-C), es sei denn eine
irrelevante Zeile mehr wurde in den code eingefuegt - das verweist auf einen verborgenen Pointer-Fehler!
Nun geht es, aber moeglicherweise gibt es einen Fehler --> Delphi-Hilfe: "PChar in String Konvertierung"
}

{$mode Delphi}

interface

uses
  Classes, SysUtils, globlib;

function Eval_Exp (expression: string; var err: boolean): real;
function Get_Eval_exp_errmess: string;


implementation


type
  NodeType = (binop, number, error);

  pAstNode = ^tAstNode;
  tAstNode = record
    case typ: NodeType of
              binop:
              (
                operation: char;
                first, second: pAstNode;
              );
              number:
               (value: real);
              error:
               ();
             end;
var
  Eval_exp_errmess: string;

function newBinOp(op: char; left: pAstNode): pAstNode;
var
  node: pAstNode;
begin
  new(node);
  node^.typ:=binop;
  node^.operation := op;
  node^.first := left;
  node^.second := nil;
  newBinOp := node;
end;

procedure disposeTree(tree: pAstNode);
 begin
  if tree^.typ = binop
   then
    begin
     if (tree^.first <> nil)
      then
       disposeTree(tree^.first);
     if (tree^.second <> nil)
      then
       disposeTree(tree^.second)
    end;
  dispose(tree);
 end;

function parseAddSub(var f: PChar): pAstNode; forward;
function parseMulDiv(var f: PChar): pAstNode; forward;
function parseValue(var f: PChar): pAstNode; forward;

function parseAddSub;
var
  node1, node2: pAstNode;
  continue: boolean;
begin
  node1 := parseMulDiv(f);
  if node1^.typ <> error then begin
    continue := true;
    while continue and (f <> #0) do begin
      if f^ in ['+', '-'] then begin
        node1 := newBinop(f^,node1);
        Inc(f);
        node2 := parseMulDiv(f);
        if (node2^.typ = error) then begin
          disposeTree(node1);
          node1 := node2;
          continue := false
        end else
          node1^.second := node2
        end else
         continue := false
      end;
    end;
  parseAddSub := node1;
end;

function parseMulDiv;
var
  node1, node2: pAstNode;
  continue: boolean;
begin
  node1 := parseValue(f);
  if node1^.typ <> error then begin
    continue := true;
    while continue and (f<>#0) do begin
      if f^ in ['*', '/'] then begin
        node1 := newBinop(f^,node1);
        Inc(f);
        node2 := parseValue(f);
        if (node2^.typ = error) then begin
          disposeTree(node1);
          node1 := node2;
          continue := false
        end else
          node1^.second := node2
        end else
         continue := false
      end;
    end;
  parseMulDiv := node1;
 end;

function parseValue;
var
  node:  pAstNode;
  value: real;
  neg:   boolean;
  valst: string;
  errint, isy: integer;
  errboo: boolean;
begin
  node := nil;
  if f^ = '('  then begin
    Inc(f);
    node := parseAddSub(f);
    if node^.typ <> error  then  begin
      if f^ = ')' then Inc(f) else begin
        disposeTree(node);
        new(node); node^.typ:=error;
      end; //else
    end; //<> error
  end // bracket '('

  // check if it is any alphanumeric character (only uppercase allowed) or sign or comma
  else begin
    if f^ in [ '+', '-', '.', '0' .. '9', 'A' .. 'Z', '_' ] then begin
      valst:='';
// first char may be a minus (or +)
      neg := (f^ = '-');
      if f^ in ['+', '-'] then Inc(f);


// test next character to distinguish a number and a variable name
      if f^ in ['.', '0' .. '9'] then begin
//is a number probably, so we expect only digits, comma and perhaps an E for exponents.
//don't accept any +/- since this would be the next operator
        while f^ in ['E', '0' .. '9', '.'] do begin
          valst:=valst+f^;
// special treatment for a sign following an exponent like 1.3E-05
          if f^='E' then begin
            Inc(f); //peep one char ahead, if it is + or - (if it is last char, it will be #0)
            if f^ in ['+', '-'] then valst:=valst+f^ else Dec(f);
          end;
          Inc(f);
        end; //while
// try conversion into a number
{$R-}
        Val(valst,value,errint);
{$R+}

        if errint=0 then begin
          new(node); node^.typ:=number;
          if neg then  node^.value:=-value else node^.value:=value;
// if this failed, then check if it is a variable we know and get its value
        end;
        if node = nil then begin
          new(node); node^.typ:=error;
          Eval_exp_errmess:=Eval_exp_errmess+'invalid numeric format: "'+valst+'".';
        end;
      end // is a number

      else if f^ in ['A' .. 'Z', '_'] then begin
//probably it is a variable, so we expect chars and digits but no comma.
//don't accept any +/- since this would be the next operator
        while f^ in ['0' .. '9', 'A' .. 'Z', '_'] do begin
          valst:=valst+f^;
          Inc(f);
        end; //while
//look for a variable with same name
        for isy:=0 to High(Variable) do with Variable[isy] do begin
          if compareText(nam,valst)=0 then begin
// Alternatives: take the value stored in variable or re-evaluate its expression
// if exp=nil, then we have a constant, i.e. a pure number
            value:=val;   errboo:=false;
            if (exp <>'') then value:=Eval_Exp(exp, errboo);
            use:=true;    // this variable was used
            new(node); node^.typ:=number;
            if neg then node^.value:=-value else node^.value:=value;
          end;
        end; //for
        if node = nil then begin
          new(node); node^.typ:=error;
          Eval_exp_errmess:=Eval_exp_errmess+'variable "'+valst+'" does not exist.';
        end;
      end; // is a variable
    end; // test on valid initial character for number or variable

    // if it was neither a number nor a variable, the input was invalid --> error
    if node = nil then begin
      new(node); node^.typ:=error;
      if ord(f^)=0 then Eval_exp_errmess:=Eval_exp_errmess+'line incomplete.' else Eval_exp_errmess:=Eval_exp_errmess+'invalid character "'+f^+'" (#'+inttostr(ord(f^))+').';
     end;
  end; // not a bracket '('
  parseValue := node
end;

function eval(ast: pAstNode): real;
begin
  with ast^ do begin
    case typ of
      number: eval := value;
      binop:
        case operation of
        '+': eval := eval(first) + eval(second);
        '-': eval := eval(first) - eval(second);
        '*': eval := eval(first) * eval(second);
        '/': eval := eval(first) / eval(second);
        end;
      error: begin      // can never happen, since eval only called if no error?
//        opalog(1,'Error in eval procedure!');
        eval:=0.0;
      end;
    end;
  end;
end;

{-----------------------------------------------------------------------------}

function Eval_Exp (expression: string; var err: boolean): real;
// evaluate an expression: get a string containing an expression and calculate the result
var
  ast: pAstnode;
  res: real;
  pline: PChar;
begin
  pline:=PChar(expression);
  Eval_exp_errmess:='';
  ast := parseAddSub(pline);
  err:= (ast^.typ = error);
  if err then res:=0 else res:=eval(ast);
  disposeTree(ast);
  Eval_Exp:=res;
end;

function Get_Eval_exp_errmess: string;
begin
  Get_Eval_Exp_errmess:=Eval_Exp_errmess;
end;



end.

