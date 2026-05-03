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
        if(session == null || session.getAttribute("userId") == null){
            response.sendRedirect("SignIn.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String bio = request.getParameter("bio");

        // ✅ Get specialization (multiple checkboxes)
        String[] specializationArray = request.getParameterValues("specialization");
        String specialization = "";

        if(specializationArray != null){
            specialization = String.join(",", specializationArray);
        }

        if(name == null || name.trim().isEmpty()){
            response.sendRedirect("MentorDashboard/updateMentor.jsp?error=Name cannot be empty");
            return;
        }

        Part filePart = request.getPart("photo");
        String fileName = null;

        if(filePart != null && filePart.getSize() > 0){
            fileName = System.currentTimeMillis() + "_" +
                    filePart.getSubmittedFileName();

            String uploadPath = getServletContext().getRealPath("") + "uploads";
            File uploadDir = new File(uploadPath);
            if(!uploadDir.exists()) uploadDir.mkdir();

            filePart.write(uploadPath + File.separator + fileName);
        }

        try(Connection con = DBConnection.getConnection()) {

            // ✅ Update name in users table
            PreparedStatement psUser = con.prepareStatement(
                "UPDATE users SET name=? WHERE id=?");
            psUser.setString(1,name);
            psUser.setInt(2,userId);
            psUser.executeUpdate();
            psUser.close();

            // ✅ Check if mentor_profile exists
            PreparedStatement check = con.prepareStatement(
                "SELECT photo FROM mentor_profile WHERE user_id=?");
            check.setInt(1,userId);
            ResultSet rs = check.executeQuery();

            if(rs.next()){

                // If no new photo uploaded, keep old photo
                if(fileName == null){
                    fileName = rs.getString("photo");
                }

                PreparedStatement psUpdate = con.prepareStatement(
                "UPDATE mentor_profile SET bio=?, photo=?, specialization=? WHERE user_id=?");

                psUpdate.setString(1,bio);
                psUpdate.setString(2,fileName);
                psUpdate.setString(3,specialization);
                psUpdate.setInt(4,userId);
                psUpdate.executeUpdate();
                psUpdate.close();

            } else {

                PreparedStatement psInsert = con.prepareStatement(
                "INSERT INTO mentor_profile(user_id,bio,photo,specialization) VALUES(?,?,?,?)");

                psInsert.setInt(1,userId);
                psInsert.setString(2,bio);
                psInsert.setString(3,fileName);
                psInsert.setString(4,specialization);
                psInsert.executeUpdate();
                psInsert.close();
            }

            rs.close();
            check.close();

        } catch(Exception e){
            e.printStackTrace();
        }

        response.sendRedirect("MentorDashboard/viewProfile.jsp");
    }
}