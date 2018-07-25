<?php

namespace App\Http\Controllers\api\v1\smoke\store;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Smoke;
use App\User;
use Sly\NotificationPusher\Model\Message;
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
            'uuid' => 'bail|required|string|max:191',
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }

        $user = User::where('uuid', $request->get('uuid'))->firstOrFail();

        $new_smoke = new Smoke;
        $new_smoke->user_id = $user->id;
        $new_smoke->save();

        if ($user->token != "") {
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
