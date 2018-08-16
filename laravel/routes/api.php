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

Route::group(['namespace' => 'api\v1\user', 'prefix' => '{API1}'], function(){
    Route::put('token', 'APITokenController@update');

    Route::post('user', 'APIUserController@store');
    Route::get('user/{id}', 'APIUserController@show');
    Route::put('user/{id}', 'APIUserController@update');
});


Route::group(['namespace' => 'api\v1\smoke\store', 'prefix' => '{API1}'], function(){
    Route::post('smoke', 'APIStoreSmokeController@store');
    Route::post('smoke/some', 'APIStoreSomeSmokeController@store');
});


Route::group(['namespace' => 'api\v1\smoke\show', 'prefix' => '{API1}'], function(){
    Route::get('smoke/24hour/user/{id}', 'APIShow24hourSmokeController@show');
    Route::get('smoke/overview/user/{id}', 'APIShowOverViewSmokeController@show');
});


Route::group(['namespace' => 'api\v1\smoke\destroy', 'prefix' => '{API1}'], function(){
    Route::delete('smoke/{smoke_id}/user/{user_id}', 'APIDestroySmokeController@destroy');
});


Route::group(['namespace' => 'api\v1\smoke\update', 'prefix' => '{API1}'], function(){
    Route::put('smoke/{id}', 'APIUpdateSmokeController@update');
    Route::patch('smoke/{id}', 'APIUpdateAllSmokeController@update');
});