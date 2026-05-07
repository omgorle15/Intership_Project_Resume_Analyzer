package com.smartresume.mentor;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.*;
import java.util.Properties;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import util.DBConnection;

@WebServlet("/sendBookingMail")
public class BookingMailServlet extends HttpServlet {

    private static final String SENDER_EMAIL    = "omgorle5@gmail.com";
    private static final String SENDER_PASSWORD = "zgvl dcnd pldm ugsq"; // Gmail App Password

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String bookingIdStr = req.getParameter("bookingId");

        // ROOT CAUSE FIX 1: If bookingId is null here, it means the internal POST
        // from viewUser.jsp is missing Content-Type header, so Tomcat never parses
        // the body and getParameter() always returns null.
        if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
            System.err.println("[BookingMailServlet] FATAL: bookingId is NULL. " +
                "Caller (viewUser.jsp) must set Content-Type: application/x-www-form-urlencoded");
            res.sendError(400, "Missing bookingId");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(bookingIdStr.trim());
        } catch (NumberFormatException e) {
            res.sendError(400, "Invalid bookingId: " + bookingIdStr);
            return;
        }

        System.out.println("[BookingMailServlet] Processing bookingId=" + bookingId);

        try (Connection con = DBConnection.getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                "SELECT " +
                "  u.name AS uname, u.email AS uemail, " +
                "  mu.name AS mname, mu.phone AS mphone, " +
                "  mts.day, mts.time " +
                "FROM mentor_booking mb " +
                "JOIN users u              ON mb.user_id           = u.id " +
                "JOIN mentor_profile mp    ON mb.mentor_profile_id = mp.id " +
                "JOIN users mu             ON mp.user_id           = mu.id " +
                "JOIN mentor_timeslot mts  ON mb.slot_id           = mts.slot_id " +
                "WHERE mb.booking_id = ?"
            );
            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                res.sendError(404, "Booking not found: " + bookingId);
                return;
            }

            String userName    = rs.getString("uname");
            String userEmail   = rs.getString("uemail");
            String mentorName  = rs.getString("mname");
            String mentorPhone = rs.getString("mphone") != null ? rs.getString("mphone") : "Not provided";
            String day         = rs.getString("day");
            java.sql.Time t    = rs.getTime("time");
            String slotTime    = (t != null) ? t.toString().substring(0, 5) : "N/A";

            if (userEmail == null || userEmail.trim().isEmpty()) {
                res.sendError(422, "User has no email");
                return;
            }

            System.out.println("[BookingMailServlet] Sending mail to: " + userEmail);
            String subject = "✅ Mentor Session Booked — " + day + " at " + slotTime;
            String body    = buildEmailBody(userName, mentorName, mentorPhone, day, slotTime);
            sendEmail(userEmail.trim(), subject, body);

            System.out.println("[BookingMailServlet] SUCCESS - mail sent to " + userEmail);
            res.setStatus(200);
            res.getWriter().write("OK");

        } catch (MessagingException e) {
            System.err.println("[BookingMailServlet] SMTP ERROR: " + e.getMessage());
            e.printStackTrace();
            res.sendError(500, "SMTP: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("[BookingMailServlet] ERROR: " + e.getMessage());
            e.printStackTrace();
            res.sendError(500, e.getMessage());
        }
    }

    private void sendEmail(String toEmail, String subject, String htmlBody)
            throws MessagingException, UnsupportedEncodingException {

        Properties props = new Properties();
        props.put("mail.smtp.host",              "smtp.gmail.com");
        props.put("mail.smtp.port",              "587");
        props.put("mail.smtp.auth",              "true");
        props.put("mail.smtp.starttls.enable",   "true");
        props.put("mail.smtp.starttls.required", "true");
        // ROOT CAUSE FIX 2: Java 21 strict TLS — without this line, SSLHandshakeException
        props.put("mail.smtp.ssl.trust",         "smtp.gmail.com");
        props.put("mail.smtp.ssl.protocols",     "TLSv1.2 TLSv1.3");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        // Shows full SMTP conversation in Tomcat catalina.out — helps diagnose auth failures
        session.setDebug(true);

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "Smart Resume System"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(htmlBody, "text/html; charset=utf-8");
        Transport.send(message);
    }

    private String buildEmailBody(String userName, String mentorName,
                                   String mentorPhone, String day, String slotTime) {
        return "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f6f9;margin:0;padding:0'>"
            + "<div style='max-width:600px;margin:30px auto;background:white;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,.1)'>"
            + "  <div style='background:linear-gradient(135deg,#1f2937,#2563eb);padding:30px;text-align:center'>"
            + "    <h1 style='color:white;margin:0;font-size:24px'>📅 Session Confirmed!</h1>"
            + "  </div>"
            + "  <div style='padding:30px'>"
            + "    <p style='font-size:16px;color:#374151'>Hi <strong>" + userName + "</strong>,</p>"
            + "    <p style='color:#6b7280'>Your mentoring session has been successfully booked. Here are your details:</p>"
            + "    <div style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:10px;padding:20px;margin:20px 0'>"
            + "      <table style='width:100%;border-collapse:collapse'>"
            + "        <tr><td style='padding:8px 0;color:#6b7280;width:40%'>👨‍🏫 Mentor</td>"
            + "            <td style='padding:8px 0;font-weight:bold;color:#111827'>" + mentorName + "</td></tr>"
            + "        <tr><td style='padding:8px 0;color:#6b7280'>📅 Day</td>"
            + "            <td style='padding:8px 0;font-weight:bold;color:#111827'>" + day + "</td></tr>"
            + "        <tr><td style='padding:8px 0;color:#6b7280'>⏰ Time</td>"
            + "            <td style='padding:8px 0;font-weight:bold;color:#111827'>" + slotTime + "</td></tr>"
            + "        <tr><td style='padding:8px 0;color:#6b7280'>📞 Mentor Phone</td>"
            + "            <td style='padding:8px 0;font-weight:bold;color:#2563eb;font-size:18px'>" + mentorPhone + "</td></tr>"
            + "      </table>"
            + "    </div>"
            + "    <div style='background:#fffbeb;border:1px solid #fde68a;border-radius:10px;padding:15px'>"
            + "      <p style='margin:0;color:#92400e;font-size:14px'>"
            + "        <strong>📌 Important:</strong> Call your mentor at <strong>" + mentorPhone + "</strong>"
            + "        on <strong>" + day + " at " + slotTime + "</strong>."
            + "      </p>"
            + "    </div>"
            + "    <p style='color:#9ca3af;font-size:12px;text-align:center;margin-top:25px'>Smart Resume Analyzer &amp; Job Recommendation System</p>"
            + "  </div>"
            + "</div></body></html>";
    }
}
