<?php

namespace App\Http\Controllers\api\v1;

use App\Smoke;
use App\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Validator;

class APISmokeController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request, $v)
    {
        $current_url = url()->current();
        $pattern_standard = "#api/".$v."/smoke#";
        $pattern_all = "#api/".$v."/smoke/all#";


        /********* all *********/
        if (preg_match($pattern_all, $current_url)) {
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


        /********* standard *********/
        if (preg_match($pattern_standard, $current_url)) {
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

            return Response()->json([
                'uuid'      => $request->get('uuid'),
                'smoke_id'  => $new_smoke->id
            ]);
        }

        return Response('', 404);
    }

    /**
     * Display the specified resource.
     *
     * @param  string   $v
     * @param  int      $id
     * @param  string   $uuid
     * @return \Illuminate\Http\Response
     */
    public function show($v, $id, $uuid="")
    {
        $current_url = url()->current();
        $pattern_overview = "#api/".$v."/smoke/overview/user/[0-9]+#";
        $pattern_24hour = "#api/".$v."/smoke/24hour/user/[0-9]+/[0-9|A-F]{8}+-[0-9|A-F]{4}+-[0-9|A-F]{4}+-[0-9|A-F]{4}+-[0-9|A-F]{12}+#";



        /********* overview *********/
        if (preg_match($pattern_overview, $current_url)) {
            $user = User::where('id', $id)->firstOrFail();


            $now = date(now());
            $prev_hour = date('Y-m-d H:i:s', strtotime('- 24 hour'));

            /* 対象ユーザの24時間以内の喫煙データを取得 */
            $smokes = Smoke::where('user_id', $id)
            ->whereBetween('started_at', [$prev_hour, $now])
            ->orderBy('started_at', 'desc')
            ->get();

            $count_hour = count($smokes);

            // ユーザの目標本数
            $target_number = $user->target_number;

            /* 最新の喫煙データが何分前かを計算 */
            $latest = Smoke::where('user_id', $id)->orderBy('started_at', 'DESC')->first()->started_at;

            $latest_datetime = new \DateTime($latest);
            $now_datetime = new \DateTime($now);
            $min = round(($now_datetime->getTimestamp() - $latest_datetime->getTimestamp())/60, 0, PHP_ROUND_HALF_UP);


            /* 時間別で集計 */
            $hour_smokes = $smokes->groupBy(function($date) {
                return Carbon::parse($date->started_at)->format('H');
            });


            // 時間ごとのカウントを配列へ入れる(最新順のため、返す時に逆順にする必要あり)
            $count_array = [];
            foreach ($hour_smokes as $key => $value ) {
                $tmp = [$key => count($value)];
                $count_array[] = $tmp;
            }


            // 今月の給与日
            $year = date('Y');
            $month = date('m');
            $user_paydate = $year . '-' . $month . '-'. $user->payday;


            // 今月の給与日を超えていた場合はその日付を、超えていない場合は先月の日付を生成
            if (date('Y-m-d', strtotime($user_paydate)) <= date('Y-m-d')){
                $pre_paydate = date('Y-m-d', strtotime($user_paydate));
            }
            else{
                $pre_paydate = date('Y-m-d', strtotime($user_paydate .'-1 month'));
            }

            // 先月の給与までのレコードを日付別で取得
            $smokes = Smoke::where('user_id', $id)
                ->where('started_at', '>=', $pre_paydate)->get()
                ->groupBy(function($date) {
                    return Carbon::parse($date->started_at)->format('d');
                });


            // 日付別の件数、1本の所要時間をカウント
            $count_by_day = array();
            $difference_sum = 0.0;
            foreach ($smokes as $key => $val) {
                foreach ($val as $smoke_obj) {
                    $started_at = new \DateTime($smoke_obj->started_at);
                    $ended_at = new \DateTime($smoke_obj->ended_at);
                    $difference_sum += ($ended_at->getTimestamp() - $started_at->getTimestamp())/60;
                }

                $count_by_day[] = count($val);
            }

            $ave = round($difference_sum / array_sum($count_by_day), 1, PHP_ROUND_HALF_UP);

            return Response()->json([
                'count' => $count_hour,
                'min'   => $min,
                'hour'  => array_reverse($count_array, false),
                'over'  => $count_hour - $target_number,
                'ave'   => $ave,
                'used' => array_sum($count_by_day) * $user->price
            ]);
        }



        /********* 24hour *********/
        if (preg_match($pattern_24hour, $current_url)) {
            // ユーザの存在を確認
            $user = User::where('id', $id)->where('uuid', $uuid)->firstOrFail();

            // API実行時から24時間以内の喫煙データを取得
            $pre_datetime = date('Y-m-d H:i:s', strtotime('-24 hour', time()));
            $smokes = Smoke::where('user_id', $user->id)
                ->where('started_at', '>=', $pre_datetime)
                ->orderBy('started_at', 'desc')
                ->get();

            return Response()->json(['results' => $smokes]);
        }

        return Response('', 404);
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

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
        $validator_array = [];
        $isput = true;

        /* バリデータとフラグを切り替え */
        if ($request->method() == 'PUT') {
            $validator_array = [
                'uuid' => 'bail|required|string|max:191',
                'minus_sec' => 'bail|required|integer|min:0',
            ];

        }else if ($request->method() == 'PATCH') {
            $isput = false;
            $validator_array = [
                'uuid' => 'bail|required|string|max:191',
                'started_at' => 'bail|required|string|max:191',
                'ended_at' => 'bail|required|string|max:191'
            ];
        }


        /* バリデーション */
        $validator = Validator::make($request->all(), $validator_array);

        if ($validator->fails()) {
            return Response()->json($validator->errors());
        }

        /* ユーザIDと対象となる喫煙レコードのIDの一致を確認 */
        $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        $smoke = Smoke::where('id', $id)->firstOrFail();

        if ($user->id != $smoke->user_id) {
            return Response('', 404);
        }

        if ($isput) {
            /*
            開始時間を超えない場合は調整実施。超える場合は誤データとして削除
             */
            $minus_sec = '- ' .$request->get('minus_sec') . ' sec';

            if ($smoke->started_at <= date('Y-m-d H:i:s', strtotime($minus_sec))) {
                $ended_at = date('Y-m-d H:i:s', strtotime($minus_sec));
            }else {
                try {
                    $smoke->delete();
                } catch (\Exception $e) {}

                return Response()->json([
                    'smoke_id' => 0,
                    'started_at' => "",
                    'ended_at' => ""
                ]);
            }

            $smoke->ended_at = $ended_at;
            $smoke->save();

        }else {
            $smoke->started_at = $request->get('started_at');
            $smoke->ended_at = $request->get('ended_at');
            $smoke->save();
        }

        return Response()->json([
            'smoke_id'      => $smoke->id,
            'started_at'    => $smoke->started_at,
            'ended_at'      => $smoke->ended_at,
        ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  string   $v
     * @param  int      $smoke_id
     * @param  int      $user_id
     * @return \Illuminate\Http\Response
     */
    public function destroy($v, $smoke_id, $user_id)
    {
        try {
            Smoke::where([['id', $smoke_id], ['user_id', $user_id]])->delete();
        } catch (\Exception $e) {
            return Response()->json(['msg' => 'Error'], 404);
        }
        return Response()->json(['msg' => 'Success'],200);
    }
}
