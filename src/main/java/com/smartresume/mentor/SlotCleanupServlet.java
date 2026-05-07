package com.smartresume.mentor;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

/**
 * Called automatically when mentor views their dashboard or booked users page.
 * Marks bookings as cleared (is_cleared=1) if the slot time has passed by more than 1 hour.
 * These cleared bookings move to the History page and are removed from the active view.
 */
@WebServlet("/clearExpiredSlots")
public class SlotCleanupServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        String mentorProfileIdStr = req.getParameter("mentorProfileId");
        if (mentorProfileIdStr == null) { res.sendError(400); return; }

        int mentorProfileId = Integer.parseInt(mentorProfileIdStr);

        try (Connection con = DBConnection.getConnection()) {

            // Mark bookings as cleared where:
            // - booking is Approved
            // - slot time + 1 hour < NOW()
            // - not already cleared
            // Uses DAY-OF-WEEK matching: we compare time only since day is stored as name (Monday etc)
            // Simple approach: clear if booked_at + 1 day < NOW() as fallback,
            // OR if CURTIME() > slot time + 1 hour (same day logic)
            PreparedStatement ps = con.prepareStatement(
                "UPDATE mentor_booking mb " +
                "JOIN mentor_timeslot mts ON mb.slot_id = mts.slot_id " +
                "SET mb.is_cleared = 1, mb.cleared_at = NOW() " +
                "WHERE mb.mentor_profile_id = ? " +
                "AND mb.is_cleared = 0 " +
                "AND mb.status IN ('Approved', 'Rejected') " +
                "AND ADDTIME(mts.time, '01:00:00') < CURTIME() " +
                "AND DATE(mb.booked_at) = CURDATE()"
            );
            ps.setInt(1, mentorProfileId);
            int rows = ps.executeUpdate();

            // Also clear Approved bookings older than 1 day (safety net)
            PreparedStatement ps2 = con.prepareStatement(
                "UPDATE mentor_booking mb " +
                "JOIN mentor_timeslot mts ON mb.slot_id = mts.slot_id " +
                "SET mb.is_cleared = 1, mb.cleared_at = NOW() " +
                "WHERE mb.mentor_profile_id = ? " +
                "AND mb.is_cleared = 0 " +
                "AND mb.status IN ('Approved', 'Rejected') " +
                "AND mb.booked_at < DATE_SUB(NOW(), INTERVAL 1 DAY)"
            );
            ps2.setInt(1, mentorProfileId);
            ps2.executeUpdate();

            res.setStatus(200);
            res.getWriter().write("{\"cleared\":" + rows + "}");

        } catch (Exception e) {
            e.printStackTrace();
            res.sendError(500, e.getMessage());
        }
    }
}
