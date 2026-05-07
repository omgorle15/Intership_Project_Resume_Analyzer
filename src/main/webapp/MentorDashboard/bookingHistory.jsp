<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
Integer mentorUserId = (Integer) session.getAttribute("userId");
String  role         = (String)  session.getAttribute("userRole");
if (mentorUserId == null || !"mentor".equalsIgnoreCase(role)) {
    response.sendRedirect("../SignIn.jsp"); return;
}

int mentorProfileId = -1;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement("SELECT id FROM mentor_profile WHERE user_id=?");
    ps.setInt(1, mentorUserId);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) mentorProfileId = rs.getInt("id");
} catch (Exception e) { e.printStackTrace(); }

// History stats
int histTotal = 0, histApproved = 0, histRejected = 0;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT status FROM mentor_booking WHERE mentor_profile_id=? AND is_cleared=1"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        histTotal++;
        if ("Approved".equalsIgnoreCase(rs.getString("status"))) histApproved++;
        else if ("Rejected".equalsIgnoreCase(rs.getString("status"))) histRejected++;
    }
} catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Booking History</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>
body { background: #f4f6f9; }
.history-badge { font-size: 0.75rem; }
</style>
</head>
<body>
<div class="container-fluid"><div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-0"><i class="fa fa-history me-2 text-secondary"></i>Booking History</h4>
            <small class="text-muted">All completed sessions (cleared after 1 hour post-slot)</small>
        </div>
        <a href="viewUser.jsp" class="btn btn-outline-secondary btn-sm">
            <i class="fa fa-arrow-left me-1"></i>Active Bookings
        </a>
    </div>

    <!-- History Stats -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4 bg-white">
                <i class="fa fa-archive fa-2x text-secondary mb-1"></i>
                <h6 class="text-muted">Total Cleared</h6>
                <h3 class="fw-bold text-secondary"><%= histTotal %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4 bg-white">
                <i class="fa fa-check-circle fa-2x text-success mb-1"></i>
                <h6 class="text-muted">Sessions Completed</h6>
                <h3 class="fw-bold text-success"><%= histApproved %></h3>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4 bg-white">
                <i class="fa fa-times-circle fa-2x text-danger mb-1"></i>
                <h6 class="text-muted">Rejected / Cancelled</h6>
                <h3 class="fw-bold text-danger"><%= histRejected %></h3>
            </div>
        </div>
    </div>

    <!-- Search box -->
    <div class="mb-3">
        <input type="text" id="searchBox" class="form-control rounded-3"
               placeholder="🔍 Search by name, email, day..." oninput="filterTable()">
    </div>

    <div class="card shadow-sm border-0 rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="historyTable">
                    <thead style="background:#374151;color:white;">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>User</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Day</th>
                            <th>Time</th>
                            <th>Booked On</th>
                            <th>Cleared At</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="historyBody">
<%
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mb.booking_id, u.name, u.email, u.phone, " +
        "COALESCE(mts.day,'N/A') AS day, mts.time, " +
        "mb.booked_at, mb.cleared_at, mb.status " +
        "FROM mentor_booking mb " +
        "JOIN users u ON mb.user_id = u.id " +
        "LEFT JOIN mentor_timeslot mts ON mb.slot_id = mts.slot_id " +
        "WHERE mb.mentor_profile_id=? AND mb.is_cleared=1 " +
        "ORDER BY mb.cleared_at DESC"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();
    boolean found = false; int count = 1;
    while (rs.next()) {
        found = true;
        String status    = rs.getString("status");
        String bookedOn  = rs.getString("booked_at")  != null ? rs.getString("booked_at").substring(0,16)  : "—";
        String clearedAt = rs.getString("cleared_at") != null ? rs.getString("cleared_at").substring(0,16) : "—";
        String timeVal   = rs.getTime("time") != null ? rs.getTime("time").toString().substring(0,5) : "N/A";
        String phone     = rs.getString("phone") != null ? rs.getString("phone") : "—";
        String badgeCls  = "Approved".equalsIgnoreCase(status) ? "bg-success" : "bg-danger";
        String rowCls    = "Approved".equalsIgnoreCase(status) ? "" : "table-light";
%>
                        <tr class="<%= rowCls %>">
                            <td class="ps-3 text-muted"><%= count++ %></td>
                            <td>
                                <i class="fa fa-user-circle text-muted me-2"></i>
                                <strong><%= rs.getString("name") %></strong>
                            </td>
                            <td class="text-muted small"><%= rs.getString("email") %></td>
                            <td class="small"><%= phone %></td>
                            <td><%= rs.getString("day") %></td>
                            <td><i class="fa fa-clock text-muted me-1"></i><%= timeVal %></td>
                            <td class="text-muted small"><%= bookedOn %></td>
                            <td class="text-muted small"><%= clearedAt %></td>
                            <td>
                                <span class="badge <%= badgeCls %> history-badge">
                                    <%= "Approved".equalsIgnoreCase(status) ? "✔ Completed" : "✖ " + status %>
                                </span>
                            </td>
                        </tr>
<%
    }
    if (!found) {
%>
                        <tr>
                            <td colspan="9" class="text-center py-5 text-muted">
                                <i class="fa fa-clock fa-2x mb-2 d-block"></i>
                                No history yet. Completed sessions will appear here.
                            </td>
                        </tr>
<% } } catch (Exception e) { %>
                        <tr><td colspan="9" class="text-danger text-center">Error: <%= e.getMessage() %></td></tr>
<% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div></div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function filterTable() {
    const q = document.getElementById('searchBox').value.toLowerCase();
    document.querySelectorAll('#historyBody tr').forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
</script>
</body></html>
