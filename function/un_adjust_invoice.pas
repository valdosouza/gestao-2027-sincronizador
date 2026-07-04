unit un_adjust_invoice;

interface
uses
   SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,Vcl.Forms,
   IBX.IBQuery, un_dm,System.Generics.Collections, ControllerPedido,Gauges,
  ControllerNotaFiscal, ControllerItensNFL, ControllerFinanceiro, Data.DB,
  Vcl.Dialogs,ACBrNFe, pcnLeitor,pcnConversao;
type


  TDuplicate = class
  private
    FPedido: Integer;
    FNota: Integer;
    procedure setFNota(const Value: Integer);
    procedure setFPedido(const Value: Integer);

    public
      property Pedido : Integer read FPedido write setFPedido;
      property Nota : Integer read FNota write setFNota;
  end;

  TListaDuplicate = TObjectList<TDuplicate>;

  TAdjustInvoice = Class(TComponent)
      Lista  : TListaDuplicate;
    private
      procedure getDuplicates;
      procedure clearOrderItems;
      procedure remakeOrders;
      procedure AjusteNovosPedidos;
      function PreencherNota55(Pedido,Nota:Integer):Boolean;
      function PreencherNota65(Pedido,Nota:Integer):Boolean;

      procedure Pc_Salva_Arq_Disco(Pc_Tipo: Integer;
                                 Pc_Formato: String;
                                 Pc_Cd_Vinculo: Integer;
                                 Pc_Arq_Caminho: String);

      function criaPedido(Codigo:Integer):Integer;
      function updateNotaFiscal(Pedido,Nota:Integer):Boolean;
      function updateItensNFL(Pedido,Nota:Integer):Boolean;
      function deletePedido(Codigo:Integer):Boolean;

      function DeletaFinanceiroErro(Nota:Integer):Boolean;

      procedure DeleteNotaFiscal(indice:Integer);
      procedure MakeNewOrder(indice:Integer);
      function getModel(Codigo:Integer):Integer;

    public
      progresso : TGauge;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure Execute;
  End;


implementation

{ TAdjustInvoice }

procedure TAdjustInvoice.AjusteNovosPedidos;
Var
  LcQr : TIBQuery;
  LcUp : TIBQuery;
  LcRes : Boolean;
begin
  LcUp := TIBQuery.Create(Self);
  with LcUp do
  Begin
    Database := DM.IBD_Gestao;
    Transaction := dm.IBT_Atualiza;
    Active := False;
    sql.clear;
    sql.Add(concat(
          'update tb_nota_fiscal set ',
          'NFL_VL_TL_NOTA =:NFL_VL_TL_NOTA ',
          'where NFL_CODIGO =:NFL_CODIGO '
    ));
  End;


  LcQr := TIBQuery.Create(Self);
  with LcQr do
  Begin
    Database := DM.IBD_Gestao;
    Transaction := dm.IBT_Consulta;
    if dm.IBT_Consulta.InTransaction then dm.IBT_Consulta.Commit;
    
    Active := False;
    sql.clear;
    sql.Add(concat(
            'select n.nfl_codigo,n.nfl_codped, n.nfl_modelo, P.PED_VL_PEDIDO,p.peD_numero, n.nfl_vl_tl_nota, f.fin_vl_parcela, SUM ((i.itf_vl_unit * i.itf_qtde)-i.itf_vl_desc) subtotal ',
            'from tb_nota_fiscal n ',
            '  inner join tb_pedido p ',
            '  on (p.ped_codigo = n.nfl_codped) ',
            '  inner join tb_financeiro f ',
            '  on (f.fin_codnfl = n.nfl_codigo) ',
            '  left outer join tb_itens_nfl i ',
            '  on (i.itf_codnfl =n.nfl_codigo) ',
            'group by 1,2,3,4,5,6,7 ',
            'having  (n.nfl_vl_tl_nota > SUM ((i.itf_vl_unit * i.itf_qtde)-i.itf_vl_desc)) or ',
            '(SUM ((i.itf_vl_unit * i.itf_qtde)-i.itf_vl_desc) = 0) ',
            'union ',
            'select n.nfl_codigo,n.nfl_codped, n.nfl_modelo,P.PED_VL_PEDIDO,p.peD_numero,n.nfl_vl_tl_nota, f.fin_vl_parcela, SUM ((i.itf_vl_unit * i.itf_qtde)-i.itf_vl_desc) subtotal ',
            'from tb_nota_fiscal n ',
            '  inner join tb_pedido p ',
            '  on (p.ped_codigo = n.nfl_codped) ',
            '  inner join tb_financeiro f ',
            '  on (f.fin_codnfl = n.nfl_codigo) ',
            '  left outer join tb_itens_nfl i ',
            '  on (i.itf_codnfl =n.nfl_codigo) ',
            'where i.itf_codigo is null ',
            'group by 1,2,3,4,5,6,7 '
    ));
    Active := True;
    FetchAll;
    First;
    progresso.MinValue := 0;
    progresso.MaxValue := RecordCount;
    progresso.Progress := 0;
    while not eof do
    Begin
      if FieldByName('NFL_MODELO').AsString = '55' then
      Begin
        LcRes := PreencherNota55(FieldByName('NFL_CODPED').AsInteger,FieldByName('NFL_CODIGO').AsInteger);
      End
      else
      Begin
        LcRes := PreencherNota65(FieldByName('NFL_CODPED').AsInteger,FieldByName('NFL_CODIGO').AsInteger);
      End;
      if not LcRes then
      Begin
        if ( FieldByName('fin_vl_parcela').AsFloat = FieldByName('subtotal').AsFloat ) then
        Begin
          LcUp.Active := False;
          LcUp.ParamByName('NFL_VL_TL_NOTA').AsFloat := FieldByName('fin_vl_parcela').AsFloat;
          LcUp.ParamByName('NFL_CODIGO').AsInteger := FieldByName('NFL_CODIGO').AsInteger;
          LcUp.ExecSQL;
          if LcUP.Transaction.InTransaction then  LcUp.Transaction.CommitRetaining;
        End;
      End;
      next;
      progresso.Progress := progresso.Progress  + 1;
      progresso.Update;
    End;
  End;
