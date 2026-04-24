package Controller;

import Dao.BillDao;
import Daoimpl.BillDaoImpl;
import entity.Bill;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.PayOSUtil;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Timestamp;

@WebServlet("/staff/bills/check-payment")
public class CheckBillPaymentServlet extends HttpServlet {

    private final BillDao billDao = new BillDaoImpl();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String billIdRaw = req.getParameter("billId");
        if (billIdRaw == null || billIdRaw.isEmpty()) {
            resp.getWriter().write("{\"success\":false,\"paid\":false,\"message\":\"Missing billId\"}");
            return;
        }

        try {
            int billId = Integer.parseInt(billIdRaw);
            Bill bill = billDao.findById(billId);

            if (bill == null) {
                resp.getWriter().write("{\"success\":false,\"paid\":false,\"message\":\"Bill not found\"}");
                return;
            }

            System.out.println("CHECK PAYMENT billId=" + billId + " localStatus=" + bill.getPaymentStatus());

            if ("PAID".equalsIgnoreCase(bill.getPaymentStatus())) {
                resp.getWriter().write("{\"success\":true,\"paid\":true,\"billId\":" + bill.getBillId() + "}");
                return;
            }

            String lookupId = null;

            if (bill.getPaymentLinkId() != null && !bill.getPaymentLinkId().isBlank()) {
                lookupId = bill.getPaymentLinkId().trim();
            } else if (bill.getOrderCode() != null && !bill.getOrderCode().isBlank()) {
                lookupId = bill.getOrderCode().trim();
            }

            if (lookupId == null) {
                resp.getWriter().write("{\"success\":true,\"paid\":false,\"billId\":" + bill.getBillId() + "}");
                return;
            }

            JsonNode payosResult = fetchPaymentStatusFromPayOS(lookupId);
            if (payosResult == null) {
                resp.getWriter().write("{\"success\":true,\"paid\":false,\"billId\":" + bill.getBillId() + "}");
                return;
            }

            JsonNode dataNode = payosResult.path("data");
            String payosStatus = dataNode.path("status").asText("");
            String paymentLinkId = dataNode.path("id").asText("");

            System.out.println("CHECK PAYMENT billId=" + billId + " payosStatus=" + payosStatus + " lookupId=" + lookupId);

            if ("PAID".equalsIgnoreCase(payosStatus)) {
                bill.setPaymentStatus("PAID");
                bill.setPaidAt(new Timestamp(System.currentTimeMillis()));

                if (paymentLinkId != null && !paymentLinkId.isBlank()) {
                    bill.setPaymentLinkId(paymentLinkId);
                }

                billDao.update(bill);
                System.out.println("UPDATED BILL TO PAID BY POLLING: #" + bill.getBillId());

                resp.getWriter().write("{\"success\":true,\"paid\":true,\"billId\":" + bill.getBillId() + "}");
                return;
            }

            resp.getWriter().write("{\"success\":true,\"paid\":false,\"billId\":" + bill.getBillId() + "}");

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"success\":false,\"paid\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private JsonNode fetchPaymentStatusFromPayOS(String id) {
        HttpURLConnection conn = null;
        try {
            String urlStr = "https://api-merchant.payos.vn/v2/payment-requests/" + id;
            URL url = new URL(urlStr);
            conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");
            conn.setRequestProperty("x-client-id", PayOSUtil.getClientId());
            conn.setRequestProperty("x-api-key", PayOSUtil.getApiKey());

            int status = conn.getResponseCode();
            System.out.println("PAYOS GET STATUS HTTP=" + status + " id=" + id);

            InputStream is = status >= 200 && status < 300
                    ? conn.getInputStream()
                    : conn.getErrorStream();

            if (is == null) {
                return null;
            }

            String body = readAll(is);
            System.out.println("PAYOS GET STATUS RESPONSE=" + body);

            if (body == null || body.isBlank()) {
                return null;
            }

            return mapper.readTree(body);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }
    }

    private String readAll(InputStream is) throws IOException {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        }
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}