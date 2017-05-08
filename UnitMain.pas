
unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, Clipbrd, Buttons, ExtCtrls, Menus, Matrix;

type
  { TfrmMain }

  TfrmMain = class(TForm)
    grpInput: TGroupBox;
    grdInput: TStringGrid;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    splOne: TSplitter;
    bvl1: TBevel;
    grpImplets: TGroupBox;
    bvl3: TBevel;
    grdImplets: TStringGrid;
    grpSimplets: TGroupBox;
    bvl2: TBevel;
    grdSimplets: TStringGrid;
    splTwo: TSplitter;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    PopupMenu2: TPopupMenu;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    ilMain: TImageList;
    N17: TMenuItem;
    N18: TMenuItem;
    PopupMenu3: TPopupMenu;
    N19: TMenuItem;
    C1: TMenuItem;
    N20: TMenuItem;
    procedure C1Click(Sender: TObject);
    procedure grdInputDblClick(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N16Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private
    { Private declarations }
    procedure GridToMatrix(Grid: TStringGrid; var Matrix: TMatrix);
    procedure MatrixToGrid(Matrix: TMatrix; var Grid: TStringGrid; RPref: string = ''; CPref: string = '');
    function FindSimplicants(Input: TMatrix; var Output: TMatrix): Integer;
    function DeDuplicate(var Matrix: TMatrix): Integer;
    function DeExcess(var Matrix: TMatrix): Integer;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

{ Service Code }

// Загрузка данных из
procedure TfrmMain.GridToMatrix(Grid: TStringGrid; var Matrix: TMatrix);
var
  r, c : Integer;
begin
 Matrix.RowCount := Grid.RowCount-1;
 Matrix.ColCount := Grid.ColCount-1;
 for r := 0 to Matrix.RowCount-1 do
   for c := 0 to Matrix.ColCount-1 do
     if Length(Grid.Cells[c+1, r+1]) = 0 then
       Matrix[r, c] := ' '
     else
       Matrix[r, c] := Grid.Cells[c+1, r+1][1];
end;

// Выгрузка данных из матрицы в грид
procedure TfrmMain.MatrixToGrid(Matrix: TMatrix; var Grid: TStringGrid;
  RPref : string = ''; CPref: string = '');
var
  r, c : Integer;
begin
 Grid.ColCount := Matrix.ColCount+1;
 Grid.RowCount := Matrix.RowCount+1;
 for r := 1 to Grid.RowCount-1 do
   Grid.Cells[0, r] := RPref + IntToStr(r);
 for c := 1 to Grid.ColCount-1 do
   Grid.Cells[c, 0] := CPref + IntToStr(c);
   
 for r := 0 to Matrix.RowCount-1 do
   for c := 0 to Matrix.ColCount-1 do
     Grid.Cells[c+1, r+1] := Matrix[r, c];
end;

// Поиск симпликант, т.е. поглощающих пар, когда такие пары закончатся -
// значит нашли список простых импликант.
function TfrmMain.FindSimplicants(Input: TMatrix; var Output: TMatrix): Integer;
var
  M        : TMatrix;
  r1, r2, c,
  s        : Integer;
begin
 Result := 0;
 M := TMatrix.Dublicate(Input);
 Output := TMatrix.Dublicate(Input);
 // ищем посторения
 for r1 := 0 to M.RowCount-2 do
   for r2 := r1+1 to M.RowCount-1 do
     begin
       s := 0;
       for c := 0 to M.ColCount-1 do
         if (r1 <> r2) and (M[r1, c] = M[r2, c]) then Inc(s); // считаем повторения в строках
       if s = M.ColCount-1 then
         begin
           Inc(Result); 
           Output.RowCount := Output.RowCount+1;
           for c := 0 to M.ColCount-1 do
             if M[r1, c] = M[r2, c] then
               Output[Output.RowCount-1, c] := M[r1, c]
             else
               begin
                 Output[Output.RowCount-1, c] := '-';
               end
         end;
     end;
end;

// Удаление дублирующих строк (один проход)
function TfrmMain.DeDuplicate(var Matrix: TMatrix): Integer;
var
  r1, r2, c, s : Integer;
begin
 Result := 0;
 for r1 := Matrix.RowCount-1 downto 1 do
   for r2 := r1-1 downto 0 do
   begin
     s := 0;
     for c := 0 to Matrix.ColCount-1 do
       if Matrix[r1,c] = Matrix[r2,c] then Inc(s);
     if s = Matrix.ColCount then
       begin
         Matrix.DeleteRow(r1);
         Inc(Result);
         Break;
       end;
   end;
end;

// Удаление строгих условий, если есть менее строгие (1 0 -) - (1 0 1)
// второе можно удалить, т.к. оно дублирует первое, менее строгое
function TfrmMain.DeExcess(var Matrix: TMatrix): Integer;
var
  r1, r2, c, s1, s2 : Integer;
begin
 Result := 0;
 for r1 := Matrix.RowCount-1 downto 1 do
   for r2 := r1-1 downto 0 do
   begin
     s1 := 0;
     s2 := 0;
     for c := 0 to Matrix.ColCount-1 do
       begin
         if (Matrix[r1,c] = '-') or (Matrix[r1,c] = Matrix[r2,c]) then Inc(s1);
         if (Matrix[r2,c] = '-') or (Matrix[r1,c] = Matrix[r2,c]) then Inc(s2);
       end;
     if s1 = Matrix.ColCount then
       begin
         Matrix.DeleteRow(r2);
         Inc(Result);
         Exit;
       end;
     if s2 = Matrix.ColCount then
       begin
         Matrix.DeleteRow(r1);
         Inc(Result);
         Exit;
       end;
   end;
end;

{ Interface Code }

// Вставить из буфера
procedure TfrmMain.N1Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 M.PasteFromClipboard();
 MatrixToGrid(M, grdInput, 'V');
end;

// Взять из простых импликант
procedure TfrmMain.N10Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdSimplets, M);
 MatrixToGrid(M, grdInput, 'V');
 M.Free;
