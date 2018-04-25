<?php

namespace App\Http\Controllers\api\v1\smoke\update;

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
            'uuid' => 'bail|required|string|max:191',
            'started_at' => 'bail|required|string|max:191',
            'ended_at' => 'bail|required|string|max:191'
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
