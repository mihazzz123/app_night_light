# flutter-check.ps1 — универсальный помощник для Flutter + Gradle

$gradleVersion = "8.11.1"
$gradleDistName = "gradle-$gradleVersion-all"
$gradleDistUrl = "https://services.gradle.org/distributions/$gradleDistName.zip"
$gradleUserDir = "$env:USERPROFILE\.gradle\wrapper\dists\$gradleDistName"
$gradleTargetDir = "$gradleUserDir\manual"
$gradleZipPath = "$gradleTargetDir\$gradleDistName.zip"
$projectRoot = "C:\MyProjects\app_night_light"

Write-Host "`n🧹 Завершаем процессы, которые могут блокировать Gradle..."
$processes = @("java.exe", "gradle.exe", "adb.exe", "studio64.exe")
foreach ($p in $processes) {
    try {
        taskkill /F /IM $p > $null 2>&1
    } catch {}
}

Write-Host "`n🧪 Проверка Java..."
$javaVersion = & java -version 2>&1 | Select-String "version"
if ($javaVersion -match '"(\d+)\.') {
    $major = [int]$matches[1]
    if ($major -lt 17) {
        Write-Host "❌ Установлена Java $major — требуется Java 17+. Обнови JDK." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "✅ Java $major установлена."
    }
} else {
    Write-Host "❌ Java не найдена. Установи JDK 17+." -ForegroundColor Red
    exit 1
}

Write-Host "`n📦 Проверка Gradle $gradleVersion..."
$gradleBinPath = "$gradleTargetDir\gradle-$gradleVersion\bin"
if (!(Test-Path $gradleBinPath)) {
    Write-Host "📥 Скачиваем и распаковываем Gradle..."
    New-Item -ItemType Directory -Force -Path $gradleTargetDir | Out-Null
    Invoke-WebRequest -Uri $gradleDistUrl -OutFile $gradleZipPath
    Expand-Archive -Path $gradleZipPath -DestinationPath $gradleTargetDir -Force
    if (Test-Path $gradleBinPath) {
        Write-Host "✅ Gradle установлен успешно."
    } else {
        Write-Host "❌ Ошибка: Gradle не распакован корректно." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Gradle уже распакован."
}

Write-Host "`n📱 Проверка подключённых устройств..."
$devices = flutter devices
if ($devices -match "No devices") {
    Write-Host "❌ Устройства не найдены. Подключи Android-устройство с включённой отладкой." -ForegroundColor Red
    exit 1
} elseif ($devices -match "not authorized") {
    Write-Host "❗ Устройство подключено, но не авторизовано. Разблокируй экран и подтверди отладку." -ForegroundColor Yellow
} else {
    Write-Host "✅ Устройство готово."
}

Write-Host "`n🧹 Очистка Flutter-проекта..."
Set-Location $projectRoot
flutter clean
flutter pub get

Write-Host "`n🚀 Запуск Flutter-приложения..."
flutter run
