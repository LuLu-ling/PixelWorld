// 安装器的原生外壳，用系统自带的 csc 编译，不依赖额外工具链：
// - 带 payload.zip 资源时：显示加载动画并解压，再启动 PCL.PW 的安装界面，结束后清理临时文件
// - 带 --cleanup 参数时：等启动器退出后按清单删除文件，再删除自身（程序不能删除运行中的自己）
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Text;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Windows.Forms;
using Microsoft.Win32;

static class Program
{
    const string AppExe = "PCL.PW.exe";

    [STAThread]
    static int Main(string[] args)
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        int code = 0;
        var form = new LoadingForm();
        Action<LoadingForm> work;
        if (args.Length == 2 && args[0] == "--cleanup")
        {
            form.Title = "正在卸载 PCL.PW";
            string plan = args[1];
            work = f => Cleanup(f, plan);
        }
        else
        {
            form.Title = "Pixel World";
            work = f => code = Install(f, args);
        }

        form.Shown += (s, e) =>
        {
            var t = new Thread(() =>
            {
                try
                {
                    work(form);
                }
                catch (OperationCanceledException)
                {
                    code = 1;
                }
                catch (Exception ex)
                {
                    code = 1;
                    MessageBox.Show(ex.Message, form.Title, MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                form.Finish();
            });
            t.IsBackground = true;
            t.Start();
        };
        Application.Run(form);
        return code;
    }

    // ---------- 安装 ----------

    static int Install(LoadingForm form, string[] args)
    {
        var payload = Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip");
        if (payload == null) throw new InvalidOperationException("安装包已损坏：找不到程序文件");

        string root = Path.Combine(Path.GetTempPath(), "PCL.PW-Setup-" + Guid.NewGuid().ToString("N"));
        try
        {
            string appDir = Path.Combine(root, "app");
            form.SetStatus("正在准备安装程序…", 0);
            Extract(form, payload, appDir);

            form.SetStatus("正在打开安装程序…", -1);
            string ready = Path.Combine(root, "ready");
            var extra = args.Select(a => "\"" + a + "\"");
            var info = new ProcessStartInfo(Path.Combine(appDir, AppExe))
            {
                UseShellExecute = false,
                WorkingDirectory = appDir,
                Arguments = "--pw-install \"--pw-ready=" + ready + "\" \"--pw-data=" + Path.Combine(root, "data") + "\" " + string.Join(" ", extra)
            };
            using (var p = Process.Start(info))
            {
                // 安装界面准备好后才收起动画，避免中间出现空档
                var limit = DateTime.Now.AddMinutes(2);
                while (!File.Exists(ready) && !p.HasExited && DateTime.Now < limit) Thread.Sleep(100);
                if (p.HasExited && !File.Exists(ready)) throw new InvalidOperationException("安装程序没能启动，退出代码 " + p.ExitCode);
                form.HideWindow();
                p.WaitForExit();
                return p.ExitCode;
            }
        }
        finally
        {
            form.HideWindow();
            DeleteTree(root);
        }
    }

    static void Extract(LoadingForm form, Stream payload, string dir)
    {
        using (var zip = new ZipArchive(payload, ZipArchiveMode.Read))
        {
            long total = zip.Entries.Sum(e => e.Length), done = 0;
            var buffer = new byte[256 * 1024];
            string rootDir = Path.GetFullPath(dir) + Path.DirectorySeparatorChar;
            foreach (var entry in zip.Entries)
            {
                form.ThrowIfCancelled();
                string target = Path.GetFullPath(Path.Combine(dir, entry.FullName.Replace('/', '\\')));
                if (!target.StartsWith(rootDir, StringComparison.OrdinalIgnoreCase) && target + "\\" != rootDir) continue;
                if (entry.FullName.EndsWith("/"))
                {
                    Directory.CreateDirectory(target);
                    continue;
                }
                Directory.CreateDirectory(Path.GetDirectoryName(target));
                using (var input = entry.Open())
                using (var output = File.Create(target))
                {
                    int n;
                    while ((n = input.Read(buffer, 0, buffer.Length)) > 0)
                    {
                        output.Write(buffer, 0, n);
                        done += n;
                        form.SetProgress(total > 0 ? (float)done / total : 0);
                    }
                }
            }
        }
    }

    static void DeleteTree(string dir)
    {
        // 安装界面进程可能比预期晚一点退出
        for (int i = 0; i < 20 && Directory.Exists(dir); i++)
        {
            try
            {
                Directory.Delete(dir, true);
            }
            catch (Exception)
            {
                Thread.Sleep(500);
            }
        }
    }

    // ---------- 卸载 ----------

    static void Cleanup(LoadingForm form, string planFile)
    {
        var files = new List<string>();
        var dirs = new List<string>();
        var trees = new List<string>();
        string regKey = null;
        int pid = 0;
        foreach (string line in File.ReadAllLines(planFile))
        {
            int tab = line.IndexOf('\t');
            if (tab < 0) continue;
            string k = line.Substring(0, tab), v = line.Substring(tab + 1);
            if (k == "pid") pid = int.Parse(v);
            else if (k == "file") files.Add(v);
            else if (k == "dir") dirs.Add(v);
            else if (k == "tree") trees.Add(v);
            else if (k == "key") regKey = v;
        }

        form.SetStatus("正在等待启动器退出…", -1);
        try
        {
            using (var p = Process.GetProcessById(pid)) p.WaitForExit(30000);
        }
        catch (ArgumentException)
        {
            // 已经退出
        }

        int failed = 0;
        for (int i = 0; i < files.Count; i++)
        {
            form.SetStatus("正在删除文件…", (float)i / Math.Max(1, files.Count));
            if (!TryDeleteFile(files[i])) failed++;
        }
        foreach (string d in dirs.OrderByDescending(x => x.Length))
        {
            try
            {
                // 只删空文件夹：用户放在里面的文件（例如 .minecraft）不在清单中，不能动
                if (Directory.Exists(d)) Directory.Delete(d, false);
            }
            catch (IOException) { }
            catch (UnauthorizedAccessException) { }
        }
        form.SetStatus("正在清理…", -1);
        foreach (string t in trees) DeleteTree(t);
        if (regKey != null) RunHidden("reg.exe", "delete \"" + regKey + "\" /f", true);
        TryDeleteFile(planFile);

        form.SetDone(failed == 0 ? "卸载完成" : "卸载完成，有 " + failed + " 个文件没能删除");
        Thread.Sleep(failed == 0 ? 1500 : 4000);

        // 让 cmd 等本程序退出后删除它
        string self = Assembly.GetExecutingAssembly().Location;
        RunHidden("cmd.exe", "/d /c ping -n 3 127.0.0.1 >nul & del /q \"" + self + "\"", false);
    }

    static bool TryDeleteFile(string file)
    {
        for (int i = 0; i < 5; i++)
        {
            try
            {
                if (File.Exists(file)) File.Delete(file);
                return true;
            }
            catch (IOException)
            {
                Thread.Sleep(300);
            }
            catch (UnauthorizedAccessException)
            {
                Thread.Sleep(300);
            }
        }
        return false;
    }

    static void RunHidden(string exe, string arguments, bool wait)
    {
        var info = new ProcessStartInfo(exe, arguments) { CreateNoWindow = true, UseShellExecute = false };
        using (var p = Process.Start(info))
        {
            if (wait) p.WaitForExit();
        }
    }
}

/// <summary>无边框的加载窗口，绘制 MD3 的环形进度指示器和线性进度条</summary>
sealed class LoadingForm : Form
{
    const float Cycle = 1.6f;

