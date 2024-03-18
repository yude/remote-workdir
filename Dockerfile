# ubuntuのイメージ
FROM ubuntu:22.04
# パッケージマネージャーの更新
RUN apt update && apt -y upgrade
RUN apt-get update && apt-get upgrade
ENV DEBIAN_FRONTEND=noninteractive
# 必要そうなコマンドのインストール
RUN apt -y install wget --no-install-recommends
RUN apt -y install tzdata --no-install-recommends
RUN apt -y install gpg --no-install-recommends
RUN apt -y install git --no-install-recommends
RUN apt -y install nano --no-install-recommends
RUN apt -y install sudo --no-install-recommends
RUN apt -y install apt-transport-https --no-install-recommends
# supervisorのインストール
RUN apt-get update && apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#日本語化パッケージリストをインストール
RUN apt-get install -y language-pack-ja-base language-pack-ja locales
# localeを日本語に設定
RUN locale-gen ja_JP.UTF-8
# 言語を日本語に設定
ENV LANG ja_JP.UTF-8
# Desktop環境をインストール
RUN sudo apt-get -y install vanilla-gnome-desktop vanilla-gnome-default-settings --no-install-recommends
# 全角を表示できるフォントをインストール
RUN apt -y install fonts-noto-cjk --no-install-recommends
# IMEのインストールと設定
RUN sudo apt -y install ibus-mozc --no-install-recommends
RUN gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'jp'), ('ibus', 'mozc-jp')]"
# VNC環境のインストール
RUN apt install -y tigervnc-standalone-server tigervnc-scraping-server tigervnc-common
# noVNC (VNC on HTML5) のインストール
RUN apt install -y novnc websockify
# 署名鍵の登録
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
# packages.microsoft.gpgの所有権とパーミッションを変更
RUN sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
# コピー元のファイル削除
RUN rm -f packages.microsoft.gpg
# リポジトリの登録
RUN sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
# Vscodeのインストール
RUN apt update && apt -y upgrade
RUN apt -y install code --no-install-recommends
RUN mkdir -p /root/Desktop/wkprd
RUN echo "code --user-data-dir='/root/Desktop/wkprd' --no-sandbox" > /root/Desktop/VSCode.sh
RUN chmod 755 /root/Desktop/VSCode.sh
# VNCのパスワード設定
RUN mkdir ~/.vnc
RUN echo "MYVNCPASSWORD" | vncpasswd -f > /root/.vnc/passwd
RUN chmod 600 /root/.vnc/passwd
# VNCサーバーの起動 + noVNCの起動
CMD ["/usr/bin/supervisord"]