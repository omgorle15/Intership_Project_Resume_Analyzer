<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>
<%@ include file="layout.jsp" %>

<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect("SignIn.jsp");
    return;
}

if (request.getMethod().equalsIgnoreCase("POST") && request.getParameter("bookNow") != null) {
    String mpId   = request.getParameter("mentorProfileId");
    String slotId = request.getParameter("slotId");

    if (mpId != null && slotId != null && !slotId.isEmpty()) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement chk = con.prepareStatement(
                "SELECT COUNT(*) FROM mentor_booking WHERE user_id=? AND slot_id=? AND status != 'Rejected'"
            );
            chk.setInt(1, userId);
            chk.setInt(2, Integer.parseInt(slotId));
            ResultSet cr = chk.executeQuery();
            cr.next();
            if (cr.getInt(1) > 0) {
                request.setAttribute("bookMsg", "error");
                request.setAttribute("bookMsgText", "You have already booked this slot.");
            } else {
                PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO mentor_booking (mentor_profile_id, user_id, slot_id, status) VALUES (?,?,?,?)"
                );
                ins.setInt(1, Integer.parseInt(mpId));
                ins.setInt(2, userId);
                ins.setInt(3, Integer.parseInt(slotId));
                ins.setString(4, "Pending");
                ins.executeUpdate();

                PreparedStatement markSlot = con.prepareStatement(
                    "UPDATE mentor_timeslot SET status='BOOKED' WHERE slot_id=?"
                );
                markSlot.setInt(1, Integer.parseInt(slotId));
                markSlot.executeUpdate();

                request.setAttribute("bookMsg", "success");
                request.setAttribute("bookMsgText", "Booking sent! Waiting for mentor approval.");
            }
        } catch (Exception e) {
            request.setAttribute("bookMsg", "error");
            request.setAttribute("bookMsgText", "Error: " + e.getMessage());
        }
    }
}

String myBookingDay = null, myBookingTime = null, myBookingStatus = null, myMentorName = null;
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT u.name AS mname, mts.day, mts.time, mb.status " +
        "FROM mentor_booking mb " +
        "JOIN mentor_profile mp ON mb.mentor_profile_id = mp.id " +
        "JOIN users u ON mp.user_id = u.id " +
        "JOIN mentor_timeslot mts ON mb.slot_id = mts.slot_id " +
        "WHERE mb.user_id=? ORDER BY mb.booking_id DESC LIMIT 1"
    );
    ps.setInt(1, userId);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        myMentorName    = rs.getString("mname");
        myBookingDay    = rs.getString("day");
        myBookingTime   = rs.getTime("time").toString().substring(0,5);
        myBookingStatus = rs.getString("status");
    }
} catch (Exception ignore) {}

String selectedField   = request.getParameter("field");
String mentorProfileId = request.getParameter("mentorProfileId");
String loadTime        = request.getParameter("loadTime");
%>

<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <h4 class="fw-bold mb-0"><i class="bi bi-person-lines-fill me-2"></i>Book a Mentor</h4>
        <small class="text-muted">Find the right mentor and book a session</small>
    </div>
</div>

<% if (myBookingDay != null) {
    String bClass = "info"; String bIcon = "bi-clock";
    if ("Approved".equalsIgnoreCase(myBookingStatus)) { bClass = "success"; bIcon = "bi-check-circle-fill"; }
    if ("Rejected".equalsIgnoreCase(myBookingStatus)) { bClass = "danger";  bIcon = "bi-x-circle-fill"; }
%>
<div class="alert alert-<%= bClass %> rounded-4 d-flex align-items-center gap-3 mb-4">
    <i class="bi <%= bIcon %> fs-4"></i>
    <div>
        <strong>Your Latest Booking:</strong> <%= myMentorName %> —
        <%= myBookingDay %> at <%= myBookingTime %>
        <span class="badge bg-<%= bClass %> ms-2"><%= myBookingStatus %></span>
    </div>
</div>
<% } %>

<%
String bookMsg     = (String) request.getAttribute("bookMsg");
String bookMsgText = (String) request.getAttribute("bookMsgText");
if (bookMsg != null) {
%>
<div class="alert alert-<%= "success".equals(bookMsg) ? "success" : "danger" %> alert-dismissible fade show rounded-4">
    <i class="bi bi-<%= "success".equals(bookMsg) ? "check-circle" : "exclamation-circle" %> me-2"></i>
    <%= bookMsgText %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>
<% } %>

