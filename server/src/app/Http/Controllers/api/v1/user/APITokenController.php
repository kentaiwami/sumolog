<?php

namespace App\Http\Controllers\api\v1\user;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use App\Http\Controllers\Controller;
use App\User;
use Illuminate\Http\Request;
use Validator;

class APITokenController extends Controller
{
    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $validator_array = [
            'uuid'  => 'bail|required|regex:/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/',
            'token' => 'bail|required|regex:/^[0-9a-f]{64}$/',
        ];

        $validator = Validator::make($request->all(), $validator_array);

        if($validator->fails())
            return Response()->json($validator->errors());

        try {
            $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        } catch (ModelNotFoundException $e) {
            abort(404, '指定したユーザは存在しません');
        }

        $user->token = $request->get('token');
        $user->save();

        return Response()->json([
            'uuid'                  => $user->uuid,
            'id'                    => $user->id,
            'payday'                => $user->payday,
            'price'                 => $user->price,
            'target_number'         => $user->target_number,
            'address'               => $user->address,
            'token'                 => $user->token,
            'is_add_average_auto'   => (bool)$user->is_add_average_auto
        ]);
    }
}
