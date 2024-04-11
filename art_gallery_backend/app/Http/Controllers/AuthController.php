<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Models\User;

class AuthController extends Controller
{
    
    public function __construct()
    {
        $this->middleware('auth:api', ['except' => ['login','register']]);
    }

   
    public function login()
    {
        $credentials = request(['email', 'password']);
        

        if (! $token = auth()->attempt($credentials)) {
            return response()->json(['error' => $credentials ], 401);
        }

        return $this->respondWithToken($token);
    }


    public function register()
    {
        try {
            $credentials = request(['name', 'email', 'password']);
            $credentials['password'] = bcrypt($credentials['password']);
            User::create($credentials);

            return response()->json(['message' => 'User registered successfully'], 201);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Registration failed. Please try again.'], 500);
    }
    }



    public function me()
    {
        return response()->json(auth()->user());
    }


    public function logout()
    {
        auth()->logout();

        return response()->json(['message' => 'Successfully logged out']);
    }


    public function refresh()
    {
        return $this->respondWithToken(auth()->refresh());
    }


    protected function respondWithToken($token)
    {
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth()->factory()->getTTL() * 60,
            'user' => auth()->user()
        ]);
    }
}