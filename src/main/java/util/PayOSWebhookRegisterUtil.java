package util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class PayOSWebhookRegisterUtil {

    public static void confirmWebhook(String clientId, String apiKey, String webhookUrl) {
        try {
            URL url = new URL("https://api-merchant.payos.vn/confirm-webhook");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("x-client-id", clientId);
            conn.setRequestProperty("x-api-key", apiKey);

            String body = "{\"webhookUrl\":\"" + webhookUrl + "\"}";

            try (OutputStream os = conn.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            System.out.println("confirm-webhook status = " + status);

            InputStream is = status >= 200 && status < 300
                    ? conn.getInputStream()
                    : conn.getErrorStream();

            if (is != null) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                    String line;
                    StringBuilder sb = new StringBuilder();
                    while ((line = br.readLine()) != null) {
                        sb.append(line);
                    }
                    System.out.println("confirm-webhook response = " + sb);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}