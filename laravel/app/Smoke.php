<?php 

namespace App;

use Illuminate\Database\Eloquent\Model;
use Serverfireteam\Panel\ObservantTrait;

class Smoke extends Model {
	use ObservantTrait;
	
    protected $table = 'smokes';
    public $timestamps = false;

    public function user()
    {
        return $this->belongsTo('App\User');
    }

}
