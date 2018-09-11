<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use Serverfireteam\Panel\ObservantTrait;

/**
 * App\Smoke
 *
 * @property int $id
 * @property int $user_id
 * @property string $started_at
 * @property string|null $ended_at
 * @property-read \App\User $user
 * @method static \Illuminate\Database\Eloquent\Builder|\App\Smoke whereEndedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|\App\Smoke whereId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|\App\Smoke whereStartedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|\App\Smoke whereUserId($value)
 * @mixin \Eloquent
 */
class Smoke extends Model {
    protected $table = 'smokes';
    public $timestamps = false;

    public function user()
    {
        return $this->belongsTo('App\User');
    }

}
