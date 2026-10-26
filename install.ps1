<#
.SYNOPSIS
    Adds ENG (US keyboard) and Microsoft Bopomofo to the Windows 11 input list
    without touching anything else.

.DESCRIPTION
    Per-user, no admin required. Reads the current language list and only adds
    what is missing, one input method at a time:

      - some language already has it -> nothing changes for it
      - its language is in the list without it -> it is added to that entry
      - its language is not in the list -> the language is appended at the
        end with only that input method

    ENG is the US keyboard (0409:00000409) under en-US; Bopomofo is under
    zh-Hant-TW. Language order, the display language and every other input
    method stay as they were. The US keyboard ships with every Windows SKU;
    Bopomofo needs the zh-Hant-TW language feature installed.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/Quick-IME/main/install.ps1 | iex"
#>

# ponytail: ASCII only. Windows PowerShell 5.1 reads a BOM-less .ps1 as ANSI,
# so non-ASCII literals here show up as mojibake when run with -File.

# No `exit` anywhere: under `irm | iex` it would close the user's window.

$ErrorActionPreference = 'Stop'

$ENG      = '0409:00000409'
$BOPOMOFO = '0404:{B115690A-EA02-48D5-A231-E3578D2FDF80}{B2F9C502-1742-11D4-9790-0080C882687E}'

$wanted = @(
    @{ Name = 'ENG (US keyboard)'; Tag = 'en-US';      Tip = $ENG }
    @{ Name = 'Microsoft Bopomofo'; Tag = 'zh-Hant-TW'; Tip = $BOPOMOFO }
)

function Show-List($label, $color) {
    Write-Host "`n$label" -ForegroundColor $color
    Get-WinUserLanguageList |
        Format-Table LanguageTag, @{ n = 'InputMethods'; e = { $_.InputMethodTips -join ', ' } } |
        Out-Host
}

Write-Host 'Quick-IME  -  add ENG + Microsoft Bopomofo' -ForegroundColor Cyan
Show-List 'Before:' DarkGray

$list  = Get-WinUserLanguageList
# Windows uses the first language as the display language and default input,
# so it must stay where it is.
$first = $list[0].LanguageTag

$changed = $false
foreach ($w in $wanted) {
    if ($list | Where-Object { $_.InputMethodTips -contains $w.Tip }) {
        Write-Host "$($w.Name) is already installed." -ForegroundColor DarkGray
        continue
    }
    $entry = $list | Where-Object LanguageTag -eq $w.Tag | Select-Object -First 1
    if (-not $entry) {
        $list.Add($w.Tag)
        $entry = $list[$list.Count - 1]
        $entry.InputMethodTips.Clear()
    }
    $entry.InputMethodTips.Add($w.Tip)
    $changed = $true
}

if (-not $changed) {
    Write-Host 'Nothing changed.' -ForegroundColor Cyan
}
else {
    Set-WinUserLanguageList $list -Force -WarningAction SilentlyContinue

    Show-List 'After:' Green

    # Self-check: a rejected input method leaves the language in the list with
    # an empty tip list, so verify the tips landed, not just the language tags.
    $now = Get-WinUserLanguageList
    if (-not ($now | Where-Object { $_.InputMethodTips -contains $ENG })) {
        throw "ENG (US keyboard) did not apply. Current list: $($now.LanguageTag -join ', ')"
    }
    if (-not ($now | Where-Object { $_.InputMethodTips -contains $BOPOMOFO })) {
        throw 'Microsoft Bopomofo did not apply. Install the language feature as admin: Install-Language zh-Hant-TW'
    }
    if ($now[0].LanguageTag -ne $first) {
        throw "First language changed from $first to $($now[0].LanguageTag). Move $first back to the top in Settings > Time & language > Language & region."
    }

    Write-Host 'Done. Win+Space to switch. Sign out/in if the taskbar indicator lags.' -ForegroundColor Cyan
}
