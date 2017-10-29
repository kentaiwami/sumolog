<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class ChangeColumnSmokesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('smokes', function (Blueprint $table) {
            $table->dropColumn(['started_at', 'ended_at']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('smokes', function (Blueprint $table) {
            $table->dateTime('started_at');
            $table->dateTime('ended_at');
        });
    }
}
