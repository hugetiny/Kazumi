# Riverpod Provider 批量重命名脚本
# 将所有旧的 provider 名称替换为新的命名规范

$rootPath = "c:\Users\huget\StudioProjects\Kazumi\lib"

# 定义所有需要替换的 provider 名称映射
$replacements = @{
    'collectControllerProvider' = 'collectionsProvider'
    'popularControllerProvider' = 'popularProvider'
    'timelineControllerProvider' = 'timelineProvider'
    'historyControllerProvider' = 'historyProvider'
    'videoControllerProvider' = 'videoProvider'
    'searchControllerProvider' = 'searchProvider'
    'infoControllerProvider' = 'bangumiInfoProvider'
    'navigationBarControllerProvider' = 'navigationProvider'
    'pluginsControllerProvider' = 'pluginsProvider'
    'themeNotifierProvider' = 'themeProvider'
    'webDavSettingsControllerProvider' = 'webDavSettingsProvider'
}

# 获取所有 dart 文件
$dartFiles = Get-ChildItem -Path $rootPath -Filter "*.dart" -Recurse

$totalFiles = 0
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileChanged = $false

    foreach ($old in $replacements.Keys) {
        $new = $replacements[$old]
        if ($content -match $old) {
            $count = ([regex]::Matches($content, $old)).Count
            $content = $content -replace $old, $new
            $totalReplacements += $count
            $fileChanged = $true
            Write-Host "  ✓ $($file.Name): 替换 $count 处 '$old' -> '$new'"
        }
    }

    if ($fileChanged) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $totalFiles++
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✅ 完成！" -ForegroundColor Green
Write-Host "   更新文件数: $totalFiles" -ForegroundColor Cyan
Write-Host "   替换总数: $totalReplacements" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
