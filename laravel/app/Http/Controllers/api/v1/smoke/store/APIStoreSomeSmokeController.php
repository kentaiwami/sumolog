<?php

namespace App\Http\Controllers\api\v1\smoke\store;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Validator;
use App\Smoke;
use App\User;


class APIStoreSomeSmokeController extends Controller
{
    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'uuid' => 'bail|required|regex:/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/',
            'start_point' => 'bail|required|regex:/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/',
            'end_point' => 'bail|required|regex:/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/',
            'smoke_time' => 'bail|required|integer|min:1',
            'smoke_count' => 'bail|required|integer|min:1'
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }

        $user = User::where('uuid', $request->get('uuid'))->firstOrFail();

//

        return Response()->json([
            'uuid'      => 'uuid'
        ]);
    }
}
