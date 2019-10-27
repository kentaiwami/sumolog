<?php
namespace App\Observers;

use App\User;

class UserObserver
{
    
    /**
     * Listen to the User creating event.
     *
     * @param  User  $User
     * @return void
     */
    public function creating(User $User)
    {
        //code...
    }

     /**
     * Listen to the User created event.
     *
     * @param  User  $User
     * @return void
     */
    public function created(User $User)
    {
        //code...
    }

    /**
     * Listen to the User updating event.
     *
     * @param  User  $User
     * @return void
     */
    public function updating(User $User)
    {
        //code...
    }

    /**
     * Listen to the User updated event.
     *
     * @param  User  $User
     * @return void
     */
    public function updated(User $User)
    {
        //code...
    }

    /**
     * Listen to the User saving event.
     *
     * @param  User  $User
     * @return void
     */
    public function saving(User $User)
    {
        //code...
    }

    /**
     * Listen to the User saved event.
     *
     * @param  User  $User
     * @return void
     */
    public function saved(User $User)
    {
        //code...
    }

    /**
     * Listen to the User deleting event.
     *
     * @param  User  $User
     * @return void
     */
    public function deleting(User $User)
    {
        //code...
    }

    /**
     * Listen to the User deleted event.
     *
     * @param  User  $User
     * @return void
     */
    public function deleted(User $User)
    {
        //code...
    }

    /**
     * Listen to the User restoring event.
     *
     * @param  User  $User
     * @return void
     */
    public function restoring(User $User)
    {
        //code...
    }

    /**
     * Listen to the User restored event.
     *
     * @param  User  $User
     * @return void
     */
    public function restored(User $User)
    {
        //code...
    }
}