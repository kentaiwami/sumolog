<?php

$environment = env('PUSH_ENVIRONMENT');
$certificate = env('PUSH_CERTIFICATE');
$passPhrase = env('PUSH_PASSPHRASE');

return array(
    'appNameIOS'     => array(
        'environment' =>$environment,
        'certificate' =>$certificate,
        'passPhrase'  =>$passPhrase,
        'service'     =>'apns'
    )
);