<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

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
//        if (env('APP_ENV') === 'production' || env('APP_ENV') === 'staging') {
//            if ($_SERVER['HTTP_USER_AGENT'] != 'https') {
//                return redirect()->secure($request->getRequestUri());
//            }
//        }

//        if (!app()->environment('local')) {
//            // for Proxies
//            Request::setTrustedProxies([$request->getClientIp()]);
//            if (!$request->isSecure()) {
//                return redirect()->secure($request->getRequestUri());
//            }
//        }
            return $next($request);
    }
}
