// 所有效果图共用：顶部页面切换、侧栏跳转、按屏幕缩放、左右分界线对齐「后台任务」右边缘
(function () {
  const PAGES = [
    ["index.html", "首页"], ["download.html", "下载"], ["instance.html", "版本详情"],
    ["settings.html", "设置"], ["tools.html", "工具"], ["ai.html", "AI 助手"],
  ];
  const here = (location.pathname.split("/").pop() || "index.html");
  // 首页、下载页没有引用 base.css，这里补上页面切换条的样式
  const st = document.createElement("style");
  st.textContent = ".pagesw{display:flex;flex-wrap:wrap;justify-content:center;gap:4px;background:#1b1e1c;padding:4px;border-radius:12px}" +
    ".pagesw a{color:#a3ada5;text-decoration:none;font-size:14px;padding:9px 14px;border-radius:9px;font-family:system-ui,'Noto Sans SC',sans-serif}" +
    ".pagesw a.on{background:#2c5a3a;color:#c8f0d2}";
  document.head.appendChild(st);
  const sw = document.createElement("div");
  sw.className = "pagesw";
  PAGES.forEach(([href, name]) => {
    const a = document.createElement("a");
    a.href = href;
    a.textContent = name;
    if (href === here) a.className = "on";
    sw.appendChild(a);
  });
  const page = document.querySelector(".page");
  if (page) page.insertBefore(sw, page.firstChild);

  // 侧栏：data-href 的导航项可以直接点过去
  document.querySelectorAll("[data-href]").forEach((el) => {
    el.style.cursor = "pointer";
    el.addEventListener("click", () => { location.href = el.dataset.href; });
  });

  const phone = document.getElementById("phone");
  function fit() {
    if (!phone) return;
    const top = phone.getBoundingClientRect().top + window.scrollY;
    const s = Math.min(1.6, (window.innerWidth - 32) / 914, (window.innerHeight - top - 30) / 411);
    phone.style.transform = "scale(" + s + ")";
    phone.style.marginBottom = (411 * s - 411) + "px";
    phone.style.marginRight = phone.style.marginLeft = ((914 * s - 914) / 2) + "px";
    align();
  }
  function align() {
    const t = document.getElementById("tasks");
    if (!t || !phone) return;
    const s = phone.getBoundingClientRect().width / 914;
    document.querySelectorAll("[data-align]").forEach((el) => {
      el.style.flex = "0 0 " + Math.round((t.getBoundingClientRect().right - el.getBoundingClientRect().left) / s) + "px";
    });
  }
  window.addEventListener("resize", fit);
  window.addEventListener("load", fit);
  fit();

  // 子视图切换：.subsw button[data-show] 显示对应 [data-view]
  document.querySelectorAll(".subsw button[data-show], .cat[data-show]").forEach((b) => b.addEventListener("click", () => {
    const v = b.dataset.show;
    document.querySelectorAll("[data-show]").forEach((x) => x.classList.toggle("on", x.dataset.show === v));
    document.querySelectorAll("[data-view]").forEach((x) => x.classList.toggle("hidden", x.dataset.view !== v));
    align();
  }));
})();
