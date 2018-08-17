<?php

namespace App\Http\Controllers\api\v1\smoke\store;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use DateTime;
use DB;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Validator;
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

        try {
            $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        } catch (ModelNotFoundException $e) {
            abort(404, '指定したユーザは存在しません');
        }

        $diff_min = ((new DateTime($request->get('end_point')))->getTimestamp() - (new DateTime($request->get('start_point')))->getTimestamp()) / 60;
        $rand_end = $diff_min - $request->get('smoke_time');

        $smokes = array();
        $loop_count = 0;

        while (1) {
            $loop_count += 1;

            if ($loop_count > 10000) {
                abort(400, '指定した時刻の範囲に収まる喫煙情報の作成に失敗しました。下記の操作をすると作成に成功します。¥n・範囲の拡大¥n・喫煙本数を増やす¥n・喫煙時間を減らす');
            }

            $start_min = mt_rand(0, $rand_end);
            $end_min = $start_min + $request->get('smoke_time');
            $started_at = new DateTime($request->get('start_point'));
            $started_at->modify('+'.$start_min.'min');
            $ended_at = new DateTime($request->get('start_point'));
            $ended_at->modify('+'.$end_min.'min');

            $check_time_duplication = function($var) use ($started_at, $ended_at) {
                $tmp_start = new DateTime($var['started_at']);
                $tmp_end = new DateTime($var['ended_at']);

                if ($tmp_start->modify('-1min') < $ended_at && $started_at < $tmp_end->modify('+1min')) {
                    return true;
                }else {
                    return false;
                }
            };

            if (count(array_filter($smokes, $check_time_duplication)) != 0) {
                continue;
            }

            array_push($smokes, [
                'user_id' => $user->id,
                'started_at' => $started_at->format('Y-m-d H:i:s'),
                'ended_at' => $ended_at->format('Y-m-d H:i:s')
            ]);

            if (count($smokes) == $request->get('smoke_count')) {
                break;
            }
        }

        DB::table('smokes')-> insert($smokes);

        return Response()->json([
            'results' => $smokes
        ]);
    }
}
