program EstudoAPIDelphi;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse, Horse.Compression, Horse.BasicAuthentication, Horse.Jhonson, Horse.Commons, System.SysUtils, System.JSON;

var
  Users : TJSONArray;

begin
  THorse.Use(Compression()); // CHAMAR ANTES DO JHONSON
  THorse.Use(Jhonson());

  // AUTENTICAÇÃO
  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('renato') and APassword.Equals('123');
    end));

    // TESTE DE COMPRESSÃO
  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      I: Integer;
      LPong: TJSONArray;
    begin
      LPong := TJSONArray.Create;
      for I := 0 to 1000 do
        LPong.Add(TJSONObject.Create(TJSONPair.Create('ping', 'pong')));
      Res.Send(LPong);
    end);

  Users := TJSONArray.Create;

  // LISTAR
  THorse.Get('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send<TJSONAncestor>(Users.Clone);
    end);

  // INSERIR
  THorse.Post('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      User : TJSONObject;
    begin
      User := Req.Body<TJSONObject>.Clone as TJSONObject;
      Users.AddElement(User);
      Res.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created);
    end);

  // EXCLUIR
  THorse.Delete('/users/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      Id : Integer;
    begin
      id := Req.Params.Items['id'] .ToInteger;
      Users.Remove(Pred(id)).Free;
      Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.Created);
    end);

  THorse.Listen(9000);
end.

