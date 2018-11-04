<?php

namespace App\Http\Controllers\api\v1\user;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use App\User;
use Illuminate\Http\Request;
use Validator;
use App\Http\Controllers\Controller;

class APIUserInfoController extends Controller
{
    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $v, $id)
    {
        $validator_array = [
            'uuid'              => 'bail|required|regex:/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/',
            'payday'            => 'bail|required|integer|min:1|max:31',
            'price'             => 'bail|required|numeric|min:1|max:9999',
            'target_number'     => 'bail|required|integer|max:9999',
        ];

        $validator = Validator::make($request->all(), $validator_array);

        if($validator->fails())
            return Response()->json($validator->errors());

        try {
            $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        } catch (ModelNotFoundException $e) {
            abort(404, '指定したユーザは存在しません');
        }

        if ($user->id != $id)
            return Response('', 404);

        // Update user profile
        $user->payday = $request->get('payday');
        $user->price = $request->get('price');
        $user->target_number = $request->get('target_number');
        $user->save();

        return Response()->json([
            'uuid'                  => $user->uuid,
            'id'                    => $user->id,
            'payday'                => $user->payday,
            'price'                 => $user->price,
            'target_number'         => $user->target_number,
            'address'               => $user->address,
            'is_add_average_auto'   => (bool)$user->is_add_average_auto
        ]);
    }
}
