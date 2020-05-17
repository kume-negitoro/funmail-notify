# funmail-notify

はこだて未来大学の専用メールボックスに自動ログインし、**LINE Notify**での新着通知を行うスクリプトです。
自動化には**Bash**が動作するコンピュータで定期実行を設定する必要があります。以下は**Linux**を想定した設定例です。


## インストール

1. **jq**と**curl**をインストールします。

`$ sudo apt install -y jq curl`

2. このリポジトリに含まれる`funmail-notify.sh`を任意のディレクトリに配置します。

3. 後述する環境変数を設定します。

4. **cron** や **systemd** で定期実行を設定します。


## 環境変数

このスクリプトが動作するには以下の3つの環境変数が必要です。

- FUNMAIL_ID

メールボックスにログインするためのIDです。


- FUNMAIL_PW

メールボックスにログインするためのパスワードです。


- FUNMAIL_LINE_TOKEN

LINE Notify にメッセージを送信するためのトークンです。
[LINE Notify](https://notify-bot.line.me/ja/)で個別にトークンを取得している必要があります。


## **cron**での設定例

以下は**cron**の設定例です。5分毎にメールボックスを確認し、新着メールがあれば通知を送信します。`/path/to/dir`部分には**funmail-notify.sh**を配置したディレクトリを記述してください

```bash:crontab
FUNMAIL_ID=<ID>
FUNMAIL_PW=<PASSWORD>
FUNMAIL_LINE_TOKEN=<TOKEN>
*/5 * * * * /path/to/dir/funmail-notify.sh
```

**cron**で実行する場合、環境変数がユーザログイン時のものと必ずしも一致しないことに注意してください。**crontab**に直接記述するか、手動で環境変数を読み込む必要があります。

決して数秒おきにアクセスするような設定は行わないでください。メールサーバに多大な負荷を与え、損害を発生させることになりかねません。


## 依存コマンド

- jq
- curl


## キャッシュディレクトリ

通常は`$HOME/.funmail-notify/`にクッキーとキャッシュを保存します。この項目はスクリプト内の変数で設定可能です。


## ライセンス

WTFPL
