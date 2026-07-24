unit ControllerColaborador;

interface

uses IBDatabase,Classes, IBQuery, SysUtils,ControllerBase,
      tblColaborador ,Un_MSg,Generics.Collections,
      ControllerCargo,ObjSalesMan,tblphone,tblAddress,ControllerUF, controllerCidade;


Type
  TListColaborador = TObjectList<TColaborador>;

  TControllerColaborador = Class(TControllerBase)

  private

  protected

  public
    Registro : TColaborador;
    Cargo : TControllerCargo;
    Lista : TListColaborador;
    Obj  : TObjSalesMan;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function salva:boolean;
    function migra:boolean;
    procedure getbyId;
    function insert:boolean;
    function update:boolean;
    Function delete:boolean;
    function getList:Boolean;
    function getDocByID:String;
    function getDocByUser:String;
    function getByDoc:Boolean;
    function getIDByDoc:Integer;
    function getVendedorTray:Integer;
    function getVendedorIfood:Integer;
    function getVendedorAppDelivery:Integer;
    function temPedido:Boolean;
    function getByUsuario:Boolean;
    function Replace:boolean;
    procedure FillDataObjeto();
    function VerificaExistenciaUsuario(UsuarioId:Integer):Boolean;
  End;

implementation

uses Un_sistema, Un_funcoes,Un_Regra_Negocio;

constructor TControllerColaborador.Create(AOwner: TComponent);
begin
  inherited;
  Registro  := TColaborador.Create;
  Lista     := TListColaborador.Create;
  Cargo := TControllerCargo.create(Self);
  Obj  := TObjSalesMan.Create;

end;

function TControllerColaborador.delete: boolean;
begin
  Try
    DeleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerColaborador.Destroy;
begin
  Obj.Destroy;
  FreeAndNil(Lista);
  Registro.DisposeOf;
  FreeAndNil(Cargo);
  inherited;
end;

procedure TControllerColaborador.FillDataObjeto();
Var
  LcPhone : TPhone;
  LcAddress : TAddress;
  LcUF : TControllerUf;
  LcCidade : TControllerCidade;