<div class="card shadow-sm border-0 rounded-4 p-4">

    <h6 class="fw-bold mb-3"><span class="badge bg-success me-2">1</span>Choose a Specialization</h6>
    <form method="get" class="mb-4">
        <div class="row g-2">
            <% String[] fields = {"Web","Java","C++","Python","Data Science","Machine Learning","UI/UX","Cloud","Android"};
               for (String f : fields) {
                   boolean checked = f.equals(selectedField); %>
            <div class="col-auto">
                <input type="radio" class="btn-check" name="field" id="f_<%= f %>"
                       value="<%= f %>" <%= checked ? "checked" : "" %> onchange="this.form.submit()">
                <label class="btn btn-outline-success rounded-3" for="f_<%= f %>"><%= f %></label>
            </div>
            <% } %>
        </div>
    </form>

    <% if (selectedField != null) { %>
    <hr>
    <h6 class="fw-bold mb-3"><span class="badge bg-success me-2">2</span>Select a Mentor</h6>
    <form method="post">
        <input type="hidden" name="field" value="<%= selectedField %>">
        <div class="row g-3 mb-3">
<%
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mp.id, u.name, mp.bio, mp.photo, mp.specialization " +
        "FROM users u " +
        "JOIN mentor_profile mp ON u.id = mp.user_id " +
        "WHERE u.role='mentor' AND u.status='approved' " +
        "AND REPLACE(LOWER(mp.specialization),' ','') LIKE ?"
    );
    ps.setString(1, "%" + selectedField.toLowerCase().replace(" ","") + "%");
    ResultSet rs = ps.executeQuery();
    boolean anyMentor = false;
    while (rs.next()) {
        anyMentor = true;
        String mPhoto = rs.getString("photo");
        String mName  = rs.getString("name");
        String mBio   = rs.getString("bio") != null ? rs.getString("bio") : "";
        String mSpec  = rs.getString("specialization") != null ? rs.getString("specialization") : "";
        int mpIdVal   = rs.getInt("id");
        boolean sel   = String.valueOf(mpIdVal).equals(mentorProfileId);
%>
            <div class="col-md-4">
                <div class="card border-2 rounded-4 h-100 p-3 <%= sel ? "border-success bg-success bg-opacity-10" : "border-light" %>"
                     style="cursor:pointer" onclick="document.getElementById('mp_<%= mpIdVal %>').click()">
                    <div class="d-flex align-items-center gap-3 mb-2">
                        <% if (mPhoto != null && !mPhoto.isEmpty()) { %>
                            <img src="../uploads/<%= mPhoto %>" style="width:50px;height:50px;border-radius:50%;object-fit:cover;">
                        <% } else { %>
                            <div style="width:50px;height:50px;border-radius:50%;background:#e9ecef;display:flex;align-items:center;justify-content:center;">
                                <i class="bi bi-person fs-4 text-secondary"></i>
                            </div>
                        <% } %>
                        <div>
                            <strong><%= mName %></strong><br>
                            <small class="text-muted"><%= mBio.length() > 60 ? mBio.substring(0,60)+"..." : mBio %></small>
                        </div>
                    </div>
                    <% for (String sp : mSpec.split(",")) { %>
                        <span class="badge bg-primary-subtle text-primary me-1 mb-1"><%= sp.trim() %></span>
                    <% } %>
                    <input type="radio" id="mp_<%= mpIdVal %>" name="mentorProfileId"
                           value="<%= mpIdVal %>" class="d-none" <%= sel ? "checked" : "" %>>
                </div>
            </div>
<%
    }
    if (!anyMentor) {
%>
            <div class="col-12">
                <div class="alert alert-warning rounded-3">No approved mentor found for <strong><%= selectedField %></strong>.</div>
            </div>
<%
    }
} catch (Exception e) {
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
}
%>
        </div>
        <button type="submit" name="loadTime" class="btn btn-success rounded-3 px-4">
            <i class="bi bi-calendar2-check me-2"></i>Show Available Slots
        </button>
    </form>
    <% } %>

    <% if (loadTime != null && mentorProfileId != null) { %>
    <hr>
    <h6 class="fw-bold mb-3"><span class="badge bg-success me-2">3</span>Pick a Time Slot</h6>
    <form method="post">
        <input type="hidden" name="mentorProfileId" value="<%= mentorProfileId %>">
        <input type="hidden" name="field" value="<%= selectedField %>">
        <div class="row g-3 mb-3">
<%
try (Connection con = DBConnection.getConnection()) {
    PreparedStatement ps = con.prepareStatement(
        "SELECT mts.slot_id, mts.day, mts.time " +
        "FROM mentor_timeslot mts " +
        "WHERE mts.mentor_profile_id=? " +
        "AND mts.status='ACTIVE' " +
        "ORDER BY FIELD(mts.day,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'), mts.time"
    );
    ps.setInt(1, Integer.parseInt(mentorProfileId));
    ResultSet rs = ps.executeQuery();
    boolean anySlot = false;
    while (rs.next()) {
        anySlot = true;
        String slotDay  = rs.getString("day");
        String slotTime = rs.getTime("time").toString().substring(0,5);
        int slotId      = rs.getInt("slot_id");
%>
            <div class="col-md-3">
                <div class="card border-2 border-light rounded-4 text-center p-3 slot-card"
                     style="cursor:pointer"
                     onclick="selectSlot(this, 'slot_<%= slotId %>')">
                    <i class="bi bi-calendar-event fs-3 text-success mb-1"></i>
                    <div class="fw-bold"><%= slotDay %></div>
                    <div class="text-muted fs-5"><%= slotTime %></div>
                    <input type="radio" id="slot_<%= slotId %>" name="slotId"
                           value="<%= slotId %>" class="d-none" required>
                </div>
            </div>
<%
    }
    if (!anySlot) {
%>
            <div class="col-12">
                <div class="alert alert-info rounded-3">
                    <i class="bi bi-info-circle me-2"></i>No available slots for this mentor right now.
                </div>
            </div>
<%
    }
} catch (Exception e) {
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
}
%>
        </div>
        <button type="submit" name="bookNow" class="btn btn-success px-5 py-2 rounded-3">
            <i class="bi bi-check2-circle me-2"></i>Confirm Booking
        </button>
    </form>
    <% } %>

</div>

<script>
function selectSlot(el, inputId) {
    document.querySelectorAll('.slot-card').forEach(c => {
        c.classList.remove('border-success','bg-success','bg-opacity-10');
        c.classList.add('border-light');
    });
    el.classList.remove('border-light');
    el.classList.add('border-success','bg-success','bg-opacity-10');
    document.getElementById(inputId).checked = true;
}
</script>

<%@ include file="layoutFooter.jsp" %>