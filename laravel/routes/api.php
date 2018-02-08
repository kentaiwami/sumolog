<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::pattern('API1', 'v1');
Route::group(['namespace' => 'api\v1', 'prefix' => '{API1}'], function(){
    //  Create user
    Route::post('user', 'APIUserController@store');

    // Register token
    Route::put('user/token', 'APIUserController@update');

    //  Update user profile
    Route::put('user/{id}', 'APIUserController@update');

    //  Get user data
    Route::get('user/{id}', 'APIUserController@show');


    //  Create smoke
    Route::post('smoke', 'APISmokeController@store');

    //  Create smoke all data
    Route::post('smoke/all', 'APISmokeController@store');


    //  Update end smoke time
    Route::put('smoke/{id}', 'APISmokeController@update');

    // Update smoke data
    Route::patch('smoke/{id}', 'APISmokeController@update');

    // Delete smoke data
    Route::delete('smoke/{smoke_id}/user/{user_id}', 'APISmokeController@destroy');

    //  Get user's smoke overview data
    Route::get('smoke/overview/user/{id}', 'APISmokeController@show');

    //  Get user's 24hour smoke data
    Route::get('smoke/24hour/user/{id}/{uuid}', 'APISmokeController@show');
});
