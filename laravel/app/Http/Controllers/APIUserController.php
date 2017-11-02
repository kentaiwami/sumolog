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
     * Store a newly created resource in storage.
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

            return Response()->json(['uuid' => $request->get('uuid')]);
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
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $uuid
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $uuid)
    {
        $validator = Validator::make(['uuid'=>$uuid], [
            'uuid' => 'bail|required|string|max:191'
        ]);

        if ($validator->fails()) {
            return Response()->json($validator->errors());
        }else {
            $user = User::where('uuid', $uuid)->firstOrFail();

            if($user->is_active) {
                $user->is_active = false;
            }else {
                $user->is_active = true;
            }

            $user->save();

            return Response()->json(['is_active' => $user->is_active]);
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
