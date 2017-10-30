<?php 

namespace App\Http\Controllers;

use App\Http\Requests;
use App\Http\Controllers\Controller;
use \Serverfireteam\Panel\CrudController;

use Illuminate\Http\Request;

class UserController extends CrudController{

    public function all($entity){
        parent::all($entity);
			$this->filter = \DataFilter::source(new \App\User());
			$this->filter->add('uuid', 'UUID', 'text');
            $this->filter->add('created_at', 'Created_at', 'text');
            $this->filter->add('updated_at', 'Updated_at', 'text');
			$this->filter->submit('search');
			$this->filter->reset('reset');
			$this->filter->build();

			$this->grid = \DataGrid::source($this->filter);
			$this->grid->add('uuid', 'UUID');
			$this->grid->add('created_at', 'Created_at', true);
            $this->grid->add('updated_at', 'Updated_at', true);
			$this->addStylesToGrid();


                 
        return $this->returnView();
    }
    
    public function  edit($entity){
        
        parent::edit($entity);

			$this->edit = \DataEdit::source(new \App\User());
			$this->edit->label('Edit User');

			$this->edit->add('uuid', 'UUID', 'text')->rule('required');

        return $this->returnEditView();
    }    
}
