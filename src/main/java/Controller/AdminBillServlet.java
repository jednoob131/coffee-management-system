package Controller;

import Dao.BillDao;
import Dao.BillDetailDao;
import Daoimpl.BillDaoImpl;
import Daoimpl.BillDetailDaoImpl;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/bills")
public class AdminBillServlet extends HttpServlet {
    private final BillDao billDao = new BillDaoImpl();
    private final BillDetailDao detailDao = new BillDetailDaoImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String billIdStr = req.getParameter("billId");
        String ajax = req.getParameter("ajax");

        if ("1".equals(ajax) && billIdStr != null && !billIdStr.isEmpty()) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.setCharacterEncoding("UTF-8");

            try {
                int billId = Integer.parseInt(billIdStr);

                Map<String, Object> data = new HashMap<>();
                data.put("bill", billDao.findById(billId));
                data.put("details", detailDao.findByBillId(billId));

                resp.getWriter().write(gson.toJson(data));
            } catch (Exception e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.getWriter().write("{\"error\":\"load detail fail\"}");
            }
            return;
        }

        req.setAttribute("bills", billDao.findAll());
        req.getRequestDispatcher("/admin/bills.jsp").forward(req, resp);
    }
}