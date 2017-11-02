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

//  Create user
Route::post('user', 'APIUserController@store');

//  Update user profile
Route::put('user/{id}', 'APIUserController@update');

//  Update user active status
Route::patch('user/{id}', 'APIUserController@update');

Route::post('smoke', 'APISmokeController@store');
Route::put('smoke/{id}', 'APISmokeController@update');