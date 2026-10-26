# Quick-IME

一行指令，幫 Windows 11 補上 **ENG（英文鍵盤，美式 `0409:00000409`）** 和 **繁體中文（微軟注音）**。

只新增缺少的，不動你現有的語言、順序、顯示語言與其他輸入法（倉頡、速成、日文等都會留著）。不用進設定、不用重開機、不用系統管理員權限。

---

## 快速使用

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/Quick-IME/main/install.ps1 | iex"
```

按 `Win + Space` 切換。重複執行不會有副作用：兩個都已存在時什麼都不會改。

## 本機執行

```powershell
git clone https://github.com/FanFantom9452/Quick-IME.git
cd Quick-IME
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

---

## 需求

- Windows 11（Windows 10 也可以，用的是同一組 cmdlet）
- Windows PowerShell 5.1 或 PowerShell 7+（兩者都測過）
- **不需要**系統管理員權限 — `Set-WinUserLanguageList` 只改目前使用者

### 本來就沒有 ENG 也能套用

可以。美式鍵盤配置 `0409:00000409` 是每個 Windows SKU 都內建的東西，不是選用功能。清單裡沒有 ENG 只代表「沒加進去」，不是系統缺檔，所以腳本直接加就會出現，也不需要裝 en-US 語言包（那個只影響顯示語言）。

微軟注音則需要繁體中文的語言功能有裝。若出現 `Microsoft Bopomofo did not apply`，用系統管理員開 PowerShell：

```powershell
Install-Language zh-Hant-TW
```

裝完再跑一次。

## 它做了什麼

讀取目前的語言清單，ENG（掛在 en-US）和微軟注音（掛在 zh-Hant-TW）各自這樣處理：

- 已經有了：不做任何變更
- 清單有那個語言但沒有這個輸入法：只把它加進那個語言，原本的輸入法都留著
- 清單沒有那個語言：在清單最後面新增該語言，只掛這個輸入法

並且：

- 印出執行前 / 執行後的清單
- 結尾自我檢查：驗 ENG 和注音**真的掛上去了**，且第一個語言沒有變；任一項不符就丟出錯誤（輸入法被系統拒絕時，語言仍會留在清單但輸入法是空的，這種安靜失敗會被抓出來）

## 移除

- ENG：設定 → 時間與語言 → 語言與地區 → English (United States) → 移除
- 微軟注音：設定 → 時間與語言 → 語言與地區 → 中文 (台灣) 旁的 `⋯` → 語言選項 → 鍵盤 → 微軟注音 → 移除

## 安全性

`irm | iex` 會直接執行網路上的程式碼。跑之前建議先讀過：

```powershell
irm https://raw.githubusercontent.com/FanFantom9452/Quick-IME/main/install.ps1
```

整份腳本 92 行左右，沒有相依套件、不下載其他檔案、不寫登錄檔、不需要提權。

---

## English

One-liner that adds **ENG (US keyboard, `0409:00000409`)** and **Traditional Chinese (Microsoft Bopomofo)** to Windows 11. It only adds what is missing and does not touch your existing languages, their order, the display language or any other input method. No admin, no reboot, safe to re-run (a no-op once both exist).

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/FanFantom9452/Quick-IME/main/install.ps1 | iex"
```

Works even if ENG was never added — the US keyboard layout ships with every Windows SKU. Bopomofo needs the `zh-Hant-TW` language feature (`Install-Language zh-Hant-TW` as admin if missing).

What it does, for ENG (under en-US) and Bopomofo (under zh-Hant-TW) each: if it is already there, nothing changes; if its language is in the list without it, it is added to that language and the other input methods stay; if its language is not in the list, the language is appended at the end with only that input method. It prints the list before and after, then checks that both applied and the first language is unchanged, and throws an error if not.

### Removing

- ENG: Settings → Time & language → Language & region → English (United States) → Remove
- Bopomofo: Settings → Time & language → Language & region → `⋯` next to Chinese (Traditional, Taiwan) → Language options → Keyboards → Microsoft Bopomofo → Remove

## License

MIT
