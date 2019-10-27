<?php

namespace App\Http\Controllers\api\v1\smoke\update;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use App\Http\Controllers\Controller;
use App\Smoke;
use App\User;
use Illuminate\Http\Request;
use Validator;

class APIUpdateAllSmokeController extends Controller
{
    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @param  string $v
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $v, $id)
    {
        $validator_array = [
            'uuid' => 'bail|required|regex:/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/',
            'started_at' => 'bail|required|regex:/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/',
            'ended_at' => 'bail|required|regex:/^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$/'
        ];

        $validator = Validator::make($request->all(), $validator_array);

        if ($validator->fails()) {
            return Response()->json($validator->errors());
        }

        try {
            $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        } catch (ModelNotFoundException $e) {
            abort(404, '指定したユーザは存在しません');
        }

        try {
            $smoke = Smoke::where('id', $id)->firstOrFail();
        } catch (ModelNotFoundException $e) {
            abort(404, '指定した喫煙情報は存在しません');
        }

        if ($user->id != $smoke->user_id) {
            abort(403, '権限がありません');
        }

        $smoke->started_at = $request->get('started_at');
        $smoke->ended_at = $request->get('ended_at');
        $smoke->save();

        return Response()->json([
            'smoke_id'      => $smoke->id,
            'started_at'    => $smoke->started_at,
            'ended_at'      => $smoke->ended_at,
        ]);
    }
}
