# rb-groups

情報処理応用（ロボカー）のグループ作成、貸し出しロボカー割り当てプログラム。

## Todo

## Done

* 入力値のバリデーション、それは学生番号か？しかし、コードはウルトラダサい。
* 入力のバリデーション、学生番号、グループ名はユニークか？(半分)
* alert befor delete
* mongodb sort（find と一緒。簡単）
* テーブルの色付け
* placeholder
* ボタンのサイズ

## Usage

```
$ mongodb start
```

```
> (ql:quickload :rb-groups)
> (start-server)
```

## Installation

Before compiling in production system (vm2016),

* don't forget to define collect database.
* change user/password if necessary.

```
$ git clone https://github.com/hkim0331/rb-groups.git
$ cd rb-groups
$ (edit database to use in src/rb-groups.lisp)
$ make
$ ./rb-groups
```

一番最初の起動時、コレクションが存在していないとエラーになる、かな？

## Author

* hiroshi kimura

## Copyright

Copyright (c) 2016 hiroshi kimura
