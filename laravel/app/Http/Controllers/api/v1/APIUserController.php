<?php

namespace App\Http\Controllers\api\v1;

use App\User;
use Illuminate\Http\Request;
use Validator;

class APIUserController extends \App\Http\Controllers\Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a new user.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'uuid'              => 'bail|required|string|max:191|unique:users',
            'payday'            => 'bail|required|integer|min:1|max:31',
            'price'             => 'bail|required|integer|max:9999',
            'target_number'     => 'bail|required|integer|max:9999',
            'address'           => 'bail|required|ip',
            'one_box_number'    => 'bail|required|integer|max:9999'
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
        $new_user->one_box_number = $request->get('one_box_number');
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
            'one_box_number' => $user->one_box_number
        ]);
    }

    /**
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update a user settings.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param   string  $v
     * @param   int     $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $v, $id)
    {
        /* Check validation */
        $validator = Validator::make($request->all(), [
            'uuid' => 'bail|required|string|max:191',
            'payday'            => 'bail|required|integer|min:1|max:31',
            'price'             => 'bail|required|integer|max:9999',
            'target_number'     => 'bail|required|integer|max:9999',
            'address'           => 'bail|required|ip',
            'one_box_number'    => 'bail|required|integer|max:9999'
        ]);

        if($validator->fails())
            return Response()->json($validator->errors());


        /* Check user id */
        $user = User::where('uuid', $request->uuid)->firstOrFail();

        if ($user->id != $id)
            return Response('', 404);


        /* Save user data */
        $user->payday = $request->get('payday');
        $user->price = $request->get('price');
        $user->target_number = $request->get('target_number');
        $user->address = $request->get('address');
        $user->one_box_number = $request->get('one_box_number');

        $user->save();

        return Response()->json($user);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
