<#
.SYNOPSIS
    Sets the Windows 11 input list to ENG (US keyboard) + 繁體中文.

.DESCRIPTION
    Per-user, no admin required. Replaces the current language list with
    en-US (ENG) first, then zh-Hant-TW with the chosen Traditional Chinese IME.

.PARAMETER ChineseIME
    Bopomofo (default), QuickCJ, or ChangJie.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1 | iex"

.EXAMPLE
    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1))) -ChineseIME ChangJie
#>
[CmdletBinding()]
param(
    [ValidateSet('Bopomofo', 'QuickCJ', 'ChangJie')]
    [string]$ChineseIME = 'Bopomofo'
)

$ErrorActionPreference = 'Stop'

$imeTip = @{
    Bopomofo = '0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{B2F9C502-1742-11D4-9790-0080C882687E}'
    QuickCJ  = '0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{6024B45F-5C54-11D4-B921-0080C882687E}'
    ChangJie = '0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{4BDF9F03-C7D3-11D4-B2AB-0080C882687E}'
}[$ChineseIME]

function Show-List($label, $color) {
    Write-Host "`n$label" -ForegroundColor $color
    Get-WinUserLanguageList |
        Format-Table LanguageTag, @{ n = 'InputMethods'; e = { $_.InputMethodTips -join ', ' } } |
        Out-Host
}

Write-Host 'fast_set_input  -  ENG + 繁體中文' -ForegroundColor Cyan
Show-List 'Before:' DarkGray

$list = New-WinUserLanguageList en-US
$list[0].InputMethodTips.Clear()
$list[0].InputMethodTips.Add('0409:00000409')   # US keyboard = ENG

$list.Add('zh-Hant-TW')
$list[1].InputMethodTips.Clear()
$list[1].InputMethodTips.Add($imeTip)

Set-WinUserLanguageList $list -Force

Show-List "After ($ChineseIME):" Green

# ponytail: self-check. Fails loudly if the API silently ignored us.
$now = (Get-WinUserLanguageList).LanguageTag
if ($now -notcontains 'en-US' -or $now -notcontains 'zh-Hant-TW') {
    throw "Language list did not apply (got: $($now -join ', ')). If zh-Hant-TW is missing, run as admin: Install-Language zh-Hant-TW"
}

Write-Host 'Done. Win+Space to switch. Sign out/in if the taskbar indicator lags.' -ForegroundColor Cyan
