const fs = require('fs');
const path = require('path');

const root = process.cwd();
const output = path.join(root, 'legal_site');
fs.mkdirSync(output, {recursive: true});

const pages = [
  {
    slug: 'terms',
    title: '使用者服務協議',
    eyebrow: 'TERMS OF SERVICE',
    description: 'Campus Tour 的服務規則、帳號責任與使用者權利。',
    markdown: fs.readFileSync(path.join(root, 'docs/terms_of_service_zh-TW.md'), 'utf8'),
  },
  {
    slug: 'privacy',
    title: '隱私權政策',
    eyebrow: 'PRIVACY POLICY',
    description: '了解 Campus Tour 如何處理帳號、定位、相機與遊戲資料。',
    markdown: fs.readFileSync(path.join(root, 'docs/privacy_policy_zh-TW.md'), 'utf8'),
  },
  {
    slug: 'support',
    title: '支援中心',
    eyebrow: 'SUPPORT',
    description: '取得帳號、隱私、定位與 App 使用協助。',
    markdown: `# Campus Tour 支援中心

最後更新日期：2026 年 8 月 16 日

如果您在使用 Campus Tour／咚谷粒時遇到問題，可依下列方式取得協助。

## 聯絡我們

營運單位：中央大學校園導覽團隊  
支援 Email：**ideasky716@gmail.com**

一般問題請提供 App 版本、裝置型號、作業系統版本、問題發生步驟與畫面截圖。請勿寄送密碼、Firebase ID Token、Apple authorization code 或其他完整登入憑證。

## 帳號與登入

- Email 使用者可從登入頁使用「忘記密碼」。
- Google／Apple 使用者請確認選擇原本連結的帳號。
- 若需刪除帳號，請前往「設定中心 > 帳號安全 > 刪除帳號」。
- 無法使用 App 內刪除功能時，請由帳號 Email 寄出申請，主旨填寫「帳號／資料刪除申請」。

## 權限與功能

- 定位、相機、照片、NFC 或藍牙權限可在裝置的系統設定中調整。
- 拒絕權限只會影響依賴該權限的功能。
- 校園景點、路線或安全資訊如與現場不一致，請以現場標誌與校方公告為準。

## 緊急狀況

本支援信箱不提供即時緊急救援。遇到緊急情況，請聯絡 110、119、校安中心或現場工作人員。

## 法律與隱私

請參閱本站的《使用者服務協議》與《隱私權政策》。隱私、資料存取、更正或刪除問題，也可透過上述 Email 聯絡我們。`,
  },
];

for (const page of pages) {
  fs.writeFileSync(
    path.join(output, `${page.slug}.html`),
    layout(page, markdownToHtml(page.markdown)),
  );
}

fs.writeFileSync(path.join(output, 'index.html'), homePage());
fs.writeFileSync(path.join(output, '404.html'), notFoundPage());

function escapeHtml(value) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
}

function inline(value) {
  return escapeHtml(value)
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/  $/, '<br>');
}

function markdownToHtml(markdown) {
  const lines = markdown.replaceAll('\r\n', '\n').split('\n');
  const html = [];
  let paragraph = [];
  let listOpen = false;

  const flushParagraph = () => {
    if (!paragraph.length) return;
    html.push(`<p>${inline(paragraph.join(' '))}</p>`);
    paragraph = [];
  };
  const closeList = () => {
    if (!listOpen) return;
    html.push('</ul>');
    listOpen = false;
  };

  for (const raw of lines) {
    const line = raw.trimEnd();
    const heading = line.match(/^(#{1,3})\s+(.+)$/);
    if (heading) {
      flushParagraph();
      closeList();
      const level = heading[1].length;
      if (level > 1) html.push(`<h${level}>${inline(heading[2])}</h${level}>`);
      continue;
    }
    const item = line.match(/^-\s+(.+)$/);
    if (item) {
      flushParagraph();
      if (!listOpen) {
        html.push('<ul>');
        listOpen = true;
      }
      html.push(`<li>${inline(item[1])}</li>`);
      continue;
    }
    if (!line.trim()) {
      flushParagraph();
      closeList();
      continue;
    }
    paragraph.push(line.trim());
  }
  flushParagraph();
  closeList();
  return html.join('\n');
}

function navigation(active = '') {
  const link = (slug, label) =>
    `<a ${active === slug ? 'aria-current="page"' : ''} href="/${slug}.html">${label}</a>`;
  return `<header class="site-header">
    <a class="brand" href="/" aria-label="Campus Tour 法律與支援首頁">
      <span class="brand-mark">CT</span><span>Campus Tour</span>
    </a>
    <nav aria-label="主要導覽">
      ${link('terms', '服務條款')}${link('privacy', '隱私權')}${link('support', '支援')}
    </nav>
  </header>`;
}

function layout(page, content) {
  const canonical = `https://campus-tour-679e9.web.app/${page.slug}.html`;
  return `<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${page.title}｜Campus Tour</title>
  <meta name="description" content="${page.description}"><link rel="canonical" href="${canonical}">
  <link rel="stylesheet" href="/assets/legal.css">
</head>
<body>${navigation(page.slug)}
  <main>
    <section class="hero"><p class="eyebrow">${page.eyebrow}</p><h1>${page.title}</h1><p>${page.description}</p></section>
    <article class="document">${content}</article>
  </main>${footer()}
</body></html>`;
}

function homePage() {
  return `<!doctype html><html lang="zh-Hant"><head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>法律文件與支援｜Campus Tour</title><meta name="description" content="Campus Tour 使用者服務協議、隱私權政策與支援資訊。">
  <link rel="stylesheet" href="/assets/legal.css"></head><body>${navigation()}
  <main><section class="hero home"><p class="eyebrow">LEGAL & SUPPORT</p><h1>透明、安心地探索校園</h1><p>在這裡查看 Campus Tour 的服務規則、資料處理方式，以及取得使用協助。</p></section>
  <section class="cards" aria-label="法律文件與支援">
    ${card('terms', '使用者服務協議', '帳號責任、使用規則、安全提醒與服務條款。')}
    ${card('privacy', '隱私權政策', '帳號、定位、相機、第三方服務與資料權利。')}
    ${card('support', '支援中心', '登入、帳號刪除、權限及其他使用問題。')}
  </section></main>${footer()}</body></html>`;
}

function card(slug, title, description) {
  return `<a class="card" href="/${slug}.html"><span class="card-icon">${title.slice(0, 1)}</span><h2>${title}</h2><p>${description}</p><span class="arrow">查看內容 →</span></a>`;
}

function footer() {
  return `<footer><p>中央大學校園導覽團隊</p><a href="mailto:ideasky716@gmail.com">ideasky716@gmail.com</a><p>© 2026 Campus Tour</p></footer>`;
}

function notFoundPage() {
  return `<!doctype html><html lang="zh-Hant"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>找不到頁面｜Campus Tour</title><link rel="stylesheet" href="/assets/legal.css"></head><body>${navigation()}<main><section class="hero"><p class="eyebrow">404</p><h1>找不到這個頁面</h1><p><a href="/">返回法律與支援首頁</a></p></section></main>${footer()}</body></html>`;
}
