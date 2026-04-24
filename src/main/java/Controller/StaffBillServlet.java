package Controller;

import Dao.BillDao;
import Dao.BillDetailDao;
import Dao.DrinkDao;
import Daoimpl.BillDaoImpl;
import Daoimpl.BillDetailDaoImpl;
import Daoimpl.DrinkDaoImpl;
import entity.Bill;
import entity.BillDetail;
import entity.Drink;
import entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.PayOSUtil;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;

import java.io.IOException;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

@WebServlet("/staff/bills")
public class StaffBillServlet extends HttpServlet {

    private final DrinkDao drinkDao = new DrinkDaoImpl();
    private final BillDao billDao = new BillDaoImpl();
    private final BillDetailDao detailDao = new BillDetailDaoImpl();

    private void setTodayAttributes(HttpServletRequest req, String username) {
        Calendar cal = Calendar.getInstance(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        java.sql.Date today = new java.sql.Date(cal.getTimeInMillis());

        cal.add(Calendar.DATE, 1);
        java.sql.Date tomorrow = new java.sql.Date(cal.getTimeInMillis());

        List<Bill> myBills = billDao.findPaidByUsername(username);
        List<Bill> myBillsToday = billDao.findPaidByDateAndUsername(today, tomorrow, username);

        req.setAttribute("myBillsTotal", myBills.size());
        req.setAttribute("myBillsAmount", myBills.stream().mapToDouble(Bill::getTotalAmount).sum());
        req.setAttribute("myBillsTodayTotal", myBillsToday.size());
        req.setAttribute("myBillsTodayAmount", myBillsToday.stream().mapToDouble(Bill::getTotalAmount).sum());
    }

    private int saveBillAndDetails(User user, double total, String itemsRaw,
                                   String paymentMethod, String paymentStatus, String orderCode) {
        Bill bill = new Bill();
        bill.setUsername(user.getUsername());
        bill.setTotalAmount(total);
        bill.setCreatedDate(new Timestamp(System.currentTimeMillis()));
        bill.setPaymentMethod(paymentMethod);
        bill.setPaymentStatus(paymentStatus);
        bill.setOrderCode(orderCode);

        if ("PAID".equalsIgnoreCase(paymentStatus)) {
            bill.setPaidAt(new Timestamp(System.currentTimeMillis()));
        }

        int billId = billDao.insertAndGetId(bill);

        if (billId > 0 && itemsRaw != null) {
            for (String item : itemsRaw.split("\\|")) {
                if (item == null || item.isEmpty()) continue;

                String[] parts = item.split(":");
                if (parts.length < 4) continue;

                BillDetail detail = new BillDetail();
                detail.setBillId(billId);
                detail.setDrinkId(Integer.parseInt(parts[0]));
                detail.setQuantity(Integer.parseInt(parts[1]));
                detail.setPrice(Double.parseDouble(parts[2]));
                detailDao.insert(detail);
            }
        }

        return billId;
    }

    private void forwardToBillsPage(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        setTodayAttributes(req, user.getUsername());
        req.setAttribute("drinks", drinkDao.findAll());
        req.getRequestDispatcher("/staff/bills.jsp").forward(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String billIdParam = req.getParameter("billId");
        if (billIdParam != null && !billIdParam.trim().isEmpty()) {
            try {
                int billId = Integer.parseInt(billIdParam);
                Bill bill = billDao.findById(billId);

                if (bill != null) {
                    if ("PAID".equalsIgnoreCase(bill.getPaymentStatus())) {
                        req.getSession().setAttribute(
                                "flashSuccess",
                                "Thanh toán chuyển khoản thành công. Hóa đơn #" + billId
                        );
                        resp.sendRedirect(req.getContextPath() + "/staff/bills");
                        return;
                    } else {
                        req.setAttribute("pendingCheckBillId", String.valueOf(billId));
                    }
                }
            } catch (Exception ignored) {
            }
        }

        forwardToBillsPage(req, resp, user);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        if ("preview".equals(action)) {
            String[] drinkIds = req.getParameterValues("drinkId");
            String[] quantities = req.getParameterValues("quantity");

            if (drinkIds == null || quantities == null) {
                req.setAttribute("error", "Vui lòng chọn ít nhất 1 món!");
                forwardToBillsPage(req, resp, user);
                return;
            }

            double total = 0;
            StringBuilder items = new StringBuilder();

            for (int i = 0; i < drinkIds.length; i++) {
                int qty = 0;
                try {
                    qty = Integer.parseInt(quantities[i]);
                } catch (Exception ignored) {
                }

                if (qty <= 0) continue;

                Drink d = drinkDao.findById(Integer.parseInt(drinkIds[i]));
                if (d == null) continue;

                total += d.getPrice() * qty;
                items.append(d.getDrinkId()).append(":")
                        .append(qty).append(":")
                        .append(d.getPrice()).append(":")
                        .append(d.getDrinkName()).append("|");
            }

            if (total <= 0) {
                req.setAttribute("error", "Vui lòng nhập số lượng hợp lệ!");
                forwardToBillsPage(req, resp, user);
                return;
            }

            req.setAttribute("previewItems", items.toString());
            req.setAttribute("previewTotal", total);
            forwardToBillsPage(req, resp, user);
            return;
        }

        if ("confirm".equals(action)) {
            String itemsRaw = req.getParameter("previewItems");
            String paymentMethod = req.getParameter("paymentMethod");
            String cashReceivedRaw = req.getParameter("cashReceived");

            double total;
            try {
                total = Double.parseDouble(req.getParameter("previewTotal"));
            } catch (Exception e) {
                req.setAttribute("error", "Tổng hóa đơn không hợp lệ!");
                forwardToBillsPage(req, resp, user);
                return;
            }

            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                req.setAttribute("error", "Vui lòng chọn phương thức thanh toán!");
                req.setAttribute("previewItems", itemsRaw);
                req.setAttribute("previewTotal", total);
                forwardToBillsPage(req, resp, user);
                return;
            }

            if ("cash".equals(paymentMethod)) {
                double cashReceived;
                try {
                    cashReceived = Double.parseDouble(cashReceivedRaw);
                } catch (Exception e) {
                    req.setAttribute("error", "Vui lòng nhập số tiền khách đưa hợp lệ!");
                    req.setAttribute("previewItems", itemsRaw);
                    req.setAttribute("previewTotal", total);
                    req.setAttribute("selectedPaymentMethod", "cash");
                    req.setAttribute("cashReceived", cashReceivedRaw);
                    forwardToBillsPage(req, resp, user);
                    return;
                }

                if (cashReceived < total) {
                    req.setAttribute("error", "Số tiền khách đưa không đủ để thanh toán!");
                    req.setAttribute("previewItems", itemsRaw);
                    req.setAttribute("previewTotal", total);
                    req.setAttribute("selectedPaymentMethod", "cash");
                    req.setAttribute("cashReceived", cashReceived);
                    forwardToBillsPage(req, resp, user);
                    return;
                }

                double changeAmount = cashReceived - total;

                int billId = saveBillAndDetails(user, total, itemsRaw, "cash", "PAID", null);
                if (billId <= 0) {
                    req.setAttribute("error", "Không thể tạo hóa đơn!");
                    req.setAttribute("previewItems", itemsRaw);
                    req.setAttribute("previewTotal", total);
                    forwardToBillsPage(req, resp, user);
                    return;
                }

                session.setAttribute(
                        "flashSuccess",
                        "Thanh toán tiền mặt thành công. Hóa đơn #" + billId
                                + " | Khách đưa: " + String.format("%,.0f", cashReceived) + "đ"
                                + " | Tiền thối: " + String.format("%,.0f", changeAmount) + "đ"
                );
                resp.sendRedirect(req.getContextPath() + "/staff/bills");
                return;
            }

            if ("bank".equals(paymentMethod)) {
                try {
                    String orderCode = String.valueOf(System.currentTimeMillis());

                    int billId = saveBillAndDetails(user, total, itemsRaw, "bank", "PENDING", orderCode);
                    if (billId <= 0) {
                        req.setAttribute("error", "Không thể tạo hóa đơn chờ thanh toán!");
                        req.setAttribute("previewItems", itemsRaw);
                        req.setAttribute("previewTotal", total);
                        req.setAttribute("selectedPaymentMethod", "bank");
                        forwardToBillsPage(req, resp, user);
                        return;
                    }

                    String baseUrl = req.getScheme() + "://" + req.getServerName()
                            + ((req.getServerPort() == 80 || req.getServerPort() == 443) ? "" : ":" + req.getServerPort())
                            + req.getContextPath();

                    PayOS payOS = PayOSUtil.getPayOS();

                    CreatePaymentLinkRequest paymentRequest = CreatePaymentLinkRequest.builder()
                            .orderCode(Long.parseLong(orderCode))
                            .amount((long) Math.round(total))
                            .description("Bill " + billId)
                            .returnUrl(baseUrl + "/staff/bills?billId=" + billId)
                            .cancelUrl(baseUrl + "/staff/bills?billId=" + billId)
                            .build();

                    Object paymentLink = payOS.paymentRequests().create(paymentRequest);

                    String checkoutUrl = extractCheckoutUrl(paymentLink);
                    String paymentLinkId = extractPaymentLinkId(paymentLink);
                    String qrCode = extractQrCode(paymentLink);

                    Bill bill = billDao.findById(billId);
                    if (bill != null && paymentLinkId != null && !paymentLinkId.trim().isEmpty()) {
                        bill.setPaymentLinkId(paymentLinkId);
                        billDao.update(bill);
                    }

                    if ((checkoutUrl == null || checkoutUrl.trim().isEmpty())
                            && (qrCode == null || qrCode.trim().isEmpty())) {
                        req.setAttribute("error", "Không lấy được dữ liệu thanh toán payOS!");
                        req.setAttribute("previewItems", itemsRaw);
                        req.setAttribute("previewTotal", total);
                        req.setAttribute("selectedPaymentMethod", "bank");
                        forwardToBillsPage(req, resp, user);
                        return;
                    }

                    req.setAttribute("previewItems", itemsRaw);
                    req.setAttribute("previewTotal", total);
                    req.setAttribute("selectedPaymentMethod", "bank");
                    req.setAttribute("pendingCheckBillId", String.valueOf(billId));
                    req.setAttribute("payosCheckoutUrl", checkoutUrl);
                    req.setAttribute("payosQrText", qrCode); // QUAN TRỌNG: đây là chuỗi VietQR thật
                    req.setAttribute("payosBillId", String.valueOf(billId));
                    req.setAttribute("isWaitingBankPayment", true);

                    forwardToBillsPage(req, resp, user);
                    return;

                } catch (Exception e) {
                    e.printStackTrace();
                    req.setAttribute("error", "Lỗi tạo thanh toán payOS!");
                    req.setAttribute("previewItems", itemsRaw);
                    req.setAttribute("previewTotal", total);
                    req.setAttribute("selectedPaymentMethod", "bank");
                    forwardToBillsPage(req, resp, user);
                    return;
                }
            }

            req.setAttribute("error", "Phương thức thanh toán không hợp lệ!");
            req.setAttribute("previewItems", itemsRaw);
            req.setAttribute("previewTotal", total);
            forwardToBillsPage(req, resp, user);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/staff/bills");
    }

    private String extractCheckoutUrl(Object paymentLink) {
        try {
            Object value = paymentLink.getClass().getMethod("getCheckoutUrl").invoke(paymentLink);
            return value == null ? null : String.valueOf(value);
        } catch (Exception e) {
            return null;
        }
    }

    private String extractPaymentLinkId(Object paymentLink) {
        try {
            Object value = paymentLink.getClass().getMethod("getPaymentLinkId").invoke(paymentLink);
            return value == null ? null : String.valueOf(value);
        } catch (Exception e) {
            return null;
        }
    }

    private String extractQrCode(Object paymentLink) {
        try {
            Object value = paymentLink.getClass().getMethod("getQrCode").invoke(paymentLink);
            return value == null ? null : String.valueOf(value);
        } catch (Exception e) {
            return null;
        }
    }
}