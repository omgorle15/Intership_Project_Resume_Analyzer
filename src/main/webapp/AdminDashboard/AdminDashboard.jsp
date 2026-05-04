<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page session="true" %>

<%
// Security check
if(session.getAttribute("userRole") == null ||
   !session.getAttribute("userRole").equals("admin")){
    response.sendRedirect("../SignIn.jsp");
    return;
}

int totalMentors = 0;
int pendingMentors = 0;
int approvedMentors = 0;

try(Connection con = DBConnection.getConnection()) {
    PreparedStatement ps1 = con.prepareStatement(
        "SELECT COUNT(*) FROM users WHERE role='mentor'"
    );
    ResultSet rs1 = ps1.executeQuery();
    if(rs1.next()) totalMentors = rs1.getInt(1);

    PreparedStatement ps2 = con.prepareStatement(
        "SELECT COUNT(*) FROM users WHERE role='mentor' AND status='pending'"
    );
    ResultSet rs2 = ps2.executeQuery();
    if(rs2.next()) pendingMentors = rs2.getInt(1);

    PreparedStatement ps3 = con.prepareStatement(
        "SELECT COUNT(*) FROM users WHERE role='mentor' AND status='approved'"
    );
    ResultSet rs3 = ps3.executeQuery();
    if(rs3.next()) approvedMentors = rs3.getInt(1);

} catch(Exception e) {}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style>
body { background-color: #f4f6f9; }
.sidebar { height: 100vh; background: #212529; color: white; }
.sidebar a { color: #adb5bd; text-decoration: none; display: block; padding: 12px 20px; }
.sidebar a:hover { background: #343a40; color: white; }
.card-hover:hover { transform: translateY(-5px); transition: 0.3s; }
.topbar { background: white; padding: 15px 20px; box-shadow: 0px 2px 10px rgba(0,0,0,0.1); }
</style>
</head>
<body>

<div class="container-fluid">
    <div class="row">

        <%@ include file="sidebar.jsp" %>

        <div class="col-md-10 p-0">

            <%@ include file="Topbar.jsp" %>

            <div class="container mt-4">

                <!-- Login Success Alert -->
                <% if("success".equals(request.getParameter("login"))) { %>
                <script>
                document.addEventListener("DOMContentLoaded", function(){
                    Swal.fire({
                        icon: 'success',
                        title: 'Welcome Admin!',
                        text: 'You are logged in successfully.',
                        timer: 2500,
                        timerProgressBar: true,
                        showConfirmButton: false
                    }).then(() => {
                        // Remove ?login=success from URL so popup never shows again on reload
                        window.history.replaceState({}, document.title, "AdminDashboard.jsp");
                    });
                });
                </script>
                <% } %>

                <!-- Stats Cards -->
                <div class="row g-4 mb-4">

                    <div class="col-md-4">
                        <div class="card text-white bg-primary shadow card-hover rounded-4">
                            <div class="card-body py-4">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="mb-1">Total Mentors</h6>
                                        <h2 class="fw-bold mb-0"><%= totalMentors %></h2>
                                    </div>
                                    <i class="bi bi-people fs-1 opacity-50"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card text-white bg-warning shadow card-hover rounded-4">
                            <div class="card-body py-4">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="mb-1">Pending Mentors</h6>
                                        <h2 class="fw-bold mb-0"><%= pendingMentors %></h2>
                                    </div>
                                    <i class="bi bi-hourglass-split fs-1 opacity-50"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card text-white bg-success shadow card-hover rounded-4">
                            <div class="card-body py-4">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="mb-1">Approved Mentors</h6>
                                        <h2 class="fw-bold mb-0"><%= approvedMentors %></h2>
                                    </div>
                                    <i class="bi bi-person-check fs-1 opacity-50"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- Mentor Table -->
                <div class="card shadow rounded-4">
                    <div class="card-header bg-dark text-white d-flex 
                                justify-content-between align-items-center">
                        <span>
                            <i class="bi bi-people me-2"></i>
                            Mentor Applications
                        </span>
                        <a href="ViewMentor.jsp" 
                           class="btn btn-sm btn-outline-light">
                            View All
                        </a>
                    </div>
                    <div class="card-body table-responsive">
                        <table class="table table-hover table-bordered 
                                      align-middle text-center mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Current Status</th>
                                    <th>Change Status</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                            try(Connection con2 = DBConnection.getConnection()) {
                                PreparedStatement ps = con2.prepareStatement(
                                    "SELECT id, name, email, status FROM users " +
                                    "WHERE role='mentor' ORDER BY id DESC"
                                );
                                ResultSet rs = ps.executeQuery();
                                boolean hasData = false;

                                while(rs.next()) {
                                    hasData = true;
                                    String st = rs.getString("status");
                                    String badgeColor = 
                                        "pending".equalsIgnoreCase(st)  ? "warning" :
                                        "approved".equalsIgnoreCase(st) ? "success" : 
                                        "danger";
                            %>
                                <tr>
                                    <td class="text-muted small">
                                        <%= rs.getInt("id") %>
                                    </td>
                                    <td class="fw-semibold">
                                        <%= rs.getString("name") %>
                                    </td>
                                    <td class="text-muted small">
                                        <%= rs.getString("email") %>
                                    </td>
                                    <td>
                                        <span class="badge bg-<%= badgeColor %> px-3 py-2">
                                            <%
                                            if("pending".equalsIgnoreCase(st)) {
                                                out.print("Pending");
                                            } else if("approved".equalsIgnoreCase(st)) {
                                                out.print("Approved");
                                            } else {
                                                out.print("Rejected");
                                            }
                                            %>
                                        </span>
                                    </td>
                                    <td>
                                        <form action="updateStatusMentor.jsp" 
                                              method="post">
                                            <input type="hidden" 
                                                   name="id" 
                                                   value="<%= rs.getInt("id") %>">
                                            <select name="status"
                                                    class="form-select form-select-sm"
                                                    onchange="confirmChange(this)">
                                                <option value="pending"
                                                    <%= "pending".equalsIgnoreCase(st) ? "selected" : "" %>>
                                                    Pending
                                                </option>
                                                <option value="approved"
                                                    <%= "approved".equalsIgnoreCase(st) ? "selected" : "" %>>
                                                    Approved
                                                </option>
                                                <option value="rejected"
                                                    <%= "rejected".equalsIgnoreCase(st) ? "selected" : "" %>>
                                                    Rejected
                                                </option>
                                            </select>
                                        </form>
                                    </td>
                                </tr>
                            <%
                                }
                                if(!hasData) {
                            %>
                                <tr>
                                    <td colspan="5" class="text-muted py-4">
                                        <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                                        No mentor applications yet!
                                    </td>
                                </tr>
                            <%
                                }
                            } catch(Exception e) {
                                out.println("<tr><td colspan='5' class='text-danger'>" +
                                           "DB Error: " + e.getMessage() + 
                                           "</td></tr>");
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
<script>
function confirmChange(selectElement) {
    const newStatus = selectElement.value;
    const form = selectElement.closest('form');
    const row = selectElement.closest('tr');
    const mentorName = row.querySelector('td:nth-child(2)').innerText;

    const icons = {
        'approved': 'success',
        'pending':  'warning',
        'rejected': 'error'
    };
    const colors = {
        'approved': '#3085d6',
        'pending':  '#f0ad4e',
        'rejected': '#d33'
    };
    const labels = {
        'approved': '✅ Approved',
        'pending':  '⏳ Pending',
        'rejected': '❌ Rejected'
    };

    Swal.fire({
        icon: icons[newStatus],
        title: 'Change Mentor Status?',
        html: `Change <b>${mentorName}</b> to <b>${labels[newStatus]}</b>?`,
        showCancelButton: true,
        confirmButtonColor: colors[newStatus],
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Yes, Change!',
        cancelButtonText: 'Cancel'
    }).then((result) => {
        if(result.isConfirmed) {
            form.submit();
        } else {
            location.reload();
        }
    });
}
</script>

</body>
</html>