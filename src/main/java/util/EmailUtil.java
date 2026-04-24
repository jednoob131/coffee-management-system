package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public class EmailUtil {

    private static final String EMAIL = "trandoanhtuan1@gmail.com";
    private static final String PASSWORD = "dsqs effc yuim osfw";

    public static void sendEmail(String toEmail, String subject, String content) {

        try {

            Properties props = new Properties();
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session session = Session.getInstance(props,
                    new Authenticator() {
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(EMAIL, PASSWORD);
                        }
                    });

            Message message = new MimeMessage(session);

            message.setFrom(new InternetAddress(EMAIL));
            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail)
            );

            message.setSubject(subject);
            message.setText(content);

            Transport.send(message);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}