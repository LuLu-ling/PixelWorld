package io.github.zhuzhi09.pclpw.runtime;

import android.util.SparseIntArray;
import android.view.KeyEvent;

import static net.kdt.pojavlaunch.LwjglGlfwKeycode.*;

/** Android key codes to GLFW key codes, for physical keyboards */
final class Keys {
    private Keys() {}

    private static final SparseIntArray MAP = new SparseIntArray();

    static {
        for (int i = 0; i < 26; i++) MAP.put(KeyEvent.KEYCODE_A + i, GLFW_KEY_A + i);
        for (int i = 0; i < 10; i++) MAP.put(KeyEvent.KEYCODE_0 + i, GLFW_KEY_0 + i);
        for (int i = 0; i < 12; i++) MAP.put(KeyEvent.KEYCODE_F1 + i, GLFW_KEY_F1 + i);
        for (int i = 0; i < 10; i++) MAP.put(KeyEvent.KEYCODE_NUMPAD_0 + i, GLFW_KEY_KP_0 + i);
        int[][] pairs = {
                {KeyEvent.KEYCODE_SPACE, GLFW_KEY_SPACE},
                {KeyEvent.KEYCODE_ENTER, GLFW_KEY_ENTER},
                {KeyEvent.KEYCODE_NUMPAD_ENTER, GLFW_KEY_KP_ENTER},
                {KeyEvent.KEYCODE_ESCAPE, GLFW_KEY_ESCAPE},
                {KeyEvent.KEYCODE_DEL, GLFW_KEY_BACKSPACE},
                {KeyEvent.KEYCODE_FORWARD_DEL, GLFW_KEY_DELETE},
                {KeyEvent.KEYCODE_TAB, GLFW_KEY_TAB},
                {KeyEvent.KEYCODE_SHIFT_LEFT, GLFW_KEY_LEFT_SHIFT},
                {KeyEvent.KEYCODE_SHIFT_RIGHT, GLFW_KEY_RIGHT_SHIFT},
                {KeyEvent.KEYCODE_CTRL_LEFT, GLFW_KEY_LEFT_CONTROL},
                {KeyEvent.KEYCODE_CTRL_RIGHT, GLFW_KEY_RIGHT_CONTROL},
                {KeyEvent.KEYCODE_ALT_LEFT, GLFW_KEY_LEFT_ALT},
                {KeyEvent.KEYCODE_ALT_RIGHT, GLFW_KEY_RIGHT_ALT},
                {KeyEvent.KEYCODE_CAPS_LOCK, GLFW_KEY_CAPS_LOCK},
                {KeyEvent.KEYCODE_DPAD_UP, GLFW_KEY_UP},
                {KeyEvent.KEYCODE_DPAD_DOWN, GLFW_KEY_DOWN},
                {KeyEvent.KEYCODE_DPAD_LEFT, GLFW_KEY_LEFT},
                {KeyEvent.KEYCODE_DPAD_RIGHT, GLFW_KEY_RIGHT},
                {KeyEvent.KEYCODE_PAGE_UP, GLFW_KEY_PAGE_UP},
                {KeyEvent.KEYCODE_PAGE_DOWN, GLFW_KEY_PAGE_DOWN},
                {KeyEvent.KEYCODE_MOVE_HOME, GLFW_KEY_HOME},
                {KeyEvent.KEYCODE_MOVE_END, GLFW_KEY_END},
                {KeyEvent.KEYCODE_INSERT, GLFW_KEY_INSERT},
                {KeyEvent.KEYCODE_MINUS, GLFW_KEY_MINUS},
                {KeyEvent.KEYCODE_EQUALS, GLFW_KEY_EQUAL},
                {KeyEvent.KEYCODE_LEFT_BRACKET, GLFW_KEY_LEFT_BRACKET},
                {KeyEvent.KEYCODE_RIGHT_BRACKET, GLFW_KEY_RIGHT_BRACKET},
                {KeyEvent.KEYCODE_BACKSLASH, GLFW_KEY_BACKSLASH},
                {KeyEvent.KEYCODE_SEMICOLON, GLFW_KEY_SEMICOLON},
                {KeyEvent.KEYCODE_APOSTROPHE, GLFW_KEY_APOSTROPHE},
                {KeyEvent.KEYCODE_GRAVE, GLFW_KEY_GRAVE_ACCENT},
                {KeyEvent.KEYCODE_COMMA, GLFW_KEY_COMMA},
                {KeyEvent.KEYCODE_PERIOD, GLFW_KEY_PERIOD},
                {KeyEvent.KEYCODE_SLASH, GLFW_KEY_SLASH},
        };
        for (int[] p : pairs) MAP.put(p[0], p[1]);
    }

    /** 0 when the key has no GLFW equivalent */
    static int toGlfw(int androidKeyCode) {
        return MAP.get(androidKeyCode, 0);
    }
}