begin
  with obj.objColaborador.Fiscal do
  BEgin
    Entidade.Registro.Codigo               := 0;
    Entidade.Registro.NomeRazao            := Registro.Nome;
    Entidade.Registro.ApelidoFantasia      := Registro.Nome;
    Entidade.Registro.AniversarioFundacao  := Registro.NAscimento;
    Entidade.Registro.RamoAtividade        := 0;
    Entidade.Registro.Observacao           := Registro.Observacao;

    //EntityExternalCode
    EntityExternalCode.Codigo          := 0; //Sempre zero pois ser� redefnido no Sistema Web
    EntityExternalCode.Estabelecimento := obj.objColaborador.Fiscal.Entidade.Estabelecimento;
    EntityExternalCode.Referencia      := Registro.Codigo;
    EntityExternalCode.Tipo            := 'COLABORADOR';

    if ( Length( Trim(Registro.CPFCNPJ)) = 11 ) then
    Begin
      Fisica.Codigo := 0; //Sempre zero pois ser� redefnido no Sistema Web
      Fisica.CPF := Registro.CPFCNPJ;
      Fisica.RG := Registro.Identidade;
      Fisica.Aniversario := Registro.NAscimento;
    End
    else
    Begin
      Juridica.Codigo := 0; //Sempre zero pois ser� redefnido no Sistema Web
      Juridica.CNPJ := Registro.CPFCNPJ;
      Juridica.InscricaoEstadual := Registro.Identidade;
      Juridica.CRT := '1';
      Juridica.DataFundacao := Registro.NAscimento;
      Juridica.IndicacaoIEDestinatario := '1';
      Juridica.EnviarSomenteXMLNFe := 'N';
    End;
  End;
  //Address
  obj.objColaborador.Fiscal.Entidade.setArrayAddress(0);
  LcAddress := TAddress.Create;
  LcAddress.Codigo := 0; //Sempre zero pois ser� redefnido no Sistema Web
  LcAddress.Logradouro := Registro.Endereco;
  LcAddress.NumeroPredial := '';
  LcAddress.Complemento := '';
  LcAddress.Bairro := Registro.Bairro;
  LcAddress.Regiao := '';
  LcAddress.Tipo := 'RESIDENCIAL';
  LcAddress.Cep := Registro.Cep;
  LcAddress.CodigoPais := 1058;
  Try
    LcUF := TControllerUf.Create(self);
    LcCidade := TControllerCidade.Create(self);

    LcAddress.CodigoEstado := LcUF.BuscaCodigo( Registro.Estado );
    LcAddress.CodigoCidade := LcCidade.Buscacodigo(0,Registro.Cidade,Registro.Estado);
  Finally
    FreeAndNil( LcUF );
    FreeAndNil( LcCidade );
  End;
  LcAddress.Principal := 'S';
  obj.objColaborador.Fiscal.Entidade.setArrayAddress(1);
  obj.objColaborador.Fiscal.Entidade.ListaEndereco[0] := LcAddress;

  obj.objColaborador.Fiscal.Entidade.Email.Email := Registro.email;
  //Phone
  obj.objColaborador.Fiscal.Entidade.setArrayPhone(0);
  if Registro.Fone <> '' then
  Begin
    LcPhone := TPhone.Create;
    LcPhone.Codigo := 0; //Sempre zero pois ser� redefnido no Sistema Web
    LcPhone.Tipo := 'Fone';
    LcPhone.Numero := Registro.Fone;
    LcPhone.TipoEndereco := 'Fone';
    obj.objColaborador.Fiscal.Entidade.setArrayPhone(Length(obj.objColaborador.Fiscal.Entidade.ListaFones) + 1);
    obj.objColaborador.Fiscal.Entidade.ListaFones[Length(obj.objColaborador.Fiscal.Entidade.ListaFones) -1] := LcPhone;
  End;
  //Phone
  if Registro.Celular <> '' then
  Begin
    LcPhone := TPhone.Create;
    LcPhone.Codigo := 0; //Sempre zero pois ser� redefnido no Sistema Web
    LcPhone.Tipo := 'Celular';
    LcPhone.Numero := Registro.Fone;
    LcPhone.TipoEndereco := 'Celular';
    obj.objColaborador.Fiscal.Entidade.setArrayPhone(Length(obj.objColaborador.Fiscal.Entidade.ListaFones) + 1);
    obj.objColaborador.Fiscal.Entidade.ListaFones[Length(obj.objColaborador.Fiscal.Entidade.ListaFones) -1] := LcPhone;

  End;
  //Colaborador
  with obj.objColaborador.Colaborador do
  BEgin
    Estabelecimento := obj.objColaborador.Fiscal.Entidade.Estabelecimento;
    Codigo          := 0; //Sempre zero pois ser� redefnido no Sistema Web
    DataAdmissao    := Registro.Admissao;
    DataDemissao    := Registro.Demissao;
    Salario         := Registro.Salario;
    Pai             := Registro.NomePai;
    Mamae           := Registro.NomeMae;
    Titulo          := Registro.TituloEleitor;
    Zona            := Registro.TituloZona;
    Sessao          := Registro.SecaoZona;
    Certificado     := Registro.CertificadoMilitar;
    Ativo           := 'S';
    Pis             := Registro.PIS;
  End;


  WITH obj.Vendedor DO
  Begin
    Codigo           := 0; //Sempre zero pois ser� redefnido no Sistema Web
    Estabelecimento  := obj.objColaborador.Fiscal.Entidade.Estabelecimento;
    Ativo            := 'S';
    AliquotaComissao := Registro.ComissaoAliqVenda;
    ComissaoProduto  := Registro.ComissaoPorProduto;
  End;
end;

