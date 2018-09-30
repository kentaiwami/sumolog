<?php

namespace App\Admin\Controllers;

use App\User;
use App\Http\Controllers\Controller;
use Encore\Admin\Controllers\HasResourceActions;
use Encore\Admin\Form;
use Encore\Admin\Grid;
use Encore\Admin\Layout\Content;
use Encore\Admin\Show;

class AdminUserController extends Controller
{
    use HasResourceActions;

    /**
     * Index interface.
     *
     * @param Content $content
     * @return Content
     */
    public function index(Content $content)
    {
        return $content
            ->header('Index')
            ->description('description')
            ->body($this->grid());
    }

    /**
     * Show interface.
     *
     * @param mixed $id
     * @param Content $content
     * @return Content
     */
    public function show($id, Content $content)
    {
        return $content
            ->header('Detail')
            ->description('description')
            ->body($this->detail($id));
    }

    /**
     * Edit interface.
     *
     * @param mixed $id
     * @param Content $content
     * @return Content
     */
    public function edit($id, Content $content)
    {
        return $content
            ->header('Edit')
            ->description('description')
            ->body($this->form()->edit($id));
    }

    /**
     * Create interface.
     *
     * @param Content $content
     * @return Content
     */
    public function create(Content $content)
    {
        return $content
            ->header('Create')
            ->description('description')
            ->body($this->form());
    }

    /**
     * Make a grid builder.
     *
     * @return Grid
     */
    protected function grid()
    {
        $grid = new Grid(new User);

        $grid->id('ID');
        $grid->uuid('UUID');
        $grid->created_at('Created at');
        $grid->updated_at('Updated at');
        $grid->payday('Payday');
        $grid->price('Price');
        $grid->target_number('Target number');
        $grid->address('Address');
        $grid->token('Token');

        return $grid;
    }

    /**
     * Make a show builder.
     *
     * @param mixed $id
     * @return Show
     */
    protected function detail($id)
    {
        $show = new Show(User::findOrFail($id));

        $show->id('ID');
        $show->uuid('UUID');
        $show->created_at('Created at');
        $show->updated_at('Updated at');
        $show->payday('Payday');
        $show->price('Price');
        $show->target_number('Target number');
        $show->address('Address');
        $show->token('Token');

        return $show;
    }

    /**
     * Make a form builder.
     *
     * @return Form
     */
    protected function form()
    {
        $uuid_regex = '/^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/';
        $token_regex = '/^[0-9a-f]{64}$/';

        $form = new Form(new User);

        $form->text('uuid', 'UUID')->rules('required|regex:'.$uuid_regex, [
            'uuid' => 'UUIDの形式が間違っています',
        ]);
        $form->number('payday', 'Payday')->rules('required|integer|min:1|max:31');
        $form->number('price', 'Price')->rules('required|integer|min:1|max:9999');
        $form->number('target_number', 'Target number')->rules('required|integer|max:9999');
        $form->text('address', 'Address')->rules('nullable|ip');
        $form->text('token', 'Token')->rules('required|regex:'.$token_regex, [
            'token' => 'Tokenの形式が間違っています',
        ]);

        return $form;
    }
}
