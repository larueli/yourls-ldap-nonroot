<?php
if(getenv("YOURLS_ROOT_REDIRECT_URL"))
    header( 'Location: '.getenv("YOURLS_ROOT_REDIRECT_URL") );