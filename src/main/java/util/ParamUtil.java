package util;

import jakarta.servlet.http.HttpServletRequest;

public class ParamUtil {

    /** Lấy String, trả về defaultValue nếu null hoặc rỗng */
    public static String getString(HttpServletRequest req, String name, String defaultValue) {
        String v = req.getParameter(name);
        return (v != null && !v.trim().isEmpty()) ? v.trim() : defaultValue;
    }

    public static String getString(HttpServletRequest req, String name) {
        return getString(req, name, "");
    }

    /** Lấy int, trả về defaultValue nếu lỗi */
    public static int getInt(HttpServletRequest req, String name, int defaultValue) {
        try {
            String v = req.getParameter(name);
            if (v == null || v.trim().isEmpty()) return defaultValue;
            return Integer.parseInt(v.trim());
        } catch (NumberFormatException e) { return defaultValue; }
    }

    public static int getInt(HttpServletRequest req, String name) {
        return getInt(req, name, 0);
    }

    /** Lấy long */
    public static long getLong(HttpServletRequest req, String name, long defaultValue) {
        try {
            String v = req.getParameter(name);
            if (v == null || v.trim().isEmpty()) return defaultValue;
            return Long.parseLong(v.trim());
        } catch (NumberFormatException e) { return defaultValue; }
    }

    /** Lấy double */
    public static double getDouble(HttpServletRequest req, String name, double defaultValue) {
        try {
            String v = req.getParameter(name);
            if (v == null || v.trim().isEmpty()) return defaultValue;
            return Double.parseDouble(v.trim());
        } catch (NumberFormatException e) { return defaultValue; }
    }

    public static double getDouble(HttpServletRequest req, String name) {
        return getDouble(req, name, 0.0);
    }

    /** Lấy boolean từ checkbox (on/true/1 = true) */
    public static boolean getBoolean(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return "on".equalsIgnoreCase(v) || "true".equalsIgnoreCase(v) || "1".equals(v);
    }

    /** Kiểm tra param tồn tại và không rỗng */
    public static boolean hasParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v != null && !v.trim().isEmpty();
    }

    /** Lấy java.sql.Date từ param dạng "yyyy-MM-dd" */
    public static java.sql.Date getDate(HttpServletRequest req, String name) {
        try {
            String v = req.getParameter(name);
            if (v == null || v.trim().isEmpty()) return null;
            return java.sql.Date.valueOf(v.trim());
        } catch (Exception e) { return null; }
    }

    /** Lấy String[] từ multiple params (checkbox, multi-select) */
    public static String[] getStrings(HttpServletRequest req, String name) {
        String[] v = req.getParameterValues(name);
        return v != null ? v : new String[0];
    }

    /** Lấy int[] từ multiple params */
    public static int[] getInts(HttpServletRequest req, String name) {
        String[] v = req.getParameterValues(name);
        if (v == null) return new int[0];
        int[] result = new int[v.length];
        for (int i = 0; i < v.length; i++) {
            try { result[i] = Integer.parseInt(v[i].trim()); }
            catch (NumberFormatException e) { result[i] = 0; }
        }
        return result;
    }
}
