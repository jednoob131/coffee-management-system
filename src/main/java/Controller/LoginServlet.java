package Controller;

import java.io.IOException;
import Dao.UserDao;
import Daoimpl.UserDaoImpl;
import entity.User;
import util.AuthUtil;
import util.PasswordUtil;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/login/*")
public class LoginServlet extends HttpServlet {

    private static final int SESSION_TIMEOUT_DEFAULT = 5 * 60; // 5 phút
    private static final int REMEMBER_CREDENTIALS_MAX_AGE = 7 * 24 * 60 * 60; // 7 ngày
    private static final String COOKIE_REMEMBER_USERNAME = "REMEMBER_USERNAME";
    private static final String COOKIE_REMEMBER_PASSWORD = "REMEMBER_PASSWORD";

    private UserDao dao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo();

        if ("/logout".equals(path)) {
            AuthUtil.logout(req, resp);
            return;
        }

        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            resp.sendRedirect(req.getContextPath() + "/index");
            return;
        }

        loadRememberedCredentials(req);
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            resp.sendRedirect(req.getContextPath() + "/index");
            return;
        }

        String username = req.getParameter("username");
        String password = req.getParameter("password");
        boolean rememberMe = "true".equals(req.getParameter("rememberMe"));

        User user = dao.findByUsername(username);

        if (user == null) {
            keepFormState(req, username, password, rememberMe);
            req.setAttribute("error", "Sai tài khoản!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // so sánh bcrypt
        if (!PasswordUtil.checkPassword(password, user.getPassword())) {
            keepFormState(req, username, password, rememberMe);
            req.setAttribute("error", "Sai mật khẩu!");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        AuthUtil.login(req, user, SESSION_TIMEOUT_DEFAULT);
        if (rememberMe) {
            AuthUtil.setRememberMeCookie(req, resp, user);
            saveCredentialsCookies(req, resp, username, password);
        } else {
            AuthUtil.clearRememberMeCookie(req, resp);
            clearCredentialsCookies(req, resp);
        }

        AuthUtil.setNoStoreCacheHeaders(resp);
        resp.sendRedirect(req.getContextPath() + "/index");
    }

    private void loadRememberedCredentials(HttpServletRequest req) {
        String rememberedUsername = "";
        String rememberedPassword = "";
        Cookie[] cookies = req.getCookies();

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (COOKIE_REMEMBER_USERNAME.equals(cookie.getName())) {
                    rememberedUsername = urlDecode(cookie.getValue());
                } else if (COOKIE_REMEMBER_PASSWORD.equals(cookie.getName())) {
                    rememberedPassword = urlDecode(cookie.getValue());
                }
            }
        }

        req.setAttribute("rememberedUsername", rememberedUsername);
        req.setAttribute("rememberedPassword", rememberedPassword);
        req.setAttribute("rememberChecked",
                !rememberedUsername.isEmpty() || !rememberedPassword.isEmpty());
    }

    private void keepFormState(HttpServletRequest req, String username, String password, boolean rememberMe) {
        req.setAttribute("rememberedUsername", username != null ? username : "");
        req.setAttribute("rememberedPassword", password != null ? password : "");
        req.setAttribute("rememberChecked", rememberMe);
    }

    private void saveCredentialsCookies(HttpServletRequest req, HttpServletResponse resp, String username, String password) {
        addCookie(resp, COOKIE_REMEMBER_USERNAME, urlEncode(username), req, REMEMBER_CREDENTIALS_MAX_AGE);
        addCookie(resp, COOKIE_REMEMBER_PASSWORD, urlEncode(password), req, REMEMBER_CREDENTIALS_MAX_AGE);
    }

    private void clearCredentialsCookies(HttpServletRequest req, HttpServletResponse resp) {
        addCookie(resp, COOKIE_REMEMBER_USERNAME, "", req, 0);
        addCookie(resp, COOKIE_REMEMBER_PASSWORD, "", req, 0);
    }

    private void addCookie(HttpServletResponse resp, String name, String value, HttpServletRequest req, int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
        cookie.setHttpOnly(true);
        cookie.setSecure(req.isSecure());
        cookie.setMaxAge(maxAge);
        resp.addCookie(cookie);
    }

    private String urlEncode(String value) {
        try {
            return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return "";
        }
    }

    private String urlDecode(String value) {
        try {
            return URLDecoder.decode(value == null ? "" : value, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return "";
        }
    }
}