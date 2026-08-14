# fast_set_input

一行指令，把 Windows 11 的輸入法設成 **ENG（英文鍵盤）+ 繁體中文**。

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

按 `Win + Space` 切換。

## 選別的中文輸入法

預設是注音。要用倉頡或速成，改用 scriptblock 形式傳參數：

```powershell
# 倉頡
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1))) -ChineseIME ChangJie

# 速成
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1))) -ChineseIME QuickCJ
```

| `-ChineseIME` | 輸入法 |
| --- | --- |
| `Bopomofo`（預設） | 微軟注音 |
| `QuickCJ` | 微軟速成 |
| `ChangJie` | 微軟倉頡 |

## 本機執行

```powershell
git clone https://github.com/FanFantom9452/fast_set_input.git
cd fast_set_input
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

---

## 需求

- Windows 11（Windows 10 也可以，用的是同一組 cmdlet）
- Windows PowerShell 5.1 或 PowerShell 7+
- **不需要**系統管理員權限 — `Set-WinUserLanguageList` 只改目前使用者

如果出現 `Language list did not apply`，代表系統缺繁體中文語言包。用系統管理員開 PowerShell：

```powershell
Install-Language zh-Hant-TW
```

裝完再跑一次。

## 它做了什麼

`Set-WinUserLanguageList`（Windows 內建 cmdlet），把語言清單整份換成 en-US + zh-Hant-TW。

- 會印出執行前 / 執行後的清單
- 結尾自我檢查，沒套用成功會直接報錯，不會安靜失敗

⚠️ **這是覆蓋不是新增。** 清單裡原本的其他語言（日文、韓文等）會被移除。先執行下面的備份指令留一份。

## 還原

執行前先備份：

```powershell
(Get-WinUserLanguageList).LanguageTag | Set-Content $HOME\lang-backup.txt
```

還原：

```powershell
Set-WinUserLanguageList (New-WinUserLanguageList (Get-Content $HOME\lang-backup.txt)[0]) -Force
```

## 安全性

`irm | iex` 會直接執行網路上的程式碼。跑之前建議先讀過：

```powershell
irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1
```

整份腳本不到 60 行，沒有相依套件、不下載其他檔案、不寫登錄檔。

---

## English

One-liner to set the Windows 11 input list to **ENG (US keyboard) + Traditional Chinese**. No admin, no reboot.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/fast_set_input/main/install.ps1 | iex"
```

Pass `-ChineseIME Bopomofo|QuickCJ|ChangJie` via the scriptblock form shown above. It **replaces** the language list — back it up first. Needs the `zh-Hant-TW` language pack (`Install-Language zh-Hant-TW` as admin if missing).

## License

MIT
