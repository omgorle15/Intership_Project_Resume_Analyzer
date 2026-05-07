<%@ page session="true" %>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>

<%
Integer mentorUserId = (Integer) session.getAttribute("userId");
String  role         = (String)  session.getAttribute("userRole");

// ── BUG FIX: Use userId + role check, fetch profileId from DB ──
if (mentorUserId == null || !"mentor".equalsIgnoreCase(role)) {
    response.sendRedirect("../SignIn.jsp");
    return;
}

int mentorProfileId = -1;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement pmp = con.prepareStatement("SELECT id FROM mentor_profile WHERE user_id=?");
    pmp.setInt(1, mentorUserId);
    ResultSet rmp = pmp.executeQuery();
    if (rmp.next()) {
        mentorProfileId = rmp.getInt("id");
        session.setAttribute("mentorProfileId", mentorProfileId);
    }
} catch (Exception e) { e.printStackTrace(); }

String successMsg = request.getParameter("success");
String errorMsg   = request.getParameter("error");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Add Time Slot</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>
body { background: #f4f6f9; }
.form-card { border-radius: 16px; border: none; }
.day-btn input[type=radio] { display: none; }
.day-btn label {
    display: inline-block; padding: 8px 16px; border: 2px solid #dee2e6;
    border-radius: 8px; cursor: pointer; font-weight: 500; transition: .2s; user-select: none;
}
.day-btn input[type=radio]:checked + label { background: #198754; color: white; border-color: #198754; }
</style>
</head>
<body>
<div class="container-fluid">
<div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-0"><i class="fa fa-plus-circle me-2 text-success"></i>Add Time Slot</h4>
            <small class="text-muted">Add slots that users can book for mentoring sessions</small>
        </div>
        <a href="bookTimeSlot.jsp" class="btn btn-outline-secondary btn-sm">
            <i class="fa fa-arrow-left me-1"></i>Back to Slots
        </a>
    </div>

    <% if (mentorProfileId == -1) { %>
    <div class="alert alert-warning rounded-4">
        <i class="fa fa-exclamation-triangle me-2"></i>
        Please <a href="updateMentor.jsp" class="fw-bold">set up your profile first</a> before adding slots.
    </div>
    <% } else { %>

    <% if (successMsg != null) { %>
        <div class="alert alert-success alert-dismissible fade show rounded-3">
            <i class="fa fa-check-circle me-2"></i><%= successMsg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="alert alert-danger alert-dismissible fade show rounded-3">
            <i class="fa fa-exclamation-circle me-2"></i><%= errorMsg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <div class="row">
        <div class="col-md-5">
            <div class="card shadow-sm form-card p-4">
                <h6 class="fw-bold mb-4"><i class="fa fa-calendar-plus me-2 text-success"></i>New Slot</h6>
                <form action="<%= request.getContextPath() %>/addSlot" method="post">
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Select Day</label>
                        <div class="d-flex flex-wrap gap-2">
                            <% String[] days = {"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"};
                               for (String d : days) { %>
                                <div class="day-btn">
                                    <input type="radio" name="day" id="day_<%= d %>" value="<%= d %>" required>
                                    <label for="day_<%= d %>"><%= d.substring(0,3) %></label>
                                </div>
                            <% } %>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-semibold">Select Time</label>
                        <input type="time" name="time" class="form-control form-control-lg" required>
                    </div>
                    <button type="submit" class="btn btn-success w-100 py-2 rounded-3">
                        <i class="fa fa-save me-2"></i>Save Slot
                    </button>
                </form>
            </div>
        </div>

        <div class="col-md-7">
            <div class="card shadow-sm form-card p-4">
                <h6 class="fw-bold mb-3"><i class="fa fa-list me-2 text-primary"></i>Your Current Slots</h6>
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead class="table-light">
                            <tr><th>Day</th><th>Time</th><th>Status</th></tr>
                        </thead>
                        <tbody>
<%
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mts.day, mts.time, mts.status, " +
        "(SELECT COUNT(*) FROM mentor_booking mb WHERE mb.slot_id = mts.slot_id) AS booked " +
        "FROM mentor_timeslot mts WHERE mts.mentor_profile_id=? ORDER BY mts.slot_id"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();
    boolean any = false;
    while (rs.next()) {
        any = true;
        boolean booked = rs.getInt("booked") > 0;
        String st = rs.getString("status");
%>
                            <tr>
                                <td><strong><%= rs.getString("day") %></strong></td>
                                <td><%= rs.getTime("time").toString().substring(0,5) %></td>
                                <td>
                                    <% if (booked) { %>
                                        <span class="badge bg-warning text-dark">Booked</span>
                                    <% } else if ("ACTIVE".equals(st)) { %>
                                        <span class="badge bg-success">Active</span>
                                    <% } else { %>
                                        <span class="badge bg-danger">Inactive</span>
                                    <% } %>
                                </td>
                            </tr>
<%
    }
    if (!any) {
%>
                            <tr><td colspan="3" class="text-center text-muted py-3">No slots yet</td></tr>
<%
    }
} catch (Exception e) {
    out.println("<tr><td colspan='3' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
}
%>
                        </tbody>
                    </table>
                </div>
                <a href="bookTimeSlot.jsp" class="btn btn-outline-primary btn-sm mt-2 rounded-3">
                    <i class="fa fa-cog me-1"></i>Manage All Slots
                </a>
            </div>
        </div>
    </div>
    <% } %>

</div>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
