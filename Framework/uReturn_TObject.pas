unit uReturn_TObject;

interface

uses
rtti,
generics.collections;

Type
TReturn_TObject = class
class function Instanciar<T:Class>:T;
end;

implementation

{ TReturn_TObject<T> }

class function TReturn_TObject.Instanciar<T>: T;
var
valor: TValue;
ctx: TRttiContext;
tipo: TRttiType;
tipoInstancia: TRttiInstanceType;
begin
tipo := ctx.GetType(TypeInfo(T));
tipoInstancia:= (Ctx.FindType(Tipo.QualifiedName) as TRttiInstanceType);
Valor:=Tipoinstancia.MetaclassType.Create;
Result := valor.AsType<T>;
end;

end.