function TControllerColaborador.insert: boolean;
begin
  if Registro.Codigo = 0 then
    Registro.Codigo := Generator('GN_COLABORADOR');
  Try
    InsertObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

function TControllerColaborador.migra: boolean;
begin
  Result := True;
  SaveObj(Registro);
end;

function TControllerColaborador.Replace: boolean;
begin
  Try
    replaceObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

function TControllerColaborador.salva: boolean;
begin
  Result := True;
  if Registro.Codigo = 0 then
    Registro.Codigo := Generator('GN_COLABORADOR');
  SaveObj(Registro);
end;


function TControllerColaborador.temPedido: Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add(concat('select PED_CODVDO ',
                     'from TB_PEDIDO ',
                     'where PED_CODVDO =:PED_CODVDO '
                     ));
      ParamByName('PED_CODVDO').AsInteger := Registro.codigo;
      Active := True;
      FetchAll;
      REsult := (recordCount > 0)
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;

function TControllerColaborador.update: boolean;
begin
  Try
    UpdateObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

function TControllerColaborador.VerificaExistenciaUsuario(
  UsuarioId: Integer): Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Result := True;
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add(concat('select * ',
                     'from TB_COLABORADOR ',
                     'where CLB_CODUSU =:CLB_CODUSU ',
                     ' AND CLB_CODIGO <>:CLB_CODIGO '
                     ));
      ParamByName('CLB_CODUSU').AsInteger := UsuarioId;
      ParamByName('CLB_CODIGO').AsInteger := Registro.codigo;
      Active := True;
      FetchAll;
      exist := (recordCount > 0);
      if exist then
        get(Lc_Qry,Registro);
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;

procedure TControllerColaborador.getById;
begin
  _getByKey(Registro);
end;


function TControllerColaborador.getByUsuario: Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Result := True;
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add(concat(
                  'select * ',
                  'from tb_colaborador ',
                  'where (CLB_CODUSU =:CLB_CODUSU) '
      ));
      ParamByName('CLB_CODUSU').AsInteger := Registro.Usuario;
      Active := True;
      FetchAll;
      exist := (RecordCount > 0);
      if not exist then
      Begin
        Active := False;
        sql.Clear;
        sql.Add(concat(
                  'SELECT FIRST 1 C.* ',
                  'from tb_colaborador C ',
                  '  INNER JOIN TB_CARGO G ',
                  '  ON (G.crg_codigo  = C.clb_codcrg) ',
                  'where (G.crg_descricao LIKE ''VENDEDOR%'') '
        ));
        Active := True;
        FetchAll;
        exist := (RecordCount > 0);
      End;
      if exist then
      Begin
        get(Lc_Qry,Registro);
      End
      else
      BEgin
        Active := False;
        sql.Clear;
        sql.Add(concat(
                  'SELECT FIRST 1 C.* ',
                  'from tb_colaborador C '
        ));
        Active := True;
        FetchAll;
        exist := (RecordCount > 0);
        if exist then
          get(Lc_Qry,Registro);
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerColaborador.getDocByID: String;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    Result := '';
    with Lc_Qry do
    Begin
      sql.Add(concat('select CLB_CPF ',
                     'from tb_colaborador ',
                     'where clb_codigo =:clb_codigo'
                     ));
      ParamByName('clb_codigo').AsInteger := Registro.Codigo;
      Active := True;
      First;
      if RecordCount > 0 then
        REsult := FieldByName('CLB_CPF').AsString;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerColaborador.getDocByUser: String;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    Result := '';
    with Lc_Qry do
    Begin
      sql.Add(concat('select CLB_CPF ',
                     'from tb_colaborador ',
                     'where clb_codusu =:usu_codigo'
                     ));
      ParamByName('usu_codigo').AsInteger := Registro.Usuario;
      Active := True;
      First;
      if RecordCount > 0 then
        REsult := FieldByName('CLB_CPF').AsString;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerColaborador.getIDByDoc: Integer;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    Result := 0;
    with Lc_Qry do
    Begin
      sql.Add(concat('select CLB_CODIGO ',
                     'from tb_colaborador ',
                     'where CLB_CPF =:CLB_CPF '
                     ));
      ParamByName('CLB_CPF').AsString := Registro.CPFCNPJ;
      Active := True;
      First;
      if RecordCount > 0 then
        REsult := FieldByName('CLB_CODIGO').AsInteger;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerColaborador.getList: boolean;
