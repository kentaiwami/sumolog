<?php

namespace App\Http\Controllers;

use App\User;
use Illuminate\Http\Request;
use Validator;

class APIUserController extends Controller
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
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $user = User::where('id', $id)->firstOrFail();

        return Response()->json([
            'uuid'          => $user->uuid,
            'id'            => $user->id,
            'payday'        => $user->payday,
            'price'         => $user->price,
            'target_number' => $user->target_number,
            'address'       => $user->address
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
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        /* Check validation */
        if ($request->method() == 'PUT') {
            $validator = Validator::make($request->all(), [
                'uuid' => 'bail|required|string|max:191',
                'payday' => 'bail|required|string|max:2',
                'price' => 'bail|required|string|max:191',
                'target_number' => 'bail|required|string|max:191',
            ]);

            if($validator->fails())
                return Response()->json($validator->errors());

        }else if ($request->method() == 'PATCH') {
            $validator = Validator::make($request->all(), [
                'uuid' => 'bail|required|string|max:191'
            ]);

            if($validator->fails())
                return Response()->json($validator->errors());
        }


        /* Check user id */
        $user = User::where('uuid', $request->uuid)->firstOrFail();

        if ($user->id != $id)
            return Response('', 404);


        /* Save user data */
        if ($request->method() == 'PUT') {
            $user->payday = $request->get('payday');
            $user->price = $request->get('price');
            $user->target_number = $request->get('target_number');

        }else if ($request->method() == 'PATCH') {
            if ($user->is_active)
                $user->is_active = false;
            else
                $user->is_active = true;

        }else {
            return Response('', 405);
        }

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
