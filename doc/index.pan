
= Text::PAN - Pretty Article Notation

<def name=Text::PAN /Text::PAN>
<def name=RD        /<dfn/<ref url="http://rubyforge.org/projects/rdtool/" /RD>>>
<def name=tDiary    /<dfn/<ref url="http://www.tdiary.org/" /tDiary>>>
<def name=Ruby      /<dfn/<ref url="http://www.ruby-lang.org" /Ruby>>>
<def name=Perl      /<dfn/<ref url="http://www.perl.org" /Perl>>>
<def name=PANot     /Text::PANによる特殊記法 >

Text::PAN は、<x/RD> や、<x/tDiary> 記法に似た、インデントベースの文法を持った
ドキュメント表記方式であり、ともにデザインした、pad と言う、XMLドキュメントの扱いやすい記法です。

XMLドキュメントの表記方式であるため、外部の名前空間の要素を追加することを
可能としているほか、XSLTを用い、各種文書フォーマットへの変換を可能にしています。


* 開発動機とデザイン

** 開発動機

Text::PAN は、汎用的で扱いやすいテキストベースの文書フォーマットの必要性から開発されました。

文書が汎用的なものであるためには、以下の要件を満たす必要があります。

 - 構造化された文書が記述できる
 - 文書を構成する要素に任意の拡張が可能である
 - 作成した文書を任意の形式に変換できる
 - その文書のソースが読みやすく記述しやすい

これらのうち、いくらかを満たす文書形式は既に存在します。XMLは、上記のうち、
3つの要件を満たしますが、正直に言ってそのソースはあまり扱いやすいものではありません。

パーサの実装のためのコストを下げるためか、SGMLにあった多くの省略のための表記法が 
XML では排除されました。
また、どのような要素であれタグで括る必要のあるその記述は直感的なものではありません。

そのため、テキストベースの多くの汎用的な文書フォーマットは、読みやすく記述しやすい
文書から、XMLへ変換するトランスレータを提供しています。

<x/Perl> プログラマが慣れ親しんでいる、POD や、<x/Ruby> プログラマが親しんでいる <x/RD>
などはそういったアプローチをとっています。

しかし、これらのアプローチは、XMLのような任意の要素の拡張のための仕組みは
別フォーマット文書の埋め込みと言う極めて限定的な形でしか提供されていません。

そこで、この問題を解決するため、そういった文書フォーマットに、通常のXML文書と
同じように任意の名前空間の要素を取り込む機構、そして XML と同等の表現力を持ちながら、
より簡素なタグ表記機構を取り込んだ文書フォーマットを開発しようと、Text::PAN を
開発しました。


** デザイン

Text::PAN のデザインは、RD程度にソースが綺麗で、XMLのように拡張可能な文書を目指し、
以下を柱としてデザインしています。

 - 基本的にはインデントと空行によるブロック表現
 - 任意のXML要素を直接記述できる機構の提供
 - 小さなXML要素についての、できるだけ無駄の無い表記法の提供


* 文書ヘッダ

** タイトル

Text::PAN 文書の冒頭にて

  = Text::PAN - Pretty Article Notation

のように、= で始まる行は、続く文字がその文書のタイトルとして記録され、
作成される文書のメタ要素に追加されます。

** xml名前空間

Text::PAN において、名前空間プレフィクスが省略されたものは、pad の名前空間である

  tag:neoteny.sakura.ne.jp,2009/xmlns/pad

に固定されています。拡張が必要な場合、文書の開始直後、セクションが初まるまでに、

  @xmlns:html="http://www.w3.org/2002/06/xhtml2/"

のように記すことで指定することができます。このように宣言することで、

  * HTMLを含む文書

  <html:table>
    <html:thead>
      <html:tr>
       <html:th/あああ>
       <>見出し2</>
       <>見出し3</>
      </>
    </html:thead>
  </html:table>

のように、要素を拡張することができます。


* タグの記述

Text::PAN は、タグを記述することによって、任意の名前空間要素を作ることができます。

** XML 短縮タグ機構

*** NET

XML は、SGML の短縮タグ機構より、NET と呼ばれるものを使い、

>|xml|
  <element / >
||<

のように、空要素を表現しています。
これは、<code/&lt;element /> までが、要素の開始タグであり、 <code/&gt;> 
が終了タグの略記となっています。

通常の XML 文書では、これは単に空要素を表記する為に導入され、 <code/&gt;> 
までに、何らノードを加えることができません。

Text::PAN では、この制約をとりはらい、
>|xml|
  <element / content of <em>the element</em>.>
||<

のような表記を可能にしています。もちろん
>|xml|
  <element / content of <em/ the element>.>
