<?php

namespace App\Http\Controllers\api\v1\smoke\show;

use App\User;
use App\Smoke;
use App\Http\Controllers\Controller;
use Carbon\Carbon;

class APIShowOverViewSmokeController extends Controller
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
        $count_array = [];
        $tmp_count_array = [];

        if ($count_hour != 0) {
            $hour_smokes = $smokes->groupBy(function ($date) {
                return Carbon::parse($date->started_at)->format('H');
            });

            foreach ($hour_smokes as $key => $value ) {
                $count_array[] = array('hour' => $key, 'count' => count($value));
            }
        }

        $tmp_count = 0;
        while ($tmp_count != 25) {
            $tmp_hour = date('H', strtotime('- '.$tmp_count.' hour'));
            $tmp_count += 1;
            $is_hit = false;

            foreach ($count_array as $obj) {
                if ($obj['hour'] == $tmp_hour) {
                    $tmp_count_array[] = array('hour' => $tmp_hour, 'count' => $obj['count']);
                    $is_hit = true;
                    break;
                }
            }

            if (!$is_hit) {
                $tmp_count_array[] = array('hour' => $tmp_hour, 'count' => 0);
            }
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

        // 1本の所要時間をカウント
        $difference_sum = 0.0;
        foreach ($smokes as $smoke_obj) {
            $started_at = new \DateTime($smoke_obj->started_at);
            $ended_at = new \DateTime($smoke_obj->ended_at);
            $difference_sum += ($ended_at->getTimestamp() - $started_at->getTimestamp())/60;
        }

        if (count($smokes) == 0) {
            $ave = 0.0;
        }else {
            $ave = round($difference_sum / count($smokes), 1, PHP_ROUND_HALF_UP);
        }


        // 先月の給与までのレコードを取得
        $smokes = Smoke::where('user_id', $id)->where('started_at', '>=', $pre_paydate)->get();

        return Response()->json([
            'count' => $count_hour,
            'min'   => $min,
            'hour'  => array_reverse($tmp_count_array, false),
            'over'  => $count_hour - $target_number,
            'ave'   => $ave,
            'used' => count($smokes) * $user->price
        ]);
    }
}
