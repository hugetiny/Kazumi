# 批量替换脚本 - 修复剩余的引用

$rootPath = "c:\Users\huget\StudioProjects\Kazumi\lib"

# 定义替换映射
$replacements = @{
    # Info UI State providers
    'fullIntroProvider' = 'infoUIProvider.select((s) => s.fullIntro)'
    'fullTagProvider' = 'infoUIProvider.select((s) => s.fullTag)'
    'showAllEpisodesProvider' = 'infoUIProvider.select((s) => s.showAllEpisodes)'

    # Player provider
    'playerControllerProvider' = 'playerProvider'

    # Plugin editor providers
    'pluginEditorUseNativePlayerProvider' = 'pluginEditorUIProvider.select((s) => s.useNativePlayer)'
    'pluginEditorUsePostProvider' = 'pluginEditorUIProvider.select((s) => s.usePost)'
    'pluginEditorUseLegacyParserProvider' = 'pluginEditorUIProvider.select((s) => s.useLegacyParser)'

    # Plugin shop providers
    'pluginShopLoadingProvider' = 'pluginShopUIProvider.select((s) => s.isLoading)'
    'pluginShopTimeoutProvider' = 'pluginShopUIProvider.select((s) => s.isTimeout)'
    'pluginShopSortByNameProvider' = 'pluginShopUIProvider.select((s) => s.sortByName)'

    # Plugin selection providers
    'pluginMultiSelectModeProvider' = 'pluginSelectionProvider.select((s) => s.multiSelectMode)'
    'pluginSelectedNamesProvider' = 'pluginSelectionProvider.select((s) => s.selectedNames)'
}

$dartFiles = Get-ChildItem -Path $rootPath -Filter "*.dart" -Recurse
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileChanged = $false

    foreach ($old in $replacements.Keys) {
        if ($content -match $old) {
            $new = $replacements[$old]
            $count = ([regex]::Matches($content, [regex]::Escape($old))).Count
            $content = $content -replace [regex]::Escape($old), $new
            $totalReplacements += $count
            $fileChanged = $true
            Write-Host "  ✓ $($file.Name): 替换 $count 处 '$old'" -ForegroundColor Green
        }
    }

    if ($fileChanged) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✅ 完成！总替换数: $totalReplacements" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
