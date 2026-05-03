<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
Integer mentorProfileId = (Integer) session.getAttribute("mentorProfileId");
String  role            = (String)  session.getAttribute("userRole");

if (mentorProfileId == null || !"mentor".equalsIgnoreCase(role)) {
    response.sendRedirect("../SignIn.jsp");
    return;
}

String deleteId = request.getParameter("deleteSlot");
if (deleteId != null) {
    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement ps = con.prepareStatement(
            "DELETE FROM mentor_timeslot WHERE slot_id=? " +
            "AND slot_id NOT IN (SELECT slot_id FROM mentor_booking)"
        );
        ps.setInt(1, Integer.parseInt(deleteId));
        ps.executeUpdate();
    } catch (Exception e) { e.printStackTrace(); }
    response.sendRedirect("bookTimeSlot.jsp");
    return;
}

int totalSlots = 0, activeSlots = 0, bookedSlots = 0, inactiveSlots = 0;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mts.status, " +
        "(SELECT COUNT(*) FROM mentor_booking mb WHERE mb.slot_id = mts.slot_id) AS is_booked " +
        "FROM mentor_timeslot mts WHERE mts.mentor_profile_id=?"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        totalSlots++;
        if (rs.getInt("is_booked") > 0) bookedSlots++;
        else if ("ACTIVE".equals(rs.getString("status"))) activeSlots++;
        else inactiveSlots++;
    }
} catch (Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Time Slots</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>
body { background: #f4f6f9; }
.slot-booked { background-color: #fff8e1; }
</style>
</head>
<body>
<div class="container-fluid">
<div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h4 class="fw-bold mb-0"><i class="fa fa-clock me-2"></i>Manage Time Slots</h4>
            <small class="text-muted">Add, activate, or remove your available slots</small>
        </div>
        <a href="addTimeSlot.jsp" class="btn btn-success rounded-3">
            <i class="fa fa-plus me-2"></i>Add New Slot
        </a>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 text-center p-3">
                <i class="fa fa-calendar fa-2x text-primary mb-1"></i>
                <h6 class="text-muted">Total Slots</h6>
                <h3 class="fw-bold text-primary"><%= totalSlots %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 text-center p-3">
                <i class="fa fa-check-circle fa-2x text-success mb-1"></i>
                <h6 class="text-muted">Available</h6>
                <h3 class="fw-bold text-success"><%= activeSlots %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 text-center p-3">
                <i class="fa fa-user-check fa-2x text-warning mb-1"></i>
                <h6 class="text-muted">Booked by Users</h6>
                <h3 class="fw-bold text-warning"><%= bookedSlots %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm rounded-4 text-center p-3">
                <i class="fa fa-ban fa-2x text-danger mb-1"></i>
                <h6 class="text-muted">Inactive</h6>
                <h3 class="fw-bold text-danger"><%= inactiveSlots %></h3>
            </div>
        </div>
    </div>

    <div class="mb-3 d-flex gap-2 flex-wrap">
        <span class="badge bg-success px-3 py-2">Active — visible to users</span>
        <span class="badge bg-warning text-dark px-3 py-2">Booked — user selected this</span>
        <span class="badge bg-danger px-3 py-2">Inactive — hidden from users</span>
    </div>

    <div class="card shadow-sm border-0 rounded-4">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>Day</th>
                            <th>Time</th>
                            <th>Booked By</th>
                            <th>Booking Status</th>
                            <th>Slot Status</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
<%
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mts.slot_id, mts.day, mts.time, mts.status, " +
        "u.name AS booked_by, u.email AS booked_email, mb.status AS booking_status " +
        "FROM mentor_timeslot mts " +
        "LEFT JOIN mentor_booking mb ON mts.slot_id = mb.slot_id " +
        "LEFT JOIN users u ON mb.user_id = u.id " +
        "WHERE mts.mentor_profile_id=? " +
        "ORDER BY FIELD(mts.status,'ACTIVE','DEACTIVE'), mts.slot_id"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();
    int count = 1;
    boolean found = false;
    while (rs.next()) {
        found = true;
        String slotStatus    = rs.getString("status");
        String bookedBy      = rs.getString("booked_by");
        String bookingStatus = rs.getString("booking_status");
        boolean isBooked     = (bookedBy != null);
%>
                        <tr class="<%= isBooked ? "slot-booked" : "" %>">
                            <td class="ps-3"><%= count++ %></td>
                            <td><strong><%= rs.getString("day") %></strong></td>
                            <td><i class="fa fa-clock text-muted me-1"></i><%= rs.getTime("time").toString().substring(0,5) %></td>
                            <td>
                                <% if (isBooked) { %>
                                    <i class="fa fa-user text-warning me-1"></i>
                                    <strong><%= bookedBy %></strong><br>
                                    <small class="text-muted"><%= rs.getString("booked_email") %></small>
                                <% } else { %>
                                    <span class="text-muted">Not booked</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (isBooked) {
                                    String bsCls = "bg-warning text-dark";
                                    if ("Approved".equalsIgnoreCase(bookingStatus)) bsCls = "bg-success";
                                    else if ("Rejected".equalsIgnoreCase(bookingStatus)) bsCls = "bg-danger";
                                %>
                                    <span class="badge <%= bsCls %>"><%= bookingStatus %></span>
                                <% } else { %>
                                    <span class="text-muted small">—</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (isBooked) { %>
                                    <span class="badge bg-warning text-dark">Booked</span>
                                <% } else if ("ACTIVE".equals(slotStatus)) { %>
                                    <span class="badge bg-success">Active</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Inactive</span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <% if (!isBooked) { %>
                                    <% if ("ACTIVE".equals(slotStatus)) { %>
                                        <a href="updateSlotStatus.jsp?id=<%= rs.getInt("slot_id") %>&status=DEACTIVE"
                                           class="btn btn-sm btn-outline-danger me-1" title="Deactivate">
                                            <i class="fa fa-ban"></i>
                                        </a>
                                    <% } else { %>
                                        <a href="updateSlotStatus.jsp?id=<%= rs.getInt("slot_id") %>&status=ACTIVE"
                                           class="btn btn-sm btn-outline-success me-1" title="Activate">
                                            <i class="fa fa-check"></i>
                                        </a>
                                    <% } %>
                                    <a href="bookTimeSlot.jsp?deleteSlot=<%= rs.getInt("slot_id") %>"
                                       class="btn btn-sm btn-outline-danger"
                                       onclick="return confirm('Delete this slot permanently?')"
                                       title="Delete">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                <% } else { %>
                                    <span class="badge bg-secondary">Locked</span>
                                <% } %>
                            </td>
                        </tr>
<%
    }
    if (!found) {
%>
                        <tr>
                            <td colspan="7" class="text-center py-5 text-muted">
                                <i class="fa fa-calendar-plus fa-2x mb-2 d-block"></i>
                                No slots yet. <a href="addTimeSlot.jsp">Add your first slot</a>.
                            </td>
                        </tr>
<%
    }
} catch (Exception e) {
    out.println("<tr><td colspan='7' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
}
%>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>