<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Dashboard</title>

<!-- Bootstrap 5 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
body {
    background-color: #f4f6f9;
}

.sidebar {
    height: 100vh;
    background: #212529;
    color: white;
}

.sidebar a {
    color: #adb5bd;
    text-decoration: none;
    display: block;
    padding: 12px 20px;
}

.sidebar a:hover {
    background: #343a40;
    color: white;
}

.card-hover:hover {
    transform: translateY(-5px);
    transition: 0.3s;
}

.topbar {
    background: white;
    padding: 15px 20px;
    box-shadow: 0px 2px 10px rgba(0,0,0,0.1);
}
</style>

</head>
<body>

<div class="container-fluid">
    <div class="row">

        <%@ include file="sidebar.jsp" %>
        <!-- Main Content -->
        <div class="col-md-10 p-0">

        <%@ include file="Topbar.jsp" %>


            <!-- Dashboard Cards -->
            <div class="container mt-4">
                <div class="row g-4">

                    <div class="col-md-3">
                        <div class="card text-white bg-primary shadow card-hover">
                            <div class="card-body">
                                <h5>Total Users</h5>
                                <h3>120</h3>
                                <i class="bi bi-people fs-1"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card text-white bg-success shadow card-hover">
                            <div class="card-body">
                                <h5>Total Jobs</h5>
                                <h3>85</h3>
                                <i class="bi bi-briefcase fs-1"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card text-white bg-warning shadow card-hover">
                            <div class="card-body">
                                <h5>Applications</h5>
                                <h3>230</h3>
                                <i class="bi bi-file-earmark-text fs-1"></i>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="card text-white bg-danger shadow card-hover">
                            <div class="card-body">
                                <h5>Messages</h5>
                                <h3>15</h3>
                                <i class="bi bi-envelope fs-1"></i>
                            </div>
                        </div>
                    </div>

                </div>

                <!-- Recent Activity Table -->
                <div class="card mt-5 shadow">
                    <div class="card-header bg-dark text-white">
                        Recent Users
                    </div>
                    <div class="card-body">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                </div>

            </div>

        </div>

    </div>
</div>

</body>
</html>