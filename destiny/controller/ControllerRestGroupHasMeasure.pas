unit ControllerRestGroupHasMeasure;

interface
uses System.Classes, System.SysUtils,BaseController,
      Md5, FireDAC.Stan.Param, tblRestGroupHasMeasure,
      ControllerRestGroup, ControllerMeasure;

Type

  TControllerRestGroupHasMeasure = Class(TBaseController)
    procedure clear;
  private


  public
    Registro : TRestGroupHasMeasure;
    RestGRoup : TControllerRestGroup;
    Measure : TControllerMeasure;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function insert:boolean;
    function update:boolean;
    function delete: boolean;

    function getByKey:Boolean;
  End;

implementation

procedure TControllerRestGroupHasMeasure.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerRestGroupHasMeasure.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TRestGroupHasMeasure.Create;
  RestGRoup := TControllerRestGroup.Create(Self);
  Measure := TControllerMeasure.Create(Self);
end;

function TControllerRestGroupHasMeasure.delete: boolean;
begin
  deleteObj(Registro);
end;

destructor TControllerRestGroupHasMeasure.Destroy;
begin
  RestGRoup.disposeOf;
  Registro.disposeOf;
  inherited;
end;


function TControllerRestGroupHasMeasure.insert: boolean;
begin
  try
    insertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerRestGroupHasMeasure.save: boolean;
begin
  try
    saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


function TControllerRestGroupHasMeasure.update: boolean;
begin
  try
    UpdateObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


function TControllerRestGroupHasMeasure.getByKey: Boolean;
begin
  _getByKey(Registro);
end;

end.
