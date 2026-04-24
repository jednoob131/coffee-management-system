package Controller;

import Daoimpl.UserDaoImpl;
import entity.User;
import util.AuthUtil;
import util.PasswordUtil;
import util.ResetTokenStore;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {

    private UserDaoImpl dao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            resp.sendRedirect(req.getContextPath() + "/index");
            return;
        }

        String token = req.getParameter("token");

        ResetTokenStore.TokenInfo info = ResetTokenStore.getToken(token);

        if (info == null) {

            req.setAttribute("message","Link đã hết hạn");
            req.setAttribute("error", true);

            req.getRequestDispatcher("/reset-password.jsp")
                    .forward(req, resp);
            return;
        }

        List<User> users = dao.findAllByEmail(info.getEmail());

        req.setAttribute("users", users);
        req.setAttribute("token", token);

        req.getRequestDispatcher("/reset-password.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            resp.sendRedirect(req.getContextPath() + "/index");
            return;
        }

        String token = req.getParameter("token");

        ResetTokenStore.TokenInfo info = ResetTokenStore.getToken(token);

        if (info == null) {

            req.setAttribute("message","Link đã hết hạn");
            req.setAttribute("error", true);

            req.getRequestDispatcher("/reset-password.jsp")
                    .forward(req, resp);
            return;
        }

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        /* kiểm tra mật khẩu > 4 ký tự */
        if (password == null || password.length() <= 4) {

            req.setAttribute("message","Mật khẩu phải nhiều hơn 4 ký tự");
            req.setAttribute("error", true);

            req.setAttribute("token", token);
            req.setAttribute("users", dao.findAllByEmail(info.getEmail()));

            req.getRequestDispatcher("/reset-password.jsp")
                    .forward(req, resp);
            return;
        }

        String hash = PasswordUtil.hashPassword(password);

        dao.updatePassword(username, hash);

        ResetTokenStore.removeToken(token);

        resp.sendRedirect(req.getContextPath() + "/login");
    }
}