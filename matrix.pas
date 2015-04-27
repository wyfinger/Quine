unit Matrix;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Clipbrd;

type
  TCellType = Char;
  TMatrixData = array of array of TCellType;

  { TMatrix }

  TMatrix = class
  private
    FColCount,
    FRowCount : Integer;
    FValues   : TMatrixData;
    procedure SetColCount(ColCount: Integer);
    procedure SetRowCount(RowCount: Integer);
    function GetValue(r, c: Integer): TCellType;
    procedure SetValue(r, c: Integer; Value: TCellType);
  public
    property Value[r, c: Integer]: TCellType read GetValue write SetValue; default;
    property ColCount: Integer read FColCount write SetColCount;
    property RowCount: Integer read FRowCount write SetRowCount;
    constructor Create; overload;
    constructor Create(const Rows, Cols: Integer); overload;
    constructor Dublicate(Source: TMatrix); overload;
    destructor Destroy; override;
    procedure InsertRow(RowNo: Integer; Blank: TCellType);
    procedure AddRow(Blank: TCellType);
    procedure DeleteRow(RowNo: Integer);
    procedure InsertCol(ColNo: Integer; Blank: TCellType);
    procedure AddCol(Blank: TCellType);
    procedure DeleteCol(ColNo: Integer);
    procedure CopyToClipboard();
    procedure PasteFromClipboard();
  end;

implementation

{ TMatrix }

constructor TMatrix.Create;
begin
 inherited Create;
 SetLength(FValues, 0);
 FColCount := 0;
 FRowCount := 0;
end;

constructor TMatrix.Create(const Rows, Cols: Integer);
begin
 inherited Create;
 SetRowCount(RowCount);
 SetColCount(ColCount);
end;

constructor TMatrix.Dublicate(Source: TMatrix);
var
  r, c : Integer;
begin
 inherited Create;
 SetRowCount(Source.RowCount);
 SetColCount(Source.ColCount);
 for r := 0 to FRowCount-1 do
   for c := 0 to FColCount-1 do
     FValues[r, c] := Source[r, c];
end;

destructor TMatrix.Destroy;
begin
 SetLength(FValues, 0);
 inherited;
end;

procedure TMatrix.InsertRow(RowNo: Integer; Blank: TCellType);
var
  Inp  : TMatrix;
  r, c : Integer;
begin
 Inp := TMatrix.Dublicate(Self);
 SetRowCount(RowCount+1);
 SetColCount(ColCount);
 for c := 0 to ColCount-1 do
   FValues[RowNo,c] := Blank;
 for r := RowNo to Inp.RowCount-1 do
   for c := 0 to ColCount-1 do
     FValues[r+1,c] := Inp[r,c];
 Inp.Free;
end;

procedure TMatrix.AddRow(Blank: TCellType);
var
 c : Integer;
begin
 SetRowCount(RowCount+1);
 SetColCount(ColCount);
 for c := 0 to ColCount-1 do
   FValues[RowCount-1,c] := Blank;
end;

procedure TMatrix.SetColCount(ColCount: Integer);
var
  r : Integer;
begin
 for r := 0 to FRowCount-1 do
   SetLength(FValues[r], ColCount);
 FColCount := ColCount;
end;

procedure TMatrix.SetRowCount(RowCount: Integer);
begin
 SetLength(FValues, RowCount);
 FRowCount := RowCount;
end;

procedure TMatrix.SetValue(r, c: Integer; Value: TCellType);
begin
 if r > FRowCount-1 then SetRowCount(r+1);
 if (c > FColCount-1) then SetColCount(c+1);
 if (Length(FValues[r]) <> FColCount) then SetLength(FValues[r], FColCount);
 FValues[r, c] := Value;
end;

function TMatrix.GetValue(r, c: Integer): TCellType;
begin
 GetValue := FValues[r, c];
end;

procedure TMatrix.DeleteRow(RowNo: Integer);
var
  r : Integer;
begin
 SetLength(FValues[RowNo], 0);
 if RowNo < FRowCount-1 then
   for r := RowNo to FRowCount-2 do
     begin
       FValues[r] := FValues[r+1];
       //for c := 0 to FColCount-1 do
       //  FValues[r, c] := FValues[r+1, c];
     end;
 SetLength(FValues, FRowCount-1);
 Dec(FRowCount);
end;

procedure TMatrix.InsertCol(ColNo: Integer; Blank: TCellType);
var
  r, c : Integer;
begin
 SetColCount(FColCount+1);
 for r := 0 to FRowCount-1 do
   begin
     for c := FColCount-1 downto ColNo+1 do
       FValues[r, c] := FValues[r, c-1];
     FValues[r, ColNo] := Blank;
   end;
end;

procedure TMatrix.AddCol(Blank: TCellType);
var
  r : Integer;
begin
 SetColCount(FColCount+1);
 for r := 0 to FRowCount-1 do
   FValues[r, FColCount-1] := Blank;
end;

procedure TMatrix.DeleteCol(ColNo: Integer);
begin

end;

procedure TMatrix.CopyToClipboard;
var
  RList : TStringList;
  Line  : string;
  r, c  : Integer;
begin
 RList := TStringList.Create;
 for r := 0 to FRowCount-1 do
   begin
     Line := '';
     for c := 0 to FColCount-1 do
       if c = FColCount-1 then Line := Line + FValues[r,c]
         else Line := Line + FValues[r,c] + #9;
     RList.Add(Line);
   end;
 Clipboard.SetTextBuf(PChar(RList.Text));
end;

procedure TMatrix.PasteFromClipboard;
var
  RecordList, FieldsList: TStrings;
  r, c: integer;
begin
 if not Clipboard.HasFormat(CF_TEXT) then Exit;
 RecordList := TStringList.Create;
 FieldsList := TStringList.Create;
 RecordList.Text := Clipboard.AsText;
 for r := 0 to RecordList.Count - 1 do
  begin
    FieldsList.Text := StringReplace(RecordList.Strings[r], #9, #13#10, [rfReplaceAll]);
    for c := 0 to FieldsList.Count - 1 do
      if (Trim(FieldsList.Strings[c]) = '') or (Trim(FieldsList.Strings[c]) = '0') then
        SetValue(r, c, '0')
      else if Trim(FieldsList.Strings[c]) = '-' then
        SetValue(r, c, '-')
      else
        SetValue(r, c, '1');
  end;
 for r := 0 to RowCount - 1 do
   for c := 0 to ColCount - 1 do
     if FValues[r,c] = #0 then FValues[r,c] := '0';
end;

end.

