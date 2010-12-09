unit QueryPageTemplateInfosMainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  MediaWikiUtils,
  MediaWikiApi;

type
  TMainForm = class(TForm)
    MemoResult: TMemo;
    ButtonQueryAsync: TButton;
    ButtonQuerySync: TButton;
    EditMaxTemplates: TEdit;
    LabelMaxTemplates: TLabel;
    EditPage: TEdit;
    LabelPage: TLabel;
    LabelStartTemplate: TLabel;
    EditStartTemplate: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure ButtonQuerySyncClick(Sender: TObject);
    procedure ButtonQueryAsyncClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FMediaWikiApi: TMediaWikiApi;
    procedure MediaWikiAllPageTemplateDone(Sender: TMediaWikiApi; const PageTemplateInfos: TMediaWikiPageTemplateInfos);
    procedure MediaWikiAllPageTemplateContinue(Sender: TMediaWikiApi; const Start: string);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.ButtonQueryAsyncClick(Sender: TObject);
begin
  MemoResult.Lines.Clear;
  FMediaWikiApi.OnQueryPageTemplateInfoDone := MediaWikiAllPageTemplateDone;
  FMediaWikiApi.OnQueryPageTemplateInfoContinue := MediaWikiAllPageTemplateContinue;
  FMediaWikiApi.QueryInit;
  FMediaWikiApi.QueryPageTemplateInfoAsync(EditPage.Text, False, StrToInt(EditMaxTemplates.Text), -1, EditStartTemplate.Text);
  FMediaWikiApi.QueryExecuteAsync;
end;

procedure TMainForm.ButtonQuerySyncClick(Sender: TObject);
var
  TemplateInfos: TMediaWikiPageTemplateInfos;
  Index: Integer;
begin
  MemoResult.Lines.Clear;
  FMediaWikiApi.OnQueryPageTemplateInfoDone := nil;
  FMediaWikiApi.OnQueryPageTemplateInfoContinue := nil;
  FMediaWikiApi.QueryPageTemplateInfo(EditPage.Text, False, TemplateInfos, StrToInt(EditMaxTemplates.Text), -1, EditStartTemplate.Text);
  for Index := Low(TemplateInfos) to High(TemplateInfos) do
  begin
    MemoResult.Lines.Add('template page title = ' + TemplateInfos[Index].TemplatePageBasics.PageTitle);
    MemoResult.Lines.Add('template page ID = ' + IntToStr(TemplateInfos[Index].TemplatePageBasics.PageID));
    MemoResult.Lines.Add('template page namespace = ' + IntToStr(TemplateInfos[Index].TemplatePageBasics.PageNamespace));
    MemoResult.Lines.Add('page title = ' + TemplateInfos[Index].TemplateTitle);
    MemoResult.Lines.Add('page namespace = ' + IntToStr(TemplateInfos[Index].TemplateNameSpace));
    MemoResult.Lines.Add('');
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caFree then
  begin
    // logout is not required
    //FMediaWikiApi.Logout;
    FMediaWikiApi.Free;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FMediaWikiApi := TMediaWikiApi.Create;
  FMediaWikiApi.URL := 'http://wiki.delphi-jedi.org/api.php';
  FMediaWikiApi.UserAgent := 'MediaWiki JEDI bot';
  FMediaWikiApi.FollowRelocation := False;
  // login is not mandatory
  //FMediaWikiApi.Login()
end;

procedure TMainForm.MediaWikiAllPageTemplateContinue(Sender: TMediaWikiApi;
  const Start: string);
begin
  EditStartTemplate.Text := Start;
end;

procedure TMainForm.MediaWikiAllPageTemplateDone(Sender: TMediaWikiApi;
  const PageTemplateInfos: TMediaWikiPageTemplateInfos);
var
  Index: Integer;
begin
  for Index := Low(PageTemplateInfos) to High(PageTemplateInfos) do
  begin
    MemoResult.Lines.Add('template page title = ' + PageTemplateInfos[Index].TemplatePageBasics.PageTitle);
    MemoResult.Lines.Add('template page ID = ' + IntToStr(PageTemplateInfos[Index].TemplatePageBasics.PageID));
    MemoResult.Lines.Add('template page namespace = ' + IntToStr(PageTemplateInfos[Index].TemplatePageBasics.PageNamespace));
    MemoResult.Lines.Add('page title = ' + PageTemplateInfos[Index].TemplateTitle);
    MemoResult.Lines.Add('page namespace = ' + IntToStr(PageTemplateInfos[Index].TemplateNameSpace));
    MemoResult.Lines.Add('');
  end;
end;

end.
