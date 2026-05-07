<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
/*
 * Reads from MENTOR-SPECIFIC session keys (mentor_id, mentor_name, mentor_logged_in)
 * So even if a user logs in on another tab and sets "userName", this page
 * still shows the correct mentor name from "mentor_name" key.
 */
Boolean mentorLoggedIn = (Boolean) session.getAttribute("mentor_logged_in");
Integer id             = (Integer) session.getAttribute("mentor_id");
String  name           = (String)  session.getAttribute("mentor_name");

if (mentorLoggedIn == null || !mentorLoggedIn || id == null) {
    response.sendRedirect("../SignIn.jsp");
    return;
}

// Sync shared keys so included files (sidebar etc.) still work
session.setAttribute("userId",   id);
session.setAttribute("userName", name);
session.setAttribute("userRole", "mentor");

// Fetch mentorProfileId fresh from DB (in case session lost it)
Integer mentorProfileId = (Integer) session.getAttribute("mentor_profile_id");
if (mentorProfileId == null) {
    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement pmp = con.prepareStatement("SELECT id FROM mentor_profile WHERE user_id=?");
        pmp.setInt(1, id);
        ResultSet rmp = pmp.executeQuery();
        if (rmp.next()) {
            mentorProfileId = rmp.getInt("id");
            session.setAttribute("mentor_profile_id", mentorProfileId);
            session.setAttribute("mentorProfileId",   mentorProfileId);
        }
    } catch (Exception e) { e.printStackTrace(); }
}

int totalUsers = 0, totalBookings = 0, pendingCount = 0, approvedCount = 0;
String bio = "", photo = "", specialization = "";

