<%@ page import="java.sql.*,java.net.*,java.io.*" %>
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
    if (rs.next()) {
        mentorProfileId = rs.getInt("id");
        session.setAttribute("mentorProfileId", mentorProfileId);
    }
} catch (Exception e) { e.printStackTrace(); }

if (mentorProfileId == -1) {
%>
<!DOCTYPE html><html><head>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<style>body{background:#f4f6f9;}</style></head><body>
<div class="container-fluid"><div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">
<div class="alert alert-warning mt-5 rounded-4">
    <i class="fa fa-exclamation-triangle me-2"></i>
    Profile not set up yet. <a href="updateMentor.jsp" class="fw-bold">Create your profile first</a>.
</div></div></div></div></body></html>
<% return; }

// Auto-trigger slot cleanup
try {
    URL url = new URL(request.getScheme() + "://" + request.getServerName()
              + ":" + request.getServerPort()
              + request.getContextPath() + "/clearExpiredSlots?mentorProfileId=" + mentorProfileId);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");
    conn.getResponseCode();
    conn.disconnect();
} catch (Exception ignore) {}

// ── Handle Approve / Reject / Re-approve ─────────────────────────────────────
String action    = request.getParameter("action");
String bookingId = request.getParameter("bid");

if (action != null && bookingId != null) {
    String newStatus = "approve".equals(action) ? "Approved" : "Rejected";
    int bid = Integer.parseInt(bookingId);
    boolean mailSent = false;
    String mailError = "";

    try (Connection con = DBConnection.getConnection()) {
        PreparedStatement upd = con.prepareStatement(
            "UPDATE mentor_booking SET status=? WHERE booking_id=?"
        );
        upd.setString(1, newStatus);
        upd.setInt(2, bid);
        upd.executeUpdate();

        // If rejected, free the slot
        if ("Rejected".equals(newStatus)) {
            PreparedStatement getSlot = con.prepareStatement(
                "SELECT slot_id FROM mentor_booking WHERE booking_id=?"
            );
            getSlot.setInt(1, bid);
            ResultSet slotRs = getSlot.executeQuery();
            if (slotRs.next()) {
                PreparedStatement reactivate = con.prepareStatement(
                    "UPDATE mentor_timeslot SET status='ACTIVE' WHERE slot_id=?"
                );
                reactivate.setInt(1, slotRs.getInt("slot_id"));
                reactivate.executeUpdate();
            }
        }

        // Send confirmation email on approve
        if ("Approved".equals(newStatus)) {
            try {
                URL mailUrl = new URL(request.getScheme() + "://" + request.getServerName()
                    + ":" + request.getServerPort()
                    + request.getContextPath() + "/sendBookingMail");
                HttpURLConnection mailConn = (HttpURLConnection) mailUrl.openConnection();
                mailConn.setRequestMethod("POST");
                mailConn.setDoOutput(true);
                mailConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                String postBody = "bookingId=" + bid;
                mailConn.setRequestProperty("Content-Length", String.valueOf(postBody.length()));
                try (OutputStream os = mailConn.getOutputStream()) {
                    os.write(postBody.getBytes("UTF-8"));
                    os.flush();
                }
                int code = mailConn.getResponseCode();
                mailConn.disconnect();
                mailSent = (code == 200);
                if (!mailSent) {
                    mailError = "Mail servlet returned HTTP " + code;
                }
            } catch (Exception mailEx) {
                mailError = mailEx.getMessage();
            }
        }
    } catch (Exception ex) { ex.printStackTrace(); }

    String requestedWith = request.getHeader("X-Requested-With");
    if ("XMLHttpRequest".equals(requestedWith)) {
        response.setContentType("application/json; charset=UTF-8");
        if ("Approved".equals(newStatus)) {
            response.getWriter().write("{\"success\":true,\"status\":\"" + newStatus
                + "\",\"mailSent\":" + mailSent
                + ",\"mailError\":\"" + (mailError != null ? mailError.replace("\"","'") : "") + "\"}");
        } else {
            response.getWriter().write("{\"success\":true,\"status\":\"" + newStatus + "\",\"mailSent\":false}");
        }
        return;
    }
    response.sendRedirect("viewUser.jsp"); return;
}

// ── Handle Send Mail (AJAX only) ─────────────────────────────────────────────
String sendMailBid = request.getParameter("sendMail");
if (sendMailBid != null) {
    int bid = Integer.parseInt(sendMailBid);
    boolean mailSent = false;
    String mailError = "";
    try {
        URL mailUrl = new URL(request.getScheme() + "://" + request.getServerName()
            + ":" + request.getServerPort()
            + request.getContextPath() + "/sendBookingMail");
        HttpURLConnection mailConn = (HttpURLConnection) mailUrl.openConnection();
        mailConn.setRequestMethod("POST");
        mailConn.setDoOutput(true);
        mailConn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        String postBody = "bookingId=" + bid;
        mailConn.setRequestProperty("Content-Length", String.valueOf(postBody.length()));
        try (OutputStream os = mailConn.getOutputStream()) {
            os.write(postBody.getBytes("UTF-8"));
            os.flush();
        }
        int code = mailConn.getResponseCode();
        mailConn.disconnect();
        mailSent = (code == 200);
        if (!mailSent) mailError = "Mail servlet returned HTTP " + code;
    } catch (Exception mailEx) {
        mailError = mailEx.getMessage();
    }
    response.setContentType("application/json; charset=UTF-8");
    response.getWriter().write("{\"mailSent\":" + mailSent
        + ",\"mailError\":\"" + (mailError != null ? mailError.replace("\"","'") : "") + "\"}");
    return;
}

// ── Counts ───────────────────────────────────────────────────────────────────
int total = 0, pending = 0, approved = 0, rejected = 0;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT status FROM mentor_booking WHERE mentor_profile_id=? AND is_cleared=0"
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

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Booked Users</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
<style>
body { background: #f4f6f9; }
tr.status-updating { opacity: 0.45; pointer-events: none; transition: opacity .2s; }
.btn-resend { font-size: 0.78rem; padding: 3px 9px; }
</style>
</head>
<body>
<div class="container-fluid"><div class="row">
<%@ include file="sidebar.jsp" %>
<div class="col-md-10 p-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold"><i class="fa fa-users me-2"></i>Active Bookings</h4>
        <div class="d-flex gap-2">
            <a href="bookingHistory.jsp" class="btn btn-outline-secondary btn-sm">
                <i class="fa fa-history me-1"></i>View History
            </a>
            <a href="MentorDashboard.jsp" class="btn btn-outline-dark btn-sm">
                <i class="fa fa-arrow-left me-1"></i>Back
            </a>
        </div>
    </div>

    <div class="alert alert-info rounded-4 mb-4 py-2 px-3" style="font-size:.88rem">
        <i class="fa fa-info-circle me-1"></i>
        <strong>Email sent automatically</strong> when you click <strong>Approve</strong>.
        You can also <strong>resend</strong> it anytime from the Action column.
    </div>

    <!-- Summary Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Total Active</h6>
                <h3 class="fw-bold text-primary" id="countTotal"><%= total %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Pending</h6>
                <h3 class="fw-bold text-warning" id="countPending"><%= pending %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Approved</h6>
                <h3 class="fw-bold text-success" id="countApproved"><%= approved %></h3>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card border-0 shadow-sm text-center p-3 rounded-4">
                <h6 class="text-muted">Rejected</h6>
                <h3 class="fw-bold text-danger" id="countRejected"><%= rejected %></h3>
            </div>
        </div>
    </div>

    <!-- Filter Tabs -->
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
                            <th>User</th>
                            <th>Email</th>
                            <th>Phone</th>
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
        "SELECT mb.booking_id, u.name, u.email, u.phone, " +
        "COALESCE(mts.day,'N/A') AS day, mts.time, mb.status, mb.booked_at " +
        "FROM mentor_booking mb " +
        "JOIN users u ON mb.user_id = u.id " +
        "LEFT JOIN mentor_timeslot mts ON mb.slot_id = mts.slot_id " +
        "WHERE mb.mentor_profile_id=? AND mb.is_cleared=0 " +
        "ORDER BY mb.booking_id DESC"
    );
    ps.setInt(1, mentorProfileId);
    ResultSet rs = ps.executeQuery();
    boolean found = false; int count = 1;
    while (rs.next()) {
        found = true;
        String status   = rs.getString("status");
        String bid      = String.valueOf(rs.getInt("booking_id"));
        String bookedOn = rs.getString("booked_at") != null ? rs.getString("booked_at").substring(0,10) : "N/A";
        String timeVal  = rs.getTime("time") != null ? rs.getTime("time").toString().substring(0,5) : "N/A";
        String phone    = rs.getString("phone") != null ? rs.getString("phone") : "Not Available";
        String uname    = rs.getString("name");
        String uemail   = rs.getString("email");
        String day      = rs.getString("day");
        String badgeCls = "bg-warning text-dark";
        if ("Approved".equalsIgnoreCase(status)) badgeCls = "bg-success";
        else if ("Rejected".equalsIgnoreCase(status)) badgeCls = "bg-danger";
%>
                        <tr data-status="<%= status %>" id="row-<%= bid %>">
                            <td class="ps-3"><%= count++ %></td>
                            <td><i class="fa fa-user-circle text-muted me-2"></i><strong><%= uname %></strong></td>
                            <td class="text-muted small"><%= uemail %></td>
                            <td><i class="fa fa-phone text-muted me-1"></i><%= phone %></td>
                            <td><strong><%= day %></strong></td>
                            <td><i class="fa fa-clock text-muted me-1"></i><%= timeVal %></td>
                            <td class="text-muted small"><%= bookedOn %></td>
                            <td><span class="badge <%= badgeCls %>" id="badge-<%= bid %>"><%= status %></span></td>
                            <td class="text-center" id="action-<%= bid %>">

                                <%-- ── PENDING: Approve + Reject ── --%>
                                <% if ("Pending".equalsIgnoreCase(status)) { %>
                                    <button class="btn btn-sm btn-success me-1"
                                            onclick="handleAction('<%= bid %>', 'approve', '<%= uname %>')">
                                        <i class="fa fa-check"></i> Approve
                                    </button>
                                    <button class="btn btn-sm btn-danger"
                                            onclick="handleAction('<%= bid %>', 'reject', '<%= uname %>')">
                                        <i class="fa fa-times"></i> Reject
                                    </button>

                                <%-- ── APPROVED: Resend Mail button ── --%>
                                <% } else if ("Approved".equalsIgnoreCase(status)) { %>
                                    <button class="btn btn-sm btn-outline-primary btn-resend"
                                            onclick="resendMail('<%= bid %>', '<%= uname %>')">
                                        <i class="fa fa-envelope me-1"></i>Resend Mail
                                    </button>

                                <%-- ── REJECTED: Re-approve button ── --%>
                                <% } else if ("Rejected".equalsIgnoreCase(status)) { %>
                                    <button class="btn btn-sm btn-outline-warning"
                                            onclick="handleAction('<%= bid %>', 'approve', '<%= uname %>')">
                                        <i class="fa fa-redo me-1"></i>Re-approve
                                    </button>
                                <% } %>

                            </td>
                        </tr>
<%
    }
    if (!found) {
%>
                        <tr>
                            <td colspan="9" class="text-center py-5 text-muted">
                                <i class="fa fa-inbox fa-2x mb-2 d-block"></i>
                                No active bookings. <a href="bookingHistory.jsp">View history</a>.
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
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>

// ─── Filter tabs ──────────────────────────────────────────────────────────────
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

// ─── Approve / Reject / Re-approve ───────────────────────────────────────────
function handleAction(bid, action, userName) {
    const isApprove = (action === 'approve');

    Swal.fire({
        title: isApprove ? 'Approve Booking?' : 'Reject Booking?',
        html: isApprove
            ? `Approve booking for <strong>${userName}</strong>?<br>
               <small class="text-muted mt-1 d-block">A confirmation email will be sent to the user.</small>`
            : `Reject booking for <strong>${userName}</strong>?<br>
               <small class="text-muted mt-1 d-block">The time slot will be freed for others.</small>`,
        icon: isApprove ? 'question' : 'warning',
        showCancelButton: true,
        confirmButtonColor: isApprove ? '#198754' : '#dc3545',
        cancelButtonColor: '#6c757d',
        confirmButtonText: isApprove ? 'Yes, Approve' : 'Yes, Reject',
        cancelButtonText: 'Cancel',
        reverseButtons: true
    }).then(result => {
        if (!result.isConfirmed) return;

        const row = document.getElementById('row-' + bid);
        row.classList.add('status-updating');

        Swal.fire({
            title: isApprove ? 'Approving...' : 'Rejecting...',
            text: isApprove ? 'Sending confirmation email to user...' : 'Updating status...',
            allowOutsideClick: false,
            allowEscapeKey: false,
            didOpen: () => Swal.showLoading()
        });

        fetch('viewUser.jsp?action=' + action + '&bid=' + bid, {
            method: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => {
            if (!res.ok) throw new Error('Server error: HTTP ' + res.status);
            return res.json();
        })
        .then(data => {
            row.classList.remove('status-updating');

            const badge     = document.getElementById('badge-' + bid);
            const newStatus = data.status;

            // Update badge colour
            badge.textContent = newStatus;
            badge.className   = 'badge ' + (newStatus === 'Approved' ? 'bg-success' : 'bg-danger');

            // Update action buttons based on new status
            const actionCell = document.getElementById('action-' + bid);
            if (newStatus === 'Approved') {
                actionCell.innerHTML =
                    `<button class="btn btn-sm btn-outline-primary btn-resend"
                             onclick="resendMail('${bid}', '${userName}')">
                         <i class="fa fa-envelope me-1"></i>Resend Mail
                     </button>`;
            } else if (newStatus === 'Rejected') {
                actionCell.innerHTML =
                    `<button class="btn btn-sm btn-outline-warning"
                             onclick="handleAction('${bid}', 'approve', '${userName}')">
                         <i class="fa fa-redo me-1"></i>Re-approve
                     </button>`;
            }

            // Update filter data attribute
            row.dataset.status = newStatus;
            refreshCounters();

            // Show result alert
            if (newStatus === 'Approved') {
                const mailMsg = data.mailSent
                    ? '<br><span style="color:#198754"><i class="fa fa-envelope"></i> ✅ Confirmation email sent to user.</span>'
                    : '<br><span style="color:#dc3545"><i class="fa fa-envelope"></i> ⚠️ Approved but email failed: ' + (data.mailError || 'unknown error') + '</span>';
                Swal.fire({
                    icon: data.mailSent ? 'success' : 'warning',
                    title: 'Booking Approved!',
                    html: `Booking for <strong>${userName}</strong> approved.` + mailMsg,
                    confirmButtonColor: '#198754',
                    timer: 5000,
                    timerProgressBar: true
                });
            } else {
                Swal.fire({
                    icon: 'info',
                    title: 'Booking Rejected',
                    text: `Booking for ${userName} has been rejected. Slot is now available.`,
                    confirmButtonColor: '#6c757d',
                    timer: 3000,
                    timerProgressBar: true
                });
            }
        })
        .catch(err => {
            row.classList.remove('status-updating');
            Swal.fire({
                icon: 'error',
                title: 'Action Failed',
                html: `<b>${err.message}</b><br><small>Please refresh the page and try again.</small>`,
                confirmButtonColor: '#dc3545'
            });
        });
    });
}

// ─── Resend Mail ──────────────────────────────────────────────────────────────
function resendMail(bid, userName) {
    Swal.fire({
        title: 'Resend Confirmation?',
        html: `Resend booking confirmation email to <strong>${userName}</strong>?`,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#0d6efd',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Yes, Resend',
        cancelButtonText: 'Cancel'
    }).then(result => {
        if (!result.isConfirmed) return;

        Swal.fire({
            title: 'Sending Email...',
            text: 'Please wait...',
            allowOutsideClick: false,
            allowEscapeKey: false,
            didOpen: () => Swal.showLoading()
        });

        fetch('viewUser.jsp?sendMail=' + bid, {
            method: 'GET',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(res => res.json())
        .then(data => {
            if (data.mailSent) {
                Swal.fire({
                    icon: 'success',
                    title: 'Email Sent!',
                    html: `Confirmation email resent to <strong>${userName}</strong> successfully.`,
                    confirmButtonColor: '#0d6efd',
                    timer: 4000,
                    timerProgressBar: true
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Email Failed!',
                    html: `Could not send email.<br><small>${data.mailError || 'Unknown error'}</small>`,
                    confirmButtonColor: '#dc3545'
                });
            }
        })
        .catch(err => {
            Swal.fire({
                icon: 'error',
                title: 'Request Failed',
                text: err.message,
                confirmButtonColor: '#dc3545'
            });
        });
    });
}

// ─── Refresh summary counters ─────────────────────────────────────────────────
function refreshCounters() {
    let total = 0, pending = 0, approved = 0, rejected = 0;
    document.querySelectorAll('#bookingTable tbody tr[data-status]').forEach(row => {
        const s = row.dataset.status;
        total++;
        if (s === 'Pending')  pending++;
        if (s === 'Approved') approved++;
        if (s === 'Rejected') rejected++;
    });
    document.getElementById('countTotal').textContent    = total;
    document.getElementById('countPending').textContent  = pending;
    document.getElementById('countApproved').textContent = approved;
    document.getElementById('countRejected').textContent = rejected;
}
</script>
</body>
</html>
