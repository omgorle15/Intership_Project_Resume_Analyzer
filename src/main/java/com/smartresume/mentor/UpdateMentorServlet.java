package com.smartresume.mentor;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.*;
import util.DBConnection;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)
@WebServlet("/UpdateMentorServlet")
public class UpdateMentorServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("SignIn.jsp"); return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        request.setCharacterEncoding("UTF-8");

        String name  = request.getParameter("name");
        String bio   = request.getParameter("bio");
        String phone = request.getParameter("phone");

        String[] specializationArray = request.getParameterValues("specialization");
        String specialization = "";
        if (specializationArray != null) specialization = String.join(",", specializationArray);

        if (name == null || name.trim().isEmpty()) {
            response.sendRedirect("MentorDashboard/updateMentor.jsp?error=Name+cannot+be+empty");
            return;
        }

        Part filePart = request.getPart("photo");
        String fileName = null;
        if (filePart != null && filePart.getSize() > 0) {
            fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
            String uploadPath = getServletContext().getRealPath("") + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();
            filePart.write(uploadPath + File.separator + fileName);
        }

        try (Connection con = DBConnection.getConnection()) {

            // Update name + phone in users table
            PreparedStatement psUser = con.prepareStatement(
                "UPDATE users SET name=?, phone=? WHERE id=?"
            );
            psUser.setString(1, name);
            psUser.setString(2, phone != null ? phone.trim() : null);
            psUser.setInt(3, userId);
            psUser.executeUpdate();

            // Update session name
            session.setAttribute("userName", name);

            // Check if mentor_profile exists
            PreparedStatement check = con.prepareStatement(
                "SELECT id, photo FROM mentor_profile WHERE user_id=?"
            );
            check.setInt(1, userId);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                int profileId = rs.getInt("id");
                if (fileName == null) fileName = rs.getString("photo");

                PreparedStatement psUpdate = con.prepareStatement(
                    "UPDATE mentor_profile SET bio=?, photo=?, specialization=? WHERE user_id=?"
                );
                psUpdate.setString(1, bio);
                psUpdate.setString(2, fileName);
                psUpdate.setString(3, specialization);
                psUpdate.setInt(4, userId);
                psUpdate.executeUpdate();

                // Keep session in sync
                session.setAttribute("mentorProfileId", profileId);

            } else {
                PreparedStatement psInsert = con.prepareStatement(
                    "INSERT INTO mentor_profile(user_id,bio,photo,specialization) VALUES(?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS
                );
                psInsert.setInt(1, userId);
                psInsert.setString(2, bio);
                psInsert.setString(3, fileName);
                psInsert.setString(4, specialization);
                psInsert.executeUpdate();

                ResultSet gk = psInsert.getGeneratedKeys();
                if (gk.next()) session.setAttribute("mentorProfileId", gk.getInt(1));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("MentorDashboard/updateMentor.jsp?error=" +
                java.net.URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
            return;
        }

        response.sendRedirect("MentorDashboard/updateMentor.jsp?success=Profile+updated+successfully!");
    }
}
