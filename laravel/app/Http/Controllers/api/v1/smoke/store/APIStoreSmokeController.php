<?php

namespace App\Http\Controllers\api\v1\smoke\store;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Smoke;
use App\User;
use Validator;

class APIStoreSmokeController extends Controller
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
            'is_sensor' => 'bail|required|boolean'
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }

        try {
            $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        } catch (ModelNotFoundException $e) {
            abort(404, '指定したユーザは存在しません');
        }

        $new_smoke = new Smoke;
        $new_smoke->user_id = $user->id;
        $new_smoke->save();

        if ($user->token != '' and $request->get('is_sensor')) {
            (new \Davibennun\LaravelPushNotification\PushNotification)->app('Sumolog')
                ->to($user->token)
                ->send('喫煙開始をセンサーが検知しました', array('badge' => 1, 'sound' => 'default'));
        }

        return Response()->json([
            'uuid'      => $request->get('uuid'),
            'smoke_id'  => $new_smoke->id
        ]);
    }
}
