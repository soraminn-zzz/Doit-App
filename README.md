# doitapp

## 1. 🛠 開発環境のセットアップ

チーム全員でFlutterのバージョンを完全に統一するため、**FVM (Flutter Version Management)** を使用します。「自分だけビルドが通らない」という事態を防ぐための重要なステップです。

## FVMのインストール

* **macOS / Linux (Homebrew):**
* brew tap leoafarias/fvm && brew install fvm

* Windows (Chocolatey):
* choco install fvm

* ・Dart pub を使用する場合:
* dart pub global activate fvm

* **Windowsで「fvmが認識されない」エラーが出る場合**
> 環境変数の `Path` に以下を追加して、PCを再起動（またはターミナルを再起動）してください。
> `C:\Users\あなたのユーザー名\AppData\Local\Pub\Cache\bin`
>
> 
> ### ② プロジェクトの初期化
リポジトリをクローンした後、以下のコマンドで環境を整えます。

# プロジェクトディレクトリへ移動
cd [your_project_name]

# プロジェクト指定バージョンのFlutter SDKをインストール
fvm install

# 依存パッケージの取得
fvm flutter pub get

###開発の進め方

  develop ブランチから最新の状態を pull し、新しい feature/xxx ブランチを作成します。

  機能の実装とテストを行います。

  GitHub上で、feature/xxx から develop へ向けて Pull Request (PR) を作成します。

  チームメンバー最低1名以上のApprove（承認）を得てからマージしてください。

