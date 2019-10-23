<?php

namespace App\Http\Controllers\api\v1\smoke\destroy;

use App\Http\Controllers\Controller;
use App\Smoke;

class APIDestroySmokeController extends Controller
{
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
