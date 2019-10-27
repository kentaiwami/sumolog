<?php
namespace App\Observers;

use App\Smoke;

class SmokeObserver
{
    
    /**
     * Listen to the Smoke creating event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function creating(Smoke $Smoke)
    {
        //code...
    }

     /**
     * Listen to the Smoke created event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function created(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke updating event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function updating(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke updated event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function updated(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke saving event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function saving(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke saved event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function saved(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke deleting event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function deleting(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke deleted event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function deleted(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke restoring event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function restoring(Smoke $Smoke)
    {
        //code...
    }

    /**
     * Listen to the Smoke restored event.
     *
     * @param  Smoke  $Smoke
     * @return void
     */
    public function restored(Smoke $Smoke)
    {
        //code...
    }
}