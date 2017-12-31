<?php

namespace App\Http\Controllers;

use App\Smoke;
use App\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Validator;

class APISmokeController extends Controller
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

        return Response()->json([
            'uuid'      => $request->get('uuid'),
            'smoke_id'  => $new_smoke->id
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $current_url = url()->current();
        $pattern_overview = "#api/smoke/overview/user/+[0-9]#";
        $pattern_detail = "#api/smoke/detail/user/+[0-9]#";

        if (preg_match($pattern_overview, $current_url)) {
            //TODO: 現在時刻から24時間前までの喫煙データをDBから取得(1)
            //TODO: (1)の件数を"count": "23"とする

            //TODO: 最新の喫煙データを抽出(2)
            //TODO: 現在時刻-(2)を"latest": "240"とする


            //TODO: 1時間ごとの件数をカウント(3)
            //TODO: (3)を"hour": [1,2,3,....]とする


            return Response()->json(['id' => 'overview']);
        }

        if (preg_match($pattern_detail, $current_url)) {
            return Response()->json(['test' => 'detail']);
        }

        return Response('', 404);


//        $user = User::where('id', $id)->firstOrFail();
//
//        // 今月の給与日
//        $year = date('Y');
//        $month = date('m');
//        $user_paydate = $year . $month . $user->payday;
//
//        // 今月の給与日を超えていた場合はその日付を、超えていない場合は先月の日付を生成
//        if (date('Y-m-d', strtotime($user_paydate)) < date('Y-m-d'))
//            $pre_paydate = date('Y-m-d', strtotime($user_paydate));
//        else
//            $pre_paydate = date('Y-m-d', strtotime($user_paydate .'-1 month'));
//
//        // 先月の給与までのレコードを日付別で取得
//        $smokes = Smoke::where('user_id', $user->id)
//            ->where('started_at', '>=', $pre_paydate)->get()
//            ->groupBy(function($date) {
//                return Carbon::parse($date->started_at)->format('d');
//            });
//
//        // 日付別の件数をカウント
//        $count_by_day = array();
//        foreach ($smokes as $key => $val) {
//            $count_by_day[] = count($val);
//        }
//
//        $count_by_day_str = implode(',', $count_by_day);
//
//        // ユーザの給与日と配列文字列をコマンドラインに投げる
//        exec(env('PYTHON_PATH') .' ' .env('SCRIPT_PATH') .' '.$count_by_day_str.' '.$user->payday,$output,$return);
//
//        return Response()->json(['results' => $output]);
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
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $validator_array = [];
        $isput = true;

        /* バリデータとフラグを切り替え */
        if ($request->method() == 'PUT') {
            $validator_array = ['uuid' => 'bail|required|string|max:191'];

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
            /* 開始時間を超えない範囲で時間を調整する */
            $ended_at = date(now());
            if ($smoke->started_at <= date('Y-m-d H:i:s', strtotime('- 1 min'))) {
                $ended_at = date('Y-m-d H:i:s', strtotime('- 1 min'));
            }elseif ($smoke->started_at <= date('Y-m-d H:i:s', strtotime('- 30 sec'))) {
                $ended_at = date('Y-m-d H:i:s', strtotime('- 30 sec'));
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
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
