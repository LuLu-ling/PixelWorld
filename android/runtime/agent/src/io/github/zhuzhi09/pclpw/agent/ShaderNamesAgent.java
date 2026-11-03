package io.github.zhuzhi09.pclpw.agent;

import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.ByteArrayInputStream;
import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.Instrumentation;
import java.security.ProtectionDomain;
import java.util.HashMap;
import java.util.Map;

/**
 * Java agent for Minecraft 26.x on MobileGlues (part of the PCL.PW runtime, LGPL-3.0).
 *
 * <p>26.x's OpenGL backend compiles shaders to SPIR-V and back to GLSL, naming uniform blocks
 * {@code _uniform_00_00} and their instances {@code _uniform_instance_00_00}. MobileGlues
 * ({@code process_uniform_declarations} in glsl_for_es.cpp) finds the keyword "uniform" without
 * checking word boundaries, treats those names as declarations and rewrites them into invalid
 * GLSL, so the terrain shaders fail to compile. This agent renames the two format strings, in
 * the classes that declare and the classes that look up the blocks, to names without "uniform".
 *
 * <p>Only string constants in the class files of the OpenGL backend are changed, while they load.
 */
public final class ShaderNamesAgent implements ClassFileTransformer {
    private static final String PACKAGE = "com/mojang/renderpearl/backend/opengl/";
    private static final Map<String, String> RENAMES = new HashMap<>();

    static {
        RENAMES.put("_uniform_%02d_%02d", "_ublk_%02d_%02d");
        RENAMES.put("_uniform_instance_%02d_%02d", "_ublk_inst_%02d_%02d");
    }

    public static void premain(String args, Instrumentation inst) {
        // The launcher bridge (CallbackBridge natives, e.g. the SDL_Init notification) lives in
        // libpojavexec, which only the GLFW stub loads. 26.x never touches GLFW, so load it here.
        try {
            System.loadLibrary("pojavexec");
        } catch (Throwable e) {
            System.out.println("[PCL.PW] Cannot load pojavexec: " + e);
        }
        inst.addTransformer(new ShaderNamesAgent());
    }

    @Override
    public byte[] transform(ClassLoader loader, String className, Class<?> redefined,
                            ProtectionDomain domain, byte[] bytes) {
        if (className == null || !className.startsWith(PACKAGE)) return null;
        try {
            byte[] out = renameStrings(bytes);
            if (out != null) System.out.println("[PCL.PW] Renamed shader uniform names in " + className);
            return out;
        } catch (Throwable e) {
            System.out.println("[PCL.PW] Cannot patch " + className + ": " + e);
            return null;
        }
    }

    /** Rewrites matching UTF8 constants; returns null if nothing changed */
    static byte[] renameStrings(byte[] bytes) throws IOException {
        DataInputStream in = new DataInputStream(new ByteArrayInputStream(bytes));
        ByteArrayOutputStream buffer = new ByteArrayOutputStream(bytes.length + 64);
        DataOutputStream out = new DataOutputStream(buffer);
        out.writeInt(in.readInt()); // magic
        out.writeShort(in.readUnsignedShort()); // minor
        out.writeShort(in.readUnsignedShort()); // major
        int count = in.readUnsignedShort();
        out.writeShort(count);
        boolean changed = false;
        for (int i = 1; i < count; i++) {
            int tag = in.readUnsignedByte();
            out.writeByte(tag);
            switch (tag) {
                case 1: { // Utf8
                    String s = in.readUTF();
                    String r = RENAMES.get(s);
                    if (r != null) {
                        s = r;
                        changed = true;
                    }
                    out.writeUTF(s);
                    break;
                }
                case 3: case 4: // Integer, Float
                case 9: case 10: case 11: case 12: // refs, NameAndType
                case 17: case 18: // Dynamic, InvokeDynamic
                    copy(in, out, 4);
                    break;
                case 5: case 6: // Long, Double take two slots
                    copy(in, out, 8);
                    i++;
                    break;
                case 7: case 8: case 16: case 19: case 20: // Class, String, MethodType, Module, Package
                    copy(in, out, 2);
                    break;
                case 15: // MethodHandle
                    copy(in, out, 3);
                    break;
                default:
                    throw new IOException("Unknown constant pool tag " + tag);
            }
        }
        if (!changed) return null;
        // Nothing after the constant pool refers to byte offsets inside it
        byte[] rest = new byte[in.available()];
        in.readFully(rest);
        out.write(rest);
        out.flush();
        return buffer.toByteArray();
    }

    private static void copy(DataInputStream in, DataOutputStream out, int n) throws IOException {
        byte[] b = new byte[n];
        in.readFully(b);
        out.write(b);
    }
}
