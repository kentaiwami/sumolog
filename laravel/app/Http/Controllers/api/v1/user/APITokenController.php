<?php

namespace App\Http\Controllers\api\v1\user;

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
            'uuid'  => 'bail|required|string|max:191',
            'token' => 'bail|nullable|string|max:191',
        ];

        $validator = Validator::make($request->all(), $validator_array);

        if($validator->fails())
            return Response()->json($validator->errors());

        $user = User::where('uuid', $request->get('uuid'))->firstOrFail();
        $user->token = $request->get('token');
        $user->save();

        return Response()->json($user);
    }
}
