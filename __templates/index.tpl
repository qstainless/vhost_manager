<!doctype html>
<html lang="en-US">
<head>
    <title>@SiteUrl@</title>
</head>
<body style="font-family: monospace;">
    <p>Your site <span style="color:green">@SiteUrl@</span> is ready!</p>

    <p>The Document root is <span style="color:green"><?= $_SERVER['DOCUMENT_ROOT'] ?></span> </p>
    <p>The current PHP version is <span style="color:green"><?= PHP_VERSION ?></span>.</p>

    <p>Click <a href="info.php">here</a> to view your phpinfo().</p>
</body>
</html>