end;

procedure TAdjustInvoice.clearOrderItems;
Var
  LcQr : TIBQuery;
  LcPedido,LcNota : Integer;
  LcDup : TDuplicate;
begin
  LcQr := TIBQuery.Create(Self);
  with LcQr do
  Begin
    Database := DM.IBD_Gestao;
    Transaction := dm.IBT_Crud;
    Active := False;
    sql.clear;
    sql.Add(concat(
              'delete from tb_itens_icms where icm_codnfl =:NFL_CODIGO;',
              'commit;',
              'delete from tb_itens_ipi where ipi_codnfl =:NFL_CODIGO;',
              'commit;',
              'delete from tb_itens_pis where pis_codnfl =:NFL_CODIGO;',
              'commit;',
              'delete from tb_itens_cfs where cfs_codnfl =:NFL_CODIGO;',
              'commit;',
              'delete from tb_itens_nfl where itf_codnfl =:NFL_CODIGO;',
              'commit;'
    ));
    ExecSQL;
  End;
  LcQr.Close;
  FreeAndNil(LcQr);
end;

constructor TAdjustInvoice.Create(AOwner: TComponent);
begin
  inherited;
  Lista  := TListaDuplicate.Create;
end;

function TAdjustInvoice.criaPedido(Codigo: Integer): Integer;
Var
  LcPEdido : TControllerPedido;
begin
  try
    LcPEdido := TControllerPedido.create(self);
    LcPEdido.Registro.Codigo := Codigo;
    LcPEdido.getbyId;
    if LcPEdido.exist then
    Begin
      //Muda o codigo para criar um novo pedido
      LcPEdido.Registro.Codigo := 0;
      LcPEdido.salva;
      Result := LcPEdido.Registro.Codigo;
    End;
  finally
    FreeAndNil(LcPEdido);
  end;
end;

function TAdjustInvoice.DeletaFinanceiroErro(Nota:Integer): Boolean;
Var
  LcFinanceiro : TControllerFinanceiro;
begin
  LcFinanceiro := TControllerFinanceiro.Create(Self);
  LcFinanceiro.Registro.CodigoNota := Nota;
  LcFinanceiro.deleteFinanceiroErro;
  FreeAndNil(LcFinanceiro);
end;

procedure TAdjustInvoice.DeleteNotaFiscal(indice: Integer);
begin

end;

function TAdjustInvoice.deletePedido(Codigo: Integer): Boolean;
Var
  LcPEdido : TControllerPedido;
begin
  LcPEdido := TControllerPedido.create(self);
  LcPEdido.Registro.Codigo := Codigo;
  LcPEdido.delete;
  FreeAndNil(LcPEdido);
