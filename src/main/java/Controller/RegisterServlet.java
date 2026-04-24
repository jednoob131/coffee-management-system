package Controller;

import java.io.IOException;
import Dao.UserDao;
import Daoimpl.UserDaoImpl;
import entity.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.AuthUtil;
import util.EmailUtil;
import util.PasswordUtil;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDao dao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (AuthUtil.isLoggedIn(req) || AuthUtil.restoreLoginFromRememberCookie(req)) {
            resp.sendRedirect(req.getContextPath() + "/index");
            return;
        }
        req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
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
        String confirm  = req.getParameter("confirm");
        String fullname = req.getParameter("fullname");
        String email    = req.getParameter("email");
        String phone    = req.getParameter("phone");
        boolean role    = false; // Mặc định Staff

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Mật khẩu không khớp!");
            req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
            return;
        }

        if (dao.findByUsername(username) != null) {
            req.setAttribute("error", "Tài khoản đã tồn tại!");
            req.getRequestDispatcher("/dangky.jsp").forward(req, resp);
            return;
        }

        User user = new User();
        user.setUsername(username);
        String hash = PasswordUtil.hashPassword(password);
        user.setPassword(hash);
        user.setFullname(fullname);
        user.setEmail(email);
        user.setPhone(phone);
        user.setRole(role);

        dao.insert(user);

        /* Gửi email đăng ký thành công */
        EmailUtil.sendEmail(
                email,
                "Đăng ký thành công - Polly Coffee",
                "Xin chào " + fullname +
                        "\n\nTài khoản của bạn đã được đăng ký thành công." +
                        "\nUsername: " + username +
                        "\n\nChúc bạn sử dụng hệ thống Polly Coffee vui vẻ!"
        );

        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
