<?php

namespace App\Http\Controllers\api\v1\user;

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
            'price'             => 'bail|required|integer|max:9999',
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
        $user = User::where('id', $id)->firstOrFail();

        return Response()->json([
            'uuid'           => $user->uuid,
            'id'             => $user->id,
            'payday'         => $user->payday,
            'price'          => $user->price,
            'target_number'  => $user->target_number,
            'address'        => $user->address,
        ]);
    }

    /**
     * Update a user settings.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param   string  $v
     * @param   string     $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $v, $id)
    {
        $validator_array = [
            'uuid'              => 'bail|required|regex:/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/',
            'payday'            => 'bail|required|integer|min:1|max:31',
            'price'             => 'bail|required|integer|max:9999',
            'target_number'     => 'bail|required|integer|max:9999',
            'address'           => 'bail|nullable|ip',
        ];

        $validator = Validator::make($request->all(), $validator_array);

        if($validator->fails())
            return Response()->json($validator->errors());

        $user = User::where('uuid', $request->get('uuid'))->firstOrFail();

        if ($user->id != $id)
            return Response('', 404);

        // Update user profile
        $user->payday = $request->get('payday');
        $user->price = $request->get('price');
        $user->target_number = $request->get('target_number');
        $user->address = $request->get('address');
        $user->save();

        return Response()->json($user);
    }
}
