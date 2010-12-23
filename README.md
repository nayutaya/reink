
# README

　reink は Web サイト（主にニュースサイト）を epub 形式に変換するツールです。
Kindle 3 向けに最適化されています。

## 使い方

  $ cat list.txt
  http://...
  http://...
  http://...
  http://...

  $ cat foo.yaml
  url-list: list.txt
  output: output.epub
  title: "タイトル"
  author: "作者"
  publisher: "出版社"
  uuid: null

  $ reink epub --manifest=foo.yaml

　manifestファイルを使わずに、コマンドライン引数で各種オプションを
指定する事もできます。

## サブコマンド

* epub
* dump
* xhtml

## コマンドライン引数

### reink epub

  Usage: reink epub [options]
      -m, --manifest=FILE
      -u, --url-list=FILE
      -o, --output=FILE
      -t, --title=STRING
      -a, --author=STRING
      -p, --publisher=STRING
      -U, --uuid=UUID
      -c, --cache-dir=DIRECTORY
      -i, --interval=SECOND
      -l, --log-level=LEVEL
      -v, --verbose

### reink dump

  Usage: reink dump [options]
      -o, --output-dir=DIR
      -i, --interval=SECOND
      -l, --log-level=LEVEL
      -v, --verbose

### reink xhtml

  Usage: reink xhtml [options]
      -i, --interval=SECOND
      -l, --log-level=LEVEL
      -v, --verbose

## 作者

Yuya Kato / Nayutaya Inc. <yuyakato@gmail.com>

## ライセンス

Apache License 2.0