end;

// Цикл склеивания из исходных данных
procedure TfrmMain.N12Click(Sender: TObject);
var
  Inp, Rez : TMatrix;
begin
 Inp := TMatrix.Create;
 GridToMatrix(grdInput, Inp);
 FindSimplicants(Inp, Rez);
 MatrixToGrid(Rez, grdSimplets);
end;

// Цикл склеивания из импликант
procedure TfrmMain.N15Click(Sender: TObject);
var
  Inp, Rez : TMatrix;
begin
 Inp := TMatrix.Create;
 GridToMatrix(grdSimplets, Inp);
 FindSimplicants(Inp, Rez);
 MatrixToGrid(Rez, grdSimplets, 'I');
end;

// Удалить дубликаты
procedure TfrmMain.N14Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdSimplets, M);
 DeDuplicate(M);
 MatrixToGrid(M, grdSimplets, 'I');
end;

// Поглощение
procedure TfrmMain.N16Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdSimplets, M);
 while DeExcess(M) > 0 do
   begin end;
 MatrixToGrid(M, grdSimplets, 'I');
end;

// Получить Сокращенную форму
procedure TfrmMain.N17Click(Sender: TObject);
var
  Inp, Rez : TMatrix;
  i        : Integer;
begin
 Inp := TMatrix.Create;
 GridToMatrix(grdInput, Inp);

 for i := 0 to 1000 do  // это чтобы не зацикл
   begin
     if (FindSimplicants(Inp, Rez) > 0) then
       begin
         DeDuplicate(Rez);
         while DeExcess(Rez) > 0 do
           begin end;
         Inp.Free;
         Inp := Rez;
       end else Break;
   end;

 MatrixToGrid(Rez, grdSimplets, 'I');
end;

// Получить Импликантную матрицу
procedure TfrmMain.N18Click(Sender: TObject);
var
  Inp, Sim, IM : TMatrix;
  ir, sc, c, s : Integer;
begin
 Inp := TMatrix.Create;
 Sim := TMatrix.Create;
 GridToMatrix(grdInput, Inp);
 GridToMatrix(grdSimplets, Sim);

 IM := TMatrix.Create(Inp.RowCount, Sim.RowCount);

 for ir := 0 to Inp.RowCount-1 do
   for sc := 0 to Sim.RowCount-1 do
     begin
       s := 0;
       IM[ir,sc] := ' ';
       for c := 0 to Inp.ColCount-1 do
         if (Inp[ir,c] = Sim[sc,c]) or (Sim[sc,c] = '-') then Inc(s);
       if s = Inp.ColCount then IM[ir,sc] := 'x';
     end;
 MatrixToGrid(IM, grdImplets, 'V', 'I');
end;

// Выделить ядро
procedure TfrmMain.N19Click(Sender: TObject);
var
  M         : TMatrix;
  r, c      : Integer;
  s, r2, c2 : Integer;
