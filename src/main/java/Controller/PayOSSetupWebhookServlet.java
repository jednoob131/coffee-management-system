package Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.PayOSWebhookRegisterUtil;
import util.PayOSUtil;

import java.io.IOException;

@WebServlet("/payos/setup-webhook")
public class PayOSSetupWebhookServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain; charset=UTF-8");

        String publicBaseUrl = "https://glare-daintily-nebula.ngrok-free.dev/Tesst";
        String webhookUrl = publicBaseUrl + "/payos/webhook";

        PayOSWebhookRegisterUtil.confirmWebhook(
                PayOSUtil.getClientId(),
                PayOSUtil.getApiKey(),
                webhookUrl
        );

        resp.getWriter().write("Đã gửi đăng ký webhook: " + webhookUrl);
    }
}