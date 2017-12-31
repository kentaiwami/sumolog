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

//  Get user data
Route::get('user/{id}', 'APIUserController@show');


//  Create smoke
Route::post('smoke', 'APISmokeController@store');

//  Update end smoke time
Route::put('smoke/{id}', 'APISmokeController@update');

// Update smoke data
Route::patch('smoke/{id}', 'APISmokeController@update');

//  Get user's smoke overview data
Route::get('smoke/overview/user/{id}', 'APISmokeController@show');

// Get user's smoke detail data
Route::get('smoke/detail/user/{id}', 'APISmokeController@show');

