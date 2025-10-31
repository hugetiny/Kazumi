# 简单批量替换 - 只替换 provider 名称，不改变使用方式

$rootPath = "c:\Users\huget\StudioProjects\Kazumi\lib"

# 简单的名称替换
$simpleReplacements = @{
    'playerControllerProvider' = 'playerProvider'
}

# 获取所有 dart 文件
$dartFiles = Get-ChildItem -Path $rootPath -Filter "*.dart" -Recurse

$totalFiles = 0
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileChanged = $false

    foreach ($old in $simpleReplacements.Keys) {
        $new = $simpleReplacements[$old]
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
