<?php

namespace App\Http\Controllers\api\v1\smoke\update;

use App\Http\Controllers\Controller;
use App\Smoke;
use App\User;
use Illuminate\Http\Request;
use Validator;

class APIUpdateSmokeController extends Controller
{
    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int    $id
     * @param  string $v
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $v, $id)
    {
        $validator_array = [
            'uuid' => 'bail|required|string|max:191',
            'minus_sec' => 'bail|required|integer|min:0',
            'is_sensor' => 'bail|required|boolean'
        ];

        $validator = Validator::make($request->all(), $validator_array);

        if ($validator->fails()) {
            return Response()->json($validator->errors());
        }

        $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        $smoke = Smoke::where('id', $id)->firstOrFail();

        if ($user->id != $smoke->user_id) {
            return Response('', 404);
        }

        $minus_sec = '- ' .$request->get('minus_sec') . ' sec';

        //開始時間を超える、1分より短いデータは誤データとして削除(ただし、時間調整が0の場合はどんなに短くても記録する)
        if (strtotime($minus_sec) -  strtotime($smoke->started_at) < 60 and  $request->get('minus_sec') != 0) {
            try {
                $smoke->delete();
            } catch (\Exception $e) {}

            // スマホからのアクセスは時間調整が0のためここには来ないので、is_sensorは不要。
            if ($user->token != "") {
                (new \Davibennun\LaravelPushNotification\PushNotification)->app('Sumolog')
                    ->to($user->token)
                    ->send('誤検出したデータを削除しました');
            }

            return Response()->json([
                'smoke_id' => 0,
                'started_at' => "",
                'ended_at' => ""
            ]);
        }else {
            $ended_at = date('Y-m-d H:i:s', strtotime($minus_sec));

            if ($user->token != "" and $request->get('is_sensor')) {
                (new \Davibennun\LaravelPushNotification\PushNotification)->app('Sumolog')
                    ->to($user->token)
                    ->send('喫煙終了をセンサーが検知しました');
            }
        }

        $smoke->ended_at = $ended_at;
        $smoke->save();

        return Response()->json([
            'smoke_id'      => $smoke->id,
            'started_at'    => $smoke->started_at,
            'ended_at'      => $smoke->ended_at,
        ]);
    }
}