begin
 M := TMatrix.Create;
 GridToMatrix(grdImplets, M);

 for r := 0 to M.RowCount-1 do
   begin
     s := 0;
     c2 := 0;
     for c := 0 to M.ColCount-1 do
       if M[r,c] <> ' ' then
         begin
           Inc(s);
           c2 := c;
         end;  
     if s = 1 then
       begin
         for r2 := 0 to M.RowCount-1 do
           if M[r2,c2] = 'x' then M[r2,c2] := 'X';
         M[r,c2] := '*';
       end;
   end;
 MatrixToGrid(M, grdImplets, 'V', 'I');
end;

// Скопировать простые импликанты
procedure TfrmMain.N7Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdSimplets, M);
 M.CopyToClipboard();
 M.Free;
end;

// Скопировать Импликантную матрицу
procedure TfrmMain.C1Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdImplets, M);
 M.CopyToClipboard();
 M.Free;
end;

// Инвертировать ячейку
procedure TfrmMain.grdInputDblClick(Sender: TObject);
begin
 if grdInput.Cells[grdInput.Col, grdInput.Row] = '1' then
   grdInput.Cells[grdInput.Col, grdInput.Row] := '0'
 else
   grdInput.Cells[grdInput.Col, grdInput.Row] := '1';
end;

// Заменить 0 на -
procedure TfrmMain.MenuItem10Click(Sender: TObject);
var
  M : TMatrix;
  r, c      : Integer;
begin
 M := TMatrix.Create;
 GridToMatrix(grdInput, M);
 for r := 0 to M.RowCount-1 do
   for c := 0 to M.ColCount-1 do
     if M[r,c] = '0' then M[r,c] := '-';
 MatrixToGrid(M, grdInput, 'V');
end;

// Заменить 1 на -
procedure TfrmMain.MenuItem11Click(Sender: TObject);
var
  M : TMatrix;
  r, c      : Integer;
begin
 M := TMatrix.Create;
 GridToMatrix(grdInput, M);
 for r := 0 to M.RowCount-1 do
   for c := 0 to M.ColCount-1 do
     if M[r,c] = '1' then M[r,c] := '-';
 MatrixToGrid(M, grdInput, 'V');
end;

// Скопировать матрицу исходных данных
procedure TfrmMain.MenuItem12Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdInput, M);
 M.CopyToClipboard();
 M.Free;
end;

// Вставить строку
procedure TfrmMain.MenuItem2Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdInput, M);
 // Если выделена последняя строка - добавим строку вниз,
 if grdInput.Row-1 = M.RowCount-1 then
   M.AddRow(' ')
 else
   M.InsertRow(grdInput.Row-1, ' ');
 MatrixToGrid(M, grdInput, 'V');
end;

// Вставить столбец
procedure TfrmMain.MenuItem3Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdInput, M);
 // Если выделена последняя строка - добавим строку вниз,
 if grdInput.Row-1 = M.ColCount-1 then
   M.AddCol(' ')
 else
   M.InsertCol(grdInput.Col-1, ' ');
 MatrixToGrid(M, grdInput, 'V');
end;

// Удалить строку
procedure TfrmMain.MenuItem4Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdInput, M);
 M.DeleteRow(grdInput.Row-1);
 MatrixToGrid(M, grdInput, 'V');
end;

// Удалить столбец
procedure TfrmMain.MenuItem5Click(Sender: TObject);
var
  M : TMatrix;
begin
 M := TMatrix.Create;
 GridToMatrix(grdInput, M);
 M.DeleteCol(grdInput.Col-1);
 MatrixToGrid(M, grdInput, 'V');
end;

// Удалить импликант из импликантной матрицы (столбец) и простых импликант
// (строка)
procedure TfrmMain.MenuItem7Click(Sender: TObject);
var
  S, IM : TMatrix;
begin
 S  := TMatrix.Create;    // Простые импликанты
 IM := TMatrix.Create;    // Импликантная матрица
 GridToMatrix(grdSimplets, S);
 GridToMatrix(grdImplets, IM);
 IM.DeleteCol(grdImplets.Col-1);
 S.DeleteRow(grdSimplets.Col-1);
 MatrixToGrid(S, grdSimplets, 'I');
 MatrixToGrid(IM, grdImplets, 'V', 'I');
end;

procedure TfrmMain.MenuItem8Click(Sender: TObject);
begin

end;


end.
