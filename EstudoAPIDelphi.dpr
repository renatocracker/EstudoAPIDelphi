program EstudoAPIDelphi;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Horse,
  Horse.Logger,
  Horse.Logger.Provider.LogFile,
  Horse.Compression,
  Horse.BasicAuthentication,
  Horse.Jhonson,
  Horse.Commons,
  System.SysUtils,
  System.JSON,
  Horse.OctetStream,
  System.Classes;

var
  Users : TJSONArray;
  LLogFileConfig: THorseLoggerLogFileConfig;

begin
  THorse.Use(Compression()); // CHAMAR ANTES DO JHONSON
  THorse.Use(Jhonson());
  THorse.Use(OctetStream);
  THorse.Use(eTag);
  //THorse.Use(THorseLoggerLog.ne);


  // EXEMPLO LOG
   LLogFileConfig := THorseLoggerLogFileConfig.new
    .SetLogFormat('${request_clientip} [${time}] ${response_status}')
    .SetDir('C:\Users\Renato\Documents\GitHub\EstudoAPIDelphi\log');

  // EXEMPLO ETAG
  THorse.Get('ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send<TJsonObject>(TJsonObject.Create.AddPair('Teste', 'Teste'));
    end);



  // Voc� tamb�m pode especificar o formato do log e o caminho onde ele ser� salvo:
  // THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New(LLogFileConfig));

  // Aqui voc� definir� o provedor que ser� usado.
  THorseLoggerManager.RegisterProvider(THorseLoggerProviderLogFile.New());

  // � necess�rio adicionar o middleware no Cavalo:
  THorse.Use(THorseLoggerManager.HorseCallback);

  // EXEMPLO STREAM
  THorse.Get('/imagem',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TFileStream;
    begin
      LStream := TFileStream.Create('E:\qrCode.png', fmOpenRead);
      Res.Send<TStream>(LStream);
    end);

  THorse.Post('/imagem',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LStream: TMemoryStream;
    begin
      LStream := Req.Body<TMemoryStream>;
      LStream.SaveToFile('E:\estudo api.jpg');
      Res.Send('Imagem cadastrada com sucesso.').Status(201);
    end);


  // AUTENTICA��O
  THorse.Use(HorseBasicAuthentication(
    function(const AUsername, APassword: string): Boolean
    begin
      Result := AUsername.Equals('renato') and APassword.Equals('123');
    end));


    // TESTE DE COMPRESS�O
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

