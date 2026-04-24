package Controller;

import Daoimpl.UserDaoImpl;
import entity.User;
import util.AuthUtil;
import util.EmailUtil;
import util.ResetTokenStore;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private UserDaoImpl dao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            resp.sendRedirect(req.getContextPath() + "/index");
            return;
        }

        req.getRequestDispatcher("/forgot-password.jsp")
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

        String email = req.getParameter("email");

        List<User> users = dao.findAllByEmail(email);

        if (users == null || users.isEmpty()) {

            req.setAttribute("message", "Email không tồn tại");

            req.getRequestDispatcher("/forgot-password.jsp")
                    .forward(req, resp);
            return;
        }

        String token = UUID.randomUUID().toString();

        ResetTokenStore.saveToken(token, email, 5);

        String link =
                req.getScheme() + "://"
                        + req.getServerName() + ":"
                        + req.getServerPort()
                        + req.getContextPath()
                        + "/reset-password?token=" + token;

        EmailUtil.sendEmail(
                email,
                "Reset Password PollyCoffee",
                "Click link sau để đổi mật khẩu (hiệu lực 5 phút):\n" + link
        );

        req.setAttribute("message", "Link reset đã gửi về email");

        req.getRequestDispatcher("/forgot-password.jsp")
                .forward(req, resp);
    }
}