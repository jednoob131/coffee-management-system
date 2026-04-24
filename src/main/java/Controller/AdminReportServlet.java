package Controller;

import Dao.BillDao;
import Daoimpl.BillDaoImpl;
import entity.Bill;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/admin/report")
public class AdminReportServlet extends HttpServlet {
    private BillDao billDao = new BillDaoImpl();
    private static final TimeZone TZ_VN = TimeZone.getTimeZone("Asia/Ho_Chi_Minh");

    private static String jsonEscape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static String toJsonStringArray(List<String> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append('"').append(jsonEscape(list.get(i))).append('"');
        }
        sb.append(']');
        return sb.toString();
    }

    private static String toJsonNumberArray(List<Double> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append(list.get(i));
        }
        sb.append(']');
        return sb.toString();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Calendar cal = Calendar.getInstance(TZ_VN);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Timestamp todayStart = new Timestamp(cal.getTimeInMillis());
        cal.add(Calendar.DATE, 1);
        Timestamp todayEnd = new Timestamp(cal.getTimeInMillis());

        List<Bill> allBills = billDao.findAll();
        req.setAttribute("bills", allBills);

        double grandTotal = allBills.stream().mapToDouble(Bill::getTotalAmount).sum();
        req.setAttribute("grandTotal", grandTotal);

        double totalToday = allBills.stream()
            .filter(b -> b.getCreatedDate() != null
                && !b.getCreatedDate().before(todayStart)
                && b.getCreatedDate().before(todayEnd))
            .mapToDouble(Bill::getTotalAmount).sum();
        req.setAttribute("totalToday", totalToday);

        long billToday = allBills.stream()
            .filter(b -> b.getCreatedDate() != null
                && !b.getCreatedDate().before(todayStart)
                && b.getCreatedDate().before(todayEnd))
            .count();
        req.setAttribute("billToday", billToday);

        int n = allBills.size();
        double avgOrder = n > 0 ? grandTotal / n : 0;
        req.setAttribute("avgOrder", avgOrder);

        /* 7 ngày gần nhất — cho biểu đồ cột */
        SimpleDateFormat dayFmt = new SimpleDateFormat("dd/MM", Locale.forLanguageTag("vi-VN"));
        dayFmt.setTimeZone(TZ_VN);
        List<String> chartLabels = new ArrayList<>(7);
        List<Double> chartValues = new ArrayList<>(7);
        for (int offset = 6; offset >= 0; offset--) {
            Calendar c = Calendar.getInstance(TZ_VN);
            c.add(Calendar.DATE, -offset);
            c.set(Calendar.HOUR_OF_DAY, 0);
            c.set(Calendar.MINUTE, 0);
            c.set(Calendar.SECOND, 0);
            c.set(Calendar.MILLISECOND, 0);
            Timestamp dayStart = new Timestamp(c.getTimeInMillis());
            c.add(Calendar.DATE, 1);
            Timestamp dayEnd = new Timestamp(c.getTimeInMillis());
            double daySum = allBills.stream()
                .filter(b -> b.getCreatedDate() != null
                    && !b.getCreatedDate().before(dayStart)
                    && b.getCreatedDate().before(dayEnd))
                .mapToDouble(Bill::getTotalAmount).sum();
            chartLabels.add(dayFmt.format(new Date(dayStart.getTime())));
            chartValues.add(daySum);
        }
        req.setAttribute("chartLabelsJson", toJsonStringArray(chartLabels));
        req.setAttribute("chartDataJson", toJsonNumberArray(chartValues));

        /* Doanh thu theo nhân viên — top 6 + Khác (biểu đồ tròn) */
        Map<String, Double> byStaff = new HashMap<>();
        for (Bill b : allBills) {
            String u = b.getUsername() != null ? b.getUsername() : "—";
            byStaff.merge(u, b.getTotalAmount(), Double::sum);
        }
        List<Map.Entry<String, Double>> sorted = byStaff.entrySet().stream()
            .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
            .collect(Collectors.toList());
        List<String> staffLabels = new ArrayList<>();
        List<Double> staffValues = new ArrayList<>();
        final int top = 6;
        if (sorted.size() <= top) {
            for (Map.Entry<String, Double> e : sorted) {
                staffLabels.add(e.getKey());
                staffValues.add(e.getValue());
            }
        } else {
            double other = 0;
            for (int i = 0; i < sorted.size(); i++) {
                if (i < top) {
                    staffLabels.add(sorted.get(i).getKey());
                    staffValues.add(sorted.get(i).getValue());
                } else {
                    other += sorted.get(i).getValue();
                }
            }
            if (other > 0) {
                staffLabels.add("Khác");
                staffValues.add(other);
            }
        }
        req.setAttribute("staffLabelsJson", toJsonStringArray(staffLabels));
        req.setAttribute("staffDataJson", toJsonNumberArray(staffValues));
        req.setAttribute("staffChartEmpty", staffLabels.isEmpty());

        req.getRequestDispatcher("/admin/report.jsp").forward(req, resp);
    }
}
