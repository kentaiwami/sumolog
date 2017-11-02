<?php

namespace App\Http\Controllers;

use App\Smoke;
use App\User;
use Illuminate\Http\Request;
use Validator;

class APISmokeController extends Controller
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
            'uuid' => 'bail|required|string|max:191',
        ]);

        if($validator->fails()){
            return Response()->json($validator->errors());
        }else {
            $user = User::where('uuid', $request->get('uuid'))->firstOrFail();

            $new_smoke = new Smoke;
            $new_smoke->user_id = $user->id;
            $new_smoke->save();

            return Response()->json([
                'uuid'      => $request->get('uuid'),
                'smoke_id'  => $new_smoke->id
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
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $validator = Validator::make(['id'=>$id], [
            'id' => 'bail|required|string'
        ]);

        if ($validator->fails()) {
            return Response()->json($validator->errors());
        }

        $smoke = Smoke::where('id', $id)->firstOrFail();
        $smoke->ended_at = $date = date('Y-m-d H:i:s');

        $smoke->save();

        return Response()->json([
            'smoke_id'      => $smoke->id,
            'started_at'    => $smoke->started_at,
            'ended_at'      => $smoke->ended_at,
        ]);
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
