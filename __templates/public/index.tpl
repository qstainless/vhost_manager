<!doctype html>
<html lang="en-US">

<head>
    <title>@SiteUrl@</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.css">
    <link rel="stylesheet" href="assets/css/style.css">
</head>

<body style="font-family: monospace;">
    <p>Your site <span class="green">@SiteUrl@</span> is ready!</p>

    <p>The Document root is <span class="green"><?= $_SERVER['DOCUMENT_ROOT'] ?></span></p>
    <p>The current PHP version is <span class="green"><?= PHP_VERSION ?></span>. Click <a href="info.php" class="green">here</a> to view phpinfo().</p>

    <hr>

    <p>php.ini file location:<br><span class="green"><?= php_ini_loaded_file() ?></span></p>
    <p>php.ini scanned files:<br><span class="green"><?= php_ini_scanned_files() ?></span></p>
</body>

</html>
