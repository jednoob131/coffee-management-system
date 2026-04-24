package Controller;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

import Dao.BillDao;
import Dao.DrinkDao;
import Dao.UserDao;
import Daoimpl.BillDaoImpl;
import Daoimpl.DrinkDaoImpl;
import Daoimpl.UserDaoImpl;
import entity.Bill;
import entity.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/index")
public class IndexServlet extends HttpServlet {

    private BillDao billDao = new BillDaoImpl();
    private DrinkDao drinkDao = new DrinkDaoImpl();
    private UserDao userDao = new UserDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // highlight menu dashboard
        req.setAttribute("activeNav", "dashboard");

        // thời gian hôm nay
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));

        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);

        Timestamp todayStart = new Timestamp(cal.getTimeInMillis());

        cal.add(Calendar.DATE, 1);

        Timestamp todayEnd = new Timestamp(cal.getTimeInMillis());

        List<Bill> allBills = billDao.findAll();

        double totalToday = allBills.stream()
                .filter(b -> b.getCreatedDate() != null
                        && !b.getCreatedDate().before(todayStart)
                        && b.getCreatedDate().before(todayEnd))
                .mapToDouble(Bill::getTotalAmount)
                .sum();

        long billToday = allBills.stream()
                .filter(b -> b.getCreatedDate() != null
                        && !b.getCreatedDate().before(todayStart)
                        && b.getCreatedDate().before(todayEnd))
                .count();

        long totalDrinks = drinkDao.countAll();

        long totalStaff = userDao.countStaff();

        req.setAttribute("totalToday", totalToday);
        req.setAttribute("billToday", billToday);
        req.setAttribute("totalDrinks", totalDrinks);
        req.setAttribute("totalStaff", totalStaff);

        // nếu là nhân viên thì hiển thị hóa đơn của mình
        if (!user.isRole()) {
            int myBills = billDao.findByUsername(user.getUsername()).size();
            req.setAttribute("myBills", myBills);
        }

        // tiêu đề dashboard theo role
        if (user.isRole()) {
            req.setAttribute("pageTitle", "Dashboard Quản Trị");
        } else {
            req.setAttribute("pageTitle", "Dashboard Nhân Viên");
        }

        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}