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

/* ✅ Responsive Fix */
@media (max-width: 768px) {

    .col-md-10 {
        width: 100% !important;
        padding: 15px !important;
    }

    h4 {
        font-size: 18px;
    }

    .card h3 {
        font-size: 20px;
    }

    .table th, .table td {
        font-size: 12px;
        white-space: nowrap;
    }

    .table-responsive {
        overflow-x: auto;
    }

    #searchBox {
        font-size: 14px;
    }
}
</style>
</head>

<body>

<div class="container-fluid">
<div class="row">

<%@ include file="sidebar.jsp" %>

<div class="col-md-10 p-4">

    <!-- HEADER -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-2 mb-4">
        <div>
            <h4 class="fw-bold mb-0">
                <i class="fa fa-history me-2 text-secondary"></i>Booking History
            </h4>
            <small class="text-muted">All completed sessions</small>
        </div>
        <a href="viewUser.jsp" class="btn btn-outline-secondary btn-sm">
            <i class="fa fa-arrow-left me-1"></i>Active Bookings
        </a>
    </div>

    <!-- STATS -->
    <div class="row g-3 mb-4">
        <div class="col-12 col-sm-6 col-md-4">
            <div class="card shadow-sm text-center p-3 rounded-4">
                <h6>Total Cleared</h6>
                <h3><%= histTotal %></h3>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-md-4">
            <div class="card shadow-sm text-center p-3 rounded-4">
                <h6>Completed</h6>
                <h3 class="text-success"><%= histApproved %></h3>
            </div>
        </div>

        <div class="col-12 col-sm-6 col-md-4">
            <div class="card shadow-sm text-center p-3 rounded-4">
                <h6>Rejected</h6>
                <h3 class="text-danger"><%= histRejected %></h3>
            </div>
        </div>
    </div>

    <!-- SEARCH -->
    <div class="mb-3">
        <input type="text" id="searchBox" class="form-control rounded-3 w-100"
               placeholder="Search..." oninput="filterTable()">
    </div>

    <!-- TABLE -->
    <div class="card shadow-sm rounded-4">
        <div class="table-responsive">
            <table class="table table-hover text-nowrap mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>User</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Day</th>
                        <th>Time</th>
                        <th>Booked</th>
                        <th>Cleared</th>
                        <th>Status</th>
                    </tr>
                </thead>

                <tbody id="historyBody">

<%
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mb.booking_id, u.name, u.email, u.phone, mts.day, mts.time, mb.booked_at, mb.cleared_at, mb.status " +
        "FROM mentor_booking mb " +
        "JOIN users u ON mb.user_id = u.id " +
        "LEFT JOIN mentor_timeslot mts ON mb.slot_id = mts.slot_id " +
        "WHERE mb.mentor_profile_id=? AND mb.is_cleared=1"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();

    int count = 1;
    while (rs.next()) {
%>
<tr>
<td><%= count++ %></td>
<td><%= rs.getString("name") %></td>
<td><%= rs.getString("email") %></td>
<td><%= rs.getString("phone") %></td>
<td><%= rs.getString("day") %></td>
<td><%= rs.getTime("time") %></td>
<td><%= rs.getString("booked_at") %></td>
<td><%= rs.getString("cleared_at") %></td>
<td>
<span class="badge bg-success"><%= rs.getString("status") %></span>
</td>
</tr>
<%
    }
} catch (Exception e) {
%>
<tr><td colspan="9">Error: <%= e.getMessage() %></td></tr>
<%
}
%>

                </tbody>
            </table>
        </div>
    </div>

</div>
</div>
</div>

<script>
function filterTable() {
    const q = document.getElementById('searchBox').value.toLowerCase();
    document.querySelectorAll('#historyBody tr').forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
</script>

</body>
</html>