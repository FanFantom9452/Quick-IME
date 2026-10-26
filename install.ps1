<#
.SYNOPSIS
    Adds ENG (US keyboard) to the Windows 11 input list without touching anything else.

.DESCRIPTION
    Per-user, no admin required. Reads the current language list and only adds
    the US keyboard layout (0409:00000409):

      - some language already has ENG -> nothing changes
      - en-US is in the list without ENG -> ENG is added to that en-US entry
      - en-US is not in the list -> en-US is appended at the end with ENG only

    Language order, the display language and every other input method stay as
    they were. The US keyboard layout ships with every Windows SKU, so ENG
    applies even if the user has never added it.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/Quick-IME/main/install.ps1 | iex"
#>

# ponytail: ASCII only. Windows PowerShell 5.1 reads a BOM-less .ps1 as ANSI,
# so non-ASCII literals here show up as mojibake when run with -File.

# No `exit` anywhere: under `irm | iex` it would close the user's window.

$ErrorActionPreference = 'Stop'

$ENG = '0409:00000409'

function Show-List($label, $color) {
    Write-Host "`n$label" -ForegroundColor $color
    Get-WinUserLanguageList |
        Format-Table LanguageTag, @{ n = 'InputMethods'; e = { $_.InputMethodTips -join ', ' } } |
        Out-Host
}

Write-Host 'Quick-IME  -  add ENG (US keyboard)' -ForegroundColor Cyan
Show-List 'Before:' DarkGray

$list  = Get-WinUserLanguageList
# Windows uses the first language as the display language and default input,
# so it must stay where it is.
$first = $list[0].LanguageTag

if ($list | Where-Object { $_.InputMethodTips -contains $ENG }) {
    Write-Host 'ENG is already installed. Nothing changed.' -ForegroundColor Cyan
}
else {
    # Not $eng: PowerShell variable names are case-insensitive, so it would
    # silently overwrite the $ENG constant.
    $enUS = $list | Where-Object LanguageTag -eq 'en-US' | Select-Object -First 1
    if ($enUS) {
        $enUS.InputMethodTips.Add($ENG)
    }
    else {
        $list.Add('en-US')
        $enUS = $list[$list.Count - 1]
        $enUS.InputMethodTips.Clear()
        $enUS.InputMethodTips.Add($ENG)
    }

    Set-WinUserLanguageList $list -Force -WarningAction SilentlyContinue

    Show-List 'After:' Green

    # Self-check: a rejected input method leaves the language in the list with
    # an empty tip list, so verify the tip landed, not just the language tag.
    $now = Get-WinUserLanguageList
    if (-not ($now | Where-Object { $_.InputMethodTips -contains $ENG })) {
        throw "ENG (US keyboard) did not apply. Current list: $($now.LanguageTag -join ', ')"
    }
    if ($now[0].LanguageTag -ne $first) {
        throw "First language changed from $first to $($now[0].LanguageTag). Move $first back to the top in Settings > Time & language > Language & region."
    }

    Write-Host 'Done. Win+Space to switch. Sign out/in if the taskbar indicator lags.' -ForegroundColor Cyan
}
