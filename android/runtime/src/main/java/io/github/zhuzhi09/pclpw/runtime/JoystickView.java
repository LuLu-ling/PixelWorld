package io.github.zhuzhi09.pclpw.runtime;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.view.MotionEvent;
import android.view.View;

import net.kdt.pojavlaunch.LwjglGlfwKeycode;

import org.lwjgl.glfw.CallbackBridge;

/**
 * Movement joystick: holds W/A/S/D for the direction (8 directions) and sprints
 * (left Ctrl) when pushed to the outer ring.
 */
public class JoystickView extends View {
    private static final float DEAD_ZONE = 0.25f;
    private static final float SPRINT_ZONE = 0.92f;

    private final Paint base = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint ring = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint knob = new Paint(Paint.ANTI_ALIAS_FLAG);
    private float knobX, knobY;
    private int pointer = -1;
    private boolean w, a, s, d, sprint;

    public JoystickView(Context context) {
        super(context);
        base.setColor(0x40000000);
        ring.setStyle(Paint.Style.STROKE);
        ring.setStrokeWidth(getResources().getDisplayMetrics().density * 1.5f);
        ring.setColor(0x88FFFFFF);
        knob.setColor(0xAAFFFFFF);
    }

    private float radius() {
        return Math.min(getWidth(), getHeight()) / 2f;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        float cx = getWidth() / 2f, cy = getHeight() / 2f, r = radius();
        canvas.drawCircle(cx, cy, r - ring.getStrokeWidth(), base);
        canvas.drawCircle(cx, cy, r - ring.getStrokeWidth(), ring);
        // Sprint ring
        ring.setAlpha(sprint ? 0xFF : 0x44);
        canvas.drawCircle(cx, cy, r * SPRINT_ZONE, ring);
        ring.setAlpha(0x88);
        canvas.drawCircle(cx + knobX, cy + knobY, r * 0.32f, knob);
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouchEvent(MotionEvent e) {
        switch (e.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                pointer = e.getPointerId(0);
                move(e.getX(), e.getY());
                return true;
            case MotionEvent.ACTION_MOVE: {
                int i = e.findPointerIndex(pointer);
                if (i >= 0) move(e.getX(i), e.getY(i));
                return true;
            }
            case MotionEvent.ACTION_POINTER_UP:
                if (e.getPointerId(e.getActionIndex()) != pointer) return true;
                // fall through
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                release();
                return true;
        }
        return true;
    }

    private void move(float x, float y) {
        float r = radius();
        float dx = x - getWidth() / 2f, dy = y - getHeight() / 2f;
        float dist = (float) Math.hypot(dx, dy);
        float limit = r * 0.68f;
        if (dist > limit) {
            knobX = dx / dist * limit;
            knobY = dy / dist * limit;
        } else {
            knobX = dx;
            knobY = dy;
        }
        float norm = Math.min(1f, dist / limit);
        boolean nw = false, na = false, ns = false, nd = false;
        if (norm > DEAD_ZONE) {
            // 8 directions, 45° sectors
            double angle = Math.toDegrees(Math.atan2(-dy, dx));
            if (angle < 0) angle += 360;
            int sector = (int) Math.round(angle / 45) % 8;
            nd = sector == 0 || sector == 1 || sector == 7;
            nw = sector == 1 || sector == 2 || sector == 3;
            na = sector == 3 || sector == 4 || sector == 5;
            ns = sector == 5 || sector == 6 || sector == 7;
        }
        // Sprint only when pushing forward to the edge
        boolean nsprint = nw && dist >= r * SPRINT_ZONE;
        apply(nw, na, ns, nd, nsprint);
        invalidate();
    }

    private void release() {
        pointer = -1;
        knobX = knobY = 0;
        apply(false, false, false, false, false);
        invalidate();
    }

    private void apply(boolean nw, boolean na, boolean ns, boolean nd, boolean nsprint) {
        if (nw != w) key(LwjglGlfwKeycode.GLFW_KEY_W, w = nw);
        if (na != a) key(LwjglGlfwKeycode.GLFW_KEY_A, a = na);
        if (ns != s) key(LwjglGlfwKeycode.GLFW_KEY_S, s = ns);
        if (nd != d) key(LwjglGlfwKeycode.GLFW_KEY_D, d = nd);
        if (nsprint != sprint) key(LwjglGlfwKeycode.GLFW_KEY_LEFT_CONTROL, sprint = nsprint);
    }

    private static void key(int key, boolean down) {
        CallbackBridge.setModifiers(key, down);
        CallbackBridge.sendKeyPress(key, CallbackBridge.getCurrentMods(), down);
    }

    /** Releases all keys, e.g. when the game opens a menu */
    public void reset() {
        if (pointer != -1 || w || a || s || d || sprint) release();
    }
}