||<
のように、NET式の要素の表記を入れ子にすることも可能です。



*** 空タグ

Text::PAN では、SGML の空タグに似た機構も取り入れています。空タグとは、
タグの要素名が省略された開始、または終了タグであり、終了タグの名前が省略された場合、
対応する開始要素の名前が、開始タグの名前が省略された場合は、直前の兄弟要素の名前と
同じものが指定されたことになります。

たとえば、
>|pan|
  <tags><item /aaa>< /bbb>< /ccc></>
||<
は、
>|xml|
  <tags><item>aaa</item><item>bbb</item></tags>
||<
のように解釈されます。

<note>

ここで、

>|pan|
  <tags><item /aaa></bbb></ccc></>
||<

のように記述してしまわないように注意してください。
つまり、 <code/&lt;/> のように <code/&lt;> と、 <code//> の間にスペースが無いと、
Text::PAN は、NET形式の開始タグではなく、終了タグと解釈してしまいます。
つまり、ここで、bbb と言う要素も、ccc と言う要素も開始しておらず、Text::PAN はそのような
終了タグを単にテキストとして解釈するため、

>|xml|
  <tags><item>aaa</item>&lt;/bbb&gt;&lt;/ccc&gt;</tags>
||<

のように解釈します。

</note>

*** 引用符の省略

Text::PAN における、引用符の省略は、殆どのSGML文書より協力で、<code/&nbsp;>
<code/=><code/&gt;><code//><code/&lt;> 等の文字を含まないあらゆる連続
する文字列で可能です。


** インライン要素とブロック要素

Text::PAN は、文書を記述するために設計された、ある XML のもうひとつの表記法であり、
段落の概念を持っています。
段落には収まるべき要素と収まるべきでない要素がありますが、一方で拡張性を追求したものでもある
Text::PANは、それらの要素を厳密に区別はしません。ただ、要素がどのように記述されたかと
言うことに従ってその区別がつけられます。

ブロック要素は、

>|pan|
  <element>
  </element>
||<

のように、要素開始タグが行頭から始まっており、終了タグが行末で終了するものは、
そうであると見做され、その要素が段落に含まれることはありません。

それとは異なり、

>|pan|
  xxx<elem/foo>xxx
  <elem>bar</elem>xxx
  xxxx<elem>bazz</>xxxx
||<

のように、行中に現われるものについては、インライン要素と見做され、段落の内部に
含まれます。

<note>

ただ、これでは要素そのものの目的はインライン要素であるのに、その要素の前後に
何らテキストノードを持たないものは作れないようにも思えます。しかし、Text::PAD
は、任意のXML要素をタグを用い、明示的に記述することができるので、そのような場合は、たんに

>|pan|
  <p<elem/foo>>
||<

のように、段落に含まれることを明示すれば良いわけです。

</note>


* Text::PAN の記法と、作成される要素

pad は任意の要素を定義することができる名前空間として、
tag:neoteny.sakura.ne.jp,2009/xmlns/pad を提供しています。

ここでは如何なる名前、何如なる形式の要素を定義しても構いませんが、
Text::PAN は、ソースの構造に従い一定の要素を一定の構造で作成します。

ここでは、それら要素と、その表記法について説明します。

** article

文書のルート要素として作られます。

** meta

文書のメタ情報のために、必要であれば作られます。


** title

文書のメタ情報として、必要であれば /article/meta/title として作られます。


文頭で

 = ウーパールーパ丼に対する消費者の抵抗感について

のように、イコール記号からはじまるものがタイトルとして認識されます。
emacs の howm とも互換性のある表記法です。


** section

文書の章を表わす要素です。

Text::PAN では行頭より * が連結する行により開始するブロックとして表現されます。
行頭の * の数により要素の深さを指定することができ、より深い section 要素は
直前のより浅い section 要素の子要素となり、ちょうど GNU Emacs における、
outline-mode のデフォルトの設定と互換性をもったフォーマットになります。

セクションの入れ子関係は(計算機のリソースが許すかぎり)無限に
深くすることができます。

たとえば、

>||

 * セクション

 セクションの内容

 ** 副セクション

 副セクションの内容

 *** 副副セクション

 **** 副副副セクション

 ***** 副副副副セクション
      .
      .
      .


||<

これは、以下のように解釈されます

>||
 <section>
   <head>セクション</head>
   <p>セクションの内容</p>
   <section>
     <head>副セクション</head>
     <p>副セクションの内容</p>
     <section>
       <head>副副セクション</head>
       <section>
         <head>副副副セクション</head>
         <section>
           <head>副副副セクション</head>

      .
      .
      .

