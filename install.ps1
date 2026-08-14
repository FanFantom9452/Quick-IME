<#
.SYNOPSIS
    Sets the Windows 11 input list to ENG (US keyboard) + Traditional Chinese (Bopomofo).

.DESCRIPTION
    Per-user, no admin required. Replaces the current language list with
    en-US (ENG) first, then zh-Hant-TW with Microsoft Bopomofo.

    The US keyboard layout (0409:00000409) ships with every Windows SKU, so
    ENG applies even if the user has never added it. Only zh-Hant-TW needs the
    language feature installed.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/Quick-IME/main/install.ps1 | iex"
#>

# ponytail: ASCII only. Windows PowerShell 5.1 reads a BOM-less .ps1 as ANSI,
# so non-ASCII literals here show up as mojibake when run with -File.

$ErrorActionPreference = 'Stop'

$ENG      = '0409:00000409'
$BOPOMOFO = '0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{B2F9C502-1742-11D4-9790-0080C882687E}'

function Show-List($label, $color) {
    Write-Host "`n$label" -ForegroundColor $color
    Get-WinUserLanguageList |
        Format-Table LanguageTag, @{ n = 'InputMethods'; e = { $_.InputMethodTips -join ', ' } } |
        Out-Host
}

Write-Host 'Quick-IME  -  ENG + Traditional Chinese (zh-Hant-TW)' -ForegroundColor Cyan
Show-List 'Before:' DarkGray

$list = New-WinUserLanguageList en-US
$list[0].InputMethodTips.Clear()
$list[0].InputMethodTips.Add($ENG)

$list.Add('zh-Hant-TW')
$list[1].InputMethodTips.Clear()
$list[1].InputMethodTips.Add($BOPOMOFO)

Set-WinUserLanguageList $list -Force -WarningAction SilentlyContinue

Show-List 'After:' Green

# Self-check: a rejected input method leaves the language in the list with an
# empty tip list, so verify the tips landed, not just the language tags.
$now = Get-WinUserLanguageList
# Names must not collide with $ENG / $BOPOMOFO: PowerShell variable names are
# case-insensitive, so an $eng here would silently overwrite the $ENG constant.
$engEntry = $now | Where-Object LanguageTag -eq 'en-US'
$zhEntry  = $now | Where-Object LanguageTag -eq 'zh-Hant-TW'

if (-not $engEntry -or $engEntry.InputMethodTips -notcontains $ENG) {
    throw "ENG (US keyboard) did not apply. Current list: $($now.LanguageTag -join ', ')"
}
if (-not $zhEntry -or $zhEntry.InputMethodTips -notcontains $BOPOMOFO) {
    throw 'Traditional Chinese did not apply. Install the language feature as admin: Install-Language zh-Hant-TW'
}

Write-Host 'Done. Win+Space to switch. Sign out/in if the taskbar indicator lags.' -ForegroundColor Cyan
