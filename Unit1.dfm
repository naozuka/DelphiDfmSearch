object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Delphi DFM Search'
  ClientHeight = 196
  ClientWidth = 503
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    503
    196)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 16
    Width = 95
    Height = 13
    Caption = 'Directory To Search'
  end
  object lbStatus: TLabel
    Left = 3
    Top = 158
    Width = 39
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lbStatus'
    ExplicitTop = 164
  end
  object edtDirectory: TEdit
    Left = 16
    Top = 35
    Width = 467
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edtFormatStrings: TButton
    Left = 16
    Top = 88
    Width = 467
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Format Strings in Dfm Files'
    TabOrder = 1
    OnClick = edtFormatStringsClick
  end
  object pbStatus: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 176
    Width = 497
    Height = 17
    Align = alBottom
    TabOrder = 2
  end
end
