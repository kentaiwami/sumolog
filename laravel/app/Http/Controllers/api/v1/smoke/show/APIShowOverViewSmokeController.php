<?php

namespace App\Http\Controllers\api\v1\smoke\show;

use App\User;
use App\Smoke;
use App\Http\Controllers\Controller;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;

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
        $prev_24hour = date('Y-m-d H:i:s', strtotime('- 24 hour'));

        /* 対象ユーザの24時間以内の喫煙データを取得 */
        $smokes_24hour = Smoke::where('user_id', $id)
            ->whereBetween('started_at', [$prev_24hour, $now])
            ->orderBy('started_at', 'desc')
            ->get();

        $smokes_24hour_count = count($smokes_24hour);
        $min = $this->get_min($id, $now);
        $count_by_hour = $this->get_count_by_hour($smokes_24hour);
        $user_payday = date('Y') . '-' . date('m') . '-'. $user->payday;
        $payday = $this->get_payday($user_payday);
        $ave = $this->get_ave_one_smoke($smokes_24hour);

        $smokes_prev_month = Smoke::where('user_id', $id)->where('started_at', '>=', $payday)->get();

        return Response()->json([
            'count' => $smokes_24hour_count,
            'min'   => $min,
            'hour'  => array_reverse($count_by_hour, false),
            'over'  => $smokes_24hour_count - $user->target_number,
            'ave'   => $ave,
            'used' => count($smokes_prev_month) * $user->price
        ]);
    }


    /**
     * 1本の所要時間をカウント
     * @param Collection $smokes_24hour
     * @return float
     */
    public function get_ave_one_smoke($smokes_24hour) {
        $difference_sum = 0.0;
        foreach ($smokes_24hour as $smoke_obj) {
            $started_at = new \DateTime($smoke_obj->started_at);
            $ended_at = new \DateTime($smoke_obj->ended_at);
            $difference_sum += ($ended_at->getTimestamp() - $started_at->getTimestamp())/60;
        }

        if (count($smokes_24hour) == 0) {
            return 0.0;
        }else {
            return round($difference_sum / count($smokes_24hour), 1, PHP_ROUND_HALF_UP);
        }
    }


    /**
     * 時間別で集計
     * @param Collection $smokes_24hour
     * @return array
     */
    public function get_count_by_hour($smokes_24hour) {
        $count_by_hour_from_groupBy = [];
        $count_by_hour = [];

        if (count($smokes_24hour) != 0) {
            $hour_smokes = $smokes_24hour->groupBy(function ($date) {
                return Carbon::parse($date->started_at)->format('H');
            });

            foreach ($hour_smokes as $key => $value ) {
                $count_by_hour_from_groupBy[] = array('hour' => $key, 'count' => count($value));
            }
        }

        $offset = 0;
        while ($offset != 25) {
            $hour = date('H', strtotime('- '.$offset.' hour'));
            $offset += 1;
            $is_hit = false;

            foreach ($count_by_hour_from_groupBy as $obj) {
                if ($obj['hour'] == $hour) {
                    $count_by_hour[] = array('hour' => $hour, 'count' => $obj['count']);
                    $is_hit = true;
                    break;
                }
            }

            if (!$is_hit) {
                $count_by_hour[] = array('hour' => $hour, 'count' => 0);
            }
        }

        return $count_by_hour;
    }


    /**
     * 直近の喫煙が何分前か計算
     * @param string $id
     * @param string $now
     * @return float
     */
    public function get_min($id, $now) {
        $latest = Smoke::where('user_id', $id)->orderBy('started_at', 'DESC')->first()->started_at;

        $latest_datetime = new \DateTime($latest);
        $now_datetime = new \DateTime($now);
        return round(($now_datetime->getTimestamp() - $latest_datetime->getTimestamp())/60, 0, PHP_ROUND_HALF_UP);
    }


    /**
     * 今月の給与日を超えていた場合はその日付を、超えていない場合は先月の日付を返す
     * @param $user_payday
     * @return false|string
     */
    public function get_payday($user_payday) {
        if (date('Y-m-d', strtotime($user_payday)) <= date('Y-m-d')){
            return date('Y-m-d', strtotime($user_payday));
        }
        else{
            return date('Y-m-d', strtotime($user_payday .'-1 month'));
        }
    }
}
