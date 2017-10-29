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
            $table->timestamp('started_at')->useCurrent();
            $table->timestamp('ended_at')->useCurrent();
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
            $table->dropColumn(['started_at', 'ended_at']);
        });
    }
}
