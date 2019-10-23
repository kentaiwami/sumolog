<?php

namespace App\Http\Controllers\api\v1\smoke\store;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Smoke;
use App\User;
use Validator;
use DateTime;

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

        if ($user->is_add_average_auto and !$request->get('is_sensor')) {
            $result = $this->get_start_end_time($user->id);
            $new_smoke->started_at = $result['start'];
            $new_smoke->ended_at = $result['end'];
        }

        $new_smoke->save();

        if ($user->token != '' and $request->get('is_sensor')) {
            (new \Davibennun\LaravelPushNotification\PushNotification)->app('Sumolog')
                ->to($user->token)
                ->send('喫煙開始をセンサーが検知しました', array('badge' => 1, 'sound' => 'default'));
        }

        return Response()->json([
            'uuid'      => $request->get('uuid'),
            'smoke_id'  => $new_smoke->id,
            'is_add_average_auto' => (bool)$user->is_add_average_auto
        ]);
    }


    /**
     * ユーザの24時間分の喫煙情報から1本あたりの平均時間を求めて、喫煙開始・終了時刻を返す
     * @param int $user_id
     * @return array
     */
    public function get_start_end_time($user_id) {
        $now = new DateTime('now');
        $end = new DateTime('now');
        $prev_24hour = date('Y-m-d H:i:s', strtotime('- 24 hour'));
        $smokes_24hour = Smoke::where('user_id', $user_id)
            ->whereBetween('started_at', [$prev_24hour, $now])
            ->orderBy('started_at', 'desc')
            ->get();

        $ave = 0.0;
        $difference_sum = 0.0;

        foreach ($smokes_24hour as $smoke_obj) {
            $started_at = new \DateTime($smoke_obj->started_at);
            $ended_at = new \DateTime($smoke_obj->ended_at);
            $difference_sum += $ended_at->getTimestamp() - $started_at->getTimestamp();
        }

        if (count($smokes_24hour) != 0) {
            $ave = round($difference_sum / count($smokes_24hour), 0, PHP_ROUND_HALF_UP);
        }

        $end->modify('+'.$ave.'sec');

        return array(
            'start' => $now,
            'end'   => $end
        );
    }
}
