<?php

namespace App\Http\Controllers\api\v1\smoke\show;

use App\User;
use App\Smoke;
use App\Http\Controllers\Controller;

class APIShow24hourSmokeController extends Controller
{
    /**
     * Display the specified resource.
     *
     * @param  string   $v
     * @param  int      $id
     * @return \Illuminate\Http\Response
     */
    public function show($v, $id)
    {
        // ユーザの存在を確認
        $user = User::where('id', $id)->firstOrFail();

        // API実行時から24時間以内の喫煙データを取得
        $pre_datetime = date('Y-m-d H:i:s', strtotime('-24 hour', time()));
        $smokes = Smoke::where('user_id', $user->id)
            ->where('started_at', '>=', $pre_datetime)
            ->orderBy('started_at', 'desc')
            ->get();

        return Response()->json(['results' => $smokes]);
    }
}