try (Connection con = DBConnection.getConnection()) {

    PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) FROM users WHERE role='user'");
    ResultSet rs1 = ps1.executeQuery();
    if (rs1.next()) totalUsers = rs1.getInt(1);

    if (mentorProfileId != null) {
        PreparedStatement ps2 = con.prepareStatement(
            "SELECT COUNT(*), " +
            "SUM(CASE WHEN mb.status='Pending'  THEN 1 ELSE 0 END), " +
            "SUM(CASE WHEN mb.status='Approved' THEN 1 ELSE 0 END) " +
            "FROM mentor_booking mb " +
            "JOIN mentor_profile mp ON mb.mentor_profile_id = mp.id " +
            "WHERE mp.user_id = ?"
        );
        ps2.setInt(1, id);
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) {
            totalBookings = rs2.getInt(1);
            pendingCount  = rs2.getInt(2);
            approvedCount = rs2.getInt(3);
        }
    }

    PreparedStatement ps3 = con.prepareStatement(
        "SELECT bio, photo, specialization FROM mentor_profile WHERE user_id=?"
    );
    ps3.setInt(1, id);
    ResultSet rs3 = ps3.executeQuery();
    if (rs3.next()) {
        bio            = rs3.getString("bio")            != null ? rs3.getString("bio")            : "";
        photo          = rs3.getString("photo")          != null ? rs3.getString("photo")          : "";
        specialization = rs3.getString("specialization") != null ? rs3.getString("specialization") : "";
    }

} catch (Exception e) {
    out.println("<!-- DB Error: " + e.getMessage() + " -->");
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mentor Dashboard</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>
body { background: #f4f6f9; }
.stat-card { border-radius: 16px; border: none; transition: transform .2s; }
.stat-card:hover { transform: translateY(-4px); }
.profile-img { width: 90px; height: 90px; border-radius: 50%; object-fit: cover; border: 3px solid #0d6efd; }
</style>
</head>
<body>

<div class="container-fluid">
<div class="row">

<%@ include file="sidebar.jsp" %>

<div class="col-md-10 p-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-0">Mentor Dashboard</h4>
            <small class="text-muted">Welcome back, <strong><%= name %></strong></small>
        </div>
        <span class="badge bg-primary fs-6"><i class="fa fa-circle me-1" style="font-size:8px"></i>Mentor</span>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card stat-card shadow-sm p-3 text-center">
                <i class="fa fa-users fa-2x text-primary mb-2"></i>
                <h6 class="text-muted">Registered Users</h6>
                <h3 class="fw-bold text-primary"><%= totalUsers %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card stat-card shadow-sm p-3 text-center">
                <i class="fa fa-calendar-check fa-2x text-success mb-2"></i>
                <h6 class="text-muted">Total Bookings</h6>
                <h3 class="fw-bold text-success"><%= totalBookings %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card stat-card shadow-sm p-3 text-center">
                <i class="fa fa-clock fa-2x text-warning mb-2"></i>
                <h6 class="text-muted">Pending</h6>
                <h3 class="fw-bold text-warning"><%= pendingCount %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card stat-card shadow-sm p-3 text-center">
                <i class="fa fa-check-circle fa-2x text-info mb-2"></i>
                <h6 class="text-muted">Approved</h6>
                <h3 class="fw-bold text-info"><%= approvedCount %></h3>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-md-5">
            <div class="card shadow-sm rounded-4 border-0 h-100">
                <div class="card-header bg-white border-0 pt-3">
                    <h6 class="fw-bold mb-0"><i class="fa fa-user-tie me-2 text-primary"></i>My Profile</h6>
                </div>
                <div class="card-body d-flex gap-3 align-items-start">
                    <% if (photo != null && !photo.isEmpty()) { %>
                        <img src="../uploads/<%= photo %>" class="profile-img">
                    <% } else { %>
                        <div class="profile-img d-flex align-items-center justify-content-center bg-light">
                            <i class="fa fa-user-circle fa-3x text-secondary"></i>
                        </div>
                    <% } %>
                    <div>
                        <h6 class="fw-bold mb-1"><%= name %></h6>
                        <p class="text-muted small mb-2">
                            <%= bio.isEmpty() ? "No bio added yet." : (bio.length() > 100 ? bio.substring(0,100) + "..." : bio) %>
                        </p>
                        <% if (!specialization.isEmpty()) {
                            for (String s : specialization.split(",")) { %>
                                <span class="badge bg-primary-subtle text-primary me-1 mb-1"><%= s.trim() %></span>
                        <% } } %>
                        <div class="mt-3">
                            <a href="updateMentor.jsp" class="btn btn-sm btn-outline-primary me-2">
                                <i class="fa fa-edit me-1"></i>Edit
                            </a>
                            <a href="viewProfile.jsp" class="btn btn-sm btn-outline-secondary">
                                <i class="fa fa-eye me-1"></i>View
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-7">
            <div class="card shadow-sm rounded-4 border-0 h-100">
                <div class="card-header bg-white border-0 pt-3">
                    <h6 class="fw-bold mb-0"><i class="fa fa-bolt me-2 text-warning"></i>Quick Actions</h6>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-6">
                            <a href="viewUser.jsp" class="btn btn-outline-success w-100 py-3 rounded-3">
                                <i class="fa fa-users d-block fs-4 mb-1"></i>View Booked Users
                            </a>
                        </div>
                        <div class="col-6">
                            <a href="bookTimeSlot.jsp" class="btn btn-outline-primary w-100 py-3 rounded-3">
                                <i class="fa fa-clock d-block fs-4 mb-1"></i>Manage Slots
                            </a>
                        </div>
                        <div class="col-6">
                            <a href="addTimeSlot.jsp" class="btn btn-outline-info w-100 py-3 rounded-3">
                                <i class="fa fa-plus d-block fs-4 mb-1"></i>Add Time Slot
                            </a>
                        </div>
                        <div class="col-6">
                            <a href="updateMentor.jsp" class="btn btn-outline-warning w-100 py-3 rounded-3">
                                <i class="fa fa-edit d-block fs-4 mb-1"></i>Update Profile
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
