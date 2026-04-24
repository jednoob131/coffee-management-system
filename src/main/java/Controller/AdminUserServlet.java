package Controller;

import Dao.UserDao;
import Daoimpl.UserDaoImpl;
import entity.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {
    private UserDao userDao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("users", userDao.findAll());
        req.getRequestDispatcher("/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("toggleRole".equals(action)) {
            User u = userDao.findByUsername(req.getParameter("username"));
            if (u != null) {
                u.setRole(!u.isRole());
                userDao.update(u);
            }
        } else if ("delete".equals(action)) {
            userDao.delete(req.getParameter("username"));
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
