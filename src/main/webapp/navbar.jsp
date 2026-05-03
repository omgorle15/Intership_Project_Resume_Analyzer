<%
String currentPage = request.getRequestURI();
%>

<header id="header" class="header d-flex align-items-center sticky-top">
  <div class="container-fluid container-xl position-relative d-flex align-items-center">

    <a href="index.jsp" class="logo d-flex align-items-center me-auto">
      <img src="assets/img/project icon.jpeg" alt="icon">
      <h1 class="sitename">Job Analyzer</h1>
    </a>

    <nav id="navmenu" class="navmenu">
      <ul>

        <li>
          <a href="index.jsp" class="<%= currentPage.contains("index.jsp") ? "active" : "" %>">Home</a>
        </li>

        <li>
          <a href="about.jsp" class="<%= currentPage.contains("about.jsp") ? "active" : "" %>">About</a>
        </li>

        <li>
          <a href="HowItWorks.jsp" class="<%= currentPage.contains("HowItWorks.jsp") ? "active" : "" %>">How It Works</a>
        </li>

        <li>
          <a href="contact.jsp" class="<%= currentPage.contains("contact.jsp") ? "active" : "" %>">Contact</a>
        </li>

        <li class="dropdown">
          <a href="#"><span>Services</span> <i class="bi bi-chevron-down toggle-dropdown"></i></a>
          <ul>
            <li><a href="SignIn.jsp">Create Resume</a></li>
            <li><a href="SignIn.jsp">Modify Resume</a></li>
            <li><a href="SignIn.jsp">Suggestion for Resume</a></li>
            <li><a href="SignIn.jsp">Job Recommendation</a></li>
          </ul>
        </li>

        <li>
          <a href="SignIn.jsp" class="<%= currentPage.contains("SignIn.jsp") ? "active" : "" %>">Sign in</a>
        </li>

        <li>
          <a href="SignUp.jsp" class="<%= currentPage.contains("SignUp.jsp") ? "active" : "" %>">Sign up</a>
        </li>

      </ul>

      <i class="mobile-nav-toggle d-xl-none bi bi-list"></i>
    </nav>

    <a class="btn-getstarted" href="SignIn.jsp">Get Started</a>

  </div>
</header>