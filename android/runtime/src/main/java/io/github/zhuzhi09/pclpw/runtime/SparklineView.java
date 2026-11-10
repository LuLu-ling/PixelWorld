package io.github.zhuzhi09.pclpw.runtime;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Shader;
import android.view.View;

/** A small filled line chart for the frame-rate history in the HUD. */
final class SparklineView extends View {

    private static final int ACCENT = 0xFF4A4A4A;
    private static final int GRID = 0x1F000000;

    private final float[] values = new float[60];
    private int count;
    private int next;

    private final Paint line = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint fill = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint grid = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Path path = new Path();

    SparklineView(Context context) {
        super(context);
        line.setStyle(Paint.Style.STROKE);
        line.setStrokeWidth(dp(1.8f));
        line.setStrokeCap(Paint.Cap.ROUND);
        line.setStrokeJoin(Paint.Join.ROUND);
        line.setColor(ACCENT);
        fill.setStyle(Paint.Style.FILL);
        grid.setStyle(Paint.Style.STROKE);
        grid.setStrokeWidth(dp(1));
        grid.setColor(GRID);
    }

    private float dp(float v) {
        return v * getResources().getDisplayMetrics().density;
    }

    void add(float fps) {
        values[next] = Math.max(0, fps);
        next = (next + 1) % values.length;
        if (count < values.length) count++;
        invalidate();
    }

    void clear() {
        count = 0;
        next = 0;
        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        float w = getWidth();
        float h = getHeight();
        if (w <= 0 || h <= 0) return;
        float pad = dp(2);
        canvas.drawLine(pad, h / 2f, w - pad, h / 2f, grid);
        if (count < 2) return;

        float max = 60;
        for (int i = 0; i < count; i++) {
            if (values[i] > max) max = values[i];
        }
        max = (float) (Math.ceil(max / 30f) * 30f);

        path.reset();
        for (int i = 0; i < count; i++) {
            int index = (next - count + i + values.length) % values.length;
            float x = pad + i * (w - 2 * pad) / Math.max(1, count - 1);
            float y = h - pad - (values[index] / max) * (h - 2 * pad);
            if (i == 0) path.moveTo(x, y);
            else path.lineTo(x, y);
        }
        canvas.drawPath(path, line);

        // Fill under the line with a soft gradient.
        path.lineTo(w - pad, h - pad);
        path.lineTo(pad, h - pad);
        path.close();
        fill.setShader(new LinearGradient(0, pad, 0, h - pad, 0x224A4A4A, 0x004A4A4A, Shader.TileMode.CLAMP));
        canvas.drawPath(path, fill);
    }
}
