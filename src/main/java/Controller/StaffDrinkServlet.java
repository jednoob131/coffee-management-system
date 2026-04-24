package Controller;

import Dao.DrinkDao;
import Daoimpl.DrinkDaoImpl;
import entity.Drink;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/staff/drinks")
public class StaffDrinkServlet extends HttpServlet {
    private DrinkDao drinkDao = new DrinkDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String keyword = req.getParameter("keyword");
        if (keyword == null) keyword = "";

        int page = 1;
        int pageSize = 10;

        String pageParam = req.getParameter("page");
        if (pageParam != null) {
            page = Integer.parseInt(pageParam);
        }

        int offset = (page - 1) * pageSize;

        List<Drink> drinks = drinkDao.findByPage(keyword, offset, pageSize);
        long total = drinkDao.countByKeyword(keyword);

        int totalPages = (int) Math.ceil((double) total / pageSize);

        req.setAttribute("drinks", drinks);
        req.setAttribute("keyword", keyword);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);

        req.getRequestDispatcher("/staff/drinks.jsp").forward(req, resp);
    }
}