end;

destructor TAdjustInvoice.Destroy;
begin

  inherited;
end;

procedure TAdjustInvoice.Execute;
begin
  getDuplicates;
  remakeOrders;
end;

procedure TAdjustInvoice.getDuplicates;
Var
  LcQr : TIBQuery;
  LcPedido,LcNota : Integer;
  LcDup : TDuplicate;
begin
  LcQr := TIBQuery.Create(Self);
  with LcQr do
  Begin
    Database := DM.IBD_Gestao;
    Transaction := dm.IBT_Consulta;
    Active := False;
    sql.clear;
    sql.Add(concat(
              'select nfl_codigo, nfl_codped ',
              'from tb_nota_fiscal ',
              'Order by nfl_codped '
    ));
    active := True;
    First;
    LcPedido := 0;
    LcNota   := 0;
    Lista.Clear;
    while not eof do
    Begin
      if (LcPedido = FieldByName('NFL_CODPED').AsInteger) then
      Begin
        //Pega o anterior
        Prior;
        LcDup := TDuplicate.Create;
        LcDup.Pedido  := FieldByName('NFL_CODPED').AsInteger;
        LcDup.Nota    := FieldByName('NFL_CODIGO').AsInteger;
        Lista.Add(LcDup);
        //Volta para o Atual
        Next;
        LcDup := TDuplicate.Create;
        LcDup.Pedido  := FieldByName('NFL_CODPED').AsInteger;
        LcDup.Nota    := FieldByName('NFL_CODIGO').AsInteger;
        Lista.Add(LcDup);
      End;
      LcPedido := FieldByName('NFL_CODPED').AsInteger;
      LcNota   := FieldByName('NFL_CODIGO').AsInteger;
      next;
    End;
  End;
  LcQr.Close;
  FreeandNil(LcQr);
end;

function TAdjustInvoice.getModel(Codigo:Integer): Integer;
Var
  LcQr : TIBQuery;
  LcPedido,LcNota : Integer;
  LcDup : TDuplicate;
begin
  LcQr := TIBQuery.Create(Self);
  with LcQr do
  Begin
    Database := DM.IBD_Gestao;
    Transaction := dm.IBT_Crud;
    Active := False;
    sql.clear;
    sql.Add(concat(
              'select nfl_modelo ',
              'from tb_nota_fiscal '
    ));
    ParamByName('nfl_codigo').AsInteger := codigo;
    active := True;
    First;
    REsult := FieldByName('NFL_MODELO').AsInteger;
  End;
  LcQr.Close;
  FreeandNil(LcQr);
end;


procedure TAdjustInvoice.MakeNewOrder(indice:Integer);

begin

end;

function TAdjustInvoice.PreencherNota55(Pedido,Nota:Integer): Boolean;
Var
  LcQr : TIBQuery;
  LcRetorno : Integer;
  Nfe: TACBrNFe;
  wnProt: TLeitor;
  I : Integer;
  LcItens : TControllerItensNFL;
  LcProduto : Integer;
