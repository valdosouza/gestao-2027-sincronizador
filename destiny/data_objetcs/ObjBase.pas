unit ObjBase;

interface

Type

  TObjBase = Class
  private
    Fdescription: String;
    Fdate_change: TDateTime;
    Ftb_institution_id: Integer;
    Fcnpj_institution: String;
    Fweb_id: Integer;
    Fterminal: Integer;
    Fpage: Integer;
    procedure setFcnpj_institution(const Value: String);
    procedure setFdata_change(const Value: TDateTime);
    procedure setFdescription(const Value: String);
    procedure setFpage(const Value: Integer);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFterminal(const Value: Integer);
    procedure setFweb_id(const Value: Integer);


  public
    constructor Create;Virtual;
    destructor Destroy;reintroduce;Virtual;

    property Pagina : Integer read Fpage write setFpage;
    property Estabelecimento : Integer Read Ftb_institution_id write setFtb_institution_id;
    property EstabelecimentoCNPJ : String read Fcnpj_institution write setFcnpj_institution;
    property Terminal : Integer Read Fterminal write setFterminal;
    property Descricao : String read Fdescription write setFdescription;
    property CodigoWeb : Integer Read Fweb_id write setFweb_id;
    Property DataAlteracao : TDateTime read Fdate_change write setFdata_change;
  End;

implementation

{ TObjBase }

constructor TObjBase.Create;
begin

end;

destructor TObjBase.Destroy;
begin

end;

procedure TObjBase.setFcnpj_institution(const Value: String);
begin
  Fcnpj_institution := Value;
end;

procedure TObjBase.setFdata_change(const Value: TDateTime);
begin
  Fdate_change := Value;
end;

procedure TObjBase.setFdescription(const Value: String);
begin
  Fdescription := Value;
end;

procedure TObjBase.setFpage(const Value: Integer);
begin
  Fpage := Value;
end;

procedure TObjBase.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TObjBase.setFterminal(const Value: Integer);
begin
  Fterminal := Value;
end;

procedure TObjBase.setFweb_id(const Value: Integer);
begin
  Fweb_id := Value;
end;

end.
