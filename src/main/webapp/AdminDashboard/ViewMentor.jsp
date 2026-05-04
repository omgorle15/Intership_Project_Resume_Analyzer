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

String search = request.getParameter("search");
String filterStatus = request.getParameter("status");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mentor Management</title>
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

            <!-- Page Title -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h4 class="fw-bold mb-0">
                        <i class="bi bi-people me-2 text-primary"></i>
                        Manage Mentors
                    </h4>
                    <small class="text-muted">
                        View and control all mentor accounts
                    </small>
                </div>
                <a href="AdminDashboard.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-1"></i> Back to Dashboard
                </a>
            </div>

            <!-- Filter Card -->
            <div class="card shadow rounded-4 mb-4">
                <div class="card-body">
                    <form method="get" class="row g-3 align-items-end">

                        <div class="col-md-5">
                            <label class="form-label text-muted small fw-semibold">
                                Search Mentor
                            </label>
                            <div class="input-group">
                                <span class="input-group-text bg-white">
                                    <i class="bi bi-search text-muted"></i>
                                </span>
                                <input type="search" name="search"
                                       class="form-control border-start-0"
                                       placeholder="Search by name or email"
                                       value="<%= search == null ? "" : search %>">
                            </div>
                        </div>

                        <div class="col-md-4">
                            <label class="form-label text-muted small fw-semibold">
                                Filter by Status
                            </label>
                            <select name="status" class="form-select">
                                <option value="">All Status</option>
                                <option value="pending"
                                    <%= "pending".equals(filterStatus) ? "selected" : "" %>>
                                    ⏳ Pending
                                </option>
                                <option value="approved"
                                    <%= "approved".equals(filterStatus) ? "selected" : "" %>>
                                    ✅ Approved
                                </option>
                                <option value="rejected"
                                    <%= "rejected".equals(filterStatus) ? "selected" : "" %>>
                                    ❌ Rejected
                                </option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <button class="btn btn-primary w-100">
                                <i class="bi bi-funnel me-1"></i> Filter
                            </button>
                        </div>

                        <div class="col-md-1">
                            <a href="ViewMentor.jsp" class="btn btn-outline-secondary w-100"
                               title="Clear filters">
                                <i class="bi bi-x-lg"></i>
                            </a>
                        </div>

                    </form>
                </div>
            </div>

            <!-- Mentor Table Card -->
            <div class="card shadow rounded-4">
                <div class="card-header bg-dark text-white d-flex
                            justify-content-between align-items-center">
                    <span>
                        <i class="bi bi-table me-2"></i>Mentor List
                    </span>
                </div>
                <div class="card-body table-responsive p-0">
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
try(Connection con = DBConnection.getConnection()){

    String sql = "SELECT id, name, email, status FROM users WHERE role='mentor'";

    if(search != null && !search.trim().isEmpty()){
        sql += " AND (name LIKE ? OR email LIKE ?)";
    }
    if(filterStatus != null && !filterStatus.isEmpty()){
        sql += " AND status = ?";
    }
    sql += " ORDER BY id DESC";

    PreparedStatement ps = con.prepareStatement(sql);
    int index = 1;

    if(search != null && !search.trim().isEmpty()){
        ps.setString(index++, "%" + search + "%");
        ps.setString(index++, "%" + search + "%");
    }
    if(filterStatus != null && !filterStatus.isEmpty()){
        ps.setString(index++, filterStatus);
    }

    ResultSet rs = ps.executeQuery();
    boolean hasData = false;

    while(rs.next()){
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
                                        if("pending".equalsIgnoreCase(st)){
                                            out.print("Pending");
                                        } else if("approved".equalsIgnoreCase(st)){
                                            out.print("Approved");
                                        } else {
                                            out.print("Rejected");
                                        }
                                        %>
                                    </span>
                                </td>
                                <td>
                                    <form action="updateStatusMentor.jsp" method="post">
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
    if(!hasData){
%>
                            <tr>
                                <td colspan="5" class="text-muted py-5">
                                    <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                    No mentors found!
                                </td>
                            </tr>
<%
    }
} catch(Exception e){
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