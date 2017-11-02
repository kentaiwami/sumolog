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
            'payday'            => 'bail|required|string|max:2',
            'price'             => 'bail|required|string|max:191',
            'target_number'     => 'bail|required|string|max:191',
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }else {
            $new_user = new User;
            $new_user->uuid = $request->get('uuid');
            $new_user->payday = $request->get('payday');
            $new_user->price = $request->get('price');
            $new_user->target_number = $request->get('target_number');
            $new_user->save();

            return Response()->json([
                'uuid' => $request->get('uuid'),
                'id'   => $new_user->id
            ]);
        }
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Change user is_active status.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        $user = User::where('id', $id)->firstOrFail();

        if($user->is_active) {
            $user->is_active = false;
        }else {
            $user->is_active = true;
        }

        $user->save();

        return Response()->json(['is_active' => $user->is_active]);
    }

    /**
     * Update a user settings.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'uuid'              => 'bail|required|string|max:191',
            'payday'            => 'bail|required|string|max:2',
            'price'             => 'bail|required|string|max:191',
            'target_number'     => 'bail|required|string|max:191',
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }else {
            $user = User::where('uuid', $request->uuid)->firstOrFail();
            $user->uuid = $request->get('uuid');
            $user->payday = $request->get('payday');
            $user->price = $request->get('price');
            $user->target_number = $request->get('target_number');
            $user->save();

            return Response()->json(['uuid' => $request->get('uuid')]);
        }
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
