﻿unit MyLibrary.FormUtil;

interface

uses System.SysUtils,
     System.Classes,
     FMX.Forms,
     FMX.TabControl,
     System.UITypes,
     FMX.Layouts;



type
  TMyLibrary_FormBase = Class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    // ------
    FSuccProc: TProc<TModalResult>;
  protected
  public
    procedure RunFormAsModal(const ResultProc: TProc<TModalResult>);
    constructor create(aowner: TComponent); virtual;
  end;

// --------------------------------------------------------------------------------------------

type
  TMyLibrary_FormTabbed = class(TMyLibrary_FormBase)
  private
  public
    function getFormLayout: TLayout; virtual; abstract; // Descendant must implement to return main layout of form
  end;

type
  TMyLibrary_ClassOfFormTabbed = class of TMyLibrary_FormTabbed;



Type
  TMyLibraryTabsArrayRecord = array of record
    TabItem: TTabItem;
    TabForm: TMyLibrary_FormTabbed;
    ActiveFormTabByClass: TClass;
    IsbtnMenuVisible: Boolean;
    IsbtnBackVisible: Boolean;
    MenuButtonsColor: TAlphaColor;
  end;

type
  TMyLibrary_MainFormBase_Tabbed = Class(TMyLibrary_FormBase)
  private
    FTabsArray: TMyLibraryTabsArrayRecord;
    //
    function checkFormIsAlreadyOpen(p_formClass: TMyLibrary_ClassOfFormTabbed): integer;
  protected
    function getTabControl: TTabControl; virtual; abstract;
  public
    property TabsArray: TMyLibraryTabsArrayRecord read FTabsArray;
    procedure RunFormAsTab(p_formClass: TMyLibrary_ClassOfFormTabbed; p_swiCanRepeat: boolean = FALSE);
    procedure CloseAllTabs;
  end;


implementation


{ TMyLibraryFormBase_MDI_Tabbed }

uses  uFmxMain;

// Check if form already exist if then return the index of position on de TabsArray, if not returns -1
function TMyLibrary_MainFormBase_Tabbed.checkFormIsAlreadyOpen(p_formClass: TMyLibrary_ClassOfFormTabbed): integer;
begin

  // TO-DO
  result := -1;

end;


procedure TMyLibrary_MainFormBase_Tabbed.CloseAllTabs;
var
  i: integer;
begin
  for i:= 0 to Length(TabsArray) - 1 do
  begin
    TabsArray[i].TabForm.Close;
    TabsArray[i].TabForm.getFormLayout.Parent := nil;
    TabsArray[i].TabForm.Release; // Do somethings and free
    TabsArray[i].TabForm:= nil;
  end;
end;


procedure TMyLibrary_MainFormBase_Tabbed.RunFormAsTab(p_formClass: TMyLibrary_ClassOfFormTabbed; p_swiCanRepeat: boolean);
var
  i: integer;
begin
  if p_swiCanRepeat then i := -1
  else i := checkFormIsAlreadyOpen(p_formClass);

  if i = -1 then
  begin
    i := Length(FTabsArray);
    SetLength(FTabsArray, i + 1);
    //FTabControl.Add()
    TabsArray[i].TabItem:= TTabItem.Create(getTabControl); //getTabControl.add;
    TabsArray[i].TabItem.Parent:= getTabControl;
    //TabsArray[i].TabItem.TabControl := getTabControl;
    getTabControl.ActiveTab := TabsArray[i].TabItem;
    TabsArray[i].TabItem.AutoSize:= False;
    TabsArray[i].TabForm:= p_formClass.Create(NIL);
    TabsArray[i].TabForm.getFormLayout.Parent := TabsArray[i].TabItem;
  end;
end;

{ TMyLibrary_FormBase }

constructor TMyLibrary_FormBase.create(aowner: TComponent);
begin
  inherited;
  FSuccProc := NIL;
end;

procedure TMyLibrary_FormBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FSuccProc) then
  begin
    FSuccProc(ModalResult);
    FSuccProc:= nil;
  end;
end;

procedure TMyLibrary_FormBase.RunFormAsModal(const ResultProc: TProc<TModalResult>);
begin
  FSuccProc:= ResultProc;
  {$IF DEFINED(Win64) or DEFINED(Win32)}
  ShowModal;
  {$ELSE}
  Self.Show;
  {$ENDIF}

end;

end.