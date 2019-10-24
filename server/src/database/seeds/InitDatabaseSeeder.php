<?php
use Illuminate\Database\Seeder;
class InitDatabaseSeeder extends Seeder {
    public function run()
    {
        $path = 'database/sql/01_admin_menu.sql';
        DB::unprepared(file_get_contents($path));

        $path = 'database/sql/02_users.sql';
        DB::unprepared(file_get_contents($path));

        $path = 'database/sql/03_smokes.sql';
        DB::unprepared(file_get_contents($path));
    }
}
