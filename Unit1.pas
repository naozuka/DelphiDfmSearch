unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, StrUtils,
  Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Label2: TLabel;
    edtDirectory: TEdit;
    edtFormatStrings: TButton;
    pbStatus: TProgressBar;
    lbStatus: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure edtFormatStringsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

function GetFileList(dir, filter: string): TStringList;
procedure ConcatenateDfmStrings(novoDir, filename: string);

implementation

{$R *.dfm}

function GetFileList(dir, filter: string): TStringList;
var
  SR: TSearchRec;
  lst: TStringList;
begin
  lst := TStringList.Create;

  if RightStr(dir, 1) <> '\' then
    dir := dir + '\';

  try
    if FindFirst(dir+filter, faAnyFile, SR) = 0 then
    repeat
      lst.Add(SR.Name);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;

  Result := lst;
end;

procedure ConcatenateDfmStrings(novoDir, filename: string);
var lst, newLst: TStringList;
    i, j: integer;
    currLine, code, text: string;
    currChar: char;
    started, codeStarted: Boolean;
begin
  if RightStr(novoDir, 1) <> '\' then
    novoDir := novoDir + '\';

  lst := TStringList.Create;
  newLst := TStringList.Create;

  try
    lst.LoadFromFile(filename);

    if lst.Count = 0 then
      Exit;

    i := 0;
    code := '';

    started := False;
    codeStarted := False;

//    try
      while i < lst.Count-1 do
      begin
        currLine := lst.Strings[i];
        text := '';

        j := 1;
        while j <= Length(currLine) do
        begin
          currChar := currLine[j];

          if (currChar = '''') then
          begin
            if codeStarted and (code <> '') then // write the code if the string starts again
            begin
              text := text + Chr(StrToInt(code));
              code := '';
              codeStarted := False;
            end;

            started := not started;
            Inc(j);
            continue;
          end;

          if not started and (currChar = '#') then
          begin
            if code <> '' then // found another code, write the previously one
            begin
              text := text + Chr(StrToInt(code));
              code := '';
            end
            else
            begin
              codeStarted := not codeStarted;
            end;

            Inc(j);
            continue;
          end;

          // checks if there is a concatenated string with next line
          if not started and (currChar = ' ') and
             (j = Length(currLine)-1) and (currLine[j+1] = '+') then
          begin
            currLine := LeftStr(currLine, j-1);
            if i < lst.Count-1 then // concatenate next line to currLine
            begin
              currLine := currLine + Trim(lst.Strings[i+1]);
              Inc(i);
            end;

            continue;
          end;

          // end of the string
          if codeStarted and (currChar = ')') then
          begin
            text := text + Chr(StrToInt(code));
            code := '';
            codeStarted := False;
          end;

          if not codeStarted then
            text := text + currChar
          else if codeStarted then
            code := code + currChar;

          Inc(j);
        end; // while j <= Length(currLine) do

        if codeStarted then
        begin
          text := text + Chr(StrToInt(code));
          code := '';
          codeStarted := False;
        end;

        newLst.Add(text);
        Inc(i);
      end; // while i < lst.Count-1 do
//    except on E: exception do
//      ShowMessage('Error: i: ' + IntToStr(i) + ' | j: ' + IntToStr(j) + #13 + 'linha: ' + currLine + #13 + E.Message);
//    end;

    newLst.SaveToFile(novoDir+ExtractFileName(filename));
  finally
    lst.Free;
    newLst.Free;
  end;
end;

procedure TForm1.edtFormatStringsClick(Sender: TObject);
var lstFiles: TStringList;
  i: integer;
  dir, newDir: string;
begin
  dir := Trim(edtDirectory.Text);

  if (dir = '') or not DirectoryExists(dir) then
  begin
    ShowMessage('Invalid Directory!');
    edtDirectory.SetFocus;
    Exit;
  end;

  if RightStr(dir, 1) = '\' then
    Delete(dir, Length(dir), 1);

  lstFiles := GetFileList(edtDirectory.Text, '*.dfm');

  if (lstFiles.Count = 0) then
  begin
    ShowMessage('No DFM files found in directory.');
    edtDirectory.SetFocus;
    Exit;
  end;

  newDir := dir+FormatDateTime('_yyyymmdd_hhnnss', Now);

  if not DirectoryExists(newDir) then
    CreateDir(newDir);

  pbStatus.Position := 0;
  pbStatus.Max := lstFiles.Count;

  try
    for i := 0 to lstFiles.Count-1 do
    begin
      try
        lbStatus.Caption := 'Processing ' + IntToStr(i+1) + ' of ' + IntToStr(lstFiles.Count) + ' (' + lstFiles.Strings[i] + ')';
        Application.ProcessMessages;

        ConcatenateDfmStrings(newDir, dir+'\'+lstFiles.Strings[i]);

        pbStatus.Position := pbStatus.Position + 1;
        Application.ProcessMessages;
      except
        on E: Exception do
        begin
          ShowMessage('Error processing file: ' + lstFiles.Strings[i] + #13 + E.Message);
          Exit;
        end;

      end;
    end;

    ShowMessage('Files generated in: ' + #13 + newDir);
  finally
    lstFiles.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  lbStatus.Caption := '';
end;

end.
