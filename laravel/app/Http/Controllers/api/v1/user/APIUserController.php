<?php

namespace App\Http\Controllers\api\v1\user;

use Illuminate\Database\Eloquent\ModelNotFoundException;
use App\User;
use Illuminate\Http\Request;
use Validator;
use App\Http\Controllers\Controller;

class APIUserController extends Controller
{
    /**
     * Store a new user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'uuid'              => 'bail|required|regex:/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/|unique:users',
            'payday'            => 'bail|required|integer|min:1|max:31',
            'price'             => 'bail|required|numeric|min:1|max:9999',
            'target_number'     => 'bail|required|integer|max:9999',
            'address'           => 'bail|nullable|ip',
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }

        $new_user = new User;
        $new_user->uuid = $request->get('uuid');
        $new_user->payday = $request->get('payday');
        $new_user->price = $request->get('price');
        $new_user->target_number = $request->get('target_number');
        $new_user->address = $request->get('address');
        $new_user->save();

        return Response()->json([
            'uuid' => $request->get('uuid'),
            'id'   => $new_user->id
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  string   $v
     * @param  int      $id
     * @return \Illuminate\Http\Response
     */
    public function show($v, $id)
    {
        try {
            $user = User::where('id', $id)->firstOrFail();
        } catch (ModelNotFoundException $e) {
            abort(404, '指定したユーザは存在しません');
        }

        return Response()->json([
            'uuid'           => $user->uuid,
            'id'             => $user->id,
            'payday'         => $user->payday,
            'price'          => $user->price,
            'target_number'  => $user->target_number,
            'address'        => $user->address,
        ]);
    }
}
