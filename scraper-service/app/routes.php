<?php

declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';


use App\Application\Actions\User\ListUsersAction;
use App\Application\Actions\User\ViewUserAction;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Slim\App;
use Slim\Interfaces\RouteCollectorProxyInterface as Group;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface as RequestHandler;
use Prometheus\CollectorRegistry;
use Prometheus\Storage\Redis;
use Prometheus\RenderTextFormat;



return function (App $app) {
    $app->options('/{routes:.*}', function (Request $request, Response $response) {
        // CORS Pre-Flight OPTIONS Request Handler
        return $response;
    });

    $app->get('/ping', function (Request $request, Response $response) {
        
        $now = new DateTime();

        $pongInfo = array(
            "res" => "pong",
            "ts" => $now->getTimeStamp(),
            "copyright" => "Alex Lopez 1989 - " . $now->format( "Y" ),
            "date" => $now->format( 'Y-m-d H:i:s.u' ),
        );

        $response->getBody()->write(json_encode($pongInfo , JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT));

        return $response
                ->withHeader('Content-Type', 'application/json')
                ->withStatus(200);

    });

    $app->post('/', function ($request, $response, array $args) {

        $parsedBody = $request->getParsedBody();
        $urlToCall = $parsedBody["url"];
        $ch = curl_init($urlToCall);
        curl_setopt($ch,  CURLOPT_RETURNTRANSFER, TRUE);
        $curlResp = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        $adapter = new Prometheus\Storage\APC();
        $registry = new CollectorRegistry($adapter);

        $counter = $registry->getOrRegisterCounter('http', 'gets', 'Incremental Counter', ['url','code']);
        $counter->incBy(1, [$urlToCall,$httpCode]);

        $data = array('url' => $urlToCall, 'code' => $httpCode);
        $payload = json_encode($data , JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT );

        $response->getBody()->write($payload);
        return $response
                ->withHeader('Content-Type', 'application/json')
                ->withStatus(201);
    });

    $app->get('/metrics', function ($request, $response, array $args) {

        $adapter = new Prometheus\Storage\APC();
        $registry = new CollectorRegistry($adapter);

        $renderer = new RenderTextFormat();
        $result = $renderer->render($registry->getMetricFamilySamples('http', 'get'));

        $response->getBody()->write($result);
        return $response
                ->withHeader('Content-Type', RenderTextFormat::MIME_TYPE)
                ->withStatus(200);
    });

    $app->group('/users', function (Group $group) {
        $group->get('', ListUsersAction::class);
        $group->get('/{id}', ViewUserAction::class);
    });
};
