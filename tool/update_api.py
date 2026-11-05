"""根据 GitHub Releases 生成启动器的更新接口 update.json（格式见 lib/core/site_api.dart）。

用法：python3 tool/update_api.py releases.json > update.json
releases.json 为 `gh api repos/<仓库>/releases?per_page=30` 的输出。
各通道的选择规则与启动器的 latestRelease 一致：
  stable  不带「-」的最新 v* 标签
  preview 最新的 v* 标签（包括预发布）
  nightly 标签固定为 nightly
"""

import json
import re
import sys
from datetime import datetime, timezone
from functools import cmp_to_key

VERSION_TAG = re.compile(r'^v\d+(\.\d+)*(-[0-9A-Za-z.-]+)?$')


def _split(v):
    v = re.sub(r'^v', '', v.strip()).split('+')[0]
    core, _, pre = v.partition('-')
    return [int(x) if x.isdigit() else 0 for x in core.split('.')], (pre or None)


def compare_versions(a, b):
    """与 lib/core/updater.dart 的 compareVersions 相同：1.2.3 > 1.2.3-beta.2 > 1.2.3-beta.1 > 1.2.2"""
    ca, pa = _split(a)
    cb, pb = _split(b)
    for i in range(max(3, len(ca), len(cb))):
        x = ca[i] if i < len(ca) else 0
        y = cb[i] if i < len(cb) else 0
        if x != y:
            return x - y
    if pa == pb:
        return 0
    if pa is None:
        return 1
    if pb is None:
        return -1
    xa, xb = pa.split('.'), pb.split('.')
    for s, t in zip(xa, xb):
        if s.isdigit() and t.isdigit():
            c = int(s) - int(t)
        else:
            c = (s > t) - (s < t)
        if c:
            return c
    return len(xa) - len(xb)


def to_site(r):
    def sha(a):
        m = re.match(r'^sha256:([0-9a-f]{64})$', a.get('digest') or '')
        return m.group(1) if m else None

    return {
        'tag': r.get('tag_name') or '',
        'name': r.get('name') or r.get('tag_name') or '',
        'body': r.get('body') or '',
        'prerelease': bool(r.get('prerelease')),
        'commit': r.get('target_commitish') or '',
        'publishedAt': r.get('published_at'),
        'page': r.get('html_url') or '',
        'assets': [
            {
                'name': a.get('name'),
                'url': a.get('browser_download_url'),
                'size': a.get('size') or 0,
                'sha256': sha(a),
            }
            for a in r.get('assets') or []
        ],
    }


def latest(releases, prerelease_ok):
    c = [r for r in releases if not r.get('draft') and VERSION_TAG.match(r.get('tag_name') or '')
         and (prerelease_ok or not r.get('prerelease'))]
    if not c:
        return None
    c.sort(key=cmp_to_key(lambda a, b: compare_versions(b['tag_name'], a['tag_name'])))
    return to_site(c[0])


def build(releases):
    nightly = next((r for r in releases if r.get('tag_name') == 'nightly' and not r.get('draft')), None)
    return {
        'format': 1,
        'generatedAt': datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ'),
        'channels': {
            'stable': latest(releases, False),
            'preview': latest(releases, True),
            'nightly': to_site(nightly) if nightly else None,
        },
    }


if __name__ == '__main__':
    with open(sys.argv[1], encoding='utf-8') as f:
        data = json.load(f)
    sys.stdout.reconfigure(encoding='utf-8')
    json.dump(build(data), sys.stdout, ensure_ascii=False, indent=2)
    sys.stdout.write('\n')
