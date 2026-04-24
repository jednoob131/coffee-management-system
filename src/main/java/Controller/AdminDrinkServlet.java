package Controller;

import Daoimpl.DrinkDaoImpl;
import Dao.DrinkDao;
import entity.Drink;
import util.FileUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@MultipartConfig
@WebServlet("/admin/drinks")
public class AdminDrinkServlet extends HttpServlet {

    DrinkDao drinkDao = new DrinkDaoImpl();

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

        req.getRequestDispatcher("/admin/drinks.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        if ("add".equals(action)) {

            String name = req.getParameter("drinkName");
            double price = Double.parseDouble(req.getParameter("price"));
            String category = req.getParameter("category");

            // IMAGE
            String image = FileUtil.uploadImage(req, "image");

            Drink d = new Drink();
            d.setDrinkName(name);
            d.setPrice(price);
            d.setCategory(category);
            d.setStatus(true);
            d.setImage(image); // IMAGE

            drinkDao.insert(d);
        }

        else if ("edit".equals(action)) {

            int id = Integer.parseInt(req.getParameter("drinkId"));

            Drink d = drinkDao.findById(id);

            d.setDrinkName(req.getParameter("drinkName"));
            d.setPrice(Double.parseDouble(req.getParameter("price")));
            d.setCategory(req.getParameter("category"));
            d.setStatus(Boolean.parseBoolean(req.getParameter("status")));

            // IMAGE
            String newImage = FileUtil.uploadImage(req, "image");
            if (newImage != null) {
                FileUtil.deleteFile(req, d.getImage());
                d.setImage(newImage);
            }

            drinkDao.update(d);
        }

        else if ("delete".equals(action)) {

            int id = Integer.parseInt(req.getParameter("drinkId"));

            Drink d = drinkDao.findById(id);

            // IMAGE
            if (d != null && d.getImage() != null) {
                FileUtil.deleteFile(req, d.getImage());
            }

            drinkDao.delete(id);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/drinks");
    }
}