<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
Integer mentorUserId = (Integer) session.getAttribute("userId");
String  role         = (String)  session.getAttribute("userRole");

if (mentorUserId == null || !"mentor".equalsIgnoreCase(role)) {
    response.sendRedirect("../SignIn.jsp");
    return;
}

// Fetch mentorProfileId fresh from DB — never rely on session
int mentorProfileId = -1;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT id FROM mentor_profile WHERE user_id=?"
    );
    ps.setInt(1, mentorUserId);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        mentorProfileId = rs.getInt("id");
    }
} catch (Exception e) { e.printStackTrace(); }

if (mentorProfileId == -1) {
%>
<!DOCTYPE html>
<html><head>
<meta charset="UTF-8"><title>Booked Users</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>body{background:#f4f6f9;}</style>
</head><body>
<div class="container-fluid"><div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">
    <div class="alert alert-warning mt-4">
        <i class="fa fa-exclamation-triangle me-2"></i>
        You have not set up your mentor profile yet.
        <a href="updateMentor.jsp" class="alert-link">Create your profile first</a>.
    </div>
</div></div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body></html>
<%
    return;
}

// Handle approve / reject
String action    = request.getParameter("action");
String bookingId = request.getParameter("bid");

if (action != null && bookingId != null) {
    String newStatus = "approve".equals(action) ? "Approved" : "Rejected";
    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement upd = con.prepareStatement(
            "UPDATE mentor_booking SET status=? WHERE booking_id=?"
        );
        upd.setString(1, newStatus);
        upd.setInt(2, Integer.parseInt(bookingId));
        upd.executeUpdate();

        if ("Rejected".equals(newStatus)) {
            PreparedStatement getSlot = con.prepareStatement(
                "SELECT slot_id FROM mentor_booking WHERE booking_id=?"
            );
            getSlot.setInt(1, Integer.parseInt(bookingId));
            ResultSet slotRs = getSlot.executeQuery();
            if (slotRs.next() && slotRs.getObject("slot_id") != null) {
                PreparedStatement reactivate = con.prepareStatement(
                    "UPDATE mentor_timeslot SET status='ACTIVE' WHERE slot_id=?"
                );
                reactivate.setInt(1, slotRs.getInt("slot_id"));
                reactivate.executeUpdate();
            }
        }
    } catch (Exception ex) { ex.printStackTrace(); }
    response.sendRedirect("viewUser.jsp");
    return;
}

// Count summary
int total = 0, pending = 0, approved = 0, rejected = 0;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT status FROM mentor_booking WHERE mentor_profile_id=?"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        total++;
        String s = rs.getString("status");
        if ("Pending".equalsIgnoreCase(s))       pending++;
        else if ("Approved".equalsIgnoreCase(s)) approved++;
        else if ("Rejected".equalsIgnoreCase(s)) rejected++;
    }
} catch (Exception e) { e.printStackTrace(); }
%>


