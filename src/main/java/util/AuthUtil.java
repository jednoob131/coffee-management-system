package util;

import entity.User;
import Dao.UserDao;
import Daoimpl.UserDaoImpl;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import jakarta.servlet.http.Cookie;

public class AuthUtil {
    private static final String REMEMBER_ME_COOKIE = "REMEMBER_ME";
    private static final int REMEMBER_ME_MAX_AGE = 7 * 24 * 60 * 60; // 7 ngày
    private static final int SESSION_TIMEOUT_SECONDS = 5 * 60; // 5 phút
    private static final String REMEMBER_ME_SECRET = "Tesst_Remember_Me_Secret_2026";

    /** Lấy user đang đăng nhập từ session */
    public static User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("user");
    }

    /** Kiểm tra đã đăng nhập chưa */
    public static boolean isLoggedIn(HttpServletRequest req) {
        return getCurrentUser(req) != null;
    }

    /** Kiểm tra có phải Admin không (role = true) */
    public static boolean isAdmin(HttpServletRequest req) {
        User user = getCurrentUser(req);
        return user != null && user.isRole();
    }

    /** Kiểm tra có phải Staff không (role = false) */
    public static boolean isStaff(HttpServletRequest req) {
        User user = getCurrentUser(req);
        return user != null && !user.isRole();
    }

    /** Đăng nhập: lưu user vào session */
    public static void login(HttpServletRequest req, User user) {
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(SESSION_TIMEOUT_SECONDS);
    }

    public static void login(HttpServletRequest req, User user, int maxInactiveInterval) {
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(maxInactiveInterval);
    }

    public static void setRememberMeCookie(HttpServletRequest req, HttpServletResponse resp, User user) {
        long expiresAt = (System.currentTimeMillis() / 1000L) + REMEMBER_ME_MAX_AGE;
        String payload = user.getUsername() + ":" + expiresAt;
        String signature = hmacSha256(payload, REMEMBER_ME_SECRET);
        String token = Base64.getUrlEncoder().withoutPadding()
                .encodeToString((payload + ":" + signature).getBytes(StandardCharsets.UTF_8));

        Cookie cookie = new Cookie(REMEMBER_ME_COOKIE, token);
        cookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
        cookie.setHttpOnly(true);
        cookie.setSecure(req.isSecure());
        cookie.setMaxAge(REMEMBER_ME_MAX_AGE);
        resp.addCookie(cookie);
    }

    public static void clearRememberMeCookie(HttpServletRequest req, HttpServletResponse resp) {
        Cookie cookie = new Cookie(REMEMBER_ME_COOKIE, "");
        cookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
        cookie.setHttpOnly(true);
        cookie.setSecure(req.isSecure());
        cookie.setMaxAge(0);
        resp.addCookie(cookie);
    }

    public static boolean restoreLoginFromRememberCookie(HttpServletRequest req) {
        if (isLoggedIn(req)) return true;

        Cookie[] cookies = req.getCookies();
        if (cookies == null) return false;

        String token = null;
        for (Cookie c : cookies) {
            if (REMEMBER_ME_COOKIE.equals(c.getName())) {
                token = c.getValue();
                break;
            }
        }

        if (token == null || token.trim().isEmpty()) return false;

        try {
            String decoded = new String(Base64.getUrlDecoder().decode(token), StandardCharsets.UTF_8);
            String[] parts = decoded.split(":");
            if (parts.length != 3) return false;

            String username = parts[0];
            long expiresAt = Long.parseLong(parts[1]);
            String signature = parts[2];

            if ((System.currentTimeMillis() / 1000L) > expiresAt) return false;

            String expectedSignature = hmacSha256(username + ":" + expiresAt, REMEMBER_ME_SECRET);
            if (!expectedSignature.equals(signature)) return false;

            UserDao dao = new UserDaoImpl();
            User user = dao.findByUsername(username);
            if (user == null) return false;

            login(req, user, SESSION_TIMEOUT_SECONDS);
            return true;
        } catch (Exception ignored) {
            return false;
        }
    }

    public static int getRememberMeMaxAge() {
        return REMEMBER_ME_MAX_AGE;
    }

    private static String hmacSha256(String value, String secret) {
        try {
            Mac hmac = Mac.getInstance("HmacSHA256");
            SecretKeySpec key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
            hmac.init(key);
            byte[] bytes = hmac.doFinal(value.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        } catch (Exception e) {
            throw new IllegalStateException("Cannot sign remember-me token", e);
        }
    }

    /**
     * Trang cần đăng nhập: không cho browser cache (tránh Back sau logout vẫn thấy home).
     */
    public static void setNoStoreCacheHeaders(HttpServletResponse resp) {
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);
    }

    /** Đăng xuất: hủy session + xóa cache browser */
    public static void logout(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();
        clearRememberMeCookie(req, resp);
        setNoStoreCacheHeaders(resp);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    /**
     * Yêu cầu đăng nhập.
     * Trả về true nếu đã login, false + redirect /login nếu chưa.
     */
    public static boolean requireLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    /**
     * Yêu cầu quyền Admin.
     * Trả về true nếu là admin, false + redirect /index nếu không.
     */
    public static boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/index");
            return false;
        }
        return true;
    }

    /** Lấy username của user hiện tại */
    public static String getCurrentUsername(HttpServletRequest req) {
        User user = getCurrentUser(req);
        return user != null ? user.getUsername() : null;
    }
}
