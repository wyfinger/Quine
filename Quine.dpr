program Quine;

uses
  Forms, Interfaces,
  UnitMain in 'UnitMain.pas', Matrix;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