<html>
<head>
<meta charset="UTF-8">
<title>Booked Users</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>body { background: #f4f6f9; }</style>
</head>
<body>
<div class="container-fluid">
<div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold"><i class="fa fa-users me-2"></i>Booked Users</h4>
        <a href="MentorDashboard.jsp" class="btn btn-outline-secondary btn-sm">
            <i class="fa fa-arrow-left me-1"></i>Back
        </a>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Total Bookings</h6>
                <h3 class="fw-bold text-primary"><%= total %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Pending</h6>
                <h3 class="fw-bold text-warning"><%= pending %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Approved</h6>
                <h3 class="fw-bold text-success"><%= approved %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Rejected</h6>
                <h3 class="fw-bold text-danger"><%= rejected %></h3>
            </div>
        </div>
    </div>

    <ul class="nav nav-tabs mb-3" id="filterTabs">
        <li class="nav-item"><a class="nav-link active" data-filter="all"      href="#">All</a></li>
        <li class="nav-item"><a class="nav-link"        data-filter="Pending"  href="#">Pending</a></li>
        <li class="nav-item"><a class="nav-link"        data-filter="Approved" href="#">Approved</a></li>
        <li class="nav-item"><a class="nav-link"        data-filter="Rejected" href="#">Rejected</a></li>
    </ul>

    <div class="card shadow-sm border-0 rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="bookingTable">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>User Name</th>
                            <th>Email</th>
                            <th>Day</th>
                            <th>Time</th>
                            <th>Booked On</th>
                            <th>Status</th>
                            <th class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
<%
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mb.booking_id, u.name, u.email, " +
        "COALESCE(mts.day, 'N/A') AS day, " +
        "mts.time, mb.status, mb.created_at " +
        "FROM mentor_booking mb " +
        "JOIN users u                  ON mb.user_id = u.id " +
        "LEFT JOIN mentor_timeslot mts ON mb.slot_id = mts.slot_id " +
        "WHERE mb.mentor_profile_id = ? " +
        
        "ORDER BY mb.booking_id DESC"
    );
    // ^^^ REMOVED "AND u.role = 'user'" — that was blocking rows
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();

    boolean found = false;
    int count = 1;

    while (rs.next()) {
        found = true;
        String status   = rs.getString("status");
        String bid      = String.valueOf(rs.getInt("booking_id"));
        String bookedOn = rs.getString("created_at") != null
                          ? rs.getString("created_at").substring(0, 10) : "—";
        String badgeCls = "bg-warning text-dark";
        if ("Approved".equalsIgnoreCase(status)) badgeCls = "bg-success";
        else if ("Rejected".equalsIgnoreCase(status)) badgeCls = "bg-danger";
        String timeVal = rs.getTime("time") != null
                         ? rs.getTime("time").toString().substring(0, 5) : "N/A";
%>
                        <tr data-status="<%= status %>">
                            <td class="ps-3"><%= count++ %></td>
                            <td><i class="fa fa-user-circle text-muted me-2"></i><strong><%= rs.getString("name") %></strong></td>
                            <td class="text-muted"><%= rs.getString("email") %></td>
                            <td><%= rs.getString("day") %></td>
                            <td><%= timeVal %></td>
                            <td class="text-muted small"><%= bookedOn %></td>
                            <td><span class="badge <%= badgeCls %>"><%= status %></span></td>
                            <td class="text-center">
                                <% if ("Pending".equalsIgnoreCase(status)) { %>
                                    <a href="viewUser.jsp?action=approve&bid=<%= bid %>"
                                       class="btn btn-sm btn-success me-1"
                                       onclick="return confirm('Approve this booking?')">
                                        <i class="fa fa-check"></i> Approve
                                    </a>
                                    <a href="viewUser.jsp?action=reject&bid=<%= bid %>"
                                       class="btn btn-sm btn-danger"
                                       onclick="return confirm('Reject this booking?')">
                                        <i class="fa fa-times"></i> Reject
                                    </a>
                                <% } else { %>
                                    <span class="text-muted small">—</span>
                                <% } %>
                            </td>
                        </tr>
<%
    }
    if (!found) {
%>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                <i class="fa fa-inbox fa-2x mb-2 d-block"></i>No bookings found yet.
                            </td>
                        </tr>
<%
    }
} catch (Exception e) {
%>
                        <tr><td colspan="8" class="text-danger text-center">Error: <%= e.getMessage() %></td></tr>
<% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.querySelectorAll('#filterTabs .nav-link').forEach(tab => {
    tab.addEventListener('click', function(e) {
        e.preventDefault();
        document.querySelectorAll('#filterTabs .nav-link').forEach(t => t.classList.remove('active'));
        this.classList.add('active');
        const filter = this.dataset.filter;
        document.querySelectorAll('#bookingTable tbody tr[data-status]').forEach(row => {
            row.style.display = (filter === 'all' || row.dataset.status === filter) ? '' : 'none';
        });
    });
});
</script>
</body>
</html>