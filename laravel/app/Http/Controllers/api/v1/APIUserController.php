<?php

namespace App\Http\Controllers\api\v1;

use App\User;
use Illuminate\Http\Request;
use Validator;
use App\Http\Controllers\Controller;

class APIUserController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return Response('', 404);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        return Response('', 404);
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
     *
     * @return \Illuminate\Http\Response
     */
    public function edit()
    {
        return Response('', 404);
    }

    /**
     * Update a user settings.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param   string  $v
     * @param   string     $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $v, $id="")
    {
        $current_url = url()->current();
        $pattern_update_profile = "#api/".$v."/user/[0-9]+#";
        $pattern_register_token = "#api/".$v."/user/token#";


        if (preg_match($pattern_update_profile, $current_url)) {
            $validator_array = [
                'uuid'              => 'bail|required|string|max:191',
                'payday'            => 'bail|required|integer|min:1|max:31',
                'price'             => 'bail|required|integer|max:9999',
                'target_number'     => 'bail|required|integer|max:9999',
                'address'           => 'bail|nullable|ip',
            ];
        }else if (preg_match($pattern_register_token, $current_url)) {
            $validator_array = [
                'uuid'  => 'bail|required|string|max:191',
                'token' => 'bail|nullable|string|max:191',
            ];
        }else {
            return Response('', 404);
        }

        $validator = Validator::make($request->all(), $validator_array);

        if($validator->fails())
            return Response()->json($validator->errors());


        /* Check user id */
        $user = User::where('uuid', $request->uuid)->firstOrFail();

        // idが指定されている場合にidとuuidで取得したidを照合
        if ($id != "" and $user->id != $id)
            return Response('', 404);


        if (preg_match($pattern_update_profile, $current_url)) {
            // Update user profile
            $user->payday = $request->get('payday');
            $user->price = $request->get('price');
            $user->target_number = $request->get('target_number');
            $user->address = $request->get('address');
        }else if (preg_match($pattern_register_token, $current_url)) {
            // update user token
            $user->token = $request->get('token');
        }

        $user->save();

        return Response()->json($user);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @return \Illuminate\Http\Response
     */
    public function destroy()
    {
        return Response('', 404);
    }
}