var
  Lc_Qry : TIBQuery;
  LcLista : TColaborador;
begin
  Result := True;
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add('SELECT * FROM TB_COLABORADOR ');
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LcLista := TColaborador.Create;
        get(Lc_qry,LcLista);
        Lista.add(LcLista);
        next;
      end;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;


function TControllerColaborador.getVendedorAppDelivery: Integer;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add(concat('select CLB_CODIGO ',
                     'from tb_colaborador ',
                     'where CLB_NOME =:CLB_NOME'
                     ));
      ParamByName('CLB_NOME').AsString := 'APP DELIVERY';
      Active := True;
      First;
      if RecordCount > 0 then
      Begin
        REsult := FieldByName('CLB_CODIGO').AsInteger;
      End
      else
      BEgin
        Registro.Codigo := 0;
        Registro.Nome := 'APP DELIVERY';
        Registro.Sexo := 'M';
        Registro.Cargo := Cargo.GetcargoVendedor;
        Registro.Pais := 1058;
        Registro.Admissao := Date;
        Registro.NAscimento := Date;
        //Registro.Estabelecimento := InstitutitionID;n�o colocar o codigo para que o usuario n�o possa alterar no sistema
        Self.insert;
        REsult := Registro.Codigo;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerColaborador.getVendedorIfood: Integer;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add(concat('select CLB_CODIGO ',
                     'from tb_colaborador ',
                     'where CLB_NOME =:CLB_NOME'
                     ));
      ParamByName('CLB_NOME').AsString := 'VENDEDOR IFOOD';
      Active := True;
      First;
      if RecordCount > 0 then
      Begin
        REsult := FieldByName('CLB_CODIGO').AsInteger;
      End
      else
      BEgin
        Registro.Codigo := 0;
        Registro.Nome := 'VENDEDOR IFOOD';
        Registro.Sexo := 'M';
        Registro.Cargo := Cargo.GetcargoVendedor;
        Registro.Pais := 1058;
        Registro.Admissao := Date;
        Registro.NAscimento := Date;
        Self.insert;
        REsult := Registro.Codigo;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;

function TControllerColaborador.getVendedorTray: Integer;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add(concat('select CLB_CODIGO ',
                     'from tb_colaborador ',
                     'where CLB_NOME =:CLB_NOME'
                     ));
      ParamByName('CLB_NOME').AsString := 'VENDEDOR LOJA TRAY';
      Active := True;
      First;
      if RecordCount > 0 then
      Begin
        REsult := FieldByName('CLB_CODIGO').AsInteger;
      End
      else
      BEgin
        Registro.Codigo := 0;
        Registro.Nome := 'VENDEDOR LOJA TRAY';
        Registro.Sexo := 'M';
        Registro.Cargo := Cargo.GetcargoVendedor;
        Registro.Pais := 1058;
        Registro.Admissao := Date;
        Registro.NAscimento := Date;
        Self.insert;
        REsult := Registro.Codigo;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;


function TControllerColaborador.getByDoc: Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    Result := True;
    with Lc_Qry do
    Begin
      sql.Add(concat('select *  ',
                     'from tb_colaborador ',
                     'where CLB_CPF =:CLB_CPF'
                     ));
      ParamByName('CLB_CPF').AsString := Registro.CPFCNPJ;
      Active := True;
      First;
      exist := (RecordCount > 0);
      if (exist) then get(Lc_Qry,Registro);
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

end.