begin
  Result := False;
  LcQr := TIBQuery.Create(Self);
  with LcQr do
  Begin
    Database := DM.IBD_Gestao;
    Transaction := dm.IBT_Crud;
    Active := False;
    sql.clear;
    sql.Add(concat(
          'SELECT NFE_CODIGO ',
          'FROM tb_retorno_nfe N ',
          'WHERE ( N.NFE_CODNFL=:NFE_CODIGO ) '
    ));
    ParamByName('NFE_CODIGO').AsInteger := Nota;
    Active := True;
    FetchAll;
    LcRetorno := FieldByName('NFE_CODIGO').AsInteger;
  End;
  if LcRetorno > 0 then
  Begin
    Pc_Salva_Arq_Disco(1,
                       'XML',
                       LcRetorno ,
                       concat('c:\Temp\',IntToStr(Nota),'.xml'
      ));
    if FileExists(concat('c:\Temp\',IntToStr(Nota),'.xml')) then
    Begin
      Result := True;
      Nfe := TACBrNFe.Create(Self);
      Nfe.NotasFiscais.Clear;
      Nfe.NotasFiscais.LoadFromFile(concat('c:\Temp\',IntToStr(Nota),'.xml'));

      LcItens := TControllerItensNFL.Create(Self);
      WITH Nfe.NotasFiscais.Items[0].Nfe DO
      Begin
        For I := 0 to (Det.Count - 1) do
        Begin
          LcItens.Registro.CodigoPedido := Pedido;
          LcItens.getByFactoryProduct(Det.Items[I].Prod.cProd);
          if not LcItens.exist then
            LcItens.Registro.Codigo  := 0;
          LcItens.Produto.Registro.CodigoFabrica := Det.Items[I].Prod.cProd;
          LcItens.Produto.getbyFactoryProduct;
          with LcItens.Registro do
          Begin
            CodigoPedido      := Pedido;
            CodigoNota        := Nota;
            CodigoProduto     := LcItens.Produto.Registro.Codigo;
            Quantidade        := Det.Items[I].Prod.qCom;
            ValorCusto        := 0;
            ValorUnitario     := Det.Items[I].Prod.vUnTrib;
            Despachar         := 'N';
            Estoque           := 'S';
            ValorDesconto     := Det.Items[I].Prod.vDesc;;
            Operacao          := 'S';
            CodigoEstoque     := 1;
            CodigoTabela      := 1;
          End;
          if not LcItens.exist then
            LcItens.insere
          else
            LcItens.atualiza;
        End;
      End;
    End;
  End;
end;

procedure TAdjustInvoice.Pc_Salva_Arq_Disco(Pc_Tipo: Integer;
                                 Pc_Formato: String;
                                 Pc_Cd_Vinculo: Integer;
                                 Pc_Arq_Caminho: String);
var
  Lc_Qry: TIBQuery;
  Lc_SQL: String;
BEGIN
  {
   1 - Arquivo de XML da Nota Fiscal Eletronica Própria
   2 - Arquivo de XML da Carta de Correção
   3 - Arquivo de XML da Nota Fiscal Eletrônica de Terceiros
   4 - Arquivo de XML da Nota Fiscal Consumidor Eletronica
   5 - Arquivo de XML do Recibo Provisorio de Serviço
   6 - Arquivo de XML da Nota Fiscal de Serviço eletronica
  }
  Lc_Qry := TIBQuery.Create(Self);
  with Lc_Qry do
    Begin
    Database:= DM.IBD_Gestao;
    Transaction := DM.IBT_Crud;
    ForcedRefresh := True;
    CachedUpdates := True;
    Active := False;
    SQL.Clear;
    Lc_SQL := 'SELECT  '+
              '       ARQ_TIPO, '+
              '       ARQ_FORMATO, '+
              '       ARQ_CODVCL, '+
              '       ARQ_CONTEUDO '+
              'FROM TB_ARQUIVOS '+
              'WHERE (ARQ_TIPO=:ARQ_TIPO) '+
              '  AND (ARQ_FORMATO=:ARQ_FORMATO)'+
              '  AND ((ARQ_CODVCL=:ARQ_CODVCL) '+
              '   OR (ARQ_CODVCL IS NULL)) ';
    SQL.Add(Lc_SQL);
    ParamByName('ARQ_TIPO').AsInteger := Pc_Tipo;
    ParamByName('ARQ_FORMATO').AsString := Pc_Formato;
    ParamByName('ARQ_CODVCL').AsInteger := Pc_Cd_Vinculo;
    Active := True;
    if RecordCount >0 then
    Begin
      Try
        (FieldByName('ARQ_CONTEUDO') as TBlobField).SaveToFile( Pc_Arq_Caminho);
      Except
        on E:Exception do
          begin
          ShowMessage(E.Message);
          end;
      end;
    end;
  end;
  Lc_Qry.Close;
  FreeAndNil(Lc_Qry);
end;

function TAdjustInvoice.PreencherNota65(Pedido,Nota:Integer): Boolean;
Var
  LcQr : TIBQuery;
  LcRetorno : Integer;
  Nfe: TACBrNFe;
  wnProt: TLeitor;
  I : Integer;
  LcItens : TControllerItensNFL;
  LcProduto : Integer;
begin
  Result := False;
  LcQr := TIBQuery.Create(Self);
  with LcQr do
  Begin
    Database := DM.IBD_Gestao;
    Transaction := dm.IBT_Crud;
    Active := False;
    sql.clear;
    sql.Add(concat(
          'SELECT NFC_CODIGO ',
          'FROM tb_retorno_nfC N ',
          'WHERE ( N.NFC_CODNFL=:NFE_CODIGO ) '
    ));
    ParamByName('NFE_CODIGO').AsInteger := Nota;
    Active := True;
    FetchAll;
    LcRetorno := FieldByName('NFC_CODIGO').AsInteger;
  End;
  if LcRetorno > 0 then
  Begin
    Pc_Salva_Arq_Disco(4,
                       'XML',
                       LcRetorno ,
                       concat('c:\Temp\',IntToStr(Nota),'.xml'
      ));
    if FileExists(concat('c:\Temp\',IntToStr(Nota),'.xml')) then
    Begin
      Result := True;
      Nfe := TACBrNFe.Create(Self);
      Nfe.NotasFiscais.Clear;
      Nfe.NotasFiscais.LoadFromFile(concat('c:\Temp\',IntToStr(Nota),'.xml'));

      LcItens := TControllerItensNFL.Create(Self);
      WITH Nfe.NotasFiscais.Items[0].Nfe DO
      Begin
        For I := 0 to (Det.Count - 1) do
        Begin
          LcItens.Registro.CodigoPedido := Pedido;
          LcItens.getByFactoryProduct(Det.Items[I].Prod.cProd);
          if not LcItens.exist then
            LcItens.Registro.Codigo  := 0;
          LcItens.Produto.Registro.CodigoFabrica := Det.Items[I].Prod.cProd;
          LcItens.Produto.getbyFactoryProduct;
          with LcItens.Registro do
          Begin
            CodigoPedido      := Pedido;
            CodigoNota        := Nota;
            CodigoProduto     := LcItens.Produto.Registro.Codigo;
            Quantidade        := Det.Items[I].Prod.qCom;
            ValorCusto        := 0;
            ValorUnitario     := Det.Items[I].Prod.vUnTrib;
            Despachar         := 'N';
            Estoque           := 'S';
            ValorDesconto     := Det.Items[I].Prod.vDesc;;
            Operacao          := 'S';
            CodigoEstoque     := 1;
            CodigoTabela      := 1;
          End;
          if not LcItens.exist then
            LcItens.insere
          else
            LcItens.atualiza;
        End;
      End;
    End;
  End;
end;

procedure TAdjustInvoice.remakeOrders;
Var
  I : Integer;
  LcDup : TDuplicate;
  OrderUsed : Boolean;
  LCModelo : Integer;
  LcNewOrder : Integer;
  LcPedido:TControllerPedido;
begin
  LcDup := TDuplicate.Create;
  OrderUsed := False;
  getDuplicates;
  for I := 0 to lista.Count - 1 do
  Begin
    LcDup := Lista[I];
    LcNewOrder := criaPedido(LcDup.Pedido);
    updateNotaFiscal(LcNewOrder,LcDup.FNota);
    updateItensNFL(LcNewOrder,LcDup.FNota);
  End;

  progresso.MinValue := 0;
  progresso.MaxValue := lista.Count;
  progresso.Progress := 0;
  for I := 0 to lista.Count - 1 do
  Begin
    deletePedido(LcDup.Pedido);
    progresso.Progress := I + 1;
    progresso.Update;
  End;

  DeletaFinanceiroErro(LcDup.FNota);

  AjusteNovosPedidos;

end;


function TAdjustInvoice.updateItensNFL(Pedido, Nota: Integer): Boolean;
Var
  LcItens : TControllerItensNFL;
  i : Integer;
begin
  LcItens := TControllerItensNFL.Create(Self);
  LcItens.Registro.CodigoNota := Nota;
  LcItens.getListByNF;

  for I := 0 to (LcItens.Lista.Count - 1) do
  Begin
    LcItens.Registro := LcItens.Lista[I];
    LcItens.Registro.CodigoPedido := Pedido;
    LcItens.Registro.CodigoNota := Nota;
    LcItens.salva;
  End;
end;

function TAdjustInvoice.updateNotaFiscal(Pedido,Nota:Integer):Boolean;
Var
  LcNota : TControllerNotaFiscal;
begin
  LcNota := TControllerNotaFiscal.Create(Self);
  LcNota.Registro.Codigo := Nota;
  LcNota.Registro.CodigoPedido := Pedido;
  LcNota.updateCodigoPedido;
  FreeAndNil(LcNota);
end;

{ TDuplicate }

procedure TDuplicate.setFNota(const Value: Integer);
begin
  FNota := Value;
end;

procedure TDuplicate.setFPedido(const Value: Integer);
begin
  FPedido := Value;
end;

end.
