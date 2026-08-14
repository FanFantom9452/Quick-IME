# fast_set_input

一行指令，把 Windows 11 的輸入法設成 **ENG（英文鍵盤）+ 繁體中文（微軟注音）**。

不用進設定、不用重開機、不用系統管理員權限。

---

## 快速使用

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1 | iex"
```

執行後語言列會變成：

| 順序 | 語言 | 輸入法 |
| --- | --- | --- |
| 1（預設） | `en-US` | ENG — 美式鍵盤 |
| 2 | `zh-Hant-TW` | 微軟注音 |

按 `Win + Space` 切換。重複執行不會有副作用。

## 本機執行

```powershell
git clone https://github.com/FanFantom9452/fast_set_input.git
cd fast_set_input
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

---

## 需求

- Windows 11（Windows 10 也可以，用的是同一組 cmdlet）
- Windows PowerShell 5.1 或 PowerShell 7+（兩者都測過）
- **不需要**系統管理員權限 — `Set-WinUserLanguageList` 只改目前使用者

### 本來就沒有 ENG 也能套用

可以。美式鍵盤配置 `0409:00000409` 是每個 Windows SKU 都內建的東西，不是選用功能。清單裡沒有 ENG 只代表「沒加進去」，不是系統缺檔，所以腳本直接加就會出現，也不需要裝 en-US 語言包（那個只影響顯示語言）。

繁體中文則需要語言功能有裝。若出現 `Traditional Chinese did not apply`，用系統管理員開 PowerShell：

```powershell
Install-Language zh-Hant-TW
```

裝完再跑一次。

## 它做了什麼

呼叫 Windows 內建的 `Set-WinUserLanguageList`，把語言清單整份換成 en-US + zh-Hant-TW。

- 印出執行前 / 執行後的清單
- 結尾自我檢查：驗兩個語言的**輸入法真的掛上去了**，不是只驗語言有在清單裡（輸入法被系統拒絕時，語言仍會留在清單但輸入法是空的，這種安靜失敗會被抓出來並回傳非 0）

⚠️ **這是覆蓋不是新增。** 清單裡原本的其他語言（日文、韓文等）會被移除。先執行下面的備份指令留一份。

## 備份與還原

執行前備份：

```powershell
Get-WinUserLanguageList | ConvertTo-Json -Depth 4 | Set-Content "$HOME\lang-backup.json" -Encoding UTF8
```

還原：

```powershell
$backup = Get-Content "$HOME\lang-backup.json" -Raw | ConvertFrom-Json
$list = New-WinUserLanguageList $backup[0].LanguageTag
$list[0].InputMethodTips.Clear()
$backup[0].InputMethodTips | ForEach-Object { $list[0].InputMethodTips.Add($_) }
foreach ($b in $backup | Select-Object -Skip 1) {
    $list.Add($b.LanguageTag)
    $last = $list[$list.Count - 1]
    $last.InputMethodTips.Clear()
    $b.InputMethodTips | ForEach-Object { $last.InputMethodTips.Add($_) }
}
Set-WinUserLanguageList $list -Force
```

## 安全性

`irm | iex` 會直接執行網路上的程式碼。跑之前建議先讀過：

```powershell
irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1
```

整份腳本 60 行左右，沒有相依套件、不下載其他檔案、不寫登錄檔、不需要提權。

---

## English

One-liner to set the Windows 11 input list to **ENG (US keyboard) + Traditional Chinese (Microsoft Bopomofo)**. No admin, no reboot, safe to re-run.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1 | iex"
```

Works even if ENG was never added — the US keyboard layout ships with every Windows SKU. Only `zh-Hant-TW` needs its language feature installed (`Install-Language zh-Hant-TW` as admin if missing).

It **replaces** the language list, so back it up first (see 備份與還原 above). The script verifies both input methods actually applied and exits non-zero if not.

## License

MIT
