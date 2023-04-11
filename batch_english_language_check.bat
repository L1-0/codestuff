wmic os get locale | findstr /C:"0409" /C:"0809" >nul 2>&1 || echo.System language is not English.
