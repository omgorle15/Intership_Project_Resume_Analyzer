<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%@ page import="util.DBConnection" %>

<%
/*
 * ══════════════════════════════════════════════════════════════════
 *  SESSION STRATEGY — Why we use separate keys per role:
 *
 *  Problem: Browser shares one JSESSIONID cookie per domain.
 *  So Tab1 (user) and Tab2 (mentor) share the same session object.
 *  If we store "userName" for both, Tab2's login overwrites Tab1's.
 *
 *  Solution: Store each role under its own session key:
 *    User   → session: "user_id", "user_name"
 *    Mentor → session: "mentor_id", "mentor_name", "mentor_profile_id"
 *    Shared → session: "userId", "userName", "userRole"  (for the CURRENT tab only)
 *
 *  Each dashboard (layout.jsp / MentorDashboard.jsp) reads from its
 *  own role-specific keys so they never conflict.
 * ══════════════════════════════════════════════════════════════════
 */

String email     = request.getParameter("email");
String password  = request.getParameter("password");
String loginRole = request.getParameter("role");

// Admin check from database — no credentials in code
boolean isAdmin   = false;
String adminName  = "";
try (Connection adminCon = DBConnection.getConnection()) {
    PreparedStatement adminPs = adminCon.prepareStatement(
        "SELECT name FROM admin WHERE email=? AND password=?"
    );
    adminPs.setString(1, email);
    adminPs.setString(2, password);
    ResultSet adminRs = adminPs.executeQuery();
    if (adminRs.next()) {
        isAdmin   = true;
        adminName = adminRs.getString("name");
    }
} catch (Exception e) {
    e.printStackTrace();
}

if (isAdmin) {
    session.setAttribute("admin_logged_in", true);
    session.setAttribute("admin_name", adminName);
    // Also set shared keys for this tab
    session.setAttribute("userId",   0);
    session.setAttribute("userName", adminName);
    session.setAttribute("userRole", "admin");
    response.sendRedirect("AdminDashboard/AdminDashboard.jsp?login=success");
    return;
}

try (Connection con = DBConnection.getConnection()) {

    PreparedStatement ps = con.prepareStatement(
        "SELECT id, name, role, status FROM users WHERE email=? AND password=?"
    );
    ps.setString(1, email);
    ps.setString(2, password);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {

        int    userId   = rs.getInt("id");
        String userName = rs.getString("name");
        String dbRole   = rs.getString("role");
        String status   = rs.getString("status");

        if (!dbRole.equalsIgnoreCase(loginRole)) {
%>
            <script>
                alert("You are not registered as '<%= loginRole %>'. Your role is '<%= dbRole %>'.");
                window.location = "SignIn.jsp";
            </script>
<%
            return;
        }

        if ("user".equalsIgnoreCase(dbRole)) {

            // ── Store under USER-specific keys (never overwritten by mentor login) ──
            session.setAttribute("user_id",   userId);
            session.setAttribute("user_name", userName);
            session.setAttribute("user_logged_in", true);

            // Also set shared keys (for current tab context)
            session.setAttribute("userId",   userId);
            session.setAttribute("userName", userName);
            session.setAttribute("userRole", "user");
            session.setMaxInactiveInterval(1800);

            Cookie ck = new Cookie("rememberedEmail", email);
            ck.setMaxAge(7 * 24 * 60 * 60);
            response.addCookie(ck);

            response.sendRedirect("UserDashboard/UserDashboard.jsp?login=success");

        } else if ("mentor".equalsIgnoreCase(dbRole)) {

            if (!"approved".equalsIgnoreCase(status)) {
%>
                <script>
                    alert("Your account status is '<%= status %>'. Please wait for admin approval.");
                    window.location = "SignIn.jsp";
                </script>
<%
                return;
            }

            // ── Store under MENTOR-specific keys (never overwritten by user login) ──
            session.setAttribute("mentor_id",   userId);
            session.setAttribute("mentor_name", userName);
            session.setAttribute("mentor_logged_in", true);

            // Load mentor profile id
            PreparedStatement ps2 = con.prepareStatement(
                "SELECT id FROM mentor_profile WHERE user_id=?"
            );
            ps2.setInt(1, userId);
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) {
                int mpId = rs2.getInt("id");
                session.setAttribute("mentor_profile_id", mpId);
                // keep old key in sync too
                session.setAttribute("mentorProfileId", mpId);
            }

            // Also set shared keys
            session.setAttribute("userId",   userId);
            session.setAttribute("userName", userName);
            session.setAttribute("userRole", "mentor");
            session.setMaxInactiveInterval(1800);

            Cookie ck = new Cookie("rememberedEmail", email);
            ck.setMaxAge(7 * 24 * 60 * 60);
            response.addCookie(ck);

            response.sendRedirect("MentorDashboard/MentorDashboard.jsp?login=success");
        }

    } else {
%>
        <script>
            alert("Invalid Email or Password!");
            window.location = "SignIn.jsp";
        </script>
<%
    }

} catch (Exception e) {
    out.println("Error: " + e.getMessage());
}
%>