||<

<note>

このセクションの記法は、後述の各種リストと異なり、インデントによってその
ネストを表現しません。

多くの文書において階層化された章だては本質的なものであり、インデントを要求
してしまうと、ソースの殆どに対しインデントの必要が生まれてしまいます。

この表記法もあって、この要素は特権的であり、あらゆるタグはセクション見出しを
跨いで配置することができません。

</note>



** hr

水平線要素です。
この要素はあらゆる属性を持ちません。

水平線は行頭より二つ以上のマイナス記号が連続し、かつ
マイナス記号のみで構成される行によって示されます。
この字数は、二文字以上であれば制限がなく、ソースの
可読性を上げることに貢献します。

>||
------------------------------------------------------
||<

** リスト項目

行頭から、任意個数の空白とリスト開始記号は、リストの項目を示します。
項目は、その開始行と同じ深さのインデントを与えることで内部に section を
除くすべての要素を含むことができます。

たとえば、

>||

 - リスト1
   リスト1の続き
         <verb>リスト1の verbatim
</verb>
         <ul>
          <item><p>リスト2.1
</p></item>
          <item><p>リスト2.2
</p>
         </ul>
    </item>
  </ul>
||<

のように変換されます。

開始記号は、 <code/-> にて始まるものが、番号を持たないリスト、<code/+>で始まるものが、
番号付きリストのための要素となり、項目である item 要素は、それぞれ、ul 要素、ol 要素
の子要素となります。

また、

>||
:: aaa ::
   aaa の定義内容
:: bbb :: bbb の定義内容
||<

のような形で定義リストを表現することができ、この場合、item 要素が dl 要素に囲まれます。
また, 行頭の <code/::> に挟まれた部分は、定義名を示すものとし、 item 要素の firstElement 
として、 about 要素が作られ、そこにその内容が格納されます。

** verb

HTML の pre 要素のように、整形済みのテキストの為に提供されます。

Text::PAN では、

>|pan|

aaaa
bbbb
  verb
cccc
dddd


||<

のように、インデントをして表記することができます。
また、


 aaa
 bbb
 >||
  - aaaa
  - bbbb
  - cccc
 ||<
 ccc
 ddd


のような形で、通常、verb のためのインデントと見做されないものについても強制的に
verb 要素を作ることができます。


* Text::PAN::Suite と pan コマンド

Text::PAN::Suite は、Text::PAN をより扱いやすくするためのモジュールであり、XSLT や、
その他 DOM 操作にて XML 形式に変換された文書をさらに加工するための仕組みを提供します。

** フィルタロール

*** Text::PAN::Suite::Role::Filter
*** Text::PAN::Suite::Role::Filter::XSLT
*** Text::PAN::Suite::Role::Filter::XSLT::File

** 定義済みのフィルタ

*** Text::PAN::Suite::Filter::MacroExpand

XSLTテンプレートと組みあわせることで、以下のようにマクロのような仕組みを用いることができます。
実際、この文書でも使われています。


>|pan|
<def name="foo" /definition of foo>

<x/foo>
||<

*** Text::PAN::Suite::Filter::URL2Ref

テキストノードに http://example.org/foo/bar?xxx=yyy#hoge
のように、 URL が含まれている場合、その部分を内容が空の ref 要素に変換します。

*** Text::PAN::Suite::FIlter::TeXEscape

#, $, %, &,_ , {, }, \  や TeX , LaTeX , LaTeXe などの TeX の特殊記号を、TeX の為にエスケープします。


* 拡張案

Text::PAN には、現在通常の XML 文書にはあるいくつかの機能が実装されていません。
全てが実現できるかどうかはわかりませんが、必要に応じ、実装して行きたいと考えています。

** 多言語ドキュメント

現時点の Text::PAN には、多言語ドキュメントの機能をサポートしていません。
適当な XML ブロックを作って xml:lang 属性をつけることはできますが、section 要素などに
それらの属性を付加することができません。

** Entity Notation

現時点の Text::PAN には、実態宣言の機能をサポートしていません。

** Prosessing instruction

現時点の Text::PAN には、Prosessing instruction をサポートしていません。

** CDATA セクション

現時点の Text::PAN は CDATA セクションをサポートしていません。ただ、現状において文字通りのテキストを記述する方法が、
verb 要素の中身にしかないため、任意の拡張のためには必要かもしれません。あるいは、verb 記法自体を拡張すべきかもしれません。

** コメント宣言

現状でも、コメント宣言を記述することができますが、コメント宣言の内容が、
必ずしも変換後のドキュメントに反映されるとは限らないようになっています。
