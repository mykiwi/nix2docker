<?php
echo "<h1>👋 Hello from PHP 🐘</h1>";

if (file_exists($autoload = __DIR__ . '/../vendor/autoload.php')) {
    require $autoload;
    dump($_SERVER);
} else {
    echo "No PHP deps found :(";
}
echo '<hr>';
phpinfo();
