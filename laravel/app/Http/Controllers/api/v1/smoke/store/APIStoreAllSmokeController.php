<?php

namespace App\Http\Controllers\api\v1\smoke\store;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Smoke;
use App\User;
use Validator;

class APIStoreAllSmokeController extends Controller
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
            'uuid' => 'bail|required|string|max:191',
            'started_at' => 'bail|required|string|max:191',
            'ended_at' => 'bail|required|string|max:191'
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }

        $user = User::where('uuid', $request->get('uuid'))->firstOrFail();

        $new_smoke = new Smoke;
        $new_smoke->user_id = $user->id;
        $new_smoke->started_at = $request->get("started_at");
        $new_smoke->ended_at = $request->get("ended_at");
        $new_smoke->save();

        return Response()->json([
            'uuid'      => $request->get('uuid'),
            'smoke_id'  => $new_smoke->id
        ]);
    }
}
