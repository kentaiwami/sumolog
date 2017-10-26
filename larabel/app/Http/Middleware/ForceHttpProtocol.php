<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;
use PHPUnit\Exception;

class ForceHttpProtocol
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if (env('APP_ENV') === 'production' || env('APP_ENV') === 'staging') {
            if (!$request->isSecure()) {
                $secureUrl = 'https://' . $request->getHttpHost() . $request->getRequestUri();
                return redirect($secureUrl);
            }
        }
            return $next($request);
    }
}
