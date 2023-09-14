program EstudoAPIDelphi;

{$APPTYPE CONSOLE}

{$R *.res}

uses Horse;

var
  App : THorse;

  begin
    App := THorse.Create(9000);

    App.Get('/ping',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        Res.Send('pong');
      end);

    App.Start;
    --THorse.Listen(9000);
  end.

end.
