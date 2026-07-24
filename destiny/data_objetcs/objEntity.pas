unit objEntity;

interface

uses tblEntity, tblAddress, TypesCollection, tblPerson, tblCompany,
     tblSocialMedia, tblPhone,GenericDao,tblMailing,
  System.Generics.Collections, ObjBase, System.SysUtils;

Type

  TObjEntity = Class(TObjBase)
  private
    type
      TAddressArray = array of TAddress;
      TPhoneArray = array of TPhone;
  private
    FaddressList: TAddressArray;

    Fsocialmedia: TSocialMedia;
    FphoneList: TPhoneArray;
    Fentity: TEntity;
    FMailing: TMailing;
    procedure setFaddressList(const Value: TAddressArray);

    procedure setFentity(const Value: TEntity);
    procedure setFphoneList(const Value: TPhoneArray);
    procedure setFsocialmedia(const Value: TSocialMedia);
    procedure setFMailing(const Value: TMailing);
  public
    constructor Create;
    destructor Destroy;
    procedure clear;virtual;
    procedure setArrayAddress(i:Integer);
    procedure setArrayPhone(i:Integer);
    property Registro : TEntity read Fentity write setFentity;
    property Email : TMailing read FMailing write setFMailing;
    property ListaEndereco :TAddressArray read FaddressList write setFaddressList;
    property ListaFones : TPhoneArray read FphoneList write setFphoneList;
    property MidiaSocial : TSocialMedia read Fsocialmedia write setFsocialmedia;

  End;

implementation


{ TObjEntity }


procedure TObjEntity.clear;
begin
  TGenericDAO._Clear(Fentity);
  TGenericDAO._Clear(FMailing);
  TGenericDAO._Clear(Fsocialmedia);
end;

constructor TObjEntity.Create;
begin
  Fentity       := TEntity.Create;
  FMailing          := TMailing.Create;
  Fsocialmedia    := TSocialMedia.Create;
end;

destructor TObjEntity.Destroy;
begin
  setArrayAddress(0);
  setArrayPhone(0);
  Fentity.DisposeOf;
  FMailing.DisposeOf;
  Fsocialmedia.DisposeOf;
end;


procedure TObjEntity.setArrayAddress(i: Integer);
begin
  SetLength(FaddressList,i);
end;

procedure TObjEntity.setArrayPhone(i: Integer);
begin
  SetLength(FphoneList,i);
end;


procedure TObjEntity.setFaddressList(const Value: TAddressArray);
begin
  FaddressList := Value;
end;


procedure TObjEntity.setFentity(const Value: TEntity);
begin
  Fentity := Value;
end;

procedure TObjEntity.setFMailing(const Value: TMailing);
begin
  FMailing := Value;
end;

procedure TObjEntity.setFphoneList(const Value: TPhoneArray);
begin
  FphoneList := Value;
end;

procedure TObjEntity.setFsocialmedia(const Value: TSocialMedia);
begin
  Fsocialmedia := Value;
end;

end.

