# Node.js インストールガイド

公開ステップ（SKILL.md 手順6）で Node.js が見つからなかった場合に使う。

## まず説明して許可を取る

以下を伝えてから進める:

> 図解の作成は完了しています。`output/` フォルダの HTML ファイルをブラウザにドラッグ＆ドロップすれば、今すぐ確認できます。
>
> URLで公開するには「Node.js（パソコン上でプログラムを動かすための土台。世界中で広く使われている公式の無料ソフト）」のインストールが必要です。
> 公式サイト（nodejs.org）から直接ダウンロードします。今からインストールしてもよいですか？

許可が出なかった場合 → HTMLファイルをブラウザで開く方法だけ伝えて終了する。

## macOS

インストーラーを公式サイトからダウンロードする:

```bash
PKG_NAME=$(curl -sL https://nodejs.org/dist/latest-lts/ | grep -o 'node-v[0-9.]*\.pkg' | head -1) && curl -fsSL "https://nodejs.org/dist/latest-lts/${PKG_NAME}" -o /tmp/node-install.pkg && echo "ダウンロード完了: ${PKG_NAME}"
```

実行する**前に**こう伝える:

> インストールにはパソコンのパスワード（ログイン時に使っているもの）の入力が必要です。
> ターミナル欄に入力して Enter を押してください。入力中の文字は画面に表示されませんが、正常な動作です。

```bash
sudo installer -pkg /tmp/node-install.pkg -target / && rm /tmp/node-install.pkg
```

## Windows

実行する**前に**こう伝える:

> 途中で「このアプリがデバイスに変更を加えることを許可しますか？」と表示されたら「はい」を押してください。

```powershell
winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
```

インストール後、いまのターミナルで Node.js を使えるようにする:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

winget が使えない場合（「winget は認識されていません」と出た場合）:

```powershell
$msi = (Invoke-WebRequest -Uri "https://nodejs.org/dist/latest-lts/" -UseBasicParsing).Links.href | Where-Object { $_ -match "x64\.msi$" } | Select-Object -First 1; Invoke-WebRequest -Uri "https://nodejs.org/dist/latest-lts/$msi" -OutFile "$env:TEMP\node-install.msi" -UseBasicParsing; Start-Process msiexec.exe -ArgumentList "/i `"$env:TEMP\node-install.msi`"" -Verb RunAs -Wait; Remove-Item "$env:TEMP\node-install.msi"
```

## 確認

```bash
node --version
```

バージョン番号が出れば成功。エラーが出る場合は、使っているアプリ（Claude Code やターミナル）をいったん閉じて開き直してから再確認する。
