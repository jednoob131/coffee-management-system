package filter;

import util.AuthUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

public class AuthFilter implements Filter {

    /** URL chỉ dành cho khách (chưa đăng nhập): login, đăng ký, quên mật khẩu… */
    private static boolean isGuestOnlyPath(String fullPath) {
        if (fullPath == null) return false;
        if (fullPath.startsWith("/login/logout")) return false;
        if ("/login.jsp".equals(fullPath)) return true;
        if (fullPath.startsWith("/login")) return true;
        if ("/dangky.jsp".equals(fullPath)) return true;
        if ("/forgot-password.jsp".equals(fullPath)) return true;
        if ("/reset-password.jsp".equals(fullPath)) return true;
        if (fullPath.startsWith("/register")) return true;
        if (fullPath.startsWith("/forgot-password")) return true;
        if (fullPath.startsWith("/reset-password")) return true;
        return false;
    }

    private static final String[] PUBLIC_URLS = {
            "/login",
            "/register",
            "/forgot-password",
            "/dangky.jsp",
            "/login.jsp",
            "/forgot-password.jsp",
            "/reset-password"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String path     = req.getServletPath();
        String pathInfo = req.getPathInfo();
        String fullPath = pathInfo != null ? path + pathInfo : path;

        // Bỏ qua static resources
        if (fullPath.endsWith(".css") || fullPath.endsWith(".js")
                || fullPath.endsWith(".png") || fullPath.endsWith(".jpg")
                || fullPath.endsWith(".gif") || fullPath.endsWith(".ico")
                || fullPath.endsWith(".woff") || fullPath.endsWith(".woff2")) {
            chain.doFilter(request, response);
            return;
        }

        // Đã đăng nhập: không cho vào login / đăng ký / quên mật khẩu (trừ /login/logout)
        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            if (isGuestOnlyPath(fullPath)) {
                resp.sendRedirect(req.getContextPath() + "/index");
                return;
            }
        }

        // Public (trang khách): không cache — Back/bfcache phải gọi lại server để redirect nếu đã login
        for (String url : PUBLIC_URLS) {
            if (fullPath.startsWith(url)) {
                AuthUtil.setNoStoreCacheHeaders(resp);
                chain.doFilter(request, response);
                return;
            }
        }

        // Trang yêu cầu đăng nhập: không cache (Back sau logout không dùng bản cũ)
        AuthUtil.setNoStoreCacheHeaders(resp);
        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            chain.doFilter(request, response);
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }

    @Override public void init(FilterConfig f) {}
    @Override public void destroy() {}
}