    readonly System.Windows.Forms.Timer timer = new System.Windows.Forms.Timer { Interval = 16 };
    readonly Stopwatch clock = Stopwatch.StartNew();
    readonly Font titleFont;
    readonly Font statusFont;
    readonly Color surface, onSurface, onSurfaceVariant, primary, track, tertiary, secondary;
    readonly float scale;

    volatile string status = "";
    volatile bool done;
    volatile bool cancelled;
    // 显示用的进度会平滑地追赶实际进度；负数表示无法确定进度
    float progress = -1;
    float shown;

    public string Title { get; set; }

    public LoadingForm()
    {
        bool dark = IsDark();
        surface = dark ? Theme.DarkSurface : Theme.LightSurface;
        onSurface = dark ? Theme.DarkOnSurface : Theme.LightOnSurface;
        onSurfaceVariant = dark ? Theme.DarkOnSurfaceVariant : Theme.LightOnSurfaceVariant;
        primary = dark ? Theme.DarkPrimary : Theme.LightPrimary;
        track = dark ? Theme.DarkTrack : Theme.LightTrack;
        tertiary = dark ? Theme.DarkTertiary : Theme.LightTertiary;
        secondary = dark ? Theme.DarkSecondary : Theme.LightSecondary;

        using (var g = CreateGraphics()) scale = g.DpiX / 96f;
        FormBorderStyle = FormBorderStyle.None;
        StartPosition = FormStartPosition.CenterScreen;
        ClientSize = new Size(S(380), S(216));
        BackColor = surface;
        ShowInTaskbar = true;
        Text = "Pixel World";
        DoubleBuffered = true;
        SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.OptimizedDoubleBuffer, true);
        titleFont = new Font("Microsoft YaHei UI", 12.5f, FontStyle.Regular);
        statusFont = new Font("Microsoft YaHei UI", 9f, FontStyle.Regular);
        timer.Tick += (s, e) => Invalidate();
    }

