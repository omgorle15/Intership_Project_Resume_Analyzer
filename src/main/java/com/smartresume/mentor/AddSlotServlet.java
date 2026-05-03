package com.smartresume.mentor;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import util.DBConnection;

@WebServlet("/addSlot")
public class AddSlotServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("mentorProfileId") == null) {
            response.sendRedirect(request.getContextPath() + "/SignIn.jsp");
            return;
        }

        Integer mentorProfileId = (Integer) session.getAttribute("mentorProfileId");
        String day  = request.getParameter("day");
        String time = request.getParameter("time");

        if (day == null || day.isEmpty() || time == null || time.isEmpty()) {
            response.sendRedirect(request.getContextPath() +
                "/MentorDashboard/addTimeSlot.jsp?error=Please+select+both+day+and+time");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            // Duplicate check
            PreparedStatement chk = con.prepareStatement(
                "SELECT COUNT(*) FROM mentor_timeslot " +
                "WHERE mentor_profile_id=? AND day=? AND time=?"
            );
            chk.setInt(1, mentorProfileId);
            chk.setString(2, day);
            chk.setTime(3, Time.valueOf(time + ":00"));
            ResultSet rs = chk.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                response.sendRedirect(request.getContextPath() +
                    "/MentorDashboard/addTimeSlot.jsp?error=Slot+already+exists+for+" + day + "+at+" + time);
                return;
            }

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO mentor_timeslot (mentor_profile_id, day, time, status) VALUES (?, ?, ?, 'ACTIVE')"
            );
            ps.setInt(1, mentorProfileId);
            ps.setString(2, day);
            ps.setTime(3, Time.valueOf(time + ":00"));
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() +
                "/MentorDashboard/addTimeSlot.jsp?error=Error:+" + e.getMessage());
            return;
        }

        response.sendRedirect(request.getContextPath() +
            "/MentorDashboard/addTimeSlot.jsp?success=Slot+added+successfully!");
    }
}