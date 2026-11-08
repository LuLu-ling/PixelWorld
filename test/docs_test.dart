import 'package:flutter_test/flutter_test.dart';
import 'package:pcl_pw/core/docs.dart';

const sample = '''
<article>
  <h1>测试页面</h1>
  <p>正文里有一个 <a href="install.html">链接</a> 和 <code>code</code>。</p>
  <h2>设置</h2>
  <ul>
    <li>第一项</li>
    <li>第二项 <strong>重点</strong>
      <ul><li>子项</li></ul>
    </li>
  </ul>
  <pre><code>flutter run -d windows</code></pre>
  <div class="callout">
    <span class="icon">info</span>
    <div class="body"><p>提示内容</p></div>
  </div>
  <div class="table-wrap">
    <table>
      <thead><tr><th>字段</th><th>说明</th></tr></thead>
      <tbody><tr><td><code>a</code></td><td>x</td></tr></tbody>
    </table>
  </div>
  <details><summary>问题</summary><p>回答</p></details>
</article>
''';

void main() {
  test('把文档页面转换成 Markdown', () {
    final md = htmlToMarkdown(sample);
    expect(md, contains('# 测试页面'));
    expect(md, contains('## 设置'));
    expect(md, contains('[链接](install.html)'));
    expect(md, contains('`code`'));
    expect(md, contains('- 第一项'));
    expect(md, contains('**重点**'));
    expect(md, contains('  - 子项'));
    expect(md, contains('```\nflutter run -d windows\n```'));
    expect(md, contains('> 提示内容'));
    expect(md, contains('| 字段 | 说明 |'));
    expect(md, contains('| `a` | x |'));
    expect(md, contains('**问题**'));
    expect(md, contains('回答'));
  });

  test('文档页面列表覆盖官网的九页', () {
    expect(docPages.map((p) => p.id), containsAll(['index', 'install', 'ai', 'api', 'troubleshooting']));
    expect(docPages.map((p) => p.id).toSet(), hasLength(docPages.length));
    expect(docPageUrl('ai'), 'https://pixelworld.zhuzhi.site/docs/ai.html');
  });
}
