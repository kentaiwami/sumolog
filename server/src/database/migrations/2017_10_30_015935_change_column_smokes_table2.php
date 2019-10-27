<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class ChangeColumnSmokesTable2 extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('smokes', function (Blueprint $table) {
            $table->dateTime('ended_at')->change();
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
            $table->dateTime('ended_at')->nullable()->change();
        });
    }
}
