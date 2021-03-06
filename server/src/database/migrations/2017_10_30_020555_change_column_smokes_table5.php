<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class ChangeColumnSmokesTable5 extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('smokes', function (Blueprint $table) {
            DB::statement('ALTER TABLE `smokes` MODIFY `ended_at` DATETIME NOT NULL;');
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
            DB::statement('ALTER TABLE `smokes` MODIFY `ended_at` DATE NOT NULL;');
        });
    }
}
