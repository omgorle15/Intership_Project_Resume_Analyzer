<%@ include file="layout.jsp" %>

<style>
.form-container { max-width: 1100px; margin: 40px auto; }
.card-custom { background: #ffffff; border: none; border-radius: 20px; box-shadow: 0 15px 40px rgba(0,0,0,0.08); }
.section-title { font-weight: 600; font-size: 18px; color: #198754; margin-top: 25px; margin-bottom: 15px; position: relative; }
.section-title::after { content: ""; width: 50px; height: 3px; background: #198754; position: absolute; left: 0; bottom: -6px; border-radius: 10px; }
.form-control, .form-select { border-radius: 12px; padding: 10px 15px; }
.education-block { background: #f9fbfd; border: 1px solid #e3e8ee; border-radius: 15px; }
.btn-custom { border-radius: 30px; padding: 10px 35px; font-weight: 500; }

/* Validation styles */
.form-control.is-invalid, .form-select.is-invalid { border-color: #dc3545; background-image: none; }
.form-control.is-valid,   .form-select.is-valid   { border-color: #198754; background-image: none; }
.invalid-msg { color: #dc3545; font-size: 0.78rem; margin-top: 4px; display: none; }
.invalid-msg.show { display: block; }
.char-count { font-size: 0.75rem; color: #6c757d; text-align: right; margin-top: 2px; }
.char-count.warn { color: #dc3545; }
</style>

<div class="form-container">
<div class="card shadow-lg card-custom p-4">

<h3 class="text-center fw-bold mb-4">Professional Resume Builder</h3>

<form id="resumeForm" action="saveResume.jsp" method="post" novalidate>

<!-- ================= Personal Info ================= -->
<div class="section-title">Personal Information</div>

<div class="row">
    <!-- Full Name -->
    <div class="col-md-6 mb-3">
        <input type="text" id="name" name="name" class="form-control"
               placeholder="Full Name" maxlength="60" required>
        <div class="invalid-msg" id="nameErr">
            <i class="fa fa-exclamation-circle me-1"></i>Full name is required (letters only, max 60 chars).
        </div>
    </div>

    <!-- Email -->
    <div class="col-md-6 mb-3">
        <input type="email" id="email" name="email" class="form-control"
               placeholder="Email" maxlength="100" required>
        <div class="invalid-msg" id="emailErr">
            <i class="fa fa-exclamation-circle me-1"></i>Enter a valid email address (e.g. name@example.com).
        </div>
    </div>

    <!-- Phone — 10 digits only -->
    <div class="col-md-6 mb-3">
        <input type="tel" id="phone" name="phone" class="form-control"
               placeholder="Phone (10 digits)" maxlength="10" required>
        <div class="invalid-msg" id="phoneErr">
            <i class="fa fa-exclamation-circle me-1"></i>Phone must be exactly 10 digits (numbers only).
        </div>
    </div>

    <!-- Location -->
    <div class="col-md-6 mb-3">
        <input type="text" id="address" name="address" class="form-control"
               placeholder="Location (City, State)" maxlength="100">
        <div class="invalid-msg" id="addressErr">
            <i class="fa fa-exclamation-circle me-1"></i>Location cannot exceed 100 characters.
        </div>
    </div>

    <!-- LinkedIn -->
    <div class="col-md-12 mb-3">
        <input type="text" id="linkedin" name="linkedin" class="form-control"
               placeholder="LinkedIn URL (e.g. https://linkedin.com/in/yourname)" maxlength="200">
        <div class="invalid-msg" id="linkedinErr">
            <i class="fa fa-exclamation-circle me-1"></i>Enter a valid LinkedIn URL (must start with https://linkedin.com/in/).
        </div>
    </div>
</div>

<!-- ================= Summary ================= -->
<div class="section-title">Professional Summary</div>
<textarea id="objective" name="objective" class="form-control mb-1"
          rows="3" maxlength="800"
          placeholder="Write 2 to 4 lines about your professional background and goals..." required></textarea>
<div class="char-count" id="objectiveCount">0 / 800</div>
<div class="invalid-msg" id="objectiveErr">
    <i class="fa fa-exclamation-circle me-1"></i>Summary is required (minimum 30 characters).
</div>

<!-- ================= Education ================= -->
<div class="section-title">Education</div>
<div id="educationSection">
    <div class="education-block p-3 mb-3">
        <div class="row">
            <div class="col-md-6 mb-2">
                <input type="text" name="degree" class="form-control edu-degree"
                       placeholder="Degree (e.g. B.E. Computer Science)" maxlength="100" required>
                <div class="invalid-msg">
                    <i class="fa fa-exclamation-circle me-1"></i>Degree is required.
                </div>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="college" class="form-control edu-college"
                       placeholder="College / University" maxlength="120" required>
                <div class="invalid-msg">
                    <i class="fa fa-exclamation-circle me-1"></i>College name is required.
                </div>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="year" class="form-control edu-year"
                       placeholder="Passing Year (e.g. 2024)" maxlength="4">
                <div class="invalid-msg">
                    <i class="fa fa-exclamation-circle me-1"></i>Enter a valid 4-digit year (2000–2035).
                </div>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="cgpa" class="form-control edu-cgpa"
                       placeholder="CGPA (e.g. 8.5) or Percentage (e.g. 85%)" maxlength="10">
                <div class="invalid-msg">
                    <i class="fa fa-exclamation-circle me-1"></i>Enter CGPA (0–10) or percentage (0–100%).
                </div>
            </div>
        </div>
    </div>
</div>
<button type="button" class="btn btn-outline-success btn-sm mb-3"
        onclick="addEducation()">+ Add More Education</button>

<!-- ================= Experience & Skills ================= -->
<div class="row">
    <!-- Experience -->
    <div class="col-md-6">
        <div class="section-title">Experience</div>
        <select name="experienceType" id="experienceType"
                class="form-select mb-3" onchange="toggleExperienceFields()" required>
            <option value="">-- Select --</option>
            <option value="Fresher">Fresher</option>
            <option value="Experienced">Experienced</option>
        </select>
        <div class="invalid-msg" id="expTypeErr">
            <i class="fa fa-exclamation-circle me-1"></i>Please select your experience type.
        </div>

        <div id="experienceFields" style="display:none;">
            <input type="text" id="company" name="company" class="form-control mb-2"
                   placeholder="Company Name" maxlength="100">
            <div class="invalid-msg" id="companyErr">
                <i class="fa fa-exclamation-circle me-1"></i>Company name is required for experienced candidates.
            </div>

            <input type="text" id="jobRole" name="jobRole" class="form-control mb-2"
                   placeholder="Job Role" maxlength="80">
            <div class="invalid-msg mb-2" id="jobRoleErr">
                <i class="fa fa-exclamation-circle me-1"></i>Job role is required for experienced candidates.
            </div>

            <input type="text" id="duration" name="duration" class="form-control mb-2"
                   placeholder="Duration (e.g. Jan 2022 – Dec 2023)" maxlength="50">

            <textarea id="jobDescription" name="jobDescription" class="form-control mb-3"
                      rows="3" maxlength="600"
                      placeholder="Describe your responsibilities..."></textarea>
            <div class="char-count" id="jobDescCount">0 / 600</div>
        </div>
    </div>

    <!-- Skills -->
    <div class="col-md-6">
        <div class="section-title">Skills</div>
        <input type="text" id="skills" name="skills" class="form-control mb-1"
               placeholder="Java, Spring Boot, MySQL" maxlength="300" required>
        <div class="invalid-msg" id="skillsErr">
            <i class="fa fa-exclamation-circle me-1"></i>Please enter at least one skill.
        </div>
        <small class="text-muted">Separate skills with commas.</small>
    </div>
</div>

<!-- ================= Projects & Certifications ================= -->
<div class="row mt-3">
    <div class="col-md-6">
        <div class="section-title">Projects</div>
        <textarea id="projects" name="projects" class="form-control mb-1"
                  rows="4" maxlength="800"
                  placeholder="Project name, tech stack, brief description..."></textarea>
        <div class="char-count" id="projectsCount">0 / 800</div>
    </div>
    <div class="col-md-6">
        <div class="section-title">Certifications</div>
        <textarea id="certifications" name="certifications" class="form-control mb-1"
                  rows="4" maxlength="500"
                  placeholder="e.g. AWS Certified Developer, 2023"></textarea>
        <div class="char-count" id="certsCount">0 / 500</div>
    </div>
</div>

<!-- ================= Submit ================= -->
<div class="text-center mt-4">
    <button type="submit" class="btn btn-success btn-custom shadow">
        Generate Resume
    </button>
</div>

</form>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>

// ─── Helper: mark field valid/invalid ────────────────────────────────────────
function setValid(el, errEl) {
    el.classList.remove('is-invalid');
    el.classList.add('is-valid');
    if (errEl) { errEl.classList.remove('show'); }
}
function setInvalid(el, errEl) {
    el.classList.add('is-invalid');
    el.classList.remove('is-valid');
    if (errEl) { errEl.classList.add('show'); }
}
function clearState(el, errEl) {
    el.classList.remove('is-invalid', 'is-valid');
    if (errEl) errEl.classList.remove('show');
}

// ─── Individual field validators ─────────────────────────────────────────────
function validateName() {
    const el  = document.getElementById('name');
    const err = document.getElementById('nameErr');
    const v   = el.value.trim();
    if (!v || !/^[a-zA-Z\s.'-]{2,60}$/.test(v)) { setInvalid(el, err); return false; }
    setValid(el, err); return true;
}

function validateEmail() {
    const el  = document.getElementById('email');
    const err = document.getElementById('emailErr');
    const v   = el.value.trim();
    if (!v || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)) { setInvalid(el, err); return false; }
    setValid(el, err); return true;
}

function validatePhone() {
    const el  = document.getElementById('phone');
    const err = document.getElementById('phoneErr');
    // Strip non-digits as user types
    el.value  = el.value.replace(/\D/g, '');
    const v   = el.value.trim();
    if (!/^\d{10}$/.test(v)) { setInvalid(el, err); return false; }
    setValid(el, err); return true;
}

function validateAddress() {
    const el  = document.getElementById('address');
    const err = document.getElementById('addressErr');
    const v   = el.value.trim();
    if (v.length > 100) { setInvalid(el, err); return false; }
    if (v) setValid(el, err); else clearState(el, err);
    return true;
}

function validateLinkedIn() {
    const el  = document.getElementById('linkedin');
    const err = document.getElementById('linkedinErr');
    const v   = el.value.trim();
    if (!v) { clearState(el, err); return true; } // optional field
    if (!/^https:\/\/(www\.)?linkedin\.com\/in\/.+/.test(v)) {
        setInvalid(el, err); return false;
    }
    setValid(el, err); return true;
}

function validateObjective() {
    const el  = document.getElementById('objective');
    const err = document.getElementById('objectiveErr');
    const v   = el.value.trim();
    if (!v || v.length < 30) { setInvalid(el, err); return false; }
    setValid(el, err); return true;
}

function validateExpType() {
    const el  = document.getElementById('experienceType');
    const err = document.getElementById('expTypeErr');
    if (!el.value) { setInvalid(el, err); return false; }
    setValid(el, err); return true;
}

function validateExperienceFields() {
    const type = document.getElementById('experienceType').value;
    if (type !== 'Experienced') return true;

    const company  = document.getElementById('company');
    const compErr  = document.getElementById('companyErr');
    const jobRole  = document.getElementById('jobRole');
    const roleErr  = document.getElementById('jobRoleErr');
    let ok = true;

    if (!company.value.trim())  { setInvalid(company, compErr); ok = false; }
    else                         { setValid(company, compErr); }
    if (!jobRole.value.trim())  { setInvalid(jobRole, roleErr); ok = false; }
    else                         { setValid(jobRole, roleErr); }
    return ok;
}

function validateSkills() {
    const el  = document.getElementById('skills');
    const err = document.getElementById('skillsErr');
    const v   = el.value.trim();
    if (!v) { setInvalid(el, err); return false; }
    setValid(el, err); return true;
}

// ─── Education row validation ─────────────────────────────────────────────────
function validateEducationBlocks() {
    let ok = true;
    document.querySelectorAll('.education-block').forEach(block => {
        const degreeEl = block.querySelector('.edu-degree');
        const collegeEl = block.querySelector('.edu-college');
        const yearEl   = block.querySelector('.edu-year');
        const cgpaEl   = block.querySelector('.edu-cgpa');

        const degreeErr  = degreeEl  ? degreeEl.nextElementSibling  : null;
        const collegeErr = collegeEl ? collegeEl.nextElementSibling : null;
        const yearErr    = yearEl    ? yearEl.nextElementSibling    : null;
        const cgpaErr    = cgpaEl    ? cgpaEl.nextElementSibling    : null;

        if (degreeEl && !degreeEl.value.trim())  { setInvalid(degreeEl, degreeErr);  ok = false; }
        else if (degreeEl) setValid(degreeEl, degreeErr);

        if (collegeEl && !collegeEl.value.trim()) { setInvalid(collegeEl, collegeErr); ok = false; }
        else if (collegeEl) setValid(collegeEl, collegeErr);

        if (yearEl && yearEl.value.trim()) {
            const y = parseInt(yearEl.value.trim());
            if (!/^\d{4}$/.test(yearEl.value.trim()) || y < 2000 || y > 2035) {
                setInvalid(yearEl, yearErr); ok = false;
            } else setValid(yearEl, yearErr);
        }

        if (cgpaEl && cgpaEl.value.trim()) {
            const v = cgpaEl.value.trim();
            const isPercent = v.endsWith('%');
            const num = parseFloat(isPercent ? v.slice(0,-1) : v);
            const valid = !isNaN(num) && (isPercent ? num >= 0 && num <= 100 : num >= 0 && num <= 10);
            if (!valid) { setInvalid(cgpaEl, cgpaErr); ok = false; }
            else setValid(cgpaEl, cgpaErr);
        }
    });
    return ok;
}

// ─── Experience toggle ────────────────────────────────────────────────────────
function toggleExperienceFields() {
    const type   = document.getElementById('experienceType').value;
    const fields = document.getElementById('experienceFields');
    fields.style.display = (type === 'Experienced') ? 'block' : 'none';
    validateExpType();
    // Clear required-field errors if switched back to Fresher
    if (type !== 'Experienced') {
        ['company','jobRole'].forEach(id => {
            const el = document.getElementById(id);
            if (el) clearState(el, document.getElementById(id + 'Err'));
        });
    }
}

// ─── Add education block ──────────────────────────────────────────────────────
function addEducation() {
    const container = document.getElementById('educationSection');
    const block = document.createElement('div');
    block.classList.add('education-block', 'p-3', 'mb-3');
    block.innerHTML = `
        <div class="row">
            <div class="col-md-6 mb-2">
                <input type="text" name="degree" class="form-control edu-degree"
                       placeholder="Degree (e.g. B.E. Computer Science)" maxlength="100" required>
                <div class="invalid-msg"><i class="fa fa-exclamation-circle me-1"></i>Degree is required.</div>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="college" class="form-control edu-college"
                       placeholder="College / University" maxlength="120" required>
                <div class="invalid-msg"><i class="fa fa-exclamation-circle me-1"></i>College name is required.</div>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="year" class="form-control edu-year"
                       placeholder="Passing Year (e.g. 2024)" maxlength="4">
                <div class="invalid-msg"><i class="fa fa-exclamation-circle me-1"></i>Enter a valid 4-digit year (2000–2035).</div>
            </div>
            <div class="col-md-6 mb-2">
                <input type="text" name="cgpa" class="form-control edu-cgpa"
                       placeholder="CGPA (e.g. 8.5) or Percentage (e.g. 85%)" maxlength="10">
                <div class="invalid-msg"><i class="fa fa-exclamation-circle me-1"></i>Enter CGPA (0–10) or percentage (0–100%).</div>
            </div>
            <div class="col-md-12 text-end">
                <button type="button" class="btn btn-danger btn-sm"
                        onclick="this.closest('.education-block').remove()">Remove</button>
            </div>
        </div>`;
    container.appendChild(block);
    attachLiveValidation();
}

// ─── Character counters ───────────────────────────────────────────────────────
function attachCharCounter(id, counterId, max) {
    const el = document.getElementById(id);
    const counter = document.getElementById(counterId);
    if (!el || !counter) return;
    el.addEventListener('input', () => {
        const len = el.value.length;
        counter.textContent = len + ' / ' + max;
        counter.classList.toggle('warn', len >= max * 0.9);
    });
}
attachCharCounter('objective',      'objectiveCount', 800);
attachCharCounter('jobDescription', 'jobDescCount',   600);
attachCharCounter('projects',       'projectsCount',  800);
attachCharCounter('certifications', 'certsCount',     500);

// ─── Live validation listeners ────────────────────────────────────────────────
function attachLiveValidation() {
    const fields = [
        { id: 'name',     fn: validateName    },
        { id: 'email',    fn: validateEmail   },
        { id: 'phone',    fn: validatePhone   },
        { id: 'address',  fn: validateAddress },
        { id: 'linkedin', fn: validateLinkedIn},
        { id: 'objective',fn: validateObjective},
        { id: 'skills',   fn: validateSkills  },
        { id: 'experienceType', fn: validateExpType },
        { id: 'company',  fn: validateExperienceFields },
        { id: 'jobRole',  fn: validateExperienceFields },
    ];
    fields.forEach(({ id, fn }) => {
        const el = document.getElementById(id);
        if (el) {
            el.addEventListener('blur',  fn);
            el.addEventListener('input', fn);
        }
    });

    // Education fields live validation
    document.querySelectorAll('.edu-degree, .edu-college, .edu-year, .edu-cgpa')
        .forEach(el => el.addEventListener('blur', validateEducationBlocks));
}
attachLiveValidation();

// ─── Form submit: run all validations ────────────────────────────────────────
document.getElementById('resumeForm').addEventListener('submit', function (e) {
    const checks = [
        validateName(),
        validateEmail(),
        validatePhone(),
        validateAddress(),
        validateLinkedIn(),
        validateObjective(),
        validateExpType(),
        validateExperienceFields(),
        validateSkills(),
        validateEducationBlocks()
    ];

    const allValid = checks.every(Boolean);

    if (!allValid) {
        e.preventDefault();
        e.stopPropagation();

        // Scroll to first invalid field
        const firstInvalid = document.querySelector('.is-invalid');
        if (firstInvalid) {
            firstInvalid.scrollIntoView({ behavior: 'smooth', block: 'center' });
            firstInvalid.focus();
        }

        Swal.fire({
            icon: 'warning',
            title: 'Please Fix the Errors!',
            html: 'Some fields have invalid or missing values.<br>' +
                  '<small class="text-muted">Fields highlighted in red need your attention.</small>',
            confirmButtonColor: '#198754',
            confirmButtonText: 'Fix Now'
        });
    }
});
</script>

<%@ include file="layoutFooter.jsp" %>
