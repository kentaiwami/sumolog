<?php

namespace App\Http\Controllers\api\v1\health_check;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use DB;

class APIHealthCheckController extends Controller
{
    public function get(Request $request) {
        try {
            DB::connection()->getPdo();
        } catch (\Exception $e) {
            return Response('', 500);
        }
        
        return Response('', 200);
    }
}