    int S(float v)
    {
        return (int)Math.Round(v * scale);
    }

    static bool IsDark()
    {
        try
        {
            using (var key = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"))
            {
                object v = key == null ? null : key.GetValue("AppsUseLightTheme");
                return v is int && (int)v == 0;
            }
        }
        catch (Exception)
        {
            return false;
        }
    }

    protected override CreateParams CreateParams
    {
        get
        {
            var cp = base.CreateParams;
            cp.ClassStyle |= 0x00020000; // CS_DROPSHADOW
            return cp;
        }
    }

    protected override void OnHandleCreated(EventArgs e)
    {
        base.OnHandleCreated(e);
        timer.Start();
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        // 构造时已经创建了句柄（为了取 DPI），StartPosition 不再生效，手动居中
        var area = Screen.PrimaryScreen.WorkingArea;
        Location = new Point(area.X + (area.Width - Width) / 2, area.Y + (area.Height - Height) / 2);
        using (var shape = Rounded(new RectangleF(0, 0, Width, Height), S(20))) Region = new Region(shape);
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        cancelled = true;
        base.OnFormClosing(e);
    }

    public void ThrowIfCancelled()
    {
        if (cancelled) throw new OperationCanceledException();
    }

    public void SetStatus(string text, float value)
    {
        status = text;
        progress = value;
        if (value <= 0) shown = 0;
    }

    public void SetProgress(float value)
    {
        progress = value;
    }

    public void SetDone(string text)
    {
        Title = "Pixel World";
        status = text;
        progress = 1;
        done = true;
    }

    public void HideWindow()
    {
        if (IsHandleCreated) BeginInvoke((Action)Hide);
    }

    public void Finish()
    {
        if (IsHandleCreated) BeginInvoke((Action)Close);
    }

    static float Ease(float t)
    {
        // MD3 的 emphasized 缓动的近似
        return t < 0.5f ? 4 * t * t * t : 1 - (float)Math.Pow(-2 * t + 2, 3) / 2;
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        var g = e.Graphics;
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.TextRenderingHint = TextRenderingHint.ClearTypeGridFit;
        g.Clear(surface);

        DrawLogo(g, S(24), S(24), S(20));

        float size = S(44), cx = ClientSize.Width / 2f, cy = S(78);
        var box = new RectangleF(cx - size / 2, cy - size / 2, size, size);
        using (var pen = new Pen(primary, S(4)) { StartCap = LineCap.Round, EndCap = LineCap.Round })
        {
            if (done)
            {
                g.DrawArc(pen, box, 0, 359.9f);
                using (var check = new Pen(primary, S(4)) { StartCap = LineCap.Round, EndCap = LineCap.Round, LineJoin = LineJoin.Round })
                {
                    g.DrawLines(check, new[]
                    {
                        new PointF(cx - S(9), cy + S(1)),
                        new PointF(cx - S(2), cy + S(8)),
                        new PointF(cx + S(10), cy - S(7))
                    });
                }
            }
            else
            {
                // 弧的头部先伸长，尾部再追上，整体持续旋转
                float t = (float)clock.Elapsed.TotalSeconds;
                float phase = (t % Cycle) / Cycle;
                float turns = (float)Math.Floor(t / Cycle);
                float start = t * 200 + turns * 250;
                float sweep;
                if (phase < 0.5f)
                {
                    sweep = 20 + 250 * Ease(phase * 2);
                }
                else
                {
                    float k = Ease((phase - 0.5f) * 2);
                    start += 250 * k;
                    sweep = 270 - 250 * k;
                }
                g.DrawArc(pen, box, start % 360, sweep);
            }
        }

        var center = new StringFormat { Alignment = StringAlignment.Center, Trimming = StringTrimming.EllipsisCharacter };
        var titleBox = new RectangleF(S(16), S(116), ClientSize.Width - S(32), S(28));
        using (var b = new SolidBrush(onSurface)) g.DrawString(Title ?? "", titleFont, b, titleBox, center);
        var statusBox = new RectangleF(S(16), S(146), ClientSize.Width - S(32), S(22));
        using (var b = new SolidBrush(onSurfaceVariant)) g.DrawString(status ?? "", statusFont, b, statusBox, center);

        DrawBar(g, S(40), S(182), ClientSize.Width - S(80), S(4));
    }

    void DrawLogo(Graphics g, float x, float y, float size)
    {
        float half = size / 2;
        var state = g.Save();
        using (var clip = Rounded(new RectangleF(x, y, size, size), S(5))) g.SetClip(clip);
        using (var b = new SolidBrush(primary)) g.FillRectangle(b, x, y, half, half);
        using (var b = new SolidBrush(tertiary)) g.FillRectangle(b, x + half, y, half, half);
        using (var b = new SolidBrush(secondary)) g.FillRectangle(b, x, y + half, half, half);
        using (var b = new SolidBrush(track)) g.FillRectangle(b, x + half, y + half, half, half);
        g.Restore(state);
    }

    void DrawBar(Graphics g, float x, float y, float width, float height)
    {
        using (var path = Rounded(new RectangleF(x, y, width, height), height / 2))
        using (var b = new SolidBrush(track))
        {
            g.FillPath(b, path);
        }
        float p = progress;
        RectangleF fill;
        if (p < 0)
        {
            // 无法确定进度时，一段滑块来回循环
            float t = (float)(clock.Elapsed.TotalSeconds % 1.5) / 1.5f;
            float head = Ease(Math.Min(1, t * 1.25f)), tail = Ease(Math.Max(0, t * 1.25f - 0.25f));
            fill = new RectangleF(x + width * tail, y, Math.Max(height, width * (head - tail)), height);
        }
        else
        {
            shown += (p - shown) * 0.18f;
            fill = new RectangleF(x, y, Math.Max(height, width * shown), height);
        }
        using (var path = Rounded(fill, height / 2))
        using (var b = new SolidBrush(primary))
        {
            g.FillPath(b, path);
        }
    }

    static GraphicsPath Rounded(RectangleF r, float radius)
    {
        float d = Math.Min(radius * 2, Math.Min(r.Width, r.Height));
        var path = new GraphicsPath();
        path.AddArc(r.X, r.Y, d, d, 180, 90);
        path.AddArc(r.Right - d, r.Y, d, d, 270, 90);
        path.AddArc(r.Right - d, r.Bottom - d, d, d, 0, 90);
        path.AddArc(r.X, r.Bottom - d, d, d, 90, 90);
        path.CloseFigure();
        return path;
    }
}
